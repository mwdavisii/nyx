#!/usr/bin/env bash

set -euo pipefail

module="home/shared/modules/desktop/hypr/default.nix"
entrypoint="home/config/.config/hypr/hyprland.lua"

for path in \
  'hypr/hyprland.lua' \
  'hypr/monitors.lua' \
  'hypr/startup.lua' \
  'hypr/options.lua' \
  'hypr/binds.lua' \
  'hypr/rules.lua' \
  'hypr/hyprlock.conf'
do
  grep -F "\"${path}\".source" "$module" >/dev/null || {
    echo "Missing XDG config mapping for ${path}" >&2
    exit 1
  }
done

for legacy in \
  'hypr/hyprland.conf' \
  'hypr/monitors.conf' \
  'hypr/startup.conf'
do
  if grep -F "\"${legacy}\".source" "$module" >/dev/null; then
    echo "Legacy runtime path still installed: ${legacy}" >&2
    exit 1
  fi
done

if grep -F 'configType = "hyprlang"' "$module" >/dev/null; then
  echo 'Hyprland Home Manager module still forces hyprlang.' >&2
  exit 1
fi

for mod in monitors startup options binds rules; do
  grep -F "require(\"${mod}\")" "$entrypoint" >/dev/null || {
    echo "hyprland.lua is missing require(\"${mod}\")" >&2
    exit 1
  }
done
