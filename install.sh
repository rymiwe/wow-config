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
#   --fresh             Overwrite bindings/ElvUI/SetupCore + reseed auto-setup flag (DEFAULT)
#   --upsert            Preserve existing bindings/SavedVariables (smart-merge new bindings only)
#   --branch <name>     Repo branch (default: main)

set -euo pipefail

WOWDIR="${WOWDIR:-}"
ACCOUNT="${ACCOUNT:-}"
MODE="${MODE:-fresh}"
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

ADDONS=(SetupCore ChatAnchor ZygorSetup ShamanSetup DruidSetup HunterSetup PaladinSetup WarriorSetup MageSetup PriestSetup RogueSetup WarlockSetup)
for a in "${ADDONS[@]}"; do
    src="$SRC_ADDONS/$a"
    dst="$DST_ADDONS/$a"
    if [[ ! -d "$src" ]]; then echo "WARN: source not found: $src" >&2; continue; fi
    rm -rf "$dst"
    cp -r "$src" "$dst"
    echo "Installed addon: $a"
done

# Auto-detect WoW Anniversary client Interface from .build.info, rewrite each
# custom addon's TOC Interface line to match. Handles minor version bumps
# (2.5.5 -> 2.5.6 -> ...) without manual TOC edits. Falls back to 20505 if
# .build.info is missing or unparseable.
detect_anniversary_interface() {
    local build_info="$WOW/.build.info"
    [[ -f "$build_info" ]] || { echo "20505"; return; }
    local header version_col= product_col=
    IFS='|' read -ra cols < "$build_info"
    for i in "${!cols[@]}"; do
        case "${cols[$i]}" in
            Version!*) version_col=$i ;;
            Product!*) product_col=$i ;;
        esac
    done
    [[ -z "$version_col" || -z "$product_col" ]] && { echo "20505"; return; }
    local version=""
    while IFS='|' read -ra row; do
        if [[ "${row[$product_col]:-}" == "wow_anniversary" ]]; then
            version="${row[$version_col]}"
            break
        fi
    done < <(tail -n +2 "$build_info")
    if [[ "$version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
        printf "%d%02d%02d\n" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
    else
        echo "20505"
    fi
}

INTERFACE_NUM="$(detect_anniversary_interface)"
echo "Detected Anniversary client Interface: $INTERFACE_NUM"
for a in "${ADDONS[@]}"; do
    toc="$DST_ADDONS/$a/$a.toc"
    if [[ -f "$toc" ]]; then
        tmp="$(mktemp)"
        awk -v iface="$INTERFACE_NUM" '/^## Interface:/ {print "## Interface: " iface; next} {print}' "$toc" > "$tmp"
        mv "$tmp" "$toc"
    fi
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
    # Smart merge: append template's `bind KEY ACTION` lines whose KEY is not
    # already bound locally. Preserves user's /ec customizations (their KEY
    # binding wins) while letting new bindings (e.g., META-X duplicates) land
    # without --fresh. Comments + blank lines from template are skipped.
    local_keys=$(awk '/^bind / {print $2}' "$DST_BIND")
    added=0
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        [[ ! "$line" =~ ^bind[[:space:]] ]] && continue
        key=$(awk '{print $2}' <<< "$line")
        if ! grep -Fxq "$key" <<< "$local_keys"; then
            echo "$line" >> "$DST_BIND"
            added=$((added+1))
        fi
    done < "$SRC_TPL/bindings-cache.wtf"
    if [[ $added -gt 0 ]]; then
        echo "bindings-cache.wtf: appended $added new binding(s) from template (existing bindings preserved)"
    else
        echo "bindings-cache.wtf: up-to-date (no new template bindings)"
    fi
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

# Read local TOC ## Version field from an addon directory. Many addons ship
# multi-flavor TOCs (ElvUI_TBC.toc, ElvUI_Mainline.toc, WeakAuras_TBC.toc, etc.)
# instead of a single <Name>.toc, so we glob for any *.toc and prefer the TBC
# variant for our Anniversary client. Returns empty if no TOC found/parseable.
local_toc_version() {
    local addon_dir="$1"
    local toc=""
    for candidate in "$addon_dir"/*_TBC.toc "$addon_dir"/*_Wrath.toc "$addon_dir"/*_Vanilla.toc "$addon_dir"/*.toc; do
        if [[ -f "$candidate" ]]; then
            toc="$candidate"
            break
        fi
    done
    [[ -z "$toc" ]] && { echo ""; return; }
    grep -oE '^## Version:[[:space:]]*\S+' "$toc" 2>/dev/null \
        | head -1 | sed -E 's|^## Version:[[:space:]]*||'
}

# Normalize version strings for comparison. Strips leading "v" / "V".
strip_v() { sed -E 's|^[vV]||'; }

# Skip download if local TOC version matches remote. Otherwise fetch + unzip.
maybe_install_addon() {
    local name="$1" addon_dir="$2" remote_ver="$3" url="$4"
    local local_ver; local_ver="$(local_toc_version "$addon_dir")"
    if [[ -n "$local_ver" && -n "$remote_ver" ]]; then
        local lv; lv="$(echo "$local_ver" | strip_v)"
        local rv; rv="$(echo "$remote_ver" | strip_v)"
        if [[ "$lv" == "$rv" ]]; then
            echo "$name: up-to-date (v$lv)"
            return 0
        fi
    fi
    if [[ -z "$local_ver" ]]; then
        echo "$name: not installed -> v${remote_ver:-?}"
    else
        echo "$name: v$local_ver -> v${remote_ver:-?}"
    fi
    fetch_addon_zip "$name" "$url"
}

# GitHub Releases: returns "VERSION|URL" tuple (extract tag_name + first zip URL).
github_latest_release() {
    local data; data="$(curl -fsSL "https://api.github.com/repos/$1/releases/latest" 2>/dev/null)"
    local ver; ver="$(echo "$data" | grep -oE '"tag_name": *"[^"]+"' | head -1 | sed -E 's|^.*"tag_name": *"([^"]+)"|\1|')"
    local url; url="$(echo "$data" | grep -oE '"browser_download_url": *"[^"]+\.zip"' | head -1 | sed -E 's|^.*"(https[^"]+)"|\1|')"
    echo "${ver}|${url}"
}

echo
echo "Checking companion addons (ElvUI, WeakAuras, BadBoy, Questie, OPie)..."

# ElvUI from Tukui's JSON API.
elvui_json="$(curl -fsSL "https://api.tukui.org/v1/addon/elvui" 2>/dev/null)"
elvui_url="$(echo "$elvui_json" | grep -oE '"url":"[^"]+"' | head -1 | sed -E 's|^"url":"||;s|"$||')"
elvui_ver="$(echo "$elvui_json" | grep -oE '"version":"[^"]+"' | head -1 | sed -E 's|^"version":"||;s|"$||')"
maybe_install_addon "ElvUI" "$ADDONS_DIR/ElvUI" "$elvui_ver" "$elvui_url"

# WeakAuras / Questie / BadBoy from GitHub Releases (multi-flavor TOCs).
wa_data="$(github_latest_release WeakAuras/WeakAuras2)"
maybe_install_addon "WeakAuras" "$ADDONS_DIR/WeakAuras" "${wa_data%%|*}" "${wa_data##*|}"
q_data="$(github_latest_release Questie/Questie)"
maybe_install_addon "Questie" "$ADDONS_DIR/Questie" "${q_data%%|*}" "${q_data##*|}"
bb_data="$(github_latest_release funkydude/BadBoy)"
maybe_install_addon "BadBoy" "$ADDONS_DIR/BadBoy" "${bb_data%%|*}" "${bb_data##*|}"
# OPie from townlong-yak. Two-step fetch: main page links to the current
# /addons/opie/release/<major.minor>/ which contains the actual zip URL with
# a /addons/gate/<hash>/ anti-hotlink prefix.
opie_main="$(curl -fsSL https://www.townlong-yak.com/addons/opie 2>/dev/null || true)"
opie_ver_path="$(echo "$opie_main" | grep -oE 'href="/addons/opie/release/[0-9.]+"' | head -1 | sed -E 's|^href="||; s|"$||')"
if [[ -n "$opie_ver_path" ]]; then
    opie_ver_page="$(curl -fsSL "https://www.townlong-yak.com${opie_ver_path}" 2>/dev/null || true)"
    opie_zip_path="$(echo "$opie_ver_page" | grep -oE 'href="/addons/gate/[a-f0-9]+/opie/OPie-[0-9.]+\.zip"' | head -1 | sed -E 's|^href="||; s|"$||')"
    if [[ -n "$opie_zip_path" ]]; then
        # Extract version from URL via bash parameter expansion (cleaner than
        # regex - the previous `[0-9.]+` greedy match captured the dot from
        # `.zip` giving "8.3.3." with trailing dot, breaking version compare).
        opie_tmp="${opie_zip_path##*OPie-}"; opie_ver="${opie_tmp%.zip}"
        local_opie="$(local_toc_version "$ADDONS_DIR/OPie")"
        # OPie TOC may have extra version components (e.g., 6.7.4.5); accept
        # match in either direction (local prefix-of remote OR remote prefix-of local).
        if [[ -n "$local_opie" && ( "$local_opie" == "$opie_ver"* || "$opie_ver" == "$local_opie"* ) ]]; then
            echo "OPie: up-to-date (v$local_opie)"
        else
            if [[ -z "$local_opie" ]]; then
                echo "OPie: not installed -> v$opie_ver"
            else
                echo "OPie: v$local_opie -> v$opie_ver"
            fi
            rm -rf "$ADDONS_DIR/OPie"
            fetch_addon_zip "OPie" "https://www.townlong-yak.com${opie_zip_path}"
        fi
    else
        echo "WARN: OPie zip URL not found on version page; install manually from https://www.townlong-yak.com/addons/opie" >&2
    fi
else
    echo "WARN: OPie release page link not found on main page; install manually from https://www.townlong-yak.com/addons/opie" >&2
fi

echo
echo "Note: TSM (TradeSkillMaster) is not on free addon sources we can auto-install."
echo "      Install via https://www.curseforge.com/wow/addons/trade-skill-master if you want it."

# On Linux/Mac, drop a .desktop launcher so the user can add "WoW Updater" as a
# non-Steam game (Steam Deck Game Mode access). Steam's "Add Non-Steam Game"
# picker scans ~/.local/share/applications/ and auto-lists this entry.
case "$(uname -s)" in
    Linux*|Darwin*)
        APPS_DIR="$HOME/.local/share/applications"
        mkdir -p "$APPS_DIR"
        DESKTOP_FILE="$APPS_DIR/wow-config-update.desktop"
        cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=WoW Updater
Comment=Refresh wow-config: addons + custom code + bindings + templates (full wcu)
Exec=bash -c "curl -sL https://raw.githubusercontent.com/rymiwe/wow-config/main/install.sh | bash 2>&1 | tee /tmp/wow-update.log; notify-send 'wow-config' 'wow-config refreshed - check /tmp/wow-update.log if anything looks off' 2>/dev/null || true"
Icon=applications-games
Categories=Game;
Terminal=false
StartupNotify=false
EOF
        chmod +x "$DESKTOP_FILE"
        echo
        echo "Created launcher: $DESKTOP_FILE"
        echo "  To use from Steam Deck Game Mode:"
        echo "  - In Desktop Mode: Steam -> Library -> + Add a Game -> Add a Non-Steam Game"
        echo "  - Check 'WoW Updater' in the list, click Add"
        echo "  - It now appears in Game Mode library; click to update addons silently"
        ;;
esac

echo
echo "Install complete. Next steps:"
echo "  1. Launch WoW and log in - SetupCore runs /setupbars on first login."
echo "  2. OPie rings auto-bind to M4 (primary) and M5 (secondary) on first login."
echo "     If a ring isn't bound, /opie -> Ring Bindings to set it manually (overrides persist)."
echo "  3. (Optional) Install TSM from CurseForge if you use the Auction House."
echo "  4. (Optional) /tsm -> Groups -> Import each file from templates/tsm-groups/"

# Hyprland integration - auto-run on Hyprland-detected systems (Omarchy etc.)
# so Super+1-9 passes through to WoW while focused. Idempotent; safe on every
# wcu refresh. Per the "opinionated, fresh always" philosophy: detect, do.
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] || command -v hyprctl >/dev/null 2>&1; then
    echo
    echo "Hyprland detected - applying integration (Super+number passes to WoW)..."
    REPO_DIR="$TMP" bash "$TMP/scripts/install-omarchy-wow.sh"
fi

# Offer to install a `wcu` (WoW Config Update) shell alias for one-command refreshes.
SHELL_RC=""
case "$(basename "${SHELL:-}")" in
    bash) SHELL_RC="$HOME/.bashrc" ;;
    zsh)  SHELL_RC="$HOME/.zshrc" ;;
esac
if [[ -n "$SHELL_RC" && -f "$SHELL_RC" ]]; then
    if ! grep -q "alias wcu=" "$SHELL_RC" 2>/dev/null; then
        echo
        echo "Tip: add a 'wcu' alias to refresh wow-config in one command:"
        echo "  echo \"alias wcu='curl -sL https://raw.githubusercontent.com/rymiwe/wow-config/main/install.sh | bash'\" >> $SHELL_RC"
        echo "  source $SHELL_RC"
        echo "Then any time, just run:  wcu"
    else
        echo
        echo "(wcu alias already in $SHELL_RC - just run 'wcu' to refresh next time)"
    fi
fi
