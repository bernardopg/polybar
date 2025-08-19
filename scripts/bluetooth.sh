#!/usr/bin/env bash
# Advanced Bluetooth widget for Polybar
# Usage:
#   bluetooth.sh                -> prints status with icon
#   bluetooth.sh --toggle       -> toggles power
#   bluetooth.sh --list         -> lists paired devices with state
#   bluetooth.sh --connect MAC  -> connect device
#   bluetooth.sh --disconnect MAC -> disconnect device

set -euo pipefail

ICON_ON="%{F#e100ff}󰂯%{F-}"
ICON_OFF="%{F#e100ff}BT%{F-}"
ICON_CONNECTED="%{F#e100ff}󰂱%{F-}"

power_state() { bluetoothctl show 2>/dev/null | awk -F': ' '/Powered/ {print $2}' ; }

case "${1:-}" in
  --toggle)
    if [[ "$(power_state)" == "yes" ]]; then
      bluetoothctl power off >/dev/null 2>&1 || true
    else
      bluetoothctl power on >/dev/null 2>&1 || true
    fi
    exit 0 ;;
  --list)
    bluetoothctl devices Paired | while read -r _ mac rest; do
      name=${rest}
      if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
        echo "$ICON_CONNECTED $name ($mac)"
      else
        echo "$ICON_ON $name ($mac)"
      fi
    done
    exit 0 ;;
  --connect)
    mac=${2:-}
    [[ -n "$mac" ]] && bluetoothctl connect "$mac" >/dev/null 2>&1 || true
    exit 0 ;;
  --disconnect)
    mac=${2:-}
    [[ -n "$mac" ]] && bluetoothctl disconnect "$mac" >/dev/null 2>&1 || true
    exit 0 ;;
esac

state=$(power_state)
if [[ -z "${state:-}" || "$state" != "yes" ]]; then
  echo "$ICON_OFF off"
  exit 0
fi

# Connected devices names
mapfile -t devices < <(bluetoothctl devices Connected 2>/dev/null | cut -d' ' -f3-)
if [[ ${#devices[@]} -gt 0 ]]; then
  name=${devices[0]}
  short=$(echo "$name" | sed 's/ *$//' | cut -c1-18)
  echo "$ICON_CONNECTED $short"
else
  echo "$ICON_ON on"
fi
