return function(context)
    local BASE_URL = assert(context.BaseUrl, "missing v3 base URL")
    local UPSTREAM_COMMIT = "6087ca45e55cc8a1e3d6b4fda9e265cb63d2e08a"
    local UPSTREAM_BASE = "https://raw.githubusercontent.com/gamer94z/Universal-ROBLOX-ESP-Suite/" .. UPSTREAM_COMMIT
    local env = (type(getgenv) == "function" and getgenv()) or _G

    if env.__VYRS_V3_RUNTIME and type(env.__VYRS_V3_RUNTIME.destroy) == "function" then
        pcall(function() env.__VYRS_V3_RUNTIME:destroy() end)
    end
    if env.__VYRS_ESP_V2_RUNTIME and type(env.__VYRS_ESP_V2_RUNTIME.destroy) == "function" then
        pcall(function() env.__VYRS_ESP_V2_RUNTIME:destroy() end)
        env.__VYRS_ESP_V2_RUNTIME = nil
    end

    local function replaceOnce(text, from, to, label)
        local first, last = text:find(from, 1, true)
        if not first then error("[0xVyrs v3.2] patch target missing: " .. tostring(label)) end
        return text:sub(1, first - 1) .. to .. text:sub(last + 1)
    end

    local function replacePlain(text, from, to)
        local pattern = from:gsub("(%W)", "%%%1")
        return (text:gsub(pattern, function() return to end))
    end

    local function parallelFetch(specs)
        local results, errors = {}, {}
        local remaining = 0
        for _ in pairs(specs) do remaining = remaining + 1 end
        for key, url in pairs(specs) do
            task.spawn(function()
                local ok, source = pcall(function() return game:HttpGet(url) end)
                if ok and type(source) == "string" and source ~= "" then
                    results[key] = source
                else
                    errors[key] = tostring(source)
                end
                remaining = remaining - 1
            end)
        end
        while remaining > 0 do task.wait() end
        if next(errors) then
            local parts = {}
            for key, err in pairs(errors) do table.insert(parts, key .. "=" .. err) end
            table.sort(parts)
            error("[0xVyrs v3.2] preload failed: " .. table.concat(parts, " | "))
        end
        return results
    end

    local function patchRuntimeHooks(source)
        local injectionMarker = "\tlocal setLocalMovementSuppressed = context.setLocalMovementSuppressed\n\n\tlocal function isActiveToken()"
        local connectionInjection = "\tlocal setLocalMovementSuppressed = context.setLocalMovementSuppressed\n\n\tlocal previousConnections = SHARED_ENV.__VYRS_ESP_RUNTIME_CONNECTIONS\n\tif type(previousConnections) == \"table\" then\n\t\tfor _, connection in ipairs(previousConnections) do\n\t\t\tif connection and type(connection.Disconnect) == \"function\" then pcall(function() connection:Disconnect() end) end\n\t\tend\n\tend\n\tlocal runtimeConnections = {}\n\tSHARED_ENV.__VYRS_ESP_RUNTIME_CONNECTIONS = runtimeConnections\n\tlocal function connect(signal, callback)\n\t\tlocal connection = signal:Connect(callback)\n\t\ttable.insert(runtimeConnections, connection)\n\t\treturn connection\n\tend\n\tlocal function cleanupConnections()\n\t\tfor _, connection in ipairs(runtimeConnections) do\n\t\t\tif connection and type(connection.Disconnect) == \"function\" then pcall(function() connection:Disconnect() end) end\n\t\tend\n\t\tfor i = #runtimeConnections, 1, -1 do runtimeConnections[i] = nil end\n\t\tif SHARED_ENV.__VYRS_ESP_RUNTIME_CONNECTIONS == runtimeConnections then SHARED_ENV.__VYRS_ESP_RUNTIME_CONNECTIONS = nil end\n\tend\n\n\tlocal function isActiveToken()"
        source = replaceOnce(source, injectionMarker, connectionInjection, "runtime connection manager")

        local replacements = {
            { "miniHudLabels.utility.configNameInput.FocusLost:Connect(", "connect(miniHudLabels.utility.configNameInput.FocusLost, " },
            { "miniHudLabels.utility.resetPositions.MouseButton1Click:Connect(", "connect(miniHudLabels.utility.resetPositions.MouseButton1Click, " },
            { "miniHudLabels.utility.resetDisplay.MouseButton1Click:Connect(", "connect(miniHudLabels.utility.resetDisplay.MouseButton1Click, " },
            { "miniHudLabels.utility.resetView.MouseButton1Click:Connect(", "connect(miniHudLabels.utility.resetView.MouseButton1Click, " },
            { "miniHudLabels.utility.resetPerformance.MouseButton1Click:Connect(", "connect(miniHudLabels.utility.resetPerformance.MouseButton1Click, " },
            { "miniHudLabels.utility.respawn.MouseButton1Click:Connect(", "connect(miniHudLabels.utility.respawn.MouseButton1Click, " },
            { "miniHudLabels.utility.tools.MouseButton1Click:Connect(", "connect(miniHudLabels.utility.tools.MouseButton1Click, " },
            { "chrome.minimizeButton.MouseButton1Click:Connect(", "connect(chrome.minimizeButton.MouseButton1Click, " },
            { "Players.PlayerAdded:Connect(", "connect(Players.PlayerAdded, " },
            { "Players.PlayerRemoving:Connect(", "connect(Players.PlayerRemoving, " },
            { "UserInputService.JumpRequest:Connect(", "connect(UserInputService.JumpRequest, " },
            { "UserInputService.InputBegan:Connect(", "connect(UserInputService.InputBegan, " },
            { "UserInputService.InputEnded:Connect(", "connect(UserInputService.InputEnded, " },
            { "RunService.RenderStepped:Connect(", "connect(RunService.RenderStepped, " },
        }
        for _, item in ipairs(replacements) do source = replacePlain(source, item[1], item[2]) end
        source = replacePlain(source, 'window:GetPropertyChangedSignal("Position"):Connect(', 'connect(window:GetPropertyChangedSignal("Position"), ')

        source = replaceOnce(source,
            "\t\tlocal updateAccumulator = 0\n\t\tlocal frameTaskErrorCounts = {}",
            "\t\tlocal updateAccumulator = 0\n\t\tlocal maintenanceAccumulator = 0\n\t\tlocal uiAccumulator = 0\n\t\tlocal frameTaskErrorCounts = {}",
            "frame accumulators"
        )
        source = replacePlain(source,
            '\t\t\trunSafeFrameTask(frameTaskErrorCounts, "applyPerformanceSettings", applyPerformanceSettings)',
            '\t\t\tmaintenanceAccumulator = maintenanceAccumulator + deltaTime\n\t\t\tif maintenanceAccumulator >= 2 then\n\t\t\t\tmaintenanceAccumulator = 0\n\t\t\t\trunSafeFrameTask(frameTaskErrorCounts, "applyPerformanceSettings", applyPerformanceSettings)\n\t\t\tend'
        )
        local uiBlock = '\t\t\trunSafeFrameTask(frameTaskErrorCounts, "updateViewUi", updateViewUi)\n\t\t\trunSafeFrameTask(frameTaskErrorCounts, "updateMouseIconVisibility", updateMouseIconVisibility)\n\t\t\trunSafeFrameTask(frameTaskErrorCounts, "updatePerfStatsUi", context.updatePerfStatsUi)'
        local uiReplacement = '\t\t\tuiAccumulator = uiAccumulator + deltaTime\n\t\t\tif uiAccumulator >= 0.1 then\n\t\t\t\tuiAccumulator = 0\n\t\t\t\trunSafeFrameTask(frameTaskErrorCounts, "updateViewUi", updateViewUi)\n\t\t\t\trunSafeFrameTask(frameTaskErrorCounts, "updateMouseIconVisibility", updateMouseIconVisibility)\n\t\t\t\trunSafeFrameTask(frameTaskErrorCounts, "updatePerfStatsUi", context.updatePerfStatsUi)\n\t\t\tend'
        source = replacePlain(source, uiBlock, uiReplacement)
        source = replaceOnce(source,
            "\treturn {\n\t\tsetup = setup,\n\t}",
            "\treturn {\n\t\tsetup = setup,\n\t\tcleanup = cleanupConnections,\n\t}",
            "runtime cleanup export"
        )
        return source
    end

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

    local function usableParent(candidate)
        if not candidate then return false end
        local probe = Instance.new("Folder")
        local ok = pcall(function() probe.Name = "VyrsV32Probe"; probe.Parent = candidate end)
        pcall(function() probe:Destroy() end)
        return ok
    end

    local function resolveUiParent()
        if type(gethui) == "function" then
            local ok, hidden = pcall(gethui)
            if ok and usableParent(hidden) then return hidden, "gethui" end
        end
        local okCore, coreGui = pcall(function() return game:GetService("CoreGui") end)
        if okCore and usableParent(coreGui) then return coreGui, "CoreGui" end
        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
        if usableParent(playerGui) then return playerGui, "PlayerGui" end
        error("[0xVyrs v3.2] no usable UI host")
    end

    local UiParent, uiHostName = resolveUiParent()
    env.__VYRS_V3_LEGACY_UI_PARENT = UiParent

    local loadStarted = os.clock()
    local sources = parallelFetch({
        legacy = UPSTREAM_BASE .. "/esp.lua",
        keybinds = UPSTREAM_BASE .. "/esp_modules/keybinds.lua",
        ui_framework = UPSTREAM_BASE .. "/esp_modules/ui_framework.lua",
        tracking_runtime = BASE_URL .. "v3/engine/tracking_runtime.lua",
        view_runtime = BASE_URL .. "v3/engine/view_runtime_v32.lua",
        performance_runtime = BASE_URL .. "esp_modules/performance_runtime.lua",
        status_runtime = UPSTREAM_BASE .. "/esp_modules/status_runtime.lua",
        runtime_hooks = UPSTREAM_BASE .. "/esp_modules/runtime_hooks.lua",
        overlay_tools = BASE_URL .. "esp_modules/overlay_tools.lua",
        player_esp = BASE_URL .. "v3/engine/player_esp.lua",
        drawing_esp = UPSTREAM_BASE .. "/esp_modules/drawing_esp.lua",
        catalog = BASE_URL .. "v3/feature_catalog.lua",
        terminal = BASE_URL .. "v3/terminal_v32.lua",
    })
    sources.runtime_hooks = patchRuntimeHooks(sources.runtime_hooks)
    sources.terminal = sources.terminal:gsub("lineCount %+= 1", "lineCount = lineCount + 1")
    sources.terminal = sources.terminal:gsub("current %.%.= char", "current = current .. char")

    env.__VYRS_V32_MODULES = {
        keybinds = sources.keybinds,
        ui_framework = sources.ui_framework,
        tracking_runtime = sources.tracking_runtime,
        view_runtime = sources.view_runtime,
        performance_runtime = sources.performance_runtime,
        status_runtime = sources.status_runtime,
        runtime_hooks = sources.runtime_hooks,
        overlay_tools = sources.overlay_tools,
        player_esp = sources.player_esp,
        drawing_esp = sources.drawing_esp,
    }

    print(string.format("[0xVyrs v3.2] preload %.0fms | ui=%s", (os.clock() - loadStarted) * 1000, uiHostName))

    local legacySource = sources.legacy
    legacySource = replaceOnce(legacySource,
        'local CoreGui = game:GetService("CoreGui")',
        'local CoreGui = ((type(getgenv) == "function" and getgenv().__VYRS_V3_LEGACY_UI_PARENT) or game:GetService("CoreGui"))',
        "legacy UI host"
    )
    legacySource = replaceOnce(legacySource, '\ttelemetryUrl = "https://0xesp.up.railway.app/api/ping",', '\ttelemetryUrl = "",', "disable telemetry")
    legacySource = replaceOnce(legacySource, '\tversion = "1.5",', '\tversion = "3.2-alpha.1",', "runtime version")
    legacySource = replaceOnce(legacySource, '\tshowMiniHud = true,', '\tshowMiniHud = false,', "hide mini HUD")
    legacySource = replaceOnce(legacySource, '\tshowKeybindsUi = true,', '\tshowKeybindsUi = false,', "hide keybind panel")
    legacySource = replaceOnce(legacySource, '\tuiToggleKey = Enum.KeyCode.RightShift,', '\tuiToggleKey = Enum.KeyCode.F10,', "reserve RightShift")
    legacySource = replaceOnce(legacySource, '\tif type(readfile) == "function" then', '\tif false and type(readfile) == "function" then', "disable local module lookup")
    legacySource = replaceOnce(legacySource, '\tBackgroundColor3 = THEME.window,\n\tBorderSizePixel = 0,', '\tBackgroundColor3 = THEME.window,\n\tBorderSizePixel = 0,\n\tVisible = false,', "hide legacy window")

    local modulePatches = {
        { "local KEYBINDS_MODULE_SOURCE = nil", "local KEYBINDS_MODULE_SOURCE = SHARED_ENV.__VYRS_V32_MODULES.keybinds" },
        { "local UI_FRAMEWORK_MODULE_SOURCE = nil", "local UI_FRAMEWORK_MODULE_SOURCE = SHARED_ENV.__VYRS_V32_MODULES.ui_framework" },
        { "local TRACKING_RUNTIME_MODULE_SOURCE = nil", "local TRACKING_RUNTIME_MODULE_SOURCE = SHARED_ENV.__VYRS_V32_MODULES.tracking_runtime" },
        { "local VIEW_RUNTIME_MODULE_SOURCE = nil", "local VIEW_RUNTIME_MODULE_SOURCE = SHARED_ENV.__VYRS_V32_MODULES.view_runtime" },
        { "local PERFORMANCE_RUNTIME_MODULE_SOURCE = nil", "local PERFORMANCE_RUNTIME_MODULE_SOURCE = SHARED_ENV.__VYRS_V32_MODULES.performance_runtime" },
        { "local STATUS_RUNTIME_MODULE_SOURCE = nil", "local STATUS_RUNTIME_MODULE_SOURCE = SHARED_ENV.__VYRS_V32_MODULES.status_runtime" },
        { "local RUNTIME_HOOKS_MODULE_SOURCE = nil", "local RUNTIME_HOOKS_MODULE_SOURCE = SHARED_ENV.__VYRS_V32_MODULES.runtime_hooks" },
        { "local OVERLAY_TOOLS_MODULE_SOURCE = nil", "local OVERLAY_TOOLS_MODULE_SOURCE = SHARED_ENV.__VYRS_V32_MODULES.overlay_tools" },
        { "local PLAYER_ESP_MODULE_SOURCE = nil", "local PLAYER_ESP_MODULE_SOURCE = SHARED_ENV.__VYRS_V32_MODULES.player_esp" },
        { "local DRAWING_ESP_MODULE_SOURCE = nil", "local DRAWING_ESP_MODULE_SOURCE = SHARED_ENV.__VYRS_V32_MODULES.drawing_esp" },
        { "local INTRO_ANIMATION_MODULE_SOURCE = nil", "local INTRO_ANIMATION_MODULE_SOURCE = [[return function() return { play = function() end, destroy = function() end } end]]" },
    }
    for _, patch in ipairs(modulePatches) do legacySource = replaceOnce(legacySource, patch[1], patch[2], patch[1]) end

    legacySource = legacySource .. [==[

do
    CONFIG.showMiniHud = false
    CONFIG.showKeybindsUi = false
    if window then window.Visible = false end
    if watermark then watermark.Visible = false end
    if miniHud then miniHud.Visible = false end
    if type(syncUiFromConfig) == "function" then pcall(syncUiFromConfig) end

    local bridge = {}
    local actionState = { freecam = false }
    local movementKeys = { walkSpeedEnabled=true, walkSpeed=true, infiniteJump=true, noclip=true, fly=true, flySpeed=true, clickTeleport=true }
    local crosshairKeys = { showCrosshair=true, showFovCircle=true, crosshairStyle=true, crosshairColor=true, crosshairSize=true, crosshairThickness=true, crosshairGap=true, fovRadius=true, fovCircleThickness=true, fovCircleTransparency=true }

    local function refreshAfterChange(key, value)
        if key == "enabled" and type(setEspEnabled) == "function" then pcall(setEspEnabled, value) end
        if key == "cameraFov" and type(applyCameraFov) == "function" then pcall(applyCameraFov) end
        if key == "removeZoomLimit" and type(applyZoomLimitSetting) == "function" then pcall(applyZoomLimitSetting) end
        if key == "boxMode" and type(resetAllBoxEspVisuals) == "function" then pcall(resetAllBoxEspVisuals) end
        if movementKeys[key] and type(applyPlayerMovementState) == "function" then pcall(applyPlayerMovementState) end
        if crosshairKeys[key] and type(updateCrosshair) == "function" then pcall(updateCrosshair) end
        if key == "performanceMode" or key == "simplifyMaterials" or key == "hideTextures" or key == "hideEffects" or key == "disableShadows" then
            if type(applyPerformanceSettings) == "function" then pcall(applyPerformanceSettings) end
        end
        if type(refreshAllEsp) == "function" then pcall(refreshAllEsp) end
        if type(updateViewUi) == "function" then pcall(updateViewUi) end
        if type(syncUiFromConfig) == "function" then pcall(syncUiFromConfig) end
        if type(saveSettings) == "function" then pcall(saveSettings) end
    end

    function bridge:has(key) return CONFIG[key] ~= nil end
    function bridge:get(key) return CONFIG[key] end
    function bridge:all() return CONFIG end

    function bridge:set(key, value)
        if CONFIG[key] == nil then return false, "unknown feature" end
        if typeof(value) ~= typeof(CONFIG[key]) then return false, "expected " .. typeof(CONFIG[key]) end
        if key == "boxMode" and type(normalizeBoxMode) == "function" then value = normalizeBoxMode(value) end
        CONFIG[key] = value
        refreshAfterChange(key, value)
        return true
    end

    function bridge:status()
        local focused = espRuntimeState and espRuntimeState.focusedPlayer
        return {
            engine = "v3.2",
            version = CONFIG.version,
            tracked = espRuntimeState and espRuntimeState.trackedEnemyCount or 0,
            visible = espRuntimeState and espRuntimeState.visibleEnemyCount or 0,
            refreshMs = espRuntimeState and espRuntimeState.lastRefreshMs or 0,
            intervalMs = espRuntimeState and ((espRuntimeState.updateInterval or 0) * 1000) or 0,
            focused = focused and focused.Name or nil,
            freecam = actionState.freecam,
        }
    end

    function bridge:listPresets()
        local result = {}
        for index, preset in ipairs(PRESETS or {}) do
            table.insert(result, { index=index, name=preset.name or ("Preset " .. index), description=preset.description or "" })
        end
        return result
    end

    function bridge:applyPreset(identifier)
        local targetIndex = tonumber(identifier)
        if not targetIndex then
            local wanted = string.lower(tostring(identifier or ""))
            for index, preset in ipairs(PRESETS or {}) do
                if string.lower(tostring(preset.name or "")) == wanted then targetIndex = index break end
            end
        end
        local preset = targetIndex and PRESETS and PRESETS[targetIndex]
        if not preset or type(preset.apply) ~= "function" then return false, "preset not found" end
        currentPresetIndex = targetIndex
        local ok, err = pcall(preset.apply)
        if not ok then return false, err end
        if type(applyPerformanceSettings) == "function" then pcall(applyPerformanceSettings) end
        if type(applyPlayerMovementState) == "function" then pcall(applyPlayerMovementState) end
        if type(refreshAllEsp) == "function" then pcall(refreshAllEsp) end
        if type(syncUiFromConfig) == "function" then pcall(syncUiFromConfig) end
        if type(saveSettings) == "function" then pcall(saveSettings) end
        return true
    end

    function bridge:listConfigs()
        if type(getConfigSlotNames) ~= "function" then return {} end
        local ok, names = pcall(getConfigSlotNames)
        return ok and type(names) == "table" and names or {}
    end

    function bridge:saveConfig(name)
        name = tostring(name or ""):match("^%s*(.-)%s*$")
        if name == "" then return false, "config name required" end
        if type(saveConfigSlot) ~= "function" then return false, "config saving unavailable" end
        return saveConfigSlot(name)
    end

    function bridge:loadConfig(name)
        if type(loadConfigSlot) ~= "function" then return false, "config loading unavailable" end
        local ok, reason = loadConfigSlot(tostring(name or ""))
        if ok then
            if type(syncUiFromConfig) == "function" then pcall(syncUiFromConfig) end
            if type(applyPerformanceSettings) == "function" then pcall(applyPerformanceSettings) end
            if type(applyPlayerMovementState) == "function" then pcall(applyPlayerMovementState) end
            if type(refreshAllEsp) == "function" then pcall(refreshAllEsp) end
        end
        return ok, reason
    end

    function bridge:deleteConfig(name)
        if type(deleteConfigSlot) ~= "function" then return false, "config deletion unavailable" end
        return deleteConfigSlot(tostring(name or ""))
    end

    function bridge:listKeybinds()
        local result = {}
        for feature, keyText in pairs(FEATURE_KEYBINDS or {}) do
            table.insert(result, { feature=feature, key=tostring(keyText), mode=tostring(FEATURE_KEYBIND_MODES[feature] or "Toggle") })
        end
        table.sort(result, function(a,b) return a.feature < b.feature end)
        return result
    end

    function bridge:setKeybind(feature, keyText, mode)
        feature = tostring(feature or "")
        if FEATURE_KEYBINDS[feature] == nil then return false, "feature has no keybind" end
        keyText = tostring(keyText or ""):upper()
        if type(keyTextToKeyCode) == "function" and not keyTextToKeyCode(keyText) then return false, "invalid key" end
        if mode ~= nil then
            local lowered = string.lower(tostring(mode))
            if lowered == "hold" then mode = "Hold" elseif lowered == "toggle" then mode = "Toggle" else return false, "mode must be Toggle or Hold" end
            FEATURE_KEYBIND_MODES[feature] = mode
        end
        FEATURE_KEYBINDS[feature] = keyText
        if keybindController and type(keybindController.update) == "function" then pcall(keybindController.update) end
        if type(saveSettings) == "function" then pcall(saveSettings) end
        return true
    end

    function bridge:listPlayers()
        local result = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LOCAL_PLAYER then table.insert(result, { name=player.Name, displayName=player.DisplayName }) end
        end
        table.sort(result, function(a,b) return string.lower(a.displayName) < string.lower(b.displayName) end)
        return result
    end

    local function findPlayer(name)
        local wanted = string.lower(tostring(name or ""))
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LOCAL_PLAYER and (string.lower(player.Name) == wanted or string.lower(player.DisplayName) == wanted) then return player end
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LOCAL_PLAYER and (string.find(string.lower(player.Name), wanted, 1, true) == 1 or string.find(string.lower(player.DisplayName), wanted, 1, true) == 1) then return player end
        end
    end

    function bridge:call(action, argument)
        action = string.lower(tostring(action or ""))
        if action == "freecam" then
            if type(toggleFreeCam) ~= "function" then return false, "freecam unavailable" end
            local ok, err = pcall(toggleFreeCam)
            if ok then actionState.freecam = not actionState.freecam end
            return ok, err
        elseif action == "spectate" then
            if type(setSpectateTarget) ~= "function" then return false, "spectate unavailable" end
            local targetName = tostring(argument or "")
            if targetName == "" or string.lower(targetName) == "off" or string.lower(targetName) == "local" then
                pcall(setSpectateTarget, nil)
                return true
            end
            local player = findPlayer(targetName)
            if not player then return false, "player not found" end
            local ok, err = pcall(setSpectateTarget, player)
            return ok, err
        elseif action == "resetview" then
            if type(restoreLocalCamera) == "function" then pcall(restoreLocalCamera) end
            actionState.freecam = false
            return true
        elseif action == "respawn" then
            local ok = pcall(function() LOCAL_PLAYER:LoadCharacter() end)
            if not ok then
                local character = LOCAL_PLAYER.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if humanoid then pcall(function() humanoid.Health = 0 end) end
            end
            return true
        elseif action == "tools" then
            local humanoid = type(getLocalHumanoid) == "function" and getLocalHumanoid()
            if humanoid then pcall(function() humanoid:UnequipTools() end) end
            return true
        elseif action == "rejoin" then
            local ok, err = pcall(function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LOCAL_PLAYER) end)
            return ok, err
        elseif action == "serverhop" or action == "emptyhop" then
            if type(hopToPublicServer) ~= "function" then return false, "server hop unavailable" end
            return pcall(hopToPublicServer, action == "emptyhop")
        elseif action == "export" then
            if type(exportConfigString) ~= "function" then return false, "config export unavailable" end
            local ok, result = pcall(exportConfigString)
            if ok and type(result) == "string" and type(setclipboard) == "function" then pcall(setclipboard, result) end
            return ok, result
        elseif action == "import" then
            if type(getclipboard) ~= "function" or type(applyImportedConfig) ~= "function" then return false, "clipboard import unavailable" end
            local okClip, text = pcall(getclipboard)
            if not okClip or type(text) ~= "string" or text == "" then return false, "clipboard is empty" end
            local okDecode, payload = pcall(function() return HttpService:JSONDecode(text) end)
            if not okDecode then return false, "invalid config JSON" end
            local okApply = applyImportedConfig(payload)
            if okApply then
                if type(syncUiFromConfig) == "function" then pcall(syncUiFromConfig) end
                if type(applyPerformanceSettings) == "function" then pcall(applyPerformanceSettings) end
                if type(applyPlayerMovementState) == "function" then pcall(applyPlayerMovementState) end
                if type(refreshAllEsp) == "function" then pcall(refreshAllEsp) end
                if type(saveSettings) == "function" then pcall(saveSettings) end
            end
            return okApply == true, okApply == true and nil or "config rejected"
        elseif action == "resetdisplay" then
            if type(resetDisplaySettings) ~= "function" then return false, "reset unavailable" end
            pcall(resetDisplaySettings); refreshAfterChange("showNames", CONFIG.showNames); return true
        elseif action == "resetviewsettings" then
            if type(resetViewSettings) ~= "function" then return false, "reset unavailable" end
            pcall(resetViewSettings); if type(applyCameraFov)=="function" then pcall(applyCameraFov) end; if type(applyZoomLimitSetting)=="function" then pcall(applyZoomLimitSetting) end; return true
        elseif action == "resetperformance" then
            if type(resetPerformanceSettings) ~= "function" then return false, "reset unavailable" end
            pcall(resetPerformanceSettings); if type(applyPerformanceSettings)=="function" then pcall(applyPerformanceSettings) end; return true
        elseif action == "resetpositions" then
            if type(resetOverlayPositions) ~= "function" then return false, "reset unavailable" end
            pcall(resetOverlayPositions); return true
        elseif action == "focusclear" then
            CONFIG.focusLock = false
            if espRuntimeState then espRuntimeState.focusedPlayer = nil end
            return true
        end
        return false, "unknown action"
    end

    function bridge:panic()
        for _, key in ipairs({"enabled","focusLock","aimTrainerMode","walkSpeedEnabled","infiniteJump","noclip","fly","clickTeleport","performanceMode","simplifyMaterials","hideTextures","hideEffects","disableShadows"}) do
            if CONFIG[key] ~= nil and typeof(CONFIG[key]) == "boolean" then CONFIG[key] = false end
        end
        if actionState.freecam and type(toggleFreeCam) == "function" then pcall(toggleFreeCam); actionState.freecam = false end
        if type(setEspEnabled) == "function" then pcall(setEspEnabled, false) end
        if type(applyPlayerMovementState) == "function" then pcall(applyPlayerMovementState) end
        if type(setLocalMovementSuppressed) == "function" then pcall(setLocalMovementSuppressed, false) end
        if type(restoreLocalCamera) == "function" then pcall(restoreLocalCamera) end
        if type(applyPerformanceSettings) == "function" then pcall(applyPerformanceSettings) end
        if type(syncUiFromConfig) == "function" then pcall(syncUiFromConfig) end
        if type(saveSettings) == "function" then pcall(saveSettings) end
    end

    function bridge:cleanup()
        if runtimeHooks and type(runtimeHooks.cleanup) == "function" then pcall(runtimeHooks.cleanup) end
        if type(clearAllEsp) == "function" then pcall(clearAllEsp) end
    end

    function bridge:destroyLegacyUi()
        CONFIG.showMiniHud = false
        CONFIG.showKeybindsUi = false
        if window then window.Visible = false end
        if watermark then watermark.Visible = false end
        if miniHud then miniHud.Visible = false end
    end

    SHARED_ENV.__VYRS_V3_BRIDGE = bridge
end
]==]

    local legacyChunk, compileError = loadstring(legacySource)
    if not legacyChunk then error("[0xVyrs v3.2] engine compile failed: " .. tostring(compileError)) end
    local engineOk, engineError = xpcall(legacyChunk, function(err)
        if debug and debug.traceback then return debug.traceback(tostring(err), 2) end
        return tostring(err)
    end)
    if not engineOk then error("[0xVyrs v3.2] engine startup failed:\n" .. tostring(engineError)) end

    local Bridge = env.__VYRS_V3_BRIDGE
    if type(Bridge) ~= "table" then error("[0xVyrs v3.2] bridge failed to initialise") end

    local catalogChunk, catalogError = loadstring(sources.catalog)
    if not catalogChunk then error("[0xVyrs v3.2] catalog compile failed: " .. tostring(catalogError)) end
    local CatalogFactory = catalogChunk()
    local Catalog = CatalogFactory()

    local terminalChunk, terminalError = loadstring(sources.terminal)
    if not terminalChunk then error("[0xVyrs v3.2] terminal compile failed: " .. tostring(terminalError)) end
    local TerminalFactory = terminalChunk()
    local Terminal = TerminalFactory({
        Bridge = Bridge,
        Catalog = Catalog,
        UserInputService = game:GetService("UserInputService"),
        UiParent = UiParent,
    })

    local runtime = { version="3.2-alpha.1", bridge=Bridge, terminal=Terminal, destroyed=false }
    function runtime:destroy()
        if self.destroyed then return end
        self.destroyed = true
        if self.terminal and type(self.terminal.destroy) == "function" then pcall(self.terminal.destroy) end
        if self.bridge then
            pcall(function() self.bridge:panic() end)
            pcall(function() self.bridge:cleanup() end)
            pcall(function() self.bridge:destroyLegacyUi() end)
        end
        env.__VYRS_V32_MODULES = nil
        env.__VYRS_V3_BRIDGE = nil
    end

    env.__VYRS_V3_RUNTIME = runtime
    print(string.format("[0xVyrs v3.2] ready in %.0fms | fast preload | full terminal bridge", (os.clock() - loadStarted) * 1000))
    return runtime
end
