#!/bin/bash
if [ "$BUTTON" = "right" ]; then
  open "x-apple.systempreferences:com.apple.preference.network"
else
  # Copy IP to clipboard
  IP=$(ipconfig getifaddr en8 2>/dev/null || ipconfig getifaddr en0 2>/dev/null)
  echo -n "$IP" | pbcopy
  sketchybar --set "$NAME" label="copied!"
  sleep 1
  # Refresh back to normal
  "$CONFIG_DIR/plugins/network.sh"
fi
