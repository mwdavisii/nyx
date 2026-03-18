#!/bin/bash
if [ "$BUTTON" = "right" ]; then
  open "x-apple.systempreferences:com.apple.preference.sound"
elif [ "$SCROLL_DELTA" != "" ]; then
  # Scroll to adjust volume
  CURRENT=$(osascript -e 'output volume of (get volume settings)')
  NEW=$((CURRENT + SCROLL_DELTA * 5))
  [ "$NEW" -gt 100 ] && NEW=100
  [ "$NEW" -lt 0 ] && NEW=0
  osascript -e "set volume output volume $NEW"
  sketchybar --trigger volume_change
else
  # Click to toggle mute
  MUTED=$(osascript -e 'output muted of (get volume settings)')
  if [ "$MUTED" = "true" ]; then
    osascript -e 'set volume output muted false'
  else
    osascript -e 'set volume output muted true'
  fi
  sketchybar --trigger volume_change
fi
