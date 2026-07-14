<#
.SYNOPSIS
  Launch WoW Anniversary, then auto-checkpoint when it exits.

.DESCRIPTION
  Chezmoi-style wrapper: pre-launch fetch (warn if behind origin), launch WoW
  and block until it exits, then run scripts/checkpoint.ps1 to stage + commit +
  push live SavedVariables, bindings, addon edits.

  Pin this to your taskbar / Start menu instead of WowClassic.exe and your repo
  stays in sync automatically. If you launch WoW via Battle.net or directly, the
  auto-checkpoint won't run - use checkpoint.ps1 manually in that case.

.PARAMETER Flavor
  Client folder to launch (default _anniversary_; use _classic_era_ for SoD).
  Ignored if -WowExe is given explicitly.

.PARAMETER WowExe
  Path to WowClassic.exe. Defaults to ../<Flavor>/WowClassic.exe.

.PARAMETER NoSync
  Skip the pre-launch git fetch.

.PARAMETER NoCheckpoint
  Don't run checkpoint.ps1 after WoW exits. (Useful for testing the launch path.)

.PARAMETER NoPush
  Pass through to checkpoint.ps1 - commit locally but don't push.

.EXAMPLE
  .\scripts\play.ps1

.EXAMPLE
  # Offline: launch but don't push when done
  .\scripts\play.ps1 -NoPush

.EXAMPLE
  # Launch the Classic Era / SoD client instead
  .\scripts\play.ps1 -Flavor _classic_era_
#>
[CmdletBinding()]
param(
    [string]$Flavor = "_anniversary_",
    [string]$WowExe = "$PSScriptRoot/../$Flavor/WowClassic.exe",
    [switch]$NoSync,
    [switch]$NoCheckpoint,
    [switch]$NoPush
)

$ErrorActionPreference = "Stop"
$RepoPath = (Resolve-Path "$PSScriptRoot/..").Path

# Pre-launch: fetch + warn if behind. Don't auto-pull (conflicts mid-launch are bad).
if (-not $NoSync) {
    Push-Location $RepoPath
    try {
        Write-Host "Fetching origin..."
        git fetch origin main 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            $behind = [int](git rev-list --count HEAD..origin/main 2>&1)
            if ($behind -gt 0) {
                Write-Warning "Local main is behind origin/main by $behind commits."
                Write-Warning "Consider 'git pull --rebase' before playing to avoid divergence."
            }
        } else {
            Write-Warning "git fetch failed (offline?). Continuing without sync check."
        }
    } finally {
        Pop-Location
    }
}

# Resolve + verify exe
$resolvedExe = $null
try {
    $resolvedExe = (Resolve-Path $WowExe -ErrorAction Stop).Path
} catch {
    Write-Error "WoW executable not found: $WowExe"
    exit 1
}

Write-Host "Launching $resolvedExe ..."
Write-Host "(checkpoint will run automatically when WoW exits)"

# Launch and block until process exits. SavedVariables flush before the exe quits,
# so by the time Start-Process returns, the files are on disk and ready to commit.
Start-Process -FilePath $resolvedExe -Wait

Write-Host "WoW exited."

if ($NoCheckpoint) {
    Write-Host "Skipped checkpoint (-NoCheckpoint)."
    exit 0
}

# Run checkpoint
$checkpointArgs = @{}
if ($NoPush) { $checkpointArgs['NoPush'] = $true }
& "$PSScriptRoot/checkpoint.ps1" @checkpointArgs
