# hestia Darwin Home Host Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `hestia` — this agent-run M1 MacBook — to nyx as a standalone home-manager host that restores the user's terminal environment without touching the running Hermes agent or any encrypted secret.

**Architecture:** A new `mkStandaloneDarwinConfiguration` builder in `lib/default.nix` mirrors the existing Arch standalone builder, minus Hyprland and minus the agenix home-manager module. The host config lives at `system/darwin/home/hestia/default.nix`, kept separate from the system-level nix-darwin hosts in `system/darwin/hosts/`. No nix-darwin, no declarative Homebrew, no system defaults.

**Tech Stack:** Nix flakes, home-manager (standalone), nixvim.

**Spec:** `docs/superpowers/specs/2026-08-26-hestia-darwin-home-host-design.md`

## Global Constraints

- **Never import `system/shared/secrets`, never enable any `nyx.secrets.*`, never define `age.secrets`.** The encrypted secrets repository must not be consumed by this host. Passing `agenix` as a *module argument* is fine and required (see Task 1) — it is the flake input, not the secret store.
- **Never copy credentials into the repository.** The four live credentials in `~/.zshrc` (`OPENCLAW_GATEWAY_TOKEN`, `ZEROENTROPY_API_KEY`, `VOYAGE_API_KEY`, `GROQ_API_KEY`) move to `~/.local/share/zsh/zshenv` and stay there.
- **No dev toolchain modules** (`nyx.modules.dev.*`), so nix never shadows `/opt/homebrew/Cellar/python@3.14` or `/opt/homebrew/bin/codegraph`, which back the agent's MCP servers.
- **No AI modules** (`nyx.modules.ai.*`). Claude Code stays native and self-updating at `~/.local/bin/claude`.
- **`~/.local/bin` and `/opt/homebrew/bin` must precede the nix profile in PATH.**
- **Nothing touches `$HOME` until `nix build` has succeeded** (Tasks 1–2 are build-only; Task 3 is the first task that writes to `$HOME`).
- Target: `aarch64-darwin`, user `mwdavisii`, home `/Users/mwdavisii`, `home.stateVersion = "26.05"`.

## Prerequisites

Nix is not installed on this machine. Before Task 1:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Then open a new shell and confirm:

```bash
nix --version
nix flake show 2>&1 | head -20
```

Installing Nix creates the `/nix` volume and a daemon. It does not modify `~/.zshrc`, Homebrew, or anything Hermes depends on.

## File Structure

| File | Responsibility |
|---|---|
| `lib/default.nix` | Add `mkStandaloneDarwinConfiguration` (new function, ~30 lines) |
| `flake.nix:152-172` | Merge Darwin standalone configs into `homeConfigurations` |
| `system/darwin/home/hestia/default.nix` | **Create.** Host home-manager module: module toggles + packages |
| `~/.local/share/zsh/zshenv` | **Create, outside repo.** Machine-local env: credentials + PATH |

---

### Task 1: Standalone Darwin builder and flake wiring

Produces a `hestia` home configuration that evaluates and builds with a minimal host config. Capabilities come in Task 2 — this task proves the builder works.

**Files:**
- Modify: `lib/default.nix` (add function after `mkArchConfiguration` alias, ~line 138)
- Modify: `flake.nix:152-172`
- Create: `system/darwin/home/hestia/default.nix`

**Interfaces:**
- Produces: `lib.mkStandaloneDarwinConfiguration :: name -> { config ? name, user, system ? "aarch64-darwin", hostsDir ? ../system/darwin/home } -> nameValuePair`, consumed by `flake.nix`. Output attribute: `self.homeConfigurations.hestia.activationPackage`.

- [ ] **Step 1: Write the failing test — wire the flake to a builder that does not exist yet**

In `flake.nix`, replace the `homeConfigurations = mapAttrs' lib.mkStandaloneLinuxConfiguration { ... };` block (lines 152-172) with:

```nix
      homeConfigurations =
        (mapAttrs' lib.mkStandaloneLinuxConfiguration {
          L242731 = {
            user = "mdavis67";
            system = "x86_64-linux";
          };
          prometheus = {
            user = "mwdavisii";
            system = "x86_64-linux";
          };
          castor = {
            user = "mwdavisii";
            system = "aarch64-linux";
            hostsDir = ./system/dgx/hosts;
            enableHyprland = false;
          };
          pollux = {
            user = "mwdavisii";
            system = "aarch64-linux";
            hostsDir = ./system/dgx/hosts;
            enableHyprland = false;
          };
        })
        // (mapAttrs' lib.mkStandaloneDarwinConfiguration {
          hestia = { user = "mwdavisii"; system = "aarch64-darwin"; };
        });
```

- [ ] **Step 2: Run it to verify it fails**

Run: `nix flake show 2>&1 | head -20`
Expected: FAIL with `attribute 'mkStandaloneDarwinConfiguration' missing`.

This confirms the flake actually reaches the new builder rather than silently ignoring it.

- [ ] **Step 3: Add the builder**

In `lib/default.nix`, immediately after the line `mkArchConfiguration = mkStandaloneLinuxConfiguration;`, add:

```nix
  ################################## STANDALONE DARWIN ##################################
  # Standalone home-manager builder for macOS hosts that are NOT managed by nix-darwin.
  # Differs from mkStandaloneLinuxConfiguration in three ways:
  #   1. No Hyprland (macOS).
  #   2. No agenix home-manager module — this is deliberate. Hosts built here must not
  #      consume the encrypted secrets repository. `agenix` is still passed as a module
  #      ARGUMENT because several home modules declare it in their signature without
  #      using it; that is the flake input, not the secret store.
  #   3. homeDirectory is /Users/<user> rather than /home/<user>.
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
          { inherit inputs name self system user agenix; };
      }
    );
```

Note `agenix` in `extraSpecialArgs` — `lib/default.nix` opens with `with inputs;`, so the bare name resolves to `inputs.agenix`. Without it, eval fails on the eleven modules that declare `agenix` in their signature (e.g. `home/darwin/modules/apps/iterm2/default.nix:1`), because module arguments resolve at import time regardless of whether the module is enabled.

- [ ] **Step 4: Create the minimal host config**

Create `system/darwin/home/hestia/default.nix`:

```nix
{ config, pkgs, lib, inputs, ... }:

# hestia — agent-run M1 MacBook (Hermes), standalone home-manager.
#
# NO SECRETS ON THIS HOST. nyx.secrets.* is not merely disabled here — those
# options are defined only in system/shared/secrets/*.nix (system-level
# modules), which the standalone Darwin builder never imports. Setting them
# to false would be an eval error: the options do not exist in this scope.
# That absence is the guarantee. Do not import system/shared/secrets, do not
# define age.secrets. Matches headless.nix / prometheus / L242731 behavior.
#
# The only credential on this machine is the pre-existing ~/.ssh/id_ed25519,
# which nyx does not manage.

{
  programs.home-manager.enable = true;
  programs.man.enable = true;
  manual.manpages.enable = true;

  home = {
    stateVersion = "26.05";
    packages = with pkgs; [ ];
  };
}
```

- [ ] **Step 5: Run the test to verify it passes**

```bash
nix flake show 2>&1 | grep -A3 homeConfigurations
nix build .#homeConfigurations.hestia.activationPackage
```

Expected: `hestia` appears under `homeConfigurations`, and the build succeeds producing `./result`. Nothing in `$HOME` is modified.

- [ ] **Step 6: Verify no secrets were pulled in**

```bash
grep -rn "age.secrets\|nyx.secrets" system/darwin/home/hestia/default.nix; echo "exit=$? (1 = clean)"
nix eval .#homeConfigurations.hestia.config.home.username
```

Expected: no matches (exit 1), and username `"mwdavisii"`.

- [ ] **Step 7: Commit**

```bash
git add lib/default.nix flake.nix system/darwin/home/hestia/default.nix
git commit -m "feat(darwin): add standalone home-manager builder and hestia host

Adds mkStandaloneDarwinConfiguration for macOS hosts not managed by
nix-darwin. Deliberately omits the agenix home-manager module so hosts
built this way cannot consume the encrypted secrets repository."
```

---

### Task 2: Terminal capabilities

Fills in the actual environment. Still build-only — `$HOME` remains untouched.

**Files:**
- Modify: `system/darwin/home/hestia/default.nix`

**Interfaces:**
- Consumes: `system/darwin/home/hestia/default.nix` from Task 1.

- [ ] **Step 1: Write the failing test — enable a module and assert a binary lands in the build**

Replace the body of `system/darwin/home/hestia/default.nix` with the following. **Keep the secrets comment block from Task 1 Step 4 verbatim at the top** — it is the host's standing record of the no-secrets posture:

```nix
{ config, pkgs, lib, inputs, ... }:

# hestia — agent-run M1 MacBook (Hermes), standalone home-manager.
#
# NO SECRETS ON THIS HOST. nyx.secrets.* is not merely disabled here — those
# options are defined only in system/shared/secrets/*.nix (system-level
# modules), which the standalone Darwin builder never imports. Setting them
# to false would be an eval error: the options do not exist in this scope.
# That absence is the guarantee. Do not import system/shared/secrets, do not
# define age.secrets. Matches headless.nix / prometheus / L242731 behavior.
#
# The only credential on this machine is the pre-existing ~/.ssh/id_ed25519,
# which nyx does not manage.

{
  programs.home-manager.enable = true;
  programs.man.enable = true;
  manual.manpages.enable = true;

  home = {
    stateVersion = "26.05";
    packages = with pkgs; [
      ripgrep
      fd
      sd
      dua
      just
      comma
      wget
      vim
    ];
  };

  nyx.modules = {
    app = {
      alacritty = {
        enable = true;
        package = null;   # installed via Homebrew; nix manages config only
      };
      kitty = {
        enable = true;
        package = null;
      };
      wezterm = {
        enable = true;
        package = null;
        fontSize = 14;
      };
      iterm2.enable = true;   # config-only module, no package
    };

    shell = {
      atuin.enable = true;
      bash.enable = true;
      bat.enable = true;
      bottom.enable = true;
      direnv.enable = true;
      dysk.enable = true;
      eza.enable = true;
      fastfetch.enable = true;
      fzf.enable = true;
      git = {
        enable = true;
        signing.signByDefault = false;
      };
      glow.enable = true;
      jq.enable = true;
      lazygit.enable = true;
      lf.enable = true;
      navi.enable = true;
      ncdu.enable = true;
      networking.enable = true;
      nixvim.enable = true;
      openssl.enable = true;
      ranger.enable = true;
      starship.enable = true;
      tmux.enable = true;
      xdg.enable = true;
      yq.enable = true;
      zellij.enable = true;
      zoxide.enable = true;
      zsh.enable = true;
    };
  };
}
```

Deliberately absent, per the spec: every `nyx.secrets.*`, all `nyx.modules.ai.*`, all `nyx.modules.dev.*`, `shell.gnupg` (writes `~/.gnupg`), `shell.k8sTooling`, `shell.terraform`, `shell.awscliv2`, `shell.azurecli`, `shell.gcp`, and all `desktop.*` (the agent owns window management on this machine).

- [ ] **Step 2: Run the build**

Run: `nix build .#homeConfigurations.hestia.activationPackage 2>&1 | tail -30`
Expected: PASS. If it fails on a missing module argument (`called without required argument`), the fix is to add that argument to `extraSpecialArgs` in `lib/default.nix` — the same fix as `agenix` in Task 1. Do not "fix" it by importing an agenix module.

- [ ] **Step 3: Verify the generated shell config**

```bash
cat result/home-files/.zshrc
cat result/home-files/.zshenv
```

Expected: `.zshrc` sources `$HOME/.local/share/zsh/nyx_zshrc`. `.zshenv` exports `ZDOTDIR="$HOME/.config/zsh"` and sources both `$HOME/.local/share/zsh/nyx_zshenv` and `$HOME/.local/share/zsh/zshenv`. That second, un-prefixed path is the escape hatch Task 3 depends on — confirm it is present before proceeding.

- [ ] **Step 4: Prove the secrets options are structurally absent**

This is the assertion that replaces "set all secrets to false" — it verifies the options cannot be enabled at all, which is stronger.

```bash
# Each of these MUST fail with "does not exist". A success is a REGRESSION.
for opt in userSSHKeys userPGPKeys awsSSHKeys awsConfig workvpn; do
  printf "%-14s " "$opt"
  if nix eval ".#homeConfigurations.hestia.config.nyx.secrets.$opt.enable" >/dev/null 2>&1; then
    echo "REGRESSION - option exists, secrets tree is reachable"
  else
    echo "absent (correct)"
  fi
done
```

Expected: all five report `absent (correct)`. If any reports `REGRESSION`, the secrets tree has been imported into the standalone builder — stop and fix `lib/default.nix` before going further.

Then confirm no encrypted material is referenced anywhere in the closure:

```bash
grep -rn "secrets/encrypted\|age.secrets\|identityPaths" system/darwin/home/hestia/ ; echo "exit=$? (1 = clean)"
nix eval --raw .#homeConfigurations.hestia.config.home.path | xargs -I{} sh -c 'ls {}/bin | wc -l'
```

Expected: no matches (exit 1), then a binary count.

- [ ] **Step 5: Commit**

```bash
git add system/darwin/home/hestia/default.nix
git commit -m "feat(hestia): enable terminal core and emulator configs

No dev toolchains, no AI modules, no secrets: keeps Homebrew's python
and codegraph unshadowed for the Hermes agent."
```

---

### Task 3: Credential migration and activation

**First task that writes to `$HOME`.** Do not start until Tasks 1–2 build clean.

**Files:**
- Create: `~/.local/share/zsh/zshenv` (outside the repo, `chmod 600`, never committed)
- Modify: `~/.zshrc` (strip migrated lines)

- [ ] **Step 1: Snapshot current state for rollback**

```bash
cp ~/.zshrc ~/.zshrc.pre-nyx.$(date +%Y%m%d)
ps aux | grep -c "[h]ermes_cli.main"     # record gateway count, expect 6
which -a claude codegraph gemini > ~/.pre-nyx-paths.txt
cat ~/.pre-nyx-paths.txt
```

- [ ] **Step 2: Create the machine-local env file**

Create `~/.local/share/zsh/zshenv` containing, in this order: the `~/.local/bin` PATH export, the `/opt/homebrew/opt/node@24/bin` PATH export, the bun block (`BUN_INSTALL`, its PATH entry, and the `~/.bun/_bun` completion sourcing), the OpenClaw completion sourcing, and the four exports `OPENCLAW_GATEWAY_TOKEN`, `ZEROENTROPY_API_KEY`, `VOYAGE_API_KEY`, `GROQ_API_KEY` — each carrying its **exact current value**, copied from `~/.zshrc`.

Copy the values across without printing them to the terminal. Then:

```bash
mkdir -p ~/.local/share/zsh
chmod 600 ~/.local/share/zsh/zshenv
```

- [ ] **Step 3: Verify the migration with values masked**

```bash
sed -E 's/=.{0,4}[^ ]*/=***MASKED***/' ~/.local/share/zsh/zshenv
diff <(grep -oE '^[^=]*=' ~/.zshrc | sort -u) <(grep -oE '^[^=]*=' ~/.local/share/zsh/zshenv | sort -u)
```

Expected: every export name present in `~/.zshrc` also appears in the new file. **Stop and show this masked output to the user for confirmation before continuing.**

- [ ] **Step 4: Confirm PATH ordering is preserved**

```bash
zsh -c 'source ~/.local/share/zsh/zshenv; echo $PATH' | tr ':' '\n' | head -5
```

Expected: `~/.local/bin` and `/opt/homebrew/...` appear before any `/nix/store` or `~/.nix-profile` entry.

- [ ] **Step 5: Remove the migrated lines from `~/.zshrc`**

Delete every line now living in `~/.local/share/zsh/zshenv`. If that leaves the file empty, delete it — home-manager will write its own.

- [ ] **Step 6: Activate**

```bash
nix run home-manager/master -- switch --flake .#hestia -b backup
```

`-b backup` renames any colliding file to `<name>.backup` instead of failing, so `~/.zshenv` and `~/.config/zsh` are recoverable.

- [ ] **Step 7: Verify the agent is unharmed**

```bash
ps aux | grep -c "[h]ermes_cli.main"      # must match Step 1's count
which -a claude codegraph                  # must match ~/.pre-nyx-paths.txt
diff <(which -a claude codegraph gemini) ~/.pre-nyx-paths.txt
curl -sS -o /dev/null -w "%{http_code}\n" http://localhost:8362/mcp || true
```

Expected: gateway count unchanged, `claude` still resolving to `~/.local/bin/claude`, `codegraph` still to `/opt/homebrew/bin/codegraph`.

- [ ] **Step 8: Verify the shell in a fresh session**

Open a new terminal and run:

```bash
echo $OPENCLAW_GATEWAY_TOKEN | head -c 4; echo "...(should be non-empty)"
starship --version && atuin --version && zoxide --version
```

- [ ] **Step 9: Commit (repo only — nothing from `$HOME`)**

```bash
git status --short          # confirm NOTHING from $HOME is staged
git commit --allow-empty -m "chore(hestia): activate standalone home-manager config"
```

**Rollback if anything above fails:** `home-manager generations` then activate the prior one; or restore `~/.zshrc.pre-nyx.*` and remove `~/.zshrc` / `~/.zshenv`, restoring the `.backup` files.

---

### Task 4: Rename the host to hestia

Independent of the others; safe to defer.

- [ ] **Step 1: Confirm nothing depends on the current name**

```bash
grep -rniI "mikes-macbook" ~/.hermes/profiles/*/config.yaml ~/.hermes/config.yaml ~/Library/LaunchAgents/*.plist 2>/dev/null; echo "exit=$? (1 = clean)"
```

Expected: no matches. (Verified during design: Hermes binds `localhost`/`0.0.0.0`.)

- [ ] **Step 2: Record the current values**

```bash
scutil --get ComputerName; scutil --get LocalHostName; scutil --get HostName 2>/dev/null
```

- [ ] **Step 3: Set the new name**

```bash
sudo scutil --set ComputerName "hestia"
sudo scutil --set LocalHostName "hestia"
sudo scutil --set HostName "hestia"
```

- [ ] **Step 4: Verify**

```bash
scutil --get LocalHostName        # hestia
hostname                          # hestia.local or hestia
ps aux | grep -c "[h]ermes_cli.main"   # gateway count unchanged
```

**Rollback:** `sudo scutil --set` back to the Step 2 values.

---

### Task 5: Remove gemini repo-wide

Independent of Tasks 1–4 — can be done before or after, but as its **own commit**.

Context: Google retired Gemini CLI on 2026-06-18 with no grace period for free/AI Pro/Ultra personal accounts, folding it into Antigravity CLI. It remains available only under Code Assist Standard/Enterprise licenses or paid API keys. This machine's account is personal-tier, so the installed `gemini-cli 0.46.0` can no longer authenticate.

**Files:**
- Delete: `home/shared/modules/ai/gemini/`
- Modify: seven host configs plus `home/shared/profiles/headless.nix`

- [ ] **Step 1: Write the failing test — delete the module first**

```bash
git rm -r home/shared/modules/ai/gemini
nix eval .#homeConfigurations.prometheus.config.home.username 2>&1 | tail -5
```

Expected: FAIL with an error about the undefined option `nyx.modules.ai.gemini`. This proves the references are live and that Step 2 is actually required.

- [ ] **Step 2: Remove every reference**

Delete the `gemini.enable` line from each:

```
system/arch/hosts/prometheus/default.nix:58
system/nixos/shared/home.nix:29
system/arch/hosts/L242731/default.nix:52
system/nixos/hosts/hephaestus/home.nix:22
system/darwin/hosts/EU-L260076/home.nix:31
system/darwin/hosts/mwdavis-workm1/home.nix:31
system/darwin/hosts/L241729/home.nix:31
home/shared/profiles/headless.nix:51
```

- [ ] **Step 3: Verify no references remain**

```bash
grep -rn "gemini" system/ home/ --include="*.nix"; echo "exit=$? (1 = clean)"
```

Expected: no matches.

- [ ] **Step 4: Verify affected hosts still evaluate**

```bash
nix eval .#homeConfigurations.prometheus.config.home.username
nix eval .#homeConfigurations.hestia.config.home.username
nix build .#darwinConfigurations.mwdavis-workm1.system --dry-run 2>&1 | tail -5
```

Expected: all succeed. The `mwdavis-workm1` dry-run needs no macOS activation — it only evaluates.

- [ ] **Step 5: Remove the dead package from this machine**

```bash
brew uninstall gemini-cli
which -a gemini; echo "exit=$? (1 = gone)"
```

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "chore(ai): remove gemini module and all references

Google retired Gemini CLI on 2026-06-18 for personal-tier accounts,
folding it into Antigravity CLI. The module installed a CLI that can no
longer authenticate on any of these hosts."
```

---

## Out of Scope

Found during design, deliberately not fixed here:

- `lib/default.nix:208-218` hardcodes `mdavis67` in the Darwin applications activation script — wrong for `mwdavis-workm1`, which is a `mwdavisii` host. The standalone path does not use this script.
- `users/mwdavisii.nix` carries a `hashedPassword` and `signingKey` in the repo.
- Rotating the four credentials found in `~/.zshrc`. The user has these; deferred at their request.
- Antigravity CLI is not adopted: closed-source, almost certainly not in nixpkgs, and CyberScoop reported an unpatched sandbox-escape RCE against Antigravity on 2026-04-30.
