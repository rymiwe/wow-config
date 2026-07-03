<#
.SYNOPSIS
  Refresh community addons (ElvUI, WeakAuras, BadBoy, Questie, OPie, TotemTimers,
  AskMrRobotClassic) to latest upstream versions.
  upstream versions. Doesn't touch our custom addons, bindings, or SavedVariables.

.PARAMETER WowDir
  Path to your World of Warcraft install. Auto-detected if omitted.

.EXAMPLE
  .\scripts\update-addons.ps1
#>
[CmdletBinding()]
param(
    [string]$WowDir
)

$ErrorActionPreference = "Continue"

if (-not $WowDir) {
    foreach ($candidate in @(
        "C:\Program Files (x86)\World of Warcraft",
        "C:\Program Files\World of Warcraft",
        "D:\Program Files (x86)\World of Warcraft",
        "D:\Program Files\World of Warcraft",
        "E:\Program Files\World of Warcraft",
        "E:\Program Files (x86)\World of Warcraft"
    )) {
        if (Test-Path (Join-Path $candidate "_anniversary_")) { $WowDir = $candidate; break }
    }
}
if (-not $WowDir -or -not (Test-Path (Join-Path $WowDir "_anniversary_"))) {
    Write-Error "Could not find WoW install. Pass -WowDir 'C:\path\to\World of Warcraft'."
    exit 1
}

$addonsDir = Join-Path $WowDir "_anniversary_\Interface\AddOns"
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

function Get-AmrTbcZipUrl {
    try {
        $page = Invoke-WebRequest -Uri "https://www.askmrrobot.com/addon" -UseBasicParsing
        if ($page.Content -match '<h6>\s*TBC\s*</h6>.*?href="(https://static3\.askmrrobot\.com/wowaddonclassic/askmrrobot-\d+\.zip)"') {
            return $matches[1]
        }
    } catch {
        Write-Warning "AskMrRobotClassic page fetch failed: $_"
    }
    return $null
}

try {
    $elvuiInfo = Invoke-RestMethod -Uri "https://api.tukui.org/v1/addon/elvui" -UseBasicParsing
    Install-AddonZip "ElvUI" $elvuiInfo.url $addonsDir
} catch { Write-Warning "ElvUI Tukui API failed: $_" }

Install-AddonZip "WeakAuras" (Get-GitHubLatestZipUrl "WeakAuras/WeakAuras2") $addonsDir
Install-AddonZip "Questie"   (Get-GitHubLatestZipUrl "Questie/Questie")     $addonsDir
Install-AddonZip "BadBoy"    (Get-GitHubLatestZipUrl "funkydude/BadBoy")    $addonsDir
Install-AddonZip "TotemTimers" (Get-GitHubLatestZipUrl "taubut/TotemTimers_Fork") $addonsDir

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

$amrUrl = Get-AmrTbcZipUrl
if ($amrUrl) {
    Install-AddonZip "AskMrRobotClassic" $amrUrl $addonsDir
} else {
    Write-Warning "AskMrRobotClassic TBC download not found"
}

Write-Host ""
Write-Host "Done. /reload in-game to load new versions."
