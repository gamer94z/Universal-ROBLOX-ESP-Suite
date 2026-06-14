# Runtime Modules

## Purpose

`esp_modules` exists to break large runtime systems into smaller units without changing the public release entrypoint.
The root `esp.lua` loader reads these files locally when available, then falls back to the raw GitHub module URL for public loadstring use.

## Current Modules

- `keybinds.lua`
  - Feature keybind UI and input handling.
- `overlay_tools.lua`
  - Overlay dragging, placement, and update panel support.
- `player_esp.lua`
  - Per-player ESP render/update path.
- `drawing_esp.lua`
  - Drawing API overlays, crosshair, tracers, boxes, skeletons, and look direction rendering.
- `tracking_runtime.lua`
  - Target selection, ESP refresh scheduling, tracked-player aggregation.
- `view_runtime.lua`
  - Camera, spectate, freecam, and local movement view state.
- `performance_runtime.lua`
  - Performance mode and visual simplification settings.
- `status_runtime.lua`
  - Mini HUD, target card, trainer status, and runtime status UI.
- `runtime_hooks.lua`
  - Input hooks, slider bindings, render loop, and runtime event setup.
- `ui_framework.lua`
  - Shared UI row/button/slider builders.
- `intro_animation.lua`
  - Intro animation controller.

## Maintenance Rule

If a module is loaded through `requireLocalModule(...)`, the module file must exist in `esp_modules/` and be pushed with `esp.lua`.

When changing a module:

1. Update the external module file in `esp_modules/`.
2. Run:

```powershell
pwsh -File .\bin\check-repo.ps1
```

If `esp.lua` references a module that is not present in the repository, public loadstring users will fail to load that module.
