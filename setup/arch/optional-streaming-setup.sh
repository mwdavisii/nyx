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

if ! pacman -Q v4l2loopback-dkms &>/dev/null; then
    echo "  Installing v4l2loopback-dkms..."
    sudo pacman -S --noconfirm v4l2loopback-dkms
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
