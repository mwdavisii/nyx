#!/bin/bash
SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print $2}')

if [ -z "$SSID" ]; then
  sketchybar --set "$NAME" icon="󰤭" label="off"
else
  sketchybar --set "$NAME" icon="󰤨" label="$SSID"
fi
