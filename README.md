# 0xVyrs Universal ROBLOX ESP Suite

A compact, single-file Roblox ESP with a modern UI, persistent settings, and combat-focused visual tools.

**Version:** `v1.3.4`

## Latest Patch

- Added a dedicated `KEYBINDS` section inside `CONTROL` for custom feature binds
- Added `Toggle` and `Hold` bind modes with active keybinds shown under the watermark
- Improved the mini HUD styling and moved the target card into a cleaner stacked overlay
- Updated the intro with the new center-screen audio-backed open animation
- Synced standalone loading so the main `esp.lua` can still run even when the local module file is unavailable

## Patch Log Notes

- Patch notes in this README are kept short and focused on visible feature changes
- Small stability fixes and UI cleanup may ship without a long breakdown
- The in-script version number is the source of truth for the current release

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

## Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/gamer94z/Universal-ROBLOX-ESP-Suite/main/esp.lua"))()
