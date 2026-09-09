return function(context)
    local CONFIG = context.CONFIG
    local Lighting = context.Lighting
    local workspace = context.workspace
    local performanceCache = context.performanceCache
    local shared = (type(getgenv) == "function" and getgenv()) or _G

    local pending = setmetatable({}, { __mode = "k" })
    local lastState = nil

    if shared.__VYRS_PERF_DESC_CONN and type(shared.__VYRS_PERF_DESC_CONN.Disconnect) == "function" then
        pcall(function() shared.__VYRS_PERF_DESC_CONN:Disconnect() end)
    end
    shared.__VYRS_PERF_DESC_CONN = workspace.DescendantAdded:Connect(function(item)
        pending[item] = true
    end)

    local function effectiveState()
        return {
            materials = CONFIG.performanceMode or CONFIG.simplifyMaterials,
            textures = CONFIG.performanceMode or CONFIG.hideTextures,
            effects = CONFIG.performanceMode or CONFIG.hideEffects,
            shadows = CONFIG.performanceMode or CONFIG.disableShadows,
        }
    end

    local function sameState(a, b)
        return a and b
            and a.materials == b.materials
            and a.textures == b.textures
            and a.effects == b.effects
            and a.shadows == b.shadows
    end

    local function cacheLighting()
        if not performanceCache.lighting then
            performanceCache.lighting = {
                GlobalShadows = Lighting.GlobalShadows,
                FogEnd = Lighting.FogEnd,
                Brightness = Lighting.Brightness,
            }
        end
    end

    local function applyPart(part, enabled)
        if enabled then
            if not performanceCache.parts[part] then
                performanceCache.parts[part] = {
                    Material = part.Material,
                    Reflectance = part.Reflectance,
                }
            end
            part.Material = Enum.Material.SmoothPlastic
            part.Reflectance = 0
        else
            local cached = performanceCache.parts[part]
            if cached and part.Parent then
                part.Material = cached.Material
                part.Reflectance = cached.Reflectance
            end
            performanceCache.parts[part] = nil
        end
    end

    local function applyTexture(item, enabled)
        if enabled then
            if not performanceCache.textures[item] then
                performanceCache.textures[item] = { Transparency = item.Transparency }
            end
            item.Transparency = 1
        else
            local cached = performanceCache.textures[item]
            if cached and item.Parent then item.Transparency = cached.Transparency end
            performanceCache.textures[item] = nil
        end
    end

    local function applyEffect(item, enabled)
        if enabled then
            if not performanceCache.effects[item] then
                performanceCache.effects[item] = { Enabled = item.Enabled }
            end
            item.Enabled = false
        else
            local cached = performanceCache.effects[item]
            if cached and item.Parent then item.Enabled = cached.Enabled end
            performanceCache.effects[item] = nil
        end
    end

    local function applyOne(item, state)
        if not item or not item.Parent then return end
        if item:IsA("BasePart") then
            applyPart(item, state.materials)
        elseif item:IsA("Decal") or item:IsA("Texture") then
            applyTexture(item, state.textures)
        elseif item:IsA("ParticleEmitter") or item:IsA("Trail") or item:IsA("Beam") or item:IsA("Smoke") or item:IsA("Fire") or item:IsA("Sparkles") then
            applyEffect(item, state.effects)
        end
    end

    local function restoreDisabledCaches(state)
        if not state.materials then
            for item in pairs(performanceCache.parts) do applyPart(item, false) end
        end
        if not state.textures then
            for item in pairs(performanceCache.textures) do applyTexture(item, false) end
        end
        if not state.effects then
            for item in pairs(performanceCache.effects) do applyEffect(item, false) end
        end
    end

    local function applyLighting(state)
        if state.shadows then
            cacheLighting()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000
            Lighting.Brightness = math.max(Lighting.Brightness, 2)
        elseif performanceCache.lighting then
            Lighting.GlobalShadows = performanceCache.lighting.GlobalShadows
            Lighting.FogEnd = performanceCache.lighting.FogEnd
            Lighting.Brightness = performanceCache.lighting.Brightness
            performanceCache.lighting = nil
        end
    end

    local function applyPerformanceSettings()
        local state = effectiveState()
        local changed = not sameState(state, lastState)

        if changed then
            restoreDisabledCaches(state)
            applyLighting(state)

            if state.materials or state.textures or state.effects then
                for _, item in ipairs(workspace:GetDescendants()) do
                    applyOne(item, state)
                end
            end
            lastState = state
            for item in pairs(pending) do pending[item] = nil end
            return
        end

        if state.materials or state.textures or state.effects then
            for item in pairs(pending) do
                applyOne(item, state)
                pending[item] = nil
            end
        else
            for item in pairs(pending) do pending[item] = nil end
        end
    end

    return {
        applyPerformanceSettings = applyPerformanceSettings,
        cleanup = function()
            if shared.__VYRS_PERF_DESC_CONN and type(shared.__VYRS_PERF_DESC_CONN.Disconnect) == "function" then
                pcall(function() shared.__VYRS_PERF_DESC_CONN:Disconnect() end)
                shared.__VYRS_PERF_DESC_CONN = nil
            end
        end,
    }
end
