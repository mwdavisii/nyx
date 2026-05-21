#!/usr/bin/env bash

set -euo pipefail

script="setup/arch/02-install-packages.sh"

aur_block="$(
  sed -n '/^PKG_CONFIG_PATH=.*yay -S --needed --noconfirm \\/,/^$/p' "$script"
)"

if ! grep -q '^[[:space:]]*claude-desktop-bin[[:space:]]*\\$' <<<"$aur_block"; then
  echo "Expected default Arch AUR packages to include claude-desktop-bin." >&2
  exit 1
fi
