<#
.SYNOPSIS
  Register watch.ps1 as a hidden Scheduled Task that runs at logon — no
  taskbar window, no terminal, fully invisible.

.DESCRIPTION
  Replaces the Startup-folder shortcut method with a proper Windows Scheduled
  Task. Runs as the current user (so git credentials work), at logon, with
  WindowStyle Hidden so there's nothing to alt-tab past.

  Idempotent: re-registers cleanly. Stops any existing watcher process and
  removes the old Startup-folder shortcut if present.

.PARAMETER TaskName
  Scheduled task name. Default "wow-config-watch".

.PARAMETER Uninstall
  Remove the task instead of installing.

.EXAMPLE
  .\scripts\install-watch-task.ps1

.EXAMPLE
  .\scripts\install-watch-task.ps1 -Uninstall
#>
[CmdletBinding()]
param(
    [string]$TaskName = "wow-config-watch",
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"
$watchPath = (Resolve-Path "$PSScriptRoot/watch.ps1").Path
$workDir = (Resolve-Path "$PSScriptRoot/..").Path
$startupShortcut = Join-Path ([Environment]::GetFolderPath('Startup')) "wow-config-watch.lnk"

if ($Uninstall) {
    if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "Unregistered scheduled task: $TaskName"
    } else {
        Write-Host "No task named '$TaskName' found."
    }
    exit 0
}

# Stop any running watcher (from previous Startup-shortcut method or earlier task)
Get-CimInstance Win32_Process -Filter "Name = 'powershell.exe'" |
    Where-Object { $_.CommandLine -and $_.CommandLine -like '*watch.ps1*' } |
    ForEach-Object {
        Write-Host "Stopping existing watcher PID $($_.ProcessId)"
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    }

# Remove Startup-folder shortcut (replaced by Scheduled Task)
if (Test-Path $startupShortcut) {
    Remove-Item $startupShortcut -Force
    Write-Host "Removed Startup-folder shortcut: $startupShortcut"
}

# Register hidden Scheduled Task
$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File `"$watchPath`"" `
    -WorkingDirectory $workDir

$trigger = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"

# Long-running watcher: never time out, restart on failure, allow on battery
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -ExecutionTimeLimit ([System.TimeSpan]::Zero) `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 5)

$principal = New-ScheduledTaskPrincipal `
    -UserId "$env:USERDOMAIN\$env:USERNAME" `
    -LogonType Interactive `
    -RunLevel Limited

$task = New-ScheduledTask `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Description "Auto-checkpoint wow-config repo when WoW exits (runs scripts/watch.ps1 hidden)"

Register-ScheduledTask -TaskName $TaskName -InputObject $task -Force | Out-Null
Write-Host "Registered scheduled task: $TaskName"

# Start it now so we don't wait until next logon
Start-ScheduledTask -TaskName $TaskName
Start-Sleep -Seconds 1
$state = (Get-ScheduledTask -TaskName $TaskName).State
Write-Host "Started task. State: $state"
Write-Host ""
Write-Host "Verify with: Get-ScheduledTask -TaskName $TaskName"
Write-Host "Disable with: .\scripts\install-watch-task.ps1 -Uninstall"
