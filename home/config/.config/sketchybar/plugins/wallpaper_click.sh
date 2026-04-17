#!/bin/bash
# Wallpaper click handler
# Left click: random wallpaper
# Right click: default wallpaper
# Scroll: cycle through wallpapers

# SketchyBar runs with minimal PATH — add Nix profile
export PATH="/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"

WALLPAPER_DIR="$HOME/.config/wallpapers"

if [ "$BUTTON" = "right" ]; then
  wallpaper_default
  sketchybar --set "$NAME" label="wall0.png"
elif [ -n "$SCROLL_DELTA" ]; then
  # Cycle through wallpapers
  files=()
  for f in "$WALLPAPER_DIR"/*; do
    [ -f "$f" ] || [ -L "$f" ] && files+=("$f")
  done
  num=${#files[@]}
  [ "$num" -eq 0 ] && exit 0

  current=$(osascript -e 'tell application "System Events" to get picture of desktop 1' 2>/dev/null)
  current_idx=0
  for i in "${!files[@]}"; do
    if [ "$(basename "${files[$i]}")" = "$(basename "$current")" ]; then
      current_idx=$i
      break
    fi
  done

  if [ "$SCROLL_DELTA" -gt 0 ]; then
    next_idx=$(( (current_idx + 1) % num ))
  else
    next_idx=$(( (current_idx - 1 + num) % num ))
  fi

  wallpaper_apply "${files[$next_idx]}"
  sketchybar --set "$NAME" label="$(basename "${files[$next_idx]}" | cut -c1-16)"
else
  # Left click: random wallpaper
  wallpaper_random
  current=$(osascript -e 'tell application "System Events" to get picture of desktop 1' 2>/dev/null)
  sketchybar --set "$NAME" label="$(basename "$current" | cut -c1-16)"
fi
