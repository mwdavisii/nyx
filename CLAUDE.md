# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Nyx is a multi-platform declarative system configuration repository using **Nix Flakes**. It manages NixOS, macOS (Darwin), WSL2, and Android (Nix-on-Droid) environments. The entire codebase is Nix with supporting shell/PowerShell setup scripts.

## Key Commands

```bash
# Rebuild and switch to new configuration (auto-detects platform)
./switch.sh

# Darwin-specific (what switch.sh runs under the hood)
sudo --preserve-env=SSH_AUTH_SOCK darwin-rebuild switch --flake .

# NixOS-specific
sudo nixos-rebuild switch --show-trace --flake .#<hostname>

# Nix-on-Droid
nix-on-droid switch --show-trace --flake .

# Rollback a failed build
darwin-rebuild switch --rollback   # macOS
nixos-rebuild switch --rollback    # NixOS

# Update flake inputs
nix flake update

# Enter dev shell (provides git, git-crypt, nix-unstable)
nix develop

# Build ISO image
./build-iso.sh

# Build VirtualBox image
./build-vm.sh
```

## Architecture

### Configuration Flow

`flake.nix` defines all hosts and delegates to `lib/default.nix` which contains the core builder functions:

- **`mkNixSystemConfiguration`** — Builds NixOS and Darwin system configurations
- **`mkHome` / `mkUserHome`** — Builds Home Manager configurations
- **`mkNixOnDroidConfiguration`** — Builds Android configurations

Each host is defined in `flake.nix` with `{ system, user, hostname, buildTarget }` and maps to a directory under `system/<platform>/hosts/<hostname>/`.

### Directory Roles

| Directory | Purpose |
|-----------|---------|
| `lib/default.nix` | Core builder functions (~13k lines). All `mk*` functions live here |
| `system/` | OS-level and host-specific configs (networking, hardware, secrets) |
| `home/` | User-facing configs managed by Home Manager (apps, shells, dotfiles) |
| `users/` | User identity files (username, email, signing key) |
| `nix/` | Nixpkgs config, overlays, custom packages |
| `setup/` | One-time platform installation scripts |
| `home/config/` | Raw dotfiles copied into place (not Nix-managed) |

### Custom Options System (`nyx.*`)

The project defines custom NixOS/Darwin options under the `nyx` namespace. These are set per-host in `system/<platform>/hosts/<hostname>/default.nix`:

```nix
nyx = {
  modules.user.home = ./home.nix;       # Home Manager entry point for this host
  secrets = { awsSSHKeys.enable = true; userSSHKeys.enable = true; ... };
  profiles = { desktop.enable = true; work.enable = true; ... };
};
```

Where the options are applied:
- **`nyx.secrets.*`** → `system/shared/secrets/`
- **`nyx.profiles.*`** → `system/shared/profiles/`
- **`nyx.modules.app.*`** → `home/shared/modules/app/`
- **`nyx.modules.dev.*`** → `home/shared/modules/dev/`
- **`nyx.modules.shell.*`** → `home/shared/modules/shell/`

### Platform Layering

Modules are layered: `shared` (cross-platform) → `<platform>` (platform-specific). Both `system/` and `home/` follow this pattern. For example, a shell module in `home/shared/modules/shell/` applies everywhere, while one in `home/darwin/modules/` is macOS-only.

### Configured Hosts

Darwin: `mwdavis-workm1` (M1 MacBook), `L241729` (work Mac)
NixOS: `ares` (WSL), `hephaestus` (desktop), `hydra` (k3s homelab), `olenos` (ThinkPad), `L242731` (work Dell), `nixos` (generic WSL), `livecd`, `virtualbox`
Droid: `default` (Pixel Fold)

### Secrets

Uses [agenix](https://github.com/ryantm/agenix) with age-encrypted files stored in a private repo (`nix-secrets`). Secrets are decrypted at the system level (not home-manager) for better permission control. To run without secrets, point `flake.nix` at `nix-secrets-example` and set all `nyx.secrets.*.enable = false`.

### Homebrew Integration (Darwin)

macOS apps are managed via `nix-homebrew`. Cask definitions live in `system/darwin/casks.nix` and brew formulas in `system/darwin/brews.nix`.
