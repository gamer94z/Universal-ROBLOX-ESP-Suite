# 0xVyrs Universal ROBLOX ESP Suite

A compact Roblox ESP script with a custom in-game UI, team-based coloring, tracers, box modes, visibility checks, and a polished startup flow.

## Overview

This project is a single-file ESP suite built around [`esp.lua`](./esp.lua). It includes a tabbed control panel, animated splash intro, keybinds, preset modes, and multiple visual ESP styles while keeping the layout practical and easy to use.

## Features

- Team-aware ESP coloring
- Highlight, `2D Box`, and `Corner Box` modes
- Name, distance, health, and weapon display
- Tracers
- Visibility / heat-vision coloring
- Skeleton ESP
- Focus target highlighting for the closest visible enemy
- Compact mode
- Startup intro animation
- Toast notifications for setting changes
- Settings persistence through `esp_settings.json`

## Controls

- `RightShift`: Toggle full UI
- `K`: Quick hide / show menu
- `F4`: Toggle ESP
- `End`: Panic hide and disable

## Menu Tabs

### Control

- ESP enable / disable
- Preset cycling
- Team check status
- Compact mode
- Settings status

### Display

- ESP color status
- Name / distance / health / weapon toggles
- Skeleton ESP
- Focus target toggle
- Box mode selector

### Combat

- Heat vision
- Tracers
- Max distance

## Files

- [`esp.lua`](./esp.lua): Main script
- [`.gitignore`](./.gitignore): Repo ignore rules
- [`LICENSE`](./LICENSE): Repository license

## Notes

- This repo currently stores the ESP in a single Lua file for simplicity.
- Local saved settings are written to `esp_settings.json` when supported by the executor environment.
- If a drawing type is unsupported, the script falls back safely where possible.

## Setup

1. Open this repository folder in VS Code or your preferred editor.
2. Edit [`esp.lua`](./esp.lua) if you want to change defaults, theme values, or keybinds.
3. Load the script in your Roblox environment.

## Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/gamer94z/Universal-ROBLOX-ESP-Suite/main/esp.lua"))()
```

## Status

This project is currently focused on being a clean, practical ESP suite with a polished UI and straightforward configuration.
