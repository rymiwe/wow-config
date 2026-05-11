#!/bin/bash
# diag.sh — print diagnostic info about a wow-config install.
# Run on any machine: curl -sSL https://raw.githubusercontent.com/rymiwe/wow-config/main/scripts/diag.sh | bash

set -uo pipefail

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
