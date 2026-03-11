#!/bin/bash

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | head -1 | tr -d '%')
CHARGING=$(pmset -g batt | grep -c 'AC Power')

if [ -z "$PERCENTAGE" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

case $PERCENTAGE in
  9[0-9]|100) ICON="" ;;
  [6-8][0-9])  ICON="" ;;
  [3-5][0-9])  ICON="" ;;
  [1-2][0-9])  ICON="" ;;
  *)           ICON="" ;;
esac

if [ "$CHARGING" -gt 0 ]; then
  ICON=""
fi

sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE}%"
