#requires -Version 5.1
<#
.SYNOPSIS
  Install rymiwe/wow-config addons + bindings into a WoW Anniversary client.

.PARAMETER WowDir
  Path to your WoW root (the directory containing _anniversary_).
  Defaults to $env:WOWDIR, then auto-detect.

.PARAMETER Account
  Account folder name under WTF/Account/ (your Battle.net account dir).
  Defaults to auto-detect.

.PARAMETER Mode
  upsert (default): install addons, skip existing bindings/SavedVariables.
  fresh: overwrite bindings + reseed auto-setup flag.

.EXAMPLE
  iex (iwr "https://raw.githubusercontent.com/rymiwe/wow-config/main/install.ps1").Content
#>
param(
    [string]$WowDir = $env:WOWDIR,
    [string]$Account,
    [ValidateSet("upsert", "fresh")][string]$Mode = "upsert",
    [string]$Branch = "main",
    [string]$RepoUrl = "https://github.com/rymiwe/wow-config.git"
)

$ErrorActionPreference = "Stop"

function Find-WowDir {
    if ($WowDir -and (Test-Path (Join-Path $WowDir "_anniversary_"))) { return $WowDir }
    $candidates = @(
        "$env:ProgramFiles\World of Warcraft",
        "${env:ProgramFiles(x86)}\World of Warcraft",
        "C:\Program Files\World of Warcraft",
        "C:\Program Files (x86)\World of Warcraft",
        "D:\Program Files\World of Warcraft",
        "D:\Games\World of Warcraft",
        "E:\Program Files\World of Warcraft",
        "E:\Games\World of Warcraft"
    )
    foreach ($c in $candidates) {
        if (Test-Path (Join-Path $c "_anniversary_")) { return $c }
    }
    throw "Could not find WoW install. Set `$env:WOWDIR or pass -WowDir."
}

function Find-Account {
    param([string]$Wow)
    if ($Account) { return $Account }
    $acctDir = Join-Path $Wow "_anniversary_\WTF\Account"
    if (-not (Test-Path $acctDir)) {
        throw "No WTF/Account directory at $acctDir. Launch WoW once first."
    }
    $dirs = Get-ChildItem -Path $acctDir -Directory | Where-Object { $_.Name -ne "SavedVariables" }
    if ($dirs.Count -eq 0) { throw "No account folders in $acctDir" }
    if ($dirs.Count -eq 1) { return $dirs[0].Name }
    Write-Host "Multiple accounts found:"
    for ($i = 0; $i -lt $dirs.Count; $i++) { Write-Host "  [$i] $($dirs[$i].Name)" }
    $idx = Read-Host "Select account index"
    return $dirs[[int]$idx].Name
}

$wow = Find-WowDir
$acct = Find-Account -Wow $wow

Write-Host "WoW directory:  $wow"
Write-Host "Account:        $acct"
Write-Host "Mode:           $Mode"
Write-Host "Repo:           $RepoUrl ($Branch)"

$tempDir = Join-Path $env:TEMP "wow-config-install-$([guid]::NewGuid())"
Write-Host "Cloning repo to $tempDir..."
& git clone --depth 1 --branch $Branch $RepoUrl $tempDir 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { throw "git clone failed" }

try {
    $srcAddons    = Join-Path $tempDir "_anniversary_\Interface\AddOns"
    $dstAddons    = Join-Path $wow     "_anniversary_\Interface\AddOns"
    $srcTemplates = Join-Path $tempDir "templates"
    $dstSV        = Join-Path $wow     "_anniversary_\WTF\Account\$acct\SavedVariables"
    $dstBindings  = Join-Path $wow     "_anniversary_\WTF\Account\$acct\bindings-cache.wtf"
    $dstConfig    = Join-Path $wow     "_anniversary_\WTF\Config.wtf"

    if (-not (Test-Path $dstAddons)) { New-Item -ItemType Directory -Force -Path $dstAddons | Out-Null }
    if (-not (Test-Path $dstSV))     { New-Item -ItemType Directory -Force -Path $dstSV     | Out-Null }

    # Addon code is canonical — always overwrite.
    $addons = @("SetupCore", "ChatAnchor", "ShamanSetup", "DruidSetup", "HunterSetup", "PaladinSetup", "WarriorSetup")
    foreach ($a in $addons) {
        $src = Join-Path $srcAddons $a
        $dst = Join-Path $dstAddons $a
        if (-not (Test-Path $src)) {
            Write-Warning "Source addon not found: $src - skipping"
            continue
        }
        if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
        Copy-Item -Recurse $src $dst
        Write-Host "Installed addon: $a"
    }

    # Templates respect mode.
    $setupSV = Join-Path $dstSV "SetupCore.lua"
    if ($Mode -eq "fresh" -or -not (Test-Path $setupSV)) {
        Copy-Item (Join-Path $srcTemplates "SetupCore.lua") $setupSV -Force
        Write-Host "Seeded SetupCoreDB.needsSetup = true"
    } else {
        Write-Host "SetupCore.lua exists - leaving alone (use -Mode fresh to reset)"
    }

    if ($Mode -eq "fresh" -or -not (Test-Path $dstBindings)) {
        Copy-Item (Join-Path $srcTemplates "bindings-cache.wtf") $dstBindings -Force
        Write-Host "Installed bindings-cache.wtf"
    } else {
        Write-Host "bindings-cache.wtf exists - leaving alone (use -Mode fresh to overwrite)"
    }

    # ElvUI.lua — full UI layout. Only deploy in --fresh mode; in upsert mode
    # we never overwrite existing ElvUI configs (friends may have their own).
    $srcElvUI = Join-Path $srcTemplates "ElvUI.lua"
    $dstElvUI = Join-Path $dstSV "ElvUI.lua"
    if (Test-Path $srcElvUI) {
        if ($Mode -eq "fresh" -or -not (Test-Path $dstElvUI)) {
            Copy-Item $srcElvUI $dstElvUI -Force
            Write-Host "Installed ElvUI.lua (full layout — bars, movers, fonts, panels)"
        } else {
            Write-Host "ElvUI.lua exists - leaving alone (use -Mode fresh to install layout)"
        }
    }

    # Config.wtf — CVar defaults (nameplates, camera). Append-merge for safety:
    # WoW will overwrite individual SET lines; we only seed missing ones to
    # avoid clobbering user-customized graphics settings.
    $srcConfig = Join-Path $srcTemplates "Config.wtf"
    if (Test-Path $srcConfig) {
        if ($Mode -eq "fresh" -or -not (Test-Path $dstConfig)) {
            Copy-Item $srcConfig $dstConfig -Force
            Write-Host "Installed Config.wtf (CVar defaults)"
        } else {
            # Append any missing SET keys
            $existing = Get-Content $dstConfig -ErrorAction SilentlyContinue
            $existingKeys = @{}
            foreach ($line in $existing) {
                if ($line -match '^SET\s+(\S+)\s') { $existingKeys[$matches[1]] = $true }
            }
            $appended = 0
            foreach ($line in (Get-Content $srcConfig)) {
                if ($line -match '^SET\s+(\S+)\s') {
                    if (-not $existingKeys[$matches[1]]) {
                        Add-Content -Path $dstConfig -Value $line
                        $appended++
                    }
                }
            }
            Write-Host "Config.wtf merged ($appended new CVars added; existing untouched)"
        }
    }

    Write-Host ""
    Write-Host "Install complete. Launch WoW and log in - SetupCore will run /setupbars on first login."
}
finally {
    if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir }
}
