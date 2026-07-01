#!/usr/bin/env bash
# =============================================================================
# Nyx bootstrap for DGX (Ubuntu-derived) hosts.
# =============================================================================
# Run this after 01-install-packages.sh has installed the core apt packages.
#
# Steps:
#   1. Sanity-check we're on a DGX (has nvidia-smi). Bypass with --force.
#   2. Install Nix via the Determinate Systems installer.
#   3. Source the Nix profile.
#   4. Clone the nyx repo (SSH first, HTTPS fallback).
#   5. Move collision-prone dotfiles aside so home-manager can take over.
#   6. Run the first home-manager switch for this host.
# =============================================================================

set -euo pipefail

NYX_REPO_SSH="git@github.com:mwdavisii/nyx.git"
NYX_REPO_HTTPS="https://github.com/mwdavisii/nyx.git"
NYX_DIR="$HOME/code/nyx"
NYX_BRANCH="main"

force=false
if [[ "${1:-}" == "--force" ]]; then
  force=true
fi

# ---------------------------------------------------------------------------
# Step 1 — Sanity check: are we on DGX?
# ---------------------------------------------------------------------------

if ! $force; then
  if ! command -v nvidia-smi &>/dev/null; then
    echo "ERROR: nvidia-smi not found. This script targets NVIDIA DGX hosts."
    echo "       Re-run with --force to override the check."
    exit 1
  fi
fi

# ---------------------------------------------------------------------------
# Step 2 — Get hostname (must be castor or pollux; prompt if not)
# ---------------------------------------------------------------------------

DEFAULT_HOST="$(hostname -s 2>/dev/null || hostname)"
case "$DEFAULT_HOST" in
  castor|pollux) ;;
  *)
    echo "==> Hostname '$DEFAULT_HOST' is not castor or pollux."
    read -rp "    Enter DGX host to configure [castor]: " host_input
    DEFAULT_HOST="${host_input:-castor}"
    ;;
esac
HOST="$DEFAULT_HOST"
echo "==> Using host: $HOST"

read -rp "==> Nyx branch to use [${NYX_BRANCH}]: " branch_input
NYX_BRANCH="${branch_input:-$NYX_BRANCH}"
echo "    Using branch: $NYX_BRANCH"

# ---------------------------------------------------------------------------
# Step 3 — Install Nix (Determinate Systems)
# ---------------------------------------------------------------------------

if ! command -v nix &>/dev/null; then
  echo ""
  echo "==> Installing Nix via Determinate Systems installer..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
    sh -s -- install linux --no-confirm --init systemd
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
# Step 4b — Verify flakes are enabled in /etc/nix/nix.conf (idempotent)
# ---------------------------------------------------------------------------
# The Determinate Systems installer writes this by default, but future
# installer versions could drop it. We rely on flakes in Step 7, so guard
# against a confusing later failure by warning up front.

if ! sudo grep -qE '^experimental-features.*(nix-command|flakes)' /etc/nix/nix.conf 2>/dev/null; then
  echo "WARNING: 'experimental-features = nix-command flakes' not found in /etc/nix/nix.conf."
  echo "         The Nix installer should have set this — home-manager switch may fail."
  echo "         To fix: sudo tee -a /etc/nix/nix.conf <<< 'experimental-features = nix-command flakes'"
fi

# ---------------------------------------------------------------------------
# Step 5 — Clone the nyx repo (SSH with HTTPS fallback)
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
# Step 6 — Move collision-prone dotfiles aside
# ---------------------------------------------------------------------------
# Ubuntu useradd creates skeleton dotfiles (.bashrc, .profile, .bash_logout).
# home-manager refuses to overwrite files it didn't create. Move them into
# a timestamped backup dir so this script is safe to re-run.

BACKUP_DIR="$HOME/.dotfiles.pre-nyx.$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
moved_any=false
for f in .bashrc .bash_profile .bash_logout .bash_history .profile .zshrc; do
  if [ -e "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
    mv "$HOME/$f" "$BACKUP_DIR/"
    moved_any=true
  fi
done
if $moved_any; then
  echo "==> Moved collision-prone dotfiles to $BACKUP_DIR"
else
  echo "==> No collision-prone dotfiles present; skipping backup."
  rmdir "$BACKUP_DIR" 2>/dev/null || true
fi

# ---------------------------------------------------------------------------
# Step 7 — home-manager switch
# ---------------------------------------------------------------------------

echo ""
echo "==> Running home-manager switch for host: $HOST"
cd "$NYX_DIR"
nix run home-manager -- switch --show-trace -b backup --flake ".#$HOST"

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

echo ""
echo "================================================================"
echo " Bootstrap complete!"
echo "================================================================"
echo ""
echo " Log out and back in (or run: exec zsh -l) so zsh becomes your"
echo " login shell and PATH picks up the new environment."
echo ""
echo " For ongoing use:"
echo "   cd $NYX_DIR"
echo "   ./switch.sh"
echo "================================================================"
