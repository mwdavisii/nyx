#!/bin/bash

# Yabai workspace indicator for sketchybar
# Highlights focused space, shows app icons per space

YABAI="/opt/homebrew/bin/yabai"

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

FOCUSED=$($YABAI -m query --spaces --space | jq -r '.index' 2>/dev/null)

for space_json in $($YABAI -m query --spaces | jq -c '.[]' 2>/dev/null); do
  SID=$(echo "$space_json" | jq -r '.index')

  # Get app icons for this space
  ICONS=""
  while IFS= read -r app; do
    [ -z "$app" ] && continue
    ICONS+=" $(app_icon "$app")"
  done < <($YABAI -m query --windows --space "$SID" | jq -r '.[].app' 2>/dev/null)

  LABEL="${ICONS# }"

  if [ "$SID" = "$FOCUSED" ]; then
    sketchybar --set space."$SID" icon.highlight=on label="$LABEL"
  else
    sketchybar --set space."$SID" icon.highlight=off label="$LABEL"
  fi
done
