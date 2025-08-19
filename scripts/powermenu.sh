#!/usr/bin/env bash
# Ultimate Power Menu optimized for Wayland
# Requires: wofi (preferred for Wayland), rofi, or zenity as fallback

set -euo pipefail

# Colors matching polybar theme
BG="#0B0B10"            # darker background for higher contrast
FG="#E6EEF8"            # brighter foreground for readability
PRIMARY="#FF00D7"       # vivid magenta with better contrast on dark BG
SECONDARY="#C57CED"
ALERT="#FF6B6B"         # clearer alert (red)
OK="#79F2B0"            # accessible success color
ACCENT="#242430"

# Power options with beautiful icons
OPTIONS="󰌾 Lock Screen
󰍃 Log Out
󰤄 Sleep
󰑐 Reboot
󰐥 Power Off
 Cancel"

# Create wofi CSS theme file
create_wofi_theme() {
  local theme_dir="$HOME/.config/wofi"
  local theme_file="$theme_dir/power.css"

  mkdir -p "$theme_dir"

  cat > "$theme_file" << EOF
/* Wofi Power Menu Theme - Wayland Optimized */
window {
    margin: 0px;
    border: 3px solid ${PRIMARY};
    background-color: ${BG};
    border-radius: 20px;
    font-family: "JetBrains Mono", monospace;
    font-size: 14px;
}

#input {
    margin: 20px;
    padding: 15px;
    background-color: transparent;
    color: ${PRIMARY};
    border: none;
    font-size: 16px;
    font-weight: bold;
}

#inner-box {
    margin: 0px;
    padding: 20px;
    background-color: transparent;
}

#outer-box {
    margin: 0px;
    padding: 0px;
    background-color: transparent;
}

#scroll {
    margin: 0px;
    padding: 0px;
}

#text {
    margin: 0px;
    padding: 0px;
    color: ${FG};
    font-size: 14px;
    font-weight: normal;
}

#entry {
    padding: 15px;
    margin: 5px;
    border-radius: 15px;
    border: 2px solid transparent;
    /* more opaque entry background to avoid washed-out/beige look */
    background-color: rgba(30, 30, 38, 0.95);
    color: ${FG};
    min-height: 60px;
}

#entry:selected {
  background-color: ${PRIMARY};
  color: ${BG};
  border-color: ${PRIMARY};
  font-weight: 700;
}

#entry:hover {
  background-color: rgba(255, 0, 215, 0.12);
  border-color: ${PRIMARY};
}

/* Power Off - Special styling */
/* Power Off - special styling preserved but with stronger contrast */
#entry:nth-child(5) {
  color: ${ALERT};
  font-weight: 700;
}

#entry:nth-child(5):selected {
  background-color: ${ALERT};
  color: ${BG};
  border-color: ${ALERT};
}
EOF
}

# Enhanced prompt optimized for Wayland
prompt() {
  # Check if running on Wayland
  if [[ "${XDG_SESSION_TYPE:-}" == "wayland" ]] || [[ -n "${WAYLAND_DISPLAY:-}" ]]; then

    # Prefer rofi on GNOME Wayland for better compatibility
    if command -v rofi >/dev/null; then
      # Create a sophisticated rofi theme matching polybar design
  local rofi_theme="
configuration {
    show-icons: false;
    display-drun: \"\";
    drun-display-format: \"{name}\";
    disable-history: false;
    click-to-exit: true;
    location: 0;
}

* {
  background: ${BG};
  background-alt: #0F0F14;
  foreground: ${FG};
  selected: ${PRIMARY};
  active: ${OK};
  urgent: ${ALERT};
  border-radius: 12px;
  border-color: ${PRIMARY};
  font: \"JetBrains Mono Medium 13\";
}

window {
    transparency: \"real\";
    location: center;
    anchor: center;
    fullscreen: false;
    width: 380px;
    border-radius: 16px;
    cursor: \"default\";
    background-color: @background;
    border: 3px solid;
    border-color: @selected;
}

mainbox {
    enabled: true;
    spacing: 15px;
    margin: 0px;
    padding: 25px;
    background-color: transparent;
    children: [ \"inputbar\", \"listview\" ];
}

inputbar {
    enabled: true;
    spacing: 10px;
    margin: 0px;
    padding: 15px 20px;
    border-radius: 10px;
    background-color: @background-alt;
    text-color: @selected;
    children: [ \"textbox-prompt-colon\", \"prompt\" ];
}

textbox-prompt-colon {
    enabled: true;
    expand: false;
    str: \"󰐥\";
    background-color: transparent;
    text-color: @selected;
    font: \"Symbols Nerd Font Mono 16\";
}

prompt {
    enabled: true;
    background-color: transparent;
    text-color: @selected;
    font: \"JetBrains Mono Bold 14\";
}

listview {
    enabled: true;
    columns: 1;
    lines: 6;
    cycle: true;
    dynamic: true;
    scrollbar: false;
    layout: vertical;
    reverse: false;
    fixed-height: true;
    fixed-columns: true;
    spacing: 8px;
    margin: 0px;
    padding: 0px;
    background-color: transparent;
}

element {
  enabled: true;
  spacing: 12px;
  margin: 0px;
  padding: 16px 20px;
  border-radius: 10px;
  /* darker, near-opaque element background to avoid color bleed */
  background-color: #0F1116;
  text-color: ${FG};
  cursor: pointer;
  border: 2px solid;
  border-color: transparent;
}

element normal.normal {
  background-color: #0F1116;
  text-color: ${FG};
}

/* prevent light/alternate rows by explicitly styling them */
element alternate.normal {
  background-color: #0F1116;
  text-color: ${FG};
}

/* active and urgent with accessible contrast */
element normal.active {
  background-color: @active;
  text-color: @background;
  border-color: @active;
}

element normal.urgent {
  background-color: rgba(255, 107, 107, 0.18);
  text-color: ${ALERT};
  border-color: ${ALERT};
}

element selected.normal {
  background-color: @selected;
  text-color: @background;
  border-color: @selected;
}

element-text {
    background-color: transparent;
    text-color: inherit;
    highlight: inherit;
    cursor: inherit;
    vertical-align: 0.5;
    horizontal-align: 0.0;
    font: \"JetBrains Mono Medium 13\";
}
"

      echo -e "$OPTIONS" | rofi \
        -dmenu \
        -i \
        -p "Power Menu" \
        -theme-str "$rofi_theme" \
        -no-fixed-num-lines \
        -markup-rows

    # Zenity fallback for Wayland
    else
      zenity --list \
        --title="Power Menu" \
        --text="Select an action:" \
        --radiolist \
        --column="Select" \
        --column="Action" \
        --column="Description" \
        FALSE "Lock Screen" "Lock the current session" \
        FALSE "Log Out" "End current session" \
        FALSE "Sleep" "Suspend to RAM" \
        FALSE "Reboot" "Restart the system" \
        FALSE "Power Off" "Shutdown the system" \
        FALSE "Cancel" "Do nothing" \
        --width=500 --height=400 \
        2>/dev/null || true
    fi

  else
    # X11 version with full effects
    if command -v rofi >/dev/null; then
  local x11_theme="
      * {
      background-color: transparent;
      text-color: ${FG};
      font: \"JetBrains Mono 14\";
      }

      window {
          transparency: \"real\";
          background-color: rgba(30, 30, 46, 0.95);
          location: center;
          anchor: center;
          width: 450px;
          border-radius: 20px;
          border: 3px solid ${PRIMARY};
      }

      mainbox {
          padding: 25px;
          spacing: 20px;
      }

      inputbar {
          padding: 15px;
          border-radius: 10px;
          background-color: rgba(49, 50, 68, 0.5);
          children: [ prompt ];
      }

      prompt {
          text-color: ${PRIMARY};
          font: \"JetBrains Mono Bold 16\";
      }

      listview {
          lines: 6;
          spacing: 10px;
      }

    element {
      padding: 15px;
      border-radius: 12px;
      background-color: rgba(15, 17, 22, 0.95);
      border: 2px solid transparent;
    }

    element alternate {
      background-color: rgba(15, 17, 22, 0.95);
      text-color: ${FG};
    }

    element selected {
      background-color: ${PRIMARY};
      text-color: ${BG};
      border-color: ${PRIMARY};
    }
      "

      echo -e "$OPTIONS" | rofi \
        -dmenu \
        -i \
        -p "Power" \
        -theme-str "$x11_theme" \
        -no-fixed-num-lines
    fi
  fi
}

# Wayland-compatible confirmation dialog
confirm_action() {
  local action="$1"
  local message="$2"

  if [[ "${XDG_SESSION_TYPE:-}" == "wayland" ]] || [[ -n "${WAYLAND_DISPLAY:-}" ]]; then

    if command -v rofi >/dev/null; then
      local confirm_theme="
* {
    background: ${BG};
    foreground: ${ALERT};
    selected: ${ALERT};
    border-radius: 12px;
    font: \"JetBrains Mono Bold 12\";
}

window {
  location: center;
  anchor: center;
  width: 300px;
  border-radius: 12px;
  background-color: @background;
  border: 2px solid @selected;
}

mainbox {
    padding: 20px;
    spacing: 15px;
    background-color: transparent;
    children: [ \"inputbar\", \"listview\" ];
}

inputbar {
    padding: 10px;
    border-radius: 8px;
    background-color: rgba(248, 139, 168, 0.1);
    children: [ \"prompt\" ];
}

prompt {
    text-color: @selected;
    font: \"JetBrains Mono Bold 13\";
}

listview {
    lines: 2;
    spacing: 8px;
    background-color: transparent;
}

element {
  padding: 12px;
  border-radius: 8px;
  background-color: rgba(16, 18, 24, 0.9);
  text-color: @foreground;
  border: 1px solid transparent;
}

element selected {
  background-color: @selected;
  text-color: @background;
  border-color: @selected;
}
"

      echo -e "Yes\nNo" | rofi \
        -dmenu \
        -p "⚠️  $message" \
        -theme-str "$confirm_theme" \
        -lines 2

    else
      # Use zenity for Wayland confirmation
      zenity --question --text "$message" --width=300 2>/dev/null && echo "Yes" || echo "No"
    fi

  else
    zenity --question --text "$message" --width=300 2>/dev/null && echo "Yes" || echo "No"
  fi
}

# Get user choice
choice=$(prompt || true)

# Handle the selection with Wayland-optimized confirmations
case "$choice" in
  *"Lock Screen"*|*"󰌾"*)
    if command -v swaylock >/dev/null; then
      swaylock -f -c 1e1e2e --indicator --ring-color e100ff --key-hl-color a6e3a1
    elif command -v waylock >/dev/null; then
      waylock -fork -init-color 0x1e1e2e -input-color 0xe100ff
    elif command -v gtklock >/dev/null; then
      gtklock -d
    elif command -v i3lock >/dev/null; then
      i3lock -c 1e1e2e -e
    elif command -v loginctl >/dev/null; then
      loginctl lock-session
    else
      notify-send "🔒 Lock Error" "No lock screen utility found for Wayland" -u critical -t 3000
    fi
    ;;

  *"Log Out"*|*"󰍃"*)
    if [[ $(confirm_action "logout" "Log out now?") == "Yes" ]]; then
      if [[ "${XDG_CURRENT_DESKTOP:-}" == "GNOME" ]] && command -v gnome-session-quit >/dev/null; then
        gnome-session-quit --logout --no-prompt
      elif [[ "${XDG_SESSION_DESKTOP:-}" == "sway" ]] || command -v swaymsg >/dev/null; then
        swaymsg exit
      elif [[ "${XDG_SESSION_DESKTOP:-}" == "hyprland" ]] || command -v hyprctl >/dev/null; then
        hyprctl dispatch exit
      elif command -v loginctl >/dev/null; then
        loginctl terminate-user "$USER"
      fi
    fi
    ;;

  *"Sleep"*|*"󰤄"*)
    systemctl suspend
    ;;

  *"Reboot"*|*"󰑐"*)
    if [[ $(confirm_action "reboot" "Reboot the system?") == "Yes" ]]; then
      systemctl reboot
    fi
    ;;

  *"Power Off"*|*"󰐥"*)
    if [[ $(confirm_action "poweroff" "Shutdown the system?") == "Yes" ]]; then
      systemctl poweroff
    fi
    ;;

  *"Cancel"*|*""*|"")
    exit 0
    ;;

  *)
    exit 0
    ;;
esac
