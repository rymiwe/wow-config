<#
.SYNOPSIS
  Refresh community addons (ElvUI, WeakAuras, BadBoy, Questie, OPie, TotemTimers,
  AskMrRobotClassic) to latest upstream versions.
  Doesn't touch our custom addons, bindings, or SavedVariables.

.DESCRIPTION
  Flavor-aware: defaults to _anniversary_ (unchanged behavior). Pass
  -Flavor _classic_era_ to refresh the Classic Era / SoD client instead.
  The Era set skips TotemTimers (Anniversary-only patched fork) and scrapes
  the "Classic" AskMrRobot section instead of "TBC".

  NOTE: for _classic_era_ this installs the ElvUI DEV BUILD from GitHub (the
  packaged release lags WoW 1.15.9). Set env ELVUI_ERA_DEV=0 to revert. See the
  Install-ElvUIDevBuild block below.

.PARAMETER WowDir
  Path to your World of Warcraft install. Auto-detected if omitted.

.PARAMETER Flavor
  Client folder to update (default _anniversary_; use _classic_era_ for SoD).

.EXAMPLE
  .\scripts\update-addons.ps1
.EXAMPLE
  .\scripts\update-addons.ps1 -Flavor _classic_era_
#>
[CmdletBinding()]
param(
    [string]$WowDir,
    [string]$Flavor = "_anniversary_"
)

$ErrorActionPreference = "Continue"

# A real install has WowClassic.exe inside the flavor folder; testing only for
# the folder can latch onto a stray/dead <flavor> dir (e.g. an orphaned
# Program Files (x86) shell) and install addons where the game never reads them.
if (-not $WowDir) {
    foreach ($candidate in @(
        "C:\Program Files (x86)\World of Warcraft",
        "C:\Program Files\World of Warcraft",
        "D:\Program Files (x86)\World of Warcraft",
        "D:\Program Files\World of Warcraft",
        "E:\Program Files\World of Warcraft",
        "E:\Program Files (x86)\World of Warcraft"
    )) {
        if (Test-Path (Join-Path $candidate "$Flavor\WowClassic.exe")) { $WowDir = $candidate; break }
    }
}
if (-not $WowDir -or -not (Test-Path (Join-Path $WowDir "$Flavor\WowClassic.exe"))) {
    Write-Error "Could not find WoW install with '$Flavor\WowClassic.exe'. Pass -WowDir 'C:\path\to\World of Warcraft'."
    exit 1
}

$addonsDir = Join-Path $WowDir "$Flavor\Interface\AddOns"
Write-Host "Updating addons in: $addonsDir"

function Install-AddonZip {
    param([string]$Name, [string]$Url, [string]$DestDir)
    if (-not $Url) { Write-Warning "$Name has no download URL (upstream changed?)"; return }
    $tmp = Join-Path $env:TEMP "addon-$Name.zip"
    try {
        Invoke-WebRequest -Uri $Url -OutFile $tmp -UseBasicParsing
        Expand-Archive -Path $tmp -DestinationPath $DestDir -Force
        Write-Host "  Updated $Name"
    } catch {
        Write-Warning "$Name update failed: $_"
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

function Get-AmrSectionZipUrl {
    # Scrape a versioned AskMrRobot Classic zip from the section under the given
    # <h6> heading ("TBC" for Anniversary, "Classic" for Classic Era).
    param([string]$Section)
    try {
        $page = Invoke-WebRequest -Uri "https://www.askmrrobot.com/addon" -UseBasicParsing
        $pattern = '(?s)<h6>\s*' + [regex]::Escape($Section) + '\s*</h6>.*?href="(https://static3\.askmrrobot\.com/wowaddonclassic/askmrrobot-\d+\.zip)"'
        if ($page.Content -match $pattern) {
            return $matches[1]
        }
    } catch {
        Write-Warning "AskMrRobotClassic page fetch failed: $_"
    }
    return $null
}

# --- ElvUI on Classic Era: run the DEVELOPMENT build from GitHub -------------
# WoW 1.15.9 (interface 11509) reworked a lot of Blizzard UI internals. The last
# packaged ElvUI release (15.18) targets 1.15.8 and crashes on 1.15.9; the devs'
# git 'main' branch already carries the Era fixes. So for _classic_era_ we install
# ElvUI straight from github.com/tukui-org/ElvUI.
# >>> We are intentionally on the ElvUI DEV BUILD for Classic Era. <<<
# TO REVERT to the stable Tukui release once it catches up to 1.15.9:
# set the env var ELVUI_ERA_DEV=0, and Era uses the same Tukui fetch as Anniversary.
function Install-ElvUIDevBuild {
    param([string]$DestDir)
    $url = "https://github.com/tukui-org/ElvUI/archive/refs/heads/main.zip"
    $tmp = Join-Path $env:TEMP "elvui-dev.zip"
    $tmpdir = Join-Path $env:TEMP "elvui-dev-extract"
    try {
        if (Test-Path $tmpdir) { Remove-Item -Recurse -Force $tmpdir }
        Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
        Expand-Archive -Path $tmp -DestinationPath $tmpdir -Force
        $src = Join-Path $tmpdir "ElvUI-main"
        foreach ($a in @("ElvUI","ElvUI_Libraries","ElvUI_Options")) {
            $from = Join-Path $src $a
            if (Test-Path $from) {
                $to = Join-Path $DestDir $a
                if (Test-Path $to) { Remove-Item -Recurse -Force $to }
                Copy-Item -Recurse -Force $from $to
                # replace the @project-version@ packager placeholder so version parsing is clean
                Get-ChildItem $to -Filter *.toc -Recurse | ForEach-Object {
                    $c = Get-Content -Raw $_.FullName
                    if ($c -match '@project-version@') {
                        Set-Content -NoNewline -Path $_.FullName -Value ($c -replace '@project-version@','dev') -Encoding UTF8
                    }
                }
            }
        }
        Write-Host "  Updated ElvUI (GitHub dev build - Classic Era / 1.15.9)"
    } catch {
        Write-Warning "ElvUI dev-build install failed: $_"
    } finally {
        Remove-Item $tmp -Force -ErrorAction SilentlyContinue
        Remove-Item $tmpdir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

$elvuiEraDev = -not ($env:ELVUI_ERA_DEV -eq "0")
if ($Flavor -eq "_classic_era_" -and $elvuiEraDev) {
    Install-ElvUIDevBuild $addonsDir
} else {
    try {
        $elvuiInfo = Invoke-RestMethod -Uri "https://api.tukui.org/v1/addon/elvui" -UseBasicParsing
        Install-AddonZip "ElvUI" $elvuiInfo.url $addonsDir
    } catch { Write-Warning "ElvUI Tukui API failed: $_" }
}

Install-AddonZip "WeakAuras" (Get-GitHubLatestZipUrl "WeakAuras/WeakAuras2") $addonsDir
Install-AddonZip "Questie"   (Get-GitHubLatestZipUrl "Questie/Questie")     $addonsDir
Install-AddonZip "BadBoy"    (Get-GitHubLatestZipUrl "funkydude/BadBoy")    $addonsDir

# TotemTimers here is a patched TBC fork; Anniversary only.
if ($Flavor -eq "_anniversary_") {
    Install-AddonZip "TotemTimers" (Get-GitHubLatestZipUrl "taubut/TotemTimers_Fork") $addonsDir
}

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
            Write-Warning "OPie zip URL not found on version page"
        }
    } else {
        Write-Warning "OPie release page link not found on main page"
    }
} catch {
    Write-Warning "OPie download failed: $_"
}

# AskMrRobot: scrape the section matching this flavor. Both TBC and Classic Era
# builds ship as AskMrRobotClassic; the version differs per game version.
$amrSection = switch ($Flavor) {
    "_anniversary_" { "TBC" }
    "_classic_era_" { "Classic" }
    default         { $null }
}
if ($amrSection) {
    $amrUrl = Get-AmrSectionZipUrl $amrSection
    if ($amrUrl) {
        Install-AddonZip "AskMrRobotClassic" $amrUrl $addonsDir
    } else {
        Write-Warning "AskMrRobotClassic '$amrSection' download not found"
    }
}

Write-Host ""
Write-Host "Done. /reload in-game to load new versions."
