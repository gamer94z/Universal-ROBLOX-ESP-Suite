# 0xVyrs Universal ROBLOX ESP Suite

A single-file Roblox ESP with a polished in-game menu, saved settings, combat-focused overlays, and client-side view/performance tools.

Current release: `v1.2.0`

## Overview

[`esp.lua`](./esp.lua) is the full project. It builds the UI, handles saved config, draws ESP elements, and includes view plus performance utilities in one script.

The current build focuses on:
- a cleaner tabbed UI
- compact and scrollable menus
- combat controls that are easier to tune live
- practical defaults with saved settings

## Highlights

- Team-aware ESP coloring
- Highlight, `2D Box`, and `Corner Box` styles
- Separate `BOX ESP` toggle so boxes can be disabled without losing the selected mode
- Name, distance, health, weapon, skeleton, head dot, and focus target visuals
- Distance fade for cleaner long-range rendering
- Tracers with origin, thickness, and transparency controls
- Threat targeting with `Closest`, `Visible`, `Armed`, and `Smart` modes
- Focus lock and live target info
- Custom crosshair with style, color, size, thickness, gap, and FOV-circle controls
- Freecam, spectate, spectate prev/next, freecam speed, reset view, and remove zoom limit
- Mini live HUD
- Performance tab with local visual optimization options
- Tooltips for advanced settings
- Settings persistence through `esp_settings.json`
- Window position save

## Controls

- `RightShift`: Toggle the full UI
- `K`: Quick hide/show the menu window
- `F4`: Toggle ESP
- `End`: Panic disable and hide
- `Escape`: Exit freecam
- `Right Mouse`: Hold to look around in freecam
- `W/A/S/D`, `Space`, `LeftControl`: Freecam movement
- `LeftShift`: Faster freecam movement

## Menu Layout

### Control

- ESP enable toggle
- Preset cycling
- Camera FOV
- Mini HUD toggle
- Compact mode
- Settings/save status

### Display

- Name / distance / health / weapon toggles
- Skeleton ESP
- Head dot
- Focus target
- Box ESP toggle
- Box mode selector

### Combat

Combat is split into sub-tabs:

- `TARGET`
  Threat mode, focus lock, target info, heat vision, look direction, max distance
- `TRACERS`
  Tracer toggle, origin, thickness, transparency
- `CROSSHAIR`
  Crosshair toggle, style, color, thickness, size, gap, FOV circle controls

### View

- Spectate picker
- Spectate prev / next
- Freecam
- Freecam speed
- Remove zoom limit
- Reset view

### Perf

- Boost mode
- Low materials
- Hide textures
- Hide effects
- Disable shadows

## Notes

- The script is intentionally kept in one Lua file for easy loading and editing.
- Saved settings require executor file API support.
- Drawing-based elements fall back where possible if a drawing type is unavailable.
- Performance changes are local visual adjustments only.
- Reinject protection is built in so old instances do not keep fighting over camera and mouse state.

## Setup

1. Open the repository in your editor.
2. Adjust defaults in [`esp.lua`](./esp.lua) if you want to change keybinds, colors, or feature defaults.
3. Load the script in your Roblox environment.

## Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/gamer94z/Universal-ROBLOX-ESP-Suite/main/esp.lua"))()
```

## Files

- [`esp.lua`](./esp.lua): Main script
- [`README.md`](./README.md): Project overview and usage
- [`LICENSE`](./LICENSE): Repository license
- [`.gitignore`](./.gitignore): Ignore rules
