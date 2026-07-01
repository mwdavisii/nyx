# DGX (Castor & Pollux) Install Guide

Three-phase setup on a pre-installed DGX OS box:
1. **01-install-packages.sh** — validate GB10 hardware, install apt prereqs (including docker + hf CLI for the `gb10_cluster` platform), ensure `/models` exists.
2. **02-setup-nix.sh** — bootstrap Nix and run the first `home-manager switch`.
3. **`gb10_cluster` runbook** (peer's repo) — deploy the vLLM / observability platform.

## Prerequisites

- DGX OS booted, logged in as your user (`mwdavisii`).
- Sudo access.
- Network reachable (`ping -c 3 github.com`).
- Hostname set to `castor` or `pollux` (`sudo hostnamectl set-hostname castor` if not).

## Phase 1 — Vendor state (no-op)

DGX OS is already installed. NVIDIA drivers, CUDA, and `nvidia-container-toolkit` are managed by NVIDIA's apt repos. **Nyx does not touch them.**

Confirm:

```bash
nvidia-smi
```

If this doesn't work, fix the vendor install first — nothing in nyx will help.

**Driver check:** Nyx will hard-fail Phase 2 if `nvidia-smi` reports driver `590.x` — that series has a CUDAGraph deadlock on the GB10 UMA architecture (finding from peer's `gb10_cluster`). Downgrade to `580.x` first.

## Phase 2 — apt prereqs + GB10 validation

```bash
curl -LO https://raw.githubusercontent.com/mwdavisii/nyx/main/setup/dgx/01-install-packages.sh
chmod +x 01-install-packages.sh
./01-install-packages.sh
```

Runs GB10 hardware validation up front (arch, driver, docker nvidia runtime), then installs:

- **Core** (dev/shell prereqs): `git curl ca-certificates xz-utils zsh build-essential libfido2-1 unzip`
- **`gb10_cluster` platform prereqs**: `docker.io docker-buildx docker-compose-v2 pipx`

Also:
- Creates `/models` owned by your user (peer's vLLM containers mount it read-only).
- Installs HuggingFace CLI (`hf`) into `~/.local/bin` via pipx, so peer's `models/download-*.sh` scripts work.

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

## Phase 4 — Application platform (`gb10_cluster`)

Nyx does not manage the LLM inference stack. Peer's `gb10_cluster` repo owns the compose files, vLLM configs, LiteLLM routing, model downloads, and observability.

```bash
cd ~/code
git clone git@github.com:<peer-org>/gb10_cluster.git   # replace with the actual URL
cd gb10_cluster
# Follow docs/RUNBOOK.md from there.
```

Everything nyx installs in Phase 2 (docker, `hf`, `/models`) is what `gb10_cluster` expects to already be present.

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

## Ownership boundaries

| Concern | Owner |
|---|---|
| Kernel, NVIDIA drivers, CUDA, `nvidia-container-toolkit` | DGX OS (NVIDIA apt repos) |
| Docker daemon, `hf` CLI, `/models` mount target | nyx (`setup/dgx/01-install-packages.sh`) |
| Shell, dev tooling, editor, CLI AI, home dotfiles | home-manager (this repo, via `headless.nix`) |
| vLLM containers, LiteLLM, Prometheus/Grafana, model weights | `gb10_cluster` (peer) |
| Anything under `nyx.modules.desktop.*` / `app.*` / `sdr.*` | Not enabled — headless profile |
| `nyx.secrets.*` (agenix) | Not wired for standalone home-manager |
