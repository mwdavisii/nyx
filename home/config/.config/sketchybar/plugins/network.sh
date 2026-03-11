#!/bin/bash

SSID=$(ipconfig getsummary en0 2>/dev/null | awk -F: '/SSID :/{gsub(/^ +/, "", $2); print $2}')
IP=$(ipconfig getifaddr en0 2>/dev/null)

if [ -z "$IP" ]; then
  sketchybar --set "$NAME" icon="󰤭" label="off"
elif [ -n "$SSID" ]; then
  sketchybar --set "$NAME" icon="󰤨" label="$SSID"
else
  sketchybar --set "$NAME" icon="󰈀" label="$IP"
fi
