#!/bin/bash

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | head -1 | tr -d '%')
CHARGING=$(pmset -g batt | grep -c 'AC Power')

if [ -z "$PERCENTAGE" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [ "$CHARGING" -gt 0 ]; then
  ICON="󰂄"
elif [ "$PERCENTAGE" -ge 90 ]; then
  ICON="󰁹"
elif [ "$PERCENTAGE" -ge 60 ]; then
  ICON="󰂀"
elif [ "$PERCENTAGE" -ge 30 ]; then
  ICON="󰁾"
elif [ "$PERCENTAGE" -ge 10 ]; then
  ICON="󰁻"
else
  ICON="󰂃"
fi

sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE}%"
