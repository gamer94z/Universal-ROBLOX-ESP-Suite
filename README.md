# 0xVyrs Universal ROBLOX ESP Suite

A proprietary Roblox ESP release by `0xVyrs`.

**Version:** `v1.3.5`

## Ownership

Copyright (c) 2026 `gamer94z / 0xVyrs`

This project is proprietary and distributed under an `All Rights Reserved` model.
You may use it as released, but you may not modify it, resell it, repost it, or claim it as your own.

## Latest Patch

- Added `MINIMAL MODE`, startup UI gating, and more reliable draggable overlay handling
- Reworked `UTILITY > Utility` and `KEYBINDS` with clearer grouping, contrast, and better scanability
- Expanded tooltip coverage across the UI and improved labels for less obvious options
- Replaced the preset cycler with a dropdown selector that includes preset descriptions
- Polished the in-app `UPDATE TRACK` card so its notes match the current release

## Version History

### `v1.3.5`

- UI polish pass with better grouping, labels, contrast, and tooltip coverage
- New preset dropdown with descriptions
- Minimal mode and startup UI gating improvements

### `v1.3.4`

- Added a dedicated `KEYBINDS` section inside `CONTROL` for custom feature binds
- Added `Toggle` and `Hold` bind modes with active keybinds shown under the watermark
- Improved the mini HUD and stacked target card layout
- Updated the intro and standalone loading path

---

## Features

- Team-aware ESP colouring  
- Box styles: `2D` and `Corner`  
- Player info: name, distance, health, weapon  
- Skeleton, head dot, and focus target highlighting  
- Distance-based fade for cleaner visuals  

**Combat Tools**
- Multiple targeting modes (`Closest`, `Visible`, `Armed`, `Smart`)  
- Tracers (custom origin, thickness, transparency)  
- Custom crosshair with FOV circle  

**View**
- Freecam with adjustable speed  
- Spectate system (next/previous)  
- Remove zoom limit  

**Performance**
- Boost mode and visual optimisation toggles  
- Hide textures, effects, shadows  

**Utility**
- Config save/load (`esp_settings.json`)  
- Per-place configs  
- Rejoin, server hop, respawn, tool reset  

---

## Controls

| Key        | Action                |
|------------|----------------------|
| RightShift | Toggle UI            |
| K          | Toggle menu          |
| F4         | Toggle ESP           |
| End        | Panic disable        |
| Escape     | Exit freecam         |

---

## Authorized Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/gamer94z/Universal-ROBLOX-ESP-Suite/main/esp.lua"))()
