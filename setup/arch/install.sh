#!/usr/bin/env bash
# =============================================================================
# Nyx Arch Linux installer — run from archiso live environment
# =============================================================================
# Full disk install with LUKS2 encryption, Btrfs, and systemd-boot.
#
# Usage (from archiso):
#   curl -LO https://raw.githubusercontent.com/mwdavisii/nyx/main/setup/arch/install.sh
#   chmod +x install.sh
#   ./install.sh
#
# After reboot, login as mdavis67 and run start_here.sh to finish setup.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
HOSTNAME="arch-work"
USERNAME="mdavis67"
TIMEZONE="America/Chicago"
LOCALE="en_US.UTF-8"
CRYPT_NAME="cryptroot"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info()  { echo "==> $*"; }
warn()  { echo "WARNING: $*" >&2; }
die()   { echo "FATAL: $*" >&2; exit 1; }

prompt_password() {
  local desc="$1" pw pw2
  while true; do
    read -rsp "Enter $desc: " pw; echo
    read -rsp "Confirm $desc: " pw2; echo
    if [[ "$pw" == "$pw2" ]]; then
      echo "$pw"
      return
    fi
    echo "Passwords do not match. Try again."
  done
}

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
[[ "$(id -u)" -eq 0 ]] || die "Must run as root (from archiso)."
[[ -d /run/archiso ]] || warn "Not running from archiso — proceed with caution."

# ---------------------------------------------------------------------------
# Interactive prompts — collect everything before any destructive action
# ---------------------------------------------------------------------------
echo ""
echo "============================================================"
echo "  Nyx Arch Linux Installer"
echo "============================================================"
echo ""

# Disk selection
info "Available disks:"
echo ""
lsblk -d -o NAME,SIZE,TYPE,MODEL | grep -E 'disk'
echo ""
read -rp "Enter target disk (e.g. /dev/nvme0n1 or /dev/sda): " TARGET_DISK
[[ -b "$TARGET_DISK" ]] || die "Not a valid block device: $TARGET_DISK"

# Passwords
echo ""
LUKS_PASS=$(prompt_password "LUKS encryption passphrase")
ROOT_PASS=$(prompt_password "root password")
USER_PASS=$(prompt_password "password for $USERNAME")

# Final confirmation
echo ""
echo "============================================================"
echo "  WARNING: This will ERASE ALL DATA on $TARGET_DISK"
echo "============================================================"
echo ""
echo "  Disk:      $TARGET_DISK"
echo "  Hostname:  $HOSTNAME"
echo "  User:      $USERNAME"
echo "  Timezone:  $TIMEZONE"
echo ""
read -rp "Type YES to continue: " CONFIRM
[[ "$CONFIRM" == "YES" ]] || die "Aborted by user."

# ---------------------------------------------------------------------------
# Partition names — handle NVMe vs SATA naming
# ---------------------------------------------------------------------------
if [[ "$TARGET_DISK" == *nvme* ]] || [[ "$TARGET_DISK" == *mmcblk* ]]; then
  PART_EFI="${TARGET_DISK}p1"
  PART_ROOT="${TARGET_DISK}p2"
else
  PART_EFI="${TARGET_DISK}1"
  PART_ROOT="${TARGET_DISK}2"
fi

# ===========================================================================
# Phase 1 — Partitioning & Encryption (archiso)
# ===========================================================================

info "Wiping and partitioning $TARGET_DISK..."
sgdisk --zap-all "$TARGET_DISK"
sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI" "$TARGET_DISK"
sgdisk -n 2:0:0     -t 2:8309 -c 2:"cryptroot" "$TARGET_DISK"
partprobe "$TARGET_DISK"
sleep 1

info "Formatting EFI partition ($PART_EFI)..."
mkfs.fat -F32 "$PART_EFI"

info "Creating LUKS2 container on $PART_ROOT..."
echo -n "$LUKS_PASS" | cryptsetup luksFormat --type luks2 "$PART_ROOT" -

info "Opening LUKS container..."
echo -n "$LUKS_PASS" | cryptsetup open "$PART_ROOT" "$CRYPT_NAME" -

info "Formatting root filesystem (btrfs)..."
mkfs.btrfs -f "/dev/mapper/$CRYPT_NAME"

info "Creating btrfs subvolumes..."
mount "/dev/mapper/$CRYPT_NAME" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
umount /mnt

info "Mounting subvolumes..."
BTRFS_OPTS="compress=zstd,noatime,space_cache=v2"
mount -o "subvol=@,$BTRFS_OPTS" "/dev/mapper/$CRYPT_NAME" /mnt
mkdir -p /mnt/{home,.snapshots,boot}
mount -o "subvol=@home,$BTRFS_OPTS" "/dev/mapper/$CRYPT_NAME" /mnt/home
mount -o "subvol=@snapshots,$BTRFS_OPTS" "/dev/mapper/$CRYPT_NAME" /mnt/.snapshots
mount "$PART_EFI" /mnt/boot

# ===========================================================================
# Phase 2 — Pacstrap
# ===========================================================================

info "Installing base system and packages via pacstrap..."

pacstrap /mnt \
  base linux linux-firmware btrfs-progs \
  sudo vim git curl \
  \
  base-devel \
  \
  hyprland \
  hyprlock \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk \
  xorg-xwayland \
  wayland-utils \
  \
  sddm \
  \
  polkit \
  rtkit \
  \
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
  \
  thunar \
  gvfs \
  tumbler \
  \
  libinput \
  \
  acpi \
  \
  noto-fonts \
  noto-fonts-cjk \
  noto-fonts-emoji \
  ttf-firacode-nerd

# ===========================================================================
# Phase 3 — Generate fstab
# ===========================================================================

info "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# ===========================================================================
# Phase 4 — Chroot configuration
# ===========================================================================

info "Entering chroot for system configuration..."

# Grab the LUKS partition UUID before entering chroot
LUKS_UUID=$(blkid -s UUID -o value "$PART_ROOT")

arch-chroot /mnt /bin/bash <<CHROOT_EOF
set -euo pipefail

# --- Timezone ---
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc

# --- Locale ---
sed -i 's/^#${LOCALE}/${LOCALE}/' /etc/locale.gen
locale-gen
echo "LANG=${LOCALE}" > /etc/locale.conf

# --- Hostname ---
echo "${HOSTNAME}" > /etc/hostname

# --- mkinitcpio — add encrypt hook ---
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt filesystems fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P

# --- systemd-boot ---
bootctl install

mkdir -p /boot/loader/entries

cat > /boot/loader/loader.conf <<LOADER
default arch.conf
timeout 3
console-mode max
editor  no
LOADER

cat > /boot/loader/entries/arch.conf <<ENTRY
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options cryptdevice=UUID=${LUKS_UUID}:${CRYPT_NAME} root=/dev/mapper/${CRYPT_NAME} rw
ENTRY

# --- Root password ---
echo "root:${ROOT_PASS}" | chpasswd

# --- Create user ---
useradd -m -G wheel -s /bin/bash ${USERNAME}
echo "${USERNAME}:${USER_PASS}" | chpasswd

# --- Sudoers ---
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# --- Enable services (no --now, system isn't booted yet) ---
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable sddm

CHROOT_EOF

# ===========================================================================
# Phase 5 — Cleanup
# ===========================================================================

info "Unmounting filesystems..."
umount -R /mnt

info "Closing LUKS container..."
cryptsetup close "$CRYPT_NAME"

# ===========================================================================
# Done
# ===========================================================================

echo ""
echo "============================================================"
echo "  Installation complete!"
echo "============================================================"
echo ""
echo "  1. Remove the installation media"
echo "  2. Reboot:  reboot"
echo "  3. Unlock the disk with your LUKS passphrase"
echo "  4. Login as: $USERNAME"
echo "  5. Run the bootstrap script:"
echo ""
echo "     curl -LO https://raw.githubusercontent.com/mwdavisii/nyx/main/setup/arch/start_here.sh"
echo "     chmod +x start_here.sh"
echo "     ./start_here.sh"
echo ""
echo "============================================================"
