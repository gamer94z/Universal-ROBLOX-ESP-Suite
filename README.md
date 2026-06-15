# 0xVyrs Universal ROBLOX ESP Suite

Proprietary Roblox ESP release maintained by `0xVyrs`.

Version: `v1.5`

## v1.5 Changelog

- Free Cam turned off until further notice.
- Added warning symbols to risky features.
- Shrunk the UI.
- Fixed UI alignment issues.

## Ownership

Copyright (c) 2026 `gamer94z / 0xVyrs`

This project is distributed under an `All Rights Reserved` model.
Use it only as released. Do not modify, resell, repost, or claim authorship.

## Authorized Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/gamer94z/Universal-ROBLOX-ESP-Suite/main/esp.lua"))()
```

## Railway Telemetry

The included Railway service accepts anonymous launch/heartbeat pings at `/api/ping` and shows live stats at `/`.

Telemetry payloads include only a generated session id, script version, Roblox place id, job id, uptime, and event type. No Roblox username or user id is sent.

Current telemetry endpoint:

```lua
https://0xesp.up.railway.app/api/ping
```

To use the exact dashboard background image, set this Railway environment variable to a hosted image URL:

```text
DASHBOARD_BACKGROUND_URL=https://...
```
