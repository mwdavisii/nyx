# Shell Tools Enhancement — Design Spec

**Date:** 2026-03-25
**Branch:** shell-tools
**Status:** Approved, ready for implementation

---

## Overview

Add a curated set of modern terminal tools to the Nyx configuration, upgrade the existing ueberzug image preview stack to ueberzugpp, enhance neovim with inline image rendering, centralize Claude Code settings across machines, and wire up a YouTube Music TUI with playerctl integration.

---

## Approach

**One module per tool** (Option A) — each new tool gets `home/shared/modules/shell/<tool>/default.nix` with a `nyx.modules.shell.<tool>.enable` toggle. Two exceptions:
- **ueberzugpp** lives inside the `lf` module (lf's scripts already depend on it)
- **image.nvim** lives inside the `nixvim` module
- **delta** is already installed in the `git` module — only needs `.gitconfig` wiring
- **Claude settings** go in the existing `ai/claude` module

---

## Module Inventory

### New Standalone Shell Modules

| Module | Package | Alias | Platform guard | Notes |
|---|---|---|---|---|
| `shell/dysk` | `pkgs.dysk` | `df = "dysk"` | none | Rust, cross-platform |
| `shell/lm-sensors` | `pkgs.lm_sensors` | none | `isLinux` | Kernel modules loaded at system level; home module provides CLI |
| `shell/astroterm` | `pkgs.astroterm` | none | none | Pure TUI, no display deps |
| `shell/ytermusic` | `pkgs.ytermusic` | none | none | Registers MPRIS; existing Hyprland playerctl keybindings work automatically |
| `shell/lazygit` | `pkgs.lazygit` | none | none | TUI git client |
| `shell/nvtop` | `pkgs.nvtop` | none | `isLinux` | AMD GPU monitor for hephaestus/prometheus |
| `shell/bandwhich` | `pkgs.bandwhich` | none | `isLinux` | Needs `cap_net_raw`; on NixOS handled via `security.wrappers`, on Arch may need sudo |
| `shell/bottom` | `pkgs.bottom` | none | none | Unified system monitor (`btm` binary), cross-platform |
| `shell/ncdu` | `pkgs.ncdu` | `du = "ncdu"` | none | Interactive disk usage TUI |
| `shell/navi` | `pkgs.navi` | none | none | Interactive cheatsheet tool |
| `shell/atuin` | via `programs.atuin` | none | none | Replaces mcfly; set `mcfly.enable = false` per-host when enabling |

### Updates to Existing Modules

#### `shell/lf` — ueberzug → ueberzugpp

Replace `ueberzug` with `pkgs.ueberzugpp`. Add a `package` override option (default `pkgs.ueberzugpp`, set to `null` on Arch hosts to defer to pacman — matching the pattern used for kitty, alacritty, etc.).

Update three scripts in `home/config/.config/lf/scripts/`:

**`lfrun`** — change daemon invocation:
```bash
# old (bash/FIFO protocol)
tail --follow "$FIFO_UEBERZUG" | ueberzug layer --silent --parser bash &
# new (JSON/socket protocol)
ueberzugpp layer --silent --parser json < "$FIFO_UEBERZUG" &
```

**`draw`** — update to write JSON add command to FIFO instead of bash `declare -p -A`.

**`clear`** — update to write JSON remove command to FIFO instead of bash `declare -p -A`.

#### `shell/nixvim` — image.nvim

Add to `extraPlugins`:
```nix
pkgs.vimPlugins.image-nvim
```

Add to `extraPackages`:
```nix
pkgs.imagemagick
```

Configure in `extraConfigLua` with ueberzugpp backend. Enables inline image rendering in neovim buffers (markdown, file explorers). Works with all three configured terminals (kitty, alacritty, wezterm).

#### `shell/git` — wire delta as pager

Delta is already in `home.packages`. Add to `.gitconfig`:
```ini
[core]
  pager = delta
[interactive]
  diffFilter = delta --color-only
[delta]
  navigate = true
  side-by-side = true
  line-numbers = true
```

#### `ai/claude` — centralize settings

Extend module to write two managed files:

**`home.file.".claude/settings.json"`** — rendered via `builtins.toJSON`. Baseline captured from prometheus on 2026-03-25:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  },
  "enabledPlugins": {
    "clangd-lsp@claude-plugins-official": true,
    "superpowers@claude-plugins-official": true,
    "code-review@claude-plugins-official": true,
    "playwright@claude-plugins-official": true,
    "security-guidance@claude-plugins-official": true,
    "claude-md-management@claude-plugins-official": true,
    "claude-code-setup@claude-plugins-official": true,
    "agent-sdk-dev@claude-plugins-official": true,
    "skill-creator@claude-plugins-official": true,
    "discord@claude-plugins-official": true
  },
  "skipDangerousModePermissionPrompt": true,
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/protect-settings.sh"
          }
        ]
      }
    ]
  }
}
```

**`home.file.".claude/hooks/protect-settings.sh"`** — stored at `home/config/.claude/hooks/protect-settings.sh`, symlinked with `executable = true`:

```bash
#!/bin/bash
# Block writes to Nix-managed settings.json
input=$(cat)
file=$(echo "$input" | jq -r '.file_path // .old_file_path // ""' 2>/dev/null)
if [[ "$file" == *"/.claude/settings.json" ]]; then
  echo "settings.json is managed by Nix." >&2
  echo "Propose a change to home/shared/modules/ai/claude/default.nix instead." >&2
  exit 2
fi
```

Exit code 2 blocks the tool call and shows the message. Requires `jq` (already in your git module's packages).

**`home.file.".claude/statusline.sh"`** — the full cc-statusline v1.4.0 script stored at `home/config/.claude/statusline.sh`, symlinked with `executable = true`. Shows: directory, git branch, model, context remaining %, cost, tokens.

Module options exposed for per-machine overrides:
- `enabledPlugins` — attrset, baseline above, override per host to add/remove
- `skipDangerousModePermissionPrompt` — bool, default `true`
- `statusLine` — attrset, override if a host needs a different script
- `hooks` — the protect-settings hook is included by default; extend per host if needed

**Caveat:** `home.file` creates a read-only Nix store symlink. In-app changes to settings (e.g. toggling theme in UI) won't persist across `home-manager switch`. Nix config is the source of truth. The `protect-settings.sh` hook enforces this by blocking any Claude tool call that tries to write to `settings.json` and redirecting to the Nix module instead.

---

## Arch Host Handling

On `prometheus` and `L242731`, add to each host's `default.nix`:

```nix
nyx.modules.shell = {
  dysk.enable = true;
  lm-sensors.enable = true;
  astroterm.enable = true;
  ytermusic.enable = true;
  lazygit.enable = true;
  nvtop.enable = true;
  bandwhich.enable = true;
  bottom.enable = true;
  ncdu.enable = true;
  navi.enable = true;
  atuin.enable = true;
  mcfly.enable = false;  # replaced by atuin
  # lf gets ueberzugpp package = null (defer to pacman)
};
```

ueberzugpp, dysk, lm-sensors, astroterm, ytermusic, lazygit, bottom, ncdu, navi, atuin are all Rust TUI apps with no display dependencies — Nix-managed is fine on Arch. nvtop and bandwhich are Linux-only anyway.

---

## Out of Scope (Deferred)

- **aerc / Outlook email** — needs its own OAuth2/Exchange auth setup session
- **Microsoft Teams terminal client** — no viable option exists

---

## Safety Notes

All tools are open-source, well-maintained, and available in nixpkgs:
- `dysk`, `astroterm`, `ytermusic`, `lazygit`, `bottom`, `ncdu`, `navi`, `atuin` — pure Rust TUI tools, no elevated privileges needed
- `lm-sensors`, `nvtop` — read-only hardware monitoring, Linux-only
- `bandwhich` — needs `cap_net_raw` for process-level network stats; handled declaratively via NixOS `security.wrappers`, noted for Arch
- `ueberzugpp` — X11/Wayland image rendering, no OpenGL dependency (unlike gaming packages)
- `image.nvim` — neovim plugin, uses imagemagick for decoding
