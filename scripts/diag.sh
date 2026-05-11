#!/bin/bash
# diag.sh — print diagnostic info about a wow-config install.
# Run on any machine: curl -sSL https://raw.githubusercontent.com/rymiwe/wow-config/main/scripts/diag.sh | bash
#
# Auto-uploads the report to a shareable URL:
#   1. If `gh` CLI is authenticated -> creates a secret GitHub gist (preferred)
#   2. Otherwise -> uploads to 0x0.st (no-auth public paste, expires in ~1yr)
#   3. Either way, prints the URL at the end. Share that URL instead of pasting.

set -uo pipefail

# Capture all output for upload while still streaming to terminal.
TMPLOG="$(mktemp -t wow-diag-XXXXXX.txt)"
trap 'rm -f "$TMPLOG"' EXIT
exec > >(tee "$TMPLOG")

echo "=== wow-config diagnostic ==="
echo "Date:   $(date)"
echo "Bash:   $BASH_VERSION"
echo "Shell:  ${SHELL:-?}"
echo "User:   ${USER:-?}@$(hostname)"
echo

# Find WoW install (mirrors install.sh detection)
find_wow_dir() {
    [[ -n "${WOWDIR:-}" && -d "${WOWDIR}/_anniversary_" ]] && { echo "$WOWDIR"; return; }
    for d in "$HOME"/.steam/steam/steamapps/compatdata/*/pfx/drive_c/Program\ Files\ \(x86\)/World\ of\ Warcraft \
             "$HOME"/.steam/steam/steamapps/compatdata/*/pfx/drive_c/Program\ Files/World\ of\ Warcraft \
             "$HOME"/Games/battlenet/drive_c/Program\ Files\ \(x86\)/World\ of\ Warcraft \
             "$HOME"/.local/share/lutris/runners/wine/*/drive_c/Program\ Files\ \(x86\)/World\ of\ Warcraft \
             "$HOME"/.local/share/lutris/games/world-of-warcraft \
             /Applications/World\ of\ Warcraft \
             "$HOME"/Games/World\ of\ Warcraft \
             "$HOME"/Games/world-of-warcraft \
             "$HOME"/World\ of\ Warcraft; do
        [[ -d "$d/_anniversary_" ]] && { echo "$d"; return; }
    done
    return 1
}

WOW="$(find_wow_dir)" || { echo "ERROR: WoW install not found"; exit 1; }
echo "WoW dir: $WOW"
ADDONS="$WOW/_anniversary_/Interface/AddOns"
echo "Addons:  $ADDONS"
echo

# List addons we care about + their TOC files
for addon in ElvUI WeakAuras Questie BadBoy OPie; do
    echo "[$addon]"
    if [[ ! -d "$ADDONS/$addon" ]]; then
        echo "  DIR MISSING"
    else
        # All TOC files in the dir
        for toc in "$ADDONS/$addon"/*.toc; do
            if [[ -f "$toc" ]]; then
                ver="$(grep -oE '^## Version:[[:space:]]*\S+' "$toc" 2>/dev/null | head -1 | sed -E 's|^## Version:[[:space:]]*||')"
                echo "  $(basename "$toc"): Version=${ver:-NONE}"
            fi
        done
        # Confirm we found at least one TOC
        if ! ls "$ADDONS/$addon"/*.toc &>/dev/null; then
            echo "  NO .toc FILES FOUND"
        fi
    fi
done
echo

# Show what local_toc_version function the LATEST install.sh from main has
echo "=== latest install.sh local_toc_version() function ==="
curl -sSL "https://raw.githubusercontent.com/rymiwe/wow-config/main/install.sh" 2>/dev/null \
    | sed -n '/^local_toc_version() {/,/^}/p' \
    || echo "(failed to fetch)"
echo

# Show last commit on main so we know if her wcu is current
echo "=== latest commit on main ==="
curl -sSL "https://api.github.com/repos/rymiwe/wow-config/commits/main" 2>/dev/null \
    | grep -E '"sha"|"message"|"date"' | head -6 \
    || echo "(failed to fetch)"

echo
echo "=== done ==="

# Stop tee so the upload log is finalized.
exec > /dev/tty 2>&1

# Try to upload the captured log to a shareable URL.
echo
url=""
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    url="$(gh gist create --filename "wow-diag-$(hostname)-$(date +%s).txt" "$TMPLOG" 2>/dev/null | tail -1)"
    [[ -n "$url" ]] && echo ">>> Uploaded diagnostic to gist: $url"
fi
if [[ -z "$url" ]]; then
    # Fallback to 0x0.st (no auth, public expiring URL ~1yr)
    url="$(curl -sSF "file=@$TMPLOG" https://0x0.st 2>/dev/null)"
    if [[ -n "$url" && "$url" =~ ^https:// ]]; then
        echo ">>> Uploaded diagnostic to: $url"
    else
        echo ">>> Upload failed - paste the output above manually"
    fi
fi
echo ">>> Share this URL with the assistant"
