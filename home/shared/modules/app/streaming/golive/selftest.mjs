// Self-test for golive/endlive/obs-vcam.mjs: mock Home Assistant REST API plus a
// mock OBS WebSocket v5 server. Run with:  node selftest.mjs
// No network, no OBS, no HA instance, no token needed.
import http from "node:http";
import crypto from "node:crypto";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
const execFileP = promisify(execFile);

import { fileURLToPath } from "node:url";
import { mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
const DIR = fileURLToPath(new URL(".", import.meta.url)).replace(/\/$/, "");
// Generated per run: the mock OBS server only needs both sides to agree.
const PASSWORD = crypto.randomBytes(12).toString("hex");
const SALT = "salt-abc";
const CHALLENGE = "challenge-xyz";

const states = { "light.guest_room_lamp_3": "off", "light.guest_room_floor_lamp": "off" };
let obsActive = false;
const calls = [];

// ---------- mock Home Assistant ----------
const ha = http.createServer((req, res) => {
  const url = new URL(req.url, "http://x");
  calls.push(`${req.method} ${url.pathname}`);
  if (req.method === "POST" && url.pathname === "/api/services/script/turn_on") {
    let body = "";
    req.on("data", (c) => (body += c));
    req.on("end", () => {
      const entity = JSON.parse(body).entity_id;
      calls.push(`script=${entity}`);
      for (const k of Object.keys(states)) states[k] = entity.includes("off") ? "off" : "on";
      res.writeHead(200, { "content-type": "application/json" }).end("[]");
    });
    return;
  }
  if (req.method === "GET" && url.pathname.startsWith("/api/states/")) {
    const e = url.pathname.slice("/api/states/".length);
    if (!(e in states)) return res.writeHead(404).end("{}");
    return res
      .writeHead(200, { "content-type": "application/json" })
      .end(JSON.stringify({ entity_id: e, state: states[e] }));
  }
  res.writeHead(404).end("{}");
});

// ---------- minimal mock OBS WebSocket server ----------
const GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
const sha256b64 = (s) => crypto.createHash("sha256").update(s).digest("base64");

function frame(str) {
  const p = Buffer.from(str);
  if (p.length < 126) return Buffer.concat([Buffer.from([0x81, p.length]), p]);
  const h = Buffer.alloc(4);
  h[0] = 0x81;
  h[1] = 126;
  h.writeUInt16BE(p.length, 2);
  return Buffer.concat([h, p]);
}

function closeFrame(code) {
  const b = Buffer.alloc(4);
  b[0] = 0x88;
  b[1] = 2;
  b.writeUInt16BE(code, 2);
  return b;
}

function parse(buf) {
  const out = [];
  let off = 0;
  while (off + 2 <= buf.length) {
    const opcode = buf[off] & 0x0f;
    const masked = (buf[off + 1] & 0x80) !== 0;
    let len = buf[off + 1] & 0x7f;
    let p = off + 2;
    if (len === 126) {
      len = buf.readUInt16BE(p);
      p += 2;
    }
    const mask = masked ? buf.subarray(p, p + 4) : null;
    if (masked) p += 4;
    if (p + len > buf.length) break;
    const data = Buffer.from(buf.subarray(p, p + len));
    if (mask) for (let i = 0; i < data.length; i++) data[i] ^= mask[i % 4];
    if (opcode === 1) out.push(data.toString());
    off = p + len;
  }
  return out;
}

const obs = http.createServer();
obs.on("upgrade", (req, socket) => {
  const key = req.headers["sec-websocket-key"];
  socket.write(
    "HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n" +
      `Sec-WebSocket-Accept: ${crypto.createHash("sha1").update(key + GUID).digest("base64")}\r\n\r\n`,
  );
  socket.write(frame(JSON.stringify({ op: 0, d: { rpcVersion: 1, authentication: { challenge: CHALLENGE, salt: SALT } } })));

  let buf = Buffer.alloc(0);
  socket.on("data", (chunk) => {
    buf = Buffer.concat([buf, chunk]);
    for (const text of parse(buf)) {
      buf = Buffer.alloc(0);
      const msg = JSON.parse(text);
      if (msg.op === 1) {
        const expected = sha256b64(sha256b64(PASSWORD + SALT) + CHALLENGE);
        if (msg.d.authentication !== expected) {
          calls.push("obs: auth FAILED");
          socket.write(closeFrame(4009));
          socket.end();
          return;
        }
        calls.push("obs: identified");
        socket.write(frame(JSON.stringify({ op: 2, d: { negotiatedRpcVersion: 1 } })));
      }
      if (msg.op === 6) {
        const { requestType, requestId } = msg.d;
        calls.push(`obs: ${requestType}`);
        if (requestType === "GetVirtualCamStatus")
          socket.write(frame(JSON.stringify({ op: 7, d: { requestId, requestStatus: { result: true, code: 100 }, responseData: { outputActive: obsActive } } })));
        else if (requestType === "StartVirtualCam" || requestType === "StopVirtualCam") {
          obsActive = requestType === "StartVirtualCam";
          socket.write(frame(JSON.stringify({ op: 7, d: { requestId, requestStatus: { result: true, code: 100 } } })));
        }
      }
    }
  });
  socket.on("error", () => {});
});

const env = (extra = {}) => ({
  ...process.env,
  HA_TOKEN: "dummy-token",
  HA_URL: `http://127.0.0.1:${ha.address().port}`,
  OBS_WS_URL: `ws://127.0.0.1:${obs.address().port}`,
  OBS_WS_PASSWORD: PASSWORD,
  ...extra,
});

const run = async (script, extraEnv = {}, args = []) => {
  calls.length = 0;
  const r = await execFileP(`${DIR}/${script}`, args, { encoding: "utf8", env: env(extraEnv), timeout: 15000 }).then(
    (x) => ({ status: 0, out: x.stdout + x.stderr }),
    (e) => ({ status: e.code ?? 1, out: `${e.stdout ?? ""}${e.stderr ?? ""}${e.message ?? ""}` }),
  );
  return { code: r.status, out: r.out.trim(), calls: [...calls], states: { ...states }, obs: obsActive };
};

const runNode = async (args, extraEnv = {}) => {
  const r = await execFileP("node", args, { encoding: "utf8", env: env(extraEnv), timeout: 15000 }).then(
    (x) => ({ status: 0, out: x.stdout + x.stderr }),
    (e) => ({ status: e.code ?? 1, out: `${e.stdout ?? ""}${e.stderr ?? ""}${e.message ?? ""}` }),
  );
  return { status: r.status, out: r.out.trim(), calls: [] };
};

await new Promise((r) => ha.listen(0, "127.0.0.1", r));
await new Promise((r) => obs.listen(0, "127.0.0.1", r));

const results = {};
results["1 go-live from off"] = await run("golive.sh");
results["2 go-live again (idempotent)"] = await run("golive.sh");
results["3 end-live"] = await run("endlive.sh");
results["4 end-live again (idempotent)"] = await run("endlive.sh");
results["5 dry-run"] = await run("golive.sh", {}, ["--dry-run"]);
results["6 obs status"] = await runNode([`${DIR}/obs-vcam.mjs`, "status"]);
results["7 wrong password"] = await run("golive.sh", {
  OBS_WS_PASSWORD: "nope",
  OBS_LAUNCH_CMD: "echo SHOULD-NOT-LAUNCH",
});
results["8 no OBS listening"] = await runNode([`${DIR}/obs-vcam.mjs`, "status"], {
  OBS_WS_URL: "ws://127.0.0.1:1",
});

// OBS closed: golive.sh should launch it (OBS_LAUNCH_CMD) and wait for the
// WebSocket server instead of failing.
const freePort = await new Promise((res) => {
  const s = http.createServer();
  s.listen(0, "127.0.0.1", () => {
    const p = s.address().port;
    s.close(() => res(p));
  });
});
const pidDir = mkdtempSync(join(tmpdir(), "golive-selftest-"));
const pidFile = join(pidDir, "mock-obs.pid");
results["9 launches OBS when closed"] = await run("golive.sh", {
  OBS_WS_URL: `ws://127.0.0.1:${freePort}`,
  OBS_WS_PASSWORD: "",
  OBS_LAUNCH_CMD: `node ${DIR}/mock-obs.mjs ${freePort} ${pidFile}`,
  OBS_START_TIMEOUT: "10",
});
try {
  process.kill(Number(readFileSync(pidFile, "utf8")), "SIGTERM");
} catch {}
rmSync(pidDir, { recursive: true, force: true });

results["10 launch that never comes up"] = await run("golive.sh", {
  OBS_WS_URL: `ws://127.0.0.1:1`,
  OBS_WS_PASSWORD: "",
  OBS_LAUNCH_CMD: "true",
  OBS_START_TIMEOUT: "1",
});

for (const [name, r] of Object.entries(results)) {
  console.log(`\n=== ${name} ===`);
  if (r.code !== undefined) {
    console.log(`exit=${r.code} obs=${r.obs} lights=${JSON.stringify(r.states)}`);
    console.log(`calls: ${r.calls.join(" -> ")}`);
  } else {
    console.log(`exit=${r.status}`);
  }
  console.log(`out: ${(r.out ?? `${r.stdout}${r.stderr}`).trim()}`);
}

ha.close();
obs.close();

const checks = [
  ["go-live succeeds", results["1 go-live from off"].code === 0],
  ["go-live starts the camera", results["1 go-live from off"].obs === true],
  ["go-live lights both lamps", Object.values(results["1 go-live from off"].states).every((v) => v === "on")],
  [
    "go-live lights before camera",
    results["1 go-live from off"].calls.findIndex((c) => c.startsWith("POST")) <
      results["1 go-live from off"].calls.indexOf("obs: StartVirtualCam"),
  ],
  ["go-live is idempotent", results["2 go-live again (idempotent)"].code === 0 && !results["2 go-live again (idempotent)"].calls.includes("obs: StartVirtualCam")],
  ["end-live succeeds", results["3 end-live"].code === 0],
  ["end-live stops the camera", results["3 end-live"].obs === false],
  ["end-live lights off", Object.values(results["3 end-live"].states).every((v) => v === "off")],
  [
    "end-live camera before lights",
    results["3 end-live"].calls.indexOf("obs: StopVirtualCam") < results["3 end-live"].calls.findIndex((c) => c.startsWith("POST")),
  ],
  ["end-live is idempotent", results["4 end-live again (idempotent)"].code === 0 && !results["4 end-live again (idempotent)"].calls.includes("obs: StopVirtualCam")],
  ["dry-run touches nothing", results["5 dry-run"].code === 0 && results["5 dry-run"].calls.length === 0],
  ["status reports off", results["6 obs status"].status === 0 && results["6 obs status"].out === "off"],
  [
    "wrong password fails loudly without launching OBS",
    results["7 wrong password"].code === 1 &&
      /rejected the WebSocket password/.test(results["7 wrong password"].out) &&
      !/SHOULD-NOT-LAUNCH/.test(results["7 wrong password"].out) &&
      !/launching:/.test(results["7 wrong password"].out),
  ],
  ["missing OBS fails loudly", results["8 no OBS listening"].status === 1 && /cannot reach/.test(results["8 no OBS listening"].out)],
  ["golive launches OBS when closed", results["9 launches OBS when closed"].code === 0 && /launching:/.test(results["9 launches OBS when closed"].out) && /OBS ready/.test(results["9 launches OBS when closed"].out)],
  ["launched OBS gets the camera", /virtual camera on/.test(results["9 launches OBS when closed"].out)],
  ["dead launch times out loudly", results["10 launch that never comes up"].code === 1 && /did not become reachable/.test(results["10 launch that never comes up"].out)],
];

console.log("\n=== assertions ===");
let failed = 0;
for (const [name, ok] of checks) {
  console.log(`${ok ? "PASS" : "FAIL"}  ${name}`);
  if (!ok) failed++;
}
console.log(failed ? `\n${failed} check(s) failed` : "\nall checks passed");
process.exit(failed ? 1 : 0);
