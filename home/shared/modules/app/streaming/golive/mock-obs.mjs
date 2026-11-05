#!/usr/bin/env node
/**
 * mock-obs.mjs - stand-in OBS WebSocket v5 server for testing the launch path.
 *
 *   node mock-obs.mjs <port> <pidfile> [password]
 *
 * Accepts any password if none is given. Writes its pid to <pidfile> so a test
 * can shut it down. Not used by golive.sh; only by selftest.mjs.
 */
import http from "node:http";
import crypto from "node:crypto";
import { writeFileSync } from "node:fs";

const port = Number(process.argv[2] ?? 4455);
const pidFile = process.argv[3];
const PASSWORD = process.argv[4] ?? "";
const SALT = "salt-abc";
const CHALLENGE = "challenge-xyz";
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

let active = false;
const server = http.createServer();
server.on("upgrade", (req, socket) => {
  const accept = crypto
    .createHash("sha1")
    .update(req.headers["sec-websocket-key"] + GUID)
    .digest("base64");
  socket.write(
    "HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n" +
      `Sec-WebSocket-Accept: ${accept}\r\n\r\n`,
  );
  socket.write(
    frame(JSON.stringify({ op: 0, d: { rpcVersion: 1, authentication: { challenge: CHALLENGE, salt: SALT } } })),
  );

  let buf = Buffer.alloc(0);
  socket.on("data", (chunk) => {
    buf = Buffer.concat([buf, chunk]);
    for (const text of parse(buf)) {
      buf = Buffer.alloc(0);
      const msg = JSON.parse(text);
      if (msg.op === 1) {
        if (
          PASSWORD &&
          msg.d.authentication !== sha256b64(sha256b64(PASSWORD + SALT) + CHALLENGE)
        ) {
          socket.write(closeFrame(4009));
          socket.end();
          return;
        }
        socket.write(frame(JSON.stringify({ op: 2, d: { negotiatedRpcVersion: 1 } })));
      }
      if (msg.op === 6) {
        const { requestType, requestId } = msg.d;
        if (requestType === "GetVirtualCamStatus") {
          socket.write(
            frame(JSON.stringify({ op: 7, d: { requestId, requestStatus: { result: true, code: 100 }, responseData: { outputActive: active } } })),
          );
        } else if (requestType === "StartVirtualCam" || requestType === "StopVirtualCam") {
          active = requestType === "StartVirtualCam";
          socket.write(frame(JSON.stringify({ op: 7, d: { requestId, requestStatus: { result: true, code: 100 } } })));
        }
      }
    }
  });
  socket.on("error", () => {});
});

server.listen(port, "127.0.0.1", () => {
  if (pidFile) writeFileSync(pidFile, String(process.pid));
});
