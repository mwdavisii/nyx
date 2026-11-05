# Go Live / End Live — guest-room lighting + OBS Virtual Camera

Two key-bindable scripts that put the room into "on camera" state and back.

```
golive.sh    launch OBS if it is not running, lights on, then Virtual Camera on
endlive.sh   OBS Virtual Camera off, then lights off
```

Ordering is deliberate: on the way in the room is lit *before* anything starts
transmitting, and on the way out the camera stops *before* the lights snap off,
so nothing on the feed sees the change.

## Prerequisites

1. **The two Home Assistant scripts exist** as `script.go_live` and
   `script.go_live_off` (Settings → Scripts). They own the lighting logic:

   - `Go Live` — Guest Room lamp on at whatever brightness it is at when the
     script runs; Guest Room floor lamp to 100%.
   - `Go Live Off` — both lights off.

2. **A long-lived HA token**, same convention as `~/code/macros/nl116ai-light`:

   ```sh
   echo 'eyJ...' > ~/.config/ha-token && chmod 600 ~/.config/ha-token
   ```

   HA profile → Security → Long-lived access tokens. Admin user required.

3. **OBS WebSocket server enabled** — OBS → Tools → WebSocket Server Settings →
   *Enable WebSocket server*. Port 4455, password whatever it already is; the
   helper reads `server_password` straight out of
   `~/.config/obs-studio/plugin_config/obs-websocket/config.json`, so there is
   nothing to configure here.

4. **Node ≥ 22** for the built-in WebSocket (`node --version`). No npm packages.

`golive.sh` starts OBS for you if it is not running: it probes the WebSocket
server, launches `obs` when nothing answers, and polls until the server responds
(`OBS_START_TIMEOUT`, default 25 s) before starting the camera. A closed OBS is
the one failure a macro key cannot fix by retrying, so it is worth the wait.
`endlive.sh` never launches anything — stopping a camera that is already off is
fine.

Launching needs a graphical session: `obs` is started with the environment the
script inherits, so DISPLAY / WAYLAND_DISPLAY must be set wherever the macro key
runs (a desktop hotkey daemon has them; cron and ssh do not). Change the command
with `OBS_LAUNCH_CMD`.

If you already drive OBS yourself, set `OBS_VCAM_ON` / `OBS_VCAM_OFF` and the
built-in launcher and WebSocket client are bypassed entirely.

## Usage

```sh
./golive.sh              # lights, then camera
./golive.sh --dry-run    # print the steps, touch nothing
./endlive.sh
node obs-vcam.mjs status # on | off
```

Both are idempotent: pressing the key twice does not re-run anything silly.
`obs-vcam.mjs` asks OBS for the current virtual-camera state first and only
sends `StartVirtualCam` / `StopVirtualCam` when it would change something.

Exit codes: `0` done (including "already in that state"), `1` failure,
`2` usage error.

## Configuration

| Variable | Default | Purpose |
|---|---|---|
| `HA_URL` | `http://homeassistant.mwdavisii.com:8123` | HA base URL |
| `HA_TOKEN` | — | token value; overrides the file |
| `HA_TOKEN_FILE` | `~/.config/ha-token` | token file |
| `LIVE_SCRIPT` | `script.go_live` | script entity `golive.sh` runs |
| `LIVE_SCRIPT_OFF` | `script.go_live_off` | script entity `endlive.sh` runs |
| `GUEST_LAMP` | `light.guest_room_lamp_3` | polled after the call (warn-only) |
| `FLOOR_LAMP` | `light.guest_room_floor_lamp` | polled after the call (warn-only) |
| `OBS_VCAM_ON` / `OBS_VCAM_OFF` | — | shell command to run instead of `obs-vcam.mjs` |
| `OBS_LAUNCH_CMD` | `obs` | command `golive.sh` runs when OBS is not reachable |
| `OBS_START_TIMEOUT` | `25` | seconds to wait for the launched OBS to answer |
| `OBS_WS_URL` | `ws://127.0.0.1:4455` | OBS WebSocket endpoint |
| `OBS_WS_PASSWORD` | from OBS config | overrides the password read from disk |
| `OBS_WS_CONFIG` | `.../obs-websocket/config.json` | where to read the password from |
| `SKIP_LIGHTS` / `SKIP_OBS` | `0` | set to `1` to run only one half |

If you already have OBS virtual-camera commands you like, point the scripts at
them and `obs-vcam.mjs` never runs:

```sh
OBS_VCAM_ON='obs-cli virtualcam start' OBS_VCAM_OFF='obs-cli virtualcam stop' ./golive.sh
```

## What has and has not been tested

`node selftest.mjs` runs the whole pair against a mock Home Assistant REST API
and a mock OBS WebSocket v5 server (auth handshake included), 17 assertions: the
normal cycle, ordering, idempotency, dry-run, and every failure path — wrong
password, no server, and `OBS_LAUNCH_CMD` both succeeding (via `mock-obs.mjs`)
and never coming up. No OBS, no HA, no token needed.

The Home Assistant half has also been run against the real instance, with both
scripts installed via `POST /api/config/script/config/{id}`:

- `golive.sh` with the lamp on at 69 → lamp unchanged at 69, floor lamp to 255.
- `golive.sh` with the lamp off → both on, lamp restored to 69 by its own
  `power_on_behavior: previous`.
- `endlive.sh` → both off, in both cases.
- The room was restored to its prior state afterwards.

**Light entity ids are verified** against the live instance (`/api/states`,
831 entities):

| Friendly name | entity_id | Notes |
|---|---|---|
| Guest Room Lamp | `light.guest_room_lamp_3` | on, brightness 69; the `_3` suffix is real |
| Floor Lamp (Guest Room) | `light.guest_room_floor_lamp` | off; `Den Room Floor Lamp` / `Living Room Floor Lamp` are different lights |

Both are dimmable (`color_temp`, `hs`, `xy`). The brightness templates were
rendered against the live instance with `/api/template`: the lamp returns `69`
and takes the "re-apply brightness" branch, the floor lamp returns `0` and takes
the fallback branch.

OBS is live-verified too: the WebSocket server is enabled on 4455 with auth,
`node obs-vcam.mjs status` reads `on`/`off`, and full `./golive.sh` →
`./endlive.sh` cycles started and stopped the real virtual camera while driving
the real lights.

The launch path is only exercised against `mock-obs.mjs`, not by closing a
running OBS. A real cold start additionally depends on `obs` being launchable
from whatever session the macro key runs in.

A bad light id only produces a warning (the stream must not fail because a lamp
is unreachable); a bad script id fails the run before the camera is touched.

## Known limits

- **A sleeping bulb can take ~10 s.** Measured on the floor lamp: 10.6 s the
  first time after being off, then ~235 ms. The scripts wait up to 2 s per light
  for confirmation and then continue anyway — the camera is the critical path,
  so a slow bulb delays nothing but prints `did not report 'on' within 2s`.
  The light does come on; only the confirmation is late.
- The 2 s wait is per light and sequential, so a cold floor lamp plus a slow
  Guest Room lamp can add up to ~4 s before the camera starts.

## Binding it to a key

In nyx these are packaged by the streaming module: set
`nyx.modules.app.streaming.golive.enable = true;` on a host and home-manager
installs `golive` / `endlive` on `PATH` (wrapped with curl, jq and node) and
adds `golive` to `wayland.windowManager.hyprland.extraLuaFiles`, so
`~/.config/hypr/golive.lua` is written and required by the generated
`hyprland.lua`. It binds:

| Keys | Command |
|---|---|
| `SUPER + T` | `golive` |
| `SUPER + SHIFT + T` | `endlive` |

`selftest.mjs` and `mock-obs.mjs` stay in the source tree only; they are not
installed.

Nothing here holds state, so an accidental double-fire, a lost network, or a
half-pressed key leaves you in a defined state rather than a stuck one — the
worst case is lights on with the camera off, which is exactly what the next
`endlive.sh` fixes.
