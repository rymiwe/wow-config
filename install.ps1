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
    $addons = @("SetupCore", "ChatAnchor", "ChatPanelThemes", "ShamanSetup", "DruidSetup", "HunterSetup", "PaladinSetup", "WarriorSetup", "MageSetup", "PriestSetup", "RogueSetup", "WarlockSetup")
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

    # Auto-detect WoW Anniversary client Interface from .build.info, rewrite each
    # custom addon's TOC Interface line to match. Handles minor version bumps
    # (2.5.5 -> 2.5.6 -> ...) without manual TOC edits.
    function Get-AnniversaryInterface {
        param([string]$WowDir)
        $buildInfo = Join-Path $WowDir ".build.info"
        if (-not (Test-Path $buildInfo)) { return "20505" }
        $lines = Get-Content $buildInfo
        if ($lines.Count -lt 2) { return "20505" }
        $header = $lines[0] -split '\|'
        $verIdx = -1; $prodIdx = -1
        for ($i = 0; $i -lt $header.Count; $i++) {
            if ($header[$i] -like 'Version!*')      { $verIdx  = $i }
            elseif ($header[$i] -like 'Product!*')  { $prodIdx = $i }
        }
        if ($verIdx -lt 0 -or $prodIdx -lt 0) { return "20505" }
        foreach ($line in ($lines | Select-Object -Skip 1)) {
            $cols = $line -split '\|'
            if ($cols.Count -gt $prodIdx -and $cols[$prodIdx] -eq "wow_anniversary") {
                if ($cols[$verIdx] -match '^(\d+)\.(\d+)\.(\d+)') {
                    return ('{0}{1:D2}{2:D2}' -f [int]$matches[1], [int]$matches[2], [int]$matches[3])
                }
            }
        }
        return "20505"
    }

    $ifaceNum = Get-AnniversaryInterface -WowDir $wow
    Write-Host "Detected Anniversary client Interface: $ifaceNum"
    foreach ($a in $addons) {
        $toc = Join-Path $dstAddons "$a\$a.toc"
        if (Test-Path $toc) {
            $content = Get-Content $toc
            $newContent = $content -replace '^## Interface:.*', "## Interface: $ifaceNum"
            $newContent | Set-Content -Path $toc
        }
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

    # Clean up CurseBreaker artifacts from older install.ps1 runs (replaced
    # with direct downloads). Safe to remove; no in-flight state.
    $anniversaryDir = Join-Path $wow "_anniversary_"
    foreach ($leftover in @("CurseBreaker.exe", "CurseBreaker", "CB.json", "CurseBreaker_storage.json", "CurseBreaker.html")) {
        $p = Join-Path $anniversaryDir $leftover
        if (Test-Path $p) { Remove-Item $p -Force -ErrorAction SilentlyContinue; Write-Host "Removed leftover $leftover" }
    }

    # Companion addons: direct downloads from canonical sources, no addon manager.
    # Each addon fetched fresh from upstream so we always get the latest version
    # without WoWInterface multi-release ambiguity or CurseBreaker readline issues
    # that broke Steam Deck installs. Re-run install.ps1 (or scripts/update-addons.ps1)
    # anytime to refresh.
    $addonsDir = Join-Path $anniversaryDir "Interface\AddOns"

    function Install-AddonZip {
        param([string]$Name, [string]$Url, [string]$DestDir)
        if (-not $Url) {
            Write-Warning "$Name has no download URL (upstream changed?)"
            return
        }
        $tmp = Join-Path $env:TEMP "addon-$Name.zip"
        try {
            Invoke-WebRequest -Uri $Url -OutFile $tmp -UseBasicParsing
            Expand-Archive -Path $tmp -DestinationPath $DestDir -Force
            Write-Host "Installed $Name"
        } catch {
            Write-Warning "$Name install failed: $_"
        } finally {
            Remove-Item $tmp -Force -ErrorAction SilentlyContinue
        }
    }

    function Get-GitHubLatestZipUrl {
        param([string]$Repo)
        try {
            $rel = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest" -UseBasicParsing
            $asset = $rel.assets | Where-Object { $_.name -match '\.zip$' } | Select-Object -First 1
            return $asset.browser_download_url
        } catch {
            Write-Warning "GitHub API for $Repo failed: $_"
            return $null
        }
    }

    Write-Host ""
    Write-Host "Installing companion addons (ElvUI, WeakAuras, BadBoy, Questie, OPie)..."

    # ElvUI from Tukui's JSON API.
    try {
        $elvuiInfo = Invoke-RestMethod -Uri "https://api.tukui.org/v1/addon/elvui" -UseBasicParsing
        Install-AddonZip "ElvUI" $elvuiInfo.url $addonsDir
    } catch {
        Write-Warning "ElvUI Tukui API failed: $_"
    }

    # WeakAuras / Questie / BadBoy from GitHub Releases (multi-flavor TOCs).
    Install-AddonZip "WeakAuras" (Get-GitHubLatestZipUrl "WeakAuras/WeakAuras2") $addonsDir
    Install-AddonZip "Questie"   (Get-GitHubLatestZipUrl "Questie/Questie")     $addonsDir
    Install-AddonZip "BadBoy"    (Get-GitHubLatestZipUrl "funkydude/BadBoy")    $addonsDir

    # OPie from townlong-yak. Two-step fetch: main page links to the current
    # /addons/opie/release/<major.minor>/ which contains the actual zip URL with
    # a /addons/gate/<hash>/ anti-hotlink prefix.
    $opieDir = Join-Path $addonsDir "OPie"
    try {
        $opieMain = Invoke-WebRequest -Uri "https://www.townlong-yak.com/addons/opie" -UseBasicParsing
        if ($opieMain.Content -match 'href="(/addons/opie/release/[\d.]+)"') {
            $opieVerPage = Invoke-WebRequest -Uri ("https://www.townlong-yak.com" + $matches[1]) -UseBasicParsing
            if ($opieVerPage.Content -match 'href="(/addons/gate/[a-f0-9]+/opie/OPie-[\d.]+\.zip)"') {
                $opieUrl = "https://www.townlong-yak.com" + $matches[1]
                if (Test-Path $opieDir) { Remove-Item -Recurse -Force $opieDir }
                Install-AddonZip "OPie" $opieUrl $addonsDir
            } else {
                Write-Warning "OPie zip URL not found on version page; install manually from https://www.townlong-yak.com/addons/opie"
            }
        } else {
            Write-Warning "OPie release page link not found on main page; install manually from https://www.townlong-yak.com/addons/opie"
        }
    } catch {
        Write-Warning "OPie download failed: $_. Install manually from https://www.townlong-yak.com/addons/opie"
    }

    Write-Host ""
    Write-Host "Note: TSM (TradeSkillMaster) is not on free addon sources we can auto-install."
    Write-Host "      Install via https://www.curseforge.com/wow/addons/trade-skill-master if you want it."

    # Auto-checkpoint Scheduled Task — runs scripts/watch.ps1 on logon (hidden,
    # no terminal). Idempotent: re-running install.ps1 refreshes the task.
    $repoScriptsDir = Join-Path $wow "scripts"
    $installTaskScript = Join-Path $repoScriptsDir "install-watch-task.ps1"
    if (Test-Path $installTaskScript) {
        Write-Host ""
        Write-Host "Setting up auto-checkpoint task (commits + pushes session changes when WoW exits)..."
        & $installTaskScript
    }

    Write-Host ""
    Write-Host "Install complete. Next steps:"
    Write-Host "  1. Launch WoW, log in - SetupCore runs /setupbars automatically on first login"
    Write-Host "  2. OPie rings auto-bind to M4 (primary) and M5 (secondary) on first login."
    Write-Host "     If a ring isn't bound, /opie -> Ring Bindings to set manually (overrides persist)."
    Write-Host "  3. (Optional) Install TSM from CurseForge if you use the Auction House"
    Write-Host "  4. (Optional) Import TSM groups via /tsm UI from templates/tsm-groups/"
}
finally {
    if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir }
}
