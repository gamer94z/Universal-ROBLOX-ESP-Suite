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

	local function collectTrackedPlayers(localRoot)
		local trackedPlayers = {}
		local trackedData = {}

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LOCAL_PLAYER then
				local character = player.Character
				local root = character and getCharacterRoot(character)
				if character and root and localRoot and shouldTrackPlayer(player) then
					state.trackedEnemyCount = state.trackedEnemyCount + 1
					local distance = (root.Position - localRoot.Position).Magnitude
					if distance <= CONFIG.maxDistance then
						local visible = isPlayerVisible(character, root)
						local heldTool = getHeldToolName(character)
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

	local function populateThreatTelemetry(trackedPlayers, trackedData, localRoot, groupRadius)
		for index, player in ipairs(trackedPlayers) do
			local playerData = trackedData[player]
			if playerData then
				for otherIndex = index + 1, #trackedPlayers do
					local otherPlayer = trackedPlayers[otherIndex]
					local otherData = trackedData[otherPlayer]
					if otherData and (otherData.root.Position - playerData.root.Position).Magnitude <= groupRadius then
						playerData.groupDanger = playerData.groupDanger + 1
						otherData.groupDanger = otherData.groupDanger + 1
					end
				end

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
		local telemetry = playerData.telemetry
		local distance = playerData.distance
		local visible = playerData.visible
		local mode = CONFIG.threatMode

		if visible then
			state.visibleEnemyCount = state.visibleEnemyCount + 1
		end

		if mode == "Closest" then
			return -distance
		end

		if mode == "Visible" then
			return (visible and 100000 or 0) - distance
		end

		if mode == "Armed" then
			return (playerData.heldTool and 100000 or 0) + (visible and 10000 or 0) - distance
		end

		if mode == "Smart" then
			local humanoid = playerData.character:FindFirstChildOfClass("Humanoid")
			local healthFactor = humanoid and humanoid.MaxHealth > 0 and (1 - math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)) or 0
			return (visible and 120000 or 0) + (telemetry.weapon and 60000 or 0) + (healthFactor * 20000) + ((telemetry.aimingAtYou and 1 or 0) * 35000) + (telemetry.groupDanger * 4000) - distance
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
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LOCAL_PLAYER then
				pcall(function()
					local playerData = trackedData[player]
					local distance = playerData and playerData.distance or 0
					if distance > (CONFIG.maxDistance * 0.7) and math.floor(tick() * 4) % 2 == 1 then
						return
					end
					updatePlayerEsp(player, playerData)
				end)
			end
		end
	end

	local function refreshAllEsp()
		local refreshStart = os.clock()
		state.visibleEnemyCount = 0
		state.trackedEnemyCount = 0
		state.focusedPlayer = nil
		local localCharacter = LOCAL_PLAYER.Character
		local localRoot = localCharacter and getCharacterRoot(localCharacter)
		local groupRadius = 28

		if not localRoot then
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LOCAL_PLAYER then
					clearPlayerEsp(player)
				end
			end
			state.lastRefreshMs = (os.clock() - refreshStart) * 1000
			updatePerfStatsUi()
			return
		end

		local trackedPlayers, trackedData = collectTrackedPlayers(localRoot)
		populateThreatTelemetry(trackedPlayers, trackedData, localRoot, groupRadius)
		resolveFocusedTarget(trackedPlayers, trackedData)
		renderTrackedPlayers(trackedData)

		state.lastRefreshMs = (os.clock() - refreshStart) * 1000
		if context.getCurrentFps() > 0 then
			if context.getCurrentFps() < 35 then
				state.updateInterval = 1 / 16
			elseif state.trackedEnemyCount > 12 then
				state.updateInterval = 1 / 24
			else
				state.updateInterval = 1 / 30
			end
		end
		updatePerfStatsUi()
	end

	local function clearAllEsp()
		for player, entry in pairs(espObjects) do
			clearEntry(entry)
			espObjects[player] = nil
		end
	end

	return {
		refreshAllEsp = refreshAllEsp,
		clearAllEsp = clearAllEsp,
	}
end
