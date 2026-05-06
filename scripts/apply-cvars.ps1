#requires -Version 5.1
<#
.SYNOPSIS
  Smart-merge CVar defaults from templates/Config.wtf into your live Config.wtf.

.DESCRIPTION
  Adds any SET keys present in the template but missing from your live Config.wtf.
  Never overwrites an existing SET — your customized graphics settings are safe.

  WoW must be closed when you run this; otherwise WoW will overwrite your
  Config.wtf on logout and lose the CVars you just added.

.PARAMETER WowDir
  Path to WoW root. Defaults to "E:\Program Files\World of Warcraft".

.EXAMPLE
  .\scripts\apply-cvars.ps1
#>
param(
    [string]$WowDir = "E:\Program Files\World of Warcraft"
)

$ErrorActionPreference = "Stop"

$src = Join-Path $WowDir "templates\Config.wtf"
$dst = Join-Path $WowDir "_anniversary_\WTF\Config.wtf"

if (-not (Test-Path $src)) { throw "Template not found: $src" }
if (-not (Test-Path $dst)) { throw "Live Config.wtf not found: $dst (launch WoW once to create)" }

# Refuse to run while WoW is open
$wow = Get-Process -Name "Wow*" -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch "WowUp" }
if ($wow) {
    Write-Warning "WoW is running ($($wow.Name)). Exit WoW fully, then re-run this script."
    return
}

# Index existing SET keys
$existingKeys = @{}
foreach ($line in (Get-Content $dst)) {
    if ($line -match '^SET\s+(\S+)\s') { $existingKeys[$matches[1]] = $true }
}

$appended = 0
foreach ($line in (Get-Content $src)) {
    if ($line -match '^SET\s+(\S+)\s') {
        if (-not $existingKeys[$matches[1]]) {
            Add-Content -Path $dst -Value $line
            Write-Host "  + $line"
            $appended++
        }
    }
}

if ($appended -eq 0) {
    Write-Host "No changes — all template CVars already present in your Config.wtf."
} else {
    Write-Host ""
    Write-Host "Added $appended new CVar(s) to $dst. Launch WoW to apply."
}
