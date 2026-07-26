#!/usr/bin/env bash
# Refresh community addons (ElvUI, WeakAuras, BadBoy, Questie, OPie, TotemTimers,
# AskMrRobotClassic) to latest upstream versions.
# Doesn't touch our custom addons, bindings, or SavedVariables.
#
# Flavor-aware: defaults to _anniversary_ (unchanged behavior). Pass
# --flavor _classic_era_ to refresh the Classic Era / SoD client instead.
# The Era set skips TotemTimers (Anniversary-only patched fork) and scrapes
# the "Classic" AskMrRobot section instead of "TBC".
#
# NOTE: for _classic_era_ this installs the ElvUI DEV BUILD from GitHub (the
# packaged release lags WoW 1.15.9). See the ELVUI_ERA_DEV block below to revert.
#
# Usage:
#   ./scripts/update-addons.sh                              # _anniversary_ (default)
#   ./scripts/update-addons.sh --flavor _classic_era_       # Classic Era / SoD
#   WOWDIR=/path/to/World\ of\ Warcraft ./scripts/update-addons.sh

set -e

FLAVOR="${FLAVOR:-_anniversary_}"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --flavor)   FLAVOR="$2"; shift 2 ;;
        --flavor=*) FLAVOR="${1#*=}"; shift ;;
        *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

WOWDIR="${WOWDIR:-}"
# A real install has WowClassic.exe inside the flavor folder; testing only for
# the folder can latch onto a stray/dead <flavor> dir (e.g. an orphaned
# Program Files (x86) shell) and install addons where the game never reads them.
find_wow_dir() {
    if [[ -n "$WOWDIR" && -f "$WOWDIR/$FLAVOR/WowClassic.exe" ]]; then
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
        if [[ -f "$d/$FLAVOR/WowClassic.exe" ]]; then echo "$d"; return; fi
    done
    echo "ERROR: Could not find WoW install with '$FLAVOR/WowClassic.exe'. Set WOWDIR=/path." >&2
    exit 1
}

WOW="$(find_wow_dir)"
ADDONS_DIR="$WOW/$FLAVOR/Interface/AddOns"
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

# Scrape a versioned AskMrRobot Classic zip from the section under the given
# <h6> heading (e.g. "TBC" for Anniversary, "Classic" for Classic Era).
amr_section_zip() {
    local section="$1"
    local page; page="$(curl -fsSL "https://www.askmrrobot.com/addon" 2>/dev/null || true)"
    python3 - "$page" "$section" <<'PY'
import re, sys
html = sys.argv[1] if len(sys.argv) > 1 else ""
section = sys.argv[2] if len(sys.argv) > 2 else ""
m = re.search(
    r'<h6>\s*' + re.escape(section) + r'\s*</h6>.*?href="(https://static3\.askmrrobot\.com/wowaddonclassic/askmrrobot-(\d+)\.zip)"',
    html,
    re.I | re.S,
)
if m:
    print(m.group(1))
PY
}

# --- ElvUI on Classic Era: run the DEVELOPMENT build from GitHub -------------
# WoW 1.15.9 (interface 11509) reworked a lot of Blizzard UI internals. The last
# packaged ElvUI *release* (15.18) targets 1.15.8 and crashes on 1.15.9; the
# devs' git 'main' branch already carries the Era/1.15.9 fixes. So for
# _classic_era_ we install ElvUI straight from github.com/tukui-org/ElvUI.
# >>> We are intentionally on the ElvUI DEV BUILD for Classic Era. <<<
# TO REVERT to the stable Tukui release once it catches up to 1.15.9:
# run with ELVUI_ERA_DEV=0 (or flip the default below) and Era will use the
# same Tukui API fetch as Anniversary.
ELVUI_ERA_DEV="${ELVUI_ERA_DEV:-1}"
install_elvui_github_dev() {
    local url="https://github.com/tukui-org/ElvUI/archive/refs/heads/main.zip"
    local tmp tmpdir
    tmp="$(mktemp -t elvui-XXXXXX.zip)"
    tmpdir="$(mktemp -d)"
    if curl -fsSL "$url" -o "$tmp" 2>/dev/null && unzip -qo "$tmp" -d "$tmpdir" 2>/dev/null; then
        local src="$tmpdir/ElvUI-main" a
        for a in ElvUI ElvUI_Libraries ElvUI_Options; do
            if [[ -d "$src/$a" ]]; then
                rm -rf "$ADDONS_DIR/$a"
                cp -r "$src/$a" "$ADDONS_DIR/$a"
            fi
        done
        # git tree uses an @project-version@ placeholder the packager fills in;
        # replace it so ElvUI's version parsing/display is clean.
        find "$ADDONS_DIR/ElvUI" "$ADDONS_DIR/ElvUI_Libraries" "$ADDONS_DIR/ElvUI_Options" \
            -name '*.toc' -exec sed -i 's/@project-version@/dev/g' {} + 2>/dev/null || true
        echo "  Updated ElvUI (GitHub dev build - Classic Era / 1.15.9)"
    else
        echo "WARN: ElvUI dev-build download failed" >&2
    fi
    rm -rf "$tmp" "$tmpdir"
}

if [[ "$FLAVOR" == "_classic_era_" && "$ELVUI_ERA_DEV" == "1" ]]; then
    install_elvui_github_dev
else
    elvui_url="$(curl -fsSL "https://api.tukui.org/v1/addon/elvui" 2>/dev/null \
        | grep -oE '"url":"[^"]+"' | head -1 | sed -E 's|^"url":"||;s|"$||')"
    fetch_addon_zip "ElvUI"     "$elvui_url"
fi
fetch_addon_zip "WeakAuras" "$(github_latest_zip WeakAuras/WeakAuras2)"
fetch_addon_zip "Questie"   "$(github_latest_zip Questie/Questie)"
fetch_addon_zip "BadBoy"    "$(github_latest_zip funkydude/BadBoy)"

# TotemTimers here is a patched TBC fork; Anniversary only.
if [[ "$FLAVOR" == "_anniversary_" ]]; then
    fetch_addon_zip "TotemTimers" "$(github_latest_zip taubut/TotemTimers_Fork)"
fi

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

# AskMrRobot: scrape the section matching this flavor. Both TBC and Classic Era
# builds ship as AskMrRobotClassic; the version differs per game version.
case "$FLAVOR" in
    _anniversary_) amr_section="TBC" ;;
    _classic_era_) amr_section="Classic" ;;
    *)             amr_section="" ;;
esac
if [[ -n "$amr_section" ]]; then
    amr_url="$(amr_section_zip "$amr_section")"
    if [[ -n "$amr_url" ]]; then
        fetch_addon_zip "AskMrRobotClassic" "$amr_url"
    else
        echo "WARN: AskMrRobotClassic '$amr_section' download not found" >&2
    fi
fi

echo "Done. /reload in-game to load new versions."
