<#
.SYNOPSIS
  Stage + commit + push the wow-config repo. Idempotent (no-op if no changes).

.DESCRIPTION
  Captures live WTF SavedVariables, bindings, Config.wtf, plus any Interface/AddOns
  and templates edits since the last checkpoint. Auto-generates a commit message
  with timestamp + diff shortstat. Pushes to origin/main unless -NoPush.

  Designed to run automatically from scripts/play.ps1 after WoW exits, or manually
  any time you want to snapshot state.

.PARAMETER NoPush
  Commit locally but don't push. Useful when offline or for staging multiple commits.

.PARAMETER Quiet
  Suppress non-error output.

.EXAMPLE
  .\scripts\checkpoint.ps1

.EXAMPLE
  .\scripts\checkpoint.ps1 -NoPush
#>
[CmdletBinding()]
param(
    [switch]$NoPush,
    [switch]$Quiet
)

# Continue (not Stop) — PowerShell treats native-command stderr as terminating
# errors when ErrorActionPreference = Stop, which makes harmless git warnings
# (e.g. "LF will be replaced by CRLF") look like failures. We have explicit
# $LASTEXITCODE checks below for the cases that actually matter.
$ErrorActionPreference = "Continue"
$RepoPath = (Resolve-Path "$PSScriptRoot/..").Path
Set-Location $RepoPath

if (-not (Test-Path ".git")) {
    Write-Error "Not a git repo: $RepoPath"
    exit 1
}

# Refuse to touch anything mid-merge/rebase/cherry-pick. `git add` stages a
# conflicted file's literal <<<<<<< markers as if they were resolved content,
# so an auto-checkpoint firing here (e.g. WoW exits while a Claude session is
# mid-conflict-resolution) can commit-and-push broken Lua straight to main.
$gitDir = git rev-parse --git-dir 2>$null
if ($gitDir) {
    $mergeInProgress = (Test-Path (Join-Path $gitDir "MERGE_HEAD")) -or
                        (Test-Path (Join-Path $gitDir "rebase-merge")) -or
                        (Test-Path (Join-Path $gitDir "rebase-apply")) -or
                        (Test-Path (Join-Path $gitDir "CHERRY_PICK_HEAD"))
    if ($mergeInProgress) {
        Write-Warning "Merge/rebase/cherry-pick in progress - skipping checkpoint (not staging, committing, or pushing). Resolve it first."
        exit 0
    }
}

# Stage tracked-content paths only - never `git add .` (could pull in random junk).
# .gitignore enforces the deny-by-default whitelist; we just narrow further to the
# directories that actually change in normal play.
$paths = @(
    "_anniversary_/WTF",
    "_anniversary_/Interface/AddOns",
    "templates"
)
foreach ($p in $paths) {
    if (Test-Path $p) {
        git add $p 2>&1 | Out-Null
    }
}

# Auto-bump TOC Version field on any addon with staged changes (idempotent;
# no-op if no addon dirs touched). Runs BEFORE the staged-shortstat check so
# the bumped TOCs are part of the same commit.
$bumpScript = Join-Path $PSScriptRoot "bump-versions.ps1"
if (Test-Path $bumpScript) { & $bumpScript -RepoRoot $RepoPath }

# Anything staged?
$diff = git diff --cached --shortstat
if (-not $diff) {
    if (-not $Quiet) { Write-Host "No changes to commit." }
    exit 0
}

# Belt-and-suspenders: never commit literal conflict markers, even if they
# somehow got staged outside the MERGE_HEAD check above.
$stagedFiles = git diff --cached --name-only
$markerHits = @()
foreach ($f in $stagedFiles) {
    if (-not (Test-Path $f)) { continue }
    $hit = Select-String -Path $f -Pattern '^(<{7}|={7}|>{7})' -SimpleMatch:$false -ErrorAction SilentlyContinue
    if ($hit) { $markerHits += $f }
}
if ($markerHits.Count -gt 0) {
    Write-Error "Unresolved conflict markers staged in: $($markerHits -join ', '). Aborting checkpoint - resolve manually."
    git reset | Out-Null
    exit 1
}

# Auto commit message
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$msg = @"
Auto-checkpoint $timestamp

$($diff.Trim())

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
"@

git commit -m $msg | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error "git commit failed"
    exit 1
}
if (-not $Quiet) { Write-Host "Committed: $($diff.Trim())" }

if ($NoPush) {
    if (-not $Quiet) { Write-Host "Skipped push (-NoPush)." }
    exit 0
}

# Push - non-fatal on failure (commit is the safety net)
$pushOutput = git push origin main 2>&1
if ($LASTEXITCODE -eq 0) {
    if (-not $Quiet) { Write-Host "Pushed to origin/main." }
} else {
    Write-Warning "Push failed (commit is local-only - run 'git push' manually later):`n$pushOutput"
    exit 0
}
