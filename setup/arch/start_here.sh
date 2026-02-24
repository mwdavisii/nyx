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
# Step 2 — Work security tools (AUR)
# ---------------------------------------------------------------------------

echo ""
echo "==> Installing work security tools..."

# CrowdStrike Falcon (EDR agent)
if ! systemctl list-unit-files falcon-sensor.service &>/dev/null; then
  echo "    Installing CrowdStrike Falcon..."
  yay -S --noconfirm falcon-sensor
  #sudo systemctl enable --now falcon-sensor / this enable will fail with customer id.
else
  echo "    falcon-sensor already installed."
fi

# Cisco Secure Client (VPN)
if ! command -v csc-vpn &>/dev/null; then
  echo "    Installing Cisco Secure Client..."
  yay -S --noconfirm cisco-secure-client
  sudo systemctl enable --now vpnagentd
else
  echo "    Cisco Secure Client already installed."
fi

# ---------------------------------------------------------------------------
# Step 3 — AUR utilities
# ---------------------------------------------------------------------------

echo ""
echo "==> Installing AUR utilities..."

# kmonad — keyboard remapper (needs uinput group + udev rules from install.sh)
if ! command -v kmonad &>/dev/null; then
  echo "    Installing kmonad..."
  yay -S --noconfirm kmonad-bin
else
  echo "    kmonad already installed: $(kmonad --version 2>/dev/null || echo 'version unknown')"
fi

# ---------------------------------------------------------------------------
# Step 4 — Cloudflare WARP (optional)
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
# Step 7 — Clone the nyx repo (SSH with HTTPS fallback)
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
# Step 8 — Remove bash skeleton files that collide with home-manager
# ---------------------------------------------------------------------------
# useradd creates .bash_profile, .bashrc, .bash_logout stubs. home-manager
# refuses to overwrite files it didn't create, so remove them first.

echo ""
echo "==> Removing bash skeleton files to prevent home-manager collisions..."
rm -f "$HOME"/.bash_profile "$HOME"/.bashrc "$HOME"/.bash_logout "$HOME"/.bash_history

# ---------------------------------------------------------------------------
# Step 9 — Apply the home-manager configuration
# ---------------------------------------------------------------------------

echo ""
echo "==> Running home-manager switch for host: $HOST"
cd "$NYX_DIR"

nix run home-manager -- switch --show-trace --flake ".#$HOST"

# ---------------------------------------------------------------------------
# Step 10 — TTY auto-login
# ---------------------------------------------------------------------------
# No display manager. getty auto-logs in on tty1; the zsh login profile
# (managed by home-manager) launches Hyprland automatically.

echo ""
echo "==> Configuring TTY auto-login for $USER on tty1..."
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER --noclear %I \$TERM
EOF
sudo systemctl daemon-reload

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
echo " Reboot to start SDDM and land in Hyprland:"
echo "   sudo reboot"
echo "================================================================"
