#!/usr/bin/env bash
# Move a workspace to a monitor (Hyprland Lua dispatch). Usage: ws-to-monitor.sh <workspace> <monitor>
# Kept as a script because kanshi's exec goes through sh, which can't take the Lua call inline.
hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"$1\", monitor = \"$2\" })"
