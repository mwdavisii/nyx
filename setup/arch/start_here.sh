#!/usr/bin/env bash
# =============================================================================
# Nyx bootstrap script for Arch Linux — post-boot phase
# =============================================================================
# Run this after first login on a system installed by install.sh.
# System packages and services are already in place — this script handles:
#   1. yay (AUR helper)
#   2. Cloudflare WARP (optional, via AUR)
#   3. Nix (Determinate Systems installer)
#   4. Clone the nyx repo
#   5. home-manager switch
# =============================================================================

set -euo pipefail

NYX_REPO_SSH="git@github.com:mwdavisii/nyx.git"
NYX_REPO_HTTPS="https://github.com/mwdavisii/nyx.git"
NYX_DIR="$HOME/code/nyx"
HOST="arch-work"

# ---------------------------------------------------------------------------
# Step 1 — AUR helper (yay)
# ---------------------------------------------------------------------------
# Can't run makepkg as root in chroot, so yay is installed post-boot.

if ! command -v yay &>/dev/null; then
  echo ""
  echo "==> Installing yay (AUR helper)..."
  sudo pacman -S --needed --noconfirm base-devel git
  local_tmp=$(mktemp -d)
  git clone https://aur.archlinux.org/yay-bin.git "$local_tmp/yay-bin"
  (cd "$local_tmp/yay-bin" && makepkg -si --noconfirm)
  rm -rf "$local_tmp"
else
  echo "==> yay already installed: $(yay --version | head -1)"
fi

# ---------------------------------------------------------------------------
# Step 2 — Cloudflare WARP (optional)
# ---------------------------------------------------------------------------
# WARP should be installed before Nix when possible — it modifies
# /etc/resolv.conf and network paths that can conflict if Nix goes first.
# However, it is NOT a hard requirement. The script continues either way.

echo ""
echo "==> Checking for Cloudflare WARP..."
if ! command -v warp-cli &>/dev/null; then
  echo ""
  echo "  Cloudflare WARP is not installed."
  echo "  It's recommended to install it before Nix to avoid path conflicts."
  echo ""
  read -rp "  Install WARP now via yay? [Y/n] " warp_choice
  if [[ "${warp_choice,,}" != "n" ]]; then
    yay -S --noconfirm cloudflare-warp-bin
    echo ""
    echo "  WARP installed. After this script finishes, register and connect:"
    echo "    sudo systemctl enable --now warp-svc"
    echo "    warp-cli registration new"
    echo "    warp-cli connect"
  else
    echo "  Skipping WARP. You can install it later: yay -S cloudflare-warp-bin"
  fi
else
  echo "    WARP found: $(warp-cli --version 2>/dev/null || echo 'version unknown')"
fi

# ---------------------------------------------------------------------------
# Step 3 — Install Nix (Determinate Systems)
# ---------------------------------------------------------------------------

if ! command -v nix &>/dev/null; then
  echo ""
  echo "==> Installing Nix via Determinate Systems installer..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
    sh -s -- install
else
  echo "==> Nix already installed: $(nix --version)"
fi

# ---------------------------------------------------------------------------
# Step 4 — Source the Nix profile
# ---------------------------------------------------------------------------

NIX_PROFILE="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
if [ -f "$NIX_PROFILE" ]; then
  # shellcheck source=/dev/null
  . "$NIX_PROFILE"
  echo "==> Nix profile sourced."
else
  echo "WARNING: Nix profile not found at $NIX_PROFILE — you may need to open a new shell."
fi

# ---------------------------------------------------------------------------
# Step 5 — Clone the nyx repo (SSH with HTTPS fallback)
# ---------------------------------------------------------------------------

if [ ! -d "$NYX_DIR" ]; then
  echo ""
  echo "==> Cloning nyx repo to $NYX_DIR..."
  mkdir -p "$(dirname "$NYX_DIR")"
  if git clone "$NYX_REPO_SSH" "$NYX_DIR" 2>/dev/null; then
    echo "    Cloned via SSH."
  else
    echo "    SSH clone failed (keys not set up?). Falling back to HTTPS..."
    git clone "$NYX_REPO_HTTPS" "$NYX_DIR"
    echo "    Cloned via HTTPS. Switch remote to SSH later:"
    echo "      cd $NYX_DIR && git remote set-url origin $NYX_REPO_SSH"
  fi
else
  echo "==> Repo already present at $NYX_DIR"
fi

# ---------------------------------------------------------------------------
# Step 6 — Apply the home-manager configuration
# ---------------------------------------------------------------------------

echo ""
echo "==> Running home-manager switch for host: $HOST"
cd "$NYX_DIR"

nix run home-manager -- switch --show-trace --flake ".#$HOST"

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

echo ""
echo "================================================================"
echo " Bootstrap complete!"
echo "================================================================"
echo ""
echo " Restart your shell (or run: exec \$SHELL) to pick up the new"
echo " PATH and environment variables."
echo ""
echo " PipeWire audio: if not working after first login, run:"
echo "   systemctl --user start pipewire pipewire-pulse wireplumber"
echo ""
echo " If you skipped WARP, install it now:"
echo "   yay -S cloudflare-warp-bin"
echo "   sudo systemctl enable --now warp-svc"
echo "   warp-cli registration new"
echo "   warp-cli connect"
echo ""
echo " For ongoing use:"
echo "   cd $NYX_DIR"
echo "   home-manager switch --flake .#$HOST"
echo ""
echo " Or use the switch script from the repo root:"
echo "   ./switch.sh"
echo ""
echo " SDDM + Hyprland should already be active."
echo " If not, reboot and select Hyprland from the session menu."
echo "================================================================"
