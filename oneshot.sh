#!/usr/bin/env bash
# =============================================================================
# oneshot.sh — turn this checkout into "my nyx" for a single DGX box.
# =============================================================================
# For less-technical users who want to fork-in-place:
#   1. Prompt for hostname (default: current `hostname -s`).
#   2. Read $USER from the environment.
#   3. Optionally prompt for display name and email (for git commits later).
#   4. Write users/$USER.nix if missing.
#   5. Rewrite flake.nix homeConfigurations to a SINGLE entry (their box).
#   6. rm -rf .git  (they own this checkout; no upstream contamination).
#   7. Run setup/dgx/01-install-packages.sh
#   8. Run setup/dgx/02-setup-nix.sh (with NYX_HOST + NYX_SKIP_CLONE=1)
#
# Idempotency: this script is a "make it mine" one-way transform. Once .git
# is removed it will refuse to run again. That's on purpose — the whole
# point is that after oneshot.sh, the checkout is theirs.
#
# Non-DGX use: works on any Linux box, but 01/02 will complain if it's
# not a DGX (driver check warns, /models still gets created). Fine for
# other Ubuntu-derived hosts if you know what you're doing.
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${GREEN}[oneshot]${NC} $*"; }
warn()  { echo -e "${YELLOW}[oneshot]${NC} $*"; }
error() { echo -e "${RED}[oneshot]${NC} $*"; exit 1; }
ask()   { echo -e "${BLUE}[oneshot]${NC} $*"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ── Sanity checks ────────────────────────────────────────────────────

if [[ "${USER:-}" == "" || "${USER:-}" == "root" ]]; then
  error "\$USER is empty or root. Run this as your regular user (not sudo)."
fi

if [[ ! -f flake.nix ]]; then
  error "flake.nix not found. Run this from the root of the nyx checkout."
fi

if [[ ! -f setup/dgx/01-install-packages.sh || ! -f setup/dgx/02-setup-nix.sh ]]; then
  error "setup/dgx/01-install-packages.sh or 02-setup-nix.sh missing. Wrong checkout?"
fi

# ── Prompts ──────────────────────────────────────────────────────────

info "Setting up nyx for user: $USER"
echo ""

DEFAULT_HOST="$(hostname -s 2>/dev/null || hostname)"
ask "What should this machine be called?"
read -rp "    Hostname [$DEFAULT_HOST]: " host_input
HOST="${host_input:-$DEFAULT_HOST}"

# Validate: nix attrpath must be [a-zA-Z_][a-zA-Z0-9_'-]*
if ! [[ "$HOST" =~ ^[a-zA-Z_][a-zA-Z0-9_-]*$ ]]; then
  error "Hostname '$HOST' contains characters that would break flake.nix. Use letters, digits, - and _."
fi

# Only ask for identity if we're actually going to create a user file.
USER_NIX="users/${USER}.nix"
if [[ ! -f "$USER_NIX" ]]; then
  echo ""
  ask "Creating $USER_NIX — need a couple of details for git commit metadata."
  read -rp "    Display name [$USER]: " display_input
  DISPLAY_NAME="${display_input:-$USER}"

  DEFAULT_EMAIL="${USER}@$(hostname -f 2>/dev/null || echo localhost)"
  read -rp "    Email [$DEFAULT_EMAIL]: " email_input
  EMAIL="${email_input:-$DEFAULT_EMAIL}"
else
  info "Reusing existing $USER_NIX."
fi

echo ""
info "About to transform this checkout:"
echo "  - Hostname:  $HOST"
echo "  - User:      $USER"
if [[ ! -f "$USER_NIX" ]]; then
  echo "  - New file:  $USER_NIX"
fi
echo "  - flake.nix: reduced to a single homeConfigurations entry ($HOST)"
echo "  - .git:      DELETED (checkout becomes yours, no upstream)"
echo "  - Then run:  setup/dgx/01-install-packages.sh"
echo "  - Then run:  setup/dgx/02-setup-nix.sh"
echo ""
read -rp "Proceed? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  error "Aborted."
fi

# ── Write users/<USER>.nix ───────────────────────────────────────────

if [[ ! -f "$USER_NIX" ]]; then
  info "Writing $USER_NIX"
  cat > "$USER_NIX" <<EOF
{
  userName = "$USER";
  email = "$EMAIL";
  displayName = "$DISPLAY_NAME";
  # Set once you have a signing key: 0xDEADBEEF...
  signingKey = "";
  hashedPassword = "";
  yubiKeySerials = [ ];
  windowsUserDirName = "";
}
EOF
fi

# ── Rewrite flake.nix ────────────────────────────────────────────────
#
# Strategy: replace the entire homeConfigurations = { ... }; block with a
# single-entry block for this box. Python is used instead of sed because
# the block spans multiple lines and involves brace matching.

info "Rewriting flake.nix homeConfigurations..."
python3 - "$HOST" "$USER" <<'PY'
import re, sys, pathlib

host, user = sys.argv[1], sys.argv[2]
path = pathlib.Path("flake.nix")
src = path.read_text()

new_block = f"""      homeConfigurations = mapAttrs' lib.mkStandaloneLinuxConfiguration {{
        {host} = {{
          user = "{user}";
          system = "aarch64-linux";
          hostsDir = ./system/dgx/hosts;
          enableHyprland = false;
        }};
      }};"""

# The outer homeConfigurations block ends with `      };` at column 6.
# Inner host entries close with `        };` at column 8. Anchor on the
# outer close explicitly so nested closes don't stop the match early.
pattern = re.compile(
    r"^      homeConfigurations\s*=\s*mapAttrs'\s+lib\.mk\w+\s*\{.*?^      \};",
    re.DOTALL | re.MULTILINE,
)

new_src, count = pattern.subn(new_block, src, count=1)
if count != 1:
    sys.stderr.write("ERROR: could not find homeConfigurations block in flake.nix\n")
    sys.exit(1)

path.write_text(new_src)
PY

# Also drop the DGX host directory placeholder for this hostname if it
# doesn't exist yet, so flake.nix's hostsDir = ./system/dgx/hosts finds
# an entry for the new name.
HOST_DIR="system/dgx/hosts/${HOST}"
if [[ ! -d "$HOST_DIR" ]]; then
  info "Creating $HOST_DIR/default.nix"
  mkdir -p "$HOST_DIR"
  cat > "$HOST_DIR/default.nix" <<EOF
{ config, pkgs, lib, inputs, ... }:

# $HOST — headless nyx host. Auto-generated by oneshot.sh.
# Host-specific overrides go here; nothing needed at first.

{
  imports = [ ../../../../home/shared/profiles/headless.nix ];
}
EOF
fi

# ── rm -rf .git ──────────────────────────────────────────────────────

if [[ -d .git ]]; then
  info "Removing .git (this checkout is now yours)"
  rm -rf .git
fi

# ── Run 01 and 02 ────────────────────────────────────────────────────

echo ""
info "Running setup/dgx/01-install-packages.sh"
bash setup/dgx/01-install-packages.sh

echo ""
info "Running setup/dgx/02-setup-nix.sh"
NYX_HOST="$HOST" NYX_SKIP_CLONE=1 NYX_SKIP_BRANCH=1 bash setup/dgx/02-setup-nix.sh

echo ""
info "Done. Your box '$HOST' is set up."
info "For ongoing updates: cd $(pwd) && ./switch.sh"
