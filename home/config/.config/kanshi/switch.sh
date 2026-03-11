#!/bin/zsh

CONFIG="$HOME/.config/kanshi/config"
STATE_FILE="/tmp/kanshi_profile_index"

# 1. Get all profile names
PROFILES=$(grep -oP '^profile \K[^ {]+' "$CONFIG")
profile_array=("${(f)PROFILES}")
count=${#profile_array}

# 2. Read the last index (default to 0 if file doesn't exist)
if [[ -f "$STATE_FILE" ]]; then
    last_index=$(cat "$STATE_FILE")
else
    last_index=0
fi

# 3. Increment and wrap around
# (Zsh arrays are 1-indexed, so we go from 1 to count)
next_index=$(( (last_index % count) + 1 ))

# 4. Get the profile name and attempt switch
next_profile="${profile_array[$next_index]}"
kanshictl switch "$next_profile"

# 5. Save the new index for next time
echo "$next_index" > "$STATE_FILE"

# 6. Notify user (optional but helpful for debugging)
notify-send "Kanshi Cycle" "Attempting: $next_profile ($next_index/$count)"