#!/bin/bash
MEMORY=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{printf "%.0f", 100-$5}' 2>/dev/null || echo "?")
sketchybar --set "$NAME" label="${MEMORY}%"
