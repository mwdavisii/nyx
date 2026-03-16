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
INSTALL_OLLAMA="n"
INSTALL_NORDVPN="n"
INSTALL_PROTONVPN="n"
INSTALL_TAILSCALE="n"
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

  read -rp "Install Ollama with ROCm (local LLM inference on AMD GPU)? [y/N] " ollama_input
  INSTALL_OLLAMA="${ollama_input,,}"

  read -rp "Install NordVPN? [y/N] " nordvpn_input
  INSTALL_NORDVPN="${nordvpn_input,,}"

  read -rp "Install ProtonVPN? [y/N] " protonvpn_input
  INSTALL_PROTONVPN="${protonvpn_input,,}"

  read -rp "Install Tailscale? [y/N] " tailscale_input
  INSTALL_TAILSCALE="${tailscale_input,,}"

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
  obs-studio \
  pipewire \
  wireplumber \
  pipewire-alsa \
  pipewire-pulse \
  pipewire-jack \
  pavucontrol \
  pamixer \
  playerctl \
  base-devel \
  cmake \
  cpio \
  meson \
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
  gnome-calculator \
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
    linux-headers \
    dkms \
    mesa \
    vulkan-radeon \
    libva-mesa-driver \
    xf86-video-amdgpu \
    vulkan-tools \
    steam \
    lutris \
    lib32-mesa \
    lib32-vulkan-radeon

  info "Installing AUR gaming packages..."
  yay -S --needed --noconfirm \
    xpadneo-dkms \
    heroic-games-launcher-bin \
    openai-codex-bin
fi

# ---------------------------------------------------------------------------
# Step 4 — Ollama + ROCm (interactive only)
# ---------------------------------------------------------------------------

if [[ "$INSTALL_OLLAMA" == "y" ]]; then
  info "Installing ROCm runtime and Ollama with AMD GPU support..."
  sudo pacman -S --needed --noconfirm \
    rocm-hip-runtime \
    rocm-smi-lib

  info "Installing Ollama (ROCm) from AUR..."
  yay -S --needed --noconfirm \
    ollama-rocm
fi

# ---------------------------------------------------------------------------
# Step 5 — NordVPN (interactive only)
# ---------------------------------------------------------------------------

if [[ "$INSTALL_NORDVPN" == "y" ]]; then
  if ! command -v nordvpn &>/dev/null; then
    info "Installing NordVPN..."
    yay -S --needed --noconfirm nordvpn-bin
    sudo systemctl enable --now nordvpnd
    echo ""
    echo "  NordVPN installed. Log in after this script finishes:"
    echo "    nordvpn login"
    echo "    nordvpn connect"
  else
    info "NordVPN already installed."
  fi
fi

# ---------------------------------------------------------------------------
# Step 6 — ProtonVPN (interactive only)
# ---------------------------------------------------------------------------

if [[ "$INSTALL_PROTONVPN" == "y" ]]; then
  if ! command -v protonvpn &>/dev/null; then
    info "Installing ProtonVPN..."
    sudo pacman -S --needed --noconfirm proton-vpn-gtk-app
    echo ""
    echo "  ProtonVPN installed. Launch and log in after this script finishes."
  else
    info "ProtonVPN already installed."
  fi
fi

# ---------------------------------------------------------------------------
# Step 7 — Tailscale (interactive only)
# ---------------------------------------------------------------------------

if [[ "$INSTALL_TAILSCALE" == "y" ]]; then
  info "Installing Tailscale..."
  sudo pacman -S --needed --noconfirm tailscale
  sudo systemctl enable --now tailscaled
  echo ""
  echo "  Tailscale installed. Authenticate after this script finishes:"
  echo "    sudo tailscale up"
fi

# ---------------------------------------------------------------------------
# Step 8 — AUR packages (always)
# ---------------------------------------------------------------------------

info "Installing AUR packages..."

yay -S --needed --noconfirm \
  swww \
  nwg-displays \
  obsidian \
  claude-desktop-bin \
  sublime-text-4

info "Installing Hyprland plugins via hyprpm..."
# Use system cmake/pkg-config, not Nix's, which can't find system packages
_SYSPATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin
_PKGCFG=/usr/lib/pkgconfig:/usr/share/pkgconfig
PKG_CONFIG_PATH="$_PKGCFG" PATH="$_SYSPATH" hyprpm update
PKG_CONFIG_PATH="$_PKGCFG" PATH="$_SYSPATH" hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm enable hyprexpo
hyprpm enable hyprbars
hyprpm enable hyprwinwrap
hyprpm enable hyprtrails



# ---------------------------------------------------------------------------
# Step 9 — Work security tools (interactive only)
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
# Step 10 — Cloudflare WARP (interactive only)
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
# Step 11 — Enable services
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
