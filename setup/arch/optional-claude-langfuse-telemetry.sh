#!/usr/bin/env bash
# optional-claude-langfuse-telemetry.sh — wire Claude Code OTel traces to a
# self-hosted Langfuse instance, per machine.
#
# Why this isn't in the nyx module: this only runs on machines where you actually
# want Claude Code usage telemetry. Run it once per host; safe to re-run.
#
# What it does:
#   1. Ensures ~/.claude/.env has LANGFUSE_PUBLIC_KEY / LANGFUSE_SECRET_KEY /
#      LANGFUSE_BASE_URL (prompts only if missing — keys never leave this box).
#   2. Drops ~/.claude/hooks/langfuse-otel-headers.sh — a Claude Code
#      otelHeadersHelper that reads ~/.claude/.env at startup + every ~29min
#      and emits the Basic auth header. Keeps secrets out of settings.json.
#   3. Merges the OTel env block + otelHeadersHelper path into
#      ~/.claude/settings.json with jq (preserves anything already there;
#      backup written to settings.json.bak.<timestamp>).
#
# What it deliberately doesn't do:
#   - Metrics or logs exporter (Langfuse isn't a metrics backend; traces only).
#   - OTEL_LOG_USER_PROMPTS / TOOL_DETAILS / TOOL_CONTENT / RAW_API_BODIES
#     (these send prompt text + tool I/O. Opt in by editing settings.json if
#     you want richer spans.)
#
# On nyx-managed hosts: settings.json is owned by home-manager and write-blocked
# by ~/.claude/hooks/protect-settings.sh. The right place to add this is the
# nyx module — see home/shared/modules/ai/claude/default.nix. This script is
# for *non-nyx* machines.

set -euo pipefail

LANGFUSE_HOST_DEFAULT="${LANGFUSE_HOST_DEFAULT:-https://langfuse.mwdavisii.com}"

CLAUDE_DIR="${HOME}/.claude"
ENV_FILE="${CLAUDE_DIR}/.env"
SETTINGS_FILE="${CLAUDE_DIR}/settings.json"
HOOKS_DIR="${CLAUDE_DIR}/hooks"
HELPER_PATH="${HOOKS_DIR}/langfuse-otel-headers.sh"

echo "=== Claude Code → Langfuse telemetry setup ==="

# --- Sanity: nyx-managed settings.json refuses writes ---
if [[ -L "$SETTINGS_FILE" ]] && readlink "$SETTINGS_FILE" | grep -q '/nix/store/'; then
  cat >&2 <<EOF
ERROR: ${SETTINGS_FILE} is a symlink into /nix/store — this host is nyx-managed.
       Configure telemetry in home/shared/modules/ai/claude/default.nix and
       run a home-manager rebuild instead of running this script.
EOF
  exit 2
fi

# --- 1. Dependencies ---
for bin in jq base64; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "Installing missing dependency: ${bin}"
    sudo pacman -S --needed --noconfirm "$bin"
  fi
done

mkdir -p "$CLAUDE_DIR" "$HOOKS_DIR"

# --- 2. ~/.claude/.env — single source of truth for Langfuse creds ---
read_env_var() {
  # Echoes the value of $1 in $ENV_FILE, or empty if missing/unreadable.
  [[ -r "$ENV_FILE" ]] || { echo ""; return; }
  # shellcheck disable=SC1090
  ( set +u; . "$ENV_FILE" >/dev/null 2>&1; printf '%s' "${!1:-}" )
}

upsert_env_var() {
  local key="$1" val="$2"
  touch "$ENV_FILE"
  chmod 600 "$ENV_FILE"
  if grep -qE "^${key}=" "$ENV_FILE"; then
    # Replace existing line (use a delimiter unlikely to appear in keys).
    local tmp; tmp=$(mktemp)
    awk -v k="$key" -v v="$val" 'BEGIN{FS=OFS="="} $1==k {print k"=\""v"\""; next} {print}' "$ENV_FILE" > "$tmp"
    mv "$tmp" "$ENV_FILE"
  else
    printf '%s="%s"\n' "$key" "$val" >> "$ENV_FILE"
  fi
  chmod 600 "$ENV_FILE"
}

prompt_if_missing() {
  local key="$1" prompt_text="$2" default="${3:-}" cur
  cur=$(read_env_var "$key")
  if [[ -n "$cur" ]]; then
    echo "  ${key}: already set, leaving alone"
    return
  fi
  local val=""
  if [[ -n "$default" ]]; then
    read -r -p "  ${prompt_text} [${default}]: " val
    val="${val:-$default}"
  else
    # Use -s for the secret key so it doesn't echo to the terminal.
    if [[ "$key" == "LANGFUSE_SECRET_KEY" ]]; then
      read -r -s -p "  ${prompt_text}: " val; echo
    else
      read -r -p "  ${prompt_text}: " val
    fi
  fi
  if [[ -z "$val" ]]; then
    echo "ERROR: ${key} is required" >&2
    exit 1
  fi
  upsert_env_var "$key" "$val"
}

echo ""
echo "[1/3] Checking ${ENV_FILE} for Langfuse credentials"
prompt_if_missing LANGFUSE_PUBLIC_KEY "Langfuse public key (pk-lf-...)"
prompt_if_missing LANGFUSE_SECRET_KEY "Langfuse secret key (sk-lf-...)"
prompt_if_missing LANGFUSE_BASE_URL   "Langfuse base URL" "$LANGFUSE_HOST_DEFAULT"

LF_BASE=$(read_env_var LANGFUSE_BASE_URL)
LF_BASE="${LF_BASE%/}"  # strip trailing slash
OTLP_ENDPOINT="${LF_BASE}/api/public/otel"

# --- 3. otelHeadersHelper script ---
echo ""
echo "[2/3] Installing ${HELPER_PATH}"
cat > "$HELPER_PATH" <<'HELPER_EOF'
#!/usr/bin/env bash
# Claude Code otelHeadersHelper — emits Langfuse OTLP auth headers.
#
# Reads LANGFUSE_PUBLIC_KEY / LANGFUSE_SECRET_KEY from ~/.claude/.env so the
# credentials stay outside settings.json. Claude Code reruns this every ~29min,
# so rotating keys in the .env takes effect without restarting the CLI.
set -euo pipefail

env_file="${HOME}/.claude/.env"
if [[ ! -r "$env_file" ]]; then
  echo "langfuse-otel-headers: ${env_file} not readable" >&2
  exit 1
fi

# shellcheck disable=SC1090
pk=$(set +u; . "$env_file"; printf '%s' "${LANGFUSE_PUBLIC_KEY:-}")
sk=$(set +u; . "$env_file"; printf '%s' "${LANGFUSE_SECRET_KEY:-}")

if [[ -z "$pk" || -z "$sk" ]]; then
  echo "langfuse-otel-headers: LANGFUSE_PUBLIC_KEY / LANGFUSE_SECRET_KEY missing in ${env_file}" >&2
  exit 1
fi

# -w 0 keeps base64 on a single line (GNU coreutils); fall back if unsupported.
auth=$(printf '%s:%s' "$pk" "$sk" | base64 -w 0 2>/dev/null \
  || printf '%s:%s' "$pk" "$sk" | base64 | tr -d '\n')

printf '{"Authorization":"Basic %s","x-langfuse-ingestion-version":"4"}\n' "$auth"
HELPER_EOF
chmod 700 "$HELPER_PATH"

# Smoke-test it — Claude Code reports helper errors to /doctor, but we'd rather
# fail loud here.
echo "  Testing helper..."
helper_out=$("$HELPER_PATH")
echo "$helper_out" | jq -e '.Authorization | startswith("Basic ")' >/dev/null \
  || { echo "ERROR: helper output didn't parse — got: $helper_out" >&2; exit 1; }
echo "  OK"

# --- 4. Merge settings.json ---
echo ""
echo "[3/3] Updating ${SETTINGS_FILE}"

if [[ -f "$SETTINGS_FILE" ]]; then
  ts=$(date +%Y%m%d-%H%M%S)
  cp -p "$SETTINGS_FILE" "${SETTINGS_FILE}.bak.${ts}"
  echo "  Backup: ${SETTINGS_FILE}.bak.${ts}"
else
  echo "{}" > "$SETTINGS_FILE"
fi

tmp=$(mktemp)
jq \
  --arg endpoint   "$OTLP_ENDPOINT" \
  --arg helper     "$HELPER_PATH" \
  '
  .env += {
    "CLAUDE_CODE_ENABLE_TELEMETRY":         "1",
    "CLAUDE_CODE_ENHANCED_TELEMETRY_BETA":  "1",
    "OTEL_TRACES_EXPORTER":                 "otlp",
    "OTEL_METRICS_EXPORTER":                "none",
    "OTEL_LOGS_EXPORTER":                   "none",
    "OTEL_EXPORTER_OTLP_PROTOCOL":          "http/protobuf",
    "OTEL_EXPORTER_OTLP_ENDPOINT":          $endpoint,
    "OTEL_RESOURCE_ATTRIBUTES":             "service.name=claude-code"
  }
  | .otelHeadersHelper = $helper
  ' "$SETTINGS_FILE" > "$tmp"

mv "$tmp" "$SETTINGS_FILE"
echo "  Merged OTel env block + otelHeadersHelper pointer"

echo ""
echo "=== Done ==="
echo ""
echo "Endpoint:    ${OTLP_ENDPOINT}"
echo "Helper:      ${HELPER_PATH}"
echo "Credentials: ${ENV_FILE}"
echo ""
echo "Start a new \`claude\` session; spans land in Langfuse within ~5s of the first prompt."
echo "Want richer traces? Add OTEL_LOG_TOOL_DETAILS=1 (tool names+args) or"
echo "OTEL_LOG_TOOL_CONTENT=1 (full tool I/O) to ${SETTINGS_FILE}'s env block."
