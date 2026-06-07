#!/usr/bin/env bash
# Refresh community addons (ElvUI, WeakAuras, BadBoy, Questie, OPie, TotemTimers) to latest
# upstream versions. Doesn't touch our custom addons, bindings, or SavedVariables.
#
# Usage:
#   ./scripts/update-addons.sh                           # auto-detect WoW dir
#   WOWDIR=/path/to/World\ of\ Warcraft ./scripts/update-addons.sh

set -e

WOWDIR="${WOWDIR:-}"
find_wow_dir() {
    if [[ -n "$WOWDIR" && -d "$WOWDIR/_anniversary_" ]]; then
        echo "$WOWDIR"; return
    fi
    for d in "$HOME"/.steam/steam/steamapps/compatdata/*/pfx/drive_c/Program\ Files\ \(x86\)/World\ of\ Warcraft \
             "$HOME"/.steam/steam/steamapps/compatdata/*/pfx/drive_c/Program\ Files/World\ of\ Warcraft \
             "$HOME"/Games/battlenet/drive_c/Program\ Files\ \(x86\)/World\ of\ Warcraft \
             "$HOME"/.local/share/lutris/runners/wine/*/drive_c/Program\ Files\ \(x86\)/World\ of\ Warcraft \
             "$HOME"/.local/share/lutris/games/world-of-warcraft \
             /Applications/World\ of\ Warcraft \
             "$HOME"/Games/World\ of\ Warcraft \
             "$HOME"/Games/world-of-warcraft \
             "$HOME"/World\ of\ Warcraft; do
        if [[ -d "$d/_anniversary_" ]]; then echo "$d"; return; fi
    done
    echo "ERROR: Could not find WoW install. Set WOWDIR=/path." >&2
    exit 1
}

WOW="$(find_wow_dir)"
ADDONS_DIR="$WOW/_anniversary_/Interface/AddOns"
echo "Updating addons in: $ADDONS_DIR"

fetch_addon_zip() {
    local name="$1" url="$2"
    if [[ -z "$url" ]]; then
        echo "WARN: $name has no download URL (upstream changed?)" >&2; return 1
    fi
    local tmp; tmp="$(mktemp -t "addon-XXXXXX.zip")"
    if curl -fsSL "$url" -o "$tmp" 2>/dev/null; then
        if unzip -qo "$tmp" -d "$ADDONS_DIR" 2>/dev/null; then
            echo "  Updated $name"
        else
            echo "WARN: $name unzip failed" >&2
        fi
    else
        echo "WARN: $name download failed" >&2
    fi
    rm -f "$tmp"
}

github_latest_zip() {
    curl -fsSL "https://api.github.com/repos/$1/releases/latest" 2>/dev/null \
        | grep -oE '"browser_download_url": *"[^"]+\.zip"' | head -1 \
        | sed -E 's|^.*"(https[^"]+)"|\1|'
}

elvui_url="$(curl -fsSL "https://api.tukui.org/v1/addon/elvui" 2>/dev/null \
    | grep -oE '"url":"[^"]+"' | head -1 | sed -E 's|^"url":"||;s|"$||')"
fetch_addon_zip "ElvUI"     "$elvui_url"
fetch_addon_zip "WeakAuras" "$(github_latest_zip WeakAuras/WeakAuras2)"
fetch_addon_zip "Questie"   "$(github_latest_zip Questie/Questie)"
fetch_addon_zip "BadBoy"    "$(github_latest_zip funkydude/BadBoy)"
fetch_addon_zip "TotemTimers" "$(github_latest_zip taubut/TotemTimers_Fork)"

opie_main="$(curl -fsSL https://www.townlong-yak.com/addons/opie 2>/dev/null || true)"
opie_ver_path="$(echo "$opie_main" | grep -oE 'href="/addons/opie/release/[0-9.]+"' | head -1 | sed -E 's|^href="||; s|"$||')"
if [[ -n "$opie_ver_path" ]]; then
    opie_ver_page="$(curl -fsSL "https://www.townlong-yak.com${opie_ver_path}" 2>/dev/null || true)"
    opie_zip_path="$(echo "$opie_ver_page" | grep -oE 'href="/addons/gate/[a-f0-9]+/opie/OPie-[0-9.]+\.zip"' | head -1 | sed -E 's|^href="||; s|"$||')"
    if [[ -n "$opie_zip_path" ]]; then
        rm -rf "$ADDONS_DIR/OPie"
        fetch_addon_zip "OPie" "https://www.townlong-yak.com${opie_zip_path}"
    fi
fi

echo "Done. /reload in-game to load new versions."
