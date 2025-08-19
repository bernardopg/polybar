# Polybar setup

A simple Polybar configuration with helper scripts for Bluetooth, network, calendar, power menu, and temperature.

## Files

- `config.ini` – Main Polybar configuration
- `launch.sh` – Kills running bars and launches this setup
- `polybar-launch.desktop` – Optional autostart entry
- `scripts/` – Shell scripts used by modules (bluetooth, network, calendar, power, temperature)

## Quick start

1) Make scripts executable:
   - `chmod +x launch.sh scripts/*.sh`
2) Launch Polybar:
   - `./launch.sh`

## Autostart (optional)

Copy `polybar-launch.desktop` to `~/.config/autostart/` and ensure the `Exec` path points to this folder and `launch.sh` is executable.

## Customize

- Edit `config.ini` to tweak modules, fonts, and colors
- Adjust scripts in `scripts/` to match your tools (e.g., `nmcli`, `bluetoothctl`, `rofi`, `sensors`)
