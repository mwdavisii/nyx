#!/bin/bash
CPU=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s/8}')
sketchybar --set "$NAME" label="${CPU}%"
