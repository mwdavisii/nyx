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
# Install via AUR:
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
# Step 1 — AUR helper (yay)
# ---------------------------------------------------------------------------
# Required before AUR packages. base-devel must be installed first.

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
# Step 2 — System packages via pacman
# ---------------------------------------------------------------------------
# These must live at the OS level — system services, compositors, and audio
# infrastructure cannot be managed purely by Nix on a non-NixOS host.

echo ""
echo "==> Installing system packages via pacman..."

PACMAN_PKGS=(
  # Build tools
  base-devel
  git

  # Wayland compositor stack
  hyprland
  hyprlock
  xdg-desktop-portal-hyprland
  xdg-desktop-portal-gtk
  xorg-xwayland
  wayland-utils

  # Display manager — SDDM (≥0.20.0, "works flawlessly" per Hyprland wiki)
  # Picks up Hyprland's desktop entry automatically; no config file needed.
  sddm

  # Security infrastructure
  polkit
  rtkit

  # Audio — PipeWire stack
  pipewire
  wireplumber
  pipewire-alsa
  pipewire-pulse
  pipewire-jack
  pavucontrol
  pamixer
  playerctl

  # Network — WiFi and management
  networkmanager
  wpa_supplicant
  iw
  wireless_tools
  network-manager-applet
  nm-connection-editor

  # Bluetooth
  bluez
  bluez-utils
  blueman

  # Wayland / display utilities
  # (equivalent to NixOS packages module — not covered by home-manager on Arch)
  wlr-randr
  grim
  slurp
  wl-clipboard
  kanshi

  # File management
  thunar
  gvfs
  tumbler

  # Input handling
  libinput

  # System utilities
  acpi
  linux-firmware

  # Fonts — system baseline (nerd fonts come via Nix home-manager)
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  ttf-firacode-nerd
)

sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

# ---------------------------------------------------------------------------
# Step 3 — AUR packages
# ---------------------------------------------------------------------------
# cloudflare-warp-bin is already installed (Step 0 pre-flight).
# Add any additional AUR packages here as needed.

# (no additional AUR packages required at this time)

# ---------------------------------------------------------------------------
# Step 4 — Enable system services
# ---------------------------------------------------------------------------

echo ""
echo "==> Enabling system services..."

# NetworkManager — handles WiFi, ethernet, and VPN
sudo systemctl enable --now NetworkManager

# Bluetooth
sudo systemctl enable --now bluetooth

# PipeWire — user-level services; best-effort since we may not have a full session
echo "    Enabling PipeWire user services (best-effort)..."
systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber || \
  echo "    (PipeWire user services will activate on next login)"

# SDDM — enabled here, starts on next boot.
# The hyprland package ships /usr/share/wayland-sessions/hyprland.desktop
# which SDDM picks up automatically. No config file needed.
sudo systemctl enable sddm

# ---------------------------------------------------------------------------
# Step 5 — Install Nix (Determinate Systems)
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
# Step 6 — Source the Nix profile
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
# Step 7 — Clone the nyx repo (if not already present)
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
# Step 8 — Apply the home-manager configuration
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
echo " For ongoing use:"
echo "   cd $NYX_DIR"
echo "   home-manager switch --flake .#$HOST"
echo ""
echo " Or use the switch script from the repo root:"
echo "   ./switch.sh"
echo ""
echo " SDDM will activate on next boot → select Hyprland from the session menu."
echo "================================================================"
