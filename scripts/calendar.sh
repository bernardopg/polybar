#!/usr/bin/env bash
# Launch a small calendar: gsimplecal, gnome-calendar, or cal in a terminal

if command -v gsimplecal >/dev/null; then
  gsimplecal & disown
elif command -v gnome-calendar >/dev/null; then
  gnome-calendar & disown
else
  (${TERMINAL:-alacritty} -e sh -lc 'cal -m && read -n1 -r -p "Press any key to close"' ) & disown
fi
