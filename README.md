# 0xVyrs Universal ROBLOX ESP Suite

A proprietary Roblox ESP release by `0xVyrs`, built for authorized loader-based use with a modern UI, persistent settings, and combat-focused visual tools.

**Version:** `v1.3.4`

## Ownership

Copyright (c) 2026 `gamer94z / 0xVyrs`

This project is proprietary and distributed under an `All Rights Reserved` model.
Source access, redistribution, reuploading, modification, resale, and reuse are not permitted without explicit written permission from the owner.

This repository is not intended to grant open-source rights.

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

## Distribution Notes

- Intended usage is through an approved loadstring or private distribution channel
- Public raw-source hosting is not the intended release model for this project
- If you are running a public GitHub repo, move the real source to a private location before using a public loader
- This README does not grant permission to copy or republish the source

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
loadstring(game:HttpGet("https://your-private-loader-endpoint/0xvyrs/esp.lua"))()
