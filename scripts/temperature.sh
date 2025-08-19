#!/usr/bin/env bash
# Temperature via lm-sensors or thermal_zone
# Requires: lm-sensors (sensors) or /sys/class/thermal

if command -v sensors >/dev/null 2>&1; then
  # Try to get CPU temperature from Package id
  temp=$(sensors 2>/dev/null | awk '/Package id [0-9]+:/ {print $4}' | sed 's/[+°C]//g' | head -n1)

  # If that fails, try Tctl (AMD)
  if [[ -z "$temp" ]]; then
    temp=$(sensors 2>/dev/null | awk '/Tctl:/ {print $2}' | sed 's/[+°C]//g' | head -n1)
  fi

  # If that fails, try Core 0
  if [[ -z "$temp" ]]; then
    temp=$(sensors 2>/dev/null | awk '/Core 0:/ {print $3}' | sed 's/[+°C]//g' | head -n1)
  fi

  # Convert to integer
  if [[ -n "$temp" ]]; then
    temp=$(echo "$temp" | cut -d'.' -f1)
    echo "$temp"
    exit 0
  fi
fi

# Fallback to thermal zones
best=0
for t in /sys/class/thermal/thermal_zone*/temp; do
  [[ -r "$t" ]] || continue
  v=$(cat "$t")
  # Convert millidegC to degC if needed
  if [[ "$v" -gt 1000 ]]; then v=$((v/1000)); fi
  (( v > best )) && best=$v
done

echo "$best"
