#!/bin/bash

# Toggle Cloudflare WARP on/off

WARP_CLI="/usr/local/bin/warp-cli"

if [ ! -f "$WARP_CLI" ]; then
  exit 0
fi

STATUS=$($WARP_CLI status 2>/dev/null | grep -i "Status" | awk '{print $NF}')

if [ "$STATUS" = "Connected" ]; then
  $WARP_CLI disconnect
else
  $WARP_CLI connect
fi

# Small delay then refresh the indicator
sleep 1
$CONFIG_DIR/plugins/warp.sh
