#!/bin/bash

# Uses macOS MediaRemote framework via osascript
INFO=$(osascript -e '
tell application "System Events"
  set _apps to (name of every process whose background only is false)
end tell
if _apps contains "Spotify" then
  tell application "Spotify"
    if player state is playing then
      return (artist of current track) & " - " & (name of current track)
    else
      return ""
    end if
  end tell
else if _apps contains "Music" then
  tell application "Music"
    if player state is playing then
      return (artist of current track) & " - " & (name of current track)
    else
      return ""
    end if
  end tell
else
  return ""
end if
' 2>/dev/null)

if [ -z "$INFO" ]; then
  sketchybar --set "$NAME" drawing=off
else
  sketchybar --set "$NAME" drawing=on label="$INFO"
fi
