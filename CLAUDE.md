# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

**Nyx** is a personal multi-platform Nix Flakes configuration repository managing system and user configurations across NixOS (bare-metal, WSL2), macOS (Darwin), and Android (Nix-on-Droid). It is declarative infrastructure-as-code — there are no traditional tests, build artifacts, or application code.

## Key Commands

### Rebuild and Apply Configuration

```bash
# Auto-detects OS and applies correct rebuild
./switch.sh

# NixOS (manual)
sudo nixos-rebuild switch --show-trace --flake .#<hostname>

# macOS (manual)
sudo darwin-rebuild switch --flake .

# Android
nix-on-droid switch --show-trace --flake .
```

### Validate Before Applying

```bash
# Check flake outputs and syntax
nix flake show

# Dry-run (builds without activating)
sudo nixos-rebuild dry-build --flake .#<hostname>
sudo darwin-rebuild dry-build --flake .

# Build a specific host's derivation without switching
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
nix build .#darwinConfigurations.<hostname>.system
```

### Build Special Images

```bash
# Bootable installer ISO
nix build .#nixosConfigurations.livecd.config.system.build.isoImage

# VirtualBox OVA
nix build .#nixosConfigurations.virtualbox.config.system.build.isoImage

# Scripts
./build-iso.sh
./build-vm.sh
```

### Development Shell

```bash
nix develop          # Enter dev shell (provides git, git-crypt, nixUnstable)
nix flake update     # Update all flake inputs in flake.lock
nix flake update <input>  # Update a single input
```

## Architecture

### Configuration Layers

```
flake.nix  →  lib/default.nix  →  system/<platform>/  +  home/
                (mkNixSystemConfiguration, mkHome)
```

**`flake.nix`** is the entry point. It defines all inputs (nixpkgs, home-manager, hyprland, agenix, nix-darwin, nixos-wsl, nix-on-droid, etc.) and maps hostnames to their configurations via `lib/default.nix` helper functions.

**`lib/default.nix`** provides three builder functions:
- `mkNixSystemConfiguration` — builds NixOS and Darwin configurations, handles specialization by platform type (`nixos`, `darwin`, `iso`, `vm`, `wsl`)
- `mkHome` — builds standalone home-manager configurations
- `mkNixOnDroidConfiguration` — builds Android configurations

### Directory Structure

- **`system/`** — system-level modules and host definitions
  - `shared/` — cross-platform: profiles (`desktop.nix`, `macbook.nix`, `work.nix`), secrets, common modules
  - `nixos/` — NixOS kernel/boot/hardware; hosts under `nixos/hosts/<hostname>/`
  - `darwin/` — macOS-specific (yabai, dock, brews, casks); hosts under `darwin/hosts/<hostname>/`
  - `droid/` — Android Nix-on-Droid system config

- **`home/`** — user-level home-manager modules
  - `shared/modules/` — cross-platform modules by category: `app/`, `dev/`, `shell/`, `theme/`, `ai/`, `gaming/`
  - `nixos/`, `darwin/`, `droid/` — platform-specific home modules
  - `config/` — raw dotfiles symlinked into `$HOME` (`.config/`, `.ssh/`, `.gnupg/`, shell profiles)

- **`nix/`** — nixpkgs config (`config.nix`), daemon config (`nix.conf`), overlays, custom packages

- **`users/`** — user profile definitions (`mwdavisii.nix`, `mdavis67.nix`, `nixos.nix`, `droid.nix`)

- **`secrets/`** — age-encrypted secrets; `secrets/secrets.nix` defines key recipients

### Host Configuration Pattern

Each host has a directory under `system/<platform>/hosts/<hostname>/` containing some combination of:
- `default.nix` — enables/disables `nyx` modules and secrets via the `nyx` namespace options
- `home.nix` — per-host user home configuration
- `system.nix` — hardware/networking for that machine

### Module Toggle Pattern

Hosts configure themselves through the `nyx` option namespace:

```nix
nyx = {
  modules.system.hyprland.enable = true;
  secrets.userSSHKeys.enable = true;
  profiles.desktop.enable = true;
};
```

### Secrets (agenix)

Secrets are encrypted with `age` and stored in `secrets/encrypted/`. The `secrets/secrets.nix` file defines which SSH/age keys can decrypt each secret. To add or re-key secrets, edit `secrets/secrets.nix` and run `agenix` commands from the `secrets/` directory.

## Supported Hosts

| Hostname | Platform | Description |
|---|---|---|
| `hephaestus` | NixOS | Home desktop (i9 / AMD 7900xt) |
| `ares` | NixOS (WSL) | Personal WSL2 instance |
| `nixos` | NixOS (WSL) | Generic WSL2 |
| `work` | NixOS (WSL) | Work WSL2 |
| `olenos` | NixOS | ThinkPad X13 laptop |
| `L242731` | NixOS | Work Dell |
| `hydra` | NixOS | Home lab k3s VM on Proxmox |
| `livecd` | NixOS | Bootable installer ISO |
| `virtualbox` | NixOS | VirtualBox VM image |
| `mwdavis-workm1` | Darwin | Work MacBook M1 16" |
| `L241729` | Darwin | Additional Darwin host |
| `default` | Nix-on-Droid | Google Pixel Fold |
