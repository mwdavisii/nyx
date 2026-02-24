# Arch Linux Install Guide

Two-phase setup: **install.sh** builds the system from archiso, **start_here.sh** bootstraps user tooling after first boot.

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
curl -LO https://raw.githubusercontent.com/mwdavisii/nyx/main/setup/arch/install.sh
chmod +x install.sh
./install.sh
```

The script will prompt for:

| Prompt | Notes |
|---|---|
| Target disk | Selected by number from a list — **this disk will be wiped** |
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
3. **Pacstraps** the base system plus all desktop packages (Hyprland, PipeWire, NetworkManager, Bluetooth, fonts, etc.)
4. **Configures** timezone (America/Chicago), locale (en_US.UTF-8), hostname (arch-work)
5. **Sets up** mkinitcpio with the `encrypt` hook for LUKS
6. **Installs** systemd-boot with an entry that unlocks the encrypted root
7. **Creates** user `mdavis67` (wheel group, sudo access)
8. **Enables** services: NetworkManager, bluetooth

### After install completes

```bash
reboot
```

Remove the installation media when prompted. The system will ask for your LUKS passphrase, then drop you to a **TTY login prompt**.

## Phase 2 — User Bootstrap (after first login)

Login as your user at the TTY prompt.

### Reconnect to WiFi

The archiso connection does not carry over. Use NetworkManager (already installed and running):

```bash
sudo nmtui
```

Navigate to **Activate a connection**, select your network, enter the passphrase, then **Back** and quit. Verify with `ping -c 3 archlinux.org`.

> Note: `iwctl` is only available on the Arch ISO. The installed system uses `nmtui` / `nmcli` instead.

### Run the bootstrap



```bash
curl -LO https://raw.githubusercontent.com/mwdavisii/nyx/main/setup/arch/start_here.sh
chmod +x start_here.sh
./start_here.sh
```

### What the bootstrap does

1. **Installs yay** — AUR helper (can't build packages as root in chroot, so this runs post-boot)
2. **Cloudflare WARP** — optional, prompts to install via yay. Recommended before Nix to avoid DNS/path conflicts
3. **Installs Nix** — via the Determinate Systems installer
4. **Clones nyx repo** — tries SSH first, falls back to HTTPS if keys aren't set up
5. **Runs home-manager switch** — applies the `arch-work` flake configuration
6. **Configures TTY auto-login** — getty on tty1 logs you in automatically; the zsh login profile launches Hyprland if `$DISPLAY` is unset and you're on tty1

### After bootstrap completes

- Reboot into Hyprland: `sudo reboot`
- On every subsequent boot: LUKS passphrase → auto-login → Hyprland starts automatically
- If PipeWire audio isn't working: `systemctl --user start pipewire pipewire-pulse wireplumber`
- If you skipped WARP, install it later:
  ```bash
  yay -S cloudflare-warp-bin
  sudo systemctl enable --now warp-svc
  warp-cli registration new
  warp-cli connect
  ```

## Ongoing Use

```bash
cd ~/code/nyx
home-manager switch --flake .#arch-work
```

Or from the repo root:

```bash
./switch.sh
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
