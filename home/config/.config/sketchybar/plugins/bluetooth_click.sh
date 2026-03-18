#!/bin/bash
if [ "$BUTTON" = "right" ]; then
  open "x-apple.systempreferences:com.apple.BluetoothSettings"
else
  # Toggle bluetooth power
  POWER=$(defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState 2>/dev/null)
  if [ "$POWER" = "1" ]; then
    blueutil --power 0 2>/dev/null || open "x-apple.systempreferences:com.apple.BluetoothSettings"
  else
    blueutil --power 1 2>/dev/null || open "x-apple.systempreferences:com.apple.BluetoothSettings"
  fi
  sleep 1
  "$CONFIG_DIR/plugins/bluetooth.sh"
fi
