#!/bin/bash
USAGE=$(df -h / | awk 'NR==2 {print $5}')
sketchybar --set "$NAME" label="$USAGE"
