import http from "node:http";

const PORT = Number(process.env.PORT || 3000);
const ACTIVE_WINDOW_MS = Number(process.env.ACTIVE_WINDOW_MS || 5 * 60 * 1000);
const STATS_TOKEN = process.env.STATS_TOKEN || "";
const DASHBOARD_BACKGROUND_URL = process.env.DASHBOARD_BACKGROUND_URL || "";
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
  const backgroundLayer = DASHBOARD_BACKGROUND_URL
    ? `linear-gradient(90deg, rgba(0, 8, 26, 0.58), rgba(0, 10, 32, 0.78)), url("${String(DASHBOARD_BACKGROUND_URL).replace(/["\\\r\n]/g, "")}")`
    : `radial-gradient(circle at 12% 28%, rgba(0, 98, 255, 0.42), transparent 24%),
       radial-gradient(circle at 88% 28%, rgba(0, 76, 255, 0.35), transparent 24%),
       linear-gradient(90deg, #020716 0%, #06142d 48%, #020716 100%)`;
  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>0xVyrs ESP Telemetry</title>
  <style>
    :root {
      --blue: #1282ff;
      --hot: #2ba4ff;
      --text: #e9f3ff;
      --muted: #75a2e6;
      --panel: rgba(2, 12, 33, 0.62);
      --line: rgba(24, 130, 255, 0.58);
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      min-height: 100vh;
      font-family: Inter, ui-sans-serif, system-ui, Segoe UI, sans-serif;
      background-image: ${backgroundLayer};
      background-size: cover;
      background-position: center;
      background-attachment: fixed;
      color: var(--text);
      overflow-x: hidden;
    }
    body::before {
      content: "";
      position: fixed;
      inset: 0;
      pointer-events: none;
      background:
        linear-gradient(rgba(18, 130, 255, 0.045) 1px, transparent 1px),
        linear-gradient(90deg, rgba(18, 130, 255, 0.04) 1px, transparent 1px),
        radial-gradient(circle at 50% 50%, transparent 0 48%, rgba(0, 0, 0, 0.32) 100%);
      background-size: 42px 42px, 42px 42px, 100% 100%;
      mix-blend-mode: screen;
    }
    main {
      min-height: 100vh;
      display: grid;
      grid-template-rows: auto 1fr auto;
      gap: 24px;
      padding: 28px clamp(18px, 4vw, 58px);
    }
    header, footer {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 18px;
      text-transform: uppercase;
      letter-spacing: 0;
    }
    h1 {
      margin: 0;
      color: var(--hot);
      font-size: clamp(22px, 2.6vw, 40px);
      font-weight: 900;
      text-shadow: 0 0 22px rgba(18, 130, 255, 0.8);
    }
    .sub { color: var(--muted); font-size: 12px; font-weight: 800; }
    .content {
      align-self: center;
      display: grid;
      grid-template-columns: minmax(260px, 420px) minmax(280px, 1fr);
      gap: 18px;
      max-width: 1180px;
      width: 100%;
      margin: 0 auto;
    }
    .panel, .card, pre {
      position: relative;
      background: var(--panel);
      border: 1px solid var(--line);
      border-radius: 8px;
      box-shadow: 0 0 28px rgba(0, 92, 255, 0.24), inset 0 0 22px rgba(0, 92, 255, 0.12);
      backdrop-filter: blur(10px);
    }
    .panel { padding: 18px; }
    .panel::before, .card::before {
      content: "";
      position: absolute;
      inset: -1px;
      border-radius: inherit;
      pointer-events: none;
      border-top: 2px solid rgba(43, 164, 255, 0.8);
      opacity: 0.7;
    }
    .grid { display: grid; grid-template-columns: repeat(2, minmax(128px, 1fr)); gap: 12px; }
    .card { min-height: 104px; padding: 14px; }
    .label { color: var(--muted); font-size: 11px; font-weight: 900; text-transform: uppercase; }
    .value { margin-top: 10px; color: #dfeeff; font-size: 34px; font-weight: 900; text-shadow: 0 0 16px rgba(18, 130, 255, 0.85); }
    .meter {
      height: 5px;
      margin-top: 12px;
      background: rgba(117, 162, 230, 0.18);
      overflow: hidden;
    }
    .meter span { display: block; width: 72%; height: 100%; background: linear-gradient(90deg, var(--blue), #7bd0ff); box-shadow: 0 0 18px var(--blue); }
    pre {
      min-height: 330px;
      max-height: 54vh;
      margin: 0;
      padding: 18px;
      overflow: auto;
      color: #9fc6ff;
      font-size: 12px;
      line-height: 1.45;
    }
    footer { color: var(--muted); font-size: 12px; font-weight: 800; }
    .status { color: var(--hot); }
    @media (max-width: 820px) {
      .content { grid-template-columns: 1fr; align-self: start; }
      header, footer { align-items: flex-start; flex-direction: column; }
      .grid { grid-template-columns: 1fr; }
    }
  </style>
</head>
<body>
  <main>
    <header>
      <div>
        <h1>0xVyrs Core</h1>
        <div class="sub">Real-time ESP telemetry</div>
      </div>
      <div class="sub status">// synchronized</div>
    </header>
    <section class="content">
      <div class="panel">
        <div class="grid">
          <div class="card"><div class="label">Active users</div><div class="value" id="active">--</div><div class="meter"><span></span></div></div>
          <div class="card"><div class="label">Launches</div><div class="value" id="launches">--</div><div class="meter"><span></span></div></div>
          <div class="card"><div class="label">Ping total</div><div class="value" id="pings">--</div><div class="meter"><span></span></div></div>
          <div class="card"><div class="label">Uptime</div><div class="value" id="uptime">--</div><div class="meter"><span></span></div></div>
        </div>
      </div>
      <pre id="raw">Loading...</pre>
    </section>
    <footer>
      <span>Persistent monitoring</span>
      <span>v1.5</span>
      <span>Stay ahead. Stay unseen.</span>
    </footer>
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
