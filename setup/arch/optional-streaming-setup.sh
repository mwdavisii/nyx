#!/usr/bin/env bash
# 04-streaming-setup.sh — One-time system-level setup for the streaming pipeline.
#
# Run this after 02-install-packages.sh on a new Arch install.
# Requires sudo. Safe to re-run (idempotent).
#
# What it configures:
#   - v4l2loopback kernel module (OBS Virtual Camera for conf calls)
#   - udev rule for Logitech Litra Glow (non-root HID access)
#   - Restarts WirePlumber to pick up mic priority config

set -euo pipefail

echo "=== Streaming pipeline system setup ==="

# --- v4l2loopback (OBS Virtual Camera) ---
echo ""
echo "[1/4] Configuring v4l2loopback (OBS Virtual Camera)..."

# Ensure DKMS toolchain is present before pulling in the dkms package.
missing_pkgs=()
for pkg in linux-headers dkms v4l2loopback-dkms; do
    if ! pacman -Q "$pkg" &>/dev/null; then
        missing_pkgs+=("$pkg")
    fi
done
if (( ${#missing_pkgs[@]} > 0 )); then
    echo "  Installing: ${missing_pkgs[*]}"
    sudo pacman -S --needed --noconfirm "${missing_pkgs[@]}"
fi

# If the running kernel doesn't match the installed kernel, modprobe will fail
# because the running kernel's /lib/modules dir was removed on upgrade. Bail
# with a clear message instead of letting modprobe emit a cryptic error.
running_kernel=$(uname -r)
if [[ ! -d "/lib/modules/${running_kernel}" ]]; then
    echo ""
    echo "  ERROR: running kernel ${running_kernel} has no /lib/modules directory."
    echo "  You likely upgraded the kernel without rebooting. Reboot, then re-run this script."
    exit 1
fi

# Build the module for the running kernel if DKMS hasn't already.
if ! dkms status v4l2loopback 2>/dev/null | grep -q "${running_kernel}.*installed"; then
    echo "  Building v4l2loopback via DKMS for ${running_kernel}..."
    sudo dkms autoinstall -k "${running_kernel}"
fi

sudo tee /etc/modprobe.d/v4l2loopback.conf > /dev/null <<'EOF'
options v4l2loopback video_nr=10 card_label="OBS Virtual Camera" exclusive_caps=1
EOF

sudo tee /etc/modules-load.d/v4l2loopback.conf > /dev/null <<'EOF'
v4l2loopback
EOF

if ! lsmod | grep -q v4l2loopback; then
    echo "  Loading v4l2loopback module..."
    sudo modprobe v4l2loopback video_nr=10 card_label="OBS Virtual Camera" exclusive_caps=1
else
    echo "  v4l2loopback already loaded."
fi

# --- Litra udev rule ---
echo ""
echo "[2/4] Configuring Litra Glow udev rule..."

sudo tee /etc/udev/rules.d/99-litra.rules > /dev/null <<'EOF'
# Logitech Litra Glow — allow non-root HID access
SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c900", MODE="0666"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger
echo "  Udev rules reloaded."

# --- Restart WirePlumber ---
echo ""
echo "[3/4] Restarting WirePlumber (picks up mic priority config)..."
systemctl --user restart wireplumber
echo "  WirePlumber restarted."

# --- Restart EasyEffects ---
echo ""
echo "[4/4] Restarting EasyEffects..."
if systemctl --user is-active easyeffects &>/dev/null; then
    systemctl --user restart easyeffects
    echo "  EasyEffects restarted."
else
    echo "  EasyEffects not running as a service. Start it manually or add to autostart."
fi

echo ""
echo "=== Done! ==="
echo ""
echo "Next steps:"
echo "  1. Open OBS → Start Virtual Camera"
echo "  2. In Teams/Zoom/Meet, select 'OBS Virtual Camera' as your camera"
echo "  3. Open EasyEffects → Input tab → Load 'Streaming' preset → Toggle on"
echo "  4. Verify: v4l2-ctl --list-devices (should show 'OBS Virtual Camera')"
echo "  5. Verify: litra devices (should show your Litra Glow)"
