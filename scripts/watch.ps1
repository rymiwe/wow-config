<#
.SYNOPSIS
  Background watcher: checkpoint the wow-config repo every time WoW exits.

.DESCRIPTION
  Runs forever. Polls every 30s for either WoW client:
    WowClassic.exe  - Anniversary / Classic Era (_anniversary_, _classic_era_)
    Wow.exe         - WoW: Forever (_forever_)
  When one appears, attaches and waits for it to exit (this is efficient - no
  busy-loop). On exit, runs scripts/checkpoint.ps1 which stages + commits +
  pushes any session changes. Then looks again right away (no sleep), so if
  both clients were open, the second one gets its own checkpoint when it
  closes instead of being missed. Only when neither is running does it go back
  to sleeping between polls.

  Retail WoW is also Wow.exe, so closing retail triggers a checkpoint too.
  That's harmless: checkpoint.ps1 is a no-op when nothing changed.

  Designed for Battle.net users who launch WoW outside scripts/play.ps1.
  Run this once and leave the window open, OR drop a shortcut into your
  Windows Startup folder so it runs automatically at login.

  Startup folder: shell:startup
  (Win+R -> shell:startup -> drop a shortcut here, target:
   powershell.exe -WindowStyle Minimized -ExecutionPolicy Bypass -File "<path to watch.ps1>")

.PARAMETER PollSeconds
  How often to check for WowClassic.exe / Wow.exe when neither is running.
  Default 30.

.PARAMETER NoPush
  Pass through to checkpoint.ps1 - commit locally but don't push.

.EXAMPLE
  .\scripts\watch.ps1

.EXAMPLE
  # Check less frequently; useful for low-power machines
  .\scripts\watch.ps1 -PollSeconds 60
#>
[CmdletBinding()]
param(
    [int]$PollSeconds = 30,
    [switch]$NoPush
)

$ErrorActionPreference = "Continue"  # Watchers shouldn't die on transient errors
$checkpointPath = Join-Path $PSScriptRoot "checkpoint.ps1"

# Process names (Get-Process drops the .exe). WowClassic = Anniversary/Era,
# Wow = WoW: Forever. Order only matters when both are running: we attach to
# the first one found, checkpoint when it exits, then immediately look again.
$wowProcessNames = @("WowClassic", "Wow")

if (-not (Test-Path $checkpointPath)) {
    Write-Error "checkpoint.ps1 not found at $checkpointPath"
    exit 1
}

Write-Host "wow-config watcher started. Polling every ${PollSeconds}s for WowClassic.exe or Wow.exe."
Write-Host "Ctrl+C to stop. Leave this window open while you play.`n"

while ($true) {
    $proc = $null
    try {
        $proc = Get-Process -Name $wowProcessNames -ErrorAction SilentlyContinue | Select-Object -First 1
    } catch {
        # Process API can throw on rare races; just retry
    }

    if (-not $proc) {
        Start-Sleep -Seconds $PollSeconds
        continue
    }

    # Name the client so the log says which one we're waiting on.
    $exeName = "$($proc.ProcessName).exe"
    Write-Host "$(Get-Date -Format 'HH:mm:ss') $exeName detected (PID $($proc.Id)). Waiting for exit..."
    try {
        $proc | Wait-Process -ErrorAction Stop
    } catch {
        # Process may exit before Wait-Process attaches; ignore
    }
    Write-Host "$(Get-Date -Format 'HH:mm:ss') $exeName exited. Running checkpoint..."

    $args = @{}
    if ($NoPush) { $args['NoPush'] = $true }
    try {
        & $checkpointPath @args
    } catch {
        Write-Warning "checkpoint failed: $_"
    }

    Write-Host ""  # blank line before next poll cycle
    # No sleep here on purpose: loop straight back to Get-Process so a second
    # client that is still running (e.g. Forever open while Anniversary just
    # closed) gets attached right away. The sleep only happens above, when
    # neither client is running.
}
