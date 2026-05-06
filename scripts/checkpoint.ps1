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

$ErrorActionPreference = "Stop"
$RepoPath = (Resolve-Path "$PSScriptRoot/..").Path
Set-Location $RepoPath

if (-not (Test-Path ".git")) {
    Write-Error "Not a git repo: $RepoPath"
    exit 1
}

# Stage tracked-content paths only — never `git add .` (could pull in random junk).
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

# Anything staged?
$diff = git diff --cached --shortstat
if (-not $diff) {
    if (-not $Quiet) { Write-Host "No changes to commit." }
    exit 0
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

# Push — non-fatal on failure (commit is the safety net)
$pushOutput = git push origin main 2>&1
if ($LASTEXITCODE -eq 0) {
    if (-not $Quiet) { Write-Host "Pushed to origin/main." }
} else {
    Write-Warning "Push failed (commit is local-only — run 'git push' manually later):`n$pushOutput"
    exit 0
}
