#!/usr/bin/env bash
# Simple Rofi menu to manage Bluetooth devices
# Requires: rofi (or wofi), bluetoothctl

set -euo pipefail

menu() {
  if command -v rofi >/dev/null; then
    rofi -dmenu -p "Bluetooth" -i
  elif command -v wofi >/dev/null; then
    wofi --dmenu -p "Bluetooth"
  else
    zenity --list --text "Bluetooth" --column "Selection" 2>/dev/null || true
  fi
}

# Build list
mapfile -t entries < <(~/.config/polybar/scripts/bluetooth.sh --list)
entries+=("Toggle Power")

choice=$(printf '%s\n' "${entries[@]}" | menu || true)

case "$choice" in
  *"Toggle Power"*)
    ~/.config/polybar/scripts/bluetooth.sh --toggle &
    ;;
  "") ;;
  *)
    # Extract MAC within parentheses
    mac=$(sed -n 's/.*(\(.*\)).*/\1/p' <<<"$choice")
    if [[ -n "$mac" ]]; then
      if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
        ~/.config/polybar/scripts/bluetooth.sh --disconnect "$mac" &
      else
        ~/.config/polybar/scripts/bluetooth.sh --connect "$mac" &
      fi
    fi
    ;;
 esac
