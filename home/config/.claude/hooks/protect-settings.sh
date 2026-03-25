#!/bin/bash
# Block writes to Nix-managed settings.json and redirect to source of truth
input=$(cat)
file=$(echo "$input" | jq -r '.file_path // .old_file_path // ""' 2>/dev/null)
if [[ "$file" == *"/.claude/settings.json" ]]; then
  echo "settings.json is managed by Nix." >&2
  echo "Propose a change to home/shared/modules/ai/claude/default.nix instead." >&2
  exit 2
fi
