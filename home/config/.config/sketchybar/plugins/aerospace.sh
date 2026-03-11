#!/bin/bash

# Highlight the focused workspace, dim the rest
FOCUSED=$(/opt/homebrew/bin/aerospace list-workspaces --focused 2>/dev/null)

for sid in $(/opt/homebrew/bin/aerospace list-workspaces --all 2>/dev/null); do
  if [ "$sid" = "$FOCUSED" ]; then
    sketchybar --set space.$sid icon.highlight=on
  else
    sketchybar --set space.$sid icon.highlight=off
  fi
done
