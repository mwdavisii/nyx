#!/bin/bash

# Get bluetooth power state and connected device
POWER=$(defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState 2>/dev/null)
DEVICE=$(system_profiler SPBluetoothDataType 2>/dev/null | grep -A6 "Connected: Yes" | grep "Name:" | head -1 | awk -F': ' '{print $2}')

if [ "$POWER" = "0" ] || [ -z "$POWER" ]; then
  sketchybar --set "$NAME" icon="󰂲" label="off"
elif [ -n "$DEVICE" ]; then
  sketchybar --set "$NAME" icon="󰂱" label="$DEVICE"
else
  sketchybar --set "$NAME" icon="󰂯" label="on"
fi
