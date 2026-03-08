#!/bin/zsh

# Path to your kanshi config
CONFIG="$HOME/.config/kanshi/config"

# 1. Get all profile names from the config
# This looks for lines starting with 'profile' and grabs the name
PROFILES=$(grep -oP '^profile \K[^ {]+' "$CONFIG")

# 2. Get the current profile name from kanshictl
CURRENT=$(kanshictl status | jq -r '.current_profile')

# 3. Convert the newline-separated PROFILES string into a Zsh array
# (f) splits by newlines
profile_array=("${(f)PROFILES}")

# 4. Find the index and pick the next profile
# Note: Zsh arrays are 1-indexed!
count=${#profile_array}
next_profile="${profile_array[1]}" # Default fallback

for i in {1..$count}; do
    if [[ "${profile_array[$i]}" == "$CURRENT" ]]; then
        # Calculate next index with wrap-around
        next_index=$(( (i % count) + 1 ))
        next_profile="${profile_array[$next_index]}"
        break
    fi
done

# 5. Apply the profile
kanshictl switch "$next_profile"
notify-send "Kanshi" "Switched to profile: $next_profile"