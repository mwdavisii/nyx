---
name: nyx-update
description: Update Nyx flake inputs and rebuild. Use when updating nixpkgs, home-manager, hyprland, or other flake inputs to get new package versions or fixes.
argument-hint: [input-name or "all"]
user-invocable: true
allowed-tools: Bash(nix flake update *), Bash(nix flake show), Bash(nix build *), Bash(./switch.sh), Bash(sudo nixos-rebuild *), Bash(sudo darwin-rebuild *), Bash(home-manager switch *), Bash(git diff *), Bash(git add *), Bash(git commit *)
---

The user wants to update their Nyx flake inputs.

## Update options

### Update all inputs
```bash
nix flake update
```

### Update a single input
```bash
nix flake update nixpkgs
nix flake update home-manager
nix flake update hyprland
nix flake update nixvim
# etc.
```

## Common inputs and what they affect

| Input | What updates |
|---|---|
| `nixpkgs` | All system and home packages |
| `home-manager` | Home-manager itself |
| `hyprland` | Hyprland compositor and plugins |
| `nixvim` | Neovim configuration framework |
| `agenix` | Secret management tool |
| `darwin` | nix-darwin (macOS) |
| `nix-homebrew` | Homebrew integration |
| `nixos-wsl` | WSL2 integration |
| `nix-on-droid` | Android Nix |
| `kmonad` | Keyboard remapping |
| `disko` | Disk partitioning |

## Recommended update workflow

1. **Update inputs:**
   ```bash
   nix flake update
   # or for a single input:
   nix flake update nixpkgs
   ```

2. **Check what changed:**
   ```bash
   git diff flake.lock
   ```

3. **Dry build to catch breakage before switching:**
   ```bash
   sudo nixos-rebuild dry-build --flake .#<hostname>
   # or for Darwin:
   sudo darwin-rebuild dry-build --flake .
   ```

4. **Apply if build succeeds:**
   ```bash
   ./switch.sh
   ```

5. **Commit the lock file update:**
   ```bash
   git add flake.lock
   git commit -m "flake: update inputs"
   ```

## If something breaks after update

- Check if the issue is in `nixpkgs` vs a specific input by updating selectively
- Use `--show-trace` to get full error context
- Roll back to the previous lock file: `git checkout flake.lock` then rebuild
- Check upstream changelogs: most inputs use GitHub releases or commit history

## Checking current input versions

```bash
nix flake metadata
```

This shows all inputs and their current resolved revisions.
