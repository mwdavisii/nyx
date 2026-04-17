#!/bin/bash

# Cloudflare WARP status indicator for sketchybar

WARP_CLI="/usr/local/bin/warp-cli"

if [ ! -f "$WARP_CLI" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

STATUS=$($WARP_CLI status 2>/dev/null | grep -i "Status" | awk '{print $NF}')

if [ "$STATUS" = "Connected" ]; then
  sketchybar --set "$NAME" icon="󰒄" icon.color=0xff8aadf4 label="on"
else
  sketchybar --set "$NAME" icon="󰒇" icon.color=0xffed8796 label="off"
fi
