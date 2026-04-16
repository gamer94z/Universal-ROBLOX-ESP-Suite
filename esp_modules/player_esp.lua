return function(context)
	local CONFIG = context.CONFIG
	local LOCAL_PLAYER = context.LOCAL_PLAYER
	local THEME = context.THEME
	local DEV_TAG_DISTANCE = context.DEV_TAG_DISTANCE
	local getEspEntry = context.getEspEntry
	local clearEntry = context.clearEntry
	local shouldTrackPlayer = context.shouldTrackPlayer
	local getCharacterRoot = context.getCharacterRoot
	local getEspColor = context.getEspColor
	local isPlayerVisible = context.isPlayerVisible
	local getDisplayColor = context.getDisplayColor
	local getDistanceFade = context.getDistanceFade
	local isFocusedTarget = context.isFocusedTarget
	local isDevPlayer = context.isDevPlayer
	local getRainbowColor = context.getRainbowColor
	local getTargetThreatData = context.getTargetThreatData
	local getTracerColor = context.getTracerColor
	local getCamera = context.getCamera
	local getEffectiveBoxMode = context.getEffectiveBoxMode
	local ensureHighlight = context.ensureHighlight
	local updateBoxEsp = context.updateBoxEsp
	local updateSkeletonEsp = context.updateSkeletonEsp
	local updateLookDirectionEsp = context.updateLookDirectionEsp
	local updateBillboardEsp = context.updateBillboardEsp
	local updateTracerEsp = context.updateTracerEsp
	local updateHeadDotEsp = context.updateHeadDotEsp

	local function updatePlayerEsp(player, precomputed)
		local entry = getEspEntry(player)

		if not CONFIG.enabled or not shouldTrackPlayer(player) then
			clearEntry(entry)
			return
		end

		local character = player.Character
		local root = character and getCharacterRoot(character)
		local localCharacter = LOCAL_PLAYER.Character
		local localRoot = localCharacter and getCharacterRoot(localCharacter)

		if not character or not root or not localRoot then
			clearEntry(entry)
			return
		end

		local distance = precomputed and precomputed.distance or (root.Position - localRoot.Position).Magnitude
		if distance > CONFIG.maxDistance then
			clearEntry(entry)
			return
		end

		local espColor = getEspColor(player)
		local visible = precomputed and precomputed.visible
		if visible == nil then
			visible = isPlayerVisible(character, root)
		end
		local displayColor = getDisplayColor(espColor, visible)
		local distanceFade = getDistanceFade(distance)
		local focusTarget = isFocusedTarget(player)
		local showDevTag = isDevPlayer(player) and distance <= DEV_TAG_DISTANCE
		local devRainbowColor = showDevTag and getRainbowColor() or nil
		local telemetry = precomputed and precomputed.telemetry or getTargetThreatData(player, character, root, localRoot, visible)
		local tracerColor = showDevTag and devRainbowColor or (focusTarget and THEME.focus or (CONFIG.visibilityCheck and displayColor or getTracerColor(player)))
		local camera = getCamera()
		local effectiveBoxMode = getEffectiveBoxMode()
		local outlineColor = showDevTag and devRainbowColor or (focusTarget and THEME.focus or (CONFIG.visibilityCheck and displayColor or espColor))
		local fillColor = showDevTag and devRainbowColor or espColor

		local highlight = ensureHighlight(entry, character)
		highlight.FillColor = fillColor
		if showDevTag then
			local pulse = (math.sin(tick() * 3.2) + 1) * 0.5
			highlight.FillTransparency = 0.44 - (pulse * 0.14)
			highlight.OutlineTransparency = 0.02 + (pulse * 0.08)
		else
			if effectiveBoxMode == "Chams" then
				highlight.FillTransparency = math.clamp(CONFIG.fillTransparency + ((1 - distanceFade) * 0.45), 0, 1)
				highlight.OutlineTransparency = math.clamp(CONFIG.outlineTransparency + ((1 - distanceFade) * 0.35), 0, 1)
			elseif effectiveBoxMode == "Flat Chams" then
				highlight.FillTransparency = math.clamp(math.max(0.05, CONFIG.fillTransparency * 0.65) + ((1 - distanceFade) * 0.3), 0, 1)
				highlight.OutlineTransparency = 1
			elseif effectiveBoxMode == "Outline Chams" then
				highlight.FillTransparency = 1
				highlight.OutlineTransparency = math.clamp(CONFIG.outlineTransparency + ((1 - distanceFade) * 0.18), 0, 1)
			elseif effectiveBoxMode == "Split Chams" then
				if visible then
					highlight.FillTransparency = math.clamp(CONFIG.fillTransparency + 0.18 + ((1 - distanceFade) * 0.24), 0, 1)
					highlight.OutlineTransparency = math.clamp(CONFIG.outlineTransparency * 0.55, 0, 1)
				else
					highlight.FillTransparency = math.clamp(math.max(0.08, CONFIG.fillTransparency * 0.72), 0, 1)
					highlight.OutlineTransparency = math.clamp(CONFIG.outlineTransparency + 0.22 + ((1 - distanceFade) * 0.18), 0, 1)
				end
			else
				highlight.FillTransparency = 1
				highlight.OutlineTransparency = 1
			end
		end
		highlight.OutlineColor = outlineColor

		if camera then
			updateBoxEsp(entry, camera, character, outlineColor, fillColor)
			updateSkeletonEsp(entry, camera, character, outlineColor)
			updateLookDirectionEsp(entry, camera, character, root, outlineColor)
		end

		updateBillboardEsp(entry, player, character, distance, focusTarget, showDevTag, devRainbowColor, espColor, distanceFade)
		updateTracerEsp(entry, root, camera, tracerColor, focusTarget, distance, distanceFade)
		updateHeadDotEsp(entry, character, camera, distanceFade, outlineColor, showDevTag, devRainbowColor)
	end

	return {
		updatePlayerEsp = updatePlayerEsp,
	}
end
