--[[
	Copyright (c) 2026 gamer94z / 0xVyrs
	All Rights Reserved.

	This module is part of proprietary 0xVyrs software. Unauthorized copying,
	redistribution, modification, resale, reposting, or reuse is not permitted.
]]

return function(context)
	local featureDefs = {
		{ id = "freeCam", label = "Free Cam" },
		{ id = "focusLock", label = "Focus Lock" },
		{ id = "showTracers", label = "Tracers" },
		{ id = "showCrosshair", label = "Crosshair" },
		{ id = "showFovCircle", label = "FOV Circle" },
		{ id = "showTargetCard", label = "Target Card" },
		{ id = "showMiniHud", label = "Mini HUD" },
		{ id = "showLookDirection", label = "Look Dir" },
	}

	local MODE_VALUES = { "Toggle", "Hold" }
	local MOUSE_INPUTS = {
		MouseButton1 = Enum.UserInputType.MouseButton1,
		MouseButton2 = Enum.UserInputType.MouseButton2,
		MouseButton3 = Enum.UserInputType.MouseButton3,
	}
	local MOUSE_ORDER = { "MouseButton1", "MouseButton2", "MouseButton3" }
	local state = {
		listening = nil,
		rows = {},
		modeButtons = {},
		displayButton = nil,
		menu = nil,
		list = nil,
		title = nil,
		count = nil,
		held = {},
	}

	local function getDef(featureId)
		for _, def in ipairs(featureDefs) do
			if def.id == featureId then
				return def
			end
		end
	end

	local function getKeybindText(id)
		return context.featureKeybinds[id]
	end

	local function isMouseBindText(text)
		return MOUSE_INPUTS[text] ~= nil
	end

	local function getBindDescriptor(text)
		if not text or text == "" then
			return nil
		end

		if isMouseBindText(text) then
			return {
				text = text,
				userInputType = MOUSE_INPUTS[text],
			}
		end

		local keyCode = context.keyTextToKeyCode(text)
		if keyCode then
			return {
				text = context.keyCodeToText(keyCode),
				keyCode = keyCode,
			}
		end

		return nil
	end

	local function getBindForId(id)
		return getBindDescriptor(getKeybindText(id))
	end

	local function inputToBindText(input)
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
			return context.keyCodeToText(input.KeyCode)
		end

		for _, bindText in ipairs(MOUSE_ORDER) do
			if input.UserInputType == MOUSE_INPUTS[bindText] then
				return bindText
			end
		end

		return nil
	end

	local function inputMatchesBind(input, bind)
		if not bind then
			return false
		end

		if bind.keyCode then
			return input.KeyCode == bind.keyCode
		end

		if bind.userInputType then
			return input.UserInputType == bind.userInputType
		end

		return false
	end

	local function getReservedBindTexts()
		local reserved = {}
		local function push(keyCode)
			if keyCode then
				reserved[context.keyCodeToText(keyCode)] = true
			end
		end

		push(context.config.uiToggleKey)
		push(context.config.quickHideKey)
		push(context.config.espToggleKey)
		push(context.config.panicKey)
		return reserved
	end

	local function getMode(id)
		return context.featureKeybindModes[id] or "Toggle"
	end

	local function setMode(id, mode)
		context.featureKeybindModes[id] = mode
	end

	local function isActive(id)
		if id == "freeCam" then
			return context.viewState.freeCamEnabled
		end

		return context.config[id] == true
	end

	local function setFeatureActive(id, desiredState)
		if id == "freeCam" then
			if context.viewState.freeCamEnabled ~= desiredState then
				context.toggleFreeCam()
			end
			return
		end

		if context.config[id] ~= desiredState then
			context.applyConfigToggleState(id, desiredState)
		end
	end

	local function trigger(id)
		if getMode(id) == "Hold" then
			if not state.held[id] then
				state.held[id] = true
				setFeatureActive(id, true)
			end
			return
		end

		setFeatureActive(id, not isActive(id))
	end

	local function release(id)
		if getMode(id) == "Hold" and state.held[id] then
			state.held[id] = nil
			setFeatureActive(id, false)
		end
	end

	local function isTyping()
		return context.userInputService and context.userInputService:GetFocusedTextBox() ~= nil
	end

	local function cycleMode(currentMode)
		for index, value in ipairs(MODE_VALUES) do
			if value == currentMode then
				return MODE_VALUES[(index % #MODE_VALUES) + 1]
			end
		end
		return MODE_VALUES[1]
	end

	local function refreshRows()
		for _, def in ipairs(featureDefs) do
			local button = state.rows[def.id]
			if button then
				if state.listening == def.id then
					button.Text = "PRESS..."
					button.BackgroundColor3 = context.theme.accentSoft
				else
					local text = getKeybindText(def.id)
					button.Text = (text and text ~= "") and text or "NONE"
					button.BackgroundColor3 = Color3.fromRGB(35, 40, 53)
				end
			end

			local modeButton = state.modeButtons[def.id]
			if modeButton then
				modeButton.Text = string.upper(getMode(def.id))
			end
		end

		if state.displayButton then
			if context.setToggleState then
				context.setToggleState(state.displayButton, context.config.showKeybindsUi)
			else
				state.displayButton.Text = context.config.showKeybindsUi and "ON" or "OFF"
			end
		end
	end

	local function getActiveEntries()
		local entries = {}
		for _, def in ipairs(featureDefs) do
			local bind = getBindForId(def.id)
			if bind and isActive(def.id) then
				table.insert(entries, {
					key = bind.text,
					label = def.label,
					mode = getMode(def.id),
				})
			end
		end

		table.sort(entries, function(a, b)
			return a.label < b.label
		end)

		return entries
	end

	local function getAssignedEntries()
		local entries = {}
		for _, def in ipairs(featureDefs) do
			local bind = getBindForId(def.id)
			if bind then
				table.insert(entries, {
					key = bind.text,
					label = def.label,
					mode = getMode(def.id),
				})
			end
		end

		table.sort(entries, function(a, b)
			return a.label < b.label
		end)

		return entries
	end

	local function updateMenu()
		if not state.menu or not state.list or not state.count then
			return
		end

		for _, child in ipairs(state.list:GetChildren()) do
			if not child:IsA("UIListLayout") then
				child:Destroy()
			end
		end

		local activeEntries = getActiveEntries()
		local assignedEntries = getAssignedEntries()
		local showMenu = #activeEntries > 0 or #assignedEntries > 0
		state.menu.Visible = context.gui.Enabled and context.config.showKeybindsUi and showMenu
		state.count.Text = string.format("%d ACTIVE", #activeEntries)

		local menuHeight = 42

		local function addSectionLabel(text, color)
			menuHeight = menuHeight + 14
			context.create("TextLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 12),
				Font = Enum.Font.GothamBold,
				Text = text,
				TextColor3 = color,
				TextSize = 8,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 13,
				Parent = state.list,
			})
		end

		local function addEntryRow(entry, textColor, rowColor)
			menuHeight = menuHeight + 24
			local row = context.create("Frame", {
				BackgroundColor3 = rowColor,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 20),
				ZIndex = 13,
				Parent = state.list,
			})
			context.addCorner(row, 6)

			local label = context.makeLabel(row, entry.label, 9, textColor, Enum.Font.GothamMedium)
			label.Position = UDim2.new(0, 8, 0, 0)
			label.Size = UDim2.new(1, -86, 1, 0)
			label.ZIndex = 14

			local keyBadge = context.create("TextLabel", {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Color3.fromRGB(38, 44, 56),
				BorderSizePixel = 0,
				Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.new(0, 54, 0, 14),
				Font = Enum.Font.GothamBold,
				Text = entry.key,
				TextColor3 = context.theme.text,
				TextSize = 8,
				ZIndex = 14,
				Parent = row,
			})
			context.addCorner(keyBadge, 999)

			if entry.mode == "Hold" then
				local modeBadge = context.create("TextLabel", {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = context.theme.accentSoft,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -66, 0.5, 0),
					Size = UDim2.new(0, 28, 0, 14),
					Font = Enum.Font.GothamBold,
					Text = "HOLD",
					TextColor3 = context.theme.text,
					TextSize = 7,
					ZIndex = 14,
					Parent = row,
				})
				context.addCorner(modeBadge, 999)
			end
		end

		if #activeEntries > 0 then
			addSectionLabel("ACTIVE", context.theme.accent)
			for _, entry in ipairs(activeEntries) do
				addEntryRow(entry, context.theme.text, Color3.fromRGB(27, 33, 44))
			end
		end

		if #assignedEntries > 0 then
			addSectionLabel("ASSIGNED", context.theme.muted)
			for _, entry in ipairs(assignedEntries) do
				addEntryRow(entry, context.theme.muted, Color3.fromRGB(22, 27, 36))
			end
		end

		state.menu.Size = UDim2.new(0, 232, 0, menuHeight)
	end

	local function buildWatermarkMenu()
		local menu = context.create("Frame", {
			BackgroundColor3 = Color3.fromRGB(18, 22, 32),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 16, 0, 98),
			Size = UDim2.new(0, 232, 0, 42),
			Visible = false,
			ZIndex = 12,
			Parent = context.gui,
		})
		context.addCorner(menu, 8)
		context.addStroke(menu, context.theme.border, 0.25, 1)

		local accent = context.create("Frame", {
			BackgroundColor3 = context.theme.accent,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(0, 3, 1, 0),
			ZIndex = 13,
			Parent = menu,
		})
		context.addCorner(accent, 8)

		local title = context.makeLabel(menu, "KEYBINDS", 10, context.theme.text, Enum.Font.GothamBold)
		title.Position = UDim2.new(0, 12, 0, 4)
		title.Size = UDim2.new(0, 100, 0, 14)
		title.ZIndex = 13

		local count = context.create("TextLabel", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = context.theme.accentSoft,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -10, 0, 6),
			Size = UDim2.new(0, 62, 0, 16),
			Font = Enum.Font.GothamBold,
			Text = "0 ACTIVE",
			TextColor3 = context.theme.text,
			TextSize = 8,
			ZIndex = 13,
			Parent = menu,
		})
		context.addCorner(count, 999)

		local list = context.create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 8, 0, 24),
			Size = UDim2.new(1, -16, 1, -28),
			ZIndex = 13,
			Parent = menu,
		})

		context.create("UIListLayout", {
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = list,
		})

		state.menu = menu
		state.list = list
		state.title = title
		state.count = count
	end

	local function assignKeybind(featureId, newText)
		local reserved = getReservedBindTexts()
		if newText ~= "" and reserved[newText] then
			if context.showToast then
				context.showToast("Keybinds", string.format("%s is reserved", newText), context.theme.muted)
			end
			return false
		end

		for otherId, otherText in pairs(context.featureKeybinds) do
			if otherId ~= featureId and otherText == newText and newText ~= "" then
				context.featureKeybinds[otherId] = ""
				local otherDef = getDef(otherId)
				if context.showToast and otherDef then
					context.showToast("Keybinds", string.format("%s moved off %s", otherDef.label, newText), context.theme.muted)
				end
			end
		end

		context.featureKeybinds[featureId] = newText
		return true
	end

	local function resetDefaults()
		for featureId, keyText in pairs(context.defaultFeatureKeybinds) do
			context.featureKeybinds[featureId] = keyText
		end
		for featureId, modeText in pairs(context.defaultFeatureKeybindModes) do
			context.featureKeybindModes[featureId] = modeText
			release(featureId)
		end
		context.saveSettings()
		refreshRows()
		updateMenu()
		if context.showToast then
			context.showToast("Keybinds", "Binds reset to defaults", context.theme.accent)
		end
	end

	local function buildRows(parent)
		local _, headerValue = context.createStatusRow(parent, "BINDS", "PRESS KEY")
		headerValue.TextColor3 = context.theme.accent

		local _, displayButton = context.createToggleRow(parent, "DISPLAY PANEL", context.config.showKeybindsUi)
		state.displayButton = displayButton
		displayButton.MouseButton1Click:Connect(function()
			context.config.showKeybindsUi = not context.config.showKeybindsUi
			context.saveSettings()
			refreshRows()
			updateMenu()
		end)

		for _, def in ipairs(featureDefs) do
			local _, button = context.createKeybindRow(parent, string.upper(def.label), getKeybindText(def.id) or "NONE")
			state.rows[def.id] = button
			button.MouseButton1Click:Connect(function()
				state.listening = state.listening == def.id and nil or def.id
				refreshRows()
			end)

			local _, modeButton = context.createCycleRow(parent, string.upper(def.label .. " MODE"), string.upper(getMode(def.id)))
			state.modeButtons[def.id] = modeButton
			modeButton.MouseButton1Click:Connect(function()
				setMode(def.id, cycleMode(getMode(def.id)))
				context.saveSettings()
				refreshRows()
				updateMenu()
			end)
		end

		local _, resetButton = context.createCycleRow(parent, "RESET BINDS", "DEFAULTS")
		resetButton.MouseButton1Click:Connect(resetDefaults)

		refreshRows()
	end

	local function fireToast(def)
		if not context.showToast then
			return
		end

		local active = isActive(def.id)
		context.showToast("Keybind", string.format("%s %s", def.label, active and "ON" or "OFF"), active and context.theme.accent or context.theme.muted)
	end

	local function handleInput(input)
		if state.listening then
			if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
				assignKeybind(state.listening, "")
			else
				local bindText = inputToBindText(input)
				if bindText then
					assignKeybind(state.listening, bindText)
				end
			end

			state.listening = nil
			context.saveSettings()
			refreshRows()
			updateMenu()
			return true
		end

		if isTyping() then
			return false
		end

		for _, def in ipairs(featureDefs) do
			local bind = getBindForId(def.id)
			if bind and inputMatchesBind(input, bind) then
				trigger(def.id)
				fireToast(def)
				updateMenu()
				return true
			end
		end

		return false
	end

	local function handleInputEnded(input)
		if isTyping() then
			return
		end

		for _, def in ipairs(featureDefs) do
			local bind = getBindForId(def.id)
			if bind and inputMatchesBind(input, bind) then
				release(def.id)
			end
		end

		updateMenu()
	end

	buildWatermarkMenu()

	return {
		buildRows = buildRows,
		handleInput = handleInput,
		handleInputEnded = handleInputEnded,
		update = function()
			refreshRows()
			updateMenu()
		end,
	}
end
