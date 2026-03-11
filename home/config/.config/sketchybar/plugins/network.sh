#!/bin/bash

# Determine active network: prefer showing WiFi SSID, fall back to ethernet
# macOS redacts SSID without Location Services — show IP in that case

# Check for wired connection first (en8 = Thunderbolt/USB-C dock ethernet)
ETH_IP=$(ipconfig getifaddr en8 2>/dev/null)
WIFI_IP=$(ipconfig getifaddr en0 2>/dev/null)

# Try to get WiFi SSID (may be redacted or unavailable when docked)
SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I 2>/dev/null | awk -F': ' '/^ *SSID/{print $2}')

if [ -n "$ETH_IP" ]; then
  # Wired connection active
  sketchybar --set "$NAME" icon="󰈀" label="$ETH_IP"
elif [ -n "$SSID" ] && [ "$SSID" != "<SSID Redacted>" ]; then
  sketchybar --set "$NAME" icon="󰤨" label="$SSID"
elif [ -n "$WIFI_IP" ]; then
  sketchybar --set "$NAME" icon="󰤨" label="$WIFI_IP"
else
  sketchybar --set "$NAME" icon="󰤭" label="off"
fi
