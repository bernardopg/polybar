#!/usr/bin/env bash
# Network throughput for Polybar
# Prints: up_kB/s down_kB/s on one line
# Requires: awk, grep, cat, sleep

INTERFACE=${1:-auto}
INTERVAL=${INTERVAL:-1}

pick_iface() {
  # Prefer active interfaces with carrier, skip lo
  for dev in $(ls /sys/class/net | grep -v '^lo$'); do
    oper=$(cat /sys/class/net/$dev/operstate 2>/dev/null)
    if [[ "$oper" == "up" ]]; then echo "$dev"; return; fi
  done
  # Fallback to first non-lo
  for dev in $(ls /sys/class/net | grep -v '^lo$'); do echo "$dev"; return; done
}

if [[ "$INTERFACE" == "auto" ]]; then
  IFACE=$(pick_iface)
else
  IFACE=$INTERFACE
fi

rx_prev=$(cat /sys/class/net/$IFACE/statistics/rx_bytes 2>/dev/null)
tx_prev=$(cat /sys/class/net/$IFACE/statistics/tx_bytes 2>/dev/null)
[[ -z "$rx_prev" || -z "$tx_prev" ]] && { echo "0 0"; exit 0; }

while sleep "$INTERVAL"; do
  rx_now=$(cat /sys/class/net/$IFACE/statistics/rx_bytes 2>/dev/null)
  tx_now=$(cat /sys/class/net/$IFACE/statistics/tx_bytes 2>/dev/null)
  drx=$((rx_now - rx_prev))
  dtx=$((tx_now - tx_prev))
  rx_prev=$rx_now
  tx_prev=$tx_now

  # Convert to KB/s
  up=$((dtx / 1024 / INTERVAL))
  down=$((drx / 1024 / INTERVAL))
  echo "$up $down"
done
