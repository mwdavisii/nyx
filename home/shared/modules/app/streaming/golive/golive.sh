#!/usr/bin/env bash
# Go live: make sure OBS is running, guest-room lighting preset, then OBS
# Virtual Camera on.
#
#   ./golive.sh            # lights first, then camera
#   ./golive.sh --dry-run  # print the steps without running them
#
# If OBS is not running (or its WebSocket server is unreachable) it is launched
# first and waited for, so the macro key works from a cold desktop. Set
# OBS_LAUNCH_CMD to change how it is launched. A second OBS is never started: if
# an "obs" process already exists (OBS_PROCESS_NAME) but its socket does not
# answer, the run fails instead of launching a duplicate.
#
# The lighting half runs the Home Assistant script "Go Live"
# (script.go_live) - it sets the Guest Room lamp to whatever brightness it is
# at right now and the Guest Room floor lamp to 100%.
#
# Home Assistant needs a long-lived token, same convention as ~/code/macros/nl116ai-light:
#   HA profile -> Long-lived access tokens -> create, then
#   echo 'eyJ...' > ~/.config/ha-token && chmod 600 ~/.config/ha-token
#
# OBS control goes through obs-vcam.mjs (OBS WebSocket v5), or through your own
# command if you already have one:
#   OBS_VCAM_ON='obs-cli virtualcam start' ./golive.sh
#
# Toggles: SKIP_LIGHTS=1, SKIP_OBS=1. Overrides: HA_URL, HA_TOKEN, HA_TOKEN_FILE,
# LIVE_SCRIPT, GUEST_LAMP, FLOOR_LAMP, OBS_WS_URL, OBS_WS_PASSWORD,
# OBS_LAUNCH_CMD, OBS_START_TIMEOUT, OBS_PROCESS_NAME.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HA_URL="${HA_URL:-http://homeassistant.mwdavisii.com:8123}"
TOKEN_FILE="${HA_TOKEN_FILE:-$HOME/.config/ha-token}"
SCRIPT="${LIVE_SCRIPT:-script.go_live}"
GUEST_LAMP="${GUEST_LAMP:-light.guest_room_lamp_3}"
FLOOR_LAMP="${FLOOR_LAMP:-light.guest_room_floor_lamp}"
OBS_LAUNCH_CMD="${OBS_LAUNCH_CMD:-obs}"
OBS_PROCESS_NAME="${OBS_PROCESS_NAME:-obs}"
OBS_START_TIMEOUT="${OBS_START_TIMEOUT:-25}"

DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    -n|--dry-run) DRY_RUN=1 ;;
    -h|--help) sed -n '2,/^$/p' "$0"; exit 0 ;;
    *) echo "golive: unknown argument: $arg" >&2; exit 2 ;;
  esac
done

die() { echo "golive: $*" >&2; exit 1; }
say() { echo "golive: $*"; }

run() {
  if ((DRY_RUN)); then
    printf 'golive: [dry-run] %s\n' "$*"
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

# Poll an entity until it reports $2, then give up quietly: a wrong/unavailable
# entity id should not stop the stream from going live.
wait_state() {
  local entity="$1" want="$2" i
  for i in $(seq 1 20); do
    if [[ "$(api "$HA_URL/api/states/$entity" 2>/dev/null | jq -r .state 2>/dev/null)" == "$want" ]]; then
      return 0
    fi
    sleep 0.1
  done
  echo "golive: $entity did not report '$want' within 2s (continuing)" >&2
}

# OBS closed is the one failure a macro key cannot fix by retrying, so launch it
# and wait for the WebSocket server rather than dying. Everything else fails
# with the real reason: auth rejection, and "OBS is up but its virtual camera is
# unavailable" (exit 3) both mean launching a second OBS is useless.
ensure_obs() {
  local out rc=0

  out="$(node "$HERE/obs-vcam.mjs" status 2>&1)" || rc=$?
  case "$rc" in
    0) return 0 ;;
    1) ;;
    3) die "OBS is running but cannot provide a virtual camera: ${out#obs: }" ;;
    *) die "OBS status check failed (exit $rc): $out" ;;
  esac
  case "$out" in
    *"authentication failed"*)
      die "OBS is running but rejected the WebSocket password: $out"
      ;;
    *"cannot reach"*) ;;
    *)
      die "OBS status check failed: $out"
      ;;
  esac

  # The socket is dead but the process may still be alive with its WebSocket
  # server disabled - launching again would just create a second OBS.
  if command -v pgrep >/dev/null && pgrep -x "$OBS_PROCESS_NAME" >/dev/null 2>&1; then
    die "OBS is running (${OBS_PROCESS_NAME}, pid $(pgrep -x "$OBS_PROCESS_NAME" | tr '\n' ' ' | sed 's/ $//')) but its WebSocket server is unreachable - check Tools > WebSocket Server Settings in OBS"
  fi

  say "OBS not reachable, launching: $OBS_LAUNCH_CMD"
  nohup bash -c "$OBS_LAUNCH_CMD" >/dev/null 2>&1 &

  # Backoff: probe hard for the first two seconds, then once a second, so a
  # timeout costs a couple of dozen connections instead of a hundred (every one
  # of them is a desktop notification when obs-websocket alerts are on).
  local i=0 delay deadline=$((SECONDS + OBS_START_TIMEOUT))
  while ((SECONDS < deadline)); do
    rc=0
    out="$(node "$HERE/obs-vcam.mjs" status 2>&1)" || rc=$?
    if ((rc == 0)); then
      say "OBS ready"
      return 0
    fi
    case "$rc" in
      3) die "OBS is running but cannot provide a virtual camera: ${out#obs: }" ;;
      1) ;;
      *) die "OBS status check failed (exit $rc): $out" ;;
    esac
    case "$out" in
      *"authentication failed"*)
        die "OBS is running but rejected the WebSocket password: $out"
        ;;
    esac
    if ((i < 8)); then delay=0.25; else delay=1; fi
    i=$((i + 1))
    sleep "$delay"
  done
  die "OBS did not become reachable within ${OBS_START_TIMEOUT}s (launched: $OBS_LAUNCH_CMD)"
}

obs_on() {
  if [[ -n "${OBS_VCAM_ON:-}" ]]; then
    run bash -c "$OBS_VCAM_ON"
    return 0
  fi
  if ((DRY_RUN)); then
    printf 'golive: [dry-run] ensure OBS is reachable (launch "%s" first if not), then: node obs-vcam.mjs start\n' "$OBS_LAUNCH_CMD"
    return 0
  fi
  ensure_obs
  node "$HERE/obs-vcam.mjs" start ||
    die "the virtual camera could not be started (see the error above)"
}

command -v node >/dev/null || die "node not found (needed for $HERE/obs-vcam.mjs)"
command -v jq >/dev/null || die "jq not found"

# 1. Lights: camera-ready before anything starts transmitting.
if [[ "${SKIP_LIGHTS:-0}" != 1 ]]; then
  if ((DRY_RUN)); then
    printf 'golive: [dry-run] POST %s/api/services/script/turn_on entity_id=%s\n' "$HA_URL" "$SCRIPT"
  else
    api -X POST "$HA_URL/api/services/script/turn_on" -d "{\"entity_id\":\"$SCRIPT\"}" >/dev/null
    wait_state "$FLOOR_LAMP" on
    wait_state "$GUEST_LAMP" on
    say "lights on ($SCRIPT)"
  fi
fi

# 2. Camera.
if [[ "${SKIP_OBS:-0}" != 1 ]]; then
  obs_on
fi

say "live"
