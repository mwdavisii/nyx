---
name: nyx-add-host
description: Add a new host to the Nyx flakes configuration. Use when the user wants to configure a new machine, add a new system, or onboard a new host to the repo.
argument-hint: [hostname] [platform]
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash(mkdir -p *)
---

The user wants to add a new host to the Nyx configuration. Ask for:
1. **Hostname** — the machine's hostname (e.g., `kronos`)
2. **Platform** — `nixos`, `darwin`, `arch`, `wsl`, or `droid`
3. **Username** — which user profile to use (`mwdavisii`, `mdavis67`, `nixos`, or `droid`)
4. **System arch** — usually `x86_64-linux`, `aarch64-linux`, or `aarch64-darwin`

Then follow the steps for the chosen platform.

---

## NixOS host

### 1. Create host directory
```
system/nixos/hosts/<hostname>/
├── default.nix   # nyx module toggles + imports system.nix
├── system.nix    # networking, services, hardware imports
├── home.nix      # user home-manager config
└── hardware.nix  # hardware-configuration.nix (from nixos-generate-config)
```

**`default.nix` template:**
```nix
{ config, pkgs, ... }:
{
  imports = [ ./system.nix ];
  nyx = {
    modules = {
      user.home = ./home.nix;
      system = {
        garbagecollection.enable = true;
        # Add more system modules here
      };
    };
    profiles = {
      desktop.enable = true;  # or remove if server
    };
  };
}
```

**`system.nix` template:**
```nix
{ config, lib, pkgs, modulesPath, hostName, ... }:
{
  imports = [ ./hardware.nix ];
  config = {
    networking.networkmanager.enable = true;
    services.openssh.enable = true;
  };
}
```

**`home.nix` template:**
```nix
{ config, pkgs, lib, inputs, ... }:
{
  nyx.modules = {
    shell = {
      git.enable = true;
      starship.enable = true;
      zsh.enable = true;
    };
  };
}
```

### 2. Register in flake.nix

In the `nixosConfigurations` block:
```nix
<hostname> = { hostname = "<hostname>"; user = "<username>"; buildTarget = "nixos"; };
# For non-x86_64: add system = "aarch64-linux";
```

---

## Darwin host

### 1. Create host directory
```
system/darwin/hosts/<hostname>/
├── default.nix    # nyx module toggles + imports system.nix
├── system.nix     # homebrew, macOS defaults
├── home.nix       # user home-manager config
└── dockConfig.nix # Dock layout (optional)
```

**`default.nix` template:**
```nix
{ config, pkgs, ... }:
{
  imports = [ ./system.nix ];
  nyx = {
    modules = {
      user.home = ./home.nix;
      system.yabai.enable = true;
    };
    secrets = {
      userSSHKeys.enable = true;
      userPGPKeys.enable = true;
    };
    profiles = {
      macbook.enable = true;
    };
  };
}
```

### 2. Register in flake.nix

In the `darwinConfigurations` block:
```nix
<hostname> = { system = "aarch64-darwin"; user = "<username>"; buildTarget = "darwin"; };
# For Intel: system = "x86_64-darwin"
```

---

## Arch Linux host (standalone home-manager)

### 1. Create host directory
```
system/arch/hosts/<hostname>/
└── default.nix   # everything in one file
```

**`default.nix` template:**
```nix
{ config, pkgs, lib, inputs, ... }:
{
  programs.home-manager.enable = true;

  home = {
    stateVersion = "26.05";
    packages = with pkgs; [ ];
  };

  nyx.modules = {
    shell = {
      git.enable = true;
      zsh.enable = true;
      starship.enable = true;
    };
  };
}
```

### 2. Register in flake.nix

In the `homeConfigurations` block (uses `mkArchConfiguration`):
```nix
<hostname> = { user = "<username>"; system = "x86_64-linux"; };
```

---

## WSL host

Same as NixOS but use `buildTarget = "wsl"` in flake.nix. The nixos-wsl module is automatically included.

---

## After adding the host

1. Validate: `nix flake show`
2. Build (without switching): `nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel`
3. Apply: `sudo nixos-rebuild switch --show-trace --flake .#<hostname>`

For hardware.nix on a new NixOS machine, run:
```bash
sudo nixos-generate-config --show-hardware-config > system/nixos/hosts/<hostname>/hardware.nix
```
