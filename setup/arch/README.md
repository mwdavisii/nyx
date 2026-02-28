# Arch Linux Install Guide

Three-phase setup: **01-install.sh** builds a minimal bootable system from archiso, **02-install-packages.sh** installs all desktop packages, **03-setup-nix.sh** bootstraps Nix and home-manager.

## Prerequisites

- Arch Linux ISO booted (UEFI mode)
- Internet connection (ethernet or `iwctl` for WiFi)
- Target disk identified (run `lsblk` to check)

## Phase 1 — System Install (from archiso)

### Connect to the internet

Wired connections should work automatically. For WiFi:

```bash
iwctl
# Inside iwctl:
station wlan0 scan
station wlan0 get-networks
station wlan0 connect "SSID"
exit
```

Verify connectivity:

```bash
ping -c 3 archlinux.org
```

### Run the installer

```bash
curl -LO https://raw.githubusercontent.com/mwdavisii/nyx/main/setup/arch/01-install.sh
chmod +x 01-install.sh
./01-install.sh
```

The script will prompt for:

| Prompt | Notes |
|---|---|
| Target disk | Selected by number from a list — **this disk will be wiped** |
| Hostname | Machine hostname — defaults to `L242731`, press enter to accept |
| Username | Your Linux username — defaults to `mdavis67`, press enter to accept |
| LUKS passphrase | Disk encryption password — entered on every boot |
| Root password | For the root account |
| User password | For your user account |
| Final confirmation | Type `YES` to proceed |

All prompts are collected before any destructive action.

### What the installer does

1. **Partitions** the disk (GPT):
   - 512 MB EFI System Partition (FAT32, `/boot`)
   - Remaining space as LUKS2-encrypted Btrfs root (`/`)
2. **Creates Btrfs subvolumes** with zstd compression:
   - `@` mounted at `/`
   - `@home` mounted at `/home`
   - `@snapshots` mounted at `/.snapshots`
3. **Pacstraps** a minimal base system (base, linux, linux-firmware, btrfs-progs, sudo, vim, git, curl, zsh, base-devel, networkmanager)
4. **Configures** timezone (America/Chicago), locale (en_US.UTF-8), hostname (defaults to L242731)
5. **Sets up** mkinitcpio with the `encrypt` hook for LUKS
6. **Installs** systemd-boot with an entry that unlocks the encrypted root
7. **Creates** user `mdavis67` (wheel group, sudo access)
8. **Enables** NetworkManager

### After install completes

```bash
reboot
```

Remove the installation media when prompted. The system will ask for your LUKS passphrase, then drop you to a **TTY login prompt**.

## Phase 2 — Desktop Packages (after first login)

Login as your user at the TTY prompt.

### Reconnect to WiFi

The archiso connection does not carry over. Use NetworkManager (already installed and running):

```bash
sudo nmtui
```

Navigate to **Activate a connection**, select your network, enter the passphrase, then **Back** and quit. Verify with `ping -c 3 archlinux.org`.

> Note: `iwctl` is only available on the Arch ISO. The installed system uses `nmtui` / `nmcli` instead.

### Install packages

```bash
curl -LO https://raw.githubusercontent.com/mwdavisii/nyx/main/setup/arch/02-install-packages.sh
chmod +x 02-install-packages.sh
./02-install-packages.sh
```

The script will prompt for optional extras:

| Prompt | Notes |
|---|---|
| AMD gaming | Mesa, Vulkan, Steam, Lutris, 32-bit libs (enables multilib) |
| Security tools | CrowdStrike Falcon, Cisco Secure Client |
| Cloudflare WARP | DNS/VPN client |

### What 02-install-packages.sh does

1. **Installs yay** — AUR helper (can't build packages as root in chroot, so this runs post-boot)
2. **Core desktop packages** — Hyprland, PipeWire, Bluetooth, fonts, terminals, file manager, Wayland utilities, etc.
3. **AMD gaming** (optional) — enables multilib, installs Mesa/Vulkan/Steam/Lutris
4. **AUR packages** — kmonad-bin, swww, nwg-displays
5. **Security tools** (optional) — CrowdStrike Falcon, Cisco Secure Client
6. **Cloudflare WARP** (optional) — DNS/VPN via AUR
7. **Enables** bluetooth service

This script is idempotent — safe to re-run at any time. It uses `--needed` to skip already-installed packages. It also runs automatically (in `--sync` mode, core packages only) via `./switch.sh`.

## Phase 3 — Nix & Home-Manager Bootstrap

```bash
curl -LO https://raw.githubusercontent.com/mwdavisii/nyx/main/setup/arch/03-setup-nix.sh
chmod +x 03-setup-nix.sh
./03-setup-nix.sh
```

### What 03-setup-nix.sh does

1. **Installs Nix** — via the Determinate Systems installer
2. **Clones nyx repo** — tries SSH first, falls back to HTTPS if keys aren't set up
3. **Clears bash skeleton files** — removes `~/.bashrc`, `~/.bash_profile`, etc. before home-manager switch to avoid collisions
4. **Runs home-manager switch** — applies the flake configuration for your hostname

### After bootstrap completes

- Reboot: `sudo reboot`
- On every subsequent boot: LUKS passphrase → TTY login prompt → enter credentials → Hyprland launches automatically

## Ongoing Use

```bash
cd ~/code/nyx
./switch.sh
```

`switch.sh` automatically runs `02-install-packages.sh --sync` (core packages, no prompts) before `home-manager switch` on Arch, so new system packages are picked up on every switch.

To add optional packages interactively (AMD gaming, security tools, WARP):

```bash
cd ~/code/nyx
setup/arch/02-install-packages.sh
```

## Disk Layout Reference

```
/dev/nvme0n1 (or /dev/sdX)
├── p1  512M  EFI System Partition  → /boot  (FAT32)
└── p2  rest  LUKS2 container       → cryptroot
                └── Btrfs (compress=zstd,noatime,space_cache=v2)
                    ├── @           → /
                    ├── @home       → /home
                    └── @snapshots  → /.snapshots
```
