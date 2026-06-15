import http from "node:http";

const PORT = Number(process.env.PORT || 3000);
const ACTIVE_WINDOW_MS = Number(process.env.ACTIVE_WINDOW_MS || 5 * 60 * 1000);
const STATS_TOKEN = process.env.STATS_TOKEN || "";
const MAX_BODY_BYTES = 32 * 1024;

const startedAt = Date.now();
const sessions = new Map();
const totals = {
  launches: 0,
  heartbeats: 0,
  pings: 0,
};
const versions = new Map();
const places = new Map();

function send(res, status, payload, contentType = "application/json") {
  const body = contentType === "application/json" ? JSON.stringify(payload, null, 2) : payload;
  res.writeHead(status, {
    "Content-Type": contentType,
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type,X-Stats-Token,X-0xVyrs-Version",
    "Cache-Control": "no-store",
  });
  res.end(body);
}

function readJson(req) {
  return new Promise((resolve, reject) => {
    let body = "";
    req.on("data", (chunk) => {
      body += chunk;
      if (Buffer.byteLength(body) > MAX_BODY_BYTES) {
        reject(new Error("body too large"));
        req.destroy();
      }
    });
    req.on("end", () => {
      if (!body) {
        resolve({});
        return;
      }
      try {
        resolve(JSON.parse(body));
      } catch {
        reject(new Error("invalid json"));
      }
    });
    req.on("error", reject);
  });
}

function increment(map, key) {
  const safeKey = String(key || "unknown").slice(0, 80);
  map.set(safeKey, (map.get(safeKey) || 0) + 1);
}

function pruneSessions(now = Date.now()) {
  for (const [sessionId, session] of sessions) {
    if (now - session.lastSeen > ACTIVE_WINDOW_MS) {
      sessions.delete(sessionId);
    }
  }
}

function getStats() {
  const now = Date.now();
  pruneSessions(now);

  const activeByVersion = {};
  const activeByPlace = {};
  for (const session of sessions.values()) {
    activeByVersion[session.version] = (activeByVersion[session.version] || 0) + 1;
    activeByPlace[session.placeId] = (activeByPlace[session.placeId] || 0) + 1;
  }

  return {
    ok: true,
    uptimeSeconds: Math.floor((now - startedAt) / 1000),
    activeWindowSeconds: Math.floor(ACTIVE_WINDOW_MS / 1000),
    activeUsers: sessions.size,
    totals,
    launchesByVersion: Object.fromEntries(versions),
    launchesByPlace: Object.fromEntries(places),
    activeByVersion,
    activeByPlace,
  };
}

function statsAllowed(req, url) {
  if (!STATS_TOKEN) {
    return true;
  }
  return req.headers["x-stats-token"] === STATS_TOKEN || url.searchParams.get("token") === STATS_TOKEN;
}

function dashboardHtml() {
  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>0xVyrs ESP Telemetry</title>
  <style>
    body { margin: 0; font-family: system-ui, Segoe UI, sans-serif; background: #11151d; color: #f4f6fc; }
    main { max-width: 920px; margin: 0 auto; padding: 32px 18px; }
    h1 { margin: 0 0 18px; font-size: 24px; }
    .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; }
    .card { background: #1d202b; border: 1px solid #4e5466; border-radius: 8px; padding: 14px; }
    .label { color: #acb4c8; font-size: 12px; font-weight: 700; }
    .value { font-size: 28px; font-weight: 800; margin-top: 6px; }
    pre { overflow: auto; background: #171b24; border: 1px solid #4e5466; border-radius: 8px; padding: 14px; }
  </style>
</head>
<body>
  <main>
    <h1>0xVyrs ESP Telemetry</h1>
    <div class="grid">
      <div class="card"><div class="label">ACTIVE USERS</div><div class="value" id="active">--</div></div>
      <div class="card"><div class="label">LAUNCHES</div><div class="value" id="launches">--</div></div>
      <div class="card"><div class="label">PING TOTAL</div><div class="value" id="pings">--</div></div>
      <div class="card"><div class="label">UPTIME</div><div class="value" id="uptime">--</div></div>
    </div>
    <pre id="raw">Loading...</pre>
  </main>
  <script>
    const params = new URLSearchParams(location.search);
    async function refresh() {
      const suffix = params.has("token") ? "?token=" + encodeURIComponent(params.get("token")) : "";
      const res = await fetch("/api/stats" + suffix);
      const data = await res.json();
      active.textContent = data.activeUsers;
      launches.textContent = data.totals.launches;
      pings.textContent = data.totals.pings;
      uptime.textContent = Math.floor(data.uptimeSeconds / 60) + "m";
      raw.textContent = JSON.stringify(data, null, 2);
    }
    refresh();
    setInterval(refresh, 5000);
  </script>
</body>
</html>`;
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url || "/", `http://${req.headers.host || "localhost"}`);

  if (req.method === "OPTIONS") {
    send(res, 204, {});
    return;
  }

  if (req.method === "GET" && url.pathname === "/health") {
    send(res, 200, { ok: true });
    return;
  }

  if (req.method === "GET" && url.pathname === "/") {
    if (!statsAllowed(req, url)) {
      send(res, 401, { ok: false, error: "unauthorized" });
      return;
    }
    send(res, 200, dashboardHtml(), "text/html; charset=utf-8");
    return;
  }

  if (req.method === "GET" && url.pathname === "/api/stats") {
    if (!statsAllowed(req, url)) {
      send(res, 401, { ok: false, error: "unauthorized" });
      return;
    }
    send(res, 200, getStats());
    return;
  }

  if (req.method === "POST" && url.pathname === "/api/ping") {
    try {
      const data = await readJson(req);
      const now = Date.now();
      const event = data.event === "heartbeat" ? "heartbeat" : "launch";
      const sessionId = String(data.sessionId || "").replace(/[^a-zA-Z0-9-]/g, "").slice(0, 80);

      if (!sessionId) {
        send(res, 400, { ok: false, error: "missing sessionId" });
        return;
      }

      const version = String(data.version || "unknown").slice(0, 40);
      const placeId = String(data.placeId || "unknown").slice(0, 40);

      sessions.set(sessionId, {
        version,
        placeId,
        lastSeen: now,
      });

      totals.pings += 1;
      if (event === "heartbeat") {
        totals.heartbeats += 1;
      } else {
        totals.launches += 1;
        increment(versions, version);
        increment(places, placeId);
      }

      pruneSessions(now);
      send(res, 200, { ok: true, activeUsers: sessions.size });
    } catch (error) {
      send(res, 400, { ok: false, error: error.message });
    }
    return;
  }

  send(res, 404, { ok: false, error: "not found" });
});

server.listen(PORT, () => {
  console.log(`0xVyrs telemetry listening on ${PORT}`);
});
