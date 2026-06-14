$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

$requiredPaths = @(
    "esp.lua",
    "README.md",
    "LICENSE",
    "esp_modules",
    "docs",
    ".github/workflows/repo-checks.yml"
)

foreach ($path in $requiredPaths) {
    if (-not (Test-Path $path)) {
        throw "Missing required path: $path"
    }
}

$espContent = Get-Content "esp.lua" -Raw

$moduleFallbackMap = @{
    "esp_modules/keybinds.lua"            = "KEYBINDS_MODULE_SOURCE"
    "esp_modules/overlay_tools.lua"       = "OVERLAY_TOOLS_MODULE_SOURCE"
    "esp_modules/player_esp.lua"          = "PLAYER_ESP_MODULE_SOURCE"
    "esp_modules/drawing_esp.lua"         = "DRAWING_ESP_MODULE_SOURCE"
    "esp_modules/tracking_runtime.lua"    = "TRACKING_RUNTIME_MODULE_SOURCE"
    "esp_modules/view_runtime.lua"        = "VIEW_RUNTIME_MODULE_SOURCE"
    "esp_modules/performance_runtime.lua" = "PERFORMANCE_RUNTIME_MODULE_SOURCE"
    "esp_modules/status_runtime.lua"      = "STATUS_RUNTIME_MODULE_SOURCE"
    "esp_modules/runtime_hooks.lua"       = "RUNTIME_HOOKS_MODULE_SOURCE"
    "esp_modules/ui_framework.lua"        = "UI_FRAMEWORK_MODULE_SOURCE"
    "esp_modules/intro_animation.lua"     = "INTRO_ANIMATION_MODULE_SOURCE"
}

foreach ($entry in $moduleFallbackMap.GetEnumerator()) {
    if (-not (Test-Path $entry.Key)) {
        throw "Missing module file: $($entry.Key)"
    }

    if ($espContent -notmatch [regex]::Escape($entry.Value)) {
        throw "Missing module source variable in esp.lua: $($entry.Value)"
    }

    $moduleFileName = Split-Path -Leaf $entry.Key
    if ($espContent -notmatch [regex]::Escape($moduleFileName)) {
        throw "esp.lua does not reference module file: $moduleFileName"
    }
}

Write-Host "Repository checks passed."
