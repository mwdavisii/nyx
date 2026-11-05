#!/usr/bin/env bash
# End live: OBS Virtual Camera off, then guest-room lighting off.
#
#   ./endlive.sh            # camera first, then lights
#   ./endlive.sh --dry-run  # print the steps without running them
#
# Runs the Home Assistant script "Go Live Off" (script.go_live_off), which turns
# both guest-room lights off.
#
# Home Assistant needs a long-lived token, same convention as ~/code/macros/nl116ai-light:
#   echo 'eyJ...' > ~/.config/ha-token && chmod 600 ~/.config/ha-token
#
# OBS is driven through obs-vcam.mjs (OBS WebSocket v5), or through your own
# command if you already have one:
#   OBS_VCAM_OFF='obs-cli virtualcam stop' ./endlive.sh
#
# Toggles: SKIP_LIGHTS=1, SKIP_OBS=1. Overrides: HA_URL, HA_TOKEN, HA_TOKEN_FILE,
# LIVE_SCRIPT_OFF, GUEST_LAMP, FLOOR_LAMP, OBS_WS_URL, OBS_WS_PASSWORD.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HA_URL="${HA_URL:-http://homeassistant.mwdavisii.com:8123}"
TOKEN_FILE="${HA_TOKEN_FILE:-$HOME/.config/ha-token}"
SCRIPT="${LIVE_SCRIPT_OFF:-script.go_live_off}"
GUEST_LAMP="${GUEST_LAMP:-light.guest_room_lamp_3}"
FLOOR_LAMP="${FLOOR_LAMP:-light.guest_room_floor_lamp}"

DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    -n|--dry-run) DRY_RUN=1 ;;
    -h|--help) sed -n '2,/^$/p' "$0"; exit 0 ;;
    *) echo "endlive: unknown argument: $arg" >&2; exit 2 ;;
  esac
done

die() { echo "endlive: $*" >&2; exit 1; }
say() { echo "endlive: $*"; }

run() {
  if ((DRY_RUN)); then
    printf 'endlive: [dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

if [[ -z "${HA_TOKEN:-}" ]]; then
  [[ -r "$TOKEN_FILE" ]] ||
    die "missing HA token: $TOKEN_FILE (echo 'eyJ...' > $TOKEN_FILE && chmod 600 $TOKEN_FILE)"
  HA_TOKEN="$(<"$TOKEN_FILE")"
fi

api() {
  curl -fsS --max-time 10 \
    -H "Authorization: Bearer $HA_TOKEN" \
    -H "Content-Type: application/json" \
    "$@"
}

wait_state() {
  local entity="$1" want="$2" i
  for i in $(seq 1 20); do
    if [[ "$(api "$HA_URL/api/states/$entity" 2>/dev/null | jq -r .state 2>/dev/null)" == "$want" ]]; then
      return 0
    fi
    sleep 0.1
  done
  echo "endlive: $entity did not report '$want' within 2s (continuing)" >&2
}

obs_off() {
  if [[ -n "${OBS_VCAM_OFF:-}" ]]; then
    run bash -c "$OBS_VCAM_OFF"
  else
    command -v node >/dev/null || die "node not found (needed for $HERE/obs-vcam.mjs)"
    run node "$HERE/obs-vcam.mjs" stop
  fi
}

# 1. Camera off first, so nothing on the feed sees the lights snap off.
if [[ "${SKIP_OBS:-0}" != 1 ]]; then
  obs_off
fi

# 2. Lights off.
if [[ "${SKIP_LIGHTS:-0}" != 1 ]]; then
  if ((DRY_RUN)); then
    printf 'endlive: [dry-run] POST %s/api/services/script/turn_on entity_id=%s\n' "$HA_URL" "$SCRIPT"
  else
    api -X POST "$HA_URL/api/services/script/turn_on" -d "{\"entity_id\":\"$SCRIPT\"}" >/dev/null
    wait_state "$FLOOR_LAMP" off
    wait_state "$GUEST_LAMP" off
    say "lights off ($SCRIPT)"
  fi
fi

say "off air"
