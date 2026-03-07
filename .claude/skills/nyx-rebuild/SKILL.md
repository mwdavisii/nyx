---
name: nyx-rebuild
description: Run the correct rebuild command for the current Nyx host. Use when the user wants to apply config changes, switch configurations, or rebuild the system. Detects platform automatically.
user-invocable: true
allowed-tools: Bash(uname *), Bash(./switch.sh), Bash(sudo nixos-rebuild *), Bash(sudo darwin-rebuild *), Bash(home-manager switch *), Bash(nix-on-droid switch *), Bash(nix flake show), Bash(nix build *)
---

The user wants to rebuild and apply their Nyx configuration.

## Step 1: Detect platform

Run `uname -s` and `uname -n` to get the OS and hostname.

## Step 2: Apply the correct rebuild

Use this decision table:

| Platform | Command |
|---|---|
| macOS (Darwin) | `sudo --preserve-env=SSH_AUTH_SOCK darwin-rebuild switch --flake .` |
| Arch Linux (`/etc/arch-release` exists) | `setup/arch/02-install-packages.sh --sync && home-manager switch --show-trace --flake .#<hostname>` |
| Nix-on-Droid (user = `nix-on-droid`) | `nix-on-droid switch --show-trace --flake .` |
| NixOS (default) | `sudo nixos-rebuild switch --show-trace --flake .#<hostname>` |

Or just run `./switch.sh` which auto-detects and runs the right command.

## Useful variants

- **Dry run (build without activating):**
  - NixOS: `sudo nixos-rebuild dry-build --flake .#<hostname>`
  - Darwin: `sudo darwin-rebuild dry-build --flake .`

- **Validate syntax first:** `nix flake show`

- **Build without switching:** `nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel`

- **With verbose trace on error:** add `--show-trace` (already included in switch.sh defaults)

## Hosts reference

| Hostname | Platform | buildTarget |
|---|---|---|
| `hephaestus` | NixOS | nixos |
| `olenos` | NixOS | nixos |
| `hydra` | NixOS | nixos |
| `ares` | NixOS WSL | wsl |
| `nixos` | NixOS WSL | wsl |
| `mwdavis-workm1` | Darwin | darwin |
| `L241729` | Darwin | darwin |
| `L242731` | Arch | home-manager |
| `prometheus` | Arch | home-manager |
| `default` | Nix-on-Droid | droid |
