# hestia — standalone home-manager host on an agent-run Mac

**Date:** 2026-08-26
**Status:** Approved design, pending implementation

## Context

`Mikes-MacBook-Pro-2` is an M1 MacBook (macOS 26.5.2, aarch64, user `mwdavisii`)
that has run for months without a managed terminal environment. It is operated
by **Hermes**, which runs five agent gateways (`cato`, `jarvis`, `mycroft`,
`pennyworth`, `simpleton`) plus a dashboard under launchd. The Google account
signed in here is a household account owned by the agent, not the user's
primary identity.

The goal is to bring this machine into nyx as a host and restore the user's
terminal environment — without disturbing the running agent and without
introducing any of the user's secrets to the machine.

### Hard constraints

1. **No secrets.** Nothing from agenix reaches this host. The only credential
   that lives here is the existing `~/.ssh/id_ed25519`, which nyx does not
   manage.
2. **Do not break Hermes.** Five gateways, a dashboard, and MCP servers are
   live. Homebrew is load-bearing: `/opt/homebrew/bin/codegraph` and
   `/opt/homebrew/Cellar/python@3.14` back the agent's MCP servers.
3. **Nix is not installed.** This is a from-scratch bootstrap.

## Decisions

| Decision | Choice |
|---|---|
| Ownership scope | User-level only (standalone home-manager) |
| Host name | `hestia`, and rename the machine to match |
| Capabilities | Terminal core + terminal emulator configs |
| AI modules | None — Claude Code stays native and self-updating |
| Gemini | Removed repo-wide, as its own commit |
| Secrets | Zero; agenix not imported at all |

## Non-goals

- No nix-darwin. No `darwin-rebuild`, no declarative Homebrew, no managed
  dock, no `system.defaults`. Homebrew stays hand-managed exactly as today.
- No dev toolchains (rust/go/python/node/k8s/terraform/cloud CLIs). This
  removes any chance of nix shadowing the Homebrew Python and `codegraph`
  binary the agent depends on.
- No `nyx.modules.shell.gnupg`. The workm1 host enables it and it writes
  `~/.gnupg`; this machine should not carry the user's PGP material.
- No agenix, no `nyx.secrets.*`.

## Architecture

### 1. New builder: `mkStandaloneDarwinConfiguration`

The repo has no standalone home-manager path for Darwin — `homeConfigurations`
routes exclusively through `mkStandaloneLinuxConfiguration`, which imports
Hyprland and `home/arch/modules`.

Add `mkStandaloneDarwinConfiguration` to `lib/default.nix`, mirroring the Linux
builder with three differences: no Hyprland, **no agenix**, and
`homeDirectory = "/Users/${userConf.userName}"`.

```nix
mkStandaloneDarwinConfiguration = name: {
  config ? name,
  user,
  system ? "aarch64-darwin",
  hostsDir ? ../system/darwin/home,
}:
  let
    pkgs = inputs.self.legacyPackages."${system}";
    userConf = import (strToFile user ../users);
    homeDirectory = "/Users/${userConf.userName}";
    userOptions = strToPath config hostsDir;
  in
  nameValuePair name (
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        inputs.nixvim.homeModules.nixvim
        (import ../home/darwin/modules)
        (import userOptions)
        mkCommonHomeConfig
        (mkStandaloneHomeConfig { inherit system; })
        {
          home.homeDirectory = homeDirectory;
          home.username = userConf.userName;
        }
      ];
      extraSpecialArgs =
        let
          self = inputs.self;
          user = userConf;
        in
        { inherit inputs name self system user; };
    }
  );
```

Omitting `agenix.homeManagerModules.default` is deliberate and load-bearing: it
makes "no secrets on this host" a structural property rather than a matter of
leaving toggles off. It also sidesteps the `age.identityPaths` value hardcoded
in `commonModules` (`/home/<user>/.ssh/id_rsa` — a Linux path, and this machine
has an ed25519 key anyway).

`home/darwin/modules/default.nix` already imports `../../shared/modules`, the
same way `home/arch/modules` does, so importing `home/darwin/modules` pulls in
the full shared module set. No change needed there.

### 2. Host tree

New directory `system/darwin/home/hestia/` holding `default.nix`, which is a
home-manager module in the same shape as `system/arch/hosts/prometheus/`.

This deliberately sits apart from `system/darwin/hosts/`, which holds
system-level nix-darwin configs. Mixing user-level and system-level host trees
under one directory would make it easy to enable a system option on a host that
has no system config.

### 3. Flake wiring

`homeConfigurations` becomes the union of the two builders:

```nix
homeConfigurations =
  (mapAttrs' lib.mkStandaloneLinuxConfiguration {
    L242731 = { ... };
    prometheus = { ... };
    castor = { ... };
    pollux = { ... };
  })
  // (mapAttrs' lib.mkStandaloneDarwinConfiguration {
    hestia = { user = "mwdavisii"; system = "aarch64-darwin"; };
  });
```

The existing `hometop` CI aggregation in `flake.nix` walks
`builtins.attrNames inputs.self.homeConfigurations`, so `hestia` is picked up
for `activationPackage` builds automatically.

## Capabilities

Enabled in `system/darwin/home/hestia/default.nix`:

**Terminal core** — `zsh`, `bash`, `starship`, `tmux`, `zellij`, `git` (with
`signing.signByDefault = false`), `direnv`, `fzf`, `eza`, `bat`, `atuin`,
`zoxide`, `lazygit`, `jq`, `yq`, `bottom`, `dysk`, `ncdu`, `navi`, `glow`,
`lf`, `ranger`, `fastfetch`, `xdg`, `networking`, `openssl`, `nixvim`.

**Packages** — `ripgrep`, `fd`, `sd`, `dua`, `just`, `comma`, `wget`, `vim`.

**Emulator configs** — `wezterm`, `kitty`, `alacritty`, `iterm2`, each with
`package = null` where the option exists. Nix writes the config; the
applications remain Homebrew-installed, matching how `mwdavis-workm1` handles
them.

Explicitly **not** enabled: every `nyx.secrets.*`, all `nyx.modules.ai.*`, all
`nyx.modules.dev.*`, `shell.gnupg`, and `desktop.*` (aerospace, sketchybar,
karabiner, hammerspoon) — the agent owns this machine's window management.

## The `~/.zshrc` handoff

`home/shared/modules/shell/zsh/default.nix:151` writes `home.file.".zshrc"`
wholesale — home-manager **owns** that file. The current `~/.zshrc` holds four
live credentials in plaintext: `OPENCLAW_GATEWAY_TOKEN`, `ZEROENTROPY_API_KEY`,
`VOYAGE_API_KEY`, and `GROQ_API_KEY`, plus `PATH` additions for
`~/.local/bin`, `/opt/homebrew/opt/node@24/bin`, and `~/.bun/bin`.

The zsh module already provides the escape hatch. Its `.zshenv` sources two
files (lines 95–96):

```
[[ -f $HOME/.local/share/zsh/nyx_zshenv ]] && . $HOME/.local/share/zsh/nyx_zshenv
[[ -f $HOME/.local/share/zsh/zshenv ]]     && . $HOME/.local/share/zsh/zshenv
```

The first is nix-managed (`xdg.dataFile`). The second — **without** the `nyx_`
prefix — is not written by any module, making it the intended location for
machine-local configuration.

**Migration:**

1. Write `~/.local/share/zsh/zshenv`, `chmod 600`, containing the four exports,
   the `PATH` lines, and the bun completion sourcing.
2. Confirm the file with the user, values masked.
3. Delete those lines from `~/.zshrc`, leaving it for home-manager to replace.

This file is machine-local, never enters the repository, and is not covered by
any nix module. The credentials are **not** migrated into agenix — they belong
to the agent, not the user.

Note that `.zshenv` also exports `ZDOTDIR="$HOME/.config/zsh"`;
`home/darwin/modules/shell/default.nix:11` already symlinks
`home/config/.config/zsh` to that path, so the Darwin ZDOTDIR case is handled.

### PATH ordering

`~/.local/share/zsh/zshenv` must keep `~/.local/bin` and `/opt/homebrew/bin`
ahead of the nix profile, so `claude`, `codegraph`, and the Homebrew Python
resolve exactly as they do today.

The five gateways run under launchd with absolute interpreter paths, so
interactive-shell changes do not reach them. The real exposure is the
`simpleton` profile shelling out to run system commands — that path picks up
the new `~/.zshrc`, which is what this ordering protects.

## Hostname rename

Set `LocalHostName`, `ComputerName`, and `HostName` to `hestia` via `scutil`
(requires sudo).

Verified safe: no reference to `Mikes-MacBook-Pro` exists in any Hermes profile
config, the root config, `~/.claude/settings.json`, or any LaunchAgent plist.
Hermes binds `localhost` and `0.0.0.0` throughout.

## Gemini removal (separate commit)

Google retired Gemini CLI on 2026-06-18 with no grace period for free, AI Pro,
and Ultra personal accounts; it was folded into Antigravity CLI (`agy`, a
closed-source Go binary). Gemini CLI remains available only under Code Assist
Standard/Enterprise licenses or paid API keys. The account on this machine is
personal-tier, so brew's `gemini-cli 0.46.0` here can no longer authenticate.

As its own commit, independent of the hestia work:

- Delete `home/shared/modules/ai/gemini/`.
- Remove `gemini.enable` from all seven references:
  `system/arch/hosts/prometheus/default.nix:58`,
  `system/nixos/shared/home.nix:29`,
  `system/arch/hosts/L242731/default.nix:52`,
  `system/nixos/hosts/hephaestus/home.nix:22`,
  `system/darwin/hosts/EU-L260076/home.nix:31`,
  `system/darwin/hosts/mwdavis-workm1/home.nix:31`,
  `system/darwin/hosts/L241729/home.nix:31`,
  and the `gemini.enable = false` in `home/shared/profiles/headless.nix:51`.
- `brew uninstall gemini-cli` on this machine.

**Antigravity CLI is not adopted.** It is closed-source, almost certainly
absent from nixpkgs (so it could not be managed declaratively anyway), and
CyberScoop reported a sandbox-escape RCE against Antigravity on 2026-04-30 with
no CVE assignment or patch announcement located. Installing an agent-capable
closed binary on a host running five unattended gateways is not a default worth
taking.

## Risks

| Risk | Mitigation |
|---|---|
| Losing the agent's gateway token when home-manager takes `~/.zshrc` | Migrate to `~/.local/share/zsh/zshenv` and verify **before** activating |
| Nix shadowing `codegraph` / Homebrew Python for the agent | No dev toolchains enabled; PATH ordering preserved in the local zshenv |
| A shared home module unconditionally referencing `config.age` would fail eval without agenix | Caught at `nix build` — before anything touches `$HOME` |
| Existing `~/.zshenv`, `~/.zshrc` collide during activation | Pre-migrate, and activate with `-b backup` |
| Credentials leaking into git | They stay in `$HOME`; nothing in this plan copies them into the repo |

Two pre-existing issues found during design, **out of scope** but worth
tracking separately:

- `lib/default.nix:208-218` hardcodes `mdavis67` in the Darwin applications
  activation script — it chowns `~/Applications/Nix` and aliases into
  `/Users/mdavis67/`. That is wrong for `mwdavis-workm1`, which is a
  `mwdavisii` host. The standalone path does not use this script, so hestia is
  unaffected.
- `users/mwdavisii.nix` carries a `hashedPassword` and `signingKey` in the
  repo. The standalone Darwin path uses neither, but `userConf` does import it.

## Verification

Ordered so that nothing touches `$HOME` until a build has succeeded.

1. Install Nix (Determinate or the official multi-user installer).
2. `nix flake show` — confirms `hestia` appears under `homeConfigurations`.
3. `nix build .#homeConfigurations.hestia.activationPackage` — full evaluation
   and build with **no** effect on `$HOME`.
4. Inspect `./result` — confirm no agenix references, and that the generated
   `.zshrc`/`.zshenv` look correct.
5. Migrate `~/.zshrc` → `~/.local/share/zsh/zshenv`; user confirms masked.
6. `home-manager switch --flake .#hestia -b backup`.
7. Confirm the agent still works: gateways alive (`ps`), `codegraph` and
   `claude` resolve to their pre-existing paths (`which -a`), dashboard
   reachable.
8. Rename the host to `hestia`.

## Rollback

- Home-manager: `home-manager generations`, then activate the prior generation.
  On a first-ever activation, remove `~/.zshrc` / `~/.zshenv` and restore the
  `.backup` files written by `-b backup`.
- Hostname: `scutil --set` back to the previous values.
- Nix itself: uninstalling is separate and not required for rollback — an
  inactive Nix install has no effect on the agent.
