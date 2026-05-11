#!/bin/bash
# install-omarchy-wow.sh — set up Hyprland integration for WoW.
#
# After running install.sh / wcu, run this once on Omarchy or any
# Hyprland-based system to:
#   1. Drop the focus-listener script into ~/.config/hypr/scripts/
#   2. Append the wow submap + exec-once line to ~/.config/hypr/hyprland.conf
#      (idempotent - re-running cleanly replaces prior block)
#   3. Reload Hyprland to apply
#   4. Start the listener for the current session
#
# Idempotent. Safe to re-run after each `wcu`.

set -euo pipefail

REPO_URL="${REPO_URL:-https://raw.githubusercontent.com/rymiwe/wow-config/main}"
HYPR_CONFIG="$HOME/.config/hypr/hyprland.conf"
HYPR_SCRIPTS="$HOME/.config/hypr/scripts"
LISTENER_DST="$HYPR_SCRIPTS/hypr-wow-focus.sh"
MARKER_START="# >>> wow-config:hypr-wow-integration"
MARKER_END="# <<< wow-config:hypr-wow-integration"

# 1. Sanity checks
if [[ ! -f "$HYPR_CONFIG" ]]; then
    echo "ERROR: $HYPR_CONFIG not found - is Hyprland installed?"
    exit 1
fi
if ! command -v socat >/dev/null 2>&1; then
    echo "WARN: 'socat' not installed. The focus listener requires it."
    echo "      Install with: sudo pacman -S socat"
    echo
fi
if ! command -v hyprctl >/dev/null 2>&1; then
    echo "ERROR: 'hyprctl' not found - is Hyprland in PATH?"
    exit 1
fi

# 2. Install focus listener script
mkdir -p "$HYPR_SCRIPTS"
if [[ -d "${REPO_DIR:-}" && -f "${REPO_DIR}/scripts/hypr-wow-focus.sh" ]]; then
    cp "${REPO_DIR}/scripts/hypr-wow-focus.sh" "$LISTENER_DST"
else
    curl -sSL "$REPO_URL/scripts/hypr-wow-focus.sh" -o "$LISTENER_DST"
fi
chmod +x "$LISTENER_DST"
echo "Installed focus listener: $LISTENER_DST"

# 3. Fetch submap template
SUBMAP_TMP=$(mktemp)
trap "rm -f $SUBMAP_TMP" EXIT
if [[ -d "${REPO_DIR:-}" && -f "${REPO_DIR}/templates/hypr-wow-submap.conf" ]]; then
    cp "${REPO_DIR}/templates/hypr-wow-submap.conf" "$SUBMAP_TMP"
else
    curl -sSL "$REPO_URL/templates/hypr-wow-submap.conf" -o "$SUBMAP_TMP"
fi

# 4. Append (or replace) integration block in hyprland.conf
if grep -Fq "$MARKER_START" "$HYPR_CONFIG"; then
    # Block exists - delete then re-append
    sed -i "/$MARKER_START/,/$MARKER_END/d" "$HYPR_CONFIG"
    echo "Replaced existing wow-config block in $HYPR_CONFIG"
else
    echo "Adding wow-config block to $HYPR_CONFIG"
fi

cat >> "$HYPR_CONFIG" <<EOF
$MARKER_START
exec-once = $LISTENER_DST &
$(cat "$SUBMAP_TMP")
$MARKER_END
EOF

# 5. Reload Hyprland
hyprctl reload >/dev/null
echo "Reloaded Hyprland"

# 6. Start (or restart) listener for current session
if pgrep -f "hypr-wow-focus.sh" >/dev/null 2>&1; then
    pkill -f "hypr-wow-focus.sh" || true
    sleep 0.3
fi
nohup "$LISTENER_DST" >/tmp/hypr-wow-focus.log 2>&1 &
echo "Started focus listener (logs: /tmp/hypr-wow-focus.log)"

echo
echo "Done. Test it:"
echo "  - Launch WoW. Press Super+1: should fire in-game (alt-bar slot)."
echo "  - Super+Tab: cycles workspaces."
echo "  - Alt-tab to a browser: Super+1 cycles back to workspace 1 normally."
