#!/usr/bin/env node
/**
 * obs-vcam.mjs - start/stop the OBS Virtual Camera over OBS WebSocket v5.
 *
 *   node obs-vcam.mjs start | stop | status
 *
 * No dependencies: uses Node's built-in WebSocket (Node >= 22).
 *
 * Environment:
 *   OBS_WS_URL       default ws://127.0.0.1:4455
 *   OBS_WS_PASSWORD  default: server_password read from OBS_WS_CONFIG
 *   OBS_WS_CONFIG    default ~/.config/obs-studio/plugin_config/obs-websocket/config.json
 *
 * Exit: 0 = done (also when already in the requested state), 1 = failure, 2 = usage.
 */
import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const cmd = process.argv[2] ?? "status";
const DESIRED = { start: true, stop: false };
if (!["start", "stop", "status"].includes(cmd)) {
  console.error("usage: obs-vcam.mjs start|stop|status");
  process.exit(2);
}

const url = process.env.OBS_WS_URL ?? "ws://127.0.0.1:4455";

function password() {
  if (process.env.OBS_WS_PASSWORD !== undefined) return process.env.OBS_WS_PASSWORD;
  const file =
    process.env.OBS_WS_CONFIG ??
    join(homedir(), ".config/obs-studio/plugin_config/obs-websocket/config.json");
  try {
    return JSON.parse(readFileSync(file, "utf8")).server_password ?? "";
  } catch {
    return "";
  }
}

const fail = (msg) => {
  console.error(`obs: ${msg}`);
  process.exit(1);
};

const timer = setTimeout(() => fail(`timeout talking to ${url}`), 8000);
timer.unref();

let ws;
try {
  ws = new WebSocket(url);
} catch (err) {
  fail(`cannot open ${url}: ${err.message}`);
}

let identified = false;

// Connection failures surface as 'error' immediately followed by 'close'; the
// close code carries the useful part, so this handler only keeps the event
// from being unhandled.
ws.addEventListener("error", () => {});

ws.addEventListener("close", (ev) => {
  if (identified) return;
  if (ev.code === 4009) fail("authentication failed - check the OBS WebSocket password");
  if (ev.code === 1006)
    fail(
      `cannot reach ${url} - is OBS running with the WebSocket server enabled? (Tools > WebSocket Server Settings)`,
    );
  fail(`closed before identify (code ${ev.code})`);
});

ws.addEventListener("message", (ev) => {
  let msg;
  try {
    msg = JSON.parse(String(ev.data));
  } catch {
    return;
  }

  // op 0 = Hello
  if (msg.op === 0) {
    const hello = msg.d ?? {};
    const identify = { rpcVersion: 1, eventSubscriptions: 0 };
    if (hello.authentication) {
      const secret = createHash("sha256")
        .update(password() + hello.authentication.salt)
        .digest("base64");
      identify.authentication = createHash("sha256")
        .update(secret + hello.authentication.challenge)
        .digest("base64");
    }
    ws.send(JSON.stringify({ op: 1, d: identify }));
    return;
  }

  // op 2 = Identified
  if (msg.op === 2) {
    identified = true;
    ws.send(
      JSON.stringify({ op: 6, d: { requestType: "GetVirtualCamStatus", requestId: "status" } }),
    );
    return;
  }

  // op 7 = RequestResponse
  if (msg.op === 7) {
    const { requestId, requestStatus, responseData } = msg.d ?? {};
    if (requestStatus?.result === false) {
      fail(`${requestId}: ${requestStatus.comment || `error ${requestStatus.code}`}`);
    }
    const active = responseData?.outputActive;

    if (requestId === "status") {
      if (cmd === "status") {
        console.log(active ? "on" : "off");
        ws.close();
        process.exit(0);
      }
      if (active === DESIRED[cmd]) {
        console.log(`virtual camera already ${active ? "on" : "off"}`);
        ws.close();
        process.exit(0);
      }
      ws.send(
        JSON.stringify({
          op: 6,
          d: {
            requestType: cmd === "start" ? "StartVirtualCam" : "StopVirtualCam",
            requestId: "action",
          },
        }),
      );
      return;
    }

    if (requestId === "action") {
      console.log(`virtual camera ${cmd === "start" ? "on" : "off"}`);
      ws.close();
      process.exit(0);
    }
  }
});
