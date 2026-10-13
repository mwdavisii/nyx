#!/usr/bin/env bash
set -euo pipefail

# Selective rsync of /home/mwdavisii to /home/mwdavisii/nix-games/aether-home-migration/.
# Pass 1 copies everything except /nix/store symlinks and known cache directories.
# Pass 2 re-copies .ssh following symlinks so actual SSH keys land in the destination.

SRC="/home/mwdavisii/"
DEST="/home/mwdavisii/nix-games/aether-home-migration/"
EXCLUDES_FILE="symlink-excludes.txt"
LEARNINGS="/home/mwdavisii/code/nyx/.omo/notepads/aether-from-prometheus/learnings.md"
DRY_RUN_ONLY=false

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN_ONLY=true
fi

mkdir -p "$DEST"

echo "==> Generating $EXCLUDES_FILE from /nix/store symlinks..."
find /home/mwdavisii \
  -path '/home/mwdavisii/nix-games' -prune -o \
  -path '/home/mwdavisii/.cache' -prune -o \
  -path '/home/mwdavisii/Downloads' -prune -o \
  -path '/home/mwdavisii/win-games' -prune -o \
  -path '/home/mwdavisii/.local/share' -prune -o \
  -path '/home/mwdavisii/.ollama' -prune -o \
  -path '/home/mwdavisii/OpenAudible' -prune -o \
  -path '/home/mwdavisii/.vscode' -prune -o \
  -path '/home/mwdavisii/.nuget' -prune -o \
  -path '/home/mwdavisii/.claude.bak' -prune -o \
  -path '/home/mwdavisii/vault.bak' -prune -o \
  -path '/home/mwdavisii/.codegraph' -prune -o \
  -type l -lname '/nix/store/*' -printf '%P\n' 2>/dev/null > "$EXCLUDES_FILE" || true
EXCLUDE_COUNT=$(wc -l < "$EXCLUDES_FILE")
echo "    Excluded $EXCLUDE_COUNT /nix/store symlinks."

echo "==> Pass 1 dry-run to validate excludes..."
set +e
RSYNC_DRY_RUN=$(rsync -av --dry-run \
  --exclude-from="$EXCLUDES_FILE" \
  --exclude='Downloads' \
  --exclude='.cache' \
  --exclude='win-games' \
  --exclude='nix-games' \
  --exclude='.local/share' \
  --exclude='.local/state/nix' \
  --exclude='OpenAudible' \
  --exclude='.ollama' \
  --exclude='.vscode' \
  --exclude='.nuget' \
  --exclude='.claude.bak' \
  --exclude='vault.bak' \
  --exclude='list-channel-names' \
  --exclude='.codegraph' \
  --exclude='.config/google-chrome/Code Cache' \
  --exclude='.config/google-chrome/Default/Service Worker' \
  --exclude='.config/google-chrome/Default/IndexedDB' \
  --exclude='.config/google-chrome/Default/WebStorage' \
  --exclude='.config/google-chrome/OptGuideOnDeviceModel' \
  --exclude='.config/google-chrome/OptGuideOnDeviceClassifierModel' \
  --exclude='.config/google-chrome/optimization_guide_model_store' \
  --exclude='.config/google-chrome/component_crx_cache' \
  --exclude='.config/google-chrome/extensions_crx_cache' \
  --exclude='.config/google-chrome/WasmTtsEngine' \
  --exclude='.config/google-chrome/Safe Browsing' \
  --exclude='.config/google-chrome/GPUPersistentCache' \
  --exclude='.config/google-chrome/segmentation_platform' \
  --exclude='.config/Claude/vm_bundles' \
  --exclude='.config/Claude/Cache' \
  --exclude='.config/Claude/Code Cache' \
  --exclude='.config/Claude/GPUCache' \
  --exclude='.config/Code/CachedExtensionVSIXs' \
  --exclude='.config/Code/Cache' \
  --exclude='.config/Code/CachedData' \
  --exclude='.config/Code/WebStorage' \
  --exclude='.config/discord/Cache' \
  --exclude='.config/discord/Service Worker' \
  --exclude='.config/discord/Code Cache' \
  --exclude='.config/discord/GPUPersistentCache' \
  --exclude='.config/obsidian/Cache' \
  --exclude='.config/obsidian/Code Cache' \
  --exclude='.config/obsidian/IndexedDB' \
  --exclude='.config/Slack/Service Worker' \
  --exclude='.config/Slack/Cache' \
  --exclude='.config/retroarch/cores-buildbot' \
  --exclude='.config/heroic/tools' \
  --exclude='.config/BambuStudioInternal/log' \
  --exclude='.config/BambuStudioInternal/hms' \
  --exclude='.config/OrcaSlicer/plugins' \
  --exclude='.config/OrcaSlicer/log' \
  --exclude='.config/opencode/node_modules' \
  --exclude='.config/YouTube Music/Cache' \
  --exclude='.config/YouTube Music/Service Worker' \
  --exclude='.config/YouTube Music/Code Cache' \
  --exclude='.config/obs-studio/profiler_data' \
  --exclude='.config/obs-studio/logs' \
  "$SRC" "$DEST" 2>&1)
RSYNC_DRY_EXIT=$?
set -e

if [[ "$RSYNC_DRY_EXIT" -ne 0 && "$RSYNC_DRY_EXIT" -ne 23 && "$RSYNC_DRY_EXIT" -ne 24 ]]; then
  echo "ERROR: rsync dry-run failed with exit code $RSYNC_DRY_EXIT." >&2
  echo "$RSYNC_DRY_RUN" >&2
  exit 1
fi

STORE_PATHS=$(echo "$RSYNC_DRY_RUN" | grep '/nix/store/' || true)
if [[ -n "$STORE_PATHS" ]]; then
  echo "ERROR: dry-run still contains /nix/store paths:" >&2
  echo "$STORE_PATHS" >&2
  exit 1
fi

echo "    Dry-run clean: zero /nix/store paths."

if [[ "$DRY_RUN_ONLY" == true ]]; then
  echo "==> Dry-run only requested; skipping real copy and Pass 2."
  exit 0
fi

echo "==> Pass 1: copying with excludes..."
set +e
rsync -a \
  --exclude-from="$EXCLUDES_FILE" \
  --exclude='Downloads' \
  --exclude='.cache' \
  --exclude='win-games' \
  --exclude='nix-games' \
  --exclude='.local/share' \
  --exclude='.local/state/nix' \
  --exclude='OpenAudible' \
  --exclude='.ollama' \
  --exclude='.vscode' \
  --exclude='.nuget' \
  --exclude='.claude.bak' \
  --exclude='vault.bak' \
  --exclude='list-channel-names' \
  --exclude='.codegraph' \
  --exclude='.config/google-chrome/Code Cache' \
  --exclude='.config/google-chrome/Default/Service Worker' \
  --exclude='.config/google-chrome/Default/IndexedDB' \
  --exclude='.config/google-chrome/Default/WebStorage' \
  --exclude='.config/google-chrome/OptGuideOnDeviceModel' \
  --exclude='.config/google-chrome/OptGuideOnDeviceClassifierModel' \
  --exclude='.config/google-chrome/optimization_guide_model_store' \
  --exclude='.config/google-chrome/component_crx_cache' \
  --exclude='.config/google-chrome/extensions_crx_cache' \
  --exclude='.config/google-chrome/WasmTtsEngine' \
  --exclude='.config/google-chrome/Safe Browsing' \
  --exclude='.config/google-chrome/GPUPersistentCache' \
  --exclude='.config/google-chrome/segmentation_platform' \
  --exclude='.config/Claude/vm_bundles' \
  --exclude='.config/Claude/Cache' \
  --exclude='.config/Claude/Code Cache' \
  --exclude='.config/Claude/GPUCache' \
  --exclude='.config/Code/CachedExtensionVSIXs' \
  --exclude='.config/Code/Cache' \
  --exclude='.config/Code/CachedData' \
  --exclude='.config/Code/WebStorage' \
  --exclude='.config/discord/Cache' \
  --exclude='.config/discord/Service Worker' \
  --exclude='.config/discord/Code Cache' \
  --exclude='.config/discord/GPUPersistentCache' \
  --exclude='.config/obsidian/Cache' \
  --exclude='.config/obsidian/Code Cache' \
  --exclude='.config/obsidian/IndexedDB' \
  --exclude='.config/Slack/Service Worker' \
  --exclude='.config/Slack/Cache' \
  --exclude='.config/retroarch/cores-buildbot' \
  --exclude='.config/heroic/tools' \
  --exclude='.config/BambuStudioInternal/log' \
  --exclude='.config/BambuStudioInternal/hms' \
  --exclude='.config/OrcaSlicer/plugins' \
  --exclude='.config/OrcaSlicer/log' \
  --exclude='.config/opencode/node_modules' \
  --exclude='.config/YouTube Music/Cache' \
  --exclude='.config/YouTube Music/Service Worker' \
  --exclude='.config/YouTube Music/Code Cache' \
  --exclude='.config/obs-studio/profiler_data' \
  --exclude='.config/obs-studio/logs' \
  "$SRC" "$DEST"
RSYNC_PASS1_EXIT=$?
set -e
if [[ "$RSYNC_PASS1_EXIT" -ne 0 && "$RSYNC_PASS1_EXIT" -ne 23 && "$RSYNC_PASS1_EXIT" -ne 24 ]]; then
  echo "ERROR: Pass 1 rsync failed with exit code $RSYNC_PASS1_EXIT." >&2
  exit 1
fi

echo "==> Pass 2: copying .ssh with symlink-following..."
set +e
rsync -aL "/home/mwdavisii/.ssh/" "$DEST/.ssh/"
RSYNC_PASS2_EXIT=$?
set -e
if [[ "$RSYNC_PASS2_EXIT" -ne 0 && "$RSYNC_PASS2_EXIT" -ne 23 && "$RSYNC_PASS2_EXIT" -ne 24 ]]; then
  echo "ERROR: Pass 2 rsync failed with exit code $RSYNC_PASS2_EXIT." >&2
  exit 1
fi

echo "==> Verifying no /nix/store symlinks in destination..."
STORE_LINK_COUNT=$(find "$DEST" -type l -lname '/nix/store/*' 2>/dev/null | wc -l) || true
if [[ "$STORE_LINK_COUNT" -ne 0 ]]; then
  echo "ERROR: destination contains $STORE_LINK_COUNT /nix/store symlinks." >&2
  exit 1
fi

echo "    Verification passed: $STORE_LINK_COUNT /nix/store symlinks."

echo "==> Appending timestamped entry to learnings.md..."
mkdir -p "$(dirname "$LEARNINGS")"
{
  echo ""
  echo "## $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""
  echo "- Ran setup/arch/aether-migrate-home.sh"
  echo "- Excluded $EXCLUDE_COUNT /nix/store symlinks via $EXCLUDES_FILE"
  echo "- Pass 1 rsync copied /home/mwdavisii to $DEST"
  echo "- Pass 2 rsync copied .ssh with -L (follow symlinks)"
  echo "- Verification: $STORE_LINK_COUNT /nix/store symlinks in destination"
} >> "$LEARNINGS"

echo "==> Migration complete."
