# Repository Layout

## Goals

This repository keeps a flat public release surface while still separating runtime responsibilities internally.

The layout is designed around three constraints:

1. `esp.lua` must stay at the repository root so the public raw GitHub loadstring remains stable.
2. Large runtime blocks should live in `esp_modules` to reduce maintenance cost and compile pressure.
3. Extracted modules are loaded locally when file APIs exist, or from GitHub raw URLs when running from the public loadstring.

## Top-Level Structure

- `esp.lua`
  - Public entrypoint.
  - Lightweight release loader.
  - Loads runtime modules from `esp_modules`.
- `esp_modules/`
  - Extracted runtime modules used to keep the main script maintainable.
- `bin/`
  - Repository maintenance scripts.
- `docs/`
  - Documentation for maintainers.
- `.github/workflows/`
  - Repository automation and checks.

## What Not To Do

- Do not move `esp.lua` into another directory unless the public loader path is intentionally changing.
- Do not rename module files without updating the matching `requireLocalModule(...)` calls in `esp.lua`.
- Do not add generated settings files or local executor artifacts to version control.
