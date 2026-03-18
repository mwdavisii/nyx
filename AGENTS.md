# Repository Guidelines

## Project Structure & Module Organization
`nyx` is a multi-platform Nix flake for NixOS, macOS, Arch, and Nix-on-Droid. Start at `flake.nix`, then follow `lib/default.nix` into platform and home-manager modules.

- `system/<platform>/hosts/<hostname>/`: host entrypoints such as `default.nix`, `home.nix`, and `system.nix`
- `home/<platform>/` and `home/shared/modules/`: user-level modules grouped by area like `app/`, `dev/`, `shell/`, and `theme/`
- `nix/`: overlays, custom packages, and shared Nix configuration
- `users/`: reusable user profiles
- `setup/`: bootstrap scripts for Arch, macOS, WSL, and virtual installs
- `assets/`: screenshots and static docs assets

## Build, Test, and Development Commands
- `nix develop`: enter the dev shell with `git`, `git-crypt`, and Nix tooling
- `./switch.sh`: detect the current platform and apply the active host configuration
- `nix flake show`: validate flake outputs and catch syntax issues early
- `sudo nixos-rebuild dry-build --flake .#<hostname>`: validate a NixOS host without switching
- `sudo darwin-rebuild switch --flake .`: apply the macOS configuration
- `home-manager switch --show-trace --flake .#<hostname>`: apply an Arch host profile
- `./build-iso.sh` or `./build-vm.sh`: build the special installer/VM outputs

## Coding Style & Naming Conventions
Use 2-space indentation in `.nix` and shell files, matching the existing tree. Keep modules small and place them under the nearest platform or shared category. Name modules `default.nix` inside descriptive directories such as `home/shared/modules/dev/node/` or `system/nixos/modules/system/docker/`. Prefer lowercase hostnames and platform-first paths. If you touch shell scripts, keep them POSIX-friendly where practical and run `shfmt` if available; for Nix, use `nixpkgs-fmt` when reformatting larger changes.

## Testing Guidelines
There is no conventional unit-test suite here. Treat validation as:

- `nix flake show` for every change
- a target-specific dry build before merging
- `./switch.sh` only on the machine that matches the host you changed

When editing bootstrap scripts in `setup/`, document the affected platform and test path in the PR.

## Commit & Pull Request Guidelines
Recent history uses short, direct subjects such as `sketchybar`, `Arch Build Refactor (#86)`, and `Cleanup (#89)`. Keep commit messages brief, present-tense, and scoped to one platform or feature. PRs should include the affected hosts, the validation commands you ran, and screenshots for visible desktop changes such as Hyprland, SketchyBar, or Dock updates.

## Secrets & Safety
Do not commit decrypted secrets or machine-specific credentials. Secrets wiring lives under `secrets/` and `system/shared/secrets/`; if a change depends on private inputs, note the expectation clearly in the PR.
