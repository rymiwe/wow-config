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
             /Applications/World\ of\ Warcraft \
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

echo
echo "Install complete. Launch WoW and log in - SetupCore will run /setupbars on first login."
