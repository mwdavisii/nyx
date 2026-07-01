#!/usr/bin/env bash
# =============================================================================
# Nyx package sync for DGX (Ubuntu-derived) hosts.
# =============================================================================
# Installs the minimum set of apt packages nyx assumes are present,
# validates GB10 hardware assumptions, and prepares the box for the
# gb10_cluster inference platform. Idempotent.
#
# Modes:
#   ./01-install-packages.sh          Interactive — apt update + core + optional prompts
#   ./01-install-packages.sh --sync   Non-interactive — core packages only, no update
#                                     (called from switch.sh / update.sh)
#
# NEVER touches: nvidia-*, cuda-*, libnvidia-*, nvidia-container-*,
# or kernel packages. Those are vendor-managed on DGX OS. Docker itself
# is installed via apt if missing (DGX OS ships it; this is a safety net).
# =============================================================================

set -euo pipefail

# Core apt packages nyx needs before / alongside home-manager.
# - git curl ca-certificates xz-utils: bootstrap prereqs
# - zsh build-essential: home-manager login shell + treesitter/native builds
# - libfido2-1 unzip: yubikey, occasional dev tooling
# - docker.io docker-buildx docker-compose-v2: gb10_cluster platform prereqs
#   (idempotent no-op if DGX OS already provides them)
# - pipx: user-scope Python tool installer (used below for `hf` CLI)
CORE_PKGS=(
  git curl ca-certificates xz-utils
  zsh build-essential
  libfido2-1 unzip
  docker.io docker-buildx docker-compose-v2
  pipx
)

# GB10 hardware validation. Warnings do not abort; the driver-590 check
# is a hard error because it corrupts CUDAGraph state on this unified-
# memory architecture (peer's gb10_cluster finding).
validate_gb10_hardware() {
  local arch driver_version runtimes

  arch="$(uname -m)"
  if [[ "$arch" != "aarch64" ]]; then
    echo "WARN: uname -m is '$arch'; expected 'aarch64' for GB10. Continuing anyway."
  fi

  if command -v nvidia-smi &>/dev/null; then
    driver_version="$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -1)"
    echo "==> NVIDIA driver: $driver_version"
    if [[ "$driver_version" == 590.* ]]; then
      echo "ERROR: NVIDIA driver 590.x has a CUDAGraph deadlock bug on the GB10 UMA architecture."
      echo "       Downgrade to 580.x before continuing. See gb10_cluster docs."
      exit 1
    fi
  else
    echo "WARN: nvidia-smi not found. Not on a DGX box, or the driver is broken."
  fi

  if command -v docker &>/dev/null; then
    runtimes="$(docker info 2>/dev/null | grep -E '^ Runtimes:' || true)"
    if ! echo "$runtimes" | grep -q 'nvidia'; then
      echo "WARN: NVIDIA container runtime not registered with docker. GPU containers will fail."
      echo "      DGX OS owns nvidia-container-toolkit; fix on the vendor side, not here."
    fi
  fi
}

sync_only=false
if [[ "${1:-}" == "--sync" ]]; then
  sync_only=true
fi

validate_gb10_hardware

if ! $sync_only; then
  echo "==> apt-get update"
  sudo apt-get update
fi

echo "==> Installing/refreshing core packages: ${CORE_PKGS[*]}"
sudo apt-get install -y --no-install-recommends "${CORE_PKGS[@]}"

# ── Model directory ──────────────────────────────────────────────────
# gb10_cluster compose files mount ${MODEL_DIR:-/models} into the vLLM
# containers read-only. The dir must exist and be user-writable so
# `hf download` (below) can populate it without sudo.
if [[ ! -d /models ]]; then
  echo "==> Creating /models (owner: $USER)"
  sudo mkdir -p /models
  sudo chown "$USER:$USER" /models
fi

# ── HuggingFace CLI (`hf`) ───────────────────────────────────────────
# Installed via pipx so it lives under ~/.local/bin. home-manager adds
# ~/.local/bin to sessionPath (see home/shared/profiles/headless.nix),
# so no shell rc changes are required.
if ! command -v hf &>/dev/null && ! [[ -x "$HOME/.local/bin/hf" ]]; then
  echo "==> Installing HuggingFace CLI via pipx"
  pipx install "huggingface-hub[hf-xet,cli]"
fi

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
