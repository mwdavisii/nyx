#!/usr/bin/env bash
# =============================================================================
# Nyx bootstrap script for Arch Linux
# =============================================================================
# Run this on a fresh Arch install to set up standalone home-manager.
# The system itself is managed by Arch (pacman/AUR); Nix manages user tooling.
#
# IMPORTANT: Read the entire script before running. Some steps require manual
# action (e.g. WARP must be installed before Nix to avoid path conflicts).
# =============================================================================

set -euo pipefail

NYX_REPO="git@github.com:mwdavisii/nyx.git"
NYX_DIR="$HOME/code/nyx"
HOST="arch-work"

# ---------------------------------------------------------------------------
# Step 0 — Pre-flight: Cloudflare WARP
# ---------------------------------------------------------------------------
# WARP MUST be installed before Nix. It modifies /etc/resolv.conf and some
# network paths that can conflict if Nix is installed first.
#
# Install via the official Cloudflare repo or yay:
#
#   # Option A — official Cloudflare pacman repo
#   curl -fsSl https://pkg.cloudflareclient.com/pubkey.gpg | \
#     sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
#   echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] \
#     https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | \
#     sudo tee /etc/apt/sources.list.d/cloudflare-client.list
#   sudo pacman -Sy cloudflare-warp
#
#   # Option B — AUR
#   yay -S cloudflare-warp-bin
#
#   # After install, register and connect:
#   sudo systemctl enable --now warp-svc
#   warp-cli registration new
#   warp-cli connect
#
# ---------------------------------------------------------------------------

echo "==> Checking for Cloudflare WARP..."
if ! command -v warp-cli &>/dev/null; then
  echo ""
  echo "  *** Cloudflare WARP not found. ***"
  echo ""
  echo "  Install it before continuing:"
  echo "    yay -S cloudflare-warp-bin"
  echo "  Then run:"
  echo "    sudo systemctl enable --now warp-svc"
  echo "    warp-cli registration new"
  echo "    warp-cli connect"
  echo ""
  echo "  Re-run this script after WARP is installed and connected."
  exit 1
fi
echo "    WARP found: $(warp-cli --version 2>/dev/null || echo 'version unknown')"

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
# Step 3 — Clone the nyx repo (if not already present)
# ---------------------------------------------------------------------------

if [ ! -d "$NYX_DIR" ]; then
  echo ""
  echo "==> Cloning nyx repo to $NYX_DIR..."
  mkdir -p "$(dirname "$NYX_DIR")"
  git clone "$NYX_REPO" "$NYX_DIR"
else
  echo "==> Repo already present at $NYX_DIR"
fi

# ---------------------------------------------------------------------------
# Step 4 — Apply the home-manager configuration
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
echo "   home-manager switch --flake .#$HOST"
echo ""
echo " Or use the switch script from the repo root:"
echo "   ./switch.sh"
echo ""
echo " System-level packages (Hyprland, WARP, greetd, etc.) are"
echo " managed by pacman/AUR — see the comments in this script and"
echo " the plan docs for the full list."
echo "================================================================"

# ---------------------------------------------------------------------------
# System-level packages note
# ---------------------------------------------------------------------------
# The following must be installed via pacman/AUR (not Nix):
#
#   pacman -S hyprland hyprlock xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
#   pacman -S greetd
#   yay -S greetd-tuigreet
#   pacman -S polkit rtkit
#
# Configure greetd: /etc/greetd/config.toml
#   [terminal]
#   vt = 1
#   [default_session]
#   command = "tuigreet --cmd Hyprland"
#   user = "greeter"
#
# Hyprland plugins (installed via AUR to avoid ABI mismatch with pacman binary):
#   yay -S hyprland-plugins
