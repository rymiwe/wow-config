<#
.SYNOPSIS
  Background watcher: checkpoint the wow-config repo every time WoW exits.

.DESCRIPTION
  Runs forever. Polls for WowClassic.exe every 30s. When the process appears,
  attaches and waits for it to exit (this is efficient — no busy-loop). On exit,
  runs scripts/checkpoint.ps1 which stages + commits + pushes any session
  changes. Then resumes polling.

  Designed for Battle.net users who launch WoW outside scripts/play.ps1.
  Run this once and leave the window open, OR drop a shortcut into your
  Windows Startup folder so it runs automatically at login.

  Startup folder: shell:startup
  (Win+R → shell:startup → drop a shortcut here, target:
   powershell.exe -WindowStyle Minimized -ExecutionPolicy Bypass -File "<path to watch.ps1>")

.PARAMETER PollSeconds
  How often to check for WowClassic.exe when it isn't running. Default 30.

.PARAMETER NoPush
  Pass through to checkpoint.ps1 — commit locally but don't push.

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

if (-not (Test-Path $checkpointPath)) {
    Write-Error "checkpoint.ps1 not found at $checkpointPath"
    exit 1
}

Write-Host "wow-config watcher started. Polling every ${PollSeconds}s for WowClassic.exe."
Write-Host "Ctrl+C to stop. Leave this window open while you play.`n"

while ($true) {
    $proc = $null
    try {
        $proc = Get-Process -Name WowClassic -ErrorAction SilentlyContinue | Select-Object -First 1
    } catch {
        # Process API can throw on rare races; just retry
    }

    if (-not $proc) {
        Start-Sleep -Seconds $PollSeconds
        continue
    }

    Write-Host "$(Get-Date -Format 'HH:mm:ss') WoW detected (PID $($proc.Id)). Waiting for exit..."
    try {
        $proc | Wait-Process -ErrorAction Stop
    } catch {
        # Process may exit before Wait-Process attaches; ignore
    }
    Write-Host "$(Get-Date -Format 'HH:mm:ss') WoW exited. Running checkpoint..."

    $args = @{}
    if ($NoPush) { $args['NoPush'] = $true }
    try {
        & $checkpointPath @args
    } catch {
        Write-Warning "checkpoint failed: $_"
    }

    Write-Host ""  # blank line before next poll cycle
}
