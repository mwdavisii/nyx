#!/bin/bash
if [ "$BUTTON" = "right" ]; then
  # Next track
  osascript -e 'tell application "Spotify" to next track' 2>/dev/null || \
  osascript -e 'tell application "Music" to next track' 2>/dev/null
elif [ "$BUTTON" = "left" ]; then
  # Play/pause
  osascript -e 'tell application "Spotify" to playpause' 2>/dev/null || \
  osascript -e 'tell application "Music" to playpause' 2>/dev/null
fi
