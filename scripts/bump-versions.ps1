<#
.SYNOPSIS
  Bump the ## Version field in any custom-addon .toc whose addon directory
  has changes staged for commit. Auto-stages the bumped .toc so it lands in
  the same commit.

.DESCRIPTION
  Scans `git diff --cached` for files under `_anniversary_/Interface/AddOns/
  <addon>/`. For each affected addon, reads the .toc, increments the last
  numeric component of the Version line (e.g., 1.0 -> 1.0.1, 1.0.1 -> 1.0.2),
  writes back, and re-stages.

  Called by scripts/checkpoint.ps1 before commit. Safe to call standalone
  if you want to bump before a manual `git commit`.

.PARAMETER RepoRoot
  Path to the wow-config repo. Defaults to the parent of this script's dir.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = (Resolve-Path "$PSScriptRoot/..").Path
)

$ErrorActionPreference = "Continue"
Push-Location $RepoRoot
try {
    $stagedFiles = git diff --cached --name-only 2>$null
    if (-not $stagedFiles) { exit 0 }

    # Group by addon dir
    $addons = @{}
    foreach ($f in $stagedFiles) {
        if ($f -match '^_anniversary_/Interface/AddOns/([^/]+)/') {
            $addons[$matches[1]] = $true
        }
    }
    if ($addons.Count -eq 0) { exit 0 }

    foreach ($addon in $addons.Keys) {
        $tocPath = "_anniversary_/Interface/AddOns/$addon/$addon.toc"
        if (-not (Test-Path $tocPath)) { continue }

        $lines = Get-Content $tocPath
        $bumped = $false
        $oldVer = $null
        $newVer = $null
        $newLines = foreach ($line in $lines) {
            if (-not $bumped -and $line -match '^## Version:\s*(.+?)\s*$') {
                $oldVer = $matches[1]
                if ($oldVer -match '^(.*?)(\d+)$') {
                    $newVer = $matches[1] + ([int]$matches[2] + 1)
                } else {
                    $newVer = "$oldVer.1"
                }
                $bumped = $true
                "## Version: $newVer"
            } else {
                $line
            }
        }
        if ($bumped) {
            $newLines | Set-Content -Path $tocPath
            git add $tocPath 2>&1 | Out-Null
            Write-Host "Bumped ${addon}: $oldVer -> $newVer"
        }
    }
}
finally {
    Pop-Location
}
