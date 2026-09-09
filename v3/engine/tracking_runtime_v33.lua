return function(context)
    local CONFIG = context.CONFIG
    local LOCAL_PLAYER = context.LOCAL_PLAYER
    local Players = context.Players
    local state = context.state
    local viewState = context.viewState
    local clearEntry = context.clearEntry
    local clearPlayerEsp = context.clearPlayerEsp
    local espObjects = context.espObjects
    local getCharacterRoot = context.getCharacterRoot
    local shouldTrackPlayer = context.shouldTrackPlayer
    local getHeldToolName = context.getHeldToolName
    local isPlayerVisible = context.isPlayerVisible
    local getTargetThreatData = context.getTargetThreatData
    local updatePlayerEsp = context.updatePlayerEsp
    local updatePerfStatsUi = context.updatePerfStatsUi
    local shared = (type(getgenv) == "function" and getgenv()) or _G

    local visibilityCache = setmetatable({}, { __mode = "k" })
    local clearedWhileDisabled = false

    local function adaptiveProfile()
        local profile = shared.__VYRS_ADAPTIVE_PROFILE
        if profile == "quality" or profile == "balanced" or profile == "performance" then
            return profile
        end
        return nil
    end

    local function clearAllEsp()
        for player, entry in pairs(espObjects) do
            clearEntry(entry)
            espObjects[player] = nil
            visibilityCache[player] = nil
        end
    end

    local function getVisibility(player, character, root)
        if not CONFIG.visibilityCheck then
            visibilityCache[player] = nil
            return true
        end

        local now = os.clock()
        local profile = adaptiveProfile()
        local cacheWindow
        if profile == "quality" then
            cacheWindow = 0.055
        elseif profile == "balanced" then
            cacheWindow = 0.085
        elseif profile == "performance" then
            cacheWindow = 0.14
        else
            local fps = context.getCurrentFps()
            cacheWindow = (fps > 0 and fps < 40) and 0.12 or 0.075
        end

        local cached = visibilityCache[player]
        if cached and cached.character == character and now - cached.checkedAt <= cacheWindow then
            return cached.visible
        end

        local visible = isPlayerVisible(character, root)
        visibilityCache[player] = {
            character = character,
            checkedAt = now,
            visible = visible,
        }
        return visible
    end

    local function collectTrackedPlayers(localRoot)
        local trackedPlayers = {}
        local trackedData = {}
        local needsHeldTool = CONFIG.showWeapon
            or CONFIG.threatMode == "Armed"
            or CONFIG.threatMode == "Smart"
            or CONFIG.showTargetCard

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LOCAL_PLAYER and shouldTrackPlayer(player) then
                local character = player.Character
                local root = character and getCharacterRoot(character)
                if character and root and localRoot then
                    local distance = (root.Position - localRoot.Position).Magnitude
                    if distance <= CONFIG.maxDistance then
                        state.trackedEnemyCount = state.trackedEnemyCount + 1
                        local visible = getVisibility(player, character, root)
                        local heldTool = needsHeldTool and getHeldToolName(character) or nil
                        table.insert(trackedPlayers, player)
                        trackedData[player] = {
                            character = character,
                            root = root,
                            distance = distance,
                            visible = visible,
                            heldTool = heldTool,
                            groupDanger = 0,
                        }
                    end
                end
            end
        end

        return trackedPlayers, trackedData
    end

    local function populateGroupDanger(trackedPlayers, trackedData, groupRadius)
        local buckets = {}

        local function bucketCoords(position)
            return math.floor(position.X / groupRadius), math.floor(position.Z / groupRadius)
        end
        local function bucketKey(x, z)
            return tostring(x) .. ":" .. tostring(z)
        end

        for _, player in ipairs(trackedPlayers) do
            local data = trackedData[player]
            if data then
                local bx, bz = bucketCoords(data.root.Position)
                local key = bucketKey(bx, bz)
                buckets[key] = buckets[key] or {}
                table.insert(buckets[key], player)
            end
        end

        for _, player in ipairs(trackedPlayers) do
            local data = trackedData[player]
            if data then
                local bx, bz = bucketCoords(data.root.Position)
                local nearby = 0
                for dx = -1, 1 do
                    for dz = -1, 1 do
                        local bucket = buckets[bucketKey(bx + dx, bz + dz)]
                        if bucket then
                            for _, otherPlayer in ipairs(bucket) do
                                if otherPlayer ~= player then
                                    local otherData = trackedData[otherPlayer]
                                    if otherData and (otherData.root.Position - data.root.Position).Magnitude <= groupRadius then
                                        nearby = nearby + 1
                                    end
                                end
                            end
                        end
                    end
                end
                data.groupDanger = nearby
            end
        end
    end

    local function populateThreatTelemetry(trackedPlayers, trackedData, localRoot, groupRadius)
        local needsTelemetry = CONFIG.threatMode == "Smart" or CONFIG.showTargetCard
        if not needsTelemetry then return end

        if CONFIG.threatMode == "Smart" then
            populateGroupDanger(trackedPlayers, trackedData, groupRadius)
        end

        for _, player in ipairs(trackedPlayers) do
            local playerData = trackedData[player]
            if playerData then
                playerData.telemetry = getTargetThreatData(
                    player,
                    playerData.character,
                    playerData.root,
                    localRoot,
                    playerData.visible,
                    playerData.groupDanger,
                    playerData.heldTool
                )
            end
        end
    end

    local function getThreatScore(playerData)
        local distance = playerData.distance
        local visible = playerData.visible
        local mode = CONFIG.threatMode

        if visible then state.visibleEnemyCount = state.visibleEnemyCount + 1 end

        if mode == "Closest" then
            return -distance
        elseif mode == "Visible" then
            return (visible and 100000 or 0) - distance
        elseif mode == "Armed" then
            return (playerData.heldTool and 100000 or 0) + (visible and 10000 or 0) - distance
        elseif mode == "Smart" then
            local telemetry = playerData.telemetry or {}
            local humanoid = playerData.character:FindFirstChildOfClass("Humanoid")
            local healthFactor = humanoid and humanoid.MaxHealth > 0
                and (1 - math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1))
                or 0
            return (visible and 120000 or 0)
                + (telemetry.weapon and 60000 or 0)
                + (healthFactor * 20000)
                + ((telemetry.aimingAtYou and 1 or 0) * 35000)
                + ((tonumber(telemetry.groupDanger) or 0) * 4000)
                - distance
        end

        return -math.huge
    end

    local function resolveFocusedTarget(trackedPlayers, trackedData)
        local focusedScore = -math.huge
        local lockedFocusValid = false

        for _, player in ipairs(trackedPlayers) do
            local playerData = trackedData[player]
            if playerData then
                local threatScore = getThreatScore(playerData)
                if threatScore > focusedScore then
                    focusedScore = threatScore
                    state.focusedPlayer = player
                end
                if CONFIG.focusLock and player == viewState.lockedFocusTarget then
                    lockedFocusValid = true
                end
            end
        end

        if CONFIG.focusLock then
            if lockedFocusValid then
                state.focusedPlayer = viewState.lockedFocusTarget
            else
                viewState.lockedFocusTarget = state.focusedPlayer
            end
        else
            viewState.lockedFocusTarget = nil
        end
    end

    local function renderTrackedPlayers(trackedData)
        local profile = adaptiveProfile()
        local nearRatio = profile == "performance" and 0.55 or (profile == "balanced" and 0.65 or 0.75)
        local divisor = profile == "performance" and 3 or (profile == "balanced" and 2 or 1)
        local farFrame = divisor == 1 and 0 or (math.floor(os.clock() * 8) % divisor)

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LOCAL_PLAYER then
                local playerData = trackedData[player]
                if not playerData then
                    clearPlayerEsp(player)
                elseif playerData.distance <= (CONFIG.maxDistance * nearRatio) or farFrame == 0 then
                    local ok, err = pcall(updatePlayerEsp, player, playerData)
                    if not ok then
                        warn(string.format("[0xVyrs] ESP update failed for %s: %s", player.Name, tostring(err)))
                    end
                end
            end
        end
    end

    local function refreshAllEsp()
        local refreshStart = os.clock()
        state.visibleEnemyCount = 0
        state.trackedEnemyCount = 0
        state.focusedPlayer = nil

        if not CONFIG.enabled then
            if not clearedWhileDisabled then
                clearAllEsp()
                clearedWhileDisabled = true
            end
            viewState.lockedFocusTarget = nil
            state.lastRefreshMs = (os.clock() - refreshStart) * 1000
            state.updateInterval = 0.12
            updatePerfStatsUi()
            return
        end
        clearedWhileDisabled = false

        local localCharacter = LOCAL_PLAYER.Character
        local localRoot = localCharacter and getCharacterRoot(localCharacter)
        local groupRadius = 28

        if not localRoot then
            clearAllEsp()
            state.lastRefreshMs = (os.clock() - refreshStart) * 1000
            updatePerfStatsUi()
            return
        end

        local trackedPlayers, trackedData = collectTrackedPlayers(localRoot)
        populateThreatTelemetry(trackedPlayers, trackedData, localRoot, groupRadius)
        resolveFocusedTarget(trackedPlayers, trackedData)
        renderTrackedPlayers(trackedData)

        state.lastRefreshMs = (os.clock() - refreshStart) * 1000

        local profile = adaptiveProfile()
        if profile == "quality" then
            state.updateInterval = #trackedPlayers > 30 and (1 / 24) or (1 / 30)
        elseif profile == "balanced" then
            state.updateInterval = #trackedPlayers > 30 and (1 / 18) or (1 / 24)
        elseif profile == "performance" then
            state.updateInterval = #trackedPlayers > 30 and (1 / 14) or (1 / 16)
        else
            local fps = context.getCurrentFps()
            if fps > 0 then
                if fps < 35 then
                    state.updateInterval = 1 / 16
                elseif #trackedPlayers > 30 then
                    state.updateInterval = 1 / 20
                elseif #trackedPlayers > 12 then
                    state.updateInterval = 1 / 24
                else
                    state.updateInterval = 1 / 30
                end
            end
        end

        updatePerfStatsUi()
    end

    return {
        refreshAllEsp = refreshAllEsp,
        clearAllEsp = clearAllEsp,
    }
end
