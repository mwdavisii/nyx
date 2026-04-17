#!/bin/bash
# Wallpaper sketchybar item — shows current wallpaper name
current=$(osascript -e 'tell application "System Events" to get picture of desktop 1' 2>/dev/null)
if [ -n "$current" ]; then
  name=$(basename "$current")
  if [ ${#name} -gt 16 ]; then
    name="${name:0:14}.."
  fi
  sketchybar --set "$NAME" label="$name"
else
  sketchybar --set "$NAME" label="N/A"
fi
