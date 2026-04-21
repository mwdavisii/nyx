#!/usr/bin/env bash
# =============================================================================
# Nyx bootstrap script for Arch Linux — post-boot phase
# =============================================================================
# Run this after 02-install-packages.sh has installed system packages.
# This script handles:
#   1. Nix (Determinate Systems installer)
#   2. Clone the nyx repo
#   3. home-manager switch
# =============================================================================

set -euo pipefail

NYX_REPO_SSH="git@github.com:mwdavisii/nyx.git"
NYX_REPO_HTTPS="https://github.com/mwdavisii/nyx.git"
NYX_DIR="$HOME/code/nyx"
HOST="L242731"
NYX_BRANCH="main"


### Get Inputs
# Host Name
echo ""
read -rp "==> Hostname [${HOST}]: " host_input
HOST="${host_input:-$HOST}"
echo "    Using hostname: $HOST"

#Branch Name
echo ""
read -rp "==> Nyx branch to use [${NYX_BRANCH}]: " branch_input
NYX_BRANCH="${branch_input:-$NYX_BRANCH}"
echo "    Using branch: $NYX_BRANCH"


# ---------------------------------------------------------------------------
# Step 1 — Install Nix (Determinate Systems)
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
# Step 2 — Source the Nix profile
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
# Step 3 — Clone the nyx repo (SSH with HTTPS fallback)
# ---------------------------------------------------------------------------

if [ ! -d "$NYX_DIR" ]; then
  echo ""
  echo "==> Cloning nyx repo ($NYX_BRANCH) to $NYX_DIR..."
  mkdir -p "$(dirname "$NYX_DIR")"
  if git clone -b "$NYX_BRANCH" "$NYX_REPO_SSH" "$NYX_DIR" 2>/dev/null; then
    echo "    Cloned via SSH."
  else
    echo "    SSH clone failed (keys not set up?). Falling back to HTTPS..."
    git clone -b "$NYX_BRANCH" "$NYX_REPO_HTTPS" "$NYX_DIR"
    echo "    Cloned via HTTPS. Switch remote to SSH later:"
    echo "      cd $NYX_DIR && git remote set-url origin $NYX_REPO_SSH"
  fi
else
  echo "==> Repo already present at $NYX_DIR"
  git -C "$NYX_DIR" checkout "$NYX_BRANCH"
fi

# ---------------------------------------------------------------------------
# Step 3b — Initialize git-lfs and fetch LFS objects
# ---------------------------------------------------------------------------
# Wallpapers under home/config/.config/wallpapers are tracked via git-lfs.
# Home-manager's git module registers the lfs filter, but that only runs
# AFTER the clone above — so without this step the initial checkout lands as
# pointer stubs and home-manager symlinks the stubs into ~/.config/wallpapers.

if command -v git-lfs &>/dev/null; then
  echo "==> Initializing git-lfs and fetching LFS objects..."
  git -C "$NYX_DIR" lfs install --local
  git -C "$NYX_DIR" lfs pull
else
  echo "WARNING: git-lfs not found — LFS files (wallpapers) will remain as pointer stubs."
  echo "         Install git-lfs and re-run: git -C $NYX_DIR lfs install --local && git -C $NYX_DIR lfs pull"
fi

# ---------------------------------------------------------------------------
# Step 4 — Remove bash skeleton files that collide with home-manager
# ---------------------------------------------------------------------------
# useradd creates .bash_profile, .bashrc, .bash_logout stubs. home-manager
# refuses to overwrite files it didn't create, so remove them first.

echo ""
echo "==> Removing bash skeleton files to prevent home-manager collisions..."
rm -f "$HOME"/.bash_profile "$HOME"/.bashrc "$HOME"/.bash_logout "$HOME"/.bash_history

# ---------------------------------------------------------------------------
# Step 5 — Apply the home-manager configuration
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
echo " For ongoing use:"
echo "   cd $NYX_DIR"
echo "   ./switch.sh"
echo ""
echo " Reboot to start Hyprland:"
echo "   sudo reboot"
echo "================================================================"
