#!/bin/bash
# hypr-wow-focus.sh — auto-switch Hyprland submap based on WoW focus.
#
# Listens to Hyprland's IPC event stream (.socket2.sock). When the active
# window class is WoW, switches into the "wow" submap so Super+1-9 passes
# through to the game. When focus moves to anything else, switches back to
# the default submap so workspaces work normally.
#
# Run via `exec-once = ~/.config/hypr/scripts/hypr-wow-focus.sh &` in
# hyprland.conf, OR manually for current session. Loops on socat exit so it
# survives Hyprland reloads.
#
# Dependencies: socat (sudo pacman -S socat on Arch/Omarchy).

set -uo pipefail

# Match WoW window class names. Proton/Wine sometimes capitalizes
# differently across patches; match all known variants.
is_wow() {
    case "$1" in
        wow.exe|Wow.exe|WoW.exe|wowclassic.exe|WowClassic.exe|WoWClassic.exe) return 0 ;;
        *) return 1 ;;
    esac
}

main_loop() {
    local socket="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
    if [[ ! -S "$socket" ]]; then
        echo "WARN: Hyprland IPC socket not found at $socket - is Hyprland running?"
        return 1
    fi
    local current_submap=""
    socat -U - "UNIX-CONNECT:$socket" | while IFS= read -r line; do
        case "$line" in
            activewindow*)
                # Format: activewindow>>CLASS,TITLE
                payload="${line#activewindow>>}"
                class="${payload%%,*}"
                if is_wow "$class"; then
                    if [[ "$current_submap" != "wow" ]]; then
                        hyprctl dispatch submap wow >/dev/null
                        current_submap="wow"
                    fi
                else
                    if [[ "$current_submap" == "wow" ]]; then
                        hyprctl dispatch submap reset >/dev/null
                        current_submap=""
                    fi
                fi
                ;;
        esac
    done
}

# Reconnect loop: if socat exits (Hyprland restart, socket disconnect), wait
# briefly and try again. Avoids busy-loop on persistent failure.
while true; do
    main_loop || true
    sleep 2
done
