#!/bin/bash

# AeroSpace workspace indicator for sketchybar
# Shows focused + occupied workspaces, hides empty ones

AEROSPACE="/opt/homebrew/bin/aerospace"

# Map app names to nerd font icons
app_icon() {
  case "$1" in
    "Alacritty"|"kitty"|"iTerm2"|"Terminal"|"WezTerm") echo "󰆍" ;;
    "Google Chrome"|"Firefox"|"Safari"|"Arc") echo "󰖟" ;;
    "Code"|"Visual Studio Code"|"Sublime Text") echo "󰨞" ;;
    "Discord") echo "󰙯" ;;
    "Microsoft Teams") echo "󰊻" ;;
    "Microsoft Outlook") echo "󰇮" ;;
    "Obsidian") echo "󱓧" ;;
    "Finder") echo "󰀶" ;;
    "Spotify") echo "󰓇" ;;
    "Messages"|"WhatsApp"|"Telegram") echo "󰍡" ;;
    "Preview"|"Photos") echo "󰋩" ;;
    "System Settings") echo "󰒓" ;;
    *) echo "󰣆" ;;
  esac
}

FOCUSED=$($AEROSPACE list-workspaces --focused 2>/dev/null)

for sid in $($AEROSPACE list-workspaces --all 2>/dev/null); do
  # Get app icons for this space
  ICONS=""
  while IFS= read -r app; do
    [ -z "$app" ] && continue
    ICONS+=" $(app_icon "$app")"
  done < <($AEROSPACE list-windows --workspace "$sid" --format '%{app-name}' 2>/dev/null)

  LABEL="${ICONS# }"
  HAS_WINDOWS=$( [ -n "$LABEL" ] && echo 1 || echo 0 )

  if [ "$sid" = "$FOCUSED" ]; then
    sketchybar --set space."$sid" \
      drawing=on \
      icon.highlight=on \
      label.highlight=on \
      label="$LABEL"
  elif [ "$HAS_WINDOWS" = "1" ]; then
    sketchybar --set space."$sid" \
      drawing=on \
      icon.highlight=off \
      label.highlight=off \
      label="$LABEL"
  else
    sketchybar --set space."$sid" drawing=off
  fi
done
