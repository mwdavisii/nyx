#!/usr/bin/env bash
# =============================================================================
# Nyx Arch Linux package manager — idempotent, re-runnable
# =============================================================================
# Installs all system-level packages (pacman + AUR) for the Nyx desktop.
#
# Usage:
#   ./02-install-packages.sh          # Interactive — prompts for optional packages
#   ./02-install-packages.sh --sync   # Non-interactive — core + AUR only, no prompts
#
# Safe to re-run at any time. Uses --needed to skip already-installed packages.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info()  { echo "==> $*"; }
warn()  { echo "WARNING: $*" >&2; }
die()   { echo "FATAL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
[[ "$(id -u)" -ne 0 ]] || die "Do not run as root. This script uses sudo where needed."
ping -c 1 -W 3 archlinux.org &>/dev/null || die "No network connectivity. Connect first (nmtui)."

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
SYNC_MODE=false
if [[ "${1:-}" == "--sync" ]]; then
  SYNC_MODE=true
fi

# ---------------------------------------------------------------------------
# Interactive prompts (collected upfront, skipped in --sync mode)
# ---------------------------------------------------------------------------
INSTALL_AMD_GAMING="n"
INSTALL_SECURITY="n"
INSTALL_WARP="n"

if [[ "$SYNC_MODE" == false ]]; then
  echo ""
  echo "============================================================"
  echo "  Nyx Arch Linux Package Installer"
  echo "============================================================"
  echo ""

  read -rp "Install AMD graphics drivers and gaming packages (Steam, Vulkan, etc.)? [y/N] " amd_input
  INSTALL_AMD_GAMING="${amd_input,,}"

  read -rp "Install work security tools (CrowdStrike, Cisco VPN)? [y/N] " sec_input
  INSTALL_SECURITY="${sec_input,,}"

  read -rp "Install Cloudflare WARP? [y/N] " warp_input
  INSTALL_WARP="${warp_input,,}"

  echo ""
fi

# ---------------------------------------------------------------------------
# Step 1 — AUR helper (yay)
# ---------------------------------------------------------------------------

if ! command -v yay &>/dev/null; then
  info "Installing yay (AUR helper)..."
  sudo pacman -S --needed --noconfirm base-devel git
  tmp_dir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay-bin.git "$tmp_dir/yay-bin"
  (cd "$tmp_dir/yay-bin" && makepkg -si --noconfirm)
  rm -rf "$tmp_dir"
else
  info "yay already installed: $(yay --version | head -1)"
fi

# ---------------------------------------------------------------------------
# Step 2 — Core desktop packages (pacman)
# ---------------------------------------------------------------------------

info "Installing core desktop packages..."

sudo pacman -S --needed --noconfirm \
  \
  foot kitty alacritty \
  \
  hyprland \
  hyprlock \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk \
  xorg-xwayland \
  wayland-utils \
  gnome-keyring \
  libsecret \
  polkit \
  rtkit \
  ntfs-3g \
  ghostscript \
  system-config-printer \
  cups \
  bc \
  foomatic-db-engine \
  foomatic-db-engine \
  pipewire \
  wireplumber \
  pipewire-alsa \
  pipewire-pulse \
  pipewire-jack \
  pavucontrol \
  pamixer \
  playerctl \
  \
  networkmanager \
  wpa_supplicant \
  iw \
  wireless_tools \
  network-manager-applet \
  nm-connection-editor \
  \
  bluez \
  bluez-utils \
  blueman \
  \
  wlr-randr \
  grim \
  slurp \
  wl-clipboard \
  kanshi \
  scrcpy \
  hypridle \
  hyprpicker \
  \
  thunar \
  gvfs \
  tumbler \
  \
  libinput \
  \
  acpi \
  waybar \
  rofi \
  kmonad \
  \
  noto-fonts \
  noto-fonts-cjk \
  noto-fonts-emoji \
  ttf-firacode-nerd

# ---------------------------------------------------------------------------
# Step 3 — AMD gaming (interactive only)
# ---------------------------------------------------------------------------

if [[ "$INSTALL_AMD_GAMING" == "y" ]]; then
  info "Enabling multilib repository..."
  # Uncomment [multilib] and its Include line
  sudo sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//}' /etc/pacman.conf
  sudo pacman -Sy --noconfirm

  info "Installing AMD graphics drivers and gaming packages..."
  sudo pacman -S --needed --noconfirm \
    mesa \
    vulkan-radeon \
    libva-mesa-driver \
    xf86-video-amdgpu \
    vulkan-tools \
    steam \
    lutris \
    lib32-mesa \
    lib32-vulkan-radeon
fi

# ---------------------------------------------------------------------------
# Step 4 — AUR packages (always)
# ---------------------------------------------------------------------------

info "Installing AUR packages..."

yay -S --needed --noconfirm \
  swww \
  nwg-displays

# ---------------------------------------------------------------------------
# Step 5 — Work security tools (interactive only)
# ---------------------------------------------------------------------------

if [[ "$INSTALL_SECURITY" == "y" ]]; then
  info "Installing work security tools..."

  # CrowdStrike Falcon (EDR agent)
  if ! systemctl list-unit-files falcon-sensor.service &>/dev/null; then
    info "Installing CrowdStrike Falcon..."
    yay -S --noconfirm falcon-sensor
  else
    info "falcon-sensor already installed."
  fi

  # Cisco Secure Client (VPN)
  if ! command -v csc-vpn &>/dev/null; then
    info "Installing Cisco Secure Client..."
    yay -S --noconfirm cisco-secure-client
    sudo systemctl enable --now vpnagentd
  else
    info "Cisco Secure Client already installed."
  fi
fi

# ---------------------------------------------------------------------------
# Step 6 — Cloudflare WARP (interactive only)
# ---------------------------------------------------------------------------

if [[ "$INSTALL_WARP" == "y" ]]; then
  if ! command -v warp-cli &>/dev/null; then
    info "Installing Cloudflare WARP..."
    yay -S --noconfirm cloudflare-warp-bin
    echo ""
    echo "  WARP installed. After this script finishes, register and connect:"
    echo "    sudo systemctl enable --now warp-svc"
    echo "    warp-cli registration new"
    echo "    warp-cli connect"
  else
    info "WARP already installed: $(warp-cli --version 2>/dev/null || echo 'version unknown')"
  fi
fi

# ---------------------------------------------------------------------------
# Step 7 — Enable services
# ---------------------------------------------------------------------------

info "Enabling services..."
sudo systemctl enable --now bluetooth 2>/dev/null || true

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

if [[ "$SYNC_MODE" == false ]]; then
  echo ""
  echo "============================================================"
  echo "  Packages installed!"
  echo "============================================================"
  echo ""
  echo "  Next step — bootstrap Nix and home-manager:"
  echo ""
  echo "    curl -LO https://raw.githubusercontent.com/mwdavisii/nyx/main/setup/arch/03-setup-nix.sh"
  echo "    chmod +x 03-setup-nix.sh"
  echo "    ./03-setup-nix.sh"
  echo ""
  echo "============================================================"
else
  info "Package sync complete."
fi
