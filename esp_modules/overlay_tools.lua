--[[
	Copyright (c) 2026 gamer94z / 0xVyrs
	All Rights Reserved.

	This module is part of proprietary 0xVyrs software. Unauthorized copying,
	redistribution, modification, resale, reposting, or reuse is not permitted.
]]

return function(context)
	local releaseTrack = {
		latestVersion = "1.4",
		title = "Cleaner UI + Better Intro",
		notes = {
			"The intro now matches the main UI style much more closely.",
			"The menu feels cleaner and easier to read.",
			"Key pages were grouped better so settings are easier to find.",
			"Saved configs are easier to manage.",
			"Tooltips were improved for settings that were hard to understand.",
			"Floating panels behave more reliably when moved around.",
			"Preset selection is simpler and easier to use.",
			"General polish across visuals, controls, and layout.",
		},
	}

	local function getViewportSize()
		local camera = workspace.CurrentCamera
		return camera and camera.ViewportSize or Vector2.new(1920, 1080)
	end

	local function getOverlayConfigKeys(overlayId)
		if overlayId == "miniHud" then
			return "miniHudOffsetX", "miniHudOffsetY"
		end

		if overlayId == "keybindPanel" then
			return "keybindPanelOffsetX", "keybindPanelOffsetY"
		end

		if overlayId == "targetCard" then
			return "targetCardOffsetX", "targetCardOffsetY"
		end

		return nil, nil
	end

	local function getDefaultOverlayPosition(frame, overlayId)
		local viewport = getViewportSize()
		if overlayId == "miniHud" then
			return viewport.X - frame.AbsoluteSize.X - 16, 16
		end

		if overlayId == "keybindPanel" then
			return 16, 98
		end

		if overlayId == "targetCard" then
			return viewport.X - frame.AbsoluteSize.X - 16, 180
		end

		return 16, 16
	end

	local function clampOverlayPosition(frame, x, y)
		local viewport = getViewportSize()
		local maxX = math.max(0, viewport.X - frame.AbsoluteSize.X)
		local maxY = math.max(0, viewport.Y - frame.AbsoluteSize.Y)
		return math.clamp(math.floor(x + 0.5), 0, maxX), math.clamp(math.floor(y + 0.5), 0, maxY)
	end

	local function setOverlayPosition(frame, overlayId, x, y, skipSave)
		local keyX, keyY = getOverlayConfigKeys(overlayId)
		if not keyX or not keyY then
			return
		end

		x, y = clampOverlayPosition(frame, x, y)
		frame.AnchorPoint = Vector2.zero
		frame.Position = UDim2.new(0, x, 0, y)
		context.config[keyX] = x
		context.config[keyY] = y
		if not skipSave then
			context.saveSettings()
		end
	end

	local function makeOverlayDraggable(frame, overlayId)
		local keyX, keyY = getOverlayConfigKeys(overlayId)
		if not keyX or not keyY then
			return
		end

		if context.config[keyX] == nil or context.config[keyY] == nil or context.config[keyX] < 0 or context.config[keyY] < 0 then
			local defaultX, defaultY = getDefaultOverlayPosition(frame, overlayId)
			setOverlayPosition(frame, overlayId, defaultX, defaultY, true)
		else
			setOverlayPosition(frame, overlayId, context.config[keyX], context.config[keyY], true)
		end
		frame.Active = true
		frame.Draggable = true
		frame:GetPropertyChangedSignal("Position"):Connect(function()
			local position = frame.Position
			if position.X.Scale ~= 0 or position.Y.Scale ~= 0 then
				return
			end
			if context.config[keyX] ~= position.X.Offset or context.config[keyY] ~= position.Y.Offset then
				context.config[keyX] = position.X.Offset
				context.config[keyY] = position.Y.Offset
				context.saveSettings()
			end
		end)
	end

	local function resetOverlayPosition(frame, overlayId)
		if not frame then
			return
		end
		local defaultX, defaultY = getDefaultOverlayPosition(frame, overlayId)
		setOverlayPosition(frame, overlayId, defaultX, defaultY, false)
	end

	local function compareSemanticVersions(left, right)
		local function parse(version)
			local parts = {}
			for number in tostring(version):gmatch("%d+") do
				table.insert(parts, tonumber(number) or 0)
			end
			return parts
		end

		local leftParts = parse(left)
		local rightParts = parse(right)
		local count = math.max(#leftParts, #rightParts)
		for index = 1, count do
			local a = leftParts[index] or 0
			local b = rightParts[index] or 0
			if a ~= b then
				return a < b and -1 or 1
			end
		end

		return 0
	end

	local function buildUpdatePanel(parent)
		local row = context.createRow(parent, 178)
		row.BackgroundColor3 = context.theme.panelAlt

		local title = context.makeLabel(row, "UPDATE TRACK", 10, context.theme.accent, Enum.Font.GothamBold)
		title.Position = UDim2.new(0, 10, 0, 8)
		title.Size = UDim2.new(0, 112, 0, 12)

		local statusBadge = context.create("TextLabel", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = context.theme.accentSoft,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -10, 0, 8),
			Size = UDim2.new(0, 92, 0, 18),
			Font = Enum.Font.GothamBold,
			Text = "CHECKING",
			TextColor3 = context.theme.text,
			TextSize = 8,
			Parent = row,
		})
		context.addCorner(statusBadge, 999)

		local current = context.makeLabel(row, "", 9, context.theme.text, Enum.Font.GothamBold)
		current.Position = UDim2.new(0, 10, 0, 28)
		current.Size = UDim2.new(0.48, -8, 0, 12)

		local latest = context.makeLabel(row, "", 9, context.theme.muted, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
		latest.Position = UDim2.new(0.52, 0, 0, 28)
		latest.Size = UDim2.new(0.48, -10, 0, 12)

		local headline = context.makeLabel(row, releaseTrack.title, 10, context.theme.text, Enum.Font.GothamMedium)
		headline.Position = UDim2.new(0, 10, 0, 46)
		headline.Size = UDim2.new(1, -120, 0, 14)

		local checkButton = context.create("TextButton", {
			AnchorPoint = Vector2.new(1, 0),
			AutoButtonColor = false,
			BackgroundColor3 = Color3.fromRGB(35, 40, 53),
			BorderSizePixel = 0,
			Position = UDim2.new(1, -10, 0, 44),
			Size = UDim2.new(0, 92, 0, 20),
			Font = Enum.Font.GothamBold,
			Text = "CHECK NOW",
			TextColor3 = context.theme.text,
			TextSize = 8,
			Parent = row,
		})
		context.addCorner(checkButton, 999)
		context.addStroke(checkButton, context.theme.border, 0.35, 1)

		local notesScroller = context.create("ScrollingFrame", {
			Active = true,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Color3.fromRGB(20, 24, 33),
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0, 10, 0, 68),
			ScrollBarImageColor3 = context.theme.accent,
			ScrollBarThickness = 4,
			Size = UDim2.new(1, -20, 1, -78),
			Parent = row,
		})
		context.addCorner(notesScroller, 6)
		context.addStroke(notesScroller, context.theme.border, 0.35, 1)

		context.create("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			Parent = notesScroller,
		})

		context.create("UIListLayout", {
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = notesScroller,
		})

		local notes = {}
		for index = 1, #releaseTrack.notes do
			local note = context.makeLabel(notesScroller, "", 9, context.theme.muted, Enum.Font.GothamMedium)
			note.AutomaticSize = Enum.AutomaticSize.Y
			note.Size = UDim2.new(1, 0, 0, 0)
			note.TextWrapped = true
			notes[index] = note
		end

		return {
			row = row,
			status = statusBadge,
			current = current,
			latest = latest,
			headline = headline,
			check = checkButton,
			scroller = notesScroller,
			notes = notes,
		}
	end

	local function updateReleasePanel(panel)
		if not panel or not panel.status then
			return
		end

		local comparison = compareSemanticVersions(context.config.version, releaseTrack.latestVersion)
		local upToDate = comparison >= 0
		panel.current.Text = string.format("CURRENT  v%s", context.config.version)
		panel.latest.Text = string.format("LATEST  v%s", releaseTrack.latestVersion)
		panel.headline.Text = releaseTrack.title
		panel.status.Text = upToDate and "UP TO DATE" or "UPDATE READY"
		panel.status.BackgroundColor3 = upToDate and context.theme.accentSoft or Color3.fromRGB(92, 76, 28)
		panel.status.TextColor3 = context.theme.text

		for index, note in ipairs(panel.notes or {}) do
			note.Text = releaseTrack.notes[index] and ("- " .. releaseTrack.notes[index]) or ""
		end
	end

	local function bindUpdatePanel(panel)
		if not panel or not panel.check then
			return
		end

		panel.check.MouseButton1Click:Connect(function()
			updateReleasePanel(panel)
			if compareSemanticVersions(context.config.version, releaseTrack.latestVersion) >= 0 then
				context.showToast("Update Checker", string.format("You're on v%s", context.config.version), context.theme.accent)
			else
				context.showToast("Update Checker", string.format("Latest is v%s", releaseTrack.latestVersion), context.theme.focus)
			end
		end)
	end

	return {
		buildUpdatePanel = buildUpdatePanel,
		bindUpdatePanel = bindUpdatePanel,
		makeOverlayDraggable = makeOverlayDraggable,
		resetOverlayPosition = resetOverlayPosition,
		updateReleasePanel = updateReleasePanel,
	}
end
