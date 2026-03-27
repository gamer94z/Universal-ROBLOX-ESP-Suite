# 0xVyrs Universal ROBLOX ESP Suite

A compact, single-file Roblox ESP with a modern UI, persistent settings, and combat-focused visual tools.

**Version:** `v1.3.3`

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