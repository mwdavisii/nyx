#!/bin/bash
if [ "$BUTTON" = "right" ]; then
  open -a "Calendar"
else
  # Toggle between time and full date+time
  CURRENT=$(sketchybar --query clock | grep -o '"label":"[^"]*"' | cut -d'"' -f4)
  if echo "$CURRENT" | grep -q "/"; then
    sketchybar --set clock script="$CONFIG_DIR/plugins/clock.sh"
  else
    sketchybar --set clock label="$(date '+%I:%M %p | %m/%d/%Y')"
  fi
fi
