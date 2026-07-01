# DGX (Castor & Pollux) Install Guide

Two-phase setup: **01-install-packages.sh** installs the apt packages nyx assumes are present, **02-setup-nix.sh** bootstraps Nix and home-manager. DGX OS ships pre-installed — there is no Phase 0 disk-partition step (unlike `setup/arch/`).

## Prerequisites

- DGX OS booted, logged in as your user (`mwdavisii`).
- Sudo access.
- Network reachable (`ping -c 3 github.com`).
- Hostname set to `castor` or `pollux` (`sudo hostnamectl set-hostname castor` if not).

## Phase 1 — Vendor state (no-op)

DGX OS is already installed. NVIDIA drivers, CUDA, and (if enabled) `nvidia-container-toolkit` are managed by NVIDIA's apt repos. **Nyx does not touch them.**

Confirm:

```bash
nvidia-smi
```

If this doesn't work, fix the vendor install first — nothing in nyx will help.

## Phase 2 — Core apt packages

```bash
curl -LO https://raw.githubusercontent.com/mwdavisii/nyx/main/setup/dgx/01-install-packages.sh
chmod +x 01-install-packages.sh
./01-install-packages.sh
```

Installs a small core set: `git curl ca-certificates xz-utils zsh build-essential libfido2-1 unzip`.

Optional prompt (interactive mode only):

| Prompt | Notes |
|---|---|
| Yubikey / PC-SC tooling | Installs `yubikey-manager` and `pcscd`, enables the service |

This script is idempotent. It also runs automatically in `--sync` mode from `./switch.sh` and `./update.sh` on every rebuild.

## Phase 3 — Nix & home-manager

```bash
curl -LO https://raw.githubusercontent.com/mwdavisii/nyx/main/setup/dgx/02-setup-nix.sh
chmod +x 02-setup-nix.sh
./02-setup-nix.sh
```

Steps:

1. Sanity check for `nvidia-smi` (bypass with `--force`).
2. Detect hostname (`castor` / `pollux`), or prompt.
3. Install Nix via the Determinate Systems installer.
4. Clone `~/code/nyx` (SSH → HTTPS fallback).
5. Move collision-prone shell dotfiles to `~/.dotfiles.pre-nyx.<timestamp>/`.
6. First `home-manager switch --flake .#<hostname>`.

After it finishes, log out and log back in (or run `exec zsh -l`) so zsh becomes your login shell.

## Ongoing use

```bash
cd ~/code/nyx
./switch.sh
```

`switch.sh` detects DGX (via `/etc/dgx-release` or `/etc/os-release` grep), runs `01-install-packages.sh --sync` (no prompts, no `apt-get update`), then `home-manager switch --flake .#<hostname>`.

To also pull system-level apt upgrades:

```bash
cd ~/code/nyx
./update.sh
```

`update.sh` adds `sudo apt-get update && sudo apt-get -y upgrade` before the same sync + switch sequence. It does **not** run `apt-get autoremove` (foot-gun on a vendor-tuned box) and does not run `full-upgrade` / `dist-upgrade`.

## What nyx manages vs. what DGX OS manages

| Layer | Owner |
|---|---|
| Kernel, NVIDIA drivers, CUDA, container runtime, `docker*` | DGX OS (NVIDIA apt repos) |
| Core apt packages listed above | `setup/dgx/01-install-packages.sh` |
| Shell, dev tooling, editor, CLI AI, home dotfiles | home-manager (this repo) |
| Anything under `nyx.modules.desktop.*` / `app.*` / `sdr.*` | Not enabled — headless profile |
| `nyx.secrets.*` (agenix) | Not wired for standalone home-manager |
