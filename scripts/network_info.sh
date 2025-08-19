#!/usr/bin/env bash
# Unified network widget with icons, SSID/IP, throughput
# Depends: ip, awk, nmcli (optional), iw (optional)

set -euo pipefail

ICON_ETH=""   # Ethernet
ICON_WIFI=""
ICON_DOWN=""
ICON_UP=""
ICON_OFF=""

# Pick active interface (non-lo, operstate up)
pick_iface() {
  for dev in $(ls /sys/class/net | grep -v '^lo$'); do
    [[ -r "/sys/class/net/$dev/operstate" ]] || continue
    oper=$(cat /sys/class/net/$dev/operstate)
    if [[ "$oper" == "up" ]]; then echo "$dev"; return; fi
  done
  for dev in $(ls /sys/class/net | grep -v '^lo$'); do echo "$dev"; return; done
}

iface=${1:-auto}
if [[ "$iface" == "auto" ]]; then iface=$(pick_iface); fi

if [[ -z "${iface:-}" || ! -d "/sys/class/net/$iface" ]]; then
  echo "$ICON_OFF offline"
  exit 0
fi

# Determine type and details
if [[ -d "/sys/class/net/$iface/wireless" ]]; then
  icon=$ICON_WIFI
  ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}')
  [[ -z "${ssid:-}" ]] && ssid=$(iw dev 2>/dev/null | awk '/ssid/{print $2; exit}')
  name=${ssid:-wifi}
else
  icon=$ICON_ETH
  name=$iface
fi

ipaddr=$(ip -o -4 addr show dev "$iface" 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n1)

# Throughput using the existing network.sh in tail mode
# We spawn it in the background and read a single line if not already running under polybar tail.
if [[ -t 1 ]]; then
  # Non-tail invocation: print a single snapshot
  updown=$(~/.config/polybar/scripts/network.sh "$iface" | head -n1)
  up=$(awk '{print $1}' <<<"$updown")
  down=$(awk '{print $2}' <<<"$updown")
  printf "%s %s  %s %s kB/s  %s %s kB/s\n" "$icon" "${name}" "$ICON_UP" "$up" "$ICON_DOWN" "$down"
  exit 0
fi

# Tail mode: continuously forward network.sh output with richer label
~/.config/polybar/scripts/network.sh "$iface" | while read -r up down; do
  printf "%s %s  %s %s kB/s  %s %s kB/s" "$icon" "${name}" "$ICON_UP" "$up" "$ICON_DOWN" "$down"
  if [[ -n "${ipaddr:-}" ]]; then printf "  %s" "$ipaddr"; fi
  printf "\n"
done
