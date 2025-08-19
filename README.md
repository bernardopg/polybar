# Polybar setup

A simple Polybar configuration with helper scripts for Bluetooth, network, calendar, power menu, and temperature.

## Files

- `config.ini` – Main Polybar configuration
- `launch.sh` – Kills running bars and launches this setup
- `polybar-launch.desktop` – Optional autostart entry
- `scripts/` – Shell scripts used by modules (bluetooth, network, calendar, power, temperature)

## Requirements

- Polybar (3.6+ recommended)
- X11 with `xrandr` (launch script uses xrandr to detect monitors)
- Utilities used by scripts/modules (install as needed):
  - Network: `nmcli` (NetworkManager)
  - Bluetooth: `bluetoothctl` (BlueZ)
  - Audio: `pactl` (PulseAudio) and optional `pavucontrol`
  - Menus: `rofi` (used by menu scripts)
  - Temperature: `sensors` from `lm-sensors`
- Fonts (for icons and good spacing):
  - JetBrains Mono (or another monospace)
  - Symbols Nerd Font Mono (Nerd Fonts)
  - Font Awesome 6 Free + Brands

## Quick start

1) Make scripts executable:
   - `chmod +x launch.sh scripts/*.sh`
2) Launch Polybar:
   - `./launch.sh`

## Screenshots

<p align="center">
   <img src="Captura%20de%20tela%20de%202025-08-19%2002-17-07.png" alt="Screenshot 1" width="48%" />
   <img src="Captura%20de%20tela%20de%202025-08-19%2002-17-54.png" alt="Screenshot 2" width="48%" />
</p>

## Autostart (optional)

Copy `polybar-launch.desktop` to `~/.config/autostart/` and ensure the `Exec` path points to this folder and `launch.sh` is executable.

## Customize

- Edit `config.ini` to tweak modules, fonts, and colors
- Adjust scripts in `scripts/` to match your tools (e.g., `nmcli`, `bluetoothctl`, `rofi`, `sensors`)
