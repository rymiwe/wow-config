#!/usr/bin/env bash
# Install rymiwe/wow-config addons + bindings into a WoW Anniversary client.
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/rymiwe/wow-config/main/install.sh | bash
#   curl -sL ... | bash -s -- --fresh
#   WOWDIR=/path/to/wow ACCOUNT=MYACCT bash install.sh
#
# Flags:
#   --wow-dir <path>    Path to WoW root (parent of _anniversary_)
#   --account <name>    Battle.net account folder name (under WTF/Account/)
#   --fresh             Overwrite bindings + reseed auto-setup flag
#   --upsert            Skip existing bindings/SavedVariables (default)
#   --branch <name>     Repo branch (default: main)

set -euo pipefail

WOWDIR="${WOWDIR:-}"
ACCOUNT="${ACCOUNT:-}"
MODE="${MODE:-upsert}"
BRANCH="${BRANCH:-main}"
REPO_URL="${REPO_URL:-https://github.com/rymiwe/wow-config.git}"

while [[ $# -gt 0 ]]; do
    case $1 in
        --wow-dir) WOWDIR="$2"; shift 2 ;;
        --account) ACCOUNT="$2"; shift 2 ;;
        --branch)  BRANCH="$2"; shift 2 ;;
        --mode)    MODE="$2"; shift 2 ;;
        --fresh)   MODE="fresh"; shift ;;
        --upsert)  MODE="upsert"; shift ;;
        -h|--help) sed -n '2,17p' "$0"; exit 0 ;;
        *) echo "Unknown arg: $1" >&2; exit 1 ;;
    esac
done

find_wow_dir() {
    if [[ -n "$WOWDIR" && -d "$WOWDIR/_anniversary_" ]]; then
        echo "$WOWDIR"; return
    fi
    # Steam Deck Proton prefixes (any compatdata appid)
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
    echo "ERROR: Could not find WoW install. Set WOWDIR=/path or pass --wow-dir." >&2
    exit 1
}

WOW="$(find_wow_dir)"

find_account() {
    if [[ -n "$ACCOUNT" ]]; then echo "$ACCOUNT"; return; fi
    local acct_dir="$WOW/_anniversary_/WTF/Account"
    if [[ ! -d "$acct_dir" ]]; then
        echo "ERROR: No WTF/Account directory at $acct_dir. Launch WoW once first." >&2
        exit 1
    fi
    local accts=()
    for d in "$acct_dir"/*/; do
        local name
        name="$(basename "$d")"
        [[ "$name" == "SavedVariables" ]] && continue
        accts+=("$name")
    done
    if [[ ${#accts[@]} -eq 0 ]]; then echo "ERROR: No account folders" >&2; exit 1; fi
    if [[ ${#accts[@]} -eq 1 ]]; then echo "${accts[0]}"; return; fi
    echo "Multiple accounts:" >&2
    for i in "${!accts[@]}"; do echo "  [$i] ${accts[$i]}" >&2; done
    read -r -p "Select account index: " idx
    echo "${accts[$idx]}"
}

ACCT="$(find_account)"

echo "WoW directory:  $WOW"
echo "Account:        $ACCT"
echo "Mode:           $MODE"
echo "Repo:           $REPO_URL ($BRANCH)"

TMP="$(mktemp -d -t wow-config-XXXXXX)"
trap 'rm -rf "$TMP"' EXIT
echo "Cloning repo..."
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMP" >/dev/null

SRC_ADDONS="$TMP/_anniversary_/Interface/AddOns"
DST_ADDONS="$WOW/_anniversary_/Interface/AddOns"
SRC_TPL="$TMP/templates"
DST_SV="$WOW/_anniversary_/WTF/Account/$ACCT/SavedVariables"
DST_BIND="$WOW/_anniversary_/WTF/Account/$ACCT/bindings-cache.wtf"
DST_CONFIG="$WOW/_anniversary_/WTF/Config.wtf"

mkdir -p "$DST_ADDONS" "$DST_SV"

ADDONS=(SetupCore ChatAnchor ShamanSetup DruidSetup HunterSetup PaladinSetup WarriorSetup)
for a in "${ADDONS[@]}"; do
    src="$SRC_ADDONS/$a"
    dst="$DST_ADDONS/$a"
    if [[ ! -d "$src" ]]; then echo "WARN: source not found: $src" >&2; continue; fi
    rm -rf "$dst"
    cp -r "$src" "$dst"
    echo "Installed addon: $a"
done

if [[ "$MODE" == "fresh" || ! -f "$DST_SV/SetupCore.lua" ]]; then
    cp "$SRC_TPL/SetupCore.lua" "$DST_SV/SetupCore.lua"
    echo "Seeded SetupCoreDB.needsSetup = true"
else
    echo "SetupCore.lua exists - leaving alone (use --fresh to reset)"
fi

if [[ "$MODE" == "fresh" || ! -f "$DST_BIND" ]]; then
    cp "$SRC_TPL/bindings-cache.wtf" "$DST_BIND"
    echo "Installed bindings-cache.wtf"
else
    echo "bindings-cache.wtf exists - leaving alone (use --fresh to overwrite)"
fi

# ElvUI.lua — full UI layout. --fresh deploys; --upsert preserves existing.
if [[ -f "$SRC_TPL/ElvUI.lua" ]]; then
    DST_ELVUI="$DST_SV/ElvUI.lua"
    if [[ "$MODE" == "fresh" || ! -f "$DST_ELVUI" ]]; then
        cp "$SRC_TPL/ElvUI.lua" "$DST_ELVUI"
        echo "Installed ElvUI.lua (full layout)"
    else
        echo "ElvUI.lua exists - leaving alone (use --fresh to install layout)"
    fi
fi

# Config.wtf — CVar defaults. Append-merge to avoid clobbering user graphics settings.
if [[ -f "$SRC_TPL/Config.wtf" ]]; then
    if [[ "$MODE" == "fresh" || ! -f "$DST_CONFIG" ]]; then
        cp "$SRC_TPL/Config.wtf" "$DST_CONFIG"
        echo "Installed Config.wtf (CVar defaults)"
    else
        # Append SET keys not already present
        appended=0
        while IFS= read -r line; do
            if [[ "$line" =~ ^SET[[:space:]]+([^[:space:]]+)[[:space:]] ]]; then
                key="${BASH_REMATCH[1]}"
                if ! grep -qE "^SET[[:space:]]+${key}[[:space:]]" "$DST_CONFIG"; then
                    echo "$line" >> "$DST_CONFIG"
                    appended=$((appended+1))
                fi
            fi
        done < "$SRC_TPL/Config.wtf"
        echo "Config.wtf merged ($appended new CVars added; existing untouched)"
    fi
fi

# Clean up CurseBreaker artifacts from older install.sh runs (we replaced it
# with direct downloads). Safe to remove; no in-flight state.
ANN_DIR="$WOW/_anniversary_"
for f in "$ANN_DIR/CurseBreaker" "$ANN_DIR/CurseBreaker.exe" "$ANN_DIR/CB.json" \
         "$ANN_DIR/CurseBreaker_storage.json" "$ANN_DIR/CurseBreaker.html"; do
    [[ -e "$f" ]] && rm -f "$f" && echo "Removed leftover $(basename "$f")"
done

# Companion addons: direct downloads from canonical sources, no addon manager.
# Each addon fetched fresh from upstream so we always get the latest version
# without WoWInterface multi-release ambiguity or readline/console issues that
# tripped CurseBreaker on Steam Deck. Re-run install.sh (or scripts/update-addons.sh)
# anytime to refresh.
ADDONS_DIR="$ANN_DIR/Interface/AddOns"

# Helper: download a zip and unpack into AddOns dir. Tolerates individual failures.
fetch_addon_zip() {
    local name="$1" url="$2"
    if [[ -z "$url" ]]; then
        echo "WARN: $name has no download URL (upstream changed?)" >&2
        return 1
    fi
    local tmp; tmp="$(mktemp -t "addon-XXXXXX.zip")"
    if curl -fsSL "$url" -o "$tmp" 2>/dev/null; then
        if unzip -qo "$tmp" -d "$ADDONS_DIR" 2>/dev/null; then
            echo "Installed $name"
        else
            echo "WARN: $name unzip failed" >&2
        fi
    else
        echo "WARN: $name download failed from $url" >&2
    fi
    rm -f "$tmp"
}

# GitHub Releases: extract the first .zip asset's browser_download_url.
github_latest_zip() {
    curl -fsSL "https://api.github.com/repos/$1/releases/latest" 2>/dev/null \
        | grep -oE '"browser_download_url": *"[^"]+\.zip"' | head -1 \
        | sed -E 's|^.*"(https[^"]+)"|\1|'
}

echo
echo "Installing companion addons (ElvUI, WeakAuras, BadBoy, Questie, OPie)..."

# ElvUI from Tukui's JSON API.
elvui_url="$(curl -fsSL "https://api.tukui.org/v1/addon/elvui" 2>/dev/null \
    | grep -oE '"url":"[^"]+"' | head -1 | sed -E 's|^"url":"||;s|"$||')"
fetch_addon_zip "ElvUI" "$elvui_url"

# WeakAuras / Questie / BadBoy from GitHub Releases (multi-flavor TOCs).
fetch_addon_zip "WeakAuras" "$(github_latest_zip WeakAuras/WeakAuras2)"
fetch_addon_zip "Questie"   "$(github_latest_zip Questie/Questie)"
fetch_addon_zip "BadBoy"    "$(github_latest_zip funkydude/BadBoy)"
# OPie from townlong-yak. Two-step fetch: main page links to the current
# /addons/opie/release/<major.minor>/ which contains the actual zip URL with
# a /addons/gate/<hash>/ anti-hotlink prefix.
opie_main="$(curl -fsSL https://www.townlong-yak.com/addons/opie 2>/dev/null || true)"
opie_ver_path="$(echo "$opie_main" | grep -oE 'href="/addons/opie/release/[0-9.]+"' | head -1 | sed -E 's|^href="||; s|"$||')"
if [[ -n "$opie_ver_path" ]]; then
    opie_ver_page="$(curl -fsSL "https://www.townlong-yak.com${opie_ver_path}" 2>/dev/null || true)"
    opie_zip_path="$(echo "$opie_ver_page" | grep -oE 'href="/addons/gate/[a-f0-9]+/opie/OPie-[0-9.]+\.zip"' | head -1 | sed -E 's|^href="||; s|"$||')"
    if [[ -n "$opie_zip_path" ]]; then
        rm -rf "$ADDONS_DIR/OPie"
        fetch_addon_zip "OPie" "https://www.townlong-yak.com${opie_zip_path}"
    else
        echo "WARN: OPie zip URL not found on version page; install manually from https://www.townlong-yak.com/addons/opie" >&2
    fi
else
    echo "WARN: OPie release page link not found on main page; install manually from https://www.townlong-yak.com/addons/opie" >&2
fi

echo
echo "Note: TSM (TradeSkillMaster) is not on free addon sources we can auto-install."
echo "      Install via https://www.curseforge.com/wow/addons/trade-skill-master if you want it."

echo
echo "Install complete. Next steps:"
echo "  1. Launch WoW and log in - SetupCore runs /setupbars on first login."
echo "  2. OPie rings auto-bind to M4 (primary) and M5 (secondary) on first login."
echo "     If a ring isn't bound, /opie -> Ring Bindings to set it manually (overrides persist)."
echo "  3. (Optional) Install TSM from CurseForge if you use the Auction House."
echo "  4. (Optional) /tsm -> Groups -> Import each file from templates/tsm-groups/"
