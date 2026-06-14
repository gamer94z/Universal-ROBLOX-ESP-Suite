return function(context)
	local CONFIG = context.CONFIG
	local THEME = context.THEME
	local LOCAL_PLAYER = context.LOCAL_PLAYER
	local gui = context.gui
	local uiReady = context.uiReady
	local espRuntimeState = context.espRuntimeState
	local miniHudLabels = context.miniHudLabels
	local tracerSliders = context.tracerSliders
	local currentFps = context.getCurrentFps
	local truncateText = context.truncateText
	local getCharacterRoot = context.getCharacterRoot
	local getHeldToolName = context.getHeldToolName
	local getActiveTrainerPresetName = context.getActiveTrainerPresetName
	local getTrainerPresetColor = context.getTrainerPresetColor

	local function updatePerfStatsUi()
		if not miniHudLabels.perfStats then
			return
		end

		miniHudLabels.perfStats.fps.Text = tostring(math.max(0, math.floor(currentFps() + 0.5)))
		miniHudLabels.perfStats.visible.Text = tostring(espRuntimeState.visibleEnemyCount)
		miniHudLabels.perfStats.tracked.Text = tostring(espRuntimeState.trackedEnemyCount)
		miniHudLabels.perfStats.update.Text = string.format("%.1fms", espRuntimeState.lastRefreshMs)

		if miniHudLabels.status then
			miniHudLabels.status.Text = CONFIG.enabled and "ONLINE" or "OFFLINE"
			miniHudLabels.status.TextColor3 = CONFIG.enabled and THEME.accent or THEME.muted
			miniHudLabels.fps.Text = string.format("%d | %.1fms", math.max(0, math.floor(currentFps() + 0.5)), espRuntimeState.lastRefreshMs)
			miniHudLabels.fps.TextColor3 = THEME.text
			miniHudLabels.targets.Text = string.format("%d visible / %d tracked", espRuntimeState.visibleEnemyCount, espRuntimeState.trackedEnemyCount)
			if CONFIG.showFocusTarget and espRuntimeState.focusedPlayer then
				miniHudLabels.focus.Text = truncateText(espRuntimeState.focusedPlayer.Name, 18)
				miniHudLabels.focus.TextColor3 = THEME.focus
			else
				miniHudLabels.focus.Text = "None"
				miniHudLabels.focus.TextColor3 = THEME.text
			end
		end

		if tracerSliders.targetInfo then
			local compactTargetCard = CONFIG.targetCardCompact or CONFIG.minimalMode
			local targetCardHeight = compactTargetCard and 58 or 76
			if tracerSliders.targetCard then
				tracerSliders.targetCard.Size = UDim2.new(0, 228, 0, targetCardHeight)
				tracerSliders.targetCard.Visible = uiReady() and gui.Enabled and CONFIG.showTargetCard
			end
			if espRuntimeState.focusedPlayer and CONFIG.showTargetCard then
				local character = espRuntimeState.focusedPlayer.Character
				local root = character and getCharacterRoot(character)
				local localCharacter = LOCAL_PLAYER.Character
				local localRoot = localCharacter and getCharacterRoot(localCharacter)
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				local details = {}
				local detailsSecondary = {}
				local telemetry = miniHudLabels.utility.targetTelemetry[espRuntimeState.focusedPlayer] or {}

				if humanoid then
					table.insert(details, string.format("%d HP", math.max(0, math.floor(humanoid.Health))))
				end
				if root and localRoot then
					table.insert(details, string.format("%d m", math.floor((root.Position - localRoot.Position).Magnitude + 0.5)))
				end
				if character then
					local heldTool = getHeldToolName(character)
					if heldTool then
						table.insert(details, truncateText(heldTool, 12))
					end
				end
				if telemetry.visible ~= nil then
					table.insert(detailsSecondary, telemetry.visible and "Visible" or "Hidden")
				end
				if telemetry.movementState then
					table.insert(detailsSecondary, telemetry.movementState)
				end
				if telemetry.groupDanger then
					table.insert(detailsSecondary, string.format("Group %d", telemetry.groupDanger))
				end
				if telemetry.lastDamageAt then
					table.insert(detailsSecondary, string.format("Hit %.1fs", math.max(0, tick() - telemetry.lastDamageAt)))
				end

				tracerSliders.targetInfo.Text = truncateText(espRuntimeState.focusedPlayer.Name, 18)
				tracerSliders.targetInfo.TextColor3 = THEME.focus
				if tracerSliders.targetInfoMeta then
					tracerSliders.targetInfoMeta.Text = #details > 0 and truncateText(table.concat(details, "  |  "), 46) or "Tracked target"
					tracerSliders.targetInfoMeta.TextColor3 = THEME.muted
				end
				if tracerSliders.targetInfoMeta2 then
					tracerSliders.targetInfoMeta2.Text = #detailsSecondary > 0 and truncateText(table.concat(detailsSecondary, "  |  "), 46) or "Awaiting telemetry"
					tracerSliders.targetInfoMeta2.TextColor3 = telemetry.aimingAtYou and THEME.focus or THEME.muted
				end
				if tracerSliders.targetBadge then
					tracerSliders.targetBadge.Text = telemetry.aimingAtYou and string.format("AIMING | %d", telemetry.dangerScore or 0) or string.format("DANGER %d", telemetry.dangerScore or 0)
					tracerSliders.targetBadge.TextColor3 = telemetry.aimingAtYou and THEME.focus or THEME.text
					tracerSliders.targetBadge.BackgroundColor3 = telemetry.aimingAtYou and Color3.fromRGB(86, 71, 28) or Color3.fromRGB(35, 40, 53)
				end
				if tracerSliders.targetInfoMeta2 then
					tracerSliders.targetInfoMeta2.Visible = not compactTargetCard
				end
			else
				tracerSliders.targetInfo.Text = "NONE"
				tracerSliders.targetInfo.TextColor3 = THEME.text
				if tracerSliders.targetInfoMeta then
					tracerSliders.targetInfoMeta.Text = "No focus target"
					tracerSliders.targetInfoMeta.TextColor3 = THEME.muted
				end
				if tracerSliders.targetInfoMeta2 then
					tracerSliders.targetInfoMeta2.Text = "--"
					tracerSliders.targetInfoMeta2.TextColor3 = THEME.muted
					tracerSliders.targetInfoMeta2.Visible = not compactTargetCard
				end
				if tracerSliders.targetBadge then
					tracerSliders.targetBadge.Text = "NO LOCK"
					tracerSliders.targetBadge.TextColor3 = THEME.muted
					tracerSliders.targetBadge.BackgroundColor3 = Color3.fromRGB(35, 40, 53)
				end
			end
		end

		if tracerSliders.trainingStatus then
			local trainer = miniHudLabels.utility.trainer
			local activeTrainerPreset = type(getActiveTrainerPresetName) == "function" and getActiveTrainerPresetName() or nil
			local trainerPresetColor = activeTrainerPreset and type(getTrainerPresetColor) == "function" and getTrainerPresetColor(activeTrainerPreset) or nil
			local trainerAccent = trainerPresetColor or (CONFIG.trainerDrillType == "Track" and THEME.focus or THEME.accent)
			local clickShots = math.max(1, (trainer.clickHits or 0) + (trainer.clickMisses or 0))
			local clickAverage = (trainer.clickHits or 0) > 0 and math.floor((trainer.clickTotalMs or 0) / math.max(trainer.clickHits, 1) + 0.5) or nil
			local trackAverage = (trainer.trackHits or 0) > 0 and math.floor((trainer.trackTotalMs or 0) / math.max(trainer.trackHits, 1) + 0.5) or nil
			if CONFIG.aimTrainerMode then
				local parts = {}
				local totalShots = math.max(1, (trainer.hits or 0) + (trainer.misses or 0))
				if CONFIG.trainerReactionTimer and trainer.lastReactionMs then
					table.insert(parts, string.format("%dMS", trainer.lastReactionMs))
				end
				table.insert(parts, CONFIG.trainerDrillType == "Track" and "TRACK" or "CLICK")
				table.insert(parts, string.format("H %d", trainer.hits or 0))
				if CONFIG.trainerDrillType == "Click" then
					table.insert(parts, string.format("M %d", trainer.misses or 0))
					table.insert(parts, string.format("ACC %d%%", math.floor(((trainer.hits or 0) / totalShots) * 100 + 0.5)))
				else
					table.insert(parts, string.format("HOLD %d%%", math.floor((math.min(CONFIG.trainerTrackHoldTime, trainer.holdProgress or 0) / math.max(CONFIG.trainerTrackHoldTime, 1)) * 100 + 0.5)))
				end
				if trainer.bestReactionMs then
					table.insert(parts, string.format("BEST %d", trainer.bestReactionMs))
				end
				if not activeTrainerPreset then
					table.insert(parts, "CUSTOM")
				end
				if CONFIG.trainerChallengeMode and trainer.challengeEndsAt then
					table.insert(parts, string.format("T %d", math.max(0, math.ceil(trainer.challengeEndsAt - tick()))))
				end
				tracerSliders.trainingStatus.Text = table.concat(parts, " | ")
				tracerSliders.trainingStatus.TextColor3 = THEME.focus
			else
				tracerSliders.trainingStatus.Text = "OFF"
				tracerSliders.trainingStatus.TextColor3 = THEME.text
			end

			if tracerSliders.trainingCards then
				local clickCard = tracerSliders.trainingCards.click
				local trackCard = tracerSliders.trainingCards.track
				local clickActive = CONFIG.trainerDrillType == "Click"
				local trackActive = CONFIG.trainerDrillType == "Track"
				local clickStroke = clickCard.frame:FindFirstChildOfClass("UIStroke")
				local trackStroke = trackCard.frame:FindFirstChildOfClass("UIStroke")

				clickCard.badge.Text = CONFIG.aimTrainerMode and (clickActive and "LIVE" or "READY") or "IDLE"
				clickCard.badge.BackgroundColor3 = clickActive and THEME.accentSoft or Color3.fromRGB(35, 40, 53)
				clickCard.badge.TextColor3 = clickActive and THEME.text or THEME.muted
				clickCard.lines[1].Text = string.format("Hits %d | Misses %d", trainer.clickHits or 0, trainer.clickMisses or 0)
				clickCard.lines[2].Text = string.format("Accuracy %d%% | Avg %s", math.floor(((trainer.clickHits or 0) / clickShots) * 100 + 0.5), clickAverage and (tostring(clickAverage) .. "ms") or "--")
				clickCard.lines[3].Text = string.format("Best %s | Last %s", trainer.clickBestMs and (tostring(trainer.clickBestMs) .. "ms") or "--", trainer.lastReactionMs and clickActive and (tostring(trainer.lastReactionMs) .. "ms") or "--")
				clickCard.lines[4].Text = string.format("Streak %d | Peak %d", trainer.clickStreak or 0, trainer.clickBestStreak or 0)
				clickCard.frame.BackgroundColor3 = clickActive and Color3.fromRGB(25, 32, 44) or Color3.fromRGB(22, 27, 37)
				if clickStroke then
					clickStroke.Transparency = clickActive and 0.18 or 0.72
				end

				trackCard.badge.Text = CONFIG.aimTrainerMode and (trackActive and "LIVE" or "READY") or "IDLE"
				trackCard.badge.BackgroundColor3 = trackActive and Color3.fromRGB(86, 71, 28) or Color3.fromRGB(35, 40, 53)
				trackCard.badge.TextColor3 = trackActive and THEME.text or THEME.muted
				trackCard.lines[1].Text = string.format("Tracks %d | Breaks %d", trainer.trackHits or 0, trainer.trackBreaks or 0)
				trackCard.lines[2].Text = string.format("Avg %s | Best %s", trackAverage and (tostring(trackAverage) .. "ms") or "--", trainer.trackBestMs and (tostring(trainer.trackBestMs) .. "ms") or "--")
				trackCard.lines[3].Text = string.format("Hold %d%% | Req %0.1fs", math.floor((math.min(CONFIG.trainerTrackHoldTime, trainer.holdProgress or 0) / math.max(CONFIG.trainerTrackHoldTime, 1)) * 100 + 0.5), CONFIG.trainerTrackHoldTime)
				trackCard.lines[4].Text = string.format("Speed %d | Streak %d/%d", CONFIG.trainerTargetSpeed, trainer.trackStreak or 0, trainer.trackBestStreak or 0)
				trackCard.frame.BackgroundColor3 = trackActive and Color3.fromRGB(40, 35, 23) or Color3.fromRGB(22, 27, 37)
				if trackStroke then
					trackStroke.Transparency = trackActive and 0.18 or 0.72
				end
			end

			if tracerSliders.trainingResultsRow and tracerSliders.trainingResults then
				local results = miniHudLabels.utility.trainer.lastResults
				tracerSliders.trainingResultsRow.Visible = results ~= nil
				if results then
					tracerSliders.trainingResultsRow.BackgroundColor3 = trainerAccent:Lerp(Color3.fromRGB(20, 24, 33), 0.78)
					local resultsStroke = tracerSliders.trainingResultsRow:FindFirstChildOfClass("UIStroke")
					if resultsStroke then
						resultsStroke.Color = trainerAccent
						resultsStroke.Transparency = 0.3
					end
					tracerSliders.trainingResults.badge.Text = string.upper(results.drill or "RUN")
					tracerSliders.trainingResults.badge.BackgroundColor3 = trainerAccent:Lerp(Color3.fromRGB(255, 255, 255), 0.18)
					tracerSliders.trainingResults.badge.TextColor3 = THEME.text
					tracerSliders.trainingResults.lines[1].Text = string.format("Hits %d | Misses %d | Accuracy %d%%", results.hits or 0, results.misses or 0, results.accuracy or 0)
					tracerSliders.trainingResults.lines[2].Text = string.format("Click Avg %s | Click Best %s", results.clickAverage and (tostring(results.clickAverage) .. "ms") or "--", results.clickBest and (tostring(results.clickBest) .. "ms") or "--")
					tracerSliders.trainingResults.lines[3].Text = string.format("Track Avg %s | Track Best %s", results.trackAverage and (tostring(results.trackAverage) .. "ms") or "--", results.trackBest and (tostring(results.trackBest) .. "ms") or "--")
					tracerSliders.trainingResults.lines[4].Text = string.format("Click Peak %d | Track Peak %d | Breaks %d", results.clickPeak or 0, results.trackPeak or 0, results.trackBreaks or 0)
				else
					tracerSliders.trainingResultsRow.BackgroundColor3 = THEME.panelAlt
					local resultsStroke = tracerSliders.trainingResultsRow:FindFirstChildOfClass("UIStroke")
					if resultsStroke then
						resultsStroke.Color = THEME.border
						resultsStroke.Transparency = 0.45
					end
				end
			end

			if tracerSliders.trainingHistoryRow and tracerSliders.trainingHistory then
				local history = miniHudLabels.utility.trainer.history or {}
				tracerSliders.trainingHistoryRow.Visible = #history > 0
				tracerSliders.trainingHistoryRow.BackgroundColor3 = #history > 0 and trainerAccent:Lerp(Color3.fromRGB(20, 24, 33), 0.82) or THEME.panelAlt
				local historyStroke = tracerSliders.trainingHistoryRow:FindFirstChildOfClass("UIStroke")
				if historyStroke then
					historyStroke.Color = #history > 0 and trainerAccent or THEME.border
					historyStroke.Transparency = #history > 0 and 0.35 or 0.45
				end
				tracerSliders.trainingHistory.badge.Text = string.format("%d RUNS", #history)
				tracerSliders.trainingHistory.badge.BackgroundColor3 = #history > 0 and trainerAccent:Lerp(Color3.fromRGB(255, 255, 255), 0.18) or Color3.fromRGB(35, 40, 53)
				tracerSliders.trainingHistory.badge.TextColor3 = #history > 0 and THEME.text or THEME.muted
				for index, line in ipairs(tracerSliders.trainingHistory.lines) do
					local entry = history[index]
					if entry then
						line.Text = string.format(
							"%d. %s | H %d M %d | ACC %d%% | C %s | T %s",
							index,
							string.upper(entry.drill or "RUN"),
							entry.hits or 0,
							entry.misses or 0,
							entry.accuracy or 0,
							entry.clickBest and (tostring(entry.clickBest) .. "ms") or "--",
							entry.trackBest and (tostring(entry.trackBest) .. "ms") or "--"
						)
					else
						line.Text = "--"
					end
				end
			end
		end
	end

	return {
		updatePerfStatsUi = updatePerfStatsUi,
	}
end
