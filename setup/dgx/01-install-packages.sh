#!/usr/bin/env bash
# =============================================================================
# Nyx package sync for DGX (Ubuntu-derived) hosts.
# =============================================================================
# Installs the minimum set of apt packages nyx assumes are present. Idempotent.
#
# Modes:
#   ./01-install-packages.sh          Interactive — apt update + core + optional prompts
#   ./01-install-packages.sh --sync   Non-interactive — core packages only, no update
#                                     (called from switch.sh / update.sh)
#
# NEVER touches: nvidia-*, cuda-*, libnvidia-*, docker*, nvidia-container-*,
# or kernel packages. Those are vendor-managed on DGX OS.
# =============================================================================

set -euo pipefail

CORE_PKGS=(
  git curl ca-certificates xz-utils
  zsh build-essential
  libfido2-1 unzip
)

sync_only=false
if [[ "${1:-}" == "--sync" ]]; then
  sync_only=true
fi

if ! $sync_only; then
  echo "==> apt-get update"
  sudo apt-get update
fi

echo "==> Installing/refreshing core packages: ${CORE_PKGS[*]}"
sudo apt-get install -y --no-install-recommends "${CORE_PKGS[@]}"

if ! $sync_only; then
  echo ""
  read -r -p "==> Install optional Yubikey / PC-SC tooling (yubikey-manager, pcscd)? [y/N] " ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    sudo apt-get install -y --no-install-recommends yubikey-manager pcscd
    sudo systemctl enable --now pcscd
    echo "    Yubikey tooling installed and pcscd enabled."
  fi
fi

echo ""
echo "==> Done."
