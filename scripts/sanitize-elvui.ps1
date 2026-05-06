#requires -Version 5.1
<#
.SYNOPSIS
  Sanitize a personal ElvUI.lua into a shareable templates/ElvUI.lua.

.DESCRIPTION
  Strips character-specific blocks while keeping the actual Default profile:
    ElvDB.profileKeys      - character→profile mapping (empty)
    ElvDB.class            - character→class mapping (empty)
    ElvDB.gold             - per-character gold tracking (empty)
    ElvDB.faction          - per-character faction (empty)
    ElvDB.serverID         - server fingerprint (empty)
    ElvPrivateDB.profileKeys - private profile keys (empty)
    ElvPrivateDB.profiles    - per-character private settings (empty)

  ElvDB.profiles (containing the actual Default profile with layout) is kept.

.PARAMETER WowDir
  Path to the WoW root. Defaults to "E:\Program Files\World of Warcraft".

.PARAMETER AccountName
  Battle.net account folder name under WTF/Account/. Defaults to "RYMIWE".

.PARAMETER Source
  Override the Source path entirely. Otherwise computed from WowDir+AccountName.

.PARAMETER Target
  Override the Target path entirely. Otherwise computed from WowDir.

.EXAMPLE
  .\scripts\sanitize-elvui.ps1
  Sanitizes RYMIWE's ElvUI.lua into templates/ElvUI.lua.

.EXAMPLE
  .\scripts\sanitize-elvui.ps1 -AccountName SOMEONEELSE
  Use a different account folder.
#>
param(
    [string]$WowDir = "E:\Program Files\World of Warcraft",
    [string]$AccountName = "RYMIWE",
    [string]$Source,
    [string]$Target
)

$ErrorActionPreference = "Stop"

if (-not $Source) {
    $Source = Join-Path $WowDir "_anniversary_\WTF\Account\$AccountName\SavedVariables\ElvUI.lua"
}
if (-not $Target) {
    $Target = Join-Path $WowDir "templates\ElvUI.lua"
}

if (-not (Test-Path $Source)) {
    throw "Source ElvUI.lua not found: $Source"
}

Write-Host "Source: $Source"
Write-Host "Target: $Target"

# Block names per top-level DB
$elvdbBlocks   = @("profileKeys", "class", "gold", "faction", "serverID")
$privateBlocks = @("profileKeys", "profiles")

# State
$lines        = Get-Content $Source
$result       = New-Object System.Collections.ArrayList
$inPrivateDB  = $false
$skipDepth    = 0
$skippingBlock = $null
$skippingIndent = ""
$totalSkipped = 0

foreach ($line in $lines) {
    # Detect which top-level DB we're in
    if ($line -match "^ElvPrivateDB\s*=\s*\{") {
        $inPrivateDB = $true
    } elseif ($line -match "^ElvDB\s*=\s*\{") {
        $inPrivateDB = $false
    }

    if ($skippingBlock) {
        $opens  = ([regex]::Matches($line, "\{")).Count
        $closes = ([regex]::Matches($line, "\}")).Count
        $skipDepth += $opens - $closes
        $totalSkipped++

        if ($skipDepth -le 0) {
            # Block ended — emit synthetic empty closer line
            $null = $result.Add("$skippingIndent},")
            $skippingBlock = $null
            $skipDepth = 0
        }
        continue
    }

    # Check if this line opens one of the blocks we want to empty
    $blockNames = if ($inPrivateDB) { $privateBlocks } else { $elvdbBlocks }
    $matched = $false
    foreach ($block in $blockNames) {
        $pattern = "^(\s*)\[`"$block`"\]\s*=\s*\{\s*$"
        if ($line -match $pattern) {
            $skippingIndent = $matches[1]
            # Emit the opening line as-is, then skip until matching close
            $null = $result.Add("$skippingIndent[`"$block`"] = {")
            $skippingBlock = $block
            $skipDepth = 1
            $matched = $true
            break
        }
    }

    if (-not $matched) {
        $null = $result.Add($line)
    }
}

# Ensure target directory exists
$targetDir = Split-Path $Target -Parent
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
}

Set-Content -Path $Target -Value $result -Encoding UTF8

Write-Host "Wrote $($result.Count) lines to $Target (stripped $totalSkipped lines of personal data)"

# Verify no character names leaked
$leak = Select-String -Path $Target -Pattern "Dreamscythe|Rymiwe|Asog|RYMIWE" -SimpleMatch -Quiet
if ($leak) {
    Write-Warning "Personal-data check FAILED — strings still present in $Target. Investigate."
} else {
    Write-Host "Personal-data check passed."
}
