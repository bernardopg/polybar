#!/usr/bin/env bash
set -euo pipefail

# Kill existing bars
polybar-msg cmd quit || killall -q polybar || true

# Wait for all to die
for i in {1..10}; do
	pgrep -u "$UID" -x polybar >/dev/null || break
	sleep 0.25
done

PRIMARY=$(xrandr --query | awk '/ primary/{print $1; exit}')
[[ -z "${PRIMARY:-}" ]] && PRIMARY=$(xrandr --query | awk '/ connected/{print $1; exit}')

MONITORS=( $(xrandr --query | awk '/ connected/{print $1}') )

# Calculate DPI-based sizes for each monitor and launch bars
calc_and_launch() {
  local mon="$1"
  local barname="$2"

  # Parse current mode and physical size
  local info w h mmw mmh dpi
  info=$(xrandr --query | awk -v M="$mon" '$1==M && $2=="connected"{print; getline; print}')
  w=$(awk -v M="$mon" '$1==M && $2=="connected"{print $3}' <<<"$info" | awk -F'[x+]' '{print $1}')
  h=$(awk -v M="$mon" '$1==M && $2=="connected"{print $3}' <<<"$info" | awk -F'[x+]' '{print $2}')
  mmw=$(awk -F'[^0-9]+' 'NF>=3{print $(NF-1)}' <<<"$info" | head -n1)
  mmh=$(awk -F'[^0-9]+' 'NF>=2{print $NF}' <<<"$info" | head -n1)

  # Calculate DPI and set appropriate sizes
  if [[ -n "${w:-}" && -n "${h:-}" && -n "${mmw:-}" && -n "${mmh:-}" && "$mmw" -gt 0 && "$mmh" -gt 0 ]]; then
    dpi=$(awk -v w="$w" -v h="$h" -v mmw="$mmw" -v mmh="$mmh" 'BEGIN{px=sqrt(w*w+h*h); mm=sqrt(mmw*mmw+mmh*mmh); printf("%.0f", (px/mm)*25.4)}')

    # Set sizes based on DPI
    if (( dpi > 150 )); then
      export POLYBAR_HEIGHT=42
      export POLYBAR_RADIUS=16
      export POLYBAR_TRAY_SIZE=22
    elif (( dpi > 120 )); then
      export POLYBAR_HEIGHT=38
      export POLYBAR_RADIUS=12
      export POLYBAR_TRAY_SIZE=20
    else
      export POLYBAR_HEIGHT=36
      export POLYBAR_RADIUS=2
      export POLYBAR_TRAY_SIZE=18
    fi
  else
    # Default sizes for when we can't calculate DPI
    export POLYBAR_HEIGHT=36
    export POLYBAR_RADIUS=2

    export POLYBAR_TRAY_SIZE=18
  fi

  # Launch polybar for this monitor
  MONITOR="$mon" polybar --reload "$barname" &
  echo "Launched $barname on $mon (${w}x${h}, DPI: ${dpi:-unknown})"
}

# Launch bars on all monitors
for M in "${MONITORS[@]}"; do
  if [[ "$M" == "$PRIMARY" ]]; then
    calc_and_launch "$M" primary
  else
    calc_and_launch "$M" secondary
  fi
done

echo "Polybar launched on: ${MONITORS[*]} (primary: $PRIMARY)"
