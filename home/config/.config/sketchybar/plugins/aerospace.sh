#!/bin/bash

# Highlight the focused workspace, dim the rest
FOCUSED=$(aerospace list-workspaces --focused)

for sid in $(aerospace list-workspaces --all); do
  if [ "$sid" = "$FOCUSED" ]; then
    sketchybar --set space.$sid icon.highlight=on
  else
    sketchybar --set space.$sid icon.highlight=off
  fi
done
