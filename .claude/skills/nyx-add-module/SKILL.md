---
name: nyx-add-module
description: Create a new nyx.* toggle module for the Nyx configuration. Use when adding a new feature, service, or application as a reusable toggleable module.
argument-hint: [module-name] [category] [scope]
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash(mkdir -p *)
---

The user wants to create a new `nyx.*` module. Ask for:
1. **Module name** — e.g., `tailscale`, `vscode`, `discord`
2. **Category** — the namespace group:
   - **System modules** (NixOS/Darwin system-level): `system/shared/modules/system/<name>/`
   - **Home modules** by type:
     - `app/` — GUI applications
     - `dev/` — development tools
     - `shell/` — shell/CLI tools
     - `theme/` — theming
     - `ai/` — AI tools
     - `gaming/` — gaming
     - `desktop/` — desktop environment components
3. **Scope** — system-level or home-manager level

---

## Module file location

| Category | Path | Toggle namespace |
|---|---|---|
| System service | `system/shared/modules/system/<name>/default.nix` | `nyx.modules.system.<name>.enable` |
| Home app | `home/shared/modules/app/<name>/default.nix` | `nyx.modules.app.<name>.enable` |
| Home dev tool | `home/shared/modules/dev/<name>/default.nix` | `nyx.modules.dev.<name>.enable` |
| Home shell tool | `home/shared/modules/shell/<name>/default.nix` | `nyx.modules.shell.<name>.enable` |
| Home desktop | `home/shared/modules/desktop/<name>/default.nix` | `nyx.modules.desktop.<name>.enable` |

Modules are **auto-discovered** — any subdirectory under `modules/` is automatically imported. No registration needed.

---

## Simple module template (enable only)

```nix
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.nyx.modules.<category>.<name>;
in
{
  options.nyx.modules.<category>.<name> = {
    enable = mkEnableOption "<name>";
  };

  config = mkIf cfg.enable {
    # Your configuration here
    # home.packages = with pkgs; [ <name> ];
    # programs.<name>.enable = true;
  };
}
```

---

## Module template with extra options

```nix
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.nyx.modules.<category>.<name>;
in
{
  options.nyx.modules.<category>.<name> = {
    enable = mkEnableOption "<name>";

    package = mkOption {
      type = types.nullOr types.package;
      default = pkgs.<name>;
      description = "The <name> package to use. Set to null to skip package install.";
    };

    someOption = mkOption {
      type = types.bool;
      default = false;
      description = "Description of what this option does.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = mkIf (cfg.package != null) [ cfg.package ];
    # use cfg.someOption as needed
  };
}
```

---

## System-level module template (NixOS services)

```nix
{ config, lib, pkgs, modulesPath, hostName, ... }:
with lib;
let cfg = config.nyx.modules.system.<name>;
in
{
  options.nyx.modules.system.<name> = {
    enable = mkEnableOption "<name>";
  };

  config = mkIf cfg.enable {
    services.<name>.enable = true;
    environment.systemPackages = with pkgs; [ <name> ];
  };
}
```

---

## Using the new module in a host

In any host's `default.nix` (NixOS/Darwin) or `default.nix` (Arch):

```nix
nyx.modules.<category>.<name>.enable = true;
# or with options:
nyx.modules.<category>.<name> = {
  enable = true;
  someOption = true;
};
```

---

## Tips

- Keep modules focused — one service/app per module
- Use `mkEnableOption` for the main toggle (generates a bool option with `enable` name and proper description)
- Reference existing modules for patterns — e.g., `home/shared/modules/shell/starship/default.nix` (simple), `home/shared/modules/shell/git/default.nix` (with sub-options)
- For platform-specific behavior, use `pkgs.stdenv.isDarwin` / `pkgs.stdenv.isLinux`
- Config dotfiles can be placed in `home/config/.config/<name>/` and referenced via `xdg.configFile`
