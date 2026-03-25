# Shell Tools Enhancement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add 11 new shell tool modules, upgrade lf's image preview stack to ueberzugpp, add image.nvim to neovim, wire delta as git pager, and centralize Claude Code settings across machines.

**Architecture:** Each new tool gets its own `home/shared/modules/shell/<tool>/default.nix` following the established `nyx.modules.shell.<tool>.enable` toggle pattern. Three existing modules (lf, nixvim, git) are updated in-place. The ai/claude module is extended to manage `~/.claude/settings.json` and supporting scripts. Host `default.nix` / `home.nix` files for prometheus, L242731, and hephaestus are updated to enable all new modules.

**Tech Stack:** Nix Flakes, home-manager, nixpkgs (all packages confirmed available), ueberzugpp JSON protocol, image.nvim, delta, atuin

---

## Naming Note

Nix attribute names cannot contain hyphens without quoting. Modules with hyphenated names use camelCase for their option path:
- Directory `lm-sensors` → option `nyx.modules.shell.lmSensors`

All other new modules have single-word names and match exactly.

## Validation Commands (run after each task)

```bash
# Arch hosts (fast, no build):
nix build .#homeConfigurations.prometheus.activationPackage --dry-run 2>&1 | tail -5

# NixOS (run after Task 11 only — slow):
nix build .#nixosConfigurations.hephaestus.config.system.build.toplevel --dry-run 2>&1 | tail -5
```

---

## Task 1: Simple package-only modules

Five modules that follow the identical minimal pattern: install one package, no aliases, no platform guards, no shell hooks.

**Files to create:**
- `home/shared/modules/shell/astroterm/default.nix`
- `home/shared/modules/shell/lazygit/default.nix`
- `home/shared/modules/shell/ytermusic/default.nix`
- `home/shared/modules/shell/bottom/default.nix`
- `home/shared/modules/shell/navi/default.nix`

Note: `bottom` installs the `btm` binary (not `bottom`). It differs from `btop` (already in the repo) — btop is C++, bottom is Rust with a different feature set.

- [ ] **Step 1: Create astroterm module**

```nix
# home/shared/modules/shell/astroterm/default.nix
{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.astroterm;
in
{
  options.nyx.modules.shell.astroterm = {
    enable = mkEnableOption "astroterm terminal astronomy viewer";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.astroterm ];
  };
}
```

- [ ] **Step 2: Create lazygit module**

```nix
# home/shared/modules/shell/lazygit/default.nix
{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.lazygit;
in
{
  options.nyx.modules.shell.lazygit = {
    enable = mkEnableOption "lazygit TUI git client";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.lazygit ];
  };
}
```

- [ ] **Step 3: Create ytermusic module**

```nix
# home/shared/modules/shell/ytermusic/default.nix
{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.ytermusic;
in
{
  options.nyx.modules.shell.ytermusic = {
    enable = mkEnableOption "ytermusic YouTube Music TUI with MPRIS support";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.ytermusic ];
  };
}
```

- [ ] **Step 4: Create bottom module**

```nix
# home/shared/modules/shell/bottom/default.nix
{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.bottom;
in
{
  options.nyx.modules.shell.bottom = {
    enable = mkEnableOption "bottom (btm) Rust system monitor";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.bottom ];
  };
}
```

- [ ] **Step 5: Create navi module**

```nix
# home/shared/modules/shell/navi/default.nix
{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.navi;
in
{
  options.nyx.modules.shell.navi = {
    enable = mkEnableOption "navi interactive cheatsheet tool";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.navi ];
  };
}
```

- [ ] **Step 6: Validate**

```bash
nix build .#homeConfigurations.prometheus.activationPackage --dry-run 2>&1 | tail -5
```

Expected: list of would-be-built derivations (or "nothing to build" if cached), no errors.

- [ ] **Step 7: Commit**

```bash
git add home/shared/modules/shell/astroterm \
        home/shared/modules/shell/lazygit \
        home/shared/modules/shell/ytermusic \
        home/shared/modules/shell/bottom \
        home/shared/modules/shell/navi
git commit -m "feat: add astroterm, lazygit, ytermusic, bottom, navi modules"
```

---

## Task 2: Alias modules (dysk, ncdu)

Two modules that install a package and override a standard Unix command with a modern replacement via `programs.zsh.shellAliases`.

**Files to create:**
- `home/shared/modules/shell/dysk/default.nix`
- `home/shared/modules/shell/ncdu/default.nix`

- [ ] **Step 1: Create dysk module**

```nix
# home/shared/modules/shell/dysk/default.nix
{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.dysk;
in
{
  options.nyx.modules.shell.dysk = {
    enable = mkEnableOption "dysk modern df replacement";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.dysk ];
    programs.zsh.shellAliases = {
      df = "dysk";
    };
  };
}
```

- [ ] **Step 2: Create ncdu module**

```nix
# home/shared/modules/shell/ncdu/default.nix
{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.ncdu;
in
{
  options.nyx.modules.shell.ncdu = {
    enable = mkEnableOption "ncdu interactive disk usage navigator";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.ncdu ];
    programs.zsh.shellAliases = {
      du = "ncdu";
    };
  };
}
```

- [ ] **Step 3: Validate**

```bash
nix build .#homeConfigurations.prometheus.activationPackage --dry-run 2>&1 | tail -5
```

- [ ] **Step 4: Commit**

```bash
git add home/shared/modules/shell/dysk home/shared/modules/shell/ncdu
git commit -m "feat: add dysk (df alias) and ncdu (du alias) modules"
```

---

## Task 3: Linux-only modules (lmSensors, nvtop, bandwhich)

Three modules guarded by `mkIf pkgs.stdenv.isLinux` so they silently no-op on Darwin. Note the camelCase option name for `lm-sensors`.

**Files to create:**
- `home/shared/modules/shell/lm-sensors/default.nix`
- `home/shared/modules/shell/nvtop/default.nix`
- `home/shared/modules/shell/bandwhich/default.nix`

- [ ] **Step 1: Create lm-sensors module**

Directory name: `lm-sensors`. Option name: `lmSensors` (camelCase to avoid hyphen in attribute path).

```nix
# home/shared/modules/shell/lm-sensors/default.nix
{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.lmSensors;
in
{
  options.nyx.modules.shell.lmSensors = {
    enable = mkEnableOption "lm-sensors hardware monitoring CLI (Linux only)";
  };

  config = mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    home.packages = [ pkgs.lm_sensors ];
  };
}
```

> **Note:** `sensors` will read data only if kernel modules are loaded at system level.
> NixOS: add `boot.kernelModules = [ "coretemp" "it87" ]` to the host's `system.nix`.
> Arch: kernel modules are typically already loaded by the system.

- [ ] **Step 2: Create nvtop module**

```nix
# home/shared/modules/shell/nvtop/default.nix
{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.nvtop;
in
{
  options.nyx.modules.shell.nvtop = {
    enable = mkEnableOption "nvtop GPU monitor (Linux only)";
  };

  config = mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    home.packages = [ pkgs.nvtop ];
  };
}
```

- [ ] **Step 3: Create bandwhich module**

```nix
# home/shared/modules/shell/bandwhich/default.nix
{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.bandwhich;
in
{
  options.nyx.modules.shell.bandwhich = {
    enable = mkEnableOption "bandwhich network bandwidth monitor by process (Linux only)";
  };

  config = mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    home.packages = [ pkgs.bandwhich ];
  };
}
```

> **Note on capabilities:** `bandwhich` needs `cap_net_raw` to show per-process stats without sudo.
> On Arch: run with `sudo bandwhich` until capabilities are configured.
> On NixOS: add to host's `system.nix`:
> ```nix
> security.wrappers.bandwhich = {
>   source = "${pkgs.bandwhich}/bin/bandwhich";
>   capabilities = "cap_net_raw+ep";
>   owner = "root"; group = "root";
> };
> ```

- [ ] **Step 4: Validate**

```bash
nix build .#homeConfigurations.prometheus.activationPackage --dry-run 2>&1 | tail -5
```

- [ ] **Step 5: Commit**

```bash
git add home/shared/modules/shell/lm-sensors \
        home/shared/modules/shell/nvtop \
        home/shared/modules/shell/bandwhich
git commit -m "feat: add lmSensors, nvtop, bandwhich Linux-only modules"
```

---

## Task 4: atuin module (replaces mcfly)

`atuin` uses `programs.atuin` (not available through the custom zsh module path), so it follows the same pattern as `mcfly` in `home/shared/modules/shell/mclfy/default.nix`: install the package and inject shell init via `nyx.modules.shell.zsh.initExtra`.

**Files to create:**
- `home/shared/modules/shell/atuin/default.nix`

- [ ] **Step 1: Create atuin module**

```nix
# home/shared/modules/shell/atuin/default.nix
{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.atuin;
in
{
  options.nyx.modules.shell.atuin = {
    enable = mkEnableOption "atuin shell history with SQLite backend (replaces mcfly)";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.atuin ];

    nyx.modules.shell.bash.initExtra =
      mkIf config.nyx.modules.shell.bash.enable ''
        eval "$(atuin init bash)"
      '';

    nyx.modules.shell.zsh.initExtra =
      mkIf config.nyx.modules.shell.zsh.enable ''
        eval "$(atuin init zsh)"
      '';
  };
}
```

- [ ] **Step 2: Validate**

```bash
nix build .#homeConfigurations.prometheus.activationPackage --dry-run 2>&1 | tail -5
```

- [ ] **Step 3: Commit**

```bash
git add home/shared/modules/shell/atuin
git commit -m "feat: add atuin shell history module (replaces mcfly)"
```

---

## Task 5: Update lf module — ueberzug → ueberzugpp

The existing lf module installs `ueberzug` (old). Three lf scripts in `home/config/.config/lf/scripts/` use the old bash/FIFO protocol. All must be updated together.

**Files to modify:**
- `home/shared/modules/shell/lf/default.nix`
- `home/config/.config/lf/scripts/lfrun`
- `home/config/.config/lf/scripts/draw`
- `home/config/.config/lf/scripts/clear`

- [ ] **Step 1: Update lf/default.nix**

Replace `ueberzug` with `ueberzugpp`. Add an overrideable `package` option (so Arch hosts can set it to `null` and install via pacman).

```nix
# home/shared/modules/shell/lf/default.nix
{ config, lib, pkgs, ... }:

with lib;
let cfg = config.nyx.modules.shell.lf;
in
{
  options.nyx.modules.shell.lf = {
    enable = mkEnableOption "lf file manager with ueberzugpp image preview";
    ueberzugppPackage = mkOption {
      type = types.nullOr types.package;
      default = pkgs.ueberzugpp;
      description = "ueberzugpp package. Set to null to manage via system package manager (Arch).";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [ lf ]
      ++ optional (cfg.ueberzugppPackage != null) cfg.ueberzugppPackage;

    xdg.configFile."lf" = {
      source = ../../../../config/.config/lf;
      executable = true;
      recursive = true;
    };
  };
}
```

- [ ] **Step 2: Update lfrun script**

Replace the ueberzug daemon line. The new `ueberzugpp layer --parser json` reads newline-delimited JSON from the FIFO.

```bash
#!/usr/bin/env bash
export FIFO_UEBERZUG="/tmp/lf-ueberzug-${PPID}"

function cleanup {
	rm "$FIFO_UEBERZUG" 2>/dev/null
	pkill -KILL -P $$
}

mkfifo "$FIFO_UEBERZUG"
trap cleanup EXIT
ueberzugpp layer --silent --parser json < "$FIFO_UEBERZUG" &

lf $@
```

- [ ] **Step 3: Update draw script**

Replace `declare -p -A` bash protocol with JSON written to the FIFO. Arguments are: `$1`=path, `$2`=x, `$3`=y, `$4`=max_width, `$5`=max_height.

```bash
#!/bin/sh
printf '{"action":"add","identifier":"preview","path":"%s","x":%s,"y":%s,"max_width":%s,"max_height":%s}\n' \
    "$1" "$2" "$3" "$4" "$5" > "$FIFO_UEBERZUG"
```

- [ ] **Step 4: Update clear script**

```bash
#!/bin/sh
printf '{"action":"remove","identifier":"preview"}\n' > "$FIFO_UEBERZUG"
```

- [ ] **Step 5: Validate**

```bash
nix build .#homeConfigurations.prometheus.activationPackage --dry-run 2>&1 | tail -5
```

- [ ] **Step 6: Commit**

```bash
git add home/shared/modules/shell/lf/default.nix \
        home/config/.config/lf/scripts/lfrun \
        home/config/.config/lf/scripts/draw \
        home/config/.config/lf/scripts/clear
git commit -m "feat: upgrade lf image preview from ueberzug to ueberzugpp"
```

---

## Task 6: Update nixvim module — add image.nvim

Add inline image rendering to neovim using `image-nvim` (in `pkgs.vimPlugins`) with ueberzugpp as the backend. `imagemagick` is the required decode dependency.

**Files to modify:**
- `home/shared/modules/shell/nixvim/default.nix`

- [ ] **Step 1: Add image-nvim to extraPlugins, imagemagick to extraPackages, Lua config to extraConfigLua**

In `home/shared/modules/shell/nixvim/default.nix`, make three additions inside `config = mkIf cfg.enable { programs.nixvim = { ... }; }`:

**extraPlugins** — append after the existing list:
```nix
extraPlugins = with pkgs.vimPlugins; [
  neo-tree-nvim
  nui-nvim
  plenary-nvim
  nvim-web-devicons
  telescope-fzf-native-nvim
  image-nvim          # NEW
];
```

**extraPackages** — append after the existing list:
```nix
extraPackages = with pkgs; [
  ripgrep
  fd
  tree-sitter
  wl-clipboard
  imagemagick         # NEW
] ++ treeSitterGrammars;
```

**extraConfigLua** — append to the existing string:
```lua
-- image.nvim: inline image rendering via ueberzugpp
require("image").setup({
  backend = "ueberzug",
  integrations = {
    markdown = {
      enabled = true,
      clear_in_insert_mode = false,
      download_remote_images = true,
    },
  },
  max_width = 100,
  max_height = 12,
  max_height_window_percentage = math.huge,
  max_width_window_percentage = math.huge,
  window_overlap_clear_enabled = false,
})
```

- [ ] **Step 2: Validate**

```bash
nix build .#homeConfigurations.prometheus.activationPackage --dry-run 2>&1 | tail -5
```

- [ ] **Step 3: Commit**

```bash
git add home/shared/modules/shell/nixvim/default.nix
git commit -m "feat: add image.nvim with ueberzugpp backend to nixvim module"
```

---

## Task 7: Update git module — wire delta as pager

`delta` is already in `home.packages` in the git module. It just needs `.gitconfig` entries to activate.

**Files to modify:**
- `home/shared/modules/shell/git/default.nix`

- [ ] **Step 1: Add delta pager config to .gitconfig**

In `home/shared/modules/shell/git/default.nix`, append to the `home.file.".gitconfig".text` heredoc (before the closing `''`):

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

- [ ] **Step 2: Validate**

```bash
nix build .#homeConfigurations.prometheus.activationPackage --dry-run 2>&1 | tail -5
```

- [ ] **Step 3: Commit**

```bash
git add home/shared/modules/shell/git/default.nix
git commit -m "feat: wire delta as git pager with side-by-side diffs"
```

---

## Task 8: Update claude module — centralize settings

Extend `home/shared/modules/ai/claude/default.nix` to manage `~/.claude/settings.json` and the protect-settings hook. The statusline now runs via `bunx -y ccstatusline@latest` (no script to copy — bun fetches it on demand). The module also adds `pkgs.bun` so `bunx` is available on all machines.

**Baseline captured from prometheus on 2026-03-25** (current `~/.claude/settings.json`):
- statusLine command: `bunx -y ccstatusline@latest`
- ccstatusline-managed hooks on PreToolUse (Skill matcher) and UserPromptSubmit
- protect-settings hook merged into PreToolUse alongside ccstatusline

**Files to create:**
- `home/config/.claude/hooks/protect-settings.sh` (new)

**Files to modify:**
- `home/shared/modules/ai/claude/default.nix`

- [ ] **Step 1: Create protect-settings.sh hook**

```bash
mkdir -p home/config/.claude/hooks
```

Write `home/config/.claude/hooks/protect-settings.sh`:

```bash
#!/bin/bash
# Block writes to Nix-managed settings.json and redirect to source of truth
input=$(cat)
file=$(echo "$input" | jq -r '.file_path // .old_file_path // ""' 2>/dev/null)
if [[ "$file" == *"/.claude/settings.json" ]]; then
  echo "settings.json is managed by Nix." >&2
  echo "Propose a change to home/shared/modules/ai/claude/default.nix instead." >&2
  exit 2
fi
```

Make it executable: `chmod +x home/config/.claude/hooks/protect-settings.sh`

- [ ] **Step 2: Update claude module**

Replace the contents of `home/shared/modules/ai/claude/default.nix`:

```nix
{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.ai.claude;

  defaultSettings = {
    statusLine = {
      type = "command";
      command = "bunx -y ccstatusline@latest";
      padding = 0;
    };
    enabledPlugins = {
      "clangd-lsp@claude-plugins-official" = true;
      "superpowers@claude-plugins-official" = true;
      "code-review@claude-plugins-official" = true;
      "playwright@claude-plugins-official" = true;
      "security-guidance@claude-plugins-official" = true;
      "claude-md-management@claude-plugins-official" = true;
      "claude-code-setup@claude-plugins-official" = true;
      "agent-sdk-dev@claude-plugins-official" = true;
      "skill-creator@claude-plugins-official" = true;
      "discord@claude-plugins-official" = true;
    };
    skipDangerousModePermissionPrompt = true;
    hooks = {
      PreToolUse = [
        {
          "_tag" = "ccstatusline-managed";
          matcher = "Skill";
          hooks = [
            {
              type = "command";
              command = "bunx -y ccstatusline@latest --hook";
            }
          ];
        }
        {
          matcher = "Write|Edit";
          hooks = [
            {
              type = "command";
              command = "~/.claude/hooks/protect-settings.sh";
            }
          ];
        }
      ];
      UserPromptSubmit = [
        {
          "_tag" = "ccstatusline-managed";
          hooks = [
            {
              type = "command";
              command = "bunx -y ccstatusline@latest --hook";
            }
          ];
        }
      ];
    };
  };
in
{
  options.nyx.modules.ai.claude = {
    enable = mkEnableOption "Claude Code";

    package = mkOption {
      type = types.nullOr types.package;
      default = pkgs.claude-code;
      description = "The claude-code package. Set to null to manage via AUR or system package manager.";
    };

    bunPackage = mkOption {
      type = types.nullOr types.package;
      default = pkgs.bun;
      description = "Bun runtime for ccstatusline. Set to null if managing bun via system package manager.";
    };

    settings = mkOption {
      type = types.attrs;
      default = defaultSettings;
      description = "Contents of ~/.claude/settings.json. Shallow-merged with defaults on top-level keys.";
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      optional (cfg.package != null) cfg.package
      ++ optional (cfg.bunPackage != null) cfg.bunPackage;

    home.file.".claude/settings.json".text =
      builtins.toJSON (defaultSettings // cfg.settings);

    home.file.".claude/hooks/protect-settings.sh" = {
      source = ../../../../config/.claude/hooks/protect-settings.sh;
      executable = true;
    };
  };
}
```

- [ ] **Step 3: Validate**

```bash
nix build .#homeConfigurations.prometheus.activationPackage --dry-run 2>&1 | tail -5
```

- [ ] **Step 4: Commit**

```bash
git add home/config/.claude/ home/shared/modules/ai/claude/default.nix
git commit -m "feat: centralize Claude Code settings (ccstatusline + protect-settings hook)"
```

---

## Task 9: Enable all new modules on prometheus

**File to modify:** `system/arch/hosts/prometheus/default.nix`

- [ ] **Step 1: Add new module toggles to the shell block**

In `system/arch/hosts/prometheus/default.nix`, inside the `nyx.modules.shell = { ... };` block, add after the existing entries:

```nix
    # New shell tools
    astroterm.enable = true;
    atuin.enable = true;
    bandwhich.enable = true;
    bottom.enable = true;
    dysk.enable = true;
    lazygit.enable = true;
    lmSensors.enable = true;
    mcfly.enable = false;        # replaced by atuin
    navi.enable = true;
    ncdu.enable = true;
    nvtop.enable = true;
    ytermusic.enable = true;
    # lf: override ueberzugpp to null — install via pacman
    lf = {
      enable = true;             # already set above; keep, add ueberzugppPackage
      ueberzugppPackage = null;
    };
```

- [ ] **Step 2: Validate**

```bash
nix build .#homeConfigurations.prometheus.activationPackage --dry-run 2>&1 | tail -5
```

- [ ] **Step 3: Commit**

```bash
git add system/arch/hosts/prometheus/default.nix
git commit -m "feat: enable new shell tools on prometheus"
```

---

## Task 10: Enable all new modules on L242731

**File to modify:** `system/arch/hosts/L242731/default.nix`

- [ ] **Step 1: Add new module toggles**

Same additions as Task 9 (identical Arch host, same toolset needed):

```nix
    # New shell tools
    astroterm.enable = true;
    atuin.enable = true;
    bandwhich.enable = true;
    bottom.enable = true;
    dysk.enable = true;
    lazygit.enable = true;
    lmSensors.enable = true;
    mcfly.enable = false;        # replaced by atuin
    navi.enable = true;
    ncdu.enable = true;
    nvtop.enable = true;
    ytermusic.enable = true;
    lf = {
      enable = true;
      ueberzugppPackage = null;
    };
```

- [ ] **Step 2: Validate**

```bash
nix build .#homeConfigurations.L242731.activationPackage --dry-run 2>&1 | tail -5
```

- [ ] **Step 3: Commit**

```bash
git add system/arch/hosts/L242731/default.nix
git commit -m "feat: enable new shell tools on L242731"
```

---

## Task 11: Enable all new modules on hephaestus

hephaestus is NixOS; shell modules are in `system/nixos/hosts/hephaestus/home.nix`. It can receive Nix-managed packages (no `package = null` needed). Skip lm-sensors, nvtop, bandwhich if not desired on the desktop, but all are enabled here per spec.

**File to modify:** `system/nixos/hosts/hephaestus/home.nix`

- [ ] **Step 1: Add new module toggles to the shell block**

In `system/nixos/hosts/hephaestus/home.nix`, inside `nyx.modules.shell = { ... };`, add:

```nix
    # New shell tools
    astroterm.enable = true;
    atuin.enable = true;
    bandwhich.enable = true;
    bottom.enable = true;
    dysk.enable = true;
    lazygit.enable = true;
    lmSensors.enable = true;
    mcfly.enable = false;        # replaced by atuin
    navi.enable = true;
    ncdu.enable = true;
    nvtop.enable = true;
    ytermusic.enable = true;
    # lf already enabled; no package override needed on NixOS
```

- [ ] **Step 2: Validate (NixOS — may take a minute)**

```bash
nix build .#nixosConfigurations.hephaestus.config.system.build.toplevel --dry-run 2>&1 | tail -5
```

- [ ] **Step 3: Commit**

```bash
git add system/nixos/hosts/hephaestus/home.nix
git commit -m "feat: enable new shell tools on hephaestus"
```

---

## Post-Implementation Notes

**lm-sensors on NixOS (hephaestus):** If `sensors` shows no data, add to `system/nixos/hosts/hephaestus/system.nix`:
```nix
boot.kernelModules = [ "coretemp" ];
```

**bandwhich on NixOS:** Runs with sudo by default. To enable without sudo, add to `system/nixos/hosts/hephaestus/system.nix`:
```nix
security.wrappers.bandwhich = {
  source = "${pkgs.bandwhich}/bin/bandwhich";
  capabilities = "cap_net_raw+ep";
  owner = "root";
  group = "root";
};
```

**atuin:** First run: `atuin import auto` to import existing shell history. Note: hephaestus has `zsh.enable = false`, so atuin's zsh hook will not activate there — it will only initialize in bash (which is enabled). History sync between machines still works via atuin's sync backend.

**ytermusic:** First run requires a Google account login flow in the terminal. After auth, `playerctl play-pause/next/prev` bindings work immediately.

**image.nvim:** Verify with `:lua require("image").setup_config()` in neovim after rebuild. Images render in markdown previews and neo-tree.

**Claude settings.json:** After first `home-manager switch`, `~/.claude/settings.json` becomes a read-only Nix store symlink. The protect-settings hook activates automatically. To change settings (plugins, hooks, statusline), edit `home/shared/modules/ai/claude/default.nix` and rebuild. The ccstatusline is fetched on demand by `bunx` — no local script needed. On Arch hosts where bun is already installed via pacman, set `bunPackage = null` in the host config to avoid a duplicate install.
