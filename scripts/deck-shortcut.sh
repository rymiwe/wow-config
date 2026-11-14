#!/usr/bin/env bash
# deck-shortcut.sh - put a "Sync WoW Forever" icon on this machine's desktop
# (made for the Steam Deck's Desktop Mode; works on any Linux desktop).
#
# Double-clicking the icon opens a terminal, runs the latest
# scripts/sync-forever.sh from GitHub, and waits for Enter so you can read
# the result. Run once:
#   curl -sL https://raw.githubusercontent.com/rymiwe/wow-config/main/scripts/deck-shortcut.sh | bash
set -euo pipefail

URL="https://raw.githubusercontent.com/rymiwe/wow-config/main/scripts/sync-forever.sh"
BIN="$HOME/.local/bin/sync-wow-forever"
DESK="$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")"

mkdir -p "$(dirname "$BIN")" "$DESK" "$HOME/.local/share/applications"

cat > "$BIN" <<EOF
#!/usr/bin/env bash
curl -fsSL "$URL" | bash -s -- "\$@"
echo
read -r -p "Press Enter to close." _
EOF
chmod +x "$BIN"

# Konsole on SteamOS/KDE; fall back to whatever terminal exists.
TERM_CMD=""
for t in konsole kgx gnome-terminal alacritty kitty xterm; do
    if command -v "$t" >/dev/null 2>&1; then TERM_CMD="$t"; break; fi
done
case "$TERM_CMD" in
    konsole|xterm|alacritty|kitty) EXEC="$TERM_CMD -e $BIN" ;;
    gnome-terminal|kgx)            EXEC="$TERM_CMD -- $BIN" ;;
    *)                             EXEC="$BIN" ;;
esac

ENTRY="[Desktop Entry]
Type=Application
Name=Sync WoW Forever
Comment=Pull BLD's WoW: Forever layout (close WoW first)
Exec=$EXEC
Icon=view-refresh
Terminal=false
Categories=Game;"

for f in "$DESK/sync-wow-forever.desktop" "$HOME/.local/share/applications/sync-wow-forever.desktop"; do
    printf '%s\n' "$ENTRY" > "$f"
    chmod +x "$f"
done
# KDE marks desktop launchers trusted via this attribute; ignore if unsupported.
command -v gio >/dev/null 2>&1 && gio set "$DESK/sync-wow-forever.desktop" metadata::trusted true 2>/dev/null || true

echo "Added 'Sync WoW Forever' to the desktop and the app menu."
echo "Also available as a command: sync-wow-forever  (add --dry-run to preview)"
