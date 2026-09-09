-- 0xVyrs Universal ROBLOX ESP Suite v2.0
-- Self-contained public release. Runtime modules are pinned to this repository.

local LEGACY_COMMIT = "6087ca45e55cc8a1e3d6b4fda9e265cb63d2e08a"
local RELEASE_COMMIT = "5567a503ada17fd75eb051bc60d96c6f1cbbe394"
local REPO_ROOT = "https://raw.githubusercontent.com/gamer94z/Universal-ROBLOX-ESP-Suite/"
local RELEASE_URL = REPO_ROOT .. RELEASE_COMMIT .. "/"

if type(loadstring) ~= "function" then
    error("[0xVyrs v2.0] loadstring is unavailable")
end

local shared = (type(getgenv) == "function" and getgenv()) or _G
local results, errors = {}, {}
local remaining = 4

local function fetchAsync(key, url)
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

fetchAsync("bootstrap", RELEASE_URL .. "v3/bootstrap_v32.lua")
fetchAsync("stability", RELEASE_URL .. "v3/stability_v323.lua")
fetchAsync("enhancements", RELEASE_URL .. "v3/enhancements_v33.lua")
fetchAsync("entities", RELEASE_URL .. "v3/engine/entity_runtime_v33.lua")
while remaining > 0 do task.wait() end

if next(errors) then
    local parts = {}
    for key, err in pairs(errors) do table.insert(parts, key .. "=" .. err) end
    table.sort(parts)
    error("[0xVyrs v2.0] launcher fetch failed: " .. table.concat(parts, " | "))
end

local function replaceOnce(text, from, to, label)
    local first, last = text:find(from, 1, true)
    if not first then error("[0xVyrs v2.0] patch target missing: " .. tostring(label)) end
    return text:sub(1, first - 1) .. to .. text:sub(last + 1)
end

local source = results.bootstrap
source = replaceOnce(
    source,
    '        tracking_runtime = BASE_URL .. "v3/engine/tracking_runtime.lua",',
    '        tracking_runtime = "' .. RELEASE_URL .. 'v3/engine/tracking_runtime_v33.lua",',
    "adaptive tracking runtime"
)
source = replaceOnce(
    source,
    '        performance_runtime = BASE_URL .. "esp_modules/performance_runtime.lua",',
    '        performance_runtime = "' .. RELEASE_URL .. 'v3/engine/performance_runtime_v323.lua",',
    "reversible performance runtime"
)

local terminalMarker = '    sources.terminal = sources.terminal:gsub("current %.%.= char", "current = current .. char")'
local terminalPatch = terminalMarker .. [[
    sources.terminal = sources.terminal:gsub(
        "tweenWindow%(FULL_SIZE,OPEN_TIME%):Completed:Wait%(%); folded=false; animating=false",
        "local openTween = tweenWindow(FULL_SIZE,OPEN_TIME); openTween.Completed:Wait(); folded=false; animating=false"
    )
    sources.terminal = sources.terminal:gsub(
        "tweenWindow%(FOLDED_SIZE,FOLD_TIME,Enum%.EasingDirection%.In%):Completed:Wait%(%); folded=true; body%.Visible=false; minimize%.Text=\"□\"; animating=false",
        "local foldTween = tweenWindow(FOLDED_SIZE,FOLD_TIME,Enum.EasingDirection.In); foldTween.Completed:Wait(); folded=true; body.Visible=false; minimize.Text=\"□\"; animating=false"
    )
    sources.terminal = replacePlain(sources.terminal, "0xVyrs Runtime [3.2]", "0xVyrs Runtime [2.0]")
    sources.terminal = replacePlain(
        sources.terminal,
        "            connect(button.MouseButton1Click,function() local ok,err=Bridge:set(key,not Bridge:get(key)); if not ok then writeLine(tostring(err),theme.error) end; refresh() end)",
        "            connect(button.MouseButton1Click,function() local ok,err=Bridge:set(key,not Bridge:get(key)); if not ok then writeLine(tostring(err),theme.error) elseif context.requestRender then context.requestRender(currentCategory) else refresh() end end)"
    )
    sources.terminal = replacePlain(
        sources.terminal,
        '        writeLine("  respawn | tools | panic | clear | hide")',
        '        writeLine("  search <term> | inspect <player> | doctor | unload | restart")\n        writeLine("  respawn | tools | panic | clear | hide")'
    )
    sources.terminal = replacePlain(
        sources.terminal,
        '        elseif command=="panic" then Bridge:panic(); renderCategory(currentCategory); writeLine("panic state applied",theme.warning)',
        '        elseif command=="search" then local ok,e=Bridge:call("search",table.concat(args," ")); writeLine(tostring(e),ok and theme.cyan or theme.error)\n        elseif command=="inspect" then local info,e=Bridge:inspectPlayer(table.concat(args," ")); if info then writeLine(string.format("%s @%s | HP %.0f/%.0f | %.0f studs | visible=%s | tool=%s | %s",info.displayName,info.name,info.health,info.maxHealth,info.distance,info.visible and "YES" or "NO",info.tool,info.movement),theme.cyan) else writeLine(tostring(e),theme.error) end\n        elseif command=="doctor" then local ok,e=Bridge:call("doctor"); writeLine(tostring(e),ok and theme.cyan or theme.error)\n        elseif command=="unload" or command=="restart" then local ok,e=Bridge:call(command); writeLine(tostring(e),ok and theme.warning or theme.error)\n        elseif command=="panic" then Bridge:panic(); renderCategory(currentCategory); writeLine("panic state applied",theme.warning)'
    )
]]
source = replaceOnce(source, terminalMarker, terminalPatch, "terminal v2.0 hooks")

local focusMarker = '        elseif action == "resetview" then'
local focusPatch = [[        elseif action == "focus" then
            local player = findPlayer(tostring(argument or ""))
            if not player then return false, "player not found" end
            CONFIG.focusLock = true
            CONFIG.showFocusTarget = true
            if espRuntimeState then espRuntimeState.focusedPlayer = player end
            if viewState then viewState.lockedFocusTarget = player end
            if type(refreshAllEsp) == "function" then pcall(refreshAllEsp) end
            if type(syncUiFromConfig) == "function" then pcall(syncUiFromConfig) end
            return true
        elseif action == "resetview" then]]
source = replaceOnce(source, focusMarker, focusPatch, "direct focus action")

local cleanupMarker = [[    function bridge:cleanup()
        if runtimeHooks and type(runtimeHooks.cleanup) == "function" then pcall(runtimeHooks.cleanup) end
        if type(clearAllEsp) == "function" then pcall(clearAllEsp) end
    end]]
local cleanupPatch = [[    function bridge:cleanup()
        if runtimeHooks and type(runtimeHooks.cleanup) == "function" then pcall(runtimeHooks.cleanup) end
        if performanceRuntime and type(performanceRuntime.cleanup) == "function" then pcall(performanceRuntime.cleanup) end
        if viewState and viewState.walkSpeedChangedConnection then
            pcall(function() viewState.walkSpeedChangedConnection:Disconnect() end)
            viewState.walkSpeedChangedConnection = nil
        end
        if type(clearAllEsp) == "function" then pcall(clearAllEsp) end
    end]]
source = replaceOnce(source, cleanupMarker, cleanupPatch, "engine cleanup")

source = source:gsub("3%.2%-alpha%.1", "2.0")
source = source:gsub("%[0xVyrs v3%.2%]", "[0xVyrs v2.0]")
source = source:gsub('engine = "v3%.2"', 'engine = "v2.0"')

local bootstrapChunk, bootstrapError = loadstring(source)
if not bootstrapChunk then error("[0xVyrs v2.0] bootstrap compile failed: " .. tostring(bootstrapError)) end
local initOk, bootstrap = pcall(bootstrapChunk)
if not initOk or type(bootstrap) ~= "function" then error("[0xVyrs v2.0] bootstrap init failed: " .. tostring(bootstrap)) end

local enhancementSource = results.enhancements
enhancementSource = replaceOnce(
    enhancementSource,
    '        local overlayObjects, inspectorLabels = {}, {}\n        local mode="base"',
    '        local overlayObjects, inspectorLabels = {}, {}\n        local overlayConnections = {}\n        local function connectOverlay(signal, callback) local connection=signal:Connect(callback); table.insert(overlayConnections,connection); return connection end\n        local mode="base"',
    "overlay connection manager"
)
enhancementSource = replaceOnce(
    enhancementSource,
    '        local function clearOverlay() for _,object in ipairs(overlayObjects) do if object and object.Parent then object:Destroy() end end overlayObjects={} inspectorLabels={} end',
    '        local function clearOverlay() for _,connection in ipairs(overlayConnections) do pcall(function() connection:Disconnect() end) end overlayConnections={} for _,object in ipairs(overlayObjects) do if object and object.Parent then object:Destroy() end end overlayObjects={} inspectorLabels={} end',
    "overlay cleanup"
)
enhancementSource = enhancementSource:gsub('connect%(row%.MouseButton1Click,callback%); return row', 'connectOverlay(row.MouseButton1Click,callback); return row')
enhancementSource = replaceOnce(
    enhancementSource,
    [[            connect(row.MouseButton1Click,function()
                local current=Bridge:get(key)
                if typeof(current)=="boolean" then local ok,err=Bridge:set(key,not current); if not ok then write(err,theme.error) end; refresh()
                elseif typeof(current)=="number" then write("Use: set "..key.." <value>",theme.cyan)
                else write(key.." = "..tostring(current),theme.cyan) end
            end)
            refresh(); return row]],
    [[            connectOverlay(row.MouseButton1Click,function()
                local current=Bridge:get(key)
                if typeof(current)=="boolean" then local ok,err=Bridge:set(key,not current); if not ok then write(err,theme.error) end; refresh()
                elseif typeof(current)=="number" then write("Use: set "..key.." <value>",theme.cyan)
                else write(key.." = "..tostring(current),theme.cyan) end
            end)
            refresh(); return row]],
    "overlay setting connection"
)
enhancementSource = enhancementSource:gsub('connect%(spectate%.MouseButton1Click,', 'connectOverlay(spectate.MouseButton1Click,')
enhancementSource = enhancementSource:gsub('connect%(focus%.MouseButton1Click,', 'connectOverlay(focus.MouseButton1Click,')
enhancementSource = enhancementSource:gsub('connect%(clear%.MouseButton1Click,', 'connectOverlay(clear.MouseButton1Click,')

-- Navigation: all overlay views have an explicit route back to normal ESP controls.
enhancementSource = replaceOnce(
    enhancementSource,
    '            mode="search"; clearOverlay(); categoryBar.Visible=false; baseScroll.Visible=false; overlay.Visible=true; heading("SEARCH: "..tostring(query))',
    '            mode="search"; clearOverlay(); categoryBar.Visible=false; baseScroll.Visible=false; overlay.Visible=true; actionRow("<< BACK TO ESP",showBase,theme.accent); heading("SEARCH: "..tostring(query))',
    "search back navigation"
)
enhancementSource = replaceOnce(
    enhancementSource,
    '            mode="players"; search.Text=""; clearOverlay(); categoryBar.Visible=false; baseScroll.Visible=false; overlay.Visible=true; heading("PLAYER INSPECTOR")',
    '            mode="players"; search.Text=""; clearOverlay(); categoryBar.Visible=false; baseScroll.Visible=false; overlay.Visible=true; actionRow("<< BACK TO ESP",showBase,theme.accent); heading("PLAYER INSPECTOR")',
    "player back navigation"
)
enhancementSource = replaceOnce(
    enhancementSource,
    '            mode="v33"; search.Text=""; clearOverlay(); categoryBar.Visible=false; baseScroll.Visible=false; overlay.Visible=true',
    '            mode="v33"; search.Text=""; clearOverlay(); categoryBar.Visible=false; baseScroll.Visible=false; overlay.Visible=true; actionRow("<< BACK TO ESP",showBase,theme.accent)',
    "v2 runtime back navigation"
)
enhancementSource = replaceOnce(
    enhancementSource,
    '        connect(playersButton.MouseButton1Click,showPlayers); connect(v33Button.MouseButton1Click,showV33)',
    '        connect(playersButton.MouseButton1Click,function() if mode=="players" then showBase() else showPlayers() end end); connect(v33Button.MouseButton1Click,function() if mode=="v33" then showBase() else showV33() end end)',
    "overlay toggle navigation"
)
enhancementSource = enhancementSource:gsub("V3%.3 RUNTIME", "V2.0 RUNTIME")
enhancementSource = enhancementSource:gsub("%[v3%.3%]", "[v2.0]")
enhancementSource = enhancementSource:gsub('runtime.version="3%.3%-alpha%.1"', 'runtime.version="2.0"')

local stabilitySource = results.stability:gsub('runtime.version = "3%.2%.3"', 'runtime.version = "2.0"')

local function compileFactory(name, sourceText)
    local chunk, compileError = loadstring(sourceText)
    if not chunk then error("[0xVyrs v2.0] " .. name .. " compile failed: " .. tostring(compileError)) end
    local ok, factory = pcall(chunk)
    if not ok or type(factory) ~= "function" then error("[0xVyrs v2.0] " .. name .. " init failed: " .. tostring(factory)) end
    return factory
end

local stabilityFactory = compileFactory("stability", stabilitySource)
local enhancementFactory = compileFactory("enhancements", enhancementSource)
local entityFactory = compileFactory("entity runtime", results.entities)

local activeRuntime = nil
local restarting = false

local function startRuntime()
    local success, runtimeOrError = xpcall(function()
        local runtime = bootstrap({ BaseUrl = RELEASE_URL })
        stabilityFactory(runtime)
        enhancementFactory({ Runtime=runtime, EntityFactory=entityFactory })
        runtime.version = "2.0"
        return runtime
    end, function(runtimeError)
        if debug and debug.traceback then return debug.traceback(tostring(runtimeError), 2) end
        return tostring(runtimeError)
    end)
    if not success then error("[0xVyrs v2.0] startup failed:\n" .. tostring(runtimeOrError)) end
    activeRuntime = runtimeOrError
    shared.__VYRS_V33_ACTIVE_RUNTIME = activeRuntime
    return activeRuntime
end

shared.__VYRS_V33_RESTART = function()
    if restarting then return end
    restarting = true
    local oldRuntime = activeRuntime
    if oldRuntime and type(oldRuntime.destroy) == "function" then pcall(function() oldRuntime:destroy() end) end
    task.wait(0.08)
    local ok, err = pcall(startRuntime)
    restarting = false
    if not ok then warn("[0xVyrs v2.0] restart failed: " .. tostring(err)) end
end

local runtime = startRuntime()
print("[0xVyrs v2.0] ready | command console + adaptive renderer + player inspector + entity adapters")
return runtime
