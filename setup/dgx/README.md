# DGX (Castor & Pollux) Install Guide

Three-phase setup on a pre-installed DGX OS box:
1. **01-install-packages.sh** — validate GB10 hardware, install apt prereqs (docker + hf CLI), ensure `/models` exists.
2. **02-setup-nix.sh** — bootstrap Nix and run the first `home-manager switch`.
3. **vLLM containers** — run `timothystewart6/vllm-gb10` against your model weights, exposed to the LAN. The control plane (LiteLLM, Langfuse, observability, etc.) lives elsewhere.

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
- **vLLM prereqs**: `docker.io docker-buildx docker-compose-v2 pipx`

Also:
- Creates `/models` owned by your user (the vLLM container mounts it read-only).
- Installs HuggingFace CLI (`hf`) into `~/.local/bin` via pipx for downloading model weights.

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

## Phase 4 — vLLM (application layer, out of nyx scope)

Nyx does not manage the inference stack. Everything nyx installs in Phase 2 (docker, `hf`, `/models`) is what a vLLM container needs to already be present.

The image that works on GB10's aarch64 + sm_121 (Blackwell) is `timothystewart6/vllm-gb10:latest` — a known-good combination of vLLM + PyTorch + CUDA + flash-attn compiled for this architecture, courtesy of a peer's work. Reusing that image is what makes vLLM boot on GB10 without rebuilding the entire stack from source.

Download a model:

```bash
hf download nvidia/NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4 \
    --local-dir /models/nemotron-super-120b-a12b-nvfp4
```

Minimal per-host compose file (write once, per box):

```yaml
# ~/vllm.yml
services:
  vllm:
    image: timothystewart6/vllm-gb10:latest
    shm_size: '4g'
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    volumes:
      - /models/<model-dir>:/model:ro
    ports:
      - "0.0.0.0:8001:8000"
    command: >-
      vllm serve /model
      --served-model-name <name>
      --enforce-eager --dtype auto --max-model-len 32768
      --gpu-memory-utilization 0.85
      --enable-prefix-caching --trust-remote-code
      --kv-cache-dtype fp8
    restart: unless-stopped
```

Run: `docker compose -f ~/vllm.yml up -d`. Point your LAN LiteLLM (running in PVE) at `http://<host>:8001/v1`.

The LiteLLM, Langfuse, Prometheus, Grafana, Caddy, Open WebUI, n8n, and Postgres containers you may have seen in a colleague's `gb10_cluster` repo — those are a self-contained platform stack. **You already run those services elsewhere; skip them.**

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
| vLLM container + model weights | You (hand-rolled compose file, see Phase 4) |
| LiteLLM, Langfuse, Prometheus, Grafana | Already running in your PVE lab |
| Anything under `nyx.modules.desktop.*` / `app.*` / `sdr.*` | Not enabled — headless profile |
| `nyx.secrets.*` (agenix) | Not wired for standalone home-manager |
