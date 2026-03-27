# 0xVyrs Universal ROBLOX ESP Suite

A single-file Roblox ESP featuring a polished in-game UI, persistent settings, combat-focused overlays, and client-side visual/performance tools.

**Version:** `v1.3.3`

---

## Overview

[`esp.lua`](./esp.lua) contains the entire project:
- UI system  
- Configuration handling  
- ESP rendering  
- View and performance utilities  

This build emphasises:
- Structured tabbed UI  
- Compact, scrollable menus  
- Real-time combat tuning  
- Stable defaults with persistent settings  
- Improved target telemetry  

---

## Features

### ESP System
- Team-aware colouring  
- Highlight, `2D Box`, and `Corner Box` styles  
- Independent `BOX ESP` toggle  
- Name, distance, health, and weapon display  
- Skeleton ESP and head dot  
- Focus target highlighting  
- Distance-based fading  

### Tracers
- Configurable origin  
- Adjustable thickness and transparency  
- Optional split tracer mode  

### Targeting
- Modes: `Closest`, `Visible`, `Armed`, `Smart`  
- Focus lock system  
- Live target information panel  

### Crosshair
- Fully customisable (style, colour, size, gap, thickness)  
- Optional FOV circle  

### View Tools
- Freecam with adjustable speed  
- Spectate (with next/previous controls)  
- Zoom limit removal  
- View reset  

### Performance
- Boost mode  
- Low materials  
- Hide textures and effects  
- Disable shadows  

### Utility
- Rejoin / server hop  
- Respawn and tool reset  
- Config import/export  
- Per-place configuration saving  
- Window position persistence  

---

## Controls

| Key            | Action                        |
|----------------|-------------------------------|
| RightShift     | Toggle full UI                |
| K              | Toggle menu visibility        |
| F4             | Toggle ESP                    |
| End            | Panic disable                 |
| Escape         | Exit freecam                  |
| Right Mouse    | Look around (freecam)         |
| W/A/S/D        | Move (freecam)                |
| Space          | Move up (freecam)             |
| LeftControl    | Move down (freecam)           |
| LeftShift      | Increase speed (freecam)      |

---

## Menu Structure

### Control
**GENERAL**
- ESP toggle  
- Preset cycling  
- Camera FOV  
- Mini HUD  
- Compact mode  

**UTILITY**
- Anti-AFK  
- Auto-load presets  
- Config management  
- Server actions  

---

### Display
- Player info toggles (name, distance, health, weapon)  
- Skeleton ESP  
- Head dot  
- Focus target  
- Target card display  
- Text layout options  
- Box ESP toggle and mode  

---

### Combat

**TARGET**
- Threat mode  
- Focus lock  
- Target info card  
- Heat vision  
- Look direction  
- Max distance  

**TRACERS**
- Enable toggle  
- Origin and style  
- Thickness and transparency  

**CROSSHAIR**
- Enable toggle  
- Style and colour  
- Size, gap, thickness  
- FOV circle  

---

### View
- Spectate system  
- Freecam  
- Speed control  
- Zoom limit removal  
- Reset view  

---

### Performance
- Visual optimisation toggles  
- Rendering simplifications  

---

## Notes

- Single-file design for simplicity  
- Requires executor file API for saving settings  
- Drawing elements degrade gracefully if unsupported  
- Performance settings are client-side only  
- Reinjection protection prevents conflicts  
- Focused target uses a distinct highlight colour  

---

## Changelog Highlights

**v1.3.3**
- Improved cursor behaviour for FPS systems  
- Maintains hidden Roblox cursor when using custom crosshair  

**v1.3.2**
- Removed camera FOV lock conflict with FPS systems  

---

## Setup

1. Open the repository in your editor  
2. Modify defaults in [`esp.lua`](./esp.lua) if required  
3. Execute 

---

## Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/gamer94z/Universal-ROBLOX-ESP-Suite/main/esp.lua"))()