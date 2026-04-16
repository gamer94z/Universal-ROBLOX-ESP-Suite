--[[
	Copyright (c) 2026 gamer94z / 0xVyrs
	All Rights Reserved.

	This script is proprietary software. Unauthorized copying, redistribution,
	modification, resale, reposting, or reuse of this source is not permitted.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LOCAL_PLAYER = Players.LocalPlayer

getgenv().__VYRS_ESP_ACTIVE_TOKEN = tostring(os.clock())

local CONFIG = {
	enabled = true,
	showNames = true,
	showDistance = true,
	distanceFade = true,
	showHealth = true,
	showWeapon = true,
	showSkeleton = false,
	showHeadDot = false,
	headDotSize = 6,
	showFocusTarget = true,
	showBoxes = true,
	threatMode = "Closest",
	focusLock = false,
	visibilityCheck = true,
	showTracers = true,
	tracerOriginMode = "Bottom",
	tracerThickness = 2,
	tracerTransparency = 100,
	showCrosshair = true,
	showFovCircle = true,
	crosshairStyle = "Cross",
	crosshairColor = "White",
	crosshairSize = 7,
	crosshairThickness = 2,
	crosshairGap = 3,
	fovRadius = 60,
	fovCircleThickness = 2,
	fovCircleTransparency = 90,
	aimTrainerMode = false,
	trainerDrillType = "Click",
	trainerReactionTimer = true,
	trainerHitWindow = 18,
	trainerChallengeMode = false,
	trainerChallengeDuration = 30,
	trainerShrinkingTargets = false,
	trainerTrackHoldTime = 2,
	trainerTargetSpeed = 110,
	recoilVisualizer = false,
	spreadVisualizer = false,
	cameraFov = 70,
	freeCamSpeed = 72,
	removeZoomLimit = false,
	walkSpeedEnabled = false,
	walkSpeed = 24,
	infiniteJump = false,
	noclip = false,
	fly = false,
	flySpeed = 72,
	clickTeleport = false,
	boxMode = "Chams",
	minimalMode = false,
	showMiniHud = true,
	keybindsEnabled = true,
	showKeybindsUi = true,
	showLookDirection = true,
	antiAfk = false,
	autoLoadGamePreset = true,
	performanceMode = false,
	simplifyMaterials = false,
	hideTextures = false,
	hideEffects = false,
	disableShadows = false,
	showTargetCard = true,
	targetCardCompact = false,
	textStackMode = "Inline",
	tracerStyle = "Direct",
	spectateMode = "Direct",
	cameraRigPreset = "Mid",
	fallbackEspColor = Color3.fromRGB(255, 2, 127),
	visibleColor = Color3.fromRGB(117, 255, 160),
	hiddenColor = Color3.fromRGB(255, 116, 116),
	fillTransparency = 0.3,
	outlineTransparency = 0,
	maxDistance = 2500,
	panelTitle = "0xVyrs",
	panelSubtitle = " Panel",
	version = "1.4.1",
	windowOffsetX = 0,
	windowOffsetY = 0,
	miniHudOffsetX = -1,
	miniHudOffsetY = 16,
	keybindPanelOffsetX = 16,
	keybindPanelOffsetY = 98,
	targetCardOffsetX = -1,
	targetCardOffsetY = -1,
	uiToggleKey = Enum.KeyCode.RightShift,
	quickHideKey = Enum.KeyCode.K,
	espToggleKey = Enum.KeyCode.F4,
	panicKey = Enum.KeyCode.End,
}

local DEFAULT_FEATURE_KEYBINDS = {
	freeCam = "V",
	focusLock = "Q",
	showTracers = "T",
	showCrosshair = "C",
	showFovCircle = "Z",
	showTargetCard = "H",
	showMiniHud = "M",
	showLookDirection = "L",
}

local FEATURE_KEYBINDS = {}
for featureId, keyText in pairs(DEFAULT_FEATURE_KEYBINDS) do
	FEATURE_KEYBINDS[featureId] = keyText
end

local DEFAULT_FEATURE_KEYBIND_MODES = {
	freeCam = "Toggle",
	focusLock = "Toggle",
	showTracers = "Toggle",
	showCrosshair = "Toggle",
	showFovCircle = "Toggle",
	showTargetCard = "Toggle",
	showMiniHud = "Toggle",
	showLookDirection = "Toggle",
}

local FEATURE_KEYBIND_MODES = {}
for featureId, modeText in pairs(DEFAULT_FEATURE_KEYBIND_MODES) do
	FEATURE_KEYBIND_MODES[featureId] = modeText
end

local THEME = {
	window = Color3.fromRGB(20, 22, 30),
	header = Color3.fromRGB(26, 29, 39),
	panel = Color3.fromRGB(29, 32, 43),
	panelAlt = Color3.fromRGB(23, 25, 34),
	border = Color3.fromRGB(78, 84, 102),
	text = Color3.fromRGB(244, 246, 252),
	muted = Color3.fromRGB(172, 180, 200),
	accent = Color3.fromRGB(88, 166, 255),
	accentSoft = Color3.fromRGB(39, 72, 116),
	focus = Color3.fromRGB(255, 214, 102),
	shadow = Color3.fromRGB(0, 0, 0),
}

local existingGui = CoreGui:FindFirstChild("ESPGUI")
if existingGui then
	existingGui:Destroy()
end

local function create(className, properties)
	local instance = Instance.new(className)

	for key, value in pairs(properties) do
		if key ~= "Parent" then
			instance[key] = value
		end
	end

	instance.Parent = properties.Parent
	return instance
end

local function addCorner(parent, radius)
	create("UICorner", {
		CornerRadius = UDim.new(0, radius),
		Parent = parent,
	})
end

local function addStroke(parent, color, transparency, thickness)
	create("UIStroke", {
		Color = color,
		Transparency = transparency or 0,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

local function makeLabel(parent, text, size, color, font, alignment)
	return create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = font or Enum.Font.Gotham,
		Text = text,
		TextColor3 = color or THEME.text,
		TextSize = size or 12,
		TextXAlignment = alignment or Enum.TextXAlignment.Left,
		Parent = parent,
	})
end

local function keyCodeToText(keyCode)
	return tostring(keyCode):gsub("Enum.KeyCode.", ""):upper()
end

local function keyTextToKeyCode(keyText)
	if not keyText or keyText == "" then
		return nil
	end

	local direct
	pcall(function()
		direct = Enum.KeyCode[keyText]
	end)
	if direct then
		return direct
	end

	local upper = tostring(keyText):upper()
	for _, keyCode in ipairs(Enum.KeyCode:GetEnumItems()) do
		if keyCodeToText(keyCode) == upper then
			return keyCode
		end
	end

	return nil
end

local function formatSettingName(key)
	local words = {}
	for part in key:gmatch("[^_]+") do
		local withSpaces = part:gsub("(%l)(%u)", "%1 %2")
		table.insert(words, withSpaces:sub(1, 1):upper() .. withSpaces:sub(2))
	end
	return table.concat(words, " ")
end

local function truncateText(text, maxLength)
	if #text <= maxLength then
		return text
	end

	return text:sub(1, math.max(1, maxLength - 3)) .. "..."
end

local function createDrawing(kind)
	if not Drawing or type(Drawing.new) ~= "function" then
		return nil
	end

	local success, object = pcall(function()
		return Drawing.new(kind)
	end)

	if not success then
		return nil
	end

	return object
end

local function supportsDrawing(kind)
	local object = createDrawing(kind)
	if not object then
		return false
	end

	object:Remove()
	return true
end

local SETTINGS_FILE = "esp_settings.json"
local CONFIG_SLOTS_FILE = "esp_config_slots.json"
local DEV_USER_ID = 10006170169
local DEV_TAG_TEXT = "0xVyrs [DEV]"
local DEV_TAG_DISTANCE = 125
local DEFAULT_FOV_RADIUS = 60
local DEFAULT_CAMERA_FOV = 70
local FLY_ACCELERATION = 10
local FLY_DECELERATION = 14
local FLY_PRECISION_MULTIPLIER = 0.35
local FLY_BOOST_MULTIPLIER = 1.75
local NON_PERSISTENT_CONFIG_KEYS = {
	walkSpeedEnabled = true,
	walkSpeed = true,
	infiniteJump = true,
	noclip = true,
	fly = true,
	flySpeed = true,
	clickTeleport = true,
	performanceMode = true,
	simplifyMaterials = true,
	hideTextures = true,
	hideEffects = true,
	disableShadows = true,
}
local visibleEnemyCount = 0
local PRESETS
local currentPresetIndex = 2
local SETTING_KEYS
local toastLayer
local uiReady = false
local syncUiFromConfig
local getCharacterRoot
local applyConfigToggleState
local loadedTrainerRecords
local loadedTrainerCustomPresets
local keybindController
local overlayTools
local loadConfigSlot
local deleteConfigSlot
local getConfigSlotNames
local keybindState = {
	toggleButtonsByConfig = {},
}
local KEYBINDS_MODULE_SOURCE = [==[
return function(context)
	local featureDefs = {
		{ id = "freeCam", label = "Free Cam" },
		{ id = "focusLock", label = "Focus Lock" },
		{ id = "showTargetCard", label = "Target Card" },
		{ id = "showMiniHud", label = "Mini HUD" },
		{ id = "showLookDirection", label = "Look Dir" },
		{ id = "showTracers", label = "Tracers" },
		{ id = "showCrosshair", label = "Crosshair" },
		{ id = "showFovCircle", label = "FOV Circle" },
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
		enabledButton = nil,
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

	local function releaseAllHeld()
		for _, def in ipairs(featureDefs) do
			release(def.id)
		end
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

		if state.enabledButton then
			if context.setToggleState then
				context.setToggleState(state.enabledButton, context.config.keybindsEnabled)
			else
				state.enabledButton.Text = context.config.keybindsEnabled and "ON" or "OFF"
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
		local allowVisible = true
		if context.isUiReady then
			allowVisible = context.isUiReady()
		end
		state.menu.Visible = allowVisible and context.gui.Enabled and context.config.showKeybindsUi and showMenu
		state.count.Text = context.config.keybindsEnabled and string.format("%d ACTIVE", #activeEntries) or "DISABLED"

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

		local dragHandle = context.create("TextButton", {
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 0, 24),
			Text = "",
			ZIndex = 14,
			Parent = menu,
		})

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
		if context.makeOverlayDraggable then
			context.makeOverlayDraggable(menu, "keybindPanel", dragHandle)
		end
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
		local pairIndex = 0
		local function styleSection(row, accentColor)
			if not row then
				return
			end
			row.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
			local stroke = row:FindFirstChildOfClass("UIStroke")
			if stroke then
				stroke.Color = accentColor or context.theme.border
				stroke.Transparency = 0.28
			end
		end

		local function styleBindRow(row, isModeRow)
			if not row then
				return
			end
			local toneA = isModeRow and Color3.fromRGB(24, 28, 38) or Color3.fromRGB(30, 34, 45)
			local toneB = isModeRow and Color3.fromRGB(21, 25, 34) or Color3.fromRGB(26, 30, 40)
			row.BackgroundColor3 = (pairIndex % 2 == 0) and toneA or toneB
			local stroke = row:FindFirstChildOfClass("UIStroke")
			if stroke then
				stroke.Transparency = isModeRow and 0.52 or 0.4
			end
		end

		local _, headerValue = context.createStatusRow(parent, "BINDS", "PRESS / DEL / RMB")
		headerValue.TextColor3 = context.theme.accent

		local enabledRow, enabledButton = context.createToggleRow(parent, "KEYBINDS ENABLED", context.config.keybindsEnabled)
		styleSection(enabledRow, context.theme.accent)
		state.enabledButton = enabledButton
		enabledButton.MouseButton1Click:Connect(function()
			context.config.keybindsEnabled = not context.config.keybindsEnabled
			if not context.config.keybindsEnabled then
				releaseAllHeld()
			end
			context.saveSettings()
			refreshRows()
			updateMenu()
		end)

		local displayRow, displayButton = context.createToggleRow(parent, "DISPLAY PANEL", context.config.showKeybindsUi)
		styleSection(displayRow, context.theme.border)
		state.displayButton = displayButton
		displayButton.MouseButton1Click:Connect(function()
			context.config.showKeybindsUi = not context.config.showKeybindsUi
			context.saveSettings()
			refreshRows()
			updateMenu()
		end)

		styleSection(select(1, context.createStatusRow(parent, "VIEW + TARGET", "TOGGLE")), context.theme.focus)
		for _, def in ipairs(featureDefs) do
			if def.id == "showTracers" then
				styleSection(select(1, context.createStatusRow(parent, "VISUAL OVERLAYS", "TOGGLE")), context.theme.accent)
			end
			local bindRow, button = context.createKeybindRow(parent, string.upper(def.label), getKeybindText(def.id) or "NONE")
			styleBindRow(bindRow, false)
			state.rows[def.id] = button
			button.MouseButton1Click:Connect(function()
				state.listening = state.listening == def.id and nil or def.id
				refreshRows()
			end)
			button.MouseButton2Click:Connect(function()
				assignKeybind(def.id, "")
				context.saveSettings()
				refreshRows()
				updateMenu()
				if context.showToast then
					context.showToast("Keybinds", string.format("%s cleared", def.label), context.theme.muted)
				end
			end)

			local modeRow, modeButton = context.createCycleRow(parent, string.upper(def.label .. " MODE"), string.upper(getMode(def.id)))
			styleBindRow(modeRow, true)
			state.modeButtons[def.id] = modeButton
			modeButton.MouseButton1Click:Connect(function()
				setMode(def.id, cycleMode(getMode(def.id)))
				context.saveSettings()
				refreshRows()
				updateMenu()
			end)
			pairIndex = pairIndex + 1
		end

		styleSection(select(1, context.createStatusRow(parent, "RESET", "DEFAULTS")), context.theme.muted)
		local resetRow, resetButton = context.createCycleRow(parent, "RESET BINDS", "DEFAULTS")
		styleBindRow(resetRow, true)
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

		if not context.config.keybindsEnabled then
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
		resetPosition = function()
			if context.resetOverlayPosition and state.menu then
				context.resetOverlayPosition(state.menu, "keybindPanel")
			end
		end,
		update = function()
			refreshRows()
			updateMenu()
		end,
	}
end
]==]
local OVERLAY_TOOLS_MODULE_SOURCE = [==[
return function(context)
	local releaseTrack = {
		latestVersion = "1.4.1",
		title = "Stability Fixes + UI Cleanup",
		notes = {
			"Fixed issues that could make the script stop working properly.",
			"Improved crosshair and mouse-follow behavior.",
			"Cleaned up the menu so main pages are easier to use.",
			"Updated the intro and UI styling to feel more consistent.",
			"Improved overall stability across the main features.",
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
]==]

local function canUseFileApi()
	return type(isfile) == "function" and type(readfile) == "function" and type(writefile) == "function"
end

local function requireLocalModule(modulePath, fallbackSource)
	if type(loadstring) ~= "function" then
		return nil
	end

	local source = fallbackSource
	if type(readfile) == "function" then
		pcall(function()
			source = readfile(modulePath)
		end)
	end

	if type(source) ~= "string" or source == "" then
		return nil
	end

	local success, result = pcall(function()
		local chunk = loadstring(source)
		return chunk and chunk()
	end)

	if success then
		return result
	end

	return nil
end

local function shouldPersistConfigKey(key)
	return not NON_PERSISTENT_CONFIG_KEYS[key]
end

function normalizeBoxMode(value)
	if value == "Highlight" or value == "Chams" then
		return "Chams"
	end

	for _, option in ipairs(BOX_MODE_OPTIONS) do
		if value == option then
			return value
		end
	end

	return "Chams"
end

local function loadSettings()
	if not canUseFileApi() or not isfile(SETTINGS_FILE) then
		return
	end

	local success, decoded = pcall(function()
		return HttpService:JSONDecode(readfile(SETTINGS_FILE))
	end)

	if not success or type(decoded) ~= "table" then
		return
	end

	local configSource = decoded
	local keybindSource = decoded.featureKeybinds
	local bindModeSource = decoded.featureKeybindModes
	loadedTrainerRecords = type(decoded.trainerPersonalBests) == "table" and decoded.trainerPersonalBests or nil
	loadedTrainerCustomPresets = type(decoded.trainerCustomPresets) == "table" and decoded.trainerCustomPresets or nil
	if decoded.placeConfigs and decoded.placeConfigs[tostring(game.PlaceId)] and decoded.placeConfigs[tostring(game.PlaceId)].settings and decoded.autoLoadGamePreset ~= false then
		configSource = decoded.placeConfigs[tostring(game.PlaceId)].settings
		keybindSource = decoded.placeConfigs[tostring(game.PlaceId)].featureKeybinds or keybindSource
		bindModeSource = decoded.placeConfigs[tostring(game.PlaceId)].featureKeybindModes or bindModeSource
		if type(decoded.placeConfigs[tostring(game.PlaceId)].trainerPersonalBests) == "table" then
			loadedTrainerRecords = decoded.placeConfigs[tostring(game.PlaceId)].trainerPersonalBests
		end
		if type(decoded.placeConfigs[tostring(game.PlaceId)].trainerCustomPresets) == "table" then
			loadedTrainerCustomPresets = decoded.placeConfigs[tostring(game.PlaceId)].trainerCustomPresets
		end
	end

	for _, key in ipairs(SETTING_KEYS) do
		if shouldPersistConfigKey(key) and configSource[key] ~= nil then
			if key == "boxMode" then
				CONFIG[key] = normalizeBoxMode(configSource[key])
			else
				CONFIG[key] = configSource[key]
			end
		end
	end

	if configSource.minimalMode == nil and configSource.compactMode ~= nil then
		CONFIG.minimalMode = configSource.compactMode == true
	end

	if type(keybindSource) == "table" then
		for featureId, keyText in pairs(keybindSource) do
			if FEATURE_KEYBINDS[featureId] ~= nil and type(keyText) == "string" then
				FEATURE_KEYBINDS[featureId] = keyText
			end
		end
	end

	if type(bindModeSource) == "table" then
		for featureId, modeText in pairs(bindModeSource) do
			if FEATURE_KEYBIND_MODES[featureId] ~= nil and type(modeText) == "string" then
				FEATURE_KEYBIND_MODES[featureId] = modeText
			end
		end
	end

	local presetIndex = decoded.currentPresetIndex
	if decoded.placeConfigs and decoded.placeConfigs[tostring(game.PlaceId)] and decoded.placeConfigs[tostring(game.PlaceId)].currentPresetIndex and decoded.autoLoadGamePreset ~= false then
		presetIndex = decoded.placeConfigs[tostring(game.PlaceId)].currentPresetIndex
	end

	if presetIndex and PRESETS[presetIndex] then
		currentPresetIndex = presetIndex
	end
end

local function saveSettings()
	if not canUseFileApi() then
		return
	end

	local payload = {}

	if isfile(SETTINGS_FILE) then
		pcall(function()
			local existing = HttpService:JSONDecode(readfile(SETTINGS_FILE))
			if type(existing) == "table" then
				payload = existing
			end
		end)
	end

	payload.currentPresetIndex = currentPresetIndex
	payload.autoLoadGamePreset = CONFIG.autoLoadGamePreset

	for _, key in ipairs(SETTING_KEYS) do
		if shouldPersistConfigKey(key) then
			payload[key] = (key == "boxMode") and normalizeBoxMode(CONFIG[key]) or CONFIG[key]
		else
			payload[key] = nil
		end
	end

	payload.featureKeybinds = payload.featureKeybinds or {}
	for featureId, keyText in pairs(FEATURE_KEYBINDS) do
		payload.featureKeybinds[featureId] = keyText
	end
	payload.featureKeybindModes = payload.featureKeybindModes or {}
	for featureId, modeText in pairs(FEATURE_KEYBIND_MODES) do
		payload.featureKeybindModes[featureId] = modeText
	end
	if miniHudLabels and miniHudLabels.utility and miniHudLabels.utility.trainer then
		payload.trainerPersonalBests = {
			clickBestMs = miniHudLabels.utility.trainer.clickBestMs,
			clickBestStreak = miniHudLabels.utility.trainer.clickBestStreak,
			trackBestMs = miniHudLabels.utility.trainer.trackBestMs,
			trackBestStreak = miniHudLabels.utility.trainer.trackBestStreak,
		}
	end
	payload.trainerCustomPresets = TRAINER_CUSTOM_PRESETS

	payload.placeConfigs = payload.placeConfigs or {}
	payload.placeConfigs[tostring(game.PlaceId)] = {
		currentPresetIndex = currentPresetIndex,
		settings = {},
	}

	for _, key in ipairs(SETTING_KEYS) do
		if shouldPersistConfigKey(key) then
			payload.placeConfigs[tostring(game.PlaceId)].settings[key] = (key == "boxMode") and normalizeBoxMode(CONFIG[key]) or CONFIG[key]
		else
			payload.placeConfigs[tostring(game.PlaceId)].settings[key] = nil
		end
	end
	payload.placeConfigs[tostring(game.PlaceId)].featureKeybinds = payload.placeConfigs[tostring(game.PlaceId)].featureKeybinds or {}
	for featureId, keyText in pairs(FEATURE_KEYBINDS) do
		payload.placeConfigs[tostring(game.PlaceId)].featureKeybinds[featureId] = keyText
	end
	payload.placeConfigs[tostring(game.PlaceId)].featureKeybindModes = payload.placeConfigs[tostring(game.PlaceId)].featureKeybindModes or {}
	for featureId, modeText in pairs(FEATURE_KEYBIND_MODES) do
		payload.placeConfigs[tostring(game.PlaceId)].featureKeybindModes[featureId] = modeText
	end
	if miniHudLabels and miniHudLabels.utility and miniHudLabels.utility.trainer then
		payload.placeConfigs[tostring(game.PlaceId)].trainerPersonalBests = {
			clickBestMs = miniHudLabels.utility.trainer.clickBestMs,
			clickBestStreak = miniHudLabels.utility.trainer.clickBestStreak,
			trackBestMs = miniHudLabels.utility.trainer.trackBestMs,
			trackBestStreak = miniHudLabels.utility.trainer.trackBestStreak,
		}
	end
	payload.placeConfigs[tostring(game.PlaceId)].trainerCustomPresets = TRAINER_CUSTOM_PRESETS

	pcall(function()
		writefile(SETTINGS_FILE, HttpService:JSONEncode(payload))
	end)
end

local function showToast(title, detail, accentColor)
	local toast = create("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(20, 24, 34),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 24, 0, 0),
		Size = UDim2.new(1, 0, 0, 0),
		ZIndex = 31,
		Parent = toastLayer,
	})
	addCorner(toast, 10)
	addStroke(toast, accentColor or THEME.accent, 0.2, 1)

	create("UIPadding", {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		Parent = toast,
	})

	local titleLabel = makeLabel(toast, title, 11, THEME.text, Enum.Font.GothamBold)
	titleLabel.AutomaticSize = Enum.AutomaticSize.Y
	titleLabel.Size = UDim2.new(1, 0, 0, 14)
	titleLabel.ZIndex = 32

	local detailLabel = makeLabel(toast, detail, 10, THEME.muted, Enum.Font.GothamMedium)
	detailLabel.AutomaticSize = Enum.AutomaticSize.Y
	detailLabel.Position = UDim2.new(0, 0, 0, 16)
	detailLabel.Size = UDim2.new(1, 0, 0, 12)
	detailLabel.ZIndex = 32

	toast.BackgroundTransparency = 1
	titleLabel.TextTransparency = 1
	detailLabel.TextTransparency = 1

	TweenService:Create(toast, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0,
		Position = UDim2.new(0, 0, 0, 0),
	}):Play()
	TweenService:Create(titleLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
	}):Play()
	TweenService:Create(detailLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
	}):Play()

	task.delay(1.8, function()
		TweenService:Create(toast, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 24, 0, 0),
		}):Play()
		TweenService:Create(titleLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			TextTransparency = 1,
		}):Play()
		TweenService:Create(detailLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			TextTransparency = 1,
		}):Play()

		task.delay(0.24, function()
			if toast then
				toast:Destroy()
			end
		end)
	end)
end

local DRAWING_SUPPORT = {
	line = supportsDrawing("Line"),
	square = supportsDrawing("Square"),
	circle = supportsDrawing("Circle"),
}

local miniHudLabels = {}

local gui = create("ScreenGui", {
	Name = "ESPGUI",
	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = CoreGui,
})
gui:SetAttribute("ActiveToken", getgenv().__VYRS_ESP_ACTIVE_TOKEN)

local watermark = create("Frame", {
	BackgroundColor3 = Color3.fromRGB(18, 22, 32),
	BorderSizePixel = 0,
	Position = UDim2.new(0, 16, 0, 64),
	Size = UDim2.new(0, 168, 0, 28),
	Visible = false,
	ZIndex = 12,
	Parent = gui,
})
addCorner(watermark, 8)
addStroke(watermark, THEME.border, 0.25, 1)

addCorner(create("Frame", {
	BackgroundColor3 = THEME.accent,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(0, 3, 1, 0),
	ZIndex = 13,
	Parent = watermark,
}), 8)

do
	local label = makeLabel(watermark, string.format("%s  v%s", CONFIG.panelTitle, CONFIG.version), 10, THEME.text, Enum.Font.GothamBold)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.Size = UDim2.new(1, -18, 1, 0)
	label.ZIndex = 13
end

local miniHud = create("Frame", {
	AnchorPoint = Vector2.zero,
	BackgroundColor3 = Color3.fromRGB(18, 22, 32),
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 0, 16),
	Size = UDim2.new(0, 228, 0, 152),
	ZIndex = 12,
	Parent = gui,
})
addCorner(miniHud, 10)
addStroke(miniHud, THEME.border, 0.25, 1)

create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(26, 30, 42)),
		ColorSequenceKeypoint.new(0.55, Color3.fromRGB(18, 22, 31)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 15, 22)),
	}),
	Rotation = 90,
	Parent = miniHud,
})

do
	create("Frame", {
		BackgroundColor3 = THEME.accent,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 3),
		ZIndex = 13,
		Parent = miniHud,
	})

	local label = makeLabel(miniHud, CONFIG.panelTitle .. " Telemetry", 12, THEME.text, Enum.Font.GothamBold)
	label.Position = UDim2.new(0, 12, 0, 10)
	label.Size = UDim2.new(1, -82, 0, 16)
	label.ZIndex = 13
end


do
	local chip = create("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = THEME.accentSoft,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -12, 0, 12),
		Size = UDim2.new(0, 54, 0, 16),
		Font = Enum.Font.GothamBold,
		Text = "LIVE",
		TextColor3 = THEME.text,
		TextSize = 8,
		ZIndex = 13,
		Parent = miniHud,
	})
	addCorner(chip, 999)

	local label = makeLabel(miniHud, "Realtime combat snapshot", 9, THEME.muted, Enum.Font.GothamMedium)
	label.Position = UDim2.new(0, 12, 0, 28)
	label.Size = UDim2.new(1, -24, 0, 12)
	label.ZIndex = 13

	create("Frame", {
		BackgroundColor3 = Color3.fromRGB(44, 49, 64),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 12, 0, 46),
		Size = UDim2.new(1, -24, 0, 1),
		ZIndex = 13,
		Parent = miniHud,
	})
end

local miniHudBody = create("Frame", {
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 12, 0, 56),
	Size = UDim2.new(1, -24, 0, 82),
	ZIndex = 13,
	Parent = miniHud,
})

create("UIListLayout", {
	Padding = UDim.new(0, 6),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = miniHudBody,
})

local function createMiniHudRow(title)
	local row = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(22, 27, 37),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Size = UDim2.new(1, 0, 0, 16),
		ZIndex = 13,
		Parent = miniHudBody,
	})
	addCorner(row, 6)

	local left = makeLabel(row, title, 8, THEME.muted, Enum.Font.GothamBold)
	left.Position = UDim2.new(0, 8, 0, 0)
	left.Size = UDim2.new(0.36, 0, 1, 0)
	left.ZIndex = 14

	local valueCard = create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Color3.fromRGB(34, 40, 53),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -6, 0.5, 0),
		Size = UDim2.new(0.6, 0, 0, 12),
		ZIndex = 14,
		Parent = row,
	})
	addCorner(valueCard, 999)

	local right = makeLabel(valueCard, "--", 8, THEME.text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
	right.Size = UDim2.new(1, 0, 1, 0)
	right.ZIndex = 15

	return right
end

miniHudLabels.status = createMiniHudRow("STATUS")
miniHudLabels.fps = createMiniHudRow("REFRESH")
miniHudLabels.targets = createMiniHudRow("CONTACTS")
miniHudLabels.focus = createMiniHudRow("LOCK")
miniHud.Visible = false

toastLayer = create("Frame", {
	AnchorPoint = Vector2.new(1, 1),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(1, -16, 1, -16),
	Size = UDim2.new(0, 260, 0, 180),
	ZIndex = 30,
	Parent = gui,
})

create("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
	Padding = UDim.new(0, 8),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = toastLayer,
})

miniHudLabels.tooltipFrame = create("Frame", {
	AutomaticSize = Enum.AutomaticSize.XY,
	BackgroundColor3 = Color3.fromRGB(18, 22, 32),
	BackgroundTransparency = 0.06,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 0, 0),
	Visible = false,
	ZIndex = 40,
	Parent = gui,
})
addCorner(miniHudLabels.tooltipFrame, 8)
addStroke(miniHudLabels.tooltipFrame, THEME.border, 0.18, 1)

create("UIPadding", {
	PaddingLeft = UDim.new(0, 10),
	PaddingRight = UDim.new(0, 10),
	PaddingTop = UDim.new(0, 7),
	PaddingBottom = UDim.new(0, 7),
	Parent = miniHudLabels.tooltipFrame,
})

miniHudLabels.tooltipLabel = makeLabel(miniHudLabels.tooltipFrame, "", 10, THEME.text, Enum.Font.GothamMedium)
miniHudLabels.tooltipLabel.AutomaticSize = Enum.AutomaticSize.XY
miniHudLabels.tooltipLabel.TextWrapped = true
miniHudLabels.tooltipLabel.Size = UDim2.new(0, 220, 0, 0)
miniHudLabels.tooltipLabel.ZIndex = 41
miniHudLabels.utility = {
	lastHealth = {},
	killCredit = {},
}

miniHudLabels.utility.killText = create("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 1),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 1, -108),
	Size = UDim2.new(0, 380, 0, 30),
	Font = Enum.Font.GothamBlack,
	RichText = true,
	Text = "",
	TextColor3 = THEME.text,
	TextSize = 20,
	TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
	TextStrokeTransparency = 0.55,
	TextTransparency = 1,
	Visible = false,
	ZIndex = 19,
	Parent = gui,
})

miniHudLabels.utility.killTextGlow = create("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 1),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = miniHudLabels.utility.killText.Position + UDim2.new(0, 0, 0, 1),
	Size = miniHudLabels.utility.killText.Size,
	Font = Enum.Font.GothamBlack,
	RichText = true,
	Text = "",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 20,
	TextStrokeColor3 = Color3.fromRGB(255, 68, 68),
	TextStrokeTransparency = 0.85,
	TextTransparency = 1,
	Visible = false,
	ZIndex = 18,
	Parent = gui,
})

miniHudLabels.bindTooltip = function(guiObject, text)
	if not guiObject or not guiObject.IsA or not guiObject:IsA("GuiObject") then
		return
	end

	local function resolveText()
		if type(text) == "function" then
			local ok, result = pcall(text)
			return ok and tostring(result or "") or ""
		end
		return tostring(text or "")
	end

	guiObject.MouseEnter:Connect(function()
		miniHudLabels.tooltipLabel.Text = resolveText()
		miniHudLabels.tooltipFrame.Visible = true
		local mouseLocation = UserInputService:GetMouseLocation()
		miniHudLabels.tooltipFrame.Position = UDim2.new(0, mouseLocation.X + 14, 0, mouseLocation.Y + 18)
	end)

	guiObject.MouseMoved:Connect(function(x, y)
		miniHudLabels.tooltipFrame.Position = UDim2.new(0, x + 14, 0, y + 18)
	end)

	guiObject.MouseLeave:Connect(function()
		miniHudLabels.tooltipFrame.Visible = false
	end)
end

miniHudLabels.utility.applyAntiAfk = function()
	if miniHudLabels.utility.idleConnection then
		miniHudLabels.utility.idleConnection:Disconnect()
		miniHudLabels.utility.idleConnection = nil
	end

	if CONFIG.antiAfk then
		miniHudLabels.utility.idleConnection = LOCAL_PLAYER.Idled:Connect(function()
			pcall(function()
				game:GetService("VirtualUser"):CaptureController()
				game:GetService("VirtualUser"):ClickButton2(Vector2.new())
			end)
		end)
	end
end

miniHudLabels.utility.showKillText = function(text)
	local label = miniHudLabels.utility.killText
	local glow = miniHudLabels.utility.killTextGlow
	if not label or not glow then
		return
	end

	local richText = text
		:gsub("&", "&amp;")
		:gsub("<", "&lt;")
		:gsub(">", "&gt;")
		:gsub("killed", "<font color=\"#FF5A5A\">killed</font>")

	label.Text = richText
	glow.Text = richText
	label.Visible = true
	glow.Visible = true
	label.TextTransparency = 1
	label.TextStrokeTransparency = 1
	glow.TextTransparency = 1
	glow.TextStrokeTransparency = 1

	TweenService:Create(label, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
		TextStrokeTransparency = 0.55,
	}):Play()
	TweenService:Create(glow, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0.18,
		TextStrokeTransparency = 0.82,
	}):Play()

	task.delay(1.4, function()
		if not label or label.Text ~= richText then
			return
		end

		TweenService:Create(label, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			TextTransparency = 1,
			TextStrokeTransparency = 1,
		}):Play()
		TweenService:Create(glow, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			TextTransparency = 1,
			TextStrokeTransparency = 1,
		}):Play()

		task.delay(0.24, function()
			if label and label.Text == richText then
				label.Visible = false
				glow.Visible = false
			end
		end)
	end)
end

local INTRO_ANIMATION_MODULE_SOURCE = [==[
return function(context)
	local create = context.create
	local addCorner = context.addCorner
	local addStroke = context.addStroke
	local makeLabel = context.makeLabel
	local TweenService = context.TweenService
	local RunService = context.RunService
	local gui = context.gui
	local CONFIG = context.CONFIG
	local THEME = context.THEME

	local palette = {
		bg0 = Color3.fromRGB(6, 9, 14),
		bg1 = THEME.window:Lerp(Color3.fromRGB(8, 10, 16), 0.35),
		bg2 = THEME.header:Lerp(Color3.fromRGB(18, 24, 34), 0.2),
		header = THEME.header,
		panel = THEME.panel,
		panelAlt = THEME.panelAlt,
		border = THEME.border,
		text = THEME.text,
		muted = THEME.muted,
		accent = THEME.accent,
		accentSoft = THEME.accentSoft,
		focus = THEME.focus,
		core = THEME.text:Lerp(THEME.accent, 0.18),
		coreGlow = THEME.accent:Lerp(THEME.text, 0.34),
		beamHot = THEME.accent:Lerp(THEME.text, 0.62),
		beamCool = THEME.accentSoft:Lerp(THEME.accent, 0.45),
		ringA = THEME.accent:Lerp(THEME.border, 0.28),
		ringB = THEME.accent:Lerp(THEME.focus, 0.18),
		dustA = THEME.accent:Lerp(THEME.text, 0.22),
		dustB = THEME.muted:Lerp(THEME.accent, 0.32),
	}

local intro = {}
intro.runtime = {}
intro.animatables = {}
intro.orbitalDots = {}
intro.beamTrails = {}
intro.coreSpokes = {}
intro.dustMotes = {}
intro.nebulaClouds = {}
intro.ringArcs = {}
intro.beamFragments = {}
intro.titleChars = {}

local function introClamp(value, minValue, maxValue)
	return math.max(minValue, math.min(maxValue, value))
end

local function introLerp(a, b, alpha)
	return a + ((b - a) * alpha)
end

local function introEaseOutQuad(alpha)
	alpha = introClamp(alpha, 0, 1)
	return 1 - ((1 - alpha) * (1 - alpha))
end

local function introPulse(speed, phase)
	return 0.5 + (math.sin((tick() * speed) + (phase or 0)) * 0.5)
end

local function createIntroCapsule(parent, width, height, color, zIndex)
	local capsule = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = color,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, width, 0, height),
		ZIndex = zIndex,
		Parent = parent,
	})
	addCorner(capsule, 999)
	return capsule
end

local function createIntroGlowOrb(parent, size, color, zIndex)
	return create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = color,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, size, 0, size),
		ZIndex = zIndex,
		Parent = parent,
	})
end

local function createIntroGradientCapsule(parent, width, height, colorA, colorB, transparencyKeys, rotation, zIndex)
	local capsule = createIntroCapsule(parent, width, height, colorA, zIndex)
	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, colorA),
			ColorSequenceKeypoint.new(0.5, colorB),
			ColorSequenceKeypoint.new(1, colorA),
		}),
		Transparency = NumberSequence.new(transparencyKeys),
		Rotation = rotation or 0,
		Parent = capsule,
	})
	return capsule
end

local function createIntroDot(parent, size, color, zIndex)
	local dot = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = color,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, size, 0, size),
		ZIndex = zIndex,
		Parent = parent,
	})
	addCorner(dot, 999)
	return dot
end

local function createIntroCrossStar(parent, size, color, zIndex)
	local main = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = color,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, size, 0, 2),
		ZIndex = zIndex,
		Parent = parent,
	})
	addCorner(main, 999)
	local cross = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = color,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 2, 0, size),
		ZIndex = zIndex,
		Parent = main,
	})
	addCorner(cross, 999)
	return {
		main = main,
		cross = cross,
		size = size,
	}
end

local function setIntroPairTransparency(pair, value)
	if not pair then
		return
	end
	if pair.main then
		pair.main.BackgroundTransparency = value
	end
	if pair.cross then
		pair.cross.BackgroundTransparency = value
	end
end

local function setIntroLabelGradient(label, colorA, colorB, offset)
	local gradient = create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, colorA),
			ColorSequenceKeypoint.new(0.55, colorB),
			ColorSequenceKeypoint.new(1, colorA),
		}),
		Offset = offset or Vector2.new(0, 0),
		Rotation = 0,
		Parent = label,
	})
	return gradient
end

intro.overlay = create("Frame", {
	BackgroundColor3 = palette.bg0,
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 20,
	Parent = gui,
})

intro.backdrop = create("Frame", {
	BackgroundColor3 = palette.bg1,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 21,
	Parent = intro.overlay,
})
create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, palette.bg0),
		ColorSequenceKeypoint.new(0.38, palette.bg1),
		ColorSequenceKeypoint.new(0.7, palette.bg2),
		ColorSequenceKeypoint.new(1, palette.bg0),
	}),
	Rotation = 0,
	Parent = intro.backdrop,
})

intro.flashWash = create("Frame", {
	BackgroundColor3 = palette.core,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 29,
	Parent = intro.overlay,
})

intro.topLetterbox = create("Frame", {
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, 0, 0, 86),
	ZIndex = 28,
	Parent = intro.overlay,
})

intro.bottomLetterbox = create("Frame", {
	AnchorPoint = Vector2.new(0, 1),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 1, 0),
	Size = UDim2.new(1, 0, 0, 86),
	ZIndex = 28,
	Parent = intro.overlay,
})

intro.vignette = create("ImageLabel", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Image = "rbxassetid://5028857084",
	ImageColor3 = palette.bg0:Lerp(palette.accentSoft, 0.12),
	ImageTransparency = 0.18,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	ScaleType = Enum.ScaleType.Stretch,
	Size = UDim2.new(1.2, 0, 1.2, 0),
	ZIndex = 22,
	Parent = intro.overlay,
})

intro.nebulaLayer = create("Frame", {
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 21,
	Parent = intro.overlay,
})

for _, cloudInfo in ipairs({
	{ pos = UDim2.new(0.28, 0, 0.38, 0), size = 420, color = palette.accentSoft:Lerp(palette.accent, 0.35), alpha = 0.88 },
	{ pos = UDim2.new(0.72, 0, 0.36, 0), size = 510, color = palette.accent:Lerp(palette.text, 0.12), alpha = 0.9 },
	{ pos = UDim2.new(0.52, 0, 0.58, 0), size = 640, color = palette.panelAlt:Lerp(palette.accent, 0.34), alpha = 0.88 },
	{ pos = UDim2.new(0.18, 0, 0.68, 0), size = 340, color = palette.panel:Lerp(palette.accentSoft, 0.42), alpha = 0.92 },
	{ pos = UDim2.new(0.82, 0, 0.66, 0), size = 360, color = palette.border:Lerp(palette.accentSoft, 0.4), alpha = 0.92 },
}) do
	local cloud = createIntroGlowOrb(intro.nebulaLayer, cloudInfo.size, cloudInfo.color, 21)
	addCorner(cloud, 999)
	cloud.Position = cloudInfo.pos
	cloud.BackgroundTransparency = cloudInfo.alpha
	table.insert(intro.nebulaClouds, {
		frame = cloud,
		home = cloudInfo.pos,
		size = cloudInfo.size,
		alpha = cloudInfo.alpha,
	})
end

intro.coreGlow = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = palette.core,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 120, 0, 120),
	ZIndex = 24,
	Parent = intro.overlay,
})
addCorner(intro.coreGlow, 999)

intro.auraGlow = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = palette.coreGlow,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 320, 0, 320),
	ZIndex = 22,
	Parent = intro.overlay,
})
addCorner(intro.auraGlow, 999)

intro.haloInner = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 180, 0, 180),
	ZIndex = 24,
	Parent = intro.overlay,
})
addCorner(intro.haloInner, 999)
addStroke(intro.haloInner, palette.ringB, 1, 2)

intro.haloOuter = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 260, 0, 260),
	ZIndex = 23,
	Parent = intro.overlay,
})
addCorner(intro.haloOuter, 999)
addStroke(intro.haloOuter, palette.ringA, 1, 1)

intro.haloGlyph = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 560, 0, 560),
	ZIndex = 24,
	Parent = intro.overlay,
})

intro.haloMid = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 340, 0, 340),
	ZIndex = 23,
	Parent = intro.overlay,
})
addCorner(intro.haloMid, 999)
addStroke(intro.haloMid, palette.border:Lerp(palette.accent, 0.44), 1, 1)

intro.hudFrame = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = palette.panelAlt,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 10),
	Size = UDim2.new(0, 760, 0, 232),
	ZIndex = 23,
	Parent = intro.overlay,
})
addCorner(intro.hudFrame, 14)
addStroke(intro.hudFrame, palette.border, 1, 1)
create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, palette.panelAlt),
		ColorSequenceKeypoint.new(0.5, palette.panel),
		ColorSequenceKeypoint.new(1, palette.panelAlt),
	}),
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.16),
		NumberSequenceKeypoint.new(0.5, 0.34),
		NumberSequenceKeypoint.new(1, 0.16),
	}),
	Rotation = 0,
	Parent = intro.hudFrame,
})

intro.windowShell = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = palette.panel,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 8),
	Size = UDim2.new(0, 620, 0, 196),
	ZIndex = 24,
	Parent = intro.overlay,
})
addCorner(intro.windowShell, 12)
addStroke(intro.windowShell, palette.border, 1, 1)
create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, palette.header),
		ColorSequenceKeypoint.new(0.24, palette.panel),
		ColorSequenceKeypoint.new(1, palette.panelAlt),
	}),
	Rotation = 90,
	Parent = intro.windowShell,
})

intro.windowTopBar = create("Frame", {
	BackgroundColor3 = palette.header,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 0, 44),
	ZIndex = 25,
	Parent = intro.windowShell,
})
addCorner(intro.windowTopBar, 12)

intro.windowTopLine = create("Frame", {
	BackgroundColor3 = palette.accent,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, 0, 0, 3),
	ZIndex = 26,
	Parent = intro.windowTopBar,
})

intro.windowTitle = makeLabel(intro.windowTopBar, CONFIG.panelTitle, 16, palette.text, Enum.Font.GothamBlack)
intro.windowTitle.Position = UDim2.new(0, 14, 0, 7)
intro.windowTitle.Size = UDim2.new(0, 180, 0, 18)
intro.windowTitle.TextTransparency = 1
intro.windowTitle.ZIndex = 26

intro.windowSub = makeLabel(intro.windowTopBar, "TACTICAL ESP SUITE", 8, palette.accent, Enum.Font.GothamBold)
intro.windowSub.Position = UDim2.new(0, 15, 0, 24)
intro.windowSub.Size = UDim2.new(0, 180, 0, 12)
intro.windowSub.TextTransparency = 1
intro.windowSub.ZIndex = 26

intro.windowBadge = create("TextLabel", {
	AnchorPoint = Vector2.new(1, 0),
	BackgroundColor3 = palette.accentSoft,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(1, -14, 0, 11),
	Size = UDim2.new(0, 64, 0, 18),
	Font = Enum.Font.GothamBold,
	Text = "LIVE",
	TextColor3 = palette.text,
	TextSize = 8,
	ZIndex = 26,
	Parent = intro.windowTopBar,
})
addCorner(intro.windowBadge, 999)

intro.windowBodyDivider = create("Frame", {
	BackgroundColor3 = palette.border,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 14, 0, 52),
	Size = UDim2.new(1, -28, 0, 1),
	ZIndex = 25,
	Parent = intro.windowShell,
})

intro.windowBodyChip = create("TextLabel", {
	BackgroundColor3 = palette.accentSoft,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -16, 0, 66),
	Size = UDim2.new(0, 112, 0, 18),
	Font = Enum.Font.GothamBold,
	Text = "SYSTEM ONLINE",
	TextColor3 = palette.text,
	TextSize = 8,
	ZIndex = 26,
	Parent = intro.windowShell,
})
addCorner(intro.windowBodyChip, 999)

intro.hudSweep = create("Frame", {
	AnchorPoint = Vector2.new(0, 0.5),
	BackgroundColor3 = palette.beamHot,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0, -220, 0.5, 0),
	Size = UDim2.new(0, 220, 0, 2),
	ZIndex = 24,
	Parent = intro.hudFrame,
})
addCorner(intro.hudSweep, 999)
create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, palette.beamCool),
		ColorSequenceKeypoint.new(0.5, palette.beamHot),
		ColorSequenceKeypoint.new(1, palette.beamCool),
	}),
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.22, 0.7),
		NumberSequenceKeypoint.new(0.5, 0.08),
		NumberSequenceKeypoint.new(0.78, 0.7),
		NumberSequenceKeypoint.new(1, 1),
	}),
	Rotation = 0,
	Parent = intro.hudSweep,
})

intro.spokeLayer = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 440, 0, 440),
	ZIndex = 24,
	Parent = intro.overlay,
})

for index = 1, 14 do
	local spoke = createIntroGradientCapsule(
		intro.spokeLayer,
		132 + ((index % 3) * 28),
		2 + (index % 2),
		palette.beamCool,
		palette.beamHot,
		{
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.35, 0.84),
			NumberSequenceKeypoint.new(0.5, 0.16),
			NumberSequenceKeypoint.new(0.65, 0.84),
			NumberSequenceKeypoint.new(1, 1),
		},
		0,
		24
	)
	spoke.Rotation = ((index - 1) / 14) * 180
	table.insert(intro.coreSpokes, {
		frame = spoke,
		baseRotation = spoke.Rotation,
		baseSize = spoke.Size,
		alpha = 0.62 + ((index % 4) * 0.06),
	})
end

intro.ringArcLayer = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 700, 0, 700),
	ZIndex = 23,
	Parent = intro.overlay,
})

for _, arcInfo in ipairs({
	{ count = 12, radius = 252, width = 44, color = palette.ringA, thickness = 2 },
	{ count = 10, radius = 184, width = 28, color = palette.ringB, thickness = 2 },
}) do
	for index = 1, arcInfo.count do
		local angle = ((index - 1) / arcInfo.count) * 360
		local radians = math.rad(angle)
		local x = math.cos(radians) * arcInfo.radius
		local y = math.sin(radians) * arcInfo.radius
		local arc = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = arcInfo.color,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, x, 0.5, y),
			Rotation = angle + 90,
			Size = UDim2.new(0, arcInfo.width, 0, arcInfo.thickness),
			ZIndex = 23,
			Parent = intro.ringArcLayer,
		})
		addCorner(arc, 999)
		table.insert(intro.ringArcs, {
			frame = arc,
			angle = angle,
			radius = arcInfo.radius,
			width = arcInfo.width,
		})
	end
end

intro.orbitLayer = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 760, 0, 760),
	ZIndex = 24,
	Parent = intro.overlay,
})

for index = 1, 28 do
	local dot = createIntroDot(intro.orbitLayer, (index % 4 == 0) and 8 or 5, (index % 3 == 0) and palette.beamHot or palette.accent, 24)
	table.insert(intro.orbitalDots, {
		frame = dot,
		radius = 210 + ((index % 3) * 46),
		angle = ((index - 1) / 28) * 360,
		speed = 9 + (index % 5),
		alpha = 0.2 + ((index % 5) * 0.08),
	})
end

intro.crossVertical = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = palette.beamHot,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 4, 0, 460),
	ZIndex = 22,
	Parent = intro.overlay,
})
addCorner(intro.crossVertical, 999)
create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, palette.beamCool),
		ColorSequenceKeypoint.new(0.5, palette.beamHot),
		ColorSequenceKeypoint.new(1, palette.beamCool),
	}),
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.22, 0.82),
		NumberSequenceKeypoint.new(0.5, 0.18),
		NumberSequenceKeypoint.new(0.78, 0.82),
		NumberSequenceKeypoint.new(1, 1),
	}),
	Rotation = 90,
	Parent = intro.crossVertical,
})

intro.crossHorizontal = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = palette.beamHot,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 620, 0, 4),
	ZIndex = 22,
	Parent = intro.overlay,
})
addCorner(intro.crossHorizontal, 999)
create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, palette.beamCool),
		ColorSequenceKeypoint.new(0.5, palette.beamHot),
		ColorSequenceKeypoint.new(1, palette.beamCool),
	}),
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.18, 0.86),
		NumberSequenceKeypoint.new(0.5, 0.2),
		NumberSequenceKeypoint.new(0.82, 0.86),
		NumberSequenceKeypoint.new(1, 1),
	}),
	Rotation = 0,
	Parent = intro.crossHorizontal,
})

intro.diagA = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = palette.beamHot,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Rotation = 38,
	Size = UDim2.new(0, 1100, 0, 10),
	ZIndex = 23,
	Parent = intro.overlay,
})
addCorner(intro.diagA, 999)
create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, palette.beamCool),
		ColorSequenceKeypoint.new(0.5, palette.beamHot),
		ColorSequenceKeypoint.new(1, palette.beamCool),
	}),
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0.8),
		NumberSequenceKeypoint.new(0.5, 0.1),
		NumberSequenceKeypoint.new(0.8, 0.8),
		NumberSequenceKeypoint.new(1, 1),
	}),
	Parent = intro.diagA,
})

intro.diagB = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = palette.accent,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Rotation = -27,
	Size = UDim2.new(0, 1180, 0, 12),
	ZIndex = 22,
	Parent = intro.overlay,
})
addCorner(intro.diagB, 999)
create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, palette.accent),
		ColorSequenceKeypoint.new(0.5, palette.beamHot),
		ColorSequenceKeypoint.new(1, palette.accent),
	}),
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.18, 0.86),
		NumberSequenceKeypoint.new(0.5, 0.22),
		NumberSequenceKeypoint.new(0.82, 0.86),
		NumberSequenceKeypoint.new(1, 1),
	}),
	Parent = intro.diagB,
})

intro.beamAuraA = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = palette.beamHot,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Rotation = 40,
	Size = UDim2.new(0, 1320, 0, 84),
	ZIndex = 22,
	Parent = intro.overlay,
})
addCorner(intro.beamAuraA, 999)
create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, palette.beamCool),
		ColorSequenceKeypoint.new(0.5, palette.beamHot),
		ColorSequenceKeypoint.new(1, palette.beamCool),
	}),
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.18, 0.92),
		NumberSequenceKeypoint.new(0.5, 0.48),
		NumberSequenceKeypoint.new(0.82, 0.92),
		NumberSequenceKeypoint.new(1, 1),
	}),
	Parent = intro.beamAuraA,
})

intro.beamAuraB = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = palette.beamCool,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Rotation = -24,
	Size = UDim2.new(0, 1380, 0, 92),
	ZIndex = 21,
	Parent = intro.overlay,
})
addCorner(intro.beamAuraB, 999)
create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, palette.beamCool),
		ColorSequenceKeypoint.new(0.5, palette.accent),
		ColorSequenceKeypoint.new(1, palette.beamCool),
	}),
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.16, 0.94),
		NumberSequenceKeypoint.new(0.5, 0.52),
		NumberSequenceKeypoint.new(0.84, 0.94),
		NumberSequenceKeypoint.new(1, 1),
	}),
	Parent = intro.beamAuraB,
})

intro.beamTrailLayer = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 1600, 0, 900),
	ZIndex = 22,
	Parent = intro.overlay,
})

for _, trailInfo in ipairs({
	{ rotation = 38, width = 1180, height = 26, colorA = palette.beamHot, colorB = palette.text, alpha = 0.72 },
	{ rotation = 40, width = 1120, height = 12, colorA = palette.beamCool, colorB = palette.beamHot, alpha = 0.42 },
	{ rotation = -24, width = 1260, height = 32, colorA = palette.accent, colorB = palette.beamHot, alpha = 0.76 },
	{ rotation = -27, width = 1140, height = 14, colorA = palette.ringB, colorB = palette.text, alpha = 0.5 },
}) do
	local trail = createIntroGradientCapsule(
		intro.beamTrailLayer,
		trailInfo.width,
		trailInfo.height,
		trailInfo.colorA,
		trailInfo.colorB,
		{
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.16, 0.94),
			NumberSequenceKeypoint.new(0.5, trailInfo.alpha),
			NumberSequenceKeypoint.new(0.84, 0.94),
			NumberSequenceKeypoint.new(1, 1),
		},
		0,
		22
	)
	trail.Rotation = trailInfo.rotation
	table.insert(intro.beamTrails, {
		frame = trail,
		baseRotation = trailInfo.rotation,
		baseSize = trail.Size,
		alpha = trailInfo.alpha,
	})
end

for _, fragmentInfo in ipairs({
	{ angle = 18, distance = 180, length = 142, color = palette.beamHot, thickness = 2 },
	{ angle = 84, distance = 166, length = 106, color = palette.ringB, thickness = 2 },
	{ angle = 122, distance = 132, length = 78, color = palette.text, thickness = 1 },
	{ angle = 198, distance = 136, length = 88, color = palette.border, thickness = 1 },
	{ angle = 266, distance = 154, length = 126, color = palette.accent, thickness = 2 },
	{ angle = 332, distance = 128, length = 96, color = palette.text, thickness = 1 },
	{ angle = 354, distance = 198, length = 112, color = palette.beamCool, thickness = 1 },
	{ angle = 48, distance = 122, length = 86, color = palette.beamHot, thickness = 1 },
	{ angle = 146, distance = 168, length = 94, color = palette.accent, thickness = 1 },
	{ angle = 288, distance = 134, length = 92, color = palette.border, thickness = 1 },
}) do
	local radians = math.rad(fragmentInfo.angle)
	local x = math.cos(radians) * fragmentInfo.distance
	local y = math.sin(radians) * fragmentInfo.distance
	local fragment = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = fragmentInfo.color,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, x, 0.5, y),
		Rotation = fragmentInfo.angle,
		Size = UDim2.new(0, fragmentInfo.length, 0, fragmentInfo.thickness),
		ZIndex = 24,
		Parent = intro.overlay,
	})
	addCorner(fragment, 999)
	table.insert(intro.beamFragments, {
		frame = fragment,
		angle = fragmentInfo.angle,
		distance = fragmentInfo.distance,
		home = UDim2.new(0.5, x, 0.5, y),
		alpha = 0.24,
	})
end

intro.sound = create("Sound", {
	Name = "IntroHit",
	SoundId = "rbxassetid://1839701476",
	Volume = 2.2,
	PlaybackSpeed = 1,
	RollOffMaxDistance = 100,
	Parent = gui,
})

intro.kicker = makeLabel(intro.overlay, "Adaptive overlays and combat info", 10, palette.muted, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
intro.kicker.AnchorPoint = Vector2.new(0.5, 0)
intro.kicker.Position = UDim2.new(0.5, 0, 0.5, -54)
intro.kicker.Size = UDim2.new(0, 420, 0, 16)
intro.kicker.TextTransparency = 1
intro.kicker.ZIndex = 27

intro.titleShadow = makeLabel(intro.overlay, CONFIG.panelTitle, 42, palette.accentSoft:Lerp(palette.accent, 0.35), Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
intro.titleShadow.AnchorPoint = Vector2.new(0.5, 0.5)
intro.titleShadow.Position = UDim2.new(0.5, 3, 0.5, -4)
intro.titleShadow.Size = UDim2.new(0, 760, 0, 60)
intro.titleShadow.TextTransparency = 1
intro.titleShadow.ZIndex = 27

intro.title = makeLabel(intro.overlay, CONFIG.panelTitle, 42, palette.text, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
intro.title.AnchorPoint = Vector2.new(0.5, 0.5)
intro.title.Position = UDim2.new(0.5, 0, 0.5, -6)
intro.title.Size = UDim2.new(0, 760, 0, 60)
intro.title.TextTransparency = 1
intro.title.ZIndex = 28
intro.title.TextStrokeColor3 = palette.border:Lerp(palette.accent, 0.44)
intro.title.TextStrokeTransparency = 0.72
intro.titleGradient = setIntroLabelGradient(intro.title, palette.text, palette.beamHot, Vector2.new(-1, 0))
intro.titleShadowGradient = setIntroLabelGradient(intro.titleShadow, palette.accentSoft, palette.accent, Vector2.new(1, 0))

intro.sub = makeLabel(intro.overlay, string.format("v%s  |  %s", CONFIG.version, CONFIG.panelSubtitle:gsub("^%s+", "")), 18, palette.accent, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
intro.sub.AnchorPoint = Vector2.new(0.5, 0.5)
intro.sub.Position = UDim2.new(0.5, 0, 0.5, 36)
intro.sub.Size = UDim2.new(0, 520, 0, 28)
intro.sub.TextTransparency = 1
intro.sub.ZIndex = 28
intro.sub.TextStrokeColor3 = palette.accentSoft
intro.sub.TextStrokeTransparency = 0.6
intro.subGradient = setIntroLabelGradient(intro.sub, palette.accent, palette.beamHot, Vector2.new(-1, 0))

intro.titleGlintLayer = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 2),
	Size = UDim2.new(0, 820, 0, 96),
	ZIndex = 29,
	Parent = intro.overlay,
})

for _, glintInfo in ipairs({
	{ width = 210, height = 3, angle = -12, x = -282, y = -8, color = palette.text },
	{ width = 160, height = 2, angle = 8, x = 204, y = 26, color = palette.accent },
	{ width = 132, height = 2, angle = -18, x = 18, y = 42, color = palette.beamHot },
	{ width = 104, height = 2, angle = 14, x = -96, y = -28, color = palette.ringB },
}) do
	local glint = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = glintInfo.color,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, glintInfo.x, 0.5, glintInfo.y),
		Rotation = glintInfo.angle,
		Size = UDim2.new(0, glintInfo.width, 0, glintInfo.height),
		ZIndex = 27,
		Parent = intro.titleGlintLayer,
	})
	addCorner(glint, 999)
	table.insert(intro.titleChars, {
		frame = glint,
		home = glint.Position,
		alpha = 0.22,
	})
end

intro.leftLine = create("Frame", {
	AnchorPoint = Vector2.new(1, 0.5),
	BackgroundColor3 = palette.beamHot,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.36, 0, 0.5, 36),
	Size = UDim2.new(0, 0, 0, 3),
	ZIndex = 25,
	Parent = intro.overlay,
})
addCorner(intro.leftLine, 999)

intro.rightLine = create("Frame", {
	BackgroundColor3 = palette.beamHot,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.64, 0, 0.5, 36),
	Size = UDim2.new(0, 0, 0, 3),
	ZIndex = 25,
	Parent = intro.overlay,
})
addCorner(intro.rightLine, 999)

intro.sideAccentStars = {}
for _, accentInfo in ipairs({
	{ pos = UDim2.new(0.34, 0, 0.5, 36), color = palette.accent, size = 20 },
	{ pos = UDim2.new(0.66, 0, 0.5, 36), color = palette.accent, size = 20 },
}) do
	local main = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = accentInfo.color,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = accentInfo.pos,
		Size = UDim2.new(0, accentInfo.size, 0, 2),
		ZIndex = 26,
		Parent = intro.overlay,
	})
	addCorner(main, 999)
	local cross = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = accentInfo.color,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 2, 0, accentInfo.size),
		Parent = main,
	})
	addCorner(cross, 999)
	table.insert(intro.sideAccentStars, {
		main = main,
		cross = cross,
		size = accentInfo.size,
	})
end

intro.radialStreaks = {}
for _, streakInfo in ipairs({
	{ rotation = -68, distance = 424, length = 172, thickness = 2, color = palette.accent, alpha = 0.78 },
	{ rotation = -54, distance = 414, length = 118, thickness = 2, color = palette.ringA, alpha = 0.82 },
	{ rotation = -39, distance = 432, length = 146, thickness = 1, color = palette.beamHot, alpha = 0.84 },
	{ rotation = -18, distance = 426, length = 134, thickness = 1, color = palette.ringB, alpha = 0.86 },
	{ rotation = 16, distance = 432, length = 152, thickness = 1, color = palette.accent, alpha = 0.84 },
	{ rotation = 34, distance = 414, length = 126, thickness = 2, color = palette.border, alpha = 0.84 },
	{ rotation = 58, distance = 420, length = 172, thickness = 2, color = palette.accent, alpha = 0.8 },
	{ rotation = 73, distance = 434, length = 118, thickness = 1, color = palette.beamHot, alpha = 0.86 },
	{ rotation = 112, distance = 438, length = 142, thickness = 1, color = palette.accent, alpha = 0.84 },
	{ rotation = 138, distance = 420, length = 118, thickness = 1, color = palette.ringA, alpha = 0.86 },
	{ rotation = 156, distance = 410, length = 162, thickness = 2, color = palette.accent, alpha = 0.82 },
	{ rotation = 198, distance = 430, length = 134, thickness = 1, color = palette.border, alpha = 0.84 },
	{ rotation = 224, distance = 424, length = 148, thickness = 1, color = palette.beamHot, alpha = 0.84 },
	{ rotation = 248, distance = 416, length = 168, thickness = 2, color = palette.accent, alpha = 0.8 },
	{ rotation = 286, distance = 434, length = 128, thickness = 1, color = palette.ringA, alpha = 0.84 },
	{ rotation = 314, distance = 426, length = 162, thickness = 2, color = palette.accent, alpha = 0.8 },
}) do
	local radians = math.rad(streakInfo.rotation)
	local x = math.cos(radians) * streakInfo.distance
	local y = math.sin(radians) * streakInfo.distance
	local streak = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = streakInfo.color,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, x, 0.5, y),
		Rotation = streakInfo.rotation,
		Size = UDim2.new(0, streakInfo.length, 0, streakInfo.thickness),
		ZIndex = 22,
		Parent = intro.overlay,
	})
	addCorner(streak, 999)
	table.insert(intro.radialStreaks, {
		frame = streak,
		home = UDim2.new(0.5, x, 0.5, y),
		size = streakInfo.length,
		alpha = streakInfo.alpha,
	})
end

intro.sparkles = {}
for _, info in ipairs({
	{ pos = UDim2.new(0.08, 0, 0.52, 0), size = 22, color = palette.accent },
	{ pos = UDim2.new(0.19, 0, 0.42, 0), size = 10, color = palette.text },
	{ pos = UDim2.new(0.30, 0, 0.37, 0), size = 8, color = palette.beamHot },
	{ pos = UDim2.new(0.42, 0, 0.56, 0), size = 12, color = palette.text },
	{ pos = UDim2.new(0.53, 0, 0.31, 0), size = 10, color = palette.accent },
	{ pos = UDim2.new(0.70, 0, 0.38, 0), size = 10, color = palette.beamHot },
	{ pos = UDim2.new(0.86, 0, 0.51, 0), size = 24, color = palette.accent },
	{ pos = UDim2.new(0.78, 0, 0.42, 0), size = 8, color = palette.text },
	{ pos = UDim2.new(0.60, 0, 0.79, 0), size = 8, color = palette.ringA },
	{ pos = UDim2.new(0.25, 0, 0.80, 0), size = 7, color = palette.ringA },
	{ pos = UDim2.new(0.73, 0, 0.24, 0), size = 7, color = palette.beamHot },
	{ pos = UDim2.new(0.39, 0, 0.18, 0), size = 7, color = palette.beamHot },
}) do
	local sparkle = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = info.color,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = info.pos,
		Size = UDim2.new(0, info.size, 0, 2),
		Rotation = 0,
		ZIndex = 24,
		Parent = intro.overlay,
	})
	addCorner(sparkle, 999)
	local sparkleCross = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = info.color,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 2, 0, info.size),
		Parent = sparkle,
	})
	addCorner(sparkleCross, 999)
	table.insert(intro.sparkles, {
		main = sparkle,
		cross = sparkleCross,
		size = info.size,
		home = info.pos,
	})
end

intro.dustLayer = create("Frame", {
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 23,
	Parent = intro.overlay,
})

for index = 1, 42 do
	local color = (index % 4 == 0) and palette.dustA
		or ((index % 3 == 0) and palette.accent or palette.dustB)
	local size = ((index % 5) == 0) and 7 or (((index % 3) == 0) and 5 or 3)
	local pos = UDim2.new(math.random(4, 96) / 100, 0, math.random(10, 92) / 100, 0)
	local dot = createIntroDot(intro.dustLayer, size, color, 23)
	dot.Position = pos
	table.insert(intro.dustMotes, {
		frame = dot,
		home = pos,
		alpha = 0.18 + ((index % 6) * 0.08),
		speed = 0.4 + ((index % 7) * 0.12),
	})
end

intro.glyphStars = {}
for index = 1, 22 do
	local angle = math.rad(((index - 1) / 22) * 360)
	local radius = 188
	local x = math.cos(angle) * radius
	local y = math.sin(angle) * radius
	local size = (index % 4 == 0) and 14 or 10
	local star = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = palette.ringB,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, x, 0.5, y),
		Size = UDim2.new(0, size, 0, 2),
		Rotation = math.deg(angle),
		ZIndex = 24,
		Parent = intro.haloGlyph,
	})
	addCorner(star, 999)
	local cross = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = palette.ringB,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 2, 0, size),
		Parent = star,
	})
	addCorner(cross, 999)
	table.insert(intro.glyphStars, {
		main = star,
		cross = cross,
		size = size,
	})
end


local function play(onComplete)
	pcall(function()
		intro.sound.TimePosition = 0
		intro.sound:Play()
	end)

	if intro.runtimeConnection then
		intro.runtimeConnection:Disconnect()
		intro.runtimeConnection = nil
	end

	intro.active = true
	intro.overlay.BackgroundTransparency = 0
	intro.backdrop.BackgroundTransparency = 0
	intro.flashWash.BackgroundTransparency = 1
	intro.topLetterbox.Size = UDim2.new(1, 0, 0, 34)
	intro.bottomLetterbox.Size = UDim2.new(1, 0, 0, 34)
	intro.vignette.ImageTransparency = 0.12
	intro.hudFrame.BackgroundTransparency = 1
	intro.hudFrame.Size = UDim2.new(0, 700, 0, 212)
	local hudFrameStroke = intro.hudFrame:FindFirstChildOfClass("UIStroke")
	if hudFrameStroke then
		hudFrameStroke.Transparency = 1
	end
	intro.windowShell.BackgroundTransparency = 1
	intro.windowShell.Size = UDim2.new(0, 580, 0, 176)
	local windowShellStroke = intro.windowShell:FindFirstChildOfClass("UIStroke")
	if windowShellStroke then
		windowShellStroke.Transparency = 1
	end
	intro.windowTopBar.BackgroundTransparency = 1
	intro.windowTopLine.BackgroundTransparency = 1
	intro.windowTitle.TextTransparency = 1
	intro.windowSub.TextTransparency = 1
	intro.windowBadge.BackgroundTransparency = 1
	intro.windowBodyDivider.BackgroundTransparency = 1
	intro.windowBodyChip.BackgroundTransparency = 1
	intro.hudSweep.BackgroundTransparency = 1
	intro.hudSweep.Position = UDim2.new(0, -220, 0.5, 0)
	intro.coreGlow.BackgroundTransparency = 1
	intro.coreGlow.Size = UDim2.new(0, 84, 0, 84)
	intro.auraGlow.BackgroundTransparency = 1
	intro.auraGlow.Size = UDim2.new(0, 220, 0, 220)
	intro.haloInner.Size = UDim2.new(0, 140, 0, 140)
	intro.haloMid.Size = UDim2.new(0, 240, 0, 240)
	intro.haloOuter.Size = UDim2.new(0, 220, 0, 220)
	intro.haloGlyph.Size = UDim2.new(0, 460, 0, 460)
	intro.orbitLayer.Rotation = 0
	intro.ringArcLayer.Rotation = 0
	intro.spokeLayer.Rotation = 0
	intro.crossHorizontal.BackgroundTransparency = 1
	intro.crossHorizontal.Size = UDim2.new(0, 280, 0, 4)
	intro.crossVertical.BackgroundTransparency = 1
	intro.crossVertical.Size = UDim2.new(0, 4, 0, 170)
	intro.diagA.BackgroundTransparency = 1
	intro.diagA.Rotation = 35
	intro.diagB.BackgroundTransparency = 1
	intro.diagB.Rotation = -31
	intro.beamAuraA.BackgroundTransparency = 1
	intro.beamAuraA.Rotation = 40
	intro.beamAuraB.BackgroundTransparency = 1
	intro.beamAuraB.Rotation = -24
	intro.kicker.TextTransparency = 1
	intro.title.TextTransparency = 1
	intro.title.TextStrokeTransparency = 0.72
	intro.titleShadow.TextTransparency = 1
	if intro.titleGradient then
		intro.titleGradient.Offset = Vector2.new(-1, 0)
	end
	if intro.titleShadowGradient then
		intro.titleShadowGradient.Offset = Vector2.new(1, 0)
	end
	intro.title.Position = UDim2.new(0.5, 0, 0.5, 8)
	intro.titleShadow.Position = UDim2.new(0.5, 10, 0.5, 12)
	intro.sub.TextTransparency = 1
	intro.sub.TextStrokeTransparency = 0.6
	if intro.subGradient then
		intro.subGradient.Offset = Vector2.new(-1, 0)
	end
	intro.leftLine.BackgroundTransparency = 1
	intro.leftLine.Size = UDim2.new(0, 0, 0, 3)
	intro.rightLine.BackgroundTransparency = 1
	intro.rightLine.Size = UDim2.new(0, 0, 0, 3)
	for _, accentStar in ipairs(intro.sideAccentStars or {}) do
		accentStar.main.BackgroundTransparency = 1
		accentStar.cross.BackgroundTransparency = 1
	end
	for _, cloud in ipairs(intro.nebulaClouds or {}) do
		cloud.frame.BackgroundTransparency = 1
		cloud.frame.Position = cloud.home
	end
	for _, dot in ipairs(intro.orbitalDots or {}) do
		dot.frame.BackgroundTransparency = 1
	end
	for _, spoke in ipairs(intro.coreSpokes or {}) do
		spoke.frame.BackgroundTransparency = 1
		spoke.frame.Size = spoke.baseSize
		spoke.frame.Rotation = spoke.baseRotation
	end
	for _, arc in ipairs(intro.ringArcs or {}) do
		arc.frame.BackgroundTransparency = 1
	end
	for _, fragment in ipairs(intro.beamFragments or {}) do
		fragment.frame.BackgroundTransparency = 1
		fragment.frame.Position = fragment.home
	end
	for _, glint in ipairs(intro.titleChars or {}) do
		glint.frame.BackgroundTransparency = 1
		glint.frame.Position = glint.home
	end
	for _, dust in ipairs(intro.dustMotes or {}) do
		dust.frame.BackgroundTransparency = 1
		dust.frame.Position = dust.home
	end

	local haloInnerIn = TweenService:Create(intro.haloInner, TweenInfo.new(0.54, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 360, 0, 360),
	})
	local haloMidIn = TweenService:Create(intro.haloMid, TweenInfo.new(0.62, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 470, 0, 470),
	})
	local haloOuterIn = TweenService:Create(intro.haloOuter, TweenInfo.new(0.72, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 620, 0, 620),
	})
	local haloInnerStroke = intro.haloInner:FindFirstChildOfClass("UIStroke")
	if haloInnerStroke then
		haloInnerStroke.Transparency = 1
		TweenService:Create(haloInnerStroke, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 0.36,
		}):Play()
	end
	local haloOuterStroke = intro.haloOuter:FindFirstChildOfClass("UIStroke")
	if haloOuterStroke then
		haloOuterStroke.Transparency = 1
		TweenService:Create(haloOuterStroke, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 0.62,
		}):Play()
	end
	local haloMidStroke = intro.haloMid:FindFirstChildOfClass("UIStroke")
	if haloMidStroke then
		haloMidStroke.Transparency = 1
		TweenService:Create(haloMidStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 0.54,
		}):Play()
	end

	local coreIn = TweenService:Create(intro.coreGlow, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.08,
		Size = UDim2.new(0, 222, 0, 222),
	})
	local auraIn = TweenService:Create(intro.auraGlow, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.76,
		Size = UDim2.new(0, 720, 0, 720),
	})
	local windowShellIn = TweenService:Create(intro.windowShell, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.06,
		Size = UDim2.new(0, 620, 0, 196),
	})
	local hudFrameIn = TweenService:Create(intro.hudFrame, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.72,
		Size = UDim2.new(0, 760, 0, 232),
	})
	local hudSweepIn = TweenService:Create(intro.hudSweep, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.12,
	})
	local crossHorizontalIn = TweenService:Create(intro.crossHorizontal, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.18,
		Size = UDim2.new(0, 980, 0, 5),
	})
	local crossVerticalIn = TweenService:Create(intro.crossVertical, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.52,
		Size = UDim2.new(0, 4, 0, 690),
	})
	local diagAIn = TweenService:Create(intro.diagA, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.08,
		Rotation = 40,
	})
	local diagBIn = TweenService:Create(intro.diagB, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.18,
		Rotation = -24,
	})
	local beamAuraAIn = TweenService:Create(intro.beamAuraA, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.28,
	})
	local beamAuraBIn = TweenService:Create(intro.beamAuraB, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.36,
	})
	local titleShadowIn = TweenService:Create(intro.titleShadow, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0.4,
		Position = UDim2.new(0.5, 7, 0.5, -1),
	})
	local titleIn = TweenService:Create(intro.title, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0.5, -8),
	})
	local subIn = TweenService:Create(intro.sub, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0.5, 82),
	})
	local leftLineIn = TweenService:Create(intro.leftLine, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0,
		Size = UDim2.new(0, 344, 0, 3),
	})
	local rightLineIn = TweenService:Create(intro.rightLine, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0,
		Size = UDim2.new(0, 344, 0, 3),
	})

	for _, cloud in ipairs(intro.nebulaClouds or {}) do
		TweenService:Create(cloud.frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = cloud.alpha,
		}):Play()
	end
	coreIn:Play()
	auraIn:Play()
	windowShellIn:Play()
	hudFrameIn:Play()
	hudSweepIn:Play()
	crossHorizontalIn:Play()
	TweenService:Create(intro.windowTopBar, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0,
	}):Play()
	TweenService:Create(intro.windowTopLine, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0,
	}):Play()
	TweenService:Create(intro.windowTitle, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
	}):Play()
	TweenService:Create(intro.windowSub, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
	}):Play()
	TweenService:Create(intro.windowBadge, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0,
	}):Play()
	TweenService:Create(intro.windowBodyDivider, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.34,
	}):Play()
	TweenService:Create(intro.windowBodyChip, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0,
	}):Play()
	if hudFrameStroke then
		TweenService:Create(hudFrameStroke, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 0.7,
		}):Play()
	end
	if windowShellStroke then
		TweenService:Create(windowShellStroke, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 0.22,
		}):Play()
	end
	for index, streak in ipairs(intro.radialStreaks or {}) do
		if streak.frame and streak.frame.Parent then
			streak.frame.BackgroundTransparency = 1
			streak.frame.Position = UDim2.new(0.5, streak.home.X.Offset * 1.12, 0.5, streak.home.Y.Offset * 1.12)
			task.delay(0.01 + (index * 0.012), function()
				if intro.active and streak.frame and streak.frame.Parent then
					TweenService:Create(streak.frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundTransparency = streak.alpha,
						Position = streak.home,
					}):Play()
				end
			end)
		end
	end

	for index, sparkle in ipairs(intro.sparkles) do
		task.delay(0.05 + (index * 0.02), function()
			if intro.active and sparkle.main and sparkle.main.Parent then
				TweenService:Create(sparkle.main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 0.08,
				}):Play()
				TweenService:Create(sparkle.cross, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 0.08,
				}):Play()

				task.spawn(function()
					while intro.active and sparkle.main and sparkle.main.Parent do
						local pulse = 0.72 + (math.random() * 0.3)
						local widen = sparkle.size + math.random(4, 10)
						TweenService:Create(sparkle.main, TweenInfo.new(pulse, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
							BackgroundTransparency = 0.28,
							Size = UDim2.new(0, widen, 0, 2),
						}):Play()
						TweenService:Create(sparkle.cross, TweenInfo.new(pulse, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
							BackgroundTransparency = 0.28,
							Size = UDim2.new(0, 2, 0, widen),
						}):Play()
						task.wait(pulse)
						if not intro.active then
							break
						end
						TweenService:Create(sparkle.main, TweenInfo.new(0.52, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
							BackgroundTransparency = 0.08,
							Size = UDim2.new(0, sparkle.size, 0, 2),
						}):Play()
						TweenService:Create(sparkle.cross, TweenInfo.new(0.52, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
							BackgroundTransparency = 0.08,
							Size = UDim2.new(0, 2, 0, sparkle.size),
						}):Play()
						task.wait(0.35 + (math.random() * 0.45))
					end
				end)
			end
		end)
	end

	task.wait(0.12)
	crossVerticalIn:Play()

	task.wait(0.06)
	diagAIn:Play()
	diagBIn:Play()
	beamAuraAIn:Play()
	beamAuraBIn:Play()

	task.wait(0.08)
	haloInnerIn:Play()
	haloMidIn:Play()
	haloOuterIn:Play()
	TweenService:Create(intro.haloGlyph, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 580, 0, 580),
	}):Play()
	for _, arc in ipairs(intro.ringArcs or {}) do
		TweenService:Create(arc.frame, TweenInfo.new(0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.54,
		}):Play()
	end
	for _, spoke in ipairs(intro.coreSpokes or {}) do
		TweenService:Create(spoke.frame, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = spoke.alpha,
		}):Play()
	end
	for _, fragment in ipairs(intro.beamFragments or {}) do
		TweenService:Create(fragment.frame, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = fragment.alpha,
		}):Play()
	end
	for _, dot in ipairs(intro.orbitalDots or {}) do
		TweenService:Create(dot.frame, TweenInfo.new(0.36, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = dot.alpha,
		}):Play()
	end

	for index, glyphStar in ipairs(intro.glyphStars or {}) do
		task.delay(0.18 + (index * 0.018), function()
			if intro.active and glyphStar.main and glyphStar.main.Parent then
				TweenService:Create(glyphStar.main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 0.3,
				}):Play()
				TweenService:Create(glyphStar.cross, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 0.3,
				}):Play()
			end
		end)
	end

	local runtimeStart = tick()
	intro.runtimeConnection = RunService.RenderStepped:Connect(function()
		if not intro.active or not intro.overlay or not intro.overlay.Parent then
			return
		end

		local elapsed = tick() - runtimeStart
		local glowPulse = 0.5 + (math.sin(elapsed * 4.2) * 0.5)
		local beamPulse = 0.5 + (math.sin(elapsed * 2.4) * 0.5)
		local ringPulse = 0.5 + (math.cos(elapsed * 1.8) * 0.5)
		local orbitPulse = 0.5 + (math.sin(elapsed * 1.2) * 0.5)

		intro.backdrop.Rotation = math.sin(elapsed * 0.14) * 2
		intro.vignette.ImageTransparency = 0.06 + ((1 - glowPulse) * 0.08)
		intro.topLetterbox.Size = UDim2.new(1, 0, 0, 34 - math.floor(glowPulse * 2))
		intro.bottomLetterbox.Size = UDim2.new(1, 0, 0, 34 - math.floor(glowPulse * 2))

		intro.haloGlyph.Rotation = elapsed * 15
		intro.ringArcLayer.Rotation = elapsed * 11
		intro.orbitLayer.Rotation = -(elapsed * 7)
		intro.spokeLayer.Rotation = elapsed * 3.5
		intro.haloInner.Rotation = -(elapsed * 6)
		intro.haloMid.Rotation = elapsed * 5
		intro.haloOuter.Rotation = elapsed * 4

		intro.diagA.Rotation = 40 + (math.sin(elapsed * 1.55) * 4.5) + (elapsed * 1.4)
		intro.diagB.Rotation = -24 + (math.cos(elapsed * 1.35) * 4) - (elapsed * 1.2)
		intro.beamAuraA.Rotation = intro.diagA.Rotation
		intro.beamAuraB.Rotation = intro.diagB.Rotation
		if intro.titleGradient then
			intro.titleGradient.Offset = Vector2.new(-1 + ((elapsed * 0.4) % 2), 0)
		end
		if intro.titleShadowGradient then
			intro.titleShadowGradient.Offset = Vector2.new(1 - ((elapsed * 0.3) % 2), 0)
		end
		if intro.subGradient then
			intro.subGradient.Offset = Vector2.new(-1 + ((elapsed * 0.6) % 2), 0)
		end

		intro.coreGlow.Size = UDim2.new(0, 222 + math.floor(glowPulse * 38), 0, 222 + math.floor(glowPulse * 38))
		intro.auraGlow.Size = UDim2.new(0, 720 + math.floor(glowPulse * 90), 0, 720 + math.floor(glowPulse * 90))
		intro.coreGlow.BackgroundTransparency = 0.05 - (glowPulse * 0.04)
		intro.auraGlow.BackgroundTransparency = 0.72 - (glowPulse * 0.1)
		intro.windowShell.Size = UDim2.new(0, 620 + math.floor(ringPulse * 6), 0, 196 + math.floor(glowPulse * 4))
		intro.windowBadge.BackgroundTransparency = 0.04 - (beamPulse * 0.03)
		intro.windowBodyChip.BackgroundTransparency = 0.06 - (beamPulse * 0.04)
		if windowShellStroke then
			windowShellStroke.Transparency = 0.26 - (beamPulse * 0.08)
		end
		intro.hudFrame.Size = UDim2.new(0, 760 + math.floor(ringPulse * 10), 0, 232 + math.floor(glowPulse * 6))
		intro.hudFrame.BackgroundTransparency = 0.76 - (glowPulse * 0.04)
		intro.hudSweep.Position = UDim2.new(0, math.floor(((elapsed * 420) % 980) - 220), 0.5, math.floor(math.sin(elapsed * 2.2) * 24))
		intro.hudSweep.BackgroundTransparency = 0.14 - (beamPulse * 0.08)
		if hudFrameStroke then
			hudFrameStroke.Transparency = 0.72 - (beamPulse * 0.08)
		end
		intro.haloMid.Size = UDim2.new(0, 470 + math.floor(ringPulse * 14), 0, 470 + math.floor(ringPulse * 14))

		intro.crossHorizontal.Size = UDim2.new(0, 980 + math.floor(beamPulse * 90), 0, 5)
		intro.crossHorizontal.BackgroundTransparency = 0.18 - (beamPulse * 0.06)
		intro.crossVertical.Size = UDim2.new(0, 4, 0, 690 + math.floor(beamPulse * 36))
		intro.crossVertical.BackgroundTransparency = 0.52 - (beamPulse * 0.08)

		intro.beamAuraA.BackgroundTransparency = 0.28 - (beamPulse * 0.08)
		intro.beamAuraB.BackgroundTransparency = 0.36 - (beamPulse * 0.1)
		intro.haloInner.Size = UDim2.new(0, 360 + math.floor(ringPulse * 10), 0, 360 + math.floor(ringPulse * 10))
		intro.haloOuter.Size = UDim2.new(0, 620 + math.floor(ringPulse * 16), 0, 620 + math.floor(ringPulse * 16))
		for index, cloud in ipairs(intro.nebulaClouds or {}) do
			local swayX = math.sin((elapsed * 0.18) + index) * 12
			local swayY = math.cos((elapsed * 0.14) + (index * 0.6)) * 10
			cloud.frame.Position = UDim2.new(cloud.home.X.Scale, cloud.home.X.Offset + swayX, cloud.home.Y.Scale, cloud.home.Y.Offset + swayY)
			cloud.frame.Size = UDim2.new(0, cloud.size + math.floor(glowPulse * 32), 0, cloud.size + math.floor(glowPulse * 32))
			cloud.frame.BackgroundTransparency = cloud.alpha - (glowPulse * 0.05)
		end

		for index, streak in ipairs(intro.radialStreaks or {}) do
			if streak.frame and streak.frame.Parent then
				local drift = 1 + (math.sin((elapsed * 2.6) + index) * 0.035)
				streak.frame.Position = UDim2.new(0.5, math.floor(streak.home.X.Offset * drift), 0.5, math.floor(streak.home.Y.Offset * drift))
				streak.frame.BackgroundTransparency = math.clamp(streak.alpha - (beamPulse * 0.08), 0, 1)
			end
		end
		for index, trail in ipairs(intro.beamTrails or {}) do
			if trail.frame and trail.frame.Parent then
				local trailPulse = 0.5 + (math.sin((elapsed * 2.8) + index) * 0.5)
				trail.frame.Rotation = trail.baseRotation + (math.sin((elapsed * 0.9) + index) * 2.2)
				trail.frame.Size = UDim2.new(0, trail.baseSize.X.Offset + math.floor(trailPulse * 36), 0, trail.baseSize.Y.Offset + math.floor(trailPulse * 6))
				trail.frame.BackgroundTransparency = introClamp(trail.alpha - (trailPulse * 0.08), 0, 1)
			end
		end
		for index, fragment in ipairs(intro.beamFragments or {}) do
			if fragment.frame and fragment.frame.Parent then
				local sweep = math.sin((elapsed * 3.2) + index) * 12
				local radians = math.rad(fragment.angle)
				fragment.frame.Position = UDim2.new(
					0.5,
					math.floor((math.cos(radians) * (fragment.distance + sweep))),
					0.5,
					math.floor((math.sin(radians) * (fragment.distance + sweep)))
				)
				fragment.frame.Rotation = fragment.angle + (math.sin((elapsed * 2.2) + index) * 6)
				fragment.frame.BackgroundTransparency = 0.16 + ((1 - beamPulse) * 0.12)
			end
		end

		for index, sparkle in ipairs(intro.sparkles or {}) do
			if sparkle.main and sparkle.main.Parent then
				local orbit = math.sin((elapsed * 1.8) + index) * 4
				local rise = math.cos((elapsed * 1.4) + (index * 0.6)) * 5
				sparkle.main.Position = UDim2.new(sparkle.home.X.Scale, sparkle.home.X.Offset + orbit, sparkle.home.Y.Scale, sparkle.home.Y.Offset + rise)
				sparkle.main.Rotation = elapsed * (14 + index)
			end
		end
		for index, dust in ipairs(intro.dustMotes or {}) do
			if dust.frame and dust.frame.Parent then
				local offsetX = math.sin((elapsed * dust.speed) + index) * 16
				local offsetY = math.cos((elapsed * (dust.speed * 0.7)) + index) * 12
				dust.frame.Position = UDim2.new(dust.home.X.Scale, dust.home.X.Offset + offsetX, dust.home.Y.Scale, dust.home.Y.Offset + offsetY)
				dust.frame.BackgroundTransparency = introClamp(dust.alpha - (orbitPulse * 0.08), 0, 1)
			end
		end
		for _, dot in ipairs(intro.orbitalDots or {}) do
			if dot.frame and dot.frame.Parent then
				local radians = math.rad(dot.angle + (elapsed * dot.speed * 10))
				local radius = dot.radius + (math.sin((elapsed * 1.3) + dot.speed) * 6)
				dot.frame.Position = UDim2.new(0.5, math.cos(radians) * radius, 0.5, math.sin(radians) * radius)
				dot.frame.BackgroundTransparency = introClamp(dot.alpha - (orbitPulse * 0.12), 0, 1)
			end
		end
		for index, arc in ipairs(intro.ringArcs or {}) do
			if arc.frame and arc.frame.Parent then
				local pulse = 0.54 - ((0.5 + (math.sin((elapsed * 1.9) + index) * 0.5)) * 0.14)
				arc.frame.BackgroundTransparency = pulse
			end
		end
		for index, spoke in ipairs(intro.coreSpokes or {}) do
			if spoke.frame and spoke.frame.Parent then
				local spokePulse = 0.5 + (math.sin((elapsed * 2.6) + index) * 0.5)
				spoke.frame.Rotation = spoke.baseRotation + (math.sin((elapsed * 0.8) + index) * 4)
				spoke.frame.Size = UDim2.new(0, spoke.baseSize.X.Offset + math.floor(spokePulse * 14), 0, spoke.baseSize.Y.Offset)
				spoke.frame.BackgroundTransparency = introClamp(spoke.alpha - (spokePulse * 0.16), 0, 1)
			end
		end

		for index, glyphStar in ipairs(intro.glyphStars or {}) do
			if glyphStar.main and glyphStar.main.Parent then
				local shimmer = 0.3 - ((0.5 + (math.sin((elapsed * 3.4) + index) * 0.5)) * 0.12)
				glyphStar.main.BackgroundTransparency = shimmer
				glyphStar.cross.BackgroundTransparency = shimmer
			end
		end

		for index, accentStar in ipairs(intro.sideAccentStars or {}) do
			if accentStar.main and accentStar.main.Parent then
				local pulse = 0.12 - ((0.5 + (math.sin((elapsed * 4.1) + index) * 0.5)) * 0.06)
				accentStar.main.BackgroundTransparency = pulse
				accentStar.cross.BackgroundTransparency = pulse
				accentStar.main.Rotation = elapsed * (18 + (index * 3))
			end
		end
		for index, glint in ipairs(intro.titleChars or {}) do
			if glint.frame and glint.frame.Parent then
				local sweep = math.sin((elapsed * 2.2) + index) * 24
				glint.frame.Position = UDim2.new(glint.home.X.Scale, glint.home.X.Offset + sweep, glint.home.Y.Scale, glint.home.Y.Offset)
				glint.frame.BackgroundTransparency = 0.22 - ((0.5 + (math.sin((elapsed * 4.6) + index) * 0.5)) * 0.12)
			end
		end
	end)

	task.wait(0.18)
	titleShadowIn:Play()
	titleIn:Play()
	TweenService:Create(intro.title, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextStrokeTransparency = 0.48,
	}):Play()

	task.wait(0.12)
	subIn:Play()
	leftLineIn:Play()
	rightLineIn:Play()
	for _, accentStar in ipairs(intro.sideAccentStars or {}) do
		TweenService:Create(accentStar.main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.12,
		}):Play()
		TweenService:Create(accentStar.cross, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.12,
		}):Play()
	end

	task.wait(0.94)
	intro.active = false
	if intro.runtimeConnection then
		intro.runtimeConnection:Disconnect()
		intro.runtimeConnection = nil
	end

	local fadeInfo = TweenInfo.new(0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	TweenService:Create(intro.flashWash, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.16,
	}):Play()
	task.wait(0.08)
	TweenService:Create(intro.overlay, fadeInfo, {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(intro.backdrop, fadeInfo, {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(intro.windowShell, fadeInfo, {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 660, 0, 212),
	}):Play()
	TweenService:Create(intro.windowTopBar, fadeInfo, {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(intro.windowTopLine, fadeInfo, {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(intro.windowTitle, fadeInfo, {
		TextTransparency = 1,
	}):Play()
	TweenService:Create(intro.windowSub, fadeInfo, {
		TextTransparency = 1,
	}):Play()
	TweenService:Create(intro.windowBadge, fadeInfo, {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(intro.windowBodyDivider, fadeInfo, {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(intro.windowBodyChip, fadeInfo, {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(intro.hudFrame, fadeInfo, {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 820, 0, 250),
	}):Play()
	TweenService:Create(intro.hudSweep, fadeInfo, {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(intro.topLetterbox, fadeInfo, {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(intro.bottomLetterbox, fadeInfo, {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(intro.coreGlow, fadeInfo, {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 420, 0, 420),
	}):Play()
	TweenService:Create(intro.auraGlow, fadeInfo, {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 920, 0, 920),
	}):Play()
	TweenService:Create(intro.crossVertical, fadeInfo, {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(intro.crossHorizontal, fadeInfo, {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(intro.diagA, fadeInfo, {
		BackgroundTransparency = 1,
		Rotation = 45,
	}):Play()
	TweenService:Create(intro.diagB, fadeInfo, {
		BackgroundTransparency = 1,
		Rotation = -21,
	}):Play()
	TweenService:Create(intro.beamAuraA, fadeInfo, {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(intro.beamAuraB, fadeInfo, {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(intro.haloInner, fadeInfo, {
		Size = UDim2.new(0, 520, 0, 520),
	}):Play()
	TweenService:Create(intro.haloMid, fadeInfo, {
		Size = UDim2.new(0, 620, 0, 620),
	}):Play()
	TweenService:Create(intro.haloOuter, fadeInfo, {
		Size = UDim2.new(0, 760, 0, 760),
	}):Play()
	TweenService:Create(intro.haloGlyph, fadeInfo, {
		Size = UDim2.new(0, 720, 0, 720),
	}):Play()
	if haloInnerStroke then
		TweenService:Create(haloInnerStroke, fadeInfo, {
			Transparency = 1,
		}):Play()
	end
	if haloOuterStroke then
		TweenService:Create(haloOuterStroke, fadeInfo, {
			Transparency = 1,
		}):Play()
	end
	if haloMidStroke then
		TweenService:Create(haloMidStroke, fadeInfo, {
			Transparency = 1,
		}):Play()
	end
	if hudFrameStroke then
		TweenService:Create(hudFrameStroke, fadeInfo, {
			Transparency = 1,
		}):Play()
	end
	if windowShellStroke then
		TweenService:Create(windowShellStroke, fadeInfo, {
			Transparency = 1,
		}):Play()
	end
	TweenService:Create(intro.kicker, fadeInfo, {
		TextTransparency = 1,
	}):Play()
	TweenService:Create(intro.titleShadow, fadeInfo, {
		TextTransparency = 1,
	}):Play()
	TweenService:Create(intro.title, fadeInfo, {
		TextTransparency = 1,
	}):Play()
	TweenService:Create(intro.sub, fadeInfo, {
		TextTransparency = 1,
	}):Play()
	TweenService:Create(intro.title, fadeInfo, {
		TextStrokeTransparency = 1,
	}):Play()
	TweenService:Create(intro.sub, fadeInfo, {
		TextStrokeTransparency = 1,
	}):Play()
	TweenService:Create(intro.leftLine, fadeInfo, {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(intro.rightLine, fadeInfo, {
		BackgroundTransparency = 1,
	}):Play()
	for _, streak in ipairs(intro.radialStreaks or {}) do
		if streak.frame then
			TweenService:Create(streak.frame, fadeInfo, {
				BackgroundTransparency = 1,
			}):Play()
		end
	end
	for _, trail in ipairs(intro.beamTrails or {}) do
		if trail.frame then
			TweenService:Create(trail.frame, fadeInfo, {
				BackgroundTransparency = 1,
			}):Play()
		end
	end
	for _, fragment in ipairs(intro.beamFragments or {}) do
		if fragment.frame then
			TweenService:Create(fragment.frame, fadeInfo, {
				BackgroundTransparency = 1,
			}):Play()
		end
	end
	for _, sparkle in ipairs(intro.sparkles) do
		TweenService:Create(sparkle.main, fadeInfo, {
			BackgroundTransparency = 1,
		}):Play()
		TweenService:Create(sparkle.cross, fadeInfo, {
			BackgroundTransparency = 1,
		}):Play()
	end
	for _, glyphStar in ipairs(intro.glyphStars or {}) do
		TweenService:Create(glyphStar.main, fadeInfo, {
			BackgroundTransparency = 1,
		}):Play()
		TweenService:Create(glyphStar.cross, fadeInfo, {
			BackgroundTransparency = 1,
		}):Play()
	end
	for _, accentStar in ipairs(intro.sideAccentStars or {}) do
		TweenService:Create(accentStar.main, fadeInfo, {
			BackgroundTransparency = 1,
		}):Play()
		TweenService:Create(accentStar.cross, fadeInfo, {
			BackgroundTransparency = 1,
		}):Play()
	end
	for _, cloud in ipairs(intro.nebulaClouds or {}) do
		TweenService:Create(cloud.frame, fadeInfo, {
			BackgroundTransparency = 1,
		}):Play()
	end
	for _, dot in ipairs(intro.orbitalDots or {}) do
		TweenService:Create(dot.frame, fadeInfo, {
			BackgroundTransparency = 1,
		}):Play()
	end
	for _, dust in ipairs(intro.dustMotes or {}) do
		TweenService:Create(dust.frame, fadeInfo, {
			BackgroundTransparency = 1,
		}):Play()
	end
	for _, arc in ipairs(intro.ringArcs or {}) do
		TweenService:Create(arc.frame, fadeInfo, {
			BackgroundTransparency = 1,
		}):Play()
	end
	for _, spoke in ipairs(intro.coreSpokes or {}) do
		TweenService:Create(spoke.frame, fadeInfo, {
			BackgroundTransparency = 1,
		}):Play()
	end
	for _, glint in ipairs(intro.titleChars or {}) do
		TweenService:Create(glint.frame, fadeInfo, {
			BackgroundTransparency = 1,
		}):Play()
	end
	TweenService:Create(intro.flashWash, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		BackgroundTransparency = 1,
	}):Play()

	task.delay(0.42, function()
		if intro.overlay then
			intro.overlay:Destroy()
		end
	end)

	if onComplete then
		onComplete()
	end
end

return {
	play = play,
	intro = intro,
}
end

]==]

local introController

do
	local introFactory = requireLocalModule("C:\\Users\\alexl\\Desktop\\ESP\\esp_modules\\intro_animation.lua", INTRO_ANIMATION_MODULE_SOURCE)
	if type(introFactory) == "function" then
		introController = introFactory({
			create = create,
			addCorner = addCorner,
			addStroke = addStroke,
			makeLabel = makeLabel,
			TweenService = TweenService,
			RunService = RunService,
			gui = gui,
			CONFIG = CONFIG,
			THEME = THEME,
		})
	end
end

local window = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = THEME.window,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 416, 0, 454),
	Active = true,
	Draggable = true,
	Parent = gui,
})
addCorner(window, 9)
addStroke(window, THEME.border, 0.2, 1)
window.Visible = false

local expandedWindowSize = UDim2.new(0, 416, 0, 564)
local minimizedWindowSize = UDim2.new(0, 416, 0, 96)
local minimalWindowSize = UDim2.new(0, 392, 0, 486)
local minimalMinimizedWindowSize = UDim2.new(0, 392, 0, 82)
local uiMinimized = false
local updateInterval = 1 / 30
currentFps = 0
trackedEnemyCount = 0
lastRefreshMs = 0

PRESETS = {
	{
		name = "Legit",
		description = "Low-noise ESP with names and distance only. Best for subtle use.",
		apply = function()
			CONFIG.showNames = true
			CONFIG.showDistance = true
			CONFIG.showHealth = false
			CONFIG.showWeapon = false
			CONFIG.visibilityCheck = false
			CONFIG.showTracers = false
			CONFIG.boxMode = "Chams"
		end,
	},
	{
		name = "Combat",
		description = "Balanced combat layout with health, weapons, tracers, and visibility checks.",
		apply = function()
			CONFIG.showNames = true
			CONFIG.showDistance = true
			CONFIG.showHealth = true
			CONFIG.showWeapon = true
			CONFIG.visibilityCheck = true
			CONFIG.showTracers = true
			CONFIG.boxMode = "2D Box"
		end,
	},
	{
		name = "Full",
		description = "More complete combat info with stronger box visuals and full readouts.",
		apply = function()
			CONFIG.showNames = true
			CONFIG.showDistance = true
			CONFIG.showHealth = true
			CONFIG.showWeapon = true
			CONFIG.visibilityCheck = true
			CONFIG.showTracers = true
			CONFIG.boxMode = "Corner Box"
		end,
	},
	{
		name = "Rage",
		description = "Aggressive tracking with skeletons, head dots, split tracers, and focus lock.",
		apply = function()
			CONFIG.showNames = true
			CONFIG.showDistance = true
			CONFIG.showHealth = true
			CONFIG.showWeapon = true
			CONFIG.visibilityCheck = true
			CONFIG.showTracers = true
			CONFIG.showSkeleton = true
			CONFIG.showHeadDot = true
			CONFIG.showLookDirection = true
			CONFIG.focusLock = true
			CONFIG.boxMode = "Corner Box"
			CONFIG.tracerStyle = "Split"
		end,
	},
	{
		name = "Streamer",
		description = "Cleaner, lower-profile visuals that hide obvious player-identifying info.",
		apply = function()
			CONFIG.showNames = false
			CONFIG.showDistance = true
			CONFIG.showHealth = false
			CONFIG.showWeapon = false
			CONFIG.visibilityCheck = true
			CONFIG.showTracers = true
			CONFIG.showSkeleton = false
			CONFIG.showHeadDot = false
			CONFIG.showLookDirection = false
			CONFIG.boxMode = "Chams"
			CONFIG.tracerStyle = "Direct"
		end,
	},
	{
		name = "Performance",
		description = "Lightweight rendering preset for crowded games or lower-end machines.",
		apply = function()
			CONFIG.showNames = true
			CONFIG.showDistance = true
			CONFIG.showHealth = false
			CONFIG.showWeapon = false
			CONFIG.showSkeleton = false
			CONFIG.showHeadDot = false
			CONFIG.showTracers = true
			CONFIG.visibilityCheck = false
			CONFIG.performanceMode = true
			CONFIG.boxMode = "Chams"
		end,
	},
}

BOX_MODE_OPTIONS = {
	"Chams",
	"Flat Chams",
	"Outline Chams",
	"Split Chams",
	"2D Box",
	"Health Box",
	"Corner Box",
	"Head Box",
	"3D Box",
	"3D Corner",
}
BOX_3D_EDGES = {
	{ 1, 2 }, { 1, 3 }, { 1, 5 },
	{ 2, 4 }, { 2, 6 },
	{ 3, 4 }, { 3, 7 },
	{ 4, 8 },
	{ 5, 6 }, { 5, 7 },
	{ 6, 8 },
	{ 7, 8 },
}
local TRACER_ORIGIN_OPTIONS = { "Bottom", "Center", "Crosshair" }
local CROSSHAIR_OPTIONS = { "Cross", "Dot", "CrossDot" }
local CROSSHAIR_COLOR_OPTIONS = {
	{ name = "White", color = Color3.fromRGB(244, 246, 252) },
	{ name = "Blue", color = Color3.fromRGB(88, 166, 255) },
	{ name = "Green", color = Color3.fromRGB(117, 255, 160) },
	{ name = "Red", color = Color3.fromRGB(255, 116, 116) },
	{ name = "Yellow", color = Color3.fromRGB(255, 214, 102) },
	{ name = "Pink", color = Color3.fromRGB(255, 2, 127) },
}
local CROSSHAIR_SIZE_OPTIONS = { 5, 7, 9, 11, 13 }
TRAINER_PRESET_DEFS = {
	{
		name = "Warmup",
		description = "Balanced click drill with forgiving hit window and a short timed session.",
		apply = function()
			CONFIG.aimTrainerMode = true
			CONFIG.trainerDrillType = "Click"
			CONFIG.trainerReactionTimer = true
			CONFIG.trainerHitWindow = 22
			CONFIG.trainerChallengeMode = true
			CONFIG.trainerChallengeDuration = 30
			CONFIG.trainerShrinkingTargets = false
			CONFIG.trainerTrackHoldTime = 2
			CONFIG.trainerTargetSpeed = 110
		end,
	},
	{
		name = "Precision",
		description = "Small click window with shrinking targets for tighter accuracy practice.",
		apply = function()
			CONFIG.aimTrainerMode = true
			CONFIG.trainerDrillType = "Click"
			CONFIG.trainerReactionTimer = true
			CONFIG.trainerHitWindow = 12
			CONFIG.trainerChallengeMode = true
			CONFIG.trainerChallengeDuration = 45
			CONFIG.trainerShrinkingTargets = true
			CONFIG.trainerTrackHoldTime = 2
			CONFIG.trainerTargetSpeed = 125
		end,
	},
	{
		name = "Tracking",
		description = "Moving target drill with longer hold time and faster travel speed.",
		apply = function()
			CONFIG.aimTrainerMode = true
			CONFIG.trainerDrillType = "Track"
			CONFIG.trainerReactionTimer = true
			CONFIG.trainerHitWindow = 16
			CONFIG.trainerChallengeMode = true
			CONFIG.trainerChallengeDuration = 45
			CONFIG.trainerShrinkingTargets = false
			CONFIG.trainerTrackHoldTime = 3
			CONFIG.trainerTargetSpeed = 150
		end,
	},
	{
		name = "Speed",
		description = "Fast click drill for rapid target swaps with a shorter timer and larger pace demand.",
		apply = function()
			CONFIG.aimTrainerMode = true
			CONFIG.trainerDrillType = "Click"
			CONFIG.trainerReactionTimer = true
			CONFIG.trainerHitWindow = 16
			CONFIG.trainerChallengeMode = true
			CONFIG.trainerChallengeDuration = 20
			CONFIG.trainerShrinkingTargets = false
			CONFIG.trainerTrackHoldTime = 2
			CONFIG.trainerTargetSpeed = 170
		end,
	},
	{
		name = "Micro Adjust",
		description = "Tiny click targets with shrinking enabled to train fine cursor correction and stop control.",
		apply = function()
			CONFIG.aimTrainerMode = true
			CONFIG.trainerDrillType = "Click"
			CONFIG.trainerReactionTimer = true
			CONFIG.trainerHitWindow = 9
			CONFIG.trainerChallengeMode = true
			CONFIG.trainerChallengeDuration = 35
			CONFIG.trainerShrinkingTargets = true
			CONFIG.trainerTrackHoldTime = 2
			CONFIG.trainerTargetSpeed = 105
		end,
	},
}
TRAINER_CUSTOM_PRESETS = {
	["Custom 1"] = {
		label = "Custom 1",
		badge = "USER 1",
		settings = nil,
	},
	["Custom 2"] = {
		label = "Custom 2",
		badge = "USER 2",
		settings = nil,
	},
}
local SKELETON_CONNECTIONS = {
	{ "Head", "UpperTorso" },
	{ "UpperTorso", "LowerTorso" },
	{ "UpperTorso", "LeftUpperArm" },
	{ "LeftUpperArm", "LeftLowerArm" },
	{ "LeftLowerArm", "LeftHand" },
	{ "UpperTorso", "RightUpperArm" },
	{ "RightUpperArm", "RightLowerArm" },
	{ "RightLowerArm", "RightHand" },
	{ "LowerTorso", "LeftUpperLeg" },
	{ "LeftUpperLeg", "LeftLowerLeg" },
	{ "LeftLowerLeg", "LeftFoot" },
	{ "LowerTorso", "RightUpperLeg" },
	{ "RightUpperLeg", "RightLowerLeg" },
	{ "RightLowerLeg", "RightFoot" },
	{ "Head", "Torso" },
	{ "Torso", "Left Arm" },
	{ "Left Arm", "Left Leg" },
	{ "Torso", "Right Arm" },
	{ "Right Arm", "Right Leg" },
}

SETTING_KEYS = {
	"enabled",
	"showNames",
	"showDistance",
	"distanceFade",
	"showHealth",
	"showWeapon",
	"showSkeleton",
	"showHeadDot",
	"headDotSize",
	"showFocusTarget",
	"showBoxes",
	"threatMode",
	"focusLock",
	"visibilityCheck",
	"showTracers",
	"tracerOriginMode",
	"tracerThickness",
	"tracerTransparency",
	"showCrosshair",
	"showFovCircle",
	"crosshairStyle",
	"crosshairColor",
	"crosshairSize",
	"crosshairThickness",
	"crosshairGap",
	"fovRadius",
	"fovCircleThickness",
	"fovCircleTransparency",
	"aimTrainerMode",
	"trainerDrillType",
	"trainerReactionTimer",
	"trainerHitWindow",
	"trainerChallengeMode",
	"trainerChallengeDuration",
	"trainerShrinkingTargets",
	"trainerTrackHoldTime",
	"trainerTargetSpeed",
	"recoilVisualizer",
	"spreadVisualizer",
	"cameraFov",
	"freeCamSpeed",
	"removeZoomLimit",
	"walkSpeedEnabled",
	"walkSpeed",
	"infiniteJump",
	"noclip",
	"fly",
	"flySpeed",
	"clickTeleport",
	"boxMode",
	"minimalMode",
	"showMiniHud",
	"keybindsEnabled",
	"showKeybindsUi",
	"showLookDirection",
	"antiAfk",
	"autoLoadGamePreset",
	"performanceMode",
	"simplifyMaterials",
	"hideTextures",
	"hideEffects",
	"disableShadows",
	"showTargetCard",
	"targetCardCompact",
	"textStackMode",
	"tracerStyle",
	"spectateMode",
	"cameraRigPreset",
	"fillTransparency",
	"outlineTransparency",
	"maxDistance",
	"windowOffsetX",
	"windowOffsetY",
	"miniHudOffsetX",
	"miniHudOffsetY",
	"keybindPanelOffsetX",
	"keybindPanelOffsetY",
	"targetCardOffsetX",
	"targetCardOffsetY",
}

loadSettings()
CONFIG.enabled = true
CONFIG.showSkeleton = false
CONFIG.boxMode = normalizeBoxMode(CONFIG.boxMode)
CONFIG.aimTrainerMode = false
CONFIG.trainerChallengeMode = false

create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 27, 38)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 19, 27)),
	}),
	Rotation = 90,
	Parent = window,
})

local chrome = {}
chrome.topBar = create("Frame", {
	BackgroundColor3 = THEME.header,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	Size = UDim2.new(1, 0, 0, 108),
	Parent = window,
})
addCorner(chrome.topBar, 9)

chrome.minimizeButton = create("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	AutoButtonColor = false,
	BackgroundColor3 = Color3.fromRGB(42, 47, 61),
	BorderSizePixel = 0,
	Position = UDim2.new(1, -12, 0, 14),
	Size = UDim2.new(0, 26, 0, 20),
	Font = Enum.Font.GothamBold,
	Text = "-",
	TextColor3 = THEME.text,
	TextSize = 16,
	ZIndex = 6,
	Parent = chrome.topBar,
})
addCorner(chrome.minimizeButton, 4)
addStroke(chrome.minimizeButton, THEME.border, 0.25, 1)

create("Frame", {
	BackgroundColor3 = Color3.fromRGB(56, 62, 78),
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 1, -1),
	Size = UDim2.new(1, 0, 0, 1),
	Parent = chrome.topBar,
})

chrome.glow = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundColor3 = THEME.accent,
	BackgroundTransparency = 0.9,
	BorderSizePixel = 0,
	Position = UDim2.new(0.58, 0, 0, -28),
	Size = UDim2.new(0.95, 0, 0, 140),
	Parent = chrome.topBar,
})
addCorner(chrome.glow, 120)

chrome.brand = create("Frame", {
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 12, 0, 12),
	Size = UDim2.new(0, 186, 0, 42),
	Parent = chrome.topBar,
})

chrome.brandKicker = makeLabel(chrome.brand, "TACTICAL ESP SUITE", 9, THEME.accent, Enum.Font.GothamBold)
chrome.brandKicker.Size = UDim2.new(1, 0, 0, 12)

chrome.brandTitle = makeLabel(chrome.brand, CONFIG.panelTitle, 21, THEME.text, Enum.Font.GothamBlack)
chrome.brandTitle.AutomaticSize = Enum.AutomaticSize.X
chrome.brandTitle.Position = UDim2.new(0, 0, 0, 9)
chrome.brandTitle.Size = UDim2.new(0, 0, 0, 20)

chrome.brandSub = makeLabel(chrome.brand, "Adaptive overlays and combat info", 9, THEME.muted, Enum.Font.GothamMedium)
chrome.brandSub.Position = UDim2.new(0, 1, 0, 32)
chrome.brandSub.Size = UDim2.new(0, 186, 0, 12)

chrome.infoPanel = create("Frame", {
	AnchorPoint = Vector2.new(1, 0),
	BackgroundColor3 = Color3.fromRGB(33, 37, 49),
	BorderSizePixel = 0,
	Position = UDim2.new(1, -42, 0, 12),
	Size = UDim2.new(0, 138, 0, 58),
	Parent = chrome.topBar,
})
addCorner(chrome.infoPanel, 8)
addStroke(chrome.infoPanel, THEME.border, 0.35, 1)

chrome.infoContent = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(1, -10, 0, 48),
	Parent = chrome.infoPanel,
})

local function createInfoRow(parent, y, title, value)
	local row = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, y),
		Size = UDim2.new(1, 0, 0, 22),
		Parent = parent,
	})

	local label = makeLabel(row, title, 10, THEME.muted, Enum.Font.GothamBold)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.Size = UDim2.new(0, 40, 1, 0)

	local valueLabel = create("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Color3.fromRGB(54, 51, 63),
		BorderSizePixel = 0,
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 80, 0, 20),
		Font = Enum.Font.GothamBold,
		Text = value,
		TextColor3 = THEME.text,
		TextSize = 11,
		Parent = row,
	})
	addCorner(valueLabel, 4)
	addStroke(valueLabel, THEME.border, 0.25, 1)
	return valueLabel
end

createInfoRow(chrome.infoContent, 1, "PLAYER", LOCAL_PLAYER and LOCAL_PLAYER.Name or "Player")
createInfoRow(chrome.infoContent, 25, "VERSION", CONFIG.version)

local tabBar = create("Frame", {
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 12, 0, 78),
	Size = UDim2.new(1, -24, 0, 18),
	Parent = chrome.topBar,
})

create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 6),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = tabBar,
})

local content = create("Frame", {
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 0, 108),
	Size = UDim2.new(1, 0, 1, -108),
	Parent = window,
})

local pagesContainer = create("Frame", {
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, 0, 1, 0),
	Parent = content,
})

local function createPage()
	local page = create("ScrollingFrame", {
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarImageColor3 = THEME.accent,
		ScrollBarThickness = 4,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
		Parent = pagesContainer,
	})

	create("UIPadding", {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 0),
		Parent = page,
	})

	create("UIListLayout", {
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = page,
	})

	return page
end

local pages = {
	control = createPage(),
	keybinds = createPage(),
	display = createPage(),
	combat = createPage(),
	player = createPage(),
	performance = createPage(),
}

local tabButtons = {}

local function createRow(parent, height)
	local row = create("Frame", {
		BackgroundColor3 = THEME.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, height or 28),
		Parent = parent,
	})
	addCorner(row, 8)
	addStroke(row, THEME.border, 0.45, 1)
	return row
end

do
	local overlayFactory = requireLocalModule("C:\\Users\\alexl\\Desktop\\ESP\\esp_modules\\overlay_tools.lua", OVERLAY_TOOLS_MODULE_SOURCE)
	if type(overlayFactory) == "function" then
		overlayTools = overlayFactory({
			addCorner = addCorner,
			addStroke = addStroke,
			config = CONFIG,
			create = create,
			createRow = createRow,
			gui = gui,
			guiService = game:GetService("GuiService"),
			makeLabel = makeLabel,
			saveSettings = saveSettings,
			showToast = showToast,
			theme = THEME,
			userInputService = UserInputService,
		})
		overlayTools.makeOverlayDraggable(miniHud, "miniHud")
	end
end

local function createStatusRow(parent, labelText, valueText)
	local row = createRow(parent, 24)
	local label = makeLabel(row, labelText, 11, THEME.muted, Enum.Font.GothamMedium)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.Size = UDim2.new(0, 120, 1, 0)

	local value = makeLabel(row, valueText, 11, THEME.text, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
	value.AnchorPoint = Vector2.new(1, 0)
	value.Position = UDim2.new(1, -10, 0, 0)
	value.Size = UDim2.new(0, 132, 1, 0)
	return row, value
end

function createNoteRow(parent, text)
	local row = createRow(parent, 26)
	row.BackgroundColor3 = THEME.panelAlt
	local label = makeLabel(row, text, 9, THEME.muted, Enum.Font.GothamMedium)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.Size = UDim2.new(1, -20, 1, 0)
	return row, label
end

local function createPerfRow(parent)
	local row = createRow(parent, 34)

	local statHolder = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -18, 1, -8),
		Parent = row,
	})

	create("UIGridLayout", {
		CellPadding = UDim2.new(0, 6, 0, 0),
		CellSize = UDim2.new(0.25, -5, 1, 0),
		FillDirectionMaxCells = 4,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = statHolder,
	})

	local stats = {}
	for _, item in ipairs({
		{ key = "fps", title = "FPS" },
		{ key = "visible", title = "VISIBLE" },
		{ key = "tracked", title = "TRACKED" },
		{ key = "update", title = "UPDATE" },
	}) do
		local cell = create("Frame", {
			BackgroundColor3 = THEME.panelAlt,
			BorderSizePixel = 0,
			Parent = statHolder,
		})
		addCorner(cell, 6)

		local title = makeLabel(cell, item.title, 8, THEME.muted, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
		title.Position = UDim2.new(0, 0, 0, 2)
		title.Size = UDim2.new(1, 0, 0, 10)

		local value = makeLabel(cell, "--", 10, THEME.text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
		value.Position = UDim2.new(0, 0, 0, 12)
		value.Size = UDim2.new(1, 0, 1, -12)

		stats[item.key] = value
	end

	return row, stats
end

function createTrainerCardsRow(parent)
	local row = createRow(parent, 108)
	row.BackgroundColor3 = THEME.panelAlt

	local holder = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -18, 1, -12),
		Parent = row,
	})

	create("UIGridLayout", {
		CellPadding = UDim2.new(0, 8, 0, 0),
		CellSize = UDim2.new(0.5, -4, 1, 0),
		FillDirectionMaxCells = 2,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = holder,
	})

	local function createCard(titleText, accentColor)
		local card = create("Frame", {
			BackgroundColor3 = Color3.fromRGB(22, 27, 37),
			BorderSizePixel = 0,
			Parent = holder,
		})
		addCorner(card, 8)
		addStroke(card, accentColor, 0.72, 1)

		local title = makeLabel(card, titleText, 10, THEME.text, Enum.Font.GothamBold)
		title.Position = UDim2.new(0, 10, 0, 8)
		title.Size = UDim2.new(0, 66, 0, 12)

		local badge = create("TextLabel", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = Color3.fromRGB(35, 40, 53),
			BorderSizePixel = 0,
			Position = UDim2.new(1, -8, 0, 8),
			Size = UDim2.new(0, 44, 0, 14),
			Font = Enum.Font.GothamBold,
			Text = "IDLE",
			TextColor3 = THEME.muted,
			TextSize = 7,
			Parent = card,
		})
		addCorner(badge, 999)

		local lines = {}
		for index = 1, 4 do
			local line = makeLabel(card, "--", 9, THEME.muted, Enum.Font.GothamMedium)
			line.Position = UDim2.new(0, 10, 0, 28 + ((index - 1) * 16))
			line.Size = UDim2.new(1, -20, 0, 14)
			lines[index] = line
		end

		return {
			frame = card,
			badge = badge,
			lines = lines,
			accent = accentColor,
		}
	end

	return row, {
		click = createCard("CLICK", THEME.accent),
		track = createCard("TRACK", THEME.focus),
	}
end

function createTrainerResultsRow(parent)
	local row = createRow(parent, 98)
	row.BackgroundColor3 = THEME.panelAlt
	row.Visible = false

	local title = makeLabel(row, "LAST CHALLENGE", 10, THEME.text, Enum.Font.GothamBold)
	title.Position = UDim2.new(0, 10, 0, 8)
	title.Size = UDim2.new(0, 110, 0, 12)

	local badge = create("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -10, 0, 8),
		Size = UDim2.new(0, 62, 0, 16),
		Font = Enum.Font.GothamBold,
		Text = "EMPTY",
		TextColor3 = THEME.muted,
		TextSize = 8,
		Parent = row,
	})
	addCorner(badge, 999)

	local lines = {}
	for index = 1, 4 do
		local line = makeLabel(row, "--", 9, THEME.muted, Enum.Font.GothamMedium)
		line.Position = UDim2.new(0, 10, 0, 30 + ((index - 1) * 14))
		line.Size = UDim2.new(1, -20, 0, 12)
		lines[index] = line
	end

	return row, {
		badge = badge,
		lines = lines,
	}
end

function createTrainerHistoryRow(parent)
	local row = createRow(parent, 92)
	row.BackgroundColor3 = THEME.panelAlt
	row.Visible = false

	local title = makeLabel(row, "SESSION HISTORY", 10, THEME.text, Enum.Font.GothamBold)
	title.Position = UDim2.new(0, 10, 0, 8)
	title.Size = UDim2.new(0, 110, 0, 12)

	local badge = create("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -10, 0, 8),
		Size = UDim2.new(0, 54, 0, 16),
		Font = Enum.Font.GothamBold,
		Text = "0 RUNS",
		TextColor3 = THEME.muted,
		TextSize = 8,
		Parent = row,
	})
	addCorner(badge, 999)

	local lines = {}
	for index = 1, 4 do
		local line = makeLabel(row, "--", 9, THEME.muted, Enum.Font.GothamMedium)
		line.Position = UDim2.new(0, 10, 0, 30 + ((index - 1) * 14))
		line.Size = UDim2.new(1, -20, 0, 12)
		lines[index] = line
	end

	return row, {
		badge = badge,
		lines = lines,
	}
end

local function createCycleRow(parent, labelText, valueText)
	local row = createRow(parent, 30)
	local label = makeLabel(row, labelText, 10, THEME.muted, Enum.Font.GothamMedium)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.Size = UDim2.new(0, 110, 1, 0)

	local valueButton = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, 126, 0, 20),
		Font = Enum.Font.GothamBold,
		Text = valueText,
		TextColor3 = THEME.text,
		TextSize = 10,
		Parent = row,
	})
	addCorner(valueButton, 4)
	addStroke(valueButton, THEME.border, 0.25, 1)
	return row, valueButton
end

function createPresetDropdownRow(parent)
	local row = createRow(parent, 30)
	local closedHeight = 30
	local optionHeight = 24
	local openHeight = closedHeight + 8 + (#PRESETS * (optionHeight + 4))

	local label = makeLabel(row, "PRESET", 10, THEME.muted, Enum.Font.GothamMedium)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.Size = UDim2.new(0, 110, 0, 30)

	local mainButton = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -40, 0.5, 0),
		Size = UDim2.new(0, 96, 0, 20),
		Font = Enum.Font.GothamBold,
		Text = PRESETS[currentPresetIndex].name,
		TextColor3 = THEME.text,
		TextSize = 10,
		Parent = row,
	})
	addCorner(mainButton, 4)
	addStroke(mainButton, THEME.border, 0.25, 1)

	local arrowButton = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, 24, 0, 20),
		Font = Enum.Font.GothamBold,
		Text = "v",
		TextColor3 = THEME.text,
		TextSize = 12,
		Parent = row,
	})
	addCorner(arrowButton, 4)
	addStroke(arrowButton, THEME.border, 0.25, 1)

	local list = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(20, 24, 33),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 34),
		Size = UDim2.new(1, -20, 0, openHeight - closedHeight - 8),
		Visible = false,
		Parent = row,
	})
	addCorner(list, 6)
	addStroke(list, THEME.border, 0.25, 1)

	create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = list,
	})

	create("UIPadding", {
		PaddingLeft = UDim.new(0, 6),
		PaddingRight = UDim.new(0, 6),
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
		Parent = list,
	})

	local optionButtons = {}
	for index, preset in ipairs(PRESETS) do
		local option = create("TextButton", {
			AutoButtonColor = false,
			BackgroundColor3 = index == currentPresetIndex and THEME.accentSoft or Color3.fromRGB(31, 36, 48),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, optionHeight),
			Font = Enum.Font.GothamBold,
			Text = preset.name,
			TextColor3 = index == currentPresetIndex and THEME.text or THEME.muted,
			TextSize = 9,
			Parent = list,
		})
		addCorner(option, 4)
		addStroke(option, THEME.border, index == currentPresetIndex and 0.2 or 0.45, 1)
		optionButtons[index] = option
	end

	return {
		row = row,
		button = mainButton,
		arrow = arrowButton,
		list = list,
		options = optionButtons,
		closedHeight = closedHeight,
		openHeight = openHeight,
		open = false,
	}
end

local function createToggleRow(parent, labelText, defaultState)
	local row = createRow(parent, 30)
	local label = makeLabel(row, labelText, 10, THEME.muted, Enum.Font.GothamMedium)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.Size = UDim2.new(0, 186, 1, 0)

	local button = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = defaultState and THEME.accentSoft or Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, 46, 0, 20),
		Font = Enum.Font.GothamBold,
		Text = defaultState and "ON" or "OFF",
		TextColor3 = defaultState and Color3.fromRGB(228, 241, 255) or THEME.muted,
		TextSize = 9,
		Parent = row,
	})
	addCorner(button, 999)
	addStroke(button, THEME.accent, defaultState and 0.15 or 0.65, 1)
	return row, button
end

local function createKeybindRow(parent, labelText, valueText)
	local row = createRow(parent, 30)
	local label = makeLabel(row, labelText, 10, THEME.muted, Enum.Font.GothamMedium)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.Size = UDim2.new(0, 170, 1, 0)

	local button = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, 72, 0, 20),
		Font = Enum.Font.GothamBold,
		Text = valueText,
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(button, 999)
	addStroke(button, THEME.accent, 0.55, 1)
	return row, button
end

local function createOptionButtonsRow(parent, labelText, options, selectedValue, formatter)
	local row = createRow(parent, 52)

	local label = makeLabel(row, labelText, 10, THEME.muted, Enum.Font.GothamMedium)
	label.Position = UDim2.new(0, 10, 0, 6)
	label.Size = UDim2.new(1, -20, 0, 12)

	local holder = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 24),
		Size = UDim2.new(1, -20, 0, 20),
		Parent = row,
	})

	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = holder,
	})

	local buttons = {}
	for _, option in ipairs(options) do
		local text = formatter and formatter(option) or tostring(option)
		local textColor = option == selectedValue and THEME.text or THEME.muted
		if labelText == "CROSSHAIR COLOR" then
			for _, colorOption in ipairs(CROSSHAIR_COLOR_OPTIONS) do
				if colorOption.name == option then
					textColor = colorOption.color
					break
				end
			end
		end

		local button = create("TextButton", {
			AutoButtonColor = false,
			BackgroundColor3 = option == selectedValue and THEME.accentSoft or Color3.fromRGB(35, 40, 53),
			BorderSizePixel = 0,
			Size = UDim2.new(0, math.max(32, 18 + (#text * 6)), 1, 0),
			Font = Enum.Font.GothamBold,
			Text = text,
			TextColor3 = textColor,
			TextSize = 9,
			Parent = holder,
		})
		addCorner(button, 999)
		addStroke(button, THEME.accent, option == selectedValue and 0.15 or 0.65, 1)
		table.insert(buttons, {
			value = option,
			button = button,
		})
	end

	return row, buttons
end

local function setOptionButtonsState(buttonEntries, selectedValue)
	for _, entry in ipairs(buttonEntries) do
		local selected = entry.value == selectedValue
		local backgroundColor = selected and THEME.accentSoft or Color3.fromRGB(35, 40, 53)
		local textColor = selected and THEME.text or THEME.muted
		local strokeTransparency = selected and 0.15 or 0.65

		if entry.button:GetAttribute("TrainerPresetButton") then
			local presetColor = entry.button:GetAttribute("PresetColor")
			if typeof(presetColor) == "Color3" then
				backgroundColor = selected and presetColor:Lerp(Color3.fromRGB(255, 255, 255), 0.22) or presetColor:Lerp(Color3.fromRGB(20, 24, 33), 0.7)
				textColor = selected and THEME.text or presetColor
				strokeTransparency = selected and 0.08 or 0.45
			end
		end

		entry.button.BackgroundColor3 = backgroundColor
		entry.button.TextColor3 = textColor

		if type(entry.value) == "string" then
			for _, colorOption in ipairs(CROSSHAIR_COLOR_OPTIONS) do
				if colorOption.name == entry.value then
					entry.button.TextColor3 = selected and THEME.text or colorOption.color
					break
				end
			end
		end

		local stroke = entry.button:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Transparency = strokeTransparency
		end
	end
end

local function createSliderRow(parent, labelText, value, minValue, maxValue)
	local row = createRow(parent, 52)

	local label = makeLabel(row, labelText, 10, THEME.muted, Enum.Font.GothamMedium)
	label.Position = UDim2.new(0, 10, 0, 6)
	label.Size = UDim2.new(0, 150, 0, 12)

	local valueLabel = create("TextBox", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(1, -10, 0, 4),
		Size = UDim2.new(0, 44, 0, 16),
		Text = tostring(value),
		TextColor3 = THEME.text,
		TextSize = 10,
		Parent = row,
	})
	addCorner(valueLabel, 4)
	addStroke(valueLabel, THEME.border, 0.35, 1)

	local bar = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 28),
		Size = UDim2.new(1, -20, 0, 12),
		Text = "",
		Parent = row,
	})
	addCorner(bar, 999)
	addStroke(bar, THEME.border, 0.35, 1)

	local fill = create("Frame", {
		BackgroundColor3 = THEME.accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
		Parent = bar,
	})
	addCorner(fill, 999)

	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = THEME.text,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 10, 0, 10),
		Parent = bar,
	})
	addCorner(knob, 999)

	return {
		bar = bar,
		fill = fill,
		knob = knob,
		valueLabel = valueLabel,
		isEditing = false,
		min = minValue,
		max = maxValue,
	}
end

local function applySliderVisual(slider, value)
	value = tonumber(value) or slider.min or 0
	local alpha = 0
	if slider.max > slider.min then
		alpha = (value - slider.min) / (slider.max - slider.min)
	end
	alpha = math.clamp(alpha, 0, 1)
	slider.fill.Size = UDim2.new(alpha, 0, 1, 0)
	slider.knob.Position = UDim2.new(alpha, 0, 0.5, 0)
end

local function bindSliderValueInput(slider, normalizeValue, commitValue)
	slider.valueLabel.Focused:Connect(function()
		slider.isEditing = true
	end)

	slider.valueLabel:GetPropertyChangedSignal("Text"):Connect(function()
		if not slider.isEditing then
			return
		end

		local typedValue = tonumber(slider.valueLabel.Text)
		if typedValue == nil then
			return
		end

		applySliderVisual(slider, normalizeValue(typedValue))
	end)

	slider.valueLabel.FocusLost:Connect(function()
		slider.isEditing = false

		local typedValue = tonumber(slider.valueLabel.Text)
		if not typedValue then
			setSliderState(slider, normalizeValue())
			return
		end

		local nextValue = normalizeValue(typedValue)
		commitValue(nextValue)
		setSliderState(slider, nextValue)
		task.defer(function()
			if slider and slider.fill and slider.knob then
				setSliderState(slider, nextValue)
			end
		end)
	end)
end

local function createSpectateRow(parent)
	local row = createRow(parent, 30)
	row.ZIndex = 14

	local label = makeLabel(row, "SPECTATE", 10, THEME.muted, Enum.Font.GothamMedium)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.Size = UDim2.new(0, 90, 1, 0)
	label.ZIndex = 14

	local offButton = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(64, 39, 48),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, 42, 0, 20),
		Font = Enum.Font.GothamBold,
		Text = "OFF",
		TextColor3 = THEME.text,
		TextSize = 9,
		ZIndex = 14,
		Parent = row,
	})
	addCorner(offButton, 4)
	addStroke(offButton, THEME.border, 0.35, 1)

	local mainButton = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -58, 0.5, 0),
		Size = UDim2.new(0, 120, 0, 20),
		Font = Enum.Font.GothamBold,
		Text = "SELECT",
		TextColor3 = THEME.text,
		TextSize = 9,
		ZIndex = 14,
		Parent = row,
	})
	addCorner(mainButton, 4)
	addStroke(mainButton, THEME.border, 0.25, 1)

	local list = create("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(24, 28, 38),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -58, 1, 6),
		Size = UDim2.new(0, 154, 0, 176),
		Visible = false,
		ZIndex = 20,
		Parent = row,
	})
	addCorner(list, 6)
	addStroke(list, THEME.border, 0.2, 1)

	local searchBox = create("TextBox", {
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.GothamMedium,
		PlaceholderColor3 = THEME.muted,
		PlaceholderText = "Search player",
		Position = UDim2.new(0, 6, 0, 6),
		Size = UDim2.new(1, -12, 0, 22),
		Text = "",
		TextColor3 = THEME.text,
		TextSize = 10,
		ZIndex = 21,
		Parent = list,
	})
	addCorner(searchBox, 4)
	addStroke(searchBox, THEME.border, 0.35, 1)

	local scroller = create("ScrollingFrame", {
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0, 6, 0, 34),
		ScrollBarImageColor3 = THEME.accent,
		ScrollBarThickness = 4,
		Size = UDim2.new(1, -12, 1, -40),
		ZIndex = 21,
		Parent = list,
	})

	create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = scroller,
	})

	return {
		main = mainButton,
		off = offButton,
		list = list,
		search = searchBox,
		scroller = scroller,
	}
end

local function setSliderState(slider, value)
	applySliderVisual(slider, value)
	if not slider.isEditing then
		slider.valueLabel.Text = tostring(tonumber(value) or slider.min or 0)
	end
end

local function createTabButton(tabName, labelText)
	local button = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 74, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = labelText,
		TextColor3 = THEME.muted,
		TextSize = 10,
		Parent = tabBar,
	})
	addCorner(button, 999)
	addStroke(button, THEME.border, 0.5, 1)
	tabButtons[tabName] = button
	return button
end

local function setActiveTab(tabName)
	for name, page in pairs(pages) do
		page.Visible = name == tabName
	end

	for name, button in pairs(tabButtons) do
		local selected = name == tabName
		button.BackgroundColor3 = selected and THEME.accentSoft or Color3.fromRGB(35, 40, 53)
		button.TextColor3 = selected and THEME.text or THEME.muted
		local stroke = button:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Transparency = selected and 0.15 or 0.5
		end
	end
end

local function setToggleState(button, state)
	button.Text = state and "ON" or "OFF"
	button.TextColor3 = state and Color3.fromRGB(228, 241, 255) or THEME.muted
	button.BackgroundColor3 = state and THEME.accentSoft or Color3.fromRGB(35, 40, 53)

	local stroke = button:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Transparency = state and 0.15 or 0.55
	end
end

function createSubTabGroup(parent, tabState, items, defaultKey)
	tabState = tabState or {}

	local row = createRow(parent, 40)
	row.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 34, 46)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 25, 34)),
		}),
		Rotation = 90,
		Parent = row,
	})

	local accentBar = create("Frame", {
		BackgroundColor3 = THEME.accent,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 6),
		Size = UDim2.new(0, 30, 0, 2),
		Parent = row,
	})
	addCorner(accentBar, 999)

	local holder = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 12),
		Size = UDim2.new(1, -20, 0, 18),
		Parent = row,
	})

	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = holder,
	})

	local body = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = parent,
	})

	create("UIListLayout", {
		Padding = UDim.new(0, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = body,
	})

	tabState.row = row
	tabState.body = body
	tabState.order = {}

	for _, item in ipairs(items) do
		table.insert(tabState.order, item.key)
		tabState[item.key] = create("TextButton", {
			AutoButtonColor = false,
			BackgroundColor3 = item.key == defaultKey and THEME.accentSoft or Color3.fromRGB(35, 40, 53),
			BorderSizePixel = 0,
			Size = UDim2.new(0, item.width or 78, 1, 0),
			Font = Enum.Font.GothamBold,
			Text = item.label,
			TextColor3 = item.key == defaultKey and THEME.text or THEME.muted,
			TextSize = 9,
			Parent = holder,
		})
		addCorner(tabState[item.key], 999)
		addStroke(tabState[item.key], THEME.border, item.key == defaultKey and 0.15 or 0.5, 1)

			tabState[item.key .. "Page"] = create("Frame", {
				BackgroundColor3 = Color3.fromRGB(24, 28, 38),
				BorderSizePixel = 0,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0),
				Visible = item.key == defaultKey,
				Parent = body,
			})
			addCorner(tabState[item.key .. "Page"], 9)
			addStroke(tabState[item.key .. "Page"], THEME.border, 0.4, 1)

			create("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(29, 34, 45)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 24, 33)),
				}),
				Rotation = 90,
				Parent = tabState[item.key .. "Page"],
			})

			create("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 8),
				Parent = tabState[item.key .. "Page"],
			})

			create("UIListLayout", {
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = tabState[item.key .. "Page"],
			})
		end

	tabState.setTab = function(tabName)
		for _, key in ipairs(tabState.order) do
			local selected = key == tabName
			local button = tabState[key]
			local page = tabState[key .. "Page"]
			TweenService:Create(button, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = selected and THEME.accentSoft or Color3.fromRGB(35, 40, 53),
				TextColor3 = selected and THEME.text or THEME.muted,
			}):Play()
			page.Visible = selected
			local stroke = button:FindFirstChildOfClass("UIStroke")
			if stroke then
				stroke.Transparency = selected and 0.15 or 0.5
			end
		end
	end

	for _, key in ipairs(tabState.order) do
		tabState[key].MouseButton1Click:Connect(function()
			tabState.setTab(key)
		end)
	end

	tabState.setTab(defaultKey)
	return tabState
end

function createPageHero(parent, title, badge, description, accentColor)
	local row = createRow(parent, 58)
	row.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(31, 36, 48)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 24, 33)),
		}),
		Rotation = 90,
		Parent = row,
	})

	local accent = create("Frame", {
		BackgroundColor3 = accentColor or THEME.accent,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 4, 1, 0),
		Parent = row,
	})
	addCorner(accent, 8)

	local titleLabel = makeLabel(row, title, 11, THEME.text, Enum.Font.GothamBold)
	titleLabel.Position = UDim2.new(0, 12, 0, 8)
	titleLabel.Size = UDim2.new(0, 130, 0, 14)

	local badgeLabel = create("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = (accentColor or THEME.accent):Lerp(Color3.fromRGB(22, 26, 35), 0.42),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -10, 0, 8),
		Size = UDim2.new(0, 76, 0, 18),
		Font = Enum.Font.GothamBold,
		Text = badge,
		TextColor3 = THEME.text,
		TextSize = 8,
		Parent = row,
	})
	addCorner(badgeLabel, 999)

	local descriptionLabel = makeLabel(row, description, 9, THEME.muted, Enum.Font.GothamMedium)
	descriptionLabel.Position = UDim2.new(0, 12, 0, 26)
	descriptionLabel.Size = UDim2.new(1, -24, 0, 20)

	return row
end

createPageHero(pages.control, "UTILITY", "ACTIVE", "Suite behavior, presets, UI presentation, and utility actions.", THEME.accent)

miniHudLabels.perfStats = select(2, createPerfRow(pages.control))

miniHudLabels.utility.controlTabs = createSubTabGroup(pages.control, miniHudLabels.utility.controlTabs, {
	{ key = "general", label = "GENERAL", width = 86 },
	{ key = "utility", label = "UTILITY", width = 78 },
	{ key = "keybinds", label = "KEYBINDS", width = 84 },
}, "general")
miniHudLabels.utility.setControlTab = miniHudLabels.utility.controlTabs.setTab

miniHudLabels.utility.utilityTabs = createSubTabGroup(pages.control, miniHudLabels.utility.utilityTabs, {
	{ key = "session", label = "SESSION", width = 76 },
	{ key = "actions", label = "ACTIONS", width = 76 },
	{ key = "resets", label = "RESETS", width = 72 },
	{ key = "configs", label = "CONFIGS", width = 78 },
}, "session")
miniHudLabels.utility.utilityTabRow = miniHudLabels.utility.utilityTabs.row
miniHudLabels.utility.utilityTabBody = miniHudLabels.utility.utilityTabs.body
miniHudLabels.utility.setUtilityTab = miniHudLabels.utility.utilityTabs.setTab

createPageHero(pages.display, "DISPLAY", "ACTIVE", "Nameplates, boxes, cards, and how world info is presented.", THEME.focus)

displayButtons = createSubTabGroup(pages.display, displayButtons, {
	{ key = "labels", label = "LABELS", width = 78 },
	{ key = "boxes", label = "BOXES", width = 74 },
	{ key = "cards", label = "CARDS", width = 72 },
}, "labels")

tracerSliders = {}

createPageHero(pages.combat, "COMBAT", "ACTIVE", "Target selection, visibility rules, tracers, and crosshair tuning.", THEME.accent)

tracerSliders.tabs = createSubTabGroup(pages.combat, tracerSliders.tabs, {
	{ key = "targeting", label = "TARGET", width = 74 },
	{ key = "tracers", label = "TRACERS", width = 74 },
	{ key = "crosshair", label = "CROSSHAIR", width = 86 },
	{ key = "trainer", label = "TRAIN", width = 72 },
}, "targeting")
tracerSliders.setCombatTab = tracerSliders.tabs.setTab

createPageHero(pages.player, "PLAYER", "ACTIVE", "View tools and local movement utilities. Movement settings are session-only.", THEME.focus)

createPageHero(pages.performance, "PERFORMANCE", "LOCAL", "Session-only visual cuts for lower-end machines or heavy games.", THEME.muted)

createStatusRow(pages.display, "ESP COLOR", "AUTO TEAM")

miniHudLabels.utility.controls = miniHudLabels.utility.controls or {}
miniHudLabels.utility.utilityRowStyler = function(row, accentColor, tone)
	if not row then
		return
	end
	if tone then
		row.BackgroundColor3 = tone
	end
	local stroke = row:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Color = accentColor or THEME.border
		stroke.Transparency = accentColor and 0.28 or 0.42
	end
end
miniHudLabels.utility.controls.enabledToggle = select(2, createToggleRow(pages.control, "ESP ENABLED", CONFIG.enabled))
miniHudLabels.utility.controls.presetDropdown = createPresetDropdownRow(pages.control)
miniHudLabels.utility.updatePanel = {}
if overlayTools then
	miniHudLabels.utility.updatePanel = overlayTools.buildUpdatePanel(pages.control)
end
miniHudLabels.utility.teamCheckRow, miniHudLabels.utility.teamCheckValue = createStatusRow(pages.control, "TEAM CHECK", "ALWAYS ON")
miniHudLabels.utility.quickHideRow, miniHudLabels.utility.quickHideValue = createStatusRow(pages.control, "MENU TOGGLE", keyCodeToText(CONFIG.quickHideKey))
miniHudLabels.utility.controls.cameraFovSlider = createSliderRow(pages.control, "CAMERA FOV", CONFIG.cameraFov, 40, 120)
miniHudLabels.utility.controls.cameraFovSlider.reset = select(2, createCycleRow(pages.control, "RESET CAMERA", "DEFAULT"))
miniHudLabels.utility.controls.miniHudToggle = select(2, createToggleRow(pages.control, "MINI HUD", CONFIG.showMiniHud))
miniHudLabels.utility.controls.minimalToggle = select(2, createToggleRow(pages.control, "MINIMAL MODE", CONFIG.minimalMode))
miniHudLabels.utility.antiAfk = select(2, createToggleRow(pages.control, "ANTI AFK", CONFIG.antiAfk))
miniHudLabels.utility.autoLoadGamePreset = select(2, createToggleRow(pages.control, "AUTO LOAD PLACE CONFIG", CONFIG.autoLoadGamePreset))
miniHudLabels.saveStatusValue = select(2, createStatusRow(pages.control, "SETTINGS", canUseFileApi() and "AUTO SAVE" or "MEMORY"))
miniHudLabels.utility.utilitySections = miniHudLabels.utility.utilitySections or {}
miniHudLabels.utility.utilitySections.session = select(1, createStatusRow(pages.control, "SESSION", "LOCAL ONLY"))
miniHudLabels.utility.utilitySections.actions = select(1, createStatusRow(pages.control, "MATCH ACTIONS", "LIVE"))
miniHudLabels.utility.utilitySections.overlays = select(1, createStatusRow(pages.control, "OVERLAYS + RESETS", "LAYOUT"))
miniHudLabels.utility.utilitySections.config = select(1, createStatusRow(pages.control, "CONFIG TOOLS", "SAVE"))
miniHudLabels.utility.utilityRowStyler(miniHudLabels.utility.utilitySections.session, THEME.focus, Color3.fromRGB(24, 28, 38))
miniHudLabels.utility.utilityRowStyler(miniHudLabels.utility.utilitySections.actions, THEME.accent, Color3.fromRGB(24, 28, 38))
miniHudLabels.utility.utilityRowStyler(miniHudLabels.utility.utilitySections.overlays, THEME.border, Color3.fromRGB(24, 28, 38))
miniHudLabels.utility.utilityRowStyler(miniHudLabels.utility.utilitySections.config, THEME.muted, Color3.fromRGB(24, 28, 38))

do
	local row = createRow(pages.control, 30)
	local exportConfig = create("TextButton", {
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(0, 10, 0.5, -10),
		Size = UDim2.new(0.48, -6, 0, 20),
		Text = "EXPORT CFG",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(exportConfig, 4)
	addStroke(exportConfig, THEME.border, 0.35, 1)

	local importConfig = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(1, -10, 0.5, -10),
		Size = UDim2.new(0.48, -6, 0, 20),
		Text = "IMPORT CFG",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(importConfig, 4)
	addStroke(importConfig, THEME.border, 0.35, 1)

	miniHudLabels.utility.exportConfig = exportConfig
	miniHudLabels.utility.importConfig = importConfig
end

do
	local row = createRow(pages.control, 54)

	local label = makeLabel(row, "NAMED CONFIGS", 10, THEME.muted, Enum.Font.GothamMedium)
	label.Position = UDim2.new(0, 10, 0, 6)
	label.Size = UDim2.new(1, -20, 0, 12)

	local input = create("TextBox", {
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.GothamMedium,
		PlaceholderColor3 = THEME.muted,
		PlaceholderText = "Config name",
		Position = UDim2.new(0, 10, 0, 24),
		Size = UDim2.new(1, -108, 0, 20),
		Text = "",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(input, 4)
	addStroke(input, THEME.border, 0.35, 1)

	local saveButton = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(1, -10, 0, 24),
		Size = UDim2.new(0, 86, 0, 20),
		Text = "SAVE CFG",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(saveButton, 4)
	addStroke(saveButton, THEME.border, 0.35, 1)

	miniHudLabels.utility.configNameInput = input
	miniHudLabels.utility.saveNamedConfig = saveButton
	miniHudLabels.utility.configNameRow = row
end

do
	local row = createRow(pages.control, 124)

	local title = makeLabel(row, "SAVED CONFIG LIST", 10, THEME.muted, Enum.Font.GothamMedium)
	title.Position = UDim2.new(0, 10, 0, 6)
	title.Size = UDim2.new(0, 120, 0, 12)

	local count = create("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -10, 0, 6),
		Size = UDim2.new(0, 62, 0, 16),
		Font = Enum.Font.GothamBold,
		Text = "0 SAVES",
		TextColor3 = THEME.muted,
		TextSize = 8,
		Parent = row,
	})
	addCorner(count, 999)

	local list = create("ScrollingFrame", {
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0, 10, 0, 28),
		ScrollBarImageColor3 = THEME.border,
		ScrollBarThickness = 4,
		Size = UDim2.new(1, -20, 1, -36),
		Parent = row,
	})

	create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = list,
	})

	miniHudLabels.utility.configListRow = row
	miniHudLabels.utility.configList = list
	miniHudLabels.utility.configListCount = count
end

do
	local row = createRow(pages.control, 30)
	local resetPos = create("TextButton", {
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(0, 10, 0.5, -10),
		Size = UDim2.new(0.31, -4, 0, 20),
		Text = "RST UI",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(resetPos, 4)
	addStroke(resetPos, THEME.border, 0.35, 1)

	local resetDisplay = create("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(0.5, 0, 0.5, -10),
		Size = UDim2.new(0.31, -4, 0, 20),
		Text = "RST DSP",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(resetDisplay, 4)
	addStroke(resetDisplay, THEME.border, 0.35, 1)

	local resetView = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(1, -10, 0.5, -10),
		Size = UDim2.new(0.31, -4, 0, 20),
		Text = "RST VIEW",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(resetView, 4)
	addStroke(resetView, THEME.border, 0.35, 1)

	miniHudLabels.utility.resetPositions = resetPos
	miniHudLabels.utility.resetDisplay = resetDisplay
	miniHudLabels.utility.resetView = resetView
end

do
	local row = createRow(pages.control, 30)
	local resetPerf = create("TextButton", {
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(0, 10, 0.5, -10),
		Size = UDim2.new(1, -20, 0, 20),
		Text = "RESET PERFORMANCE DEFAULTS",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(resetPerf, 4)
	addStroke(resetPerf, THEME.border, 0.35, 1)
	miniHudLabels.utility.resetPerformance = resetPerf
end

do
	local utilityToneMap = {
		{ button = miniHudLabels.utility.antiAfk, accent = THEME.focus, tone = Color3.fromRGB(29, 34, 45) },
		{ button = miniHudLabels.utility.autoLoadGamePreset, accent = nil, tone = Color3.fromRGB(24, 29, 39) },
		{ button = miniHudLabels.saveStatusValue, accent = nil, tone = Color3.fromRGB(21, 25, 34) },
		{ button = miniHudLabels.utility.rejoin, accent = THEME.accent, tone = Color3.fromRGB(30, 34, 45) },
		{ button = miniHudLabels.utility.hop, accent = nil, tone = Color3.fromRGB(24, 29, 39) },
		{ button = miniHudLabels.utility.emptyHop, accent = THEME.focus, tone = Color3.fromRGB(29, 34, 45) },
		{ button = miniHudLabels.utility.respawn, accent = THEME.accent, tone = Color3.fromRGB(30, 34, 45) },
		{ button = miniHudLabels.utility.tools, accent = nil, tone = Color3.fromRGB(24, 29, 39) },
		{ button = miniHudLabels.utility.resetPositions, accent = THEME.border, tone = Color3.fromRGB(29, 34, 45) },
		{ button = miniHudLabels.utility.resetDisplay, accent = nil, tone = Color3.fromRGB(24, 29, 39) },
		{ button = miniHudLabels.utility.resetView, accent = nil, tone = Color3.fromRGB(21, 25, 34) },
		{ button = miniHudLabels.utility.resetPerformance, accent = THEME.muted, tone = Color3.fromRGB(29, 34, 45) },
		{ button = miniHudLabels.utility.exportConfig, accent = THEME.accent, tone = Color3.fromRGB(30, 34, 45) },
		{ button = miniHudLabels.utility.importConfig, accent = nil, tone = Color3.fromRGB(24, 29, 39) },
		{ button = miniHudLabels.utility.saveNamedConfig, accent = THEME.accent, tone = Color3.fromRGB(30, 34, 45) },
		{ button = miniHudLabels.utility.configListCount, accent = THEME.focus, tone = Color3.fromRGB(24, 29, 39) },
	}

	for _, entry in ipairs(utilityToneMap) do
		local row = entry.button and entry.button.Parent
		miniHudLabels.utility.utilityRowStyler(row, entry.accent, entry.tone)
	end
end

do
	local row = createRow(pages.control, 30)
	local rejoin = create("TextButton", {
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(0, 10, 0.5, -10),
		Size = UDim2.new(0.31, -4, 0, 20),
		Text = "REJOIN",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(rejoin, 4)
	addStroke(rejoin, THEME.border, 0.35, 1)

	local hop = create("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(0.5, 0, 0.5, -10),
		Size = UDim2.new(0.31, -4, 0, 20),
		Text = "SERVER HOP",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(hop, 4)
	addStroke(hop, THEME.border, 0.35, 1)

	local emptyHop = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(1, -10, 0.5, -10),
		Size = UDim2.new(0.31, -4, 0, 20),
		Text = "EMPTY HOP",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(emptyHop, 4)
	addStroke(emptyHop, THEME.border, 0.35, 1)

	miniHudLabels.utility.rejoin = rejoin
	miniHudLabels.utility.hop = hop
	miniHudLabels.utility.emptyHop = emptyHop
end

do
	local row = createRow(pages.control, 30)
	local respawn = create("TextButton", {
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(0, 10, 0.5, -10),
		Size = UDim2.new(0.48, -6, 0, 20),
		Text = "RESPAWN",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(respawn, 4)
	addStroke(respawn, THEME.border, 0.35, 1)

	local tools = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(1, -10, 0.5, -10),
		Size = UDim2.new(0.48, -6, 0, 20),
		Text = "RESET TOOLS",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(tools, 4)
	addStroke(tools, THEME.border, 0.35, 1)

	miniHudLabels.utility.respawn = respawn
	miniHudLabels.utility.tools = tools
end

do
	miniHudLabels.utility.teamCheckRow.Parent = miniHudLabels.utility.controlTabs.generalPage
	miniHudLabels.utility.quickHideRow.Parent = miniHudLabels.utility.controlTabs.generalPage
	miniHudLabels.utility.controls.enabledToggle.Parent.Parent = miniHudLabels.utility.controlTabs.generalPage
	miniHudLabels.utility.controls.presetDropdown.row.Parent = miniHudLabels.utility.controlTabs.generalPage
	if miniHudLabels.utility.updatePanel.row then
		miniHudLabels.utility.updatePanel.row.Parent = miniHudLabels.utility.controlTabs.generalPage
	end
	miniHudLabels.utility.controls.cameraFovSlider.bar.Parent.Parent = miniHudLabels.utility.controlTabs.generalPage
	miniHudLabels.utility.controls.cameraFovSlider.reset.Parent.Parent = miniHudLabels.utility.controlTabs.generalPage
	miniHudLabels.utility.controls.miniHudToggle.Parent.Parent = miniHudLabels.utility.controlTabs.generalPage
	miniHudLabels.utility.controls.minimalToggle.Parent.Parent = miniHudLabels.utility.controlTabs.generalPage

	miniHudLabels.utility.antiAfk.Parent.Parent = miniHudLabels.utility.controlTabs.utilityPage
	miniHudLabels.utility.utilityTabRow.Parent = miniHudLabels.utility.controlTabs.utilityPage
	miniHudLabels.utility.utilityTabBody.Parent = miniHudLabels.utility.controlTabs.utilityPage
	miniHudLabels.utility.utilitySections.session.Parent = miniHudLabels.utility.utilityTabs.sessionPage
	miniHudLabels.utility.antiAfk.Parent.Parent = miniHudLabels.utility.utilityTabs.sessionPage
	miniHudLabels.utility.autoLoadGamePreset.Parent.Parent = miniHudLabels.utility.utilityTabs.sessionPage
	miniHudLabels.saveStatusValue.Parent.Parent = miniHudLabels.utility.utilityTabs.sessionPage
	miniHudLabels.utility.utilitySections.actions.Parent = miniHudLabels.utility.utilityTabs.actionsPage
	miniHudLabels.utility.rejoin.Parent.Parent = miniHudLabels.utility.utilityTabs.actionsPage
	miniHudLabels.utility.hop.Parent.Parent = miniHudLabels.utility.utilityTabs.actionsPage
	miniHudLabels.utility.emptyHop.Parent.Parent = miniHudLabels.utility.utilityTabs.actionsPage
	miniHudLabels.utility.respawn.Parent.Parent = miniHudLabels.utility.utilityTabs.actionsPage
	miniHudLabels.utility.tools.Parent.Parent = miniHudLabels.utility.utilityTabs.actionsPage
	miniHudLabels.utility.utilitySections.overlays.Parent = miniHudLabels.utility.utilityTabs.resetsPage
	miniHudLabels.utility.resetPositions.Parent.Parent = miniHudLabels.utility.utilityTabs.resetsPage
	miniHudLabels.utility.resetDisplay.Parent.Parent = miniHudLabels.utility.utilityTabs.resetsPage
	miniHudLabels.utility.resetView.Parent.Parent = miniHudLabels.utility.utilityTabs.resetsPage
	miniHudLabels.utility.resetPerformance.Parent.Parent = miniHudLabels.utility.utilityTabs.resetsPage
	miniHudLabels.utility.utilitySections.config.Parent = miniHudLabels.utility.utilityTabs.configsPage
	miniHudLabels.utility.exportConfig.Parent.Parent = miniHudLabels.utility.utilityTabs.configsPage
	miniHudLabels.utility.importConfig.Parent.Parent = miniHudLabels.utility.utilityTabs.configsPage
	miniHudLabels.utility.configNameRow.Parent = miniHudLabels.utility.utilityTabs.configsPage
	miniHudLabels.utility.configListRow.Parent = miniHudLabels.utility.utilityTabs.configsPage
	miniHudLabels.utility.setUtilityTab("session")
	miniHudLabels.utility.setControlTab("general")
end

local function refreshNamedConfigList()
	local list = miniHudLabels.utility.configList
	if not list then
		return
	end

	for _, child in ipairs(list:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end

	local names = getConfigSlotNames()
	if miniHudLabels.utility.configListCount then
		miniHudLabels.utility.configListCount.Text = string.format("%d SAVES", #names)
		miniHudLabels.utility.configListCount.TextColor3 = #names > 0 and THEME.text or THEME.muted
	end

	if #names == 0 then
		local emptyLabel = makeLabel(list, "No named configs saved", 9, THEME.muted, Enum.Font.GothamMedium)
		emptyLabel.Size = UDim2.new(1, 0, 0, 18)
		return
	end

	for _, slotName in ipairs(names) do
		local row = create("Frame", {
			BackgroundColor3 = Color3.fromRGB(24, 29, 39),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 22),
			Parent = list,
		})
		addCorner(row, 6)
		addStroke(row, THEME.border, 0.45, 1)

		local nameLabel = makeLabel(row, truncateText(slotName, 20), 9, THEME.text, Enum.Font.GothamBold)
		nameLabel.Position = UDim2.new(0, 8, 0, 0)
		nameLabel.Size = UDim2.new(1, -118, 1, 0)

		local deleteButton = create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			AutoButtonColor = false,
			BackgroundColor3 = Color3.fromRGB(86, 39, 39),
			BorderSizePixel = 0,
			Position = UDim2.new(1, -6, 0.5, 0),
			Size = UDim2.new(0, 34, 0, 16),
			Font = Enum.Font.GothamBold,
			Text = "DEL",
			TextColor3 = THEME.text,
			TextSize = 8,
			Parent = row,
		})
		addCorner(deleteButton, 999)

		local loadButton = create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			AutoButtonColor = false,
			BackgroundColor3 = THEME.accentSoft,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -44, 0.5, 0),
			Size = UDim2.new(0, 34, 0, 16),
			Font = Enum.Font.GothamBold,
			Text = "LOAD",
			TextColor3 = THEME.text,
			TextSize = 8,
			Parent = row,
		})
		addCorner(loadButton, 999)

		loadButton.MouseButton1Click:Connect(function()
			local success, reason = loadConfigSlot(slotName)
			if not success then
				showToast("Settings", reason or "Load failed", THEME.muted)
				refreshNamedConfigList()
				return
			end

			syncUiFromConfig()
			applyCameraFov()
			applyZoomLimitSetting()
			applyPerformanceSettings()
			refreshAllEsp()
			saveSettings()
			showToast("Settings", string.format("%s loaded", slotName), THEME.accent)
		end)

		deleteButton.MouseButton1Click:Connect(function()
			local success, reason = deleteConfigSlot(slotName)
			if not success then
				showToast("Settings", reason or "Delete failed", THEME.muted)
				return
			end

			refreshNamedConfigList()
			showToast("Settings", string.format("%s deleted", slotName), THEME.muted)
		end)
	end
end

miniHudLabels.utility.displayToggles = {
	names = select(2, createToggleRow(pages.display, "NAME ABOVE HEAD", CONFIG.showNames)),
	distance = select(2, createToggleRow(pages.display, "SHOW DISTANCE", CONFIG.showDistance)),
	fade = select(2, createToggleRow(pages.display, "DISTANCE FADE", CONFIG.distanceFade)),
	health = select(2, createToggleRow(pages.display, "SHOW HEALTH", CONFIG.showHealth)),
	weapon = select(2, createToggleRow(pages.display, "SHOW WEAPON", CONFIG.showWeapon)),
	skeleton = select(2, createToggleRow(pages.display, "SKELETON ESP", CONFIG.showSkeleton)),
	headDot = select(2, createToggleRow(pages.display, "HEAD DOT", CONFIG.showHeadDot)),
	headDotSize = createSliderRow(pages.display, "HEAD DOT SIZE", CONFIG.headDotSize, 2, 12),
	focus = select(2, createToggleRow(pages.display, "FOCUS TARGET", CONFIG.showFocusTarget)),
	boxes = select(2, createToggleRow(pages.display, "BOX ESP", CONFIG.showBoxes)),
	boxMode = select(2, createCycleRow(pages.display, "BOX MODE", CONFIG.boxMode)),
	fillTransparency = createSliderRow(pages.display, "CHAMS FILL", math.floor(CONFIG.fillTransparency * 100 + 0.5), 0, 100),
	outlineTransparency = createSliderRow(pages.display, "CHAMS OUTLINE", math.floor(CONFIG.outlineTransparency * 100 + 0.5), 0, 100),
}
miniHudLabels.utility.displayToggles.targetCard = select(2, createToggleRow(pages.display, "TARGET CARD", CONFIG.showTargetCard))
miniHudLabels.utility.displayToggles.targetCardCompact = select(2, createToggleRow(pages.display, "COMPACT TARGET CARD", CONFIG.targetCardCompact))
miniHudLabels.utility.displayToggles.textStack = select(2, createCycleRow(pages.display, "TEXT STACK", CONFIG.textStackMode))

do
	miniHudLabels.utility.displayToggles.names.Parent.Parent = displayButtons.labelsPage
	miniHudLabels.utility.displayToggles.distance.Parent.Parent = displayButtons.labelsPage
	miniHudLabels.utility.displayToggles.fade.Parent.Parent = displayButtons.labelsPage
	miniHudLabels.utility.displayToggles.health.Parent.Parent = displayButtons.labelsPage
	miniHudLabels.utility.displayToggles.weapon.Parent.Parent = displayButtons.labelsPage
	miniHudLabels.utility.displayToggles.skeleton.Parent.Parent = displayButtons.labelsPage
	miniHudLabels.utility.displayToggles.headDot.Parent.Parent = displayButtons.labelsPage
	miniHudLabels.utility.displayToggles.headDotSize.bar.Parent.Parent = displayButtons.labelsPage
	miniHudLabels.utility.displayToggles.focus.Parent.Parent = displayButtons.labelsPage

	miniHudLabels.utility.displayToggles.boxes.Parent.Parent = displayButtons.boxesPage
	miniHudLabels.utility.displayToggles.boxMode.Parent.Parent = displayButtons.boxesPage
	miniHudLabels.utility.displayToggles.fillTransparency.bar.Parent.Parent = displayButtons.boxesPage
	miniHudLabels.utility.displayToggles.outlineTransparency.bar.Parent.Parent = displayButtons.boxesPage

	miniHudLabels.utility.displayToggles.targetCard.Parent.Parent = displayButtons.cardsPage
	miniHudLabels.utility.displayToggles.targetCardCompact.Parent.Parent = displayButtons.cardsPage
	miniHudLabels.utility.displayToggles.textStack.Parent.Parent = displayButtons.cardsPage
	displayButtons.setTab("labels")
end

tracerSliders.visibilityToggle = select(2, createToggleRow(pages.combat, "VISIBILITY CHECK", CONFIG.visibilityCheck))
tracerSliders.tracersToggle = select(2, createToggleRow(pages.combat, "TRACERS", CONFIG.showTracers))
tracerSliders.tracerOriginButton = select(2, createCycleRow(pages.combat, "TRACER ORIGIN", CONFIG.tracerOriginMode))
tracerSliders.style = select(2, createCycleRow(pages.combat, "TRACER STYLE", CONFIG.tracerStyle))
do
	local row = createRow(pages.combat, 76)
	row.BackgroundColor3 = THEME.panelAlt
	tracerSliders.targetCard = row
	row.AnchorPoint = Vector2.zero
	row.Position = UDim2.new(0, 0, 0, 0)
	row.Size = UDim2.new(0, 228, 0, 76)
	row.Visible = false
	row.ZIndex = 12
	row.Parent = gui

	local label = makeLabel(row, "TARGET", 9, THEME.muted, Enum.Font.GothamBold)
	label.Position = UDim2.new(0, 10, 0, 6)
	label.Size = UDim2.new(0, 70, 0, 10)
	label.ZIndex = 13

	tracerSliders.targetInfo = makeLabel(row, "NONE", 12, THEME.text, Enum.Font.GothamBold)
	tracerSliders.targetInfo.Position = UDim2.new(0, 10, 0, 18)
	tracerSliders.targetInfo.Size = UDim2.new(1, -20, 0, 14)
	tracerSliders.targetInfo.TextXAlignment = Enum.TextXAlignment.Left
	tracerSliders.targetInfo.TextTruncate = Enum.TextTruncate.AtEnd
	tracerSliders.targetInfo.ZIndex = 13

	tracerSliders.targetInfoMeta = makeLabel(row, "No focus target", 9, THEME.muted, Enum.Font.GothamMedium)
	tracerSliders.targetInfoMeta.Position = UDim2.new(0, 10, 0, 36)
	tracerSliders.targetInfoMeta.Size = UDim2.new(1, -20, 0, 10)
	tracerSliders.targetInfoMeta.TextXAlignment = Enum.TextXAlignment.Left
	tracerSliders.targetInfoMeta.TextTruncate = Enum.TextTruncate.AtEnd
	tracerSliders.targetInfoMeta.ZIndex = 13

	tracerSliders.targetInfoMeta2 = makeLabel(row, "--", 9, THEME.muted, Enum.Font.GothamMedium)
	tracerSliders.targetInfoMeta2.Position = UDim2.new(0, 10, 0, 50)
	tracerSliders.targetInfoMeta2.Size = UDim2.new(1, -20, 0, 10)
	tracerSliders.targetInfoMeta2.TextXAlignment = Enum.TextXAlignment.Left
	tracerSliders.targetInfoMeta2.TextTruncate = Enum.TextTruncate.AtEnd
	tracerSliders.targetInfoMeta2.ZIndex = 13

	tracerSliders.targetBadge = create("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(1, -10, 0, 10),
		Size = UDim2.new(0, 92, 0, 18),
		Text = "NO LOCK",
		TextColor3 = THEME.muted,
		TextSize = 8,
		ZIndex = 13,
		Parent = row,
	})
	addCorner(tracerSliders.targetBadge, 999)
	addStroke(tracerSliders.targetBadge, THEME.border, 0.35, 1)

	if overlayTools then
		overlayTools.makeOverlayDraggable(row, "targetCard")
	end
end

function setRowEnabled(target, enabled)
	local row = target
	if target and target:IsA("GuiObject") and target.Parent and target.Parent:IsA("GuiObject") and target.Parent.BackgroundTransparency ~= 1 then
		row = target.Parent
	end
	if not row or not row:IsA("GuiObject") then
		return
	end

	row.BackgroundTransparency = enabled and 0 or 0.35
	for _, descendant in ipairs(row:GetDescendants()) do
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
			local baseTransparency = descendant:GetAttribute("BaseTextTransparency")
			if baseTransparency == nil then
				baseTransparency = descendant.TextTransparency
				descendant:SetAttribute("BaseTextTransparency", baseTransparency)
			end
			descendant.TextTransparency = enabled and baseTransparency or math.min(1, baseTransparency + 0.38)
		elseif descendant:IsA("UIStroke") then
			local baseTransparency = descendant:GetAttribute("BaseTransparency")
			if baseTransparency == nil then
				baseTransparency = descendant.Transparency
				descendant:SetAttribute("BaseTransparency", baseTransparency)
			end
			descendant.Transparency = enabled and baseTransparency or math.min(1, baseTransparency + 0.35)
		end
	end
end
tracerSliders.focusLock = select(2, createToggleRow(pages.combat, "FOCUS LOCK", CONFIG.focusLock))
tracerSliders.threatMode = select(2, createCycleRow(pages.combat, "THREAT MODE", CONFIG.threatMode))
tracerSliders.thickness = createSliderRow(pages.combat, "TRACER THICKNESS", CONFIG.tracerThickness, 1, 4)
tracerSliders.transparency = createSliderRow(pages.combat, "TRACER TRANSPARENCY", CONFIG.tracerTransparency, 20, 100)
tracerSliders.lookDirectionToggle = select(2, createToggleRow(pages.combat, "LOOK DIRECTION", CONFIG.showLookDirection))
tracerSliders.maxDistance = createSliderRow(pages.combat, "MAX DISTANCE", CONFIG.maxDistance, 250, 5000)
tracerSliders.fovCircleSlider = createSliderRow(pages.combat, "FOV CIRCLE", CONFIG.fovRadius, 60, 300)
tracerSliders.fovThickness = createSliderRow(pages.combat, "FOV THICKNESS", CONFIG.fovCircleThickness, 1, 4)
tracerSliders.fovTransparency = createSliderRow(pages.combat, "FOV TRANSPARENCY", CONFIG.fovCircleTransparency, 10, 100)
tracerSliders.fovCircleSlider.reset = select(2, createCycleRow(pages.combat, "RESET CIRCLE", "DEFAULT"))
tracerSliders.crosshairToggle = select(2, createToggleRow(pages.combat, "CROSSHAIR", CONFIG.showCrosshair))
tracerSliders.crosshairStyleButton = select(2, createCycleRow(pages.combat, "CROSSHAIR STYLE", CONFIG.crosshairStyle))
local crosshairColorButtons = select(2, createOptionButtonsRow(pages.combat, "CROSSHAIR COLOR", { "White", "Blue", "Green", "Red", "Yellow", "Pink" }, CONFIG.crosshairColor))
tracerSliders.crosshairThickness = createSliderRow(pages.combat, "CROSSHAIR THICKNESS", CONFIG.crosshairThickness, 1, 4)
tracerSliders.crosshairSizeSlider = createSliderRow(pages.combat, "CROSSHAIR SIZE", CONFIG.crosshairSize, CROSSHAIR_SIZE_OPTIONS[1], CROSSHAIR_SIZE_OPTIONS[#CROSSHAIR_SIZE_OPTIONS])
tracerSliders.crosshairGap = createSliderRow(pages.combat, "CROSSHAIR GAP", CONFIG.crosshairGap, 0, 10)
tracerSliders.fovCircleToggle = select(2, createToggleRow(pages.combat, "FOV CIRCLE VISIBLE", CONFIG.showFovCircle))
tracerSliders.trainingStatus = select(2, createStatusRow(pages.combat, "AIM TRAINER", "OFF"))
tracerSliders.trainingCardsRow, tracerSliders.trainingCards = createTrainerCardsRow(pages.combat)
tracerSliders.trainingResultsRow, tracerSliders.trainingResults = createTrainerResultsRow(pages.combat)
tracerSliders.trainingHistoryRow, tracerSliders.trainingHistory = createTrainerHistoryRow(pages.combat)
tracerSliders.trainingToggle = select(2, createToggleRow(pages.combat, "TRAINER MODE", CONFIG.aimTrainerMode))
tracerSliders.trainingPresetButtons = select(2, createOptionButtonsRow(pages.combat, "TRAIN PRESET", { "Warmup", "Precision", "Tracking", "Speed", "Micro Adjust", "Custom 1", "Custom 2" }, "Warmup"))
tracerSliders.trainingSaveButtons = select(2, createOptionButtonsRow(pages.combat, "SAVE CUSTOM", { "Custom 1", "Custom 2" }, nil))
do
	local row = createRow(pages.combat, 52)
	local label = makeLabel(row, "CUSTOM SLOT", 10, THEME.muted, Enum.Font.GothamMedium)
	label.Position = UDim2.new(0, 10, 0, 6)
	label.Size = UDim2.new(0, 92, 0, 12)

	tracerSliders.trainingRenameInput = create("TextBox", {
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.GothamMedium,
		PlaceholderColor3 = THEME.muted,
		PlaceholderText = "Name",
		Position = UDim2.new(0, 10, 0, 24),
		Size = UDim2.new(0, 114, 0, 20),
		Text = "",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(tracerSliders.trainingRenameInput, 4)
	addStroke(tracerSliders.trainingRenameInput, THEME.border, 0.35, 1)

	tracerSliders.trainingBadgeInput = create("TextBox", {
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.GothamMedium,
		PlaceholderColor3 = THEME.muted,
		PlaceholderText = "Badge",
		Position = UDim2.new(0, 130, 0, 24),
		Size = UDim2.new(0, 68, 0, 20),
		Text = "",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(tracerSliders.trainingBadgeInput, 4)
	addStroke(tracerSliders.trainingBadgeInput, THEME.border, 0.35, 1)

	tracerSliders.trainingRenameButtons = {}
	for index, slotName in ipairs({ "Custom 1", "Custom 2" }) do
		local button = create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			AutoButtonColor = false,
			BackgroundColor3 = Color3.fromRGB(35, 40, 53),
			BorderSizePixel = 0,
			Position = UDim2.new(1, -(10 + ((2 - index) * 52)), 0.5, 8),
			Size = UDim2.new(0, 48, 0, 20),
			Font = Enum.Font.GothamBold,
			Text = index == 1 and "SLOT 1" or "SLOT 2",
			TextColor3 = slotName == "Custom 1" and Color3.fromRGB(162, 129, 255) or Color3.fromRGB(255, 154, 76),
			TextSize = 8,
			Parent = row,
		})
		addCorner(button, 4)
		addStroke(button, THEME.border, 0.35, 1)
		tracerSliders.trainingRenameButtons[slotName] = button
	end

	tracerSliders.trainingRenameRow = row
end
tracerSliders.trainingDrillType = select(2, createCycleRow(pages.combat, "DRILL TYPE", CONFIG.trainerDrillType))
tracerSliders.trainingReactionToggle = select(2, createToggleRow(pages.combat, "REACTION TIMER", CONFIG.trainerReactionTimer))
tracerSliders.trainingHitWindow = createSliderRow(pages.combat, "HIT WINDOW", CONFIG.trainerHitWindow, 8, 40)
tracerSliders.trainingChallengeToggle = select(2, createToggleRow(pages.combat, "TIMED CHALLENGE", CONFIG.trainerChallengeMode))
tracerSliders.trainingChallengeDuration = createSliderRow(pages.combat, "CHALLENGE LENGTH", CONFIG.trainerChallengeDuration, 15, 90)
tracerSliders.trainingShrinkingToggle = select(2, createToggleRow(pages.combat, "SHRINKING TARGETS", CONFIG.trainerShrinkingTargets))
tracerSliders.trainingTrackHoldTime = createSliderRow(pages.combat, "TRACK HOLD", CONFIG.trainerTrackHoldTime, 1, 5)
tracerSliders.trainingTargetSpeed = createSliderRow(pages.combat, "TARGET SPEED", CONFIG.trainerTargetSpeed, 40, 220)
tracerSliders.trainingReset = select(2, createCycleRow(pages.combat, "RESET DRILL", "NOW"))
tracerSliders.recoilVisualizerToggle = select(2, createToggleRow(pages.combat, "RECOIL VISUALIZER", CONFIG.recoilVisualizer))
tracerSliders.spreadVisualizerToggle = select(2, createToggleRow(pages.combat, "SPREAD VISUALIZER", CONFIG.spreadVisualizer))

do
	tracerSliders.focusLock.Parent.Parent = tracerSliders.tabs.targetingPage
	tracerSliders.threatMode.Parent.Parent = tracerSliders.tabs.targetingPage
	tracerSliders.maxDistance.bar.Parent.Parent = tracerSliders.tabs.targetingPage
	tracerSliders.visibilityToggle.Parent.Parent = tracerSliders.tabs.targetingPage
	tracerSliders.lookDirectionToggle.Parent.Parent = tracerSliders.tabs.targetingPage

	tracerSliders.tracersToggle.Parent.Parent = tracerSliders.tabs.tracersPage
	tracerSliders.tracerOriginButton.Parent.Parent = tracerSliders.tabs.tracersPage
	tracerSliders.style.Parent.Parent = tracerSliders.tabs.tracersPage
	tracerSliders.thickness.bar.Parent.Parent = tracerSliders.tabs.tracersPage
	tracerSliders.transparency.bar.Parent.Parent = tracerSliders.tabs.tracersPage

	tracerSliders.fovCircleSlider.bar.Parent.Parent = tracerSliders.tabs.crosshairPage
	tracerSliders.fovCircleToggle.Parent.Parent = tracerSliders.tabs.crosshairPage
	tracerSliders.fovThickness.bar.Parent.Parent = tracerSliders.tabs.crosshairPage
	tracerSliders.fovTransparency.bar.Parent.Parent = tracerSliders.tabs.crosshairPage
	tracerSliders.fovCircleSlider.reset.Parent.Parent = tracerSliders.tabs.crosshairPage
	tracerSliders.crosshairToggle.Parent.Parent = tracerSliders.tabs.crosshairPage
	tracerSliders.crosshairStyleButton.Parent.Parent = tracerSliders.tabs.crosshairPage
	crosshairColorButtons[1].button.Parent.Parent.Parent = tracerSliders.tabs.crosshairPage
	tracerSliders.crosshairThickness.bar.Parent.Parent = tracerSliders.tabs.crosshairPage
	tracerSliders.crosshairSizeSlider.bar.Parent.Parent = tracerSliders.tabs.crosshairPage
	tracerSliders.crosshairGap.bar.Parent.Parent = tracerSliders.tabs.crosshairPage
	tracerSliders.trainingStatus.Parent.Parent = tracerSliders.tabs.trainerPage
	tracerSliders.trainingCardsRow.Parent = tracerSliders.tabs.trainerPage
	tracerSliders.trainingResultsRow.Parent = tracerSliders.tabs.trainerPage
	tracerSliders.trainingHistoryRow.Parent = tracerSliders.tabs.trainerPage
	tracerSliders.trainingToggle.Parent.Parent = tracerSliders.tabs.trainerPage
	tracerSliders.trainingPresetButtons[1].button.Parent.Parent.Parent = tracerSliders.tabs.trainerPage
	tracerSliders.trainingSaveButtons[1].button.Parent.Parent.Parent = tracerSliders.tabs.trainerPage
	tracerSliders.trainingRenameRow.Parent = tracerSliders.tabs.trainerPage
	tracerSliders.trainingDrillType.Parent.Parent = tracerSliders.tabs.trainerPage
	tracerSliders.trainingReactionToggle.Parent.Parent = tracerSliders.tabs.trainerPage
	tracerSliders.trainingHitWindow.bar.Parent.Parent = tracerSliders.tabs.trainerPage
	tracerSliders.trainingChallengeToggle.Parent.Parent = tracerSliders.tabs.trainerPage
	tracerSliders.trainingChallengeDuration.bar.Parent.Parent = tracerSliders.tabs.trainerPage
	tracerSliders.trainingShrinkingToggle.Parent.Parent = tracerSliders.tabs.trainerPage
	tracerSliders.trainingTrackHoldTime.bar.Parent.Parent = tracerSliders.tabs.trainerPage
	tracerSliders.trainingTargetSpeed.bar.Parent.Parent = tracerSliders.tabs.trainerPage
	tracerSliders.trainingReset.Parent.Parent = tracerSliders.tabs.trainerPage
	tracerSliders.recoilVisualizerToggle.Parent.Parent = tracerSliders.tabs.trainerPage
	tracerSliders.spreadVisualizerToggle.Parent.Parent = tracerSliders.tabs.trainerPage
	tracerSliders.setCombatTab("targeting")
end

miniHudLabels.bindTooltip(miniHudLabels.utility.displayToggles.boxes, "Turns all box and chams ESP on or off without losing your selected box style.")
miniHudLabels.bindTooltip(miniHudLabels.utility.displayToggles.boxMode, "Cycles the box style used when box ESP is enabled, including chams.")
miniHudLabels.bindTooltip(miniHudLabels.utility.displayToggles.fillTransparency.bar, "Sets the fill strength used by the chams-based box modes.")
miniHudLabels.bindTooltip(miniHudLabels.utility.displayToggles.outlineTransparency.bar, "Sets the outline strength used by the chams-based box modes.")
miniHudLabels.bindTooltip(miniHudLabels.utility.displayToggles.headDotSize.bar, "Controls how small or aggressive the head dot marker appears.")
miniHudLabels.bindTooltip(tracerSliders.visibilityToggle, "Uses line-of-sight checks so visible enemies can be styled differently from hidden ones.")
miniHudLabels.bindTooltip(tracerSliders.tracerOriginButton, "Changes where tracers start: bottom of screen, center, or your crosshair.")
miniHudLabels.bindTooltip(tracerSliders.style, "Direct draws a straight line, Split adds a segmented tactical snapline.")
miniHudLabels.bindTooltip(tracerSliders.focusLock, "Keeps the current focus target locked until it becomes invalid or leaves range.")
miniHudLabels.bindTooltip(tracerSliders.threatMode, "Controls how the script chooses the priority target: closest, visible, armed, or smart.")
miniHudLabels.bindTooltip(tracerSliders.maxDistance.bar, "Sets the maximum distance where ESP elements will render.")
miniHudLabels.bindTooltip(tracerSliders.crosshairThickness.bar, "Adjusts the thickness of the custom crosshair lines.")
miniHudLabels.bindTooltip(tracerSliders.crosshairGap.bar, "Controls the spacing between the crosshair center and its outer lines.")
miniHudLabels.bindTooltip(tracerSliders.fovThickness.bar, "Adjusts the outline thickness of the FOV circle.")
miniHudLabels.bindTooltip(tracerSliders.fovTransparency.bar, "Controls how visible or faint the FOV circle appears.")
miniHudLabels.bindTooltip(miniHudLabels.utility.antiAfk, "Prevents Roblox from marking you idle by simulating local input when the idle prompt appears.")
miniHudLabels.bindTooltip(miniHudLabels.utility.controls.enabledToggle, "Master switch for the entire ESP suite.")
miniHudLabels.bindTooltip(miniHudLabels.utility.controls.presetDropdown.button, function()
	local preset = PRESETS[currentPresetIndex]
	return string.format("%s: %s", preset.name, preset.description or "Quick setup preset.")
end)
miniHudLabels.bindTooltip(miniHudLabels.utility.teamCheckValue, "Friendly players are always excluded from hostile ESP logic.")
miniHudLabels.bindTooltip(miniHudLabels.utility.quickHideValue, "Temporarily hides or shows the main menu and mini HUD.")
miniHudLabels.bindTooltip(miniHudLabels.utility.controls.cameraFovSlider.bar, "Adjusts the local camera field of view.")
miniHudLabels.bindTooltip(miniHudLabels.utility.controls.cameraFovSlider.reset, "Resets the camera field of view to the Roblox default.")
miniHudLabels.bindTooltip(miniHudLabels.utility.controls.miniHudToggle, "Shows or hides the floating combat telemetry widget.")
miniHudLabels.bindTooltip(miniHudLabels.utility.controls.minimalToggle, "Uses a cleaner stripped-down presentation across the whole script UI.")
miniHudLabels.bindTooltip(miniHudLabels.utility.autoLoadGamePreset, "Loads place-specific saved settings when available.")
miniHudLabels.bindTooltip(miniHudLabels.saveStatusValue, "Persistent settings save to file. Session-only controls never write here.")
miniHudLabels.bindTooltip(miniHudLabels.utility.exportConfig, "Copies the current saved configuration into a portable JSON string.")
miniHudLabels.bindTooltip(miniHudLabels.utility.importConfig, "Loads a configuration from clipboard or the last exported session string.")
miniHudLabels.bindTooltip(miniHudLabels.utility.configNameInput, "Type any config name here. Saving to an existing name overwrites it.")
miniHudLabels.bindTooltip(miniHudLabels.utility.saveNamedConfig, "Saves the current settings under the typed config name.")
miniHudLabels.bindTooltip(miniHudLabels.utility.configListCount, "Shows how many named configs are currently saved on disk.")
miniHudLabels.bindTooltip(miniHudLabels.utility.resetPositions, "Moves the mini HUD, keybind panel, and target card back to their default positions.")
miniHudLabels.bindTooltip(miniHudLabels.utility.resetDisplay, "Restores visual ESP presentation settings to their defaults.")
miniHudLabels.bindTooltip(miniHudLabels.utility.resetView, "Restores camera, spectate, and freecam view settings.")
miniHudLabels.bindTooltip(miniHudLabels.utility.resetPerformance, "Restores local performance options to their default state.")
miniHudLabels.bindTooltip(miniHudLabels.utility.rejoin, "Reconnects you to the current server instance.")
miniHudLabels.bindTooltip(miniHudLabels.utility.hop, "Finds another open public server in this place.")
miniHudLabels.bindTooltip(miniHudLabels.utility.emptyHop, "Finds the emptiest public server available in this place.")
miniHudLabels.bindTooltip(miniHudLabels.utility.respawn, "Reloads your local character if the game allows it.")
miniHudLabels.bindTooltip(miniHudLabels.utility.tools, "Attempts to unequip and clear local tool state.")
miniHudLabels.bindTooltip(miniHudLabels.utility.displayToggles.names, "Shows the player name above tracked characters.")
miniHudLabels.bindTooltip(miniHudLabels.utility.displayToggles.distance, "Shows how far each tracked player is from you.")
miniHudLabels.bindTooltip(miniHudLabels.utility.displayToggles.fade, "Makes ESP less opaque as distance increases.")
miniHudLabels.bindTooltip(miniHudLabels.utility.displayToggles.health, "Displays current health and health bars in ESP labels.")
miniHudLabels.bindTooltip(miniHudLabels.utility.displayToggles.weapon, "Shows the held tool or weapon name when detected.")
miniHudLabels.bindTooltip(miniHudLabels.utility.displayToggles.skeleton, "Draws a skeleton overlay on tracked players.")
miniHudLabels.bindTooltip(miniHudLabels.utility.displayToggles.headDot, "Adds a dot marker over enemy heads.")
miniHudLabels.bindTooltip(miniHudLabels.utility.displayToggles.focus, "Shows and highlights the script's chosen priority target.")
miniHudLabels.bindTooltip(miniHudLabels.utility.displayToggles.targetCard, "Shows the draggable target telemetry card for the current focus target.")
miniHudLabels.bindTooltip(miniHudLabels.utility.displayToggles.targetCardCompact, "Uses a shorter target card layout with less secondary detail.")
miniHudLabels.bindTooltip(miniHudLabels.utility.displayToggles.textStack, "Inline keeps labels on one line. Stacked splits info into multiple lines.")
miniHudLabels.bindTooltip(tracerSliders.tracersToggle, "Master switch for all tracer rendering.")
miniHudLabels.bindTooltip(tracerSliders.thickness.bar, "Adjusts tracer line width.")
miniHudLabels.bindTooltip(tracerSliders.transparency.bar, "Controls how strong or faint tracers appear.")
miniHudLabels.bindTooltip(tracerSliders.lookDirectionToggle, "Adds a direction arrow for the active focus target.")
miniHudLabels.bindTooltip(tracerSliders.fovCircleSlider.bar, "Sets the crosshair-centered FOV circle radius.")
miniHudLabels.bindTooltip(tracerSliders.fovCircleSlider.reset, "Resets the FOV circle radius to its default.")
miniHudLabels.bindTooltip(tracerSliders.crosshairToggle, "Shows the custom mouse-following crosshair.")
miniHudLabels.bindTooltip(tracerSliders.crosshairStyleButton, "Changes the crosshair shape.")
miniHudLabels.bindTooltip(crosshairColorButtons[1].button.Parent.Parent, "Selects the color used for the custom crosshair and FOV circle.")
miniHudLabels.bindTooltip(tracerSliders.crosshairSizeSlider.bar, "Adjusts the overall size of the custom crosshair.")
miniHudLabels.bindTooltip(tracerSliders.fovCircleToggle, "Shows or hides the FOV circle independently of the crosshair.")
miniHudLabels.bindTooltip(tracerSliders.trainingStatus, "Shows live trainer timing and hit stats while practice mode is active.")
miniHudLabels.bindTooltip(tracerSliders.trainingCards.click.frame, "Click drill card tracks acquisition speed, accuracy, misses, and click streaks.")
miniHudLabels.bindTooltip(tracerSliders.trainingCards.track.frame, "Track drill card tracks hover completions, hold stability, break rate, and tracking streaks.")
miniHudLabels.bindTooltip(tracerSliders.trainingResultsRow, "Shows the latest timed challenge result with a short breakdown of your run.")
miniHudLabels.bindTooltip(tracerSliders.trainingHistoryRow, "Keeps a short session-only history of your most recent timed challenge runs.")
miniHudLabels.bindTooltip(tracerSliders.trainingPresetButtons[1].button.Parent.Parent, "One-click drill setups for warmup, precision practice, and dedicated tracking.")
miniHudLabels.bindTooltip(tracerSliders.trainingSaveButtons[1].button.Parent.Parent, "Saves your current trainer settings into one of the custom slots.")
miniHudLabels.bindTooltip(tracerSliders.trainingRenameRow, "Set a custom slot name and badge, then assign them to Custom 1 or Custom 2.")
miniHudLabels.bindTooltip(tracerSliders.trainingToggle, "Enables visual-only aim training drills inside the crosshair page.")
miniHudLabels.bindTooltip(tracerSliders.trainingDrillType, "Click mode is for target acquisition. Track mode is for holding your cursor over a moving target.")
miniHudLabels.bindTooltip(tracerSliders.trainingReactionToggle, "Measures your time from target spawn to successful click.")
miniHudLabels.bindTooltip(tracerSliders.trainingHitWindow.bar, "Controls how close your click must be to count as a hit.")
miniHudLabels.bindTooltip(tracerSliders.trainingChallengeToggle, "Starts a timed drill using the selected challenge length.")
miniHudLabels.bindTooltip(tracerSliders.trainingChallengeDuration.bar, "Sets how long each timed challenge lasts.")
miniHudLabels.bindTooltip(tracerSliders.trainingShrinkingToggle, "Makes targets get smaller as your hit count increases.")
miniHudLabels.bindTooltip(tracerSliders.trainingTrackHoldTime.bar, "In Track mode, this is how long you must keep your cursor over the target to score.")
miniHudLabels.bindTooltip(tracerSliders.trainingTargetSpeed.bar, "Controls how fast the training target moves around the screen.")
miniHudLabels.bindTooltip(tracerSliders.trainingReset, "Clears aim trainer stats and respawns a fresh target.")
miniHudLabels.bindTooltip(tracerSliders.recoilVisualizerToggle, "Shows a temporary recoil kick marker after each click.")
miniHudLabels.bindTooltip(tracerSliders.spreadVisualizerToggle, "Shows an expanding spread ring that blooms on click and decays.")

viewButtons = {
	status = select(2, createStatusRow(pages.player, "STATUS", "LOCAL")),
	spectate = createSpectateRow(pages.player),
	nav = {},
	freeCam = select(2, createToggleRow(pages.player, "FREE CAM", false)),
	removeZoomLimit = select(2, createToggleRow(pages.player, "REMOVE ZOOM LIMIT", CONFIG.removeZoomLimit)),
	speed = createSliderRow(pages.player, "FREECAM SPEED", CONFIG.freeCamSpeed, 24, 160),
	reset = select(2, createCycleRow(pages.player, "RESET VIEW", "DEFAULT")),
}

playerButtons = {
	tabs = {},
	status = nil,
	walkSpeedToggle = nil,
	walkSpeed = nil,
	infiniteJump = nil,
	noclip = nil,
	fly = nil,
	flySpeed = nil,
	clickTeleport = nil,
	reset = nil,
}

miniHudLabels.bindTooltip(viewButtons.removeZoomLimit, "Removes the default local camera zoom cap so you can scroll farther out.")
miniHudLabels.bindTooltip(viewButtons.status, "Shows whether you are on local view, spectating, or in freecam.")
miniHudLabels.bindTooltip(viewButtons.spectate.main, "Open the player list to spectate another character.")
miniHudLabels.bindTooltip(viewButtons.spectate.off, "Immediately return from spectate to your own camera.")
miniHudLabels.bindTooltip(viewButtons.freeCam, "Toggles scriptable freecam with independent movement controls.")
miniHudLabels.bindTooltip(viewButtons.speed.bar, "Sets the movement speed used while freecam is active.")
miniHudLabels.bindTooltip(viewButtons.reset, "Restores freecam, spectate, and view settings.")
miniHudLabels.bindTooltip(viewButtons.nav.prev, "Step to the previous player in the spectate list.")
miniHudLabels.bindTooltip(viewButtons.nav.next, "Step to the next player in the spectate list.")

playerButtons.tabs = createSubTabGroup(pages.player, playerButtons.tabs, {
	{ key = "view", label = "VIEW", width = 82 },
	{ key = "player", label = "PLAYER", width = 88 },
}, "view")
playerButtons.setTab = playerButtons.tabs.setTab

do
	local row = createRow(pages.player, 30)
	local prev = create("TextButton", {
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(0, 10, 0.5, -10),
		Size = UDim2.new(0.48, -6, 0, 20),
		Text = "PREV",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(prev, 4)
	addStroke(prev, THEME.border, 0.35, 1)

	local nextButton = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(1, -10, 0.5, -10),
		Size = UDim2.new(0.48, -6, 0, 20),
		Text = "NEXT",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(nextButton, 4)
	addStroke(nextButton, THEME.border, 0.35, 1)

	viewButtons.nav.prev = prev
	viewButtons.nav.next = nextButton
end

playerButtons.status = select(2, createStatusRow(pages.player, "MOVEMENT", "SESSION"))
playerButtons.walkSpeedToggle = select(2, createToggleRow(pages.player, "WALK SPEED", CONFIG.walkSpeedEnabled))
playerButtons.walkSpeed = createSliderRow(pages.player, "WALK SPEED VALUE", CONFIG.walkSpeed, 16, 100)
playerButtons.infiniteJump = select(2, createToggleRow(pages.player, "INFINITE JUMP", CONFIG.infiniteJump))
playerButtons.noclip = select(2, createToggleRow(pages.player, "NOCLIP", CONFIG.noclip))
playerButtons.fly = select(2, createToggleRow(pages.player, "FLY", CONFIG.fly))
playerButtons.flySpeed = createSliderRow(pages.player, "FLY SPEED", CONFIG.flySpeed, 24, 140)
playerButtons.clickTeleport = select(2, createToggleRow(pages.player, "CTRL + CLICK TP", CONFIG.clickTeleport))
playerButtons.reset = select(2, createCycleRow(pages.player, "RESET PLAYER", "DEFAULT"))

do
	viewButtons.status.Parent.Parent = playerButtons.tabs.viewPage
	viewButtons.spectate.main.Parent.Parent = playerButtons.tabs.viewPage
	viewButtons.freeCam.Parent.Parent = playerButtons.tabs.viewPage
	viewButtons.removeZoomLimit.Parent.Parent = playerButtons.tabs.viewPage
	viewButtons.speed.bar.Parent.Parent = playerButtons.tabs.viewPage
	viewButtons.reset.Parent.Parent = playerButtons.tabs.viewPage
	viewButtons.nav.prev.Parent.Parent = playerButtons.tabs.viewPage

	playerButtons.status.Parent.Parent = playerButtons.tabs.playerPage
	playerButtons.walkSpeedToggle.Parent.Parent = playerButtons.tabs.playerPage
	playerButtons.walkSpeed.bar.Parent.Parent = playerButtons.tabs.playerPage
	playerButtons.infiniteJump.Parent.Parent = playerButtons.tabs.playerPage
	playerButtons.noclip.Parent.Parent = playerButtons.tabs.playerPage
	playerButtons.fly.Parent.Parent = playerButtons.tabs.playerPage
	playerButtons.flySpeed.bar.Parent.Parent = playerButtons.tabs.playerPage
	playerButtons.clickTeleport.Parent.Parent = playerButtons.tabs.playerPage
	playerButtons.reset.Parent.Parent = playerButtons.tabs.playerPage
	playerButtons.setTab("view")
end

miniHudLabels.bindTooltip(playerButtons.walkSpeedToggle, "Override your local walk speed with the value below.")
miniHudLabels.bindTooltip(playerButtons.walkSpeed.bar, "Set the local movement speed used when walk speed override is enabled.")
miniHudLabels.bindTooltip(playerButtons.infiniteJump, "Lets the local humanoid jump again while already airborne.")
miniHudLabels.bindTooltip(playerButtons.noclip, "Disables collisions on your local character so you can phase through parts.")
miniHudLabels.bindTooltip(playerButtons.fly, "Enables upright flight with hover hold. Use WASD, Space, LeftControl, Shift to boost, and LeftAlt for precision.")
miniHudLabels.bindTooltip(playerButtons.flySpeed.bar, "Sets the base movement speed used while flight is enabled.")
miniHudLabels.bindTooltip(playerButtons.clickTeleport, "Hold LeftControl and click to teleport to the cursor position.")
miniHudLabels.bindTooltip(playerButtons.status, "Shows which local movement utilities are currently active.")
miniHudLabels.bindTooltip(playerButtons.reset, "Restores local movement settings to their default values for this session.")

miniHudLabels.utility.performanceToggles = {
	mode = select(2, createToggleRow(pages.performance, "PERF BOOST", CONFIG.performanceMode)),
	materials = select(2, createToggleRow(pages.performance, "LOW MATERIALS", CONFIG.simplifyMaterials)),
	textures = select(2, createToggleRow(pages.performance, "HIDE TEXTURES", CONFIG.hideTextures)),
	effects = select(2, createToggleRow(pages.performance, "HIDE EFFECTS", CONFIG.hideEffects)),
	shadows = select(2, createToggleRow(pages.performance, "DISABLE SHADOWS", CONFIG.disableShadows)),
}
miniHudLabels.bindTooltip(miniHudLabels.utility.performanceToggles.mode, "Enables the full local performance preset by turning on all visual cuts together.")
miniHudLabels.bindTooltip(miniHudLabels.utility.performanceToggles.materials, "Simplifies part materials to reduce visual overhead.")
miniHudLabels.bindTooltip(miniHudLabels.utility.performanceToggles.textures, "Hides decals and textures locally.")
miniHudLabels.bindTooltip(miniHudLabels.utility.performanceToggles.effects, "Disables particles, beams, trails, and similar visual effects locally.")
miniHudLabels.bindTooltip(miniHudLabels.utility.performanceToggles.shadows, "Turns off lighting shadows locally for a cleaner performance profile.")

local espObjects = {}
local drawingSupported = DRAWING_SUPPORT.line
local focusedPlayer = nil
miniHudLabels.utility.targetTelemetry = {}
local performanceCache = {
	parts = {},
	textures = {},
	effects = {},
	lighting = nil,
}
local crosshairObjects = {}
local fovCircleObject
miniHudLabels.utility.trainer = miniHudLabels.utility.trainer or {
	targetPosition = nil,
	targetSpawnAt = 0,
	lastReactionMs = nil,
	bestReactionMs = nil,
	hits = 0,
	misses = 0,
	clickHits = 0,
	clickMisses = 0,
	clickTotalMs = 0,
	clickBestMs = nil,
	clickStreak = 0,
	clickBestStreak = 0,
	trackHits = 0,
	trackBreaks = 0,
	trackTotalMs = 0,
	trackBestMs = nil,
	trackStreak = 0,
	trackBestStreak = 0,
	challengeEndsAt = nil,
	lastResults = nil,
	history = {},
	holdProgress = 0,
	targetVelocity = Vector2.new(110, 76),
	spreadValue = 0,
	recoilKick = 0,
	recoilOffset = Vector2.zero,
}

local function ensureTrainerState()
	if not miniHudLabels or not miniHudLabels.utility then
		return nil
	end

	if type(miniHudLabels.utility.trainer) ~= "table" then
		miniHudLabels.utility.trainer = {}
	end

	local trainer = miniHudLabels.utility.trainer
	trainer.targetPosition = typeof(trainer.targetPosition) == "Vector2" and trainer.targetPosition or nil
	trainer.targetSpawnAt = tonumber(trainer.targetSpawnAt) or 0
	trainer.lastReactionMs = tonumber(trainer.lastReactionMs)
	trainer.bestReactionMs = tonumber(trainer.bestReactionMs)
	trainer.hits = tonumber(trainer.hits) or 0
	trainer.misses = tonumber(trainer.misses) or 0
	trainer.clickHits = tonumber(trainer.clickHits) or 0
	trainer.clickMisses = tonumber(trainer.clickMisses) or 0
	trainer.clickTotalMs = tonumber(trainer.clickTotalMs) or 0
	trainer.clickBestMs = tonumber(trainer.clickBestMs)
	trainer.clickStreak = tonumber(trainer.clickStreak) or 0
	trainer.clickBestStreak = tonumber(trainer.clickBestStreak) or 0
	trainer.trackHits = tonumber(trainer.trackHits) or 0
	trainer.trackBreaks = tonumber(trainer.trackBreaks) or 0
	trainer.trackTotalMs = tonumber(trainer.trackTotalMs) or 0
	trainer.trackBestMs = tonumber(trainer.trackBestMs)
	trainer.trackStreak = tonumber(trainer.trackStreak) or 0
	trainer.trackBestStreak = tonumber(trainer.trackBestStreak) or 0
	trainer.challengeEndsAt = tonumber(trainer.challengeEndsAt)
	trainer.lastResults = type(trainer.lastResults) == "table" and trainer.lastResults or nil
	trainer.history = type(trainer.history) == "table" and trainer.history or {}
	trainer.holdProgress = tonumber(trainer.holdProgress) or 0
	trainer.targetVelocity = typeof(trainer.targetVelocity) == "Vector2" and trainer.targetVelocity or Vector2.new(110, 76)
	trainer.spreadValue = tonumber(trainer.spreadValue) or 0
	trainer.recoilKick = tonumber(trainer.recoilKick) or 0
	trainer.recoilOffset = typeof(trainer.recoilOffset) == "Vector2" and trainer.recoilOffset or Vector2.zero
	return trainer
end

ensureTrainerState()
if type(loadedTrainerRecords) == "table" then
	miniHudLabels.utility.trainer.clickBestMs = loadedTrainerRecords.clickBestMs
	miniHudLabels.utility.trainer.clickBestStreak = loadedTrainerRecords.clickBestStreak or 0
	miniHudLabels.utility.trainer.trackBestMs = loadedTrainerRecords.trackBestMs
	miniHudLabels.utility.trainer.trackBestStreak = loadedTrainerRecords.trackBestStreak or 0
end
if type(loadedTrainerCustomPresets) == "table" then
	for slotName in pairs(TRAINER_CUSTOM_PRESETS) do
		if type(loadedTrainerCustomPresets[slotName]) == "table" then
			if loadedTrainerCustomPresets[slotName].settings ~= nil or loadedTrainerCustomPresets[slotName].label ~= nil then
				TRAINER_CUSTOM_PRESETS[slotName] = {
					label = loadedTrainerCustomPresets[slotName].label or slotName,
					badge = loadedTrainerCustomPresets[slotName].badge or (slotName == "Custom 1" and "USER 1" or "USER 2"),
					settings = loadedTrainerCustomPresets[slotName].settings,
				}
			else
				TRAINER_CUSTOM_PRESETS[slotName] = {
					label = slotName,
					badge = slotName == "Custom 1" and "USER 1" or "USER 2",
					settings = loadedTrainerCustomPresets[slotName],
				}
			end
		end
	end
end
local viewState = {
	spectateTarget = nil,
	freeCamEnabled = false,
	freeCamCFrame = nil,
	freeCamYaw = 0,
	freeCamPitch = 0,
	lookHeld = false,
	moveForward = 0,
	moveRight = 0,
	moveUp = 0,
	controls = nil,
	humanoidState = nil,
	flyVelocity = nil,
	flyLookVector = nil,
	defaultWalkSpeed = nil,
	walkSpeedChangedConnection = nil,
	defaultMinZoomDistance = nil,
	defaultMaxZoomDistance = nil,
	lockedFocusTarget = nil,
}

local function isSameTeam(player)
	if not LOCAL_PLAYER then
		return false
	end

	if LOCAL_PLAYER.Team ~= nil and player.Team ~= nil then
		return LOCAL_PLAYER.Team == player.Team
	end

	if not LOCAL_PLAYER.Neutral and not player.Neutral and LOCAL_PLAYER.TeamColor and player.TeamColor then
		return LOCAL_PLAYER.TeamColor == player.TeamColor
	end

	return false
end

local function getTeamColor(player)
	if player.Team and player.Team.TeamColor then
		return player.Team.TeamColor.Color
	end

	if player.TeamColor then
		return player.TeamColor.Color
	end

	return CONFIG.fallbackEspColor
end

local function getEspColor(player)
	return getTeamColor(player)
end

local function getEffectiveBoxMode()
	if (CONFIG.boxMode == "2D Box" or CONFIG.boxMode == "Health Box" or CONFIG.boxMode == "Head Box") and not DRAWING_SUPPORT.square then
		return "Chams"
	end

	if (CONFIG.boxMode == "Corner Box" or CONFIG.boxMode == "3D Box" or CONFIG.boxMode == "3D Corner" or CONFIG.boxMode == "Health Box") and not DRAWING_SUPPORT.line then
		return "Chams"
	end

	if not CONFIG.showBoxes then
		return nil
	end

	return CONFIG.boxMode
end

function isChamsBoxMode(mode)
	return mode == "Chams"
		or mode == "Flat Chams"
		or mode == "Outline Chams"
		or mode == "Split Chams"
end

local function isFocusedTarget(player)
	return CONFIG.showFocusTarget and focusedPlayer == player
end

local function getTracerColor(player)
	return getEspColor(player)
end

local function getHeldToolName(character)
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Tool") then
			return child.Name
		end
	end

	return nil
end

local function getMovementState(character, root)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local velocity = root and root.AssemblyLinearVelocity or Vector3.zero
	local planarSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude

	if humanoid then
		if humanoid.FloorMaterial == Enum.Material.Air then
			return velocity.Y > 1 and "Jumping" or "Falling"
		end
		if planarSpeed > 18 then
			return "Sprinting"
		end
		if planarSpeed > 2 then
			return "Moving"
		end
	end

	return "Idle"
end

local function getTargetThreatData(player, character, root, localRoot, visible, nearbyThreats, heldTool)
	nearbyThreats = nearbyThreats or 0
	local distance = localRoot and (root.Position - localRoot.Position).Magnitude or math.huge
	local distanceFactor = 0
	if distance < math.huge then
		distanceFactor = math.clamp((CONFIG.maxDistance - distance) / math.max(CONFIG.maxDistance, 1), 0, 1)
	end

	heldTool = heldTool or getHeldToolName(character)
	local aimingAtYou = false
	if localRoot then
		local toLocal = (localRoot.Position - root.Position)
		if toLocal.Magnitude > 0.001 then
			aimingAtYou = root.CFrame.LookVector:Dot(toLocal.Unit) >= 0.82
		end
	end

	local telemetry = miniHudLabels.utility.targetTelemetry[player] or {}
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local healthRatio = humanoid and humanoid.MaxHealth > 0 and math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1) or 1
	local dangerScore = math.floor(
		(distanceFactor * 35)
		+ ((visible and 1 or 0) * 25)
		+ ((heldTool and 1 or 0) * 20)
		+ ((aimingAtYou and 1 or 0) * 15)
		+ (nearbyThreats * 5)
		+ ((1 - healthRatio) * 10)
	)

	telemetry.visible = visible
	telemetry.weapon = heldTool
	telemetry.movementState = getMovementState(character, root)
	telemetry.aimingAtYou = aimingAtYou
	telemetry.groupDanger = nearbyThreats
	telemetry.dangerScore = dangerScore
	miniHudLabels.utility.targetTelemetry[player] = telemetry
	return telemetry
end

local function buildPortableConfigPayload()
	local payload = {
		currentPresetIndex = currentPresetIndex,
		placeId = game.PlaceId,
		settings = {},
	}

	for _, key in ipairs(SETTING_KEYS) do
		if key == "boxMode" then
			payload.settings[key] = normalizeBoxMode(CONFIG[key])
		else
			payload.settings[key] = CONFIG[key]
		end
	end

	return payload
end

local function exportConfigString()
	local payload = buildPortableConfigPayload()

	return HttpService:JSONEncode(payload)
end

local function applyImportedConfig(payload)
	if type(payload) ~= "table" or type(payload.settings) ~= "table" then
		return false
	end

	for _, key in ipairs(SETTING_KEYS) do
		if payload.settings[key] ~= nil then
			if key == "boxMode" then
				CONFIG[key] = normalizeBoxMode(payload.settings[key])
			else
				CONFIG[key] = payload.settings[key]
			end
		end
	end

	if payload.currentPresetIndex and PRESETS[payload.currentPresetIndex] then
		currentPresetIndex = payload.currentPresetIndex
	end

	return true
end

local function loadConfigSlotStore()
	if not canUseFileApi() or not isfile(CONFIG_SLOTS_FILE) then
		return { slots = {} }
	end

	local success, decoded = pcall(function()
		return HttpService:JSONDecode(readfile(CONFIG_SLOTS_FILE))
	end)

	if success and type(decoded) == "table" then
		decoded.slots = type(decoded.slots) == "table" and decoded.slots or {}
		return decoded
	end

	return { slots = {} }
end

local function saveConfigSlotStore(store)
	if not canUseFileApi() then
		return false
	end

	local success = pcall(function()
		writefile(CONFIG_SLOTS_FILE, HttpService:JSONEncode(store))
	end)

	return success
end

local function saveConfigSlot(slotName)
	if not canUseFileApi() then
		return false, "File API unavailable"
	end

	local store = loadConfigSlotStore()
	store.slots[slotName] = {
		payload = buildPortableConfigPayload(),
		savedAt = os.time(),
	}

	if not saveConfigSlotStore(store) then
		return false, "Write failed"
	end

	return true
end

deleteConfigSlot = function(slotName)
	if not canUseFileApi() then
		return false, "File API unavailable"
	end

	local store = loadConfigSlotStore()
	if type(store.slots[slotName]) ~= "table" then
		return false, "Config not found"
	end

	store.slots[slotName] = nil
	if not saveConfigSlotStore(store) then
		return false, "Write failed"
	end

	return true
end

loadConfigSlot = function(slotName)
	if not canUseFileApi() then
		return false, "File API unavailable"
	end

	local store = loadConfigSlotStore()
	local slot = store.slots[slotName]
	local payload = slot and slot.payload or nil
	if type(payload) ~= "table" then
		return false, "Slot empty"
	end

	if not applyImportedConfig(payload) then
		return false, "Config invalid"
	end

	return true
end

getConfigSlotNames = function()
	local store = loadConfigSlotStore()
	local names = {}

	for slotName, slot in pairs(store.slots) do
		if type(slotName) == "string" and type(slot.payload) == "table" then
			table.insert(names, slotName)
		end
	end

	table.sort(names, function(a, b)
		return a:lower() < b:lower()
	end)

	return names
end

local function normalizeConfigSlotName(name)
	if type(name) ~= "string" then
		return nil
	end

	local trimmed = name:match("^%s*(.-)%s*$")
	if not trimmed or trimmed == "" then
		return nil
	end

	if #trimmed > 36 then
		trimmed = trimmed:sub(1, 36)
	end

	return trimmed
end

local function resetDisplaySettings()
	CONFIG.showNames = true
	CONFIG.showDistance = true
	CONFIG.distanceFade = true
	CONFIG.showHealth = true
	CONFIG.showWeapon = true
	CONFIG.showSkeleton = false
	CONFIG.showHeadDot = false
	CONFIG.headDotSize = 6
	CONFIG.showFocusTarget = true
	CONFIG.showBoxes = true
	CONFIG.boxMode = "Chams"
	CONFIG.showTargetCard = true
	CONFIG.targetCardCompact = false
	CONFIG.textStackMode = "Inline"
end

local function resetViewSettings()
	CONFIG.cameraFov = DEFAULT_CAMERA_FOV
	CONFIG.freeCamSpeed = 72
	CONFIG.removeZoomLimit = false
	CONFIG.spectateMode = "Direct"
	CONFIG.cameraRigPreset = "Mid"
end

local function resetPlayerSettings()
	CONFIG.walkSpeedEnabled = false
	CONFIG.walkSpeed = 24
	CONFIG.infiniteJump = false
	CONFIG.noclip = false
	CONFIG.fly = false
	CONFIG.flySpeed = 72
	CONFIG.clickTeleport = false
end

local function resetPerformanceSettings()
	CONFIG.performanceMode = false
	CONFIG.simplifyMaterials = false
	CONFIG.hideTextures = false
	CONFIG.hideEffects = false
	CONFIG.disableShadows = false
end

local function isEnemyCandidate(player)
	if player == LOCAL_PLAYER then
		return false
	end

	if isSameTeam(player) then
		return false
	end

	return true
end

local function isDevPlayer(player)
	return player and player.UserId == DEV_USER_ID
end

local function shouldTrackPlayer(player)
	if player == LOCAL_PLAYER then
		return false
	end

	return isEnemyCandidate(player) or isDevPlayer(player)
end

local function getCamera()
	return workspace.CurrentCamera
end

local function getLocalHumanoid()
	local character = LOCAL_PLAYER and LOCAL_PLAYER.Character
	return character and character:FindFirstChildOfClass("Humanoid") or nil
end

local function getLocalRoot()
	local character = LOCAL_PLAYER and LOCAL_PLAYER.Character
	return character and getCharacterRoot(character) or nil
end

local function applyPlayerMovementState()
	local character = LOCAL_PLAYER and LOCAL_PLAYER.Character
	local humanoid = getLocalHumanoid()
	local root = getLocalRoot()
	if not character or not humanoid or not root or viewState.freeCamEnabled then
		return
	end

	if viewState.defaultWalkSpeed == nil then
		viewState.defaultWalkSpeed = humanoid.WalkSpeed
	end

	if CONFIG.walkSpeedEnabled then
		if humanoid.WalkSpeed ~= CONFIG.walkSpeed then
			humanoid.WalkSpeed = CONFIG.walkSpeed
		end
	end

	if not CONFIG.fly and humanoid.AutoRotate == false then
		humanoid.AutoRotate = true
	end

	if CONFIG.noclip then
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Blacklist
		params.FilterDescendantsInstances = { character }
		params.IgnoreWater = true
		local floorResult = workspace:Raycast(root.Position, Vector3.new(0, -4.5, 0), params)

		for _, descendant in ipairs(character:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.CanCollide = false
			end
		end

		if floorResult and root.AssemblyLinearVelocity.Y <= 0 and not UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			local targetY = floorResult.Position.Y + humanoid.HipHeight + (root.Size.Y * 0.5) + 0.05
			if root.Position.Y < targetY + 0.35 then
				root.CFrame = CFrame.fromMatrix(
					Vector3.new(root.Position.X, targetY, root.Position.Z),
					root.CFrame.XVector,
					root.CFrame.YVector,
					root.CFrame.ZVector
				)
				root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, math.max(0, root.AssemblyLinearVelocity.Y), root.AssemblyLinearVelocity.Z)
			end
		end
	end
end

local function stopFly()
	local humanoid = getLocalHumanoid()
	local root = getLocalRoot()
	if humanoid then
		humanoid.PlatformStand = false
		humanoid.AutoRotate = true
		pcall(function()
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end)
		pcall(function()
			humanoid:ChangeState(Enum.HumanoidStateType.Running)
		end)
	end
	if root then
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end
	viewState.flyVelocity = Vector3.zero
	viewState.flyLookVector = nil
	viewState.moveForward = 0
	viewState.moveRight = 0
	viewState.moveUp = 0
end

local function resetDefaultMovementCache()
	local humanoid = getLocalHumanoid()
	viewState.defaultWalkSpeed = humanoid and humanoid.WalkSpeed or nil
end

local function bindLocalMovementSignals(humanoid)
	if viewState.walkSpeedChangedConnection then
		viewState.walkSpeedChangedConnection:Disconnect()
		viewState.walkSpeedChangedConnection = nil
	end

	if not humanoid then
		viewState.defaultWalkSpeed = nil
		return
	end

	viewState.defaultWalkSpeed = humanoid.WalkSpeed
	viewState.walkSpeedChangedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if not CONFIG.walkSpeedEnabled and not viewState.freeCamEnabled and not viewState.humanoidState then
			viewState.defaultWalkSpeed = humanoid.WalkSpeed
		end
	end)
end

activeSliderDrag = nil

function setActiveSliderDrag(onUpdate, onRelease)
	activeSliderDrag = {
		update = onUpdate,
		release = onRelease,
	}
end

function clearActiveSliderDrag()
	if activeSliderDrag and activeSliderDrag.release then
		activeSliderDrag.release()
	end
	activeSliderDrag = nil
end

function bindSliderDragStart(guiObject, updateFn, onRelease)
	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			setActiveSliderDrag(updateFn, onRelease)
			updateFn(input.Position.X)
		end
	end)
end

UserInputService.InputChanged:Connect(function(input)
	if getgenv().__VYRS_ESP_ACTIVE_TOKEN ~= gui:GetAttribute("ActiveToken") then
		return
	end

	if activeSliderDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
		activeSliderDrag.update(input.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if getgenv().__VYRS_ESP_ACTIVE_TOKEN ~= gui:GetAttribute("ActiveToken") then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 and activeSliderDrag then
		clearActiveSliderDrag()
	end
end)


local function applyZoomLimitSetting()
	if not LOCAL_PLAYER then
		return
	end

	if viewState.defaultMinZoomDistance == nil then
		viewState.defaultMinZoomDistance = LOCAL_PLAYER.CameraMinZoomDistance
	end

	if viewState.defaultMaxZoomDistance == nil then
		viewState.defaultMaxZoomDistance = LOCAL_PLAYER.CameraMaxZoomDistance
	end

	if CONFIG.removeZoomLimit then
		LOCAL_PLAYER.CameraMinZoomDistance = 0.5
		LOCAL_PLAYER.CameraMaxZoomDistance = 100000
	else
		LOCAL_PLAYER.CameraMinZoomDistance = viewState.defaultMinZoomDistance
		LOCAL_PLAYER.CameraMaxZoomDistance = viewState.defaultMaxZoomDistance
	end
end

local function setLocalMovementSuppressed(state)
	local humanoid = getLocalHumanoid()

	if state then
		if not viewState.controls then
			local success, controls = pcall(function()
				return require(LOCAL_PLAYER.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
			end)
			if success then
				viewState.controls = controls
			end
		end

		if viewState.controls then
			pcall(function()
				viewState.controls:Disable()
			end)
		end

		if humanoid then
			if not viewState.humanoidState or viewState.humanoidState.humanoid ~= humanoid then
				viewState.humanoidState = {
					humanoid = humanoid,
					walkSpeed = humanoid.WalkSpeed,
					jumpPower = humanoid.JumpPower,
					jumpHeight = humanoid.JumpHeight,
					autoRotate = humanoid.AutoRotate,
				}
			end

			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0
			humanoid.JumpHeight = 0
			humanoid.AutoRotate = false
			humanoid:Move(Vector3.zero, true)
		end
	else
		if viewState.controls then
			pcall(function()
				viewState.controls:Enable()
			end)
		end

		local cached = viewState.humanoidState
		if cached and cached.humanoid and cached.humanoid.Parent then
			cached.humanoid.WalkSpeed = cached.walkSpeed
			cached.humanoid.JumpPower = cached.jumpPower
			cached.humanoid.JumpHeight = cached.jumpHeight
			cached.humanoid.AutoRotate = cached.autoRotate
		end

		viewState.humanoidState = nil
	end
end

local function restoreLocalCamera()
	local camera = getCamera()
	if not camera then
		return
	end

	local humanoid = getLocalHumanoid()
	camera.CameraType = Enum.CameraType.Custom
	if humanoid then
		camera.CameraSubject = humanoid
	end
end

local function updateViewUi()
	if viewButtons.status then
		if viewState.freeCamEnabled then
			viewButtons.status.Text = "FREE CAM"
			viewButtons.status.TextColor3 = THEME.accent
		elseif viewState.spectateTarget then
			viewButtons.status.Text = truncateText(viewState.spectateTarget.Name, 14)
			viewButtons.status.TextColor3 = THEME.focus
		else
			viewButtons.status.Text = "LOCAL"
			viewButtons.status.TextColor3 = THEME.text
		end
	end
	if viewButtons.spectate then
		viewButtons.spectate.main.Text = viewState.spectateTarget and truncateText(viewState.spectateTarget.Name, 14) or "SELECT"
	end
	if viewButtons.freeCam then
		setToggleState(viewButtons.freeCam, viewState.freeCamEnabled)
	end
	if viewButtons.speed then
		setSliderState(viewButtons.speed, CONFIG.freeCamSpeed)
	end
	if playerButtons.status then
		local states = {}
		if CONFIG.walkSpeedEnabled then
			table.insert(states, string.format("SPD %d", CONFIG.walkSpeed))
		end
		if CONFIG.infiniteJump then
			table.insert(states, "INF JUMP")
		end
		if CONFIG.fly then
			table.insert(states, "FLY")
		end
		if CONFIG.noclip then
			table.insert(states, "NOCLIP")
		end
		if CONFIG.clickTeleport then
			table.insert(states, "CLICK TP")
		end
		playerButtons.status.Text = #states > 0 and table.concat(states, " | ") or "LOCAL"
		playerButtons.status.TextColor3 = #states > 0 and THEME.accent or THEME.text
	end
end

local function setSpectateTarget(player)
	local camera = getCamera()
	viewState.spectateTarget = player
	if viewState.freeCamEnabled then
		viewState.freeCamEnabled = false
		viewState.lookHeld = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		setLocalMovementSuppressed(false)
	end

	if camera and player and player.Character then
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = humanoid
		end
	elseif not viewState.freeCamEnabled then
		restoreLocalCamera()
	end

	updateViewUi()
end

local function toggleFreeCam()
	local camera = getCamera()
	if not camera then
		return
	end

	viewState.freeCamEnabled = not viewState.freeCamEnabled
	viewState.moveForward = 0
	viewState.moveRight = 0
	viewState.moveUp = 0

	if viewState.freeCamEnabled then
		local lookVector = camera.CFrame.LookVector
		viewState.spectateTarget = nil
		viewState.freeCamCFrame = camera.CFrame
		viewState.freeCamYaw = math.atan2(-lookVector.X, -lookVector.Z)
		viewState.freeCamPitch = math.asin(math.clamp(lookVector.Y, -1, 1))
		viewState.lookHeld = false
		setLocalMovementSuppressed(true)
		camera.CameraType = Enum.CameraType.Scriptable
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	else
		viewState.lookHeld = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		setLocalMovementSuppressed(false)
		restoreLocalCamera()
	end

	updateViewUi()
	updateMouseIconVisibility()
	if keybindController then
		keybindController.update()
	end
	showToast("View", viewState.freeCamEnabled and "Free Cam enabled" or "Free Cam disabled", viewState.freeCamEnabled and THEME.accent or THEME.muted)
end

local function applyCameraFov()
	local camera = getCamera()
	if camera and math.abs(camera.FieldOfView - CONFIG.cameraFov) > 0.05 then
		camera.FieldOfView = CONFIG.cameraFov
	end
end

function getCharacterRoot(character)
	return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
end

local function getMouseScreenPosition(camera)
	camera = camera or workspace.CurrentCamera
	if not camera then
		return nil
	end

	local viewport = camera.ViewportSize
	if not viewport then
		return nil
	end

	local mouseLocation = UserInputService:GetMouseLocation()
	if typeof(mouseLocation) == "Vector2" and mouseLocation.X == mouseLocation.X and mouseLocation.Y == mouseLocation.Y then
		return Vector2.new(
			math.clamp(mouseLocation.X, 0, viewport.X),
			math.clamp(mouseLocation.Y, 0, viewport.Y)
		)
	end

	local mouse = LOCAL_PLAYER and LOCAL_PLAYER:GetMouse()
	if mouse and tonumber(mouse.X) and tonumber(mouse.Y) then
		return Vector2.new(
			math.clamp(mouse.X, 0, viewport.X),
			math.clamp(mouse.Y, 0, viewport.Y)
		)
	end

	return Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
end

local function getTracerOrigin(camera)
	if CONFIG.tracerOriginMode == "Center" then
		return Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y * 0.5)
	end

	if CONFIG.tracerOriginMode == "Crosshair" then
		local mousePosition = getMouseScreenPosition(camera)
		if mousePosition then
			return mousePosition
		end
	end

	return Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y - 24)
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

local function restorePartAppearance(part)
	local cached = performanceCache.parts[part]
	if cached and part.Parent then
		part.Material = cached.Material
		part.Reflectance = cached.Reflectance
	end
	performanceCache.parts[part] = nil
end

local function restoreTextureAppearance(item)
	local cached = performanceCache.textures[item]
	if cached and item.Parent then
		item.Transparency = cached.Transparency
	end
	performanceCache.textures[item] = nil
end

local function restoreEffectAppearance(item)
	local cached = performanceCache.effects[item]
	if cached and item.Parent and (item:IsA("ParticleEmitter") or item:IsA("Trail") or item:IsA("Beam") or item:IsA("Smoke") or item:IsA("Fire") or item:IsA("Sparkles")) then
		item.Enabled = cached.Enabled
	end
	performanceCache.effects[item] = nil
end

local function applyPerformanceSettings()
	local performanceRequested = CONFIG.performanceMode or CONFIG.simplifyMaterials or CONFIG.hideTextures or CONFIG.hideEffects or CONFIG.disableShadows
	local hasCachedChanges = performanceCache.lighting ~= nil
		or next(performanceCache.parts) ~= nil
		or next(performanceCache.textures) ~= nil
		or next(performanceCache.effects) ~= nil

	if CONFIG.performanceMode then
		CONFIG.simplifyMaterials = true
		CONFIG.hideTextures = true
		CONFIG.hideEffects = true
		CONFIG.disableShadows = true
	end

	if not performanceRequested and not hasCachedChanges then
		return
	end

	cacheLighting()

	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant:IsA("BasePart") then
			if CONFIG.simplifyMaterials then
				if not performanceCache.parts[descendant] then
					performanceCache.parts[descendant] = {
						Material = descendant.Material,
						Reflectance = descendant.Reflectance,
					}
				end
				descendant.Material = Enum.Material.SmoothPlastic
				descendant.Reflectance = 0
			else
				restorePartAppearance(descendant)
			end
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			if CONFIG.hideTextures then
				if not performanceCache.textures[descendant] then
					performanceCache.textures[descendant] = {
						Transparency = descendant.Transparency,
					}
				end
				descendant.Transparency = 1
			else
				restoreTextureAppearance(descendant)
			end
		elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("Smoke") or descendant:IsA("Fire") or descendant:IsA("Sparkles") then
			if CONFIG.hideEffects then
				if not performanceCache.effects[descendant] then
					performanceCache.effects[descendant] = {
						Enabled = descendant.Enabled,
					}
				end
				descendant.Enabled = false
			end
		end
	end

	for item in pairs(performanceCache.parts) do
		if not item.Parent or not CONFIG.simplifyMaterials then
			restorePartAppearance(item)
		end
	end

	for item in pairs(performanceCache.textures) do
		if not item.Parent or not CONFIG.hideTextures then
			restoreTextureAppearance(item)
		end
	end

	for item, cached in pairs(performanceCache.effects) do
		if not item.Parent then
			performanceCache.effects[item] = nil
		elseif not CONFIG.hideEffects then
			item.Enabled = cached.Enabled
			performanceCache.effects[item] = nil
		end
	end

	if performanceCache.lighting then
		if CONFIG.disableShadows then
			Lighting.GlobalShadows = false
			Lighting.FogEnd = 100000
			Lighting.Brightness = math.max(Lighting.Brightness, 2)
		else
			Lighting.GlobalShadows = performanceCache.lighting.GlobalShadows
			Lighting.FogEnd = performanceCache.lighting.FogEnd
			Lighting.Brightness = performanceCache.lighting.Brightness
		end
	end
end

local function getEspEntry(player)
	local entry = espObjects[player]
	if entry then
		entry.player = player
		return entry
	end

	entry = {
		player = player,
	}
	espObjects[player] = entry
	return entry
end

local function clearEntry(entry)
	if entry.highlight then
		entry.highlight:Destroy()
		entry.highlight = nil
	end

	if entry.billboard then
		entry.billboard:Destroy()
		entry.billboard = nil
		entry.title = nil
		entry.healthBack = nil
		entry.healthFill = nil
		entry.devRing = nil
	end

	if entry.tracer then
		entry.tracer.Visible = false
		entry.tracer:Remove()
		entry.tracer = nil
	end

	if entry.tracerBranch then
		entry.tracerBranch.Visible = false
		entry.tracerBranch:Remove()
		entry.tracerBranch = nil
	end

	if entry.headDot then
		entry.headDot.Visible = false
		entry.headDot:Remove()
		entry.headDot = nil
	end

	if entry.box then
		entry.box.Visible = false
		entry.box:Remove()
		entry.box = nil
	end

	if entry.cornerLines then
		for _, line in ipairs(entry.cornerLines) do
			line.Visible = false
			line:Remove()
		end
		entry.cornerLines = nil
	end

	if entry.healthBoxLines then
		for _, line in ipairs(entry.healthBoxLines) do
			line.Visible = false
			line:Remove()
		end
		entry.healthBoxLines = nil
	end

	if entry.box3DLines then
		for _, line in ipairs(entry.box3DLines) do
			line.Visible = false
			line:Remove()
		end
		entry.box3DLines = nil
	end

	if entry.box3DCornerLines then
		for _, line in ipairs(entry.box3DCornerLines) do
			line.Visible = false
			line:Remove()
		end
		entry.box3DCornerLines = nil
	end

	if entry.skeletonLines then
		for _, line in ipairs(entry.skeletonLines) do
			line.Visible = false
			line:Remove()
		end
		entry.skeletonLines = nil
	end

	if entry.lookArrowLines then
		for _, line in ipairs(entry.lookArrowLines) do
			line.Visible = false
			line:Remove()
		end
		entry.lookArrowLines = nil
	end

end

local function clearPlayerEsp(player)
	local entry = espObjects[player]
	if not entry then
		return
	end

	clearEntry(entry)
end

local function ensureHighlight(entry, character)
	if entry.highlight and entry.highlight.Parent ~= character then
		entry.highlight:Destroy()
		entry.highlight = nil
	end

	if not entry.highlight then
		entry.highlight = Instance.new("Highlight")
		entry.highlight.Name = "CHIBU_ESP"
		entry.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		entry.highlight.Parent = character
	end

	return entry.highlight
end

local function ensureBillboard(entry, character)
	if entry.billboard and entry.billboard.Parent ~= character then
		entry.billboard:Destroy()
		entry.billboard = nil
		entry.title = nil
		entry.healthBack = nil
		entry.healthFill = nil
	end

	if not entry.billboard then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "CHIBU_INFO"
		billboard.Adornee = character:FindFirstChild("Head")
		billboard.AlwaysOnTop = true
		billboard.LightInfluence = 0
		billboard.MaxDistance = CONFIG.maxDistance
		billboard.Size = UDim2.new(0, 180, 0, 30)
		billboard.StudsOffset = Vector3.new(0, 2.8, 0)
		billboard.Parent = character

		local devRing = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = THEME.accent,
			BackgroundTransparency = 0.78,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.98, 0),
			Size = UDim2.new(0, 72, 0, 18),
			Visible = false,
			ZIndex = 0,
			Parent = billboard,
		})
		addCorner(devRing, 999)

		create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
			}),
			Rotation = 0,
			Parent = devRing,
		})

		local title = create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 0, 18),
			Text = "",
			TextColor3 = THEME.text,
			TextSize = 12,
			TextStrokeTransparency = 0.45,
			Parent = billboard,
		})

		local healthBack = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Color3.fromRGB(42, 42, 52),
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 1, -2),
			Size = UDim2.new(0, 70, 0, 4),
			Parent = billboard,
		})
		addCorner(healthBack, 999)

		local healthFill = create("Frame", {
			BackgroundColor3 = CONFIG.visibleColor,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Parent = healthBack,
		})
		addCorner(healthFill, 999)

		entry.billboard = billboard
		entry.devRing = devRing
		entry.title = title
		entry.healthBack = healthBack
		entry.healthFill = healthFill
	end

	local head = character:FindFirstChild("Head")
	if head then
		entry.billboard.Adornee = head
	end

	entry.billboard.MaxDistance = CONFIG.maxDistance
	return entry.billboard, entry.title
end

local function ensureTracer(entry)
	if not drawingSupported then
		return nil
	end

	if not entry.tracer then
		entry.tracer = createDrawing("Line")
		if not entry.tracer then
			return nil
		end
		entry.tracer.Thickness = 1.5
		entry.tracer.Transparency = 1
	end

	return entry.tracer
end

local function ensureHeadDot(entry)
	if not DRAWING_SUPPORT.square then
		return nil
	end

	if not entry.headDot then
		entry.headDot = createDrawing("Square")
		if not entry.headDot then
			return nil
		end
		entry.headDot.Filled = true
		entry.headDot.Transparency = 1
	end

	return entry.headDot
end

local function ensureBox(entry)
	if not drawingSupported then
		return nil
	end

	if not entry.box then
		entry.box = createDrawing("Square")
		if not entry.box then
			return nil
		end
		entry.box.Filled = false
		entry.box.Thickness = 1.5
		entry.box.Transparency = 1
	end

	return entry.box
end

function ensureHealthLines(entry)
	if not drawingSupported then
		return nil
	end

	if not entry.healthBoxLines then
		entry.healthBoxLines = {}
		for _ = 1, 2 do
			local line = createDrawing("Line")
			if line then
				line.Thickness = 1.5
				line.Transparency = 1
				table.insert(entry.healthBoxLines, line)
			end
		end

		if #entry.healthBoxLines ~= 2 then
			for _, line in ipairs(entry.healthBoxLines) do
				line:Remove()
			end
			entry.healthBoxLines = nil
			return nil
		end
	end

	return entry.healthBoxLines
end

local function ensureCornerLines(entry)
	if not drawingSupported then
		return nil
	end

	if not entry.cornerLines then
		entry.cornerLines = {}
		for _ = 1, 8 do
			local line = createDrawing("Line")
			if line then
				line.Thickness = 1.5
				line.Transparency = 1
				table.insert(entry.cornerLines, line)
			end
		end

		if #entry.cornerLines ~= 8 then
			for _, line in ipairs(entry.cornerLines) do
				line:Remove()
			end
			entry.cornerLines = nil
			return nil
		end
	end

	return entry.cornerLines
end

function ensureBoxLines(entry, key, count)
	if not drawingSupported then
		return nil
	end

	if not entry[key] then
		entry[key] = {}
		for _ = 1, count do
			local line = createDrawing("Line")
			if line then
				line.Thickness = 1.5
				line.Transparency = 1
				table.insert(entry[key], line)
			end
		end

		if #entry[key] ~= count then
			for _, line in ipairs(entry[key]) do
				line:Remove()
			end
			entry[key] = nil
			return nil
		end
	end

	return entry[key]
end

local function ensureSkeletonLines(entry)
	if not drawingSupported then
		return nil
	end

	if not entry.skeletonLines then
		entry.skeletonLines = {}
		for _ = 1, #SKELETON_CONNECTIONS do
			local line = createDrawing("Line")
			if line then
				line.Thickness = 1.5
				line.Transparency = 1
				table.insert(entry.skeletonLines, line)
			end
		end

		if #entry.skeletonLines ~= #SKELETON_CONNECTIONS then
			for _, line in ipairs(entry.skeletonLines) do
				line:Remove()
			end
			entry.skeletonLines = nil
			return nil
		end
	end

	return entry.skeletonLines
end

local function ensureLookArrowLines(entry)
	if not drawingSupported then
		return nil
	end

	if not entry.lookArrowLines then
		entry.lookArrowLines = {}
		for _ = 1, 3 do
			local line = createDrawing("Line")
			if line then
				line.Thickness = 1.6
				line.Transparency = 0.95
				table.insert(entry.lookArrowLines, line)
			end
		end

		if #entry.lookArrowLines ~= 3 then
			for _, line in ipairs(entry.lookArrowLines) do
				line:Remove()
			end
			entry.lookArrowLines = nil
			return nil
		end
	end

	return entry.lookArrowLines
end

local function ensureCrosshairObjects()
	if not drawingSupported then
		return nil
	end

	if not crosshairObjects.horizontal then
		crosshairObjects.horizontal = createDrawing("Line")
		crosshairObjects.vertical = createDrawing("Line")
		crosshairObjects.dot = createDrawing("Square")

		if not crosshairObjects.horizontal or not crosshairObjects.vertical or not crosshairObjects.dot then
			for _, object in pairs(crosshairObjects) do
				if object then
					object:Remove()
				end
			end
			crosshairObjects = {}
			return nil
		end

		crosshairObjects.horizontal.Thickness = CONFIG.crosshairThickness
		crosshairObjects.vertical.Thickness = CONFIG.crosshairThickness
		crosshairObjects.horizontal.Transparency = 1
		crosshairObjects.vertical.Transparency = 1
		crosshairObjects.dot.Filled = true
		crosshairObjects.dot.Transparency = 1
	end

	return crosshairObjects
end

local function ensureFovCircle()
	if not DRAWING_SUPPORT.circle then
		return nil
	end

	if not fovCircleObject then
		fovCircleObject = createDrawing("Circle")
		if not fovCircleObject then
			return nil
		end
		fovCircleObject.Filled = false
		fovCircleObject.Thickness = 1.5
		fovCircleObject.Transparency = 0.9
		fovCircleObject.NumSides = 48
	end

	return fovCircleObject
end

local function clearCrosshairObjects()
	for key, object in pairs(crosshairObjects) do
		if object then
			object.Visible = false
			object:Remove()
		end
		crosshairObjects[key] = nil
	end
end

local function hideFovCircle()
	if fovCircleObject then
		fovCircleObject.Visible = false
	end
end

local function getCrosshairColor()
	for _, option in ipairs(CROSSHAIR_COLOR_OPTIONS) do
		if option.name == CONFIG.crosshairColor then
			return option.color
		end
	end

	return THEME.text
end

local function hideCrosshair()
	clearCrosshairObjects()
	hideFovCircle()
end

local function updateMouseIconVisibility()
	local shouldShowMouseIcon = viewState.freeCamEnabled or window.Visible
	if UserInputService.MouseIconEnabled ~= shouldShowMouseIcon then
		UserInputService.MouseIconEnabled = shouldShowMouseIcon
	end
end

local function updateCrosshair()
	if not CONFIG.showCrosshair or not drawingSupported then
		hideCrosshair()
		updateMouseIconVisibility()
		return
	end

	local objects = ensureCrosshairObjects()
	if not objects then
		updateMouseIconVisibility()
		return
	end

	local camera = workspace.CurrentCamera
	if not camera then
		hideCrosshair()
		updateMouseIconVisibility()
		return
	end

	local viewport = camera.ViewportSize
	local mousePosition = getMouseScreenPosition(camera)
	if not mousePosition or not viewport then
		hideCrosshair()
		updateMouseIconVisibility()
		return
	end

	local centerX = mousePosition.X
	local centerY = mousePosition.Y
	local size = CONFIG.crosshairSize
	local gap = CONFIG.crosshairGap
	local color = getCrosshairColor()

	objects.horizontal.Color = color
	objects.vertical.Color = color
	objects.dot.Color = color
	objects.horizontal.Thickness = CONFIG.crosshairThickness
	objects.vertical.Thickness = CONFIG.crosshairThickness

	local showCross = CONFIG.crosshairStyle == "Cross" or CONFIG.crosshairStyle == "CrossDot"
	local showDot = CONFIG.crosshairStyle == "Dot" or CONFIG.crosshairStyle == "CrossDot"

	objects.horizontal.Visible = showCross
	objects.vertical.Visible = showCross
	objects.dot.Visible = showDot

	if showCross then
		objects.horizontal.From = Vector2.new(centerX - size - gap, centerY)
		objects.horizontal.To = Vector2.new(centerX + size + gap, centerY)
		objects.vertical.From = Vector2.new(centerX, centerY - size - gap)
		objects.vertical.To = Vector2.new(centerX, centerY + size + gap)
	end

	if showDot then
		objects.dot.Size = Vector2.new(4, 4)
		objects.dot.Position = Vector2.new(centerX - 2, centerY - 2)
	end

	if CONFIG.showFovCircle then
		local fovCircle = ensureFovCircle()
		if fovCircle then
			fovCircle.Visible = true
			fovCircle.Color = color
			fovCircle.Thickness = CONFIG.fovCircleThickness
			fovCircle.Position = Vector2.new(centerX, centerY)
			fovCircle.Radius = CONFIG.fovRadius
			fovCircle.Transparency = math.clamp(CONFIG.fovCircleTransparency / 100, 0.1, 1)
		else
			hideFovCircle()
		end
	else
		hideFovCircle()
	end

	updateMouseIconVisibility()
end

local function hideBoxes(entry)
	if entry.box then
		entry.box.Visible = false
	end

	if entry.cornerLines then
		for _, line in ipairs(entry.cornerLines) do
			line.Visible = false
		end
	end

	if entry.healthBoxLines then
		for _, line in ipairs(entry.healthBoxLines) do
			line.Visible = false
		end
	end

	if entry.box3DLines then
		for _, line in ipairs(entry.box3DLines) do
			line.Visible = false
		end
	end

	if entry.box3DCornerLines then
		for _, line in ipairs(entry.box3DCornerLines) do
			line.Visible = false
		end
	end
end

local function resetAllBoxEspVisuals()
	for _, entry in pairs(espObjects) do
		hideBoxes(entry)
	end
end

local function hideSkeleton(entry)
	if entry.skeletonLines then
		for _, line in ipairs(entry.skeletonLines) do
			line.Visible = false
		end
	end
end

local function getCharacterScreenBounds(camera, character)
	local cf, size = character:GetBoundingBox()
	local half = size / 2
	local corners = {
		cf * Vector3.new(-half.X, -half.Y, -half.Z),
		cf * Vector3.new(-half.X, -half.Y, half.Z),
		cf * Vector3.new(-half.X, half.Y, -half.Z),
		cf * Vector3.new(-half.X, half.Y, half.Z),
		cf * Vector3.new(half.X, -half.Y, -half.Z),
		cf * Vector3.new(half.X, -half.Y, half.Z),
		cf * Vector3.new(half.X, half.Y, -half.Z),
		cf * Vector3.new(half.X, half.Y, half.Z),
	}

	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	local visibleCorner = false

	for _, corner in ipairs(corners) do
		local point, visible = camera:WorldToViewportPoint(corner)
		if point.Z > 0 then
			visibleCorner = true
			minX = math.min(minX, point.X)
			minY = math.min(minY, point.Y)
			maxX = math.max(maxX, point.X)
			maxY = math.max(maxY, point.Y)
		end
	end

	if not visibleCorner then
		return nil
	end

	return minX, minY, maxX, maxY
end

function getPartScreenBounds(camera, part)
	if not part then
		return nil
	end

	local cf = part.CFrame
	local size = part.Size
	local half = size / 2
	local corners = {
		cf * Vector3.new(-half.X, -half.Y, -half.Z),
		cf * Vector3.new(-half.X, -half.Y, half.Z),
		cf * Vector3.new(-half.X, half.Y, -half.Z),
		cf * Vector3.new(-half.X, half.Y, half.Z),
		cf * Vector3.new(half.X, -half.Y, -half.Z),
		cf * Vector3.new(half.X, -half.Y, half.Z),
		cf * Vector3.new(half.X, half.Y, -half.Z),
		cf * Vector3.new(half.X, half.Y, half.Z),
	}

	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	local visibleCorner = false

	for _, corner in ipairs(corners) do
		local point, visible = camera:WorldToViewportPoint(corner)
		if point.Z > 0 then
			visibleCorner = true
			minX = math.min(minX, point.X)
			minY = math.min(minY, point.Y)
			maxX = math.max(maxX, point.X)
			maxY = math.max(maxY, point.Y)
		end
	end

	if not visibleCorner then
		return nil
	end

	return minX, minY, maxX, maxY
end

function getBoundingBoxViewportCorners(camera, character)
	local cf, size = character:GetBoundingBox()
	local half = size / 2
	local worldCorners = {
		cf * Vector3.new(-half.X, -half.Y, -half.Z),
		cf * Vector3.new(-half.X, -half.Y, half.Z),
		cf * Vector3.new(-half.X, half.Y, -half.Z),
		cf * Vector3.new(-half.X, half.Y, half.Z),
		cf * Vector3.new(half.X, -half.Y, -half.Z),
		cf * Vector3.new(half.X, -half.Y, half.Z),
		cf * Vector3.new(half.X, half.Y, -half.Z),
		cf * Vector3.new(half.X, half.Y, half.Z),
	}

	local projected = {}
	for index, worldCorner in ipairs(worldCorners) do
		local point = camera:WorldToViewportPoint(worldCorner)
		if point.Z <= 0 then
			return nil
		end
		projected[index] = Vector2.new(point.X, point.Y)
	end

	return projected
end

function render3DBoxEdges(lines, corners, color, thickness)
	for index, edge in ipairs(BOX_3D_EDGES) do
		local line = lines[index]
		local fromPoint = corners[edge[1]]
		local toPoint = corners[edge[2]]
		line.Visible = true
		line.Color = color
		line.Thickness = thickness
		line.From = fromPoint
		line.To = toPoint
	end
end

function render3DCornerEdges(lines, corners, color, thickness)
	local lineIndex = 1
	for _, edge in ipairs(BOX_3D_EDGES) do
		local fromPoint = corners[edge[1]]
		local toPoint = corners[edge[2]]
		local delta = toPoint - fromPoint
		local edgeLength = delta.Magnitude
		local segmentLength = edgeLength * 0.28
		if edgeLength > 0.001 then
			local direction = delta.Unit
			local firstLine = lines[lineIndex]
			firstLine.Visible = true
			firstLine.Color = color
			firstLine.Thickness = thickness
			firstLine.From = fromPoint
			firstLine.To = fromPoint + (direction * segmentLength)

			local secondLine = lines[lineIndex + 1]
			secondLine.Visible = true
			secondLine.Color = color
			secondLine.Thickness = thickness
			secondLine.From = toPoint
			secondLine.To = toPoint - (direction * segmentLength)
		else
			lines[lineIndex].Visible = false
			lines[lineIndex + 1].Visible = false
		end
		lineIndex = lineIndex + 2
	end
end

local function updateBoxEsp(entry, camera, character, color, fillColor)
	local effectiveBoxMode = getEffectiveBoxMode()

	if isChamsBoxMode(effectiveBoxMode) then
		hideBoxes(entry)
		return
	end

	local root = getCharacterRoot(character)
	local localRoot = LOCAL_PLAYER.Character and getCharacterRoot(LOCAL_PLAYER.Character)
	local distance = (root and localRoot) and (root.Position - localRoot.Position).Magnitude or CONFIG.maxDistance
	local thickness = math.clamp(2.6 - ((distance / math.max(CONFIG.maxDistance, 1)) * 1.4), 1, 2.6)
	local head = character:FindFirstChild("Head")

	local minX, minY, maxX, maxY
	if effectiveBoxMode == "Head Box" then
		if not head then
			hideBoxes(entry)
			return
		end
		minX, minY, maxX, maxY = getPartScreenBounds(camera, head)
	else
		minX, minY, maxX, maxY = getCharacterScreenBounds(camera, character)
	end

	if effectiveBoxMode ~= "3D Box" and effectiveBoxMode ~= "3D Corner" and not minX then
		hideBoxes(entry)
		return
	end

	hideBoxes(entry)

	if effectiveBoxMode == "2D Box" then
		local box = ensureBox(entry)
		if not box then
			return
		end
		box.Filled = false
		box.Thickness = thickness
		box.Visible = true
		box.Color = color
		box.Transparency = 1
		box.Position = Vector2.new(minX, minY)
		box.Size = Vector2.new(math.max(maxX - minX, 2), math.max(maxY - minY, 2))
	elseif effectiveBoxMode == "Health Box" then
		local box = ensureBox(entry)
		local healthLines = ensureHealthLines(entry)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not box or not healthLines or not humanoid then
			return
		end

		local width = math.max(maxX - minX, 2)
		local height = math.max(maxY - minY, 2)
		local healthRatio = humanoid.MaxHealth > 0 and math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1) or 1
		local healthColor = Color3.fromRGB(
			math.floor(255 - (155 * healthRatio)),
			math.floor(70 + (185 * healthRatio)),
			math.floor(88 - (32 * healthRatio))
		)

		box.Filled = false
		box.Thickness = thickness
		box.Visible = true
		box.Color = color
		box.Transparency = 1
		box.Position = Vector2.new(minX, minY)
		box.Size = Vector2.new(width, height)

		healthLines[1].Visible = true
		healthLines[1].Color = Color3.fromRGB(28, 31, 40)
		healthLines[1].Thickness = math.max(2, thickness + 0.8)
		healthLines[1].From = Vector2.new(minX - 5, minY)
		healthLines[1].To = Vector2.new(minX - 5, maxY)

		healthLines[2].Visible = true
		healthLines[2].Color = healthColor
		healthLines[2].Thickness = math.max(2, thickness)
		healthLines[2].From = Vector2.new(minX - 5, maxY)
		healthLines[2].To = Vector2.new(minX - 5, maxY - (height * healthRatio))
	elseif effectiveBoxMode == "Corner Box" then
		local lines = ensureCornerLines(entry)
		if not lines then
			return
		end

		local width = math.max(maxX - minX, 2)
		local height = math.max(maxY - minY, 2)
		local cornerWidth = width * 0.25
		local cornerHeight = height * 0.25
		local segments = {
			{ Vector2.new(minX, minY), Vector2.new(minX + cornerWidth, minY) },
			{ Vector2.new(minX, minY), Vector2.new(minX, minY + cornerHeight) },
			{ Vector2.new(maxX, minY), Vector2.new(maxX - cornerWidth, minY) },
			{ Vector2.new(maxX, minY), Vector2.new(maxX, minY + cornerHeight) },
			{ Vector2.new(minX, maxY), Vector2.new(minX + cornerWidth, maxY) },
			{ Vector2.new(minX, maxY), Vector2.new(minX, maxY - cornerHeight) },
			{ Vector2.new(maxX, maxY), Vector2.new(maxX - cornerWidth, maxY) },
			{ Vector2.new(maxX, maxY), Vector2.new(maxX, maxY - cornerHeight) },
		}

		for index, line in ipairs(lines) do
			local segment = segments[index]
			line.Visible = true
			line.Color = color
			line.Thickness = math.clamp(thickness + 0.2, 1, 2.8)
			line.From = segment[1]
			line.To = segment[2]
		end
	elseif effectiveBoxMode == "Head Box" then
		local box = ensureBox(entry)
		if not box then
			return
		end
		box.Filled = false
		box.Thickness = math.clamp(thickness + 0.15, 1, 2.8)
		box.Visible = true
		box.Color = color
		box.Transparency = 1
		box.Position = Vector2.new(minX, minY)
		box.Size = Vector2.new(math.max(maxX - minX, 2), math.max(maxY - minY, 2))
	elseif effectiveBoxMode == "3D Box" then
		local corners = getBoundingBoxViewportCorners(camera, character)
		local lines = ensureBoxLines(entry, "box3DLines", #BOX_3D_EDGES)
		if not corners or not lines then
			hideBoxes(entry)
			return
		end
		render3DBoxEdges(lines, corners, color, math.clamp(thickness, 1, 2.4))
	elseif effectiveBoxMode == "3D Corner" then
		local corners = getBoundingBoxViewportCorners(camera, character)
		local lines = ensureBoxLines(entry, "box3DCornerLines", #BOX_3D_EDGES * 2)
		if not corners or not lines then
			hideBoxes(entry)
			return
		end
		render3DCornerEdges(lines, corners, color, math.clamp(thickness + 0.1, 1, 2.5))
	end
end

local function updateSkeletonEsp(entry, camera, character, color)
	if not CONFIG.showSkeleton then
		hideSkeleton(entry)
		return
	end

	local lines = ensureSkeletonLines(entry)
	if not lines then
		hideSkeleton(entry)
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local healthRatio = humanoid and humanoid.MaxHealth > 0 and math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1) or 1
	local skeletonColor = CONFIG.showHealth and Color3.fromRGB(
		math.floor(255 - (155 * healthRatio)),
		math.floor(70 + (185 * healthRatio)),
		math.floor(88 - (32 * healthRatio))
	) or color
	for index, connection in ipairs(SKELETON_CONNECTIONS) do
		local fromPart = character:FindFirstChild(connection[1])
		local toPart = character:FindFirstChild(connection[2])
		local line = lines[index]

		if fromPart and toPart then
			local fromPoint = camera:WorldToViewportPoint(fromPart.Position)
			local toPoint = camera:WorldToViewportPoint(toPart.Position)
			if fromPoint.Z > 0 and toPoint.Z > 0 then
				line.Visible = true
				line.Color = skeletonColor
				line.From = Vector2.new(fromPoint.X, fromPoint.Y)
				line.To = Vector2.new(toPoint.X, toPoint.Y)
			else
				line.Visible = false
			end
		else
			line.Visible = false
		end
	end
end

local function updateLookDirectionEsp(entry, camera, character, root, color)
	if not CONFIG.showLookDirection or not isFocusedTarget(entry.player) then
		if entry.lookArrowLines then
			for _, line in ipairs(entry.lookArrowLines) do
				line.Visible = false
			end
		end
		return
	end

	local arrowLines = ensureLookArrowLines(entry)
	if not arrowLines then
		return
	end

	local head = character:FindFirstChild("Head")
	local originWorld = (head and head.Position or root.Position) + Vector3.new(0, head and 0.15 or 0.55, 0)
	local tipWorld = originWorld + root.CFrame.LookVector * 1.8
	local tipPoint = camera:WorldToViewportPoint(tipWorld)
	local originPoint = camera:WorldToViewportPoint(originWorld)

	if originPoint.Z > 0 and tipPoint.Z > 0 then
		local tip = Vector2.new(tipPoint.X, tipPoint.Y)
		local origin = Vector2.new(originPoint.X, originPoint.Y)
		local direction = tip - origin
		if direction.Magnitude < 1 then
			for _, line in ipairs(arrowLines) do
				line.Visible = false
			end
			return
		end

		direction = direction.Unit
		local backward = -direction
		local perpendicular = Vector2.new(-direction.Y, direction.X)
		local stemStart = tip + backward * 11
		local wingLength = 9
		local wingWidth = 5
		local leftWingEnd = tip + backward * wingLength + perpendicular * wingWidth
		local rightWingEnd = tip + backward * wingLength - perpendicular * wingWidth

		arrowLines[1].Visible = true
		arrowLines[1].Color = color
		arrowLines[1].From = stemStart
		arrowLines[1].To = tip

		arrowLines[2].Visible = true
		arrowLines[2].Color = color
		arrowLines[2].From = tip
		arrowLines[2].To = leftWingEnd

		arrowLines[3].Visible = true
		arrowLines[3].Color = color
		arrowLines[3].From = tip
		arrowLines[3].To = rightWingEnd
	else
		for _, line in ipairs(arrowLines) do
			line.Visible = false
		end
	end
end


local function isPlayerVisible(character, root)
	if not CONFIG.visibilityCheck then
		return true
	end

	local localCharacter = LOCAL_PLAYER.Character
	if not localCharacter then
		return false
	end

	local camera = getCamera()
	if not camera then
		return false
	end

	local origin = camera.CFrame.Position
	local targetPart = character:FindFirstChild("Head") or root
	local direction = targetPart.Position - origin

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = { localCharacter }
	params.IgnoreWater = true

	local result = workspace:Raycast(origin, direction, params)
	return not result or result.Instance:IsDescendantOf(character)
end

local function getDisplayColor(baseColor, isVisible)
	if not CONFIG.visibilityCheck then
		return baseColor
	end

	return isVisible and CONFIG.visibleColor or CONFIG.hiddenColor
end

local function getDistanceFade(distance)
	if not CONFIG.distanceFade then
		return 1
	end

	local alpha = 1 - math.clamp(distance / math.max(CONFIG.maxDistance, 1), 0, 1)
	return 0.35 + (alpha * 0.65)
end

local function getRainbowColor()
	local hue = (tick() * 0.2) % 1
	return Color3.fromHSV(hue, 0.85, 1)
end

local function updateDevAura(entry, character, rainbowColor)
	if not entry.billboard then
		return
	end

	local pulse = (math.sin(tick() * 3.2) + 1) * 0.5
	local ring = entry.devRing

	if ring then
		ring.Visible = true
		ring.BackgroundColor3 = rainbowColor
		ring.BackgroundTransparency = 0.8 - (pulse * 0.12)
		ring.Size = UDim2.new(0, math.floor(68 + pulse * 14), 0, math.floor(16 + pulse * 4))
		local ringGradient = ring:FindFirstChildOfClass("UIGradient")
		if ringGradient then
			ringGradient.Rotation = (tick() * -150) % 360
		end
	end
end

local function hideDevAura(entry)
	if entry.devRing then
		entry.devRing.Visible = false
	end
end

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

	if CONFIG.showNames or CONFIG.showDistance or CONFIG.showHealth or showDevTag then
		local _, title = ensureBillboard(entry, character)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local labelParts = {}

		if showDevTag then
			table.insert(labelParts, DEV_TAG_TEXT)
		elseif CONFIG.showNames then
			table.insert(labelParts, player.Name)
		end

		if not showDevTag and CONFIG.showDistance then
			table.insert(labelParts, string.format("[%dm]", distance))
		end

		if not showDevTag and CONFIG.showHealth and humanoid then
			table.insert(labelParts, string.format("[%d HP]", math.max(0, math.floor(humanoid.Health))))
		end

		if not showDevTag and CONFIG.showWeapon then
			local heldTool = getHeldToolName(character)
			if heldTool then
				table.insert(labelParts, "[" .. heldTool .. "]")
			end
		end

		local labelText = table.concat(labelParts, CONFIG.textStackMode == "Stacked" and "\n" or " ")
		title.Text = focusTarget and ("[TARGET] " .. labelText) or labelText
		if showDevTag then
			title.TextColor3 = devRainbowColor
			title.TextTransparency = 0
			updateDevAura(entry, character, devRainbowColor)
		else
			title.TextColor3 = focusTarget and THEME.focus or espColor
			title.TextTransparency = math.clamp((1 - distanceFade) * 0.65, 0, 0.65)
			hideDevAura(entry)
		end
		entry.billboard.Size = CONFIG.textStackMode == "Stacked" and UDim2.new(0, 180, 0, 42) or UDim2.new(0, 180, 0, 30)

		if entry.healthBack and entry.healthFill and humanoid then
			local healthPercent = 0
			if humanoid.MaxHealth > 0 then
				healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
			end

			entry.healthBack.Visible = CONFIG.showHealth
			entry.healthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
			entry.healthFill.BackgroundColor3 = showDevTag and devRainbowColor or (focusTarget and THEME.focus or Color3.fromRGB(
				math.floor(255 - (155 * healthPercent)),
				math.floor(70 + (185 * healthPercent)),
				math.floor(88 - (32 * healthPercent))
			))
		elseif entry.healthBack then
			entry.healthBack.Visible = false
		end
	else
		if entry.billboard then
			entry.billboard:Destroy()
			entry.billboard = nil
			entry.title = nil
			entry.healthBack = nil
			entry.healthFill = nil
			entry.devRing = nil
		end
	end

	if CONFIG.showTracers and drawingSupported then
		if not camera then
			return
		end

		local tracer = ensureTracer(entry)
		if not tracer then
			return
		end
		local screenPoint, visible = camera:WorldToViewportPoint(root.Position)
		local tracerOrigin = getTracerOrigin(camera)

		if visible and tracerOrigin then
			tracer.Visible = true
			tracer.Color = tracerColor
			tracer.Thickness = math.clamp(CONFIG.tracerThickness + (focusTarget and 0.6 or 0) - ((distance / math.max(CONFIG.maxDistance, 1)) * 0.9), 1, 4)
			tracer.Transparency = math.clamp((CONFIG.tracerTransparency / 100) * distanceFade, 0.1, 1)
			if CONFIG.tracerStyle == "Split" then
				local midPoint = Vector2.new((tracerOrigin.X + screenPoint.X) * 0.5, tracerOrigin.Y + ((screenPoint.Y - tracerOrigin.Y) * 0.2))
				tracer.From = tracerOrigin
				tracer.To = midPoint
				if not entry.tracerBranch then
					entry.tracerBranch = createDrawing("Line")
				end
				if entry.tracerBranch then
					entry.tracerBranch.Visible = true
					entry.tracerBranch.Color = tracerColor
					entry.tracerBranch.Thickness = tracer.Thickness
					entry.tracerBranch.Transparency = tracer.Transparency
					entry.tracerBranch.From = midPoint
					entry.tracerBranch.To = Vector2.new(screenPoint.X, screenPoint.Y)
				end
			else
				tracer.From = tracerOrigin
				tracer.To = Vector2.new(screenPoint.X, screenPoint.Y)
				if entry.tracerBranch then
					entry.tracerBranch.Visible = false
				end
			end
		else
			tracer.Visible = false
			if entry.tracerBranch then
				entry.tracerBranch.Visible = false
			end
		end
	elseif entry.tracer then
		entry.tracer.Visible = false
		if entry.tracerBranch then
			entry.tracerBranch.Visible = false
		end
	end

	if CONFIG.showHeadDot and camera then
		local head = character:FindFirstChild("Head")
		local headDot = ensureHeadDot(entry)
		if head and headDot then
			local headPoint, headVisible = camera:WorldToViewportPoint(head.Position)
			if headVisible and headPoint.Z > 0 then
				local dotSize = math.max(2, math.floor((CONFIG.headDotSize * 0.55) + (distanceFade * CONFIG.headDotSize * 0.45)))
				headDot.Visible = true
				headDot.Color = showDevTag and devRainbowColor or outlineColor
				headDot.Size = Vector2.new(dotSize, dotSize)
				headDot.Position = Vector2.new(headPoint.X - (dotSize * 0.5), headPoint.Y - (dotSize * 0.5))
				headDot.Transparency = math.clamp(0.3 + (distanceFade * 0.7), 0.2, 1)
			else
				headDot.Visible = false
			end
		elseif entry.headDot then
			entry.headDot.Visible = false
		end
	elseif entry.headDot then
		entry.headDot.Visible = false
	end
end

local function updatePerfStatsUi()
	if not miniHudLabels.perfStats then
		return
	end

	miniHudLabels.perfStats.fps.Text = tostring(math.max(0, math.floor(currentFps + 0.5)))
	miniHudLabels.perfStats.visible.Text = tostring(visibleEnemyCount)
	miniHudLabels.perfStats.tracked.Text = tostring(trackedEnemyCount)
	miniHudLabels.perfStats.update.Text = string.format("%.1fms", lastRefreshMs)

	if miniHudLabels.status then
		miniHudLabels.status.Text = CONFIG.enabled and "ONLINE" or "OFFLINE"
		miniHudLabels.status.TextColor3 = CONFIG.enabled and THEME.accent or THEME.muted
		miniHudLabels.fps.Text = string.format("%d | %.1fms", math.max(0, math.floor(currentFps + 0.5)), lastRefreshMs)
		miniHudLabels.fps.TextColor3 = THEME.text
		miniHudLabels.targets.Text = string.format("%d visible / %d tracked", visibleEnemyCount, trackedEnemyCount)
		if CONFIG.showFocusTarget and focusedPlayer then
			miniHudLabels.focus.Text = truncateText(focusedPlayer.Name, 18)
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
			tracerSliders.targetCard.Visible = uiReady and gui.Enabled and CONFIG.showTargetCard
		end
		if focusedPlayer and CONFIG.showTargetCard then
			local character = focusedPlayer.Character
			local root = character and getCharacterRoot(character)
			local localCharacter = LOCAL_PLAYER.Character
			local localRoot = localCharacter and getCharacterRoot(localCharacter)
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local details = {}
			local detailsSecondary = {}
			local telemetry = miniHudLabels.utility.targetTelemetry[focusedPlayer] or {}

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

			tracerSliders.targetInfo.Text = truncateText(focusedPlayer.Name, 18)
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
		local activeTrainerPreset = getActiveTrainerPresetName()
		local trainerAccent = activeTrainerPreset and getTrainerPresetColor(activeTrainerPreset) or (CONFIG.trainerDrillType == "Track" and THEME.focus or THEME.accent)
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

local function refreshAllEsp()
	local refreshStart = os.clock()
	visibleEnemyCount = 0
	trackedEnemyCount = 0
	focusedPlayer = nil
	local focusedScore = -math.huge
	local lockedFocusValid = false
	local localCharacter = LOCAL_PLAYER.Character
	local localRoot = localCharacter and getCharacterRoot(localCharacter)
	local trackedPlayers = {}
	local trackedData = {}
	local groupRadius = 28

	if not localRoot then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LOCAL_PLAYER then
				clearPlayerEsp(player)
			end
		end
		lastRefreshMs = (os.clock() - refreshStart) * 1000
		updatePerfStatsUi()
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LOCAL_PLAYER then
			local character = player.Character
			local root = character and getCharacterRoot(character)
			if character and root and localRoot and shouldTrackPlayer(player) then
				trackedEnemyCount = trackedEnemyCount + 1
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

	for _, player in ipairs(trackedPlayers) do
		local playerData = trackedData[player]
		if playerData then
			local telemetry = playerData.telemetry
			local distance = playerData.distance
			local visible = playerData.visible
			local character = playerData.character
					local mode = CONFIG.threatMode
					local threatScore = -math.huge

			if visible then
				visibleEnemyCount = visibleEnemyCount + 1
			end

			if mode == "Closest" then
				threatScore = -distance
			elseif mode == "Visible" then
				threatScore = (visible and 100000 or 0) - distance
			elseif mode == "Armed" then
				threatScore = (playerData.heldTool and 100000 or 0) + (visible and 10000 or 0) - distance
			elseif mode == "Smart" then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				local healthFactor = humanoid and humanoid.MaxHealth > 0 and (1 - math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)) or 0
				threatScore = (visible and 120000 or 0) + (telemetry.weapon and 60000 or 0) + (healthFactor * 20000) + ((telemetry.aimingAtYou and 1 or 0) * 35000) + (telemetry.groupDanger * 4000) - distance
			end

			if threatScore > focusedScore then
				focusedScore = threatScore
				focusedPlayer = player
			end

			if CONFIG.focusLock and player == viewState.lockedFocusTarget then
				lockedFocusValid = true
			end
		end
	end

	if CONFIG.focusLock then
		if lockedFocusValid then
			focusedPlayer = viewState.lockedFocusTarget
		else
			viewState.lockedFocusTarget = focusedPlayer
		end
	else
		viewState.lockedFocusTarget = nil
	end

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

	lastRefreshMs = (os.clock() - refreshStart) * 1000
	if currentFps > 0 then
		if currentFps < 35 then
			updateInterval = 1 / 16
		elseif trackedEnemyCount > 12 then
			updateInterval = 1 / 24
		else
			updateInterval = 1 / 30
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

local function hookCharacter(player)
	local function attachCharacterSignals(character)
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end

		if player == LOCAL_PLAYER then
			bindLocalMovementSignals(humanoid)
		end

		miniHudLabels.utility.lastHealth[player] = humanoid.Health

		humanoid.HealthChanged:Connect(function(health)
			local previousHealth = miniHudLabels.utility.lastHealth[player] or health
			if health < previousHealth then
				miniHudLabels.utility.targetTelemetry[player] = miniHudLabels.utility.targetTelemetry[player] or {}
				miniHudLabels.utility.targetTelemetry[player].lastDamageAt = tick()
				miniHudLabels.utility.targetTelemetry[player].lastHealthDelta = previousHealth - health
			end
			miniHudLabels.utility.lastHealth[player] = health
		end)

		humanoid.Died:Connect(function()
			local killer = "Unknown"
			local creator = humanoid:FindFirstChild("creator")
			if creator and creator.Value and creator.Value:IsA("Player") then
				killer = creator.Value.Name
			end

			local localKill = killer == LOCAL_PLAYER.Name
			miniHudLabels.utility.killCredit[player] = nil

			if localKill then
				miniHudLabels.utility.showKillText(string.format("You killed %s", player.Name))
			end
		end)
	end

	player.CharacterAdded:Connect(function()
		task.wait(0.2)
		if player == LOCAL_PLAYER then
			resetDefaultMovementCache()
		end
		attachCharacterSignals(player.Character)
		refreshAllEsp()
	end)

	player.CharacterAppearanceLoaded:Connect(function()
		task.wait(0.1)
		refreshAllEsp()
	end)

	if player.Character then
		if player == LOCAL_PLAYER then
			resetDefaultMovementCache()
		end
		attachCharacterSignals(player.Character)
	end
end

local function bindToggle(button, configKey)
	button.MouseButton1Click:Connect(function()
		applyConfigToggleState(configKey, not CONFIG[configKey])
	end)
end

applyConfigToggleState = function(configKey, nextState, suppressToast)
	if configKey == "walkSpeedEnabled" then
		local humanoid = getLocalHumanoid()
		if nextState and humanoid and not viewState.defaultWalkSpeed then
			viewState.defaultWalkSpeed = humanoid.WalkSpeed
		end
	end

	CONFIG[configKey] = nextState

	if configKey == "performanceMode" and not CONFIG[configKey] then
		CONFIG.simplifyMaterials = false
		CONFIG.hideTextures = false
		CONFIG.hideEffects = false
		CONFIG.disableShadows = false
	end

	if configKey == "performanceMode" or configKey == "simplifyMaterials" or configKey == "hideTextures" or configKey == "hideEffects" or configKey == "disableShadows" then
		if configKey ~= "performanceMode" and not CONFIG[configKey] then
			CONFIG.performanceMode = false
		end

		applyPerformanceSettings()
		if syncUiFromConfig then
			syncUiFromConfig()
		end
	end

	if keybindState.toggleButtonsByConfig[configKey] then
		setToggleState(keybindState.toggleButtonsByConfig[configKey], CONFIG[configKey])
	end

	if configKey == "showMiniHud" then
		miniHud.Visible = uiReady and CONFIG.showMiniHud and window.Visible
	elseif configKey == "showCrosshair" then
		if CONFIG.showCrosshair then
			updateCrosshair()
		else
			hideCrosshair()
		end
	elseif configKey == "removeZoomLimit" then
		applyZoomLimitSetting()
	elseif configKey == "antiAfk" then
		miniHudLabels.utility.applyAntiAfk()
	elseif configKey == "aimTrainerMode" then
		if CONFIG.aimTrainerMode then
			resetTrainerSession()
		else
			miniHudLabels.utility.trainer.targetPosition = nil
			miniHudLabels.utility.trainer.challengeEndsAt = nil
			hideTrainerVisuals()
		end
	elseif configKey == "trainerChallengeMode" then
		if CONFIG.trainerChallengeMode then
			if not CONFIG.aimTrainerMode then
				CONFIG.aimTrainerMode = true
				setToggleState(tracerSliders.trainingToggle, true)
			end
			resetTrainerSession()
		else
			miniHudLabels.utility.trainer.challengeEndsAt = nil
		end
	elseif configKey == "trainerShrinkingTargets" or configKey == "trainerReactionTimer" then
		if CONFIG.aimTrainerMode and not miniHudLabels.utility.trainer.targetPosition then
			spawnTrainerTarget()
		end
	elseif configKey == "fly" and not CONFIG.fly then
		stopFly()
	elseif configKey == "showBoxes" and not CONFIG.showBoxes then
		resetAllBoxEspVisuals()
	elseif configKey == "walkSpeedEnabled" and not CONFIG.walkSpeedEnabled then
		local humanoid = getLocalHumanoid()
		if humanoid and viewState.defaultWalkSpeed then
			humanoid.WalkSpeed = viewState.defaultWalkSpeed
		end
	end

	refreshAllEsp()
	saveSettings()
	updateMouseIconVisibility()
	applyPlayerMovementState()
	if updateControlAvailability then
		updateControlAvailability()
	end
	if keybindController then
		keybindController.update()
	end

	if not suppressToast then
		showToast("Setting Updated", string.format("%s %s", formatSettingName(configKey), CONFIG[configKey] and "enabled" or "disabled"), CONFIG[configKey] and THEME.accent or THEME.muted)
	end
end

local function setEspEnabled(state)
	CONFIG.enabled = state
	setToggleState(miniHudLabels.utility.controls.enabledToggle, state)
	if state then
		refreshAllEsp()
	else
		clearAllEsp()
	end
	saveSettings()
	if keybindController then
		keybindController.update()
	end
	showToast("ESP", state and "ESP enabled" or "ESP disabled", state and THEME.accent or THEME.muted)
end

local function applyMinimalMode(state, skipSave)
	CONFIG.minimalMode = state
	chrome.infoPanel.Visible = not state
	chrome.brandSub.Visible = not state
	chrome.brandKicker.Visible = not state
	chrome.glow.Visible = not state
	chrome.topBar.Size = state and UDim2.new(1, 0, 0, 74) or UDim2.new(1, 0, 0, 108)
	tabBar.Position = state and UDim2.new(0, 12, 0, 42) or UDim2.new(0, 12, 0, 78)
	content.Position = state and UDim2.new(0, 0, 0, 74) or UDim2.new(0, 0, 0, 108)
	content.Size = state and UDim2.new(1, 0, 1, -74) or UDim2.new(1, 0, 1, -108)
	chrome.brand.Size = state and UDim2.new(0, 156, 0, 24) or UDim2.new(0, 186, 0, 42)
	chrome.brandTitle.TextSize = state and 18 or 21
	chrome.brandTitle.Position = state and UDim2.new(0, 0, 0, 4) or UDim2.new(0, 0, 0, 9)

	if watermark then
		watermark.Visible = uiReady and not state
	end

	local miniHudCompact = state
	miniHud.Size = miniHudCompact and UDim2.new(0, 228, 0, 126) or UDim2.new(0, 228, 0, 152)
	if miniHudLabels.fps and miniHudLabels.fps.Parent and miniHudLabels.fps.Parent.Parent then
		miniHudLabels.fps.Parent.Parent.Visible = not miniHudCompact
	end

	updatePerfStatsUi()

	if not skipSave then
		saveSettings()
	end
end

local function setMinimized(state)
	uiMinimized = state
	content.Visible = not state
	if CONFIG.minimalMode then
		window.Size = state and minimalMinimizedWindowSize or minimalWindowSize
	else
		window.Size = state and minimizedWindowSize or expandedWindowSize
	end
	chrome.minimizeButton.Text = state and "+" or "-"
end

function resetOverlayPositions()
	if overlayTools and overlayTools.resetOverlayPosition then
		overlayTools.resetOverlayPosition(miniHud, "miniHud")
		overlayTools.resetOverlayPosition(tracerSliders.targetCard, "targetCard")
	end
	if keybindController and keybindController.resetPosition then
		keybindController.resetPosition()
	end
end

local function finalizeIntroStartup()
	uiReady = true
	setActiveTab("control")
	window.Position = UDim2.new(0.5, CONFIG.windowOffsetX, 0.5, CONFIG.windowOffsetY)
	window.Visible = true
	watermark.Visible = not CONFIG.minimalMode
	miniHud.Visible = CONFIG.showMiniHud
	updateMouseIconVisibility()

	task.defer(function()
		syncUiFromConfig()
		applyCameraFov()
		applyZoomLimitSetting()
		resetDefaultMovementCache()
		miniHudLabels.utility.applyAntiAfk()

		task.defer(function()
			applyPerformanceSettings()
			applyMinimalMode(CONFIG.minimalMode)
			setActiveTab("control")
			setMinimized(false)

			task.defer(function()
				refreshAllEsp()
				updateMouseIconVisibility()
				if keybindController then
					keybindController.update()
				end
			end)
		end)
	end)
end

local function playIntroAnimation()
	if introController and introController.play then
		introController.play(finalizeIntroStartup)
	else
		finalizeIntroStartup()
	end
end

createTabButton("control", "UTILITY").MouseButton1Click:Connect(function()
	setActiveTab("control")
end)

createTabButton("display", "VISUALS").MouseButton1Click:Connect(function()
	setActiveTab("display")
end)

createTabButton("combat", "TARGET").MouseButton1Click:Connect(function()
	setActiveTab("combat")
end)

createTabButton("player", "PLAYER").MouseButton1Click:Connect(function()
	setActiveTab("player")
end)

createTabButton("performance", "LOCAL").MouseButton1Click:Connect(function()
	setActiveTab("performance")
end)

bindToggle(miniHudLabels.utility.controls.enabledToggle, "enabled")
bindToggle(miniHudLabels.utility.displayToggles.names, "showNames")
bindToggle(miniHudLabels.utility.displayToggles.distance, "showDistance")
bindToggle(miniHudLabels.utility.displayToggles.fade, "distanceFade")
bindToggle(miniHudLabels.utility.displayToggles.health, "showHealth")
bindToggle(miniHudLabels.utility.displayToggles.weapon, "showWeapon")
bindToggle(miniHudLabels.utility.displayToggles.skeleton, "showSkeleton")
bindToggle(miniHudLabels.utility.displayToggles.headDot, "showHeadDot")
bindToggle(miniHudLabels.utility.displayToggles.focus, "showFocusTarget")
bindToggle(miniHudLabels.utility.displayToggles.boxes, "showBoxes")
bindToggle(miniHudLabels.utility.displayToggles.targetCard, "showTargetCard")
bindToggle(miniHudLabels.utility.displayToggles.targetCardCompact, "targetCardCompact")
bindToggle(tracerSliders.visibilityToggle, "visibilityCheck")
bindToggle(tracerSliders.tracersToggle, "showTracers")
bindToggle(tracerSliders.focusLock, "focusLock")
bindToggle(tracerSliders.lookDirectionToggle, "showLookDirection")
bindToggle(tracerSliders.crosshairToggle, "showCrosshair")
bindToggle(tracerSliders.fovCircleToggle, "showFovCircle")
bindToggle(tracerSliders.trainingToggle, "aimTrainerMode")
bindToggle(tracerSliders.trainingReactionToggle, "trainerReactionTimer")
bindToggle(tracerSliders.trainingChallengeToggle, "trainerChallengeMode")
bindToggle(tracerSliders.trainingShrinkingToggle, "trainerShrinkingTargets")
bindToggle(tracerSliders.recoilVisualizerToggle, "recoilVisualizer")
bindToggle(tracerSliders.spreadVisualizerToggle, "spreadVisualizer")
bindToggle(miniHudLabels.utility.controls.miniHudToggle, "showMiniHud")
bindToggle(viewButtons.removeZoomLimit, "removeZoomLimit")
bindToggle(playerButtons.walkSpeedToggle, "walkSpeedEnabled")
bindToggle(playerButtons.infiniteJump, "infiniteJump")
bindToggle(playerButtons.noclip, "noclip")
bindToggle(playerButtons.fly, "fly")
bindToggle(playerButtons.clickTeleport, "clickTeleport")
bindToggle(miniHudLabels.utility.antiAfk, "antiAfk")
bindToggle(miniHudLabels.utility.autoLoadGamePreset, "autoLoadGamePreset")
bindToggle(miniHudLabels.utility.performanceToggles.mode, "performanceMode")
bindToggle(miniHudLabels.utility.performanceToggles.materials, "simplifyMaterials")
bindToggle(miniHudLabels.utility.performanceToggles.textures, "hideTextures")
bindToggle(miniHudLabels.utility.performanceToggles.effects, "hideEffects")
bindToggle(miniHudLabels.utility.performanceToggles.shadows, "disableShadows")

for configKey, button in pairs({
	enabled = miniHudLabels.utility.controls.enabledToggle,
	showNames = miniHudLabels.utility.displayToggles.names,
	showDistance = miniHudLabels.utility.displayToggles.distance,
	distanceFade = miniHudLabels.utility.displayToggles.fade,
	showHealth = miniHudLabels.utility.displayToggles.health,
	showWeapon = miniHudLabels.utility.displayToggles.weapon,
	showSkeleton = miniHudLabels.utility.displayToggles.skeleton,
	showHeadDot = miniHudLabels.utility.displayToggles.headDot,
	showFocusTarget = miniHudLabels.utility.displayToggles.focus,
	showBoxes = miniHudLabels.utility.displayToggles.boxes,
	showTargetCard = miniHudLabels.utility.displayToggles.targetCard,
	targetCardCompact = miniHudLabels.utility.displayToggles.targetCardCompact,
	visibilityCheck = tracerSliders.visibilityToggle,
	showTracers = tracerSliders.tracersToggle,
	focusLock = tracerSliders.focusLock,
	showLookDirection = tracerSliders.lookDirectionToggle,
	showCrosshair = tracerSliders.crosshairToggle,
	showFovCircle = tracerSliders.fovCircleToggle,
	aimTrainerMode = tracerSliders.trainingToggle,
	trainerReactionTimer = tracerSliders.trainingReactionToggle,
	trainerChallengeMode = tracerSliders.trainingChallengeToggle,
	trainerShrinkingTargets = tracerSliders.trainingShrinkingToggle,
	recoilVisualizer = tracerSliders.recoilVisualizerToggle,
	spreadVisualizer = tracerSliders.spreadVisualizerToggle,
	showMiniHud = miniHudLabels.utility.controls.miniHudToggle,
	removeZoomLimit = viewButtons.removeZoomLimit,
	walkSpeedEnabled = playerButtons.walkSpeedToggle,
	infiniteJump = playerButtons.infiniteJump,
	noclip = playerButtons.noclip,
	fly = playerButtons.fly,
	clickTeleport = playerButtons.clickTeleport,
	antiAfk = miniHudLabels.utility.antiAfk,
	autoLoadGamePreset = miniHudLabels.utility.autoLoadGamePreset,
	performanceMode = miniHudLabels.utility.performanceToggles.mode,
	simplifyMaterials = miniHudLabels.utility.performanceToggles.materials,
	hideTextures = miniHudLabels.utility.performanceToggles.textures,
	hideEffects = miniHudLabels.utility.performanceToggles.effects,
	disableShadows = miniHudLabels.utility.performanceToggles.shadows,
}) do
	keybindState.toggleButtonsByConfig[configKey] = button
end

do
	local keybindFactory = requireLocalModule("C:\\Users\\alexl\\Desktop\\ESP\\esp_modules\\keybinds.lua", KEYBINDS_MODULE_SOURCE)
	if type(keybindFactory) == "function" then
		keybindController = keybindFactory({
			addCorner = addCorner,
			addStroke = addStroke,
			applyConfigToggleState = applyConfigToggleState,
			config = CONFIG,
			create = create,
			createCycleRow = createCycleRow,
			createKeybindRow = createKeybindRow,
			createStatusRow = createStatusRow,
			createToggleRow = createToggleRow,
			defaultFeatureKeybindModes = DEFAULT_FEATURE_KEYBIND_MODES,
			defaultFeatureKeybinds = DEFAULT_FEATURE_KEYBINDS,
			featureKeybindModes = FEATURE_KEYBIND_MODES,
			featureKeybinds = FEATURE_KEYBINDS,
			gui = gui,
			keyCodeToText = keyCodeToText,
			keyTextToKeyCode = keyTextToKeyCode,
			makeOverlayDraggable = overlayTools and overlayTools.makeOverlayDraggable or nil,
			makeLabel = makeLabel,
			resetOverlayPosition = overlayTools and overlayTools.resetOverlayPosition or nil,
			saveSettings = saveSettings,
			setToggleState = setToggleState,
			showToast = showToast,
			theme = THEME,
			toggleFreeCam = toggleFreeCam,
			isUiReady = function()
				return uiReady
			end,
			userInputService = UserInputService,
			viewState = viewState,
		})
		keybindController.buildRows(miniHudLabels.utility.controlTabs.keybindsPage)
	end
end

miniHudLabels.utility.controls.minimalToggle.MouseButton1Click:Connect(function()
	applyMinimalMode(not CONFIG.minimalMode)
	setToggleState(miniHudLabels.utility.controls.minimalToggle, CONFIG.minimalMode)
	setMinimized(uiMinimized)
	showToast("Setting Updated", string.format("%s %s", "Minimal Mode", CONFIG.minimalMode and "enabled" or "disabled"), CONFIG.minimalMode and THEME.accent or THEME.muted)
end)
if overlayTools and miniHudLabels.utility.updatePanel.check then
	overlayTools.bindUpdatePanel(miniHudLabels.utility.updatePanel)
end

function setPresetDropdownOpen(isOpen)
	local dropdown = miniHudLabels.utility.controls.presetDropdown
	if not dropdown then
		return
	end
	dropdown.open = isOpen
	dropdown.list.Visible = isOpen
	dropdown.row.Size = UDim2.new(1, 0, 0, isOpen and dropdown.openHeight or dropdown.closedHeight)
	dropdown.arrow.Text = isOpen and "^" or "v"
end

function refreshPresetDropdown()
	local dropdown = miniHudLabels.utility.controls.presetDropdown
	if not dropdown then
		return
	end
	dropdown.button.Text = PRESETS[currentPresetIndex].name
	dropdown.arrow.Text = dropdown.open and "^" or "v"
	for index, option in ipairs(dropdown.options or {}) do
		local selected = index == currentPresetIndex
		option.BackgroundColor3 = selected and THEME.accentSoft or Color3.fromRGB(31, 36, 48)
		option.TextColor3 = selected and THEME.text or THEME.muted
		local stroke = option:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Transparency = selected and 0.2 or 0.45
		end
	end
end

function spawnTrainerTarget()
	local camera = getCamera()
	if not camera then
		return
	end
	local trainer = ensureTrainerState()
	if not trainer then
		return
	end
	local viewport = camera.ViewportSize
	local margin = math.max(36, CONFIG.fovRadius * 0.35)
	local minX = margin
	local maxX = math.max(margin + 1, viewport.X - margin)
	local minY = margin + 24
	local maxY = math.max(minY + 1, viewport.Y - margin)
	trainer.targetPosition = Vector2.new(
		math.random(math.floor(minX), math.floor(maxX)),
		math.random(math.floor(minY), math.floor(maxY))
	)
	trainer.targetSpawnAt = tick()
	trainer.holdProgress = 0
	local angle = math.rad(math.random(0, 359))
	trainer.targetVelocity = Vector2.new(math.cos(angle), math.sin(angle)) * CONFIG.trainerTargetSpeed
end

function recordTrainerClickSuccess(elapsedMs)
	local trainer = ensureTrainerState()
	if not trainer then
		return
	end
	local shouldSave = false
	trainer.hits = trainer.hits + 1
	trainer.clickHits = (trainer.clickHits or 0) + 1
	trainer.clickTotalMs = (trainer.clickTotalMs or 0) + elapsedMs
	trainer.clickStreak = (trainer.clickStreak or 0) + 1
	if trainer.clickStreak > (trainer.clickBestStreak or 0) then
		trainer.clickBestStreak = trainer.clickStreak
		shouldSave = true
	end
	trainer.trackStreak = 0
	trainer.lastReactionMs = elapsedMs
	if trainer.clickBestMs == nil or elapsedMs < trainer.clickBestMs then
		trainer.clickBestMs = elapsedMs
		shouldSave = true
	end
	if trainer.bestReactionMs == nil or elapsedMs < trainer.bestReactionMs then
		trainer.bestReactionMs = elapsedMs
	end
	if shouldSave then
		saveSettings()
	end
end

function recordTrainerClickMiss()
	local trainer = ensureTrainerState()
	if not trainer then
		return
	end
	trainer.misses = trainer.misses + 1
	trainer.clickMisses = (trainer.clickMisses or 0) + 1
	trainer.clickStreak = 0
end

function recordTrainerTrackSuccess(elapsedMs)
	local trainer = ensureTrainerState()
	if not trainer then
		return
	end
	local shouldSave = false
	trainer.hits = trainer.hits + 1
	trainer.trackHits = (trainer.trackHits or 0) + 1
	trainer.trackTotalMs = (trainer.trackTotalMs or 0) + elapsedMs
	trainer.trackStreak = (trainer.trackStreak or 0) + 1
	if trainer.trackStreak > (trainer.trackBestStreak or 0) then
		trainer.trackBestStreak = trainer.trackStreak
		shouldSave = true
	end
	trainer.clickStreak = 0
	trainer.lastReactionMs = elapsedMs
	if trainer.trackBestMs == nil or elapsedMs < trainer.trackBestMs then
		trainer.trackBestMs = elapsedMs
		shouldSave = true
	end
	if trainer.bestReactionMs == nil or elapsedMs < trainer.bestReactionMs then
		trainer.bestReactionMs = elapsedMs
	end
	if shouldSave then
		saveSettings()
	end
end

function recordTrainerTrackBreak()
	local trainer = ensureTrainerState()
	if not trainer then
		return
	end
	trainer.trackBreaks = (trainer.trackBreaks or 0) + 1
	trainer.trackStreak = 0
end

function resetTrainerSession()
	local trainer = ensureTrainerState()
	if not trainer then
		return
	end
	trainer.hits = 0
	trainer.misses = 0
	trainer.lastReactionMs = nil
	trainer.bestReactionMs = nil
	trainer.clickHits = 0
	trainer.clickMisses = 0
	trainer.clickTotalMs = 0
	trainer.clickStreak = 0
	trainer.trackHits = 0
	trainer.trackBreaks = 0
	trainer.trackTotalMs = 0
	trainer.trackStreak = 0
	trainer.targetSpawnAt = 0
	trainer.challengeEndsAt = CONFIG.trainerChallengeMode and (tick() + CONFIG.trainerChallengeDuration) or nil
	trainer.lastResults = nil
	trainer.holdProgress = 0
	spawnTrainerTarget()
end

function hideTrainerVisuals()
	local trainer = ensureTrainerState()
	if not trainer then
		return
	end
	for _, key in ipairs({ "targetDot", "hitWindowCircle", "spreadCircle", "recoilMarker" }) do
		local object = trainer[key]
		if object then
			object.Visible = false
		end
	end
	if trainer.trackProgressRing then
		for _, segment in ipairs(trainer.trackProgressRing) do
			segment.Visible = false
		end
	end
end

function ensureTrainerCircle(key, filled)
	local trainer = ensureTrainerState()
	if not trainer then
		return nil
	end
	if not trainer[key] then
		trainer[key] = createDrawing("Circle")
		if not trainer[key] then
			return nil
		end
		trainer[key].Filled = filled == true
		trainer[key].NumSides = 40
		trainer[key].Transparency = 1
	end
	return trainer[key]
end

function ensureTrainerProgressRing()
	local trainer = ensureTrainerState()
	if not trainer then
		return nil
	end
	if trainer.trackProgressRing then
		return trainer.trackProgressRing
	end

	trainer.trackProgressRing = {}
	for _ = 1, 18 do
		local segment = createDrawing("Line")
		if segment then
			segment.Thickness = 2
			segment.Transparency = 0.95
			table.insert(trainer.trackProgressRing, segment)
		end
	end

	if #trainer.trackProgressRing ~= 18 then
		for _, segment in ipairs(trainer.trackProgressRing) do
			segment:Remove()
		end
		trainer.trackProgressRing = nil
	end

	return trainer.trackProgressRing
end

function updateTrainerProgressRing(center, radius, progress)
	local ring = ensureTrainerProgressRing()
	if not ring then
		return
	end

	local visibleSegments = math.floor(math.clamp(progress, 0, 1) * #ring + 0.5)
	for index, segment in ipairs(ring) do
		if index <= visibleSegments then
			local startAngle = math.rad(-90 + ((index - 1) / #ring) * 360)
			local endAngle = math.rad(-90 + (index / #ring) * 360)
			segment.Visible = true
			segment.Color = THEME.focus
			segment.From = center + Vector2.new(math.cos(startAngle), math.sin(startAngle)) * radius
			segment.To = center + Vector2.new(math.cos(endAngle), math.sin(endAngle)) * radius
		else
			segment.Visible = false
		end
	end
end

function buildTrainerChallengeSummary()
	local trainer = ensureTrainerState()
	if not trainer then
		return nil
	end
	local clickShots = math.max(1, (trainer.clickHits or 0) + (trainer.clickMisses or 0))
	local accuracy = math.floor(((trainer.hits or 0) / math.max(1, (trainer.hits or 0) + (trainer.misses or 0))) * 100 + 0.5)
	return {
		drill = CONFIG.trainerDrillType,
		hits = trainer.hits or 0,
		misses = trainer.misses or 0,
		accuracy = accuracy,
		clickAverage = (trainer.clickHits or 0) > 0 and math.floor((trainer.clickTotalMs or 0) / math.max(trainer.clickHits, 1) + 0.5) or nil,
		clickBest = trainer.clickBestMs,
		clickAccuracy = math.floor(((trainer.clickHits or 0) / clickShots) * 100 + 0.5),
		clickPeak = trainer.clickBestStreak or 0,
		trackAverage = (trainer.trackHits or 0) > 0 and math.floor((trainer.trackTotalMs or 0) / math.max(trainer.trackHits, 1) + 0.5) or nil,
		trackBest = trainer.trackBestMs,
		trackBreaks = trainer.trackBreaks or 0,
		trackPeak = trainer.trackBestStreak or 0,
	}
end

function pushTrainerHistoryEntry(summary)
	local trainer = ensureTrainerState()
	if not trainer then
		return
	end
	if type(summary) ~= "table" then
		return
	end

	trainer.history = trainer.history or {}
	table.insert(trainer.history, 1, {
		drill = summary.drill,
		hits = summary.hits,
		misses = summary.misses,
		accuracy = summary.accuracy,
		clickBest = summary.clickBest,
		trackBest = summary.trackBest,
	})

	while #trainer.history > 4 do
		table.remove(trainer.history)
	end
end

function getTrainerPresetBadgeText(presetName)
	if presetName == "Warmup" then
		return "CLICK"
	end
	if presetName == "Precision" then
		return "PRECISE"
	end
	if presetName == "Tracking" then
		return "TRACK"
	end
	if presetName == "Speed" then
		return "FAST"
	end
	if presetName == "Micro Adjust" then
		return "MICRO"
	end
	if presetName == "Custom 1" then
		local slot = TRAINER_CUSTOM_PRESETS[presetName]
		return (type(slot) == "table" and type(slot.badge) == "string" and slot.badge ~= "") and slot.badge or "USER 1"
	end
	if presetName == "Custom 2" then
		local slot = TRAINER_CUSTOM_PRESETS[presetName]
		return (type(slot) == "table" and type(slot.badge) == "string" and slot.badge ~= "") and slot.badge or "USER 2"
	end
	return ""
end

function getTrainerCustomLabel(slotName)
	local slot = TRAINER_CUSTOM_PRESETS[slotName]
	if type(slot) == "table" and type(slot.label) == "string" and slot.label ~= "" then
		return truncateText(slot.label, 14)
	end
	return slotName
end

function getTrainerCustomBadge(slotName)
	local slot = TRAINER_CUSTOM_PRESETS[slotName]
	if type(slot) == "table" and type(slot.badge) == "string" and slot.badge ~= "" then
		return truncateText(slot.badge, 10)
	end
	return slotName == "Custom 1" and "USER 1" or "USER 2"
end

function getTrainerPresetColor(presetName)
	if presetName == "Warmup" then
		return Color3.fromRGB(88, 166, 255)
	end
	if presetName == "Precision" then
		return Color3.fromRGB(255, 214, 102)
	end
	if presetName == "Tracking" then
		return Color3.fromRGB(117, 255, 160)
	end
	if presetName == "Speed" then
		return Color3.fromRGB(255, 116, 116)
	end
	if presetName == "Micro Adjust" then
		return Color3.fromRGB(255, 2, 127)
	end
	if presetName == "Custom 1" then
		return Color3.fromRGB(162, 129, 255)
	end
	if presetName == "Custom 2" then
		return Color3.fromRGB(255, 154, 76)
	end
	return THEME.accent
end

function captureTrainerPresetSettings()
	return {
		aimTrainerMode = true,
		trainerDrillType = CONFIG.trainerDrillType,
		trainerReactionTimer = CONFIG.trainerReactionTimer,
		trainerHitWindow = CONFIG.trainerHitWindow,
		trainerChallengeMode = CONFIG.trainerChallengeMode,
		trainerChallengeDuration = CONFIG.trainerChallengeDuration,
		trainerShrinkingTargets = CONFIG.trainerShrinkingTargets,
		trainerTrackHoldTime = CONFIG.trainerTrackHoldTime,
		trainerTargetSpeed = CONFIG.trainerTargetSpeed,
	}
end

function applyTrainerPresetSettings(settings)
	if type(settings) ~= "table" then
		return false
	end

	CONFIG.aimTrainerMode = settings.aimTrainerMode ~= false
	CONFIG.trainerDrillType = settings.trainerDrillType or CONFIG.trainerDrillType
	CONFIG.trainerReactionTimer = settings.trainerReactionTimer ~= false
	CONFIG.trainerHitWindow = settings.trainerHitWindow or CONFIG.trainerHitWindow
	CONFIG.trainerChallengeMode = settings.trainerChallengeMode == true
	CONFIG.trainerChallengeDuration = settings.trainerChallengeDuration or CONFIG.trainerChallengeDuration
	CONFIG.trainerShrinkingTargets = settings.trainerShrinkingTargets == true
	CONFIG.trainerTrackHoldTime = settings.trainerTrackHoldTime or CONFIG.trainerTrackHoldTime
	CONFIG.trainerTargetSpeed = settings.trainerTargetSpeed or CONFIG.trainerTargetSpeed
	return true
end

function saveTrainerCustomPreset(slotName)
	if TRAINER_CUSTOM_PRESETS[slotName] == nil then
		return false
	end
	TRAINER_CUSTOM_PRESETS[slotName].settings = captureTrainerPresetSettings()
	saveSettings()
	return true
end

function renameTrainerCustomPreset(slotName, newLabel)
	if TRAINER_CUSTOM_PRESETS[slotName] == nil then
		return false
	end

	newLabel = tostring(newLabel or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if newLabel == "" then
		newLabel = slotName
	end

	TRAINER_CUSTOM_PRESETS[slotName].label = truncateText(newLabel, 18)
	saveSettings()
	return true
end

function retagTrainerCustomPreset(slotName, newBadge)
	if TRAINER_CUSTOM_PRESETS[slotName] == nil then
		return false
	end

	newBadge = tostring(newBadge or ""):upper():gsub("^%s+", ""):gsub("%s+$", "")
	if newBadge == "" then
		newBadge = slotName == "Custom 1" and "USER 1" or "USER 2"
	end

	TRAINER_CUSTOM_PRESETS[slotName].badge = truncateText(newBadge, 10)
	saveSettings()
	return true
end

function styleTrainerPresetButtons()
	if not tracerSliders or not tracerSliders.trainingPresetButtons or not tracerSliders.trainingPresetButtons[1] then
		return
	end

	local holder = tracerSliders.trainingPresetButtons[1].button.Parent
	local row = holder and holder.Parent
	if row then
		row.Size = UDim2.new(1, 0, 0, 96)
	end
	if holder then
		holder.Position = UDim2.new(0, 10, 0, 22)
		holder.Size = UDim2.new(1, -20, 0, 64)
		local listLayout = holder:FindFirstChildOfClass("UIListLayout")
		if listLayout then
			listLayout:Destroy()
		end
		if not holder:FindFirstChildOfClass("UIGridLayout") then
			create("UIGridLayout", {
				CellPadding = UDim2.new(0, 4, 0, 4),
				CellSize = UDim2.new(0.25, -3, 0, 30),
				FillDirectionMaxCells = 4,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = holder,
			})
		end
	end

	for _, entry in ipairs(tracerSliders.trainingPresetButtons) do
		local badgeText = getTrainerPresetBadgeText(entry.value)
		entry.button:SetAttribute("TrainerPresetButton", true)
		entry.button:SetAttribute("PresetColor", getTrainerPresetColor(entry.value))
		local displayName = (entry.value == "Custom 1" or entry.value == "Custom 2") and getTrainerCustomLabel(entry.value) or entry.value
		entry.button.Size = UDim2.new(1, 0, 1, 0)
		entry.button.Text = string.format("%s\n%s", displayName, badgeText)
		entry.button.TextSize = 7
		entry.button.Font = Enum.Font.GothamBold
		entry.button.TextYAlignment = Enum.TextYAlignment.Center
		entry.button.TextWrapped = true
		entry.button.RichText = false
	end
end

function getActiveTrainerPresetName()
	for slotName, settings in pairs(TRAINER_CUSTOM_PRESETS) do
		local savedSettings = type(settings) == "table" and settings.settings or nil
		if type(savedSettings) == "table"
			and (savedSettings.trainerDrillType or CONFIG.trainerDrillType) == CONFIG.trainerDrillType
			and (savedSettings.trainerReactionTimer ~= false) == CONFIG.trainerReactionTimer
			and (savedSettings.trainerHitWindow or CONFIG.trainerHitWindow) == CONFIG.trainerHitWindow
			and (savedSettings.trainerChallengeMode == true) == CONFIG.trainerChallengeMode
			and (savedSettings.trainerChallengeDuration or CONFIG.trainerChallengeDuration) == CONFIG.trainerChallengeDuration
			and (savedSettings.trainerShrinkingTargets == true) == CONFIG.trainerShrinkingTargets
			and (savedSettings.trainerTrackHoldTime or CONFIG.trainerTrackHoldTime) == CONFIG.trainerTrackHoldTime
			and (savedSettings.trainerTargetSpeed or CONFIG.trainerTargetSpeed) == CONFIG.trainerTargetSpeed then
			return slotName
		end
	end
	if CONFIG.trainerDrillType == "Click" and CONFIG.trainerShrinkingTargets and CONFIG.trainerHitWindow <= 10 and CONFIG.trainerTargetSpeed <= 110 then
		return "Micro Adjust"
	end
	if CONFIG.trainerDrillType == "Click" and not CONFIG.trainerShrinkingTargets and CONFIG.trainerHitWindow <= 18 and CONFIG.trainerChallengeDuration <= 20 and CONFIG.trainerTargetSpeed >= 160 then
		return "Speed"
	end
	if CONFIG.trainerDrillType == "Track" and CONFIG.trainerTrackHoldTime >= 3 and CONFIG.trainerTargetSpeed >= 140 then
		return "Tracking"
	end
	if CONFIG.trainerDrillType == "Click" and CONFIG.trainerShrinkingTargets and CONFIG.trainerHitWindow <= 14 then
		return "Precision"
	end
	if CONFIG.trainerDrillType == "Click" and not CONFIG.trainerShrinkingTargets and CONFIG.trainerHitWindow >= 20 then
		return "Warmup"
	end
	return nil
end

function applyTrainerPreset(presetName)
	if TRAINER_CUSTOM_PRESETS[presetName] ~= nil then
		if not applyTrainerPresetSettings(TRAINER_CUSTOM_PRESETS[presetName].settings) then
			showToast("Aim Trainer", string.format("%s is empty", getTrainerCustomLabel(presetName)), THEME.muted)
			return
		end
		resetTrainerSession()
		syncUiFromConfig()
		saveSettings()
		showToast("Aim Trainer", string.format("%s preset applied", getTrainerCustomLabel(presetName)), getTrainerPresetColor(presetName))
		return
	end

	for _, preset in ipairs(TRAINER_PRESET_DEFS) do
		if preset.name == presetName then
			preset.apply()
			resetTrainerSession()
			syncUiFromConfig()
			saveSettings()
			showToast("Aim Trainer", string.format("%s preset applied", preset.name), THEME.accent)
			return
		end
	end
end

styleTrainerPresetButtons()

function updateTrainerVisuals(deltaTime)
	local trainer = ensureTrainerState()
	if not trainer then
		hideTrainerVisuals()
		return
	end
	trainer.spreadValue = math.max(0, trainer.spreadValue - (deltaTime * 20))
	trainer.recoilKick = math.max(0, trainer.recoilKick - (deltaTime * 26))
	trainer.recoilOffset = trainer.recoilOffset:Lerp(Vector2.zero, math.clamp(deltaTime * 9, 0, 1))

	if not gui.Enabled then
		hideTrainerVisuals()
		return
	end

	local center = getMouseScreenPosition(getCamera()) or Vector2.zero

	if CONFIG.aimTrainerMode then
		if not trainer.targetPosition then
			spawnTrainerTarget()
		end
		local targetDot = ensureTrainerCircle("targetDot", true)
		local hitWindowCircle = ensureTrainerCircle("hitWindowCircle", false)
		local camera = getCamera()
		if CONFIG.trainerDrillType == "Track" and trainer.targetPosition and camera then
			local viewport = camera.ViewportSize
			local radius = CONFIG.trainerShrinkingTargets and math.max(3, 8 - (trainer.hits * 0.2)) or 6
			local nextPosition = trainer.targetPosition + (trainer.targetVelocity * deltaTime)
			if nextPosition.X <= radius or nextPosition.X >= viewport.X - radius then
				trainer.targetVelocity = Vector2.new(-trainer.targetVelocity.X, trainer.targetVelocity.Y)
			end
			if nextPosition.Y <= radius + 24 or nextPosition.Y >= viewport.Y - radius then
				trainer.targetVelocity = Vector2.new(trainer.targetVelocity.X, -trainer.targetVelocity.Y)
			end
			if trainer.targetVelocity.Magnitude <= 0.001 then
				trainer.targetVelocity = Vector2.new(CONFIG.trainerTargetSpeed, 0)
			else
				trainer.targetVelocity = trainer.targetVelocity.Unit * CONFIG.trainerTargetSpeed
			end
			trainer.targetPosition = trainer.targetPosition + (trainer.targetVelocity * deltaTime)
		end
		if targetDot and trainer.targetPosition then
			local targetRadius = CONFIG.trainerShrinkingTargets and math.max(3, 8 - (trainer.hits * 0.2)) or 6
			targetDot.Visible = true
			targetDot.Color = THEME.focus
			targetDot.Radius = targetRadius
			targetDot.Position = trainer.targetPosition
			targetDot.Transparency = 1
			if CONFIG.trainerDrillType == "Track" then
				updateTrainerProgressRing(trainer.targetPosition, targetRadius + 8, math.min(CONFIG.trainerTrackHoldTime, trainer.holdProgress or 0) / math.max(CONFIG.trainerTrackHoldTime, 1))
			elseif trainer.trackProgressRing then
				for _, segment in ipairs(trainer.trackProgressRing) do
					segment.Visible = false
				end
			end
		end
		if hitWindowCircle and trainer.targetPosition then
			hitWindowCircle.Visible = true
			hitWindowCircle.Color = CONFIG.trainerDrillType == "Track" and THEME.focus or THEME.accent
			hitWindowCircle.Thickness = 1.5
			hitWindowCircle.Radius = CONFIG.trainerDrillType == "Track" and (CONFIG.trainerHitWindow + 2) or CONFIG.trainerHitWindow
			hitWindowCircle.Position = trainer.targetPosition
			hitWindowCircle.Transparency = 0.75
		end

		if CONFIG.trainerDrillType == "Track" and trainer.targetPosition and center then
			local hoverPosition = center
			if (hoverPosition - trainer.targetPosition).Magnitude <= (CONFIG.trainerHitWindow + 2) then
				trainer.holdProgress = math.min(CONFIG.trainerTrackHoldTime, trainer.holdProgress + deltaTime)
				if trainer.holdProgress >= CONFIG.trainerTrackHoldTime then
					recordTrainerTrackSuccess(math.floor((tick() - trainer.targetSpawnAt) * 1000 + 0.5))
					spawnTrainerTarget()
				end
			else
				if trainer.holdProgress > 0 then
					recordTrainerTrackBreak()
				end
				trainer.holdProgress = 0
			end
		end
	else
		trainer.targetPosition = nil
		trainer.holdProgress = 0
		local targetDot = trainer.targetDot
		local hitWindowCircle = trainer.hitWindowCircle
		if targetDot then
			targetDot.Visible = false
		end
		if hitWindowCircle then
			hitWindowCircle.Visible = false
		end
		if trainer.trackProgressRing then
			for _, segment in ipairs(trainer.trackProgressRing) do
				segment.Visible = false
			end
		end
	end

	if CONFIG.spreadVisualizer then
		local spreadCircle = ensureTrainerCircle("spreadCircle", false)
		if spreadCircle then
			spreadCircle.Visible = true
			spreadCircle.Color = THEME.muted
			spreadCircle.Thickness = 1.2
			spreadCircle.Position = center
			spreadCircle.Radius = 10 + trainer.spreadValue
			spreadCircle.Transparency = 0.65
		end
	elseif trainer.spreadCircle then
		trainer.spreadCircle.Visible = false
	end

	if CONFIG.recoilVisualizer then
		local recoilMarker = ensureTrainerCircle("recoilMarker", true)
		if recoilMarker then
			recoilMarker.Visible = true
			recoilMarker.Color = THEME.accent
			recoilMarker.Radius = 3
			recoilMarker.Position = center + trainer.recoilOffset
			recoilMarker.Transparency = math.clamp(0.35 + (trainer.recoilKick * 0.06), 0.35, 1)
		end
	elseif trainer.recoilMarker then
		trainer.recoilMarker.Visible = false
	end

	if CONFIG.trainerChallengeMode and trainer.challengeEndsAt and tick() >= trainer.challengeEndsAt then
		CONFIG.trainerChallengeMode = false
		trainer.challengeEndsAt = nil
		trainer.targetPosition = nil
		trainer.lastResults = buildTrainerChallengeSummary()
		pushTrainerHistoryEntry(trainer.lastResults)
		if tracerSliders.trainingChallengeToggle then
			setToggleState(tracerSliders.trainingChallengeToggle, false)
		end
		saveSettings()
		showToast(
			"Aim Trainer",
			string.format(
				"Challenge complete\nHits %d | Misses %d | Accuracy %d%%\nClick Best %s | Track Best %s",
				trainer.lastResults.hits or 0,
				trainer.lastResults.misses or 0,
				trainer.lastResults.accuracy or 0,
				trainer.lastResults.clickBest and (tostring(trainer.lastResults.clickBest) .. "ms") or "--",
				trainer.lastResults.trackBest and (tostring(trainer.lastResults.trackBest) .. "ms") or "--"
			),
			THEME.accent
		)
	end
end

updateControlAvailability = function()
	local effectiveBoxMode = getEffectiveBoxMode()
	local usingChamsMode = isChamsBoxMode(effectiveBoxMode)
	setRowEnabled(miniHudLabels.utility.displayToggles.boxMode, CONFIG.showBoxes)
	setRowEnabled(miniHudLabels.utility.displayToggles.fillTransparency.bar, CONFIG.showBoxes and usingChamsMode)
	setRowEnabled(miniHudLabels.utility.displayToggles.outlineTransparency.bar, CONFIG.showBoxes and usingChamsMode)
	setRowEnabled(miniHudLabels.utility.displayToggles.headDotSize.bar, CONFIG.showHeadDot)
	setRowEnabled(miniHudLabels.utility.displayToggles.targetCardCompact, CONFIG.showTargetCard)
	setRowEnabled(miniHudLabels.utility.displayToggles.textStack, CONFIG.showTargetCard)
	setRowEnabled(tracerSliders.tracerOriginButton, CONFIG.showTracers)
	setRowEnabled(tracerSliders.style, CONFIG.showTracers)
	setRowEnabled(tracerSliders.thickness.bar, CONFIG.showTracers)
	setRowEnabled(tracerSliders.transparency.bar, CONFIG.showTracers)
	setRowEnabled(tracerSliders.crosshairStyleButton, CONFIG.showCrosshair)
	setRowEnabled(crosshairColorButtons[1].button.Parent.Parent, CONFIG.showCrosshair)
	setRowEnabled(tracerSliders.crosshairThickness.bar, CONFIG.showCrosshair)
	setRowEnabled(tracerSliders.crosshairSizeSlider.bar, CONFIG.showCrosshair)
	setRowEnabled(tracerSliders.crosshairGap.bar, CONFIG.showCrosshair)
	setRowEnabled(tracerSliders.fovCircleSlider.bar, CONFIG.showFovCircle)
	setRowEnabled(tracerSliders.fovThickness.bar, CONFIG.showFovCircle)
	setRowEnabled(tracerSliders.fovTransparency.bar, CONFIG.showFovCircle)
	setRowEnabled(tracerSliders.fovCircleSlider.reset, CONFIG.showFovCircle)
	setRowEnabled(tracerSliders.trainingDrillType, CONFIG.aimTrainerMode)
	setRowEnabled(tracerSliders.trainingReactionToggle, CONFIG.aimTrainerMode)
	setRowEnabled(tracerSliders.trainingCardsRow, CONFIG.aimTrainerMode)
	setRowEnabled(tracerSliders.trainingPresetButtons[1].button.Parent.Parent, CONFIG.aimTrainerMode)
	setRowEnabled(tracerSliders.trainingSaveButtons[1].button.Parent.Parent, CONFIG.aimTrainerMode)
	setRowEnabled(tracerSliders.trainingRenameRow, CONFIG.aimTrainerMode)
	setRowEnabled(tracerSliders.trainingHitWindow.bar, CONFIG.aimTrainerMode and CONFIG.trainerDrillType == "Click")
	setRowEnabled(tracerSliders.trainingChallengeToggle, CONFIG.aimTrainerMode)
	setRowEnabled(tracerSliders.trainingChallengeDuration.bar, CONFIG.aimTrainerMode and CONFIG.trainerChallengeMode)
	setRowEnabled(tracerSliders.trainingShrinkingToggle, CONFIG.aimTrainerMode)
	setRowEnabled(tracerSliders.trainingTrackHoldTime.bar, CONFIG.aimTrainerMode and CONFIG.trainerDrillType == "Track")
	setRowEnabled(tracerSliders.trainingTargetSpeed.bar, CONFIG.aimTrainerMode and CONFIG.trainerDrillType == "Track")
	setRowEnabled(tracerSliders.trainingReset, CONFIG.aimTrainerMode)
	setRowEnabled(playerButtons.walkSpeed.bar, CONFIG.walkSpeedEnabled)
	setRowEnabled(playerButtons.flySpeed.bar, CONFIG.fly)
end

syncUiFromConfig = function()
	setToggleState(miniHudLabels.utility.controls.enabledToggle, CONFIG.enabled)
	setToggleState(miniHudLabels.utility.displayToggles.names, CONFIG.showNames)
	setToggleState(miniHudLabels.utility.displayToggles.distance, CONFIG.showDistance)
	setToggleState(miniHudLabels.utility.displayToggles.fade, CONFIG.distanceFade)
	setToggleState(miniHudLabels.utility.displayToggles.health, CONFIG.showHealth)
	setToggleState(miniHudLabels.utility.displayToggles.weapon, CONFIG.showWeapon)
	setToggleState(miniHudLabels.utility.displayToggles.skeleton, CONFIG.showSkeleton)
	setToggleState(miniHudLabels.utility.displayToggles.headDot, CONFIG.showHeadDot)
	setSliderState(miniHudLabels.utility.displayToggles.headDotSize, CONFIG.headDotSize)
	setToggleState(miniHudLabels.utility.displayToggles.focus, CONFIG.showFocusTarget)
	setToggleState(miniHudLabels.utility.displayToggles.boxes, CONFIG.showBoxes)
	setSliderState(miniHudLabels.utility.displayToggles.fillTransparency, math.floor((CONFIG.fillTransparency or 0) * 100 + 0.5))
	setSliderState(miniHudLabels.utility.displayToggles.outlineTransparency, math.floor((CONFIG.outlineTransparency or 0) * 100 + 0.5))
	setToggleState(miniHudLabels.utility.displayToggles.targetCard, CONFIG.showTargetCard)
	setToggleState(miniHudLabels.utility.displayToggles.targetCardCompact, CONFIG.targetCardCompact)
	miniHudLabels.utility.displayToggles.textStack.Text = CONFIG.textStackMode
	tracerSliders.threatMode.Text = CONFIG.threatMode
	setToggleState(tracerSliders.visibilityToggle, CONFIG.visibilityCheck)
	setToggleState(tracerSliders.tracersToggle, CONFIG.showTracers)
	setToggleState(tracerSliders.focusLock, CONFIG.focusLock)
	tracerSliders.tracerOriginButton.Text = CONFIG.tracerOriginMode
	tracerSliders.style.Text = CONFIG.tracerStyle
	setSliderState(tracerSliders.thickness, CONFIG.tracerThickness)
	setSliderState(tracerSliders.transparency, CONFIG.tracerTransparency)
	setSliderState(tracerSliders.maxDistance, CONFIG.maxDistance)
	setSliderState(tracerSliders.fovThickness, CONFIG.fovCircleThickness)
	setSliderState(tracerSliders.fovTransparency, CONFIG.fovCircleTransparency)
	setToggleState(tracerSliders.lookDirectionToggle, CONFIG.showLookDirection)
	setToggleState(tracerSliders.crosshairToggle, CONFIG.showCrosshair)
	setToggleState(tracerSliders.fovCircleToggle, CONFIG.showFovCircle)
	setToggleState(tracerSliders.trainingToggle, CONFIG.aimTrainerMode)
	setOptionButtonsState(tracerSliders.trainingPresetButtons, getActiveTrainerPresetName())
	setOptionButtonsState(tracerSliders.trainingSaveButtons, nil)
	if tracerSliders.trainingPresetButtons and tracerSliders.trainingPresetButtons[1] then
		local presetHolder = tracerSliders.trainingPresetButtons[1].button.Parent
		local presetRow = presetHolder and presetHolder.Parent
		local presetLabel = presetRow and presetRow:FindFirstChildWhichIsA("TextLabel")
		if presetLabel then
			local activeTrainerPreset = getActiveTrainerPresetName()
			if activeTrainerPreset then
				presetLabel.Text = "TRAIN PRESET"
				presetLabel.TextColor3 = THEME.muted
			else
				presetLabel.Text = "TRAIN PRESET  [CUSTOM]"
				presetLabel.TextColor3 = THEME.focus
			end
		end
	end
	if tracerSliders.trainingSaveButtons then
		for _, entry in ipairs(tracerSliders.trainingSaveButtons) do
			local filled = type(TRAINER_CUSTOM_PRESETS[entry.value]) == "table" and type(TRAINER_CUSTOM_PRESETS[entry.value].settings) == "table"
			entry.button.TextColor3 = filled and getTrainerPresetColor(entry.value) or THEME.muted
		end
	end
	if tracerSliders.trainingRenameButtons then
		for slotName, button in pairs(tracerSliders.trainingRenameButtons) do
			button.Text = slotName == "Custom 1" and "SLOT 1" or "SLOT 2"
			button.TextColor3 = getTrainerPresetColor(slotName)
		end
	end
	tracerSliders.trainingDrillType.Text = CONFIG.trainerDrillType or "Click"
	setToggleState(tracerSliders.trainingReactionToggle, CONFIG.trainerReactionTimer)
	setToggleState(tracerSliders.trainingChallengeToggle, CONFIG.trainerChallengeMode)
	setToggleState(tracerSliders.trainingShrinkingToggle, CONFIG.trainerShrinkingTargets)
	setToggleState(tracerSliders.recoilVisualizerToggle, CONFIG.recoilVisualizer)
	setToggleState(tracerSliders.spreadVisualizerToggle, CONFIG.spreadVisualizer)
	setToggleState(miniHudLabels.utility.controls.miniHudToggle, CONFIG.showMiniHud)
	setToggleState(viewButtons.removeZoomLimit, CONFIG.removeZoomLimit)
	setToggleState(playerButtons.walkSpeedToggle, CONFIG.walkSpeedEnabled)
	setToggleState(playerButtons.infiniteJump, CONFIG.infiniteJump)
	setToggleState(playerButtons.noclip, CONFIG.noclip)
	setToggleState(playerButtons.fly, CONFIG.fly)
	setToggleState(playerButtons.clickTeleport, CONFIG.clickTeleport)
	setToggleState(miniHudLabels.utility.antiAfk, CONFIG.antiAfk)
	setToggleState(miniHudLabels.utility.autoLoadGamePreset, CONFIG.autoLoadGamePreset)
	setToggleState(miniHudLabels.utility.performanceToggles.mode, CONFIG.performanceMode)
	setToggleState(miniHudLabels.utility.performanceToggles.materials, CONFIG.simplifyMaterials)
	setToggleState(miniHudLabels.utility.performanceToggles.textures, CONFIG.hideTextures)
	setToggleState(miniHudLabels.utility.performanceToggles.effects, CONFIG.hideEffects)
	setToggleState(miniHudLabels.utility.performanceToggles.shadows, CONFIG.disableShadows)
	setToggleState(miniHudLabels.utility.controls.minimalToggle, CONFIG.minimalMode)
	refreshPresetDropdown()
	applyMinimalMode(CONFIG.minimalMode, true)
	updateControlAvailability()
	setSliderState(tracerSliders.fovCircleSlider, CONFIG.fovRadius)
	setSliderState(tracerSliders.trainingHitWindow, CONFIG.trainerHitWindow)
	setSliderState(tracerSliders.trainingChallengeDuration, CONFIG.trainerChallengeDuration)
	setSliderState(tracerSliders.trainingTrackHoldTime, CONFIG.trainerTrackHoldTime)
	setSliderState(tracerSliders.trainingTargetSpeed, CONFIG.trainerTargetSpeed)
	setSliderState(miniHudLabels.utility.controls.cameraFovSlider, CONFIG.cameraFov)
	setSliderState(playerButtons.walkSpeed, CONFIG.walkSpeed)
	setSliderState(playerButtons.flySpeed, CONFIG.flySpeed)
	tracerSliders.crosshairStyleButton.Text = string.format("< %s >", CONFIG.crosshairStyle)
	setOptionButtonsState(crosshairColorButtons, CONFIG.crosshairColor)
	setSliderState(tracerSliders.crosshairThickness, CONFIG.crosshairThickness)
	setSliderState(tracerSliders.crosshairSizeSlider, CONFIG.crosshairSize)
	setSliderState(tracerSliders.crosshairGap, CONFIG.crosshairGap)
	miniHudLabels.utility.displayToggles.boxMode.Text = tostring(getEffectiveBoxMode() or normalizeBoxMode(CONFIG.boxMode) or "Chams")
	miniHudLabels.saveStatusValue.Text = canUseFileApi() and "AUTO SAVE" or "MEMORY"
	refreshNamedConfigList()
	watermark.Visible = uiReady and not CONFIG.minimalMode
	miniHud.Visible = uiReady and CONFIG.showMiniHud
	if overlayTools then
		overlayTools.updateReleasePanel(miniHudLabels.utility.updatePanel)
	end
	updateViewUi()
end

miniHudLabels.utility.controls.presetDropdown.arrow.MouseButton1Click:Connect(function()
	setPresetDropdownOpen(not miniHudLabels.utility.controls.presetDropdown.open)
end)

for index, option in ipairs(miniHudLabels.utility.controls.presetDropdown.options) do
	miniHudLabels.bindTooltip(option, PRESETS[index].description or PRESETS[index].name)
	option.MouseButton1Click:Connect(function()
		currentPresetIndex = index
		PRESETS[currentPresetIndex].apply()
		setPresetDropdownOpen(false)
		syncUiFromConfig()
		applyPerformanceSettings()
		refreshAllEsp()
		saveSettings()
		showToast("Preset", string.format("%s applied", PRESETS[currentPresetIndex].name), THEME.accent)
	end)
end

miniHudLabels.utility.displayToggles.boxMode.MouseButton1Click:Connect(function()
	local currentIndex = table.find(BOX_MODE_OPTIONS, CONFIG.boxMode) or 1
	currentIndex = currentIndex % #BOX_MODE_OPTIONS + 1
	CONFIG.boxMode = BOX_MODE_OPTIONS[currentIndex]
	miniHudLabels.utility.displayToggles.boxMode.Text = tostring(CONFIG.boxMode or "Chams")
	resetAllBoxEspVisuals()
	refreshAllEsp()
	saveSettings()
end)

miniHudLabels.utility.displayToggles.textStack.MouseButton1Click:Connect(function()
	local options = { "Inline", "Stacked" }
	local currentIndex = table.find(options, CONFIG.textStackMode) or 1
	currentIndex = currentIndex % #options + 1
	CONFIG.textStackMode = options[currentIndex]
	miniHudLabels.utility.displayToggles.textStack.Text = CONFIG.textStackMode
	refreshAllEsp()
	saveSettings()
end)

tracerSliders.threatMode.MouseButton1Click:Connect(function()
	local options = { "Closest", "Visible", "Armed", "Smart" }
	local currentIndex = table.find(options, CONFIG.threatMode) or 1
	currentIndex = currentIndex % #options + 1
	CONFIG.threatMode = options[currentIndex]
	tracerSliders.threatMode.Text = CONFIG.threatMode
	refreshAllEsp()
	saveSettings()
	showToast("Setting Updated", string.format("Threat Mode set to %s", CONFIG.threatMode), THEME.accent)
end)

tracerSliders.tracerOriginButton.MouseButton1Click:Connect(function()
	local currentIndex = table.find(TRACER_ORIGIN_OPTIONS, CONFIG.tracerOriginMode) or 1
	currentIndex = currentIndex % #TRACER_ORIGIN_OPTIONS + 1
	CONFIG.tracerOriginMode = TRACER_ORIGIN_OPTIONS[currentIndex]
	tracerSliders.tracerOriginButton.Text = CONFIG.tracerOriginMode
	refreshAllEsp()
	saveSettings()
	showToast("Setting Updated", string.format("Tracer Origin set to %s", CONFIG.tracerOriginMode), THEME.accent)
end)

tracerSliders.style.MouseButton1Click:Connect(function()
	local options = { "Direct", "Split" }
	local currentIndex = table.find(options, CONFIG.tracerStyle) or 1
	currentIndex = currentIndex % #options + 1
	CONFIG.tracerStyle = options[currentIndex]
	tracerSliders.style.Text = CONFIG.tracerStyle
	saveSettings()
	refreshAllEsp()
	showToast("Setting Updated", string.format("Tracer Style set to %s", CONFIG.tracerStyle), THEME.accent)
end)

tracerSliders.trainingDrillType.MouseButton1Click:Connect(function()
	local options = { "Click", "Track" }
	local currentIndex = table.find(options, CONFIG.trainerDrillType) or 1
	currentIndex = currentIndex % #options + 1
	CONFIG.trainerDrillType = options[currentIndex]
	resetTrainerSession()
	syncUiFromConfig()
	saveSettings()
	showToast("Aim Trainer", string.format("Drill Type set to %s", CONFIG.trainerDrillType), THEME.accent)
end)

for _, entry in ipairs(tracerSliders.trainingPresetButtons) do
	for _, preset in ipairs(TRAINER_PRESET_DEFS) do
		if preset.name == entry.value then
			miniHudLabels.bindTooltip(entry.button, preset.description)
			break
		end
	end
	if entry.value == "Custom 1" or entry.value == "Custom 2" then
		miniHudLabels.bindTooltip(entry.button, function()
			local saved = TRAINER_CUSTOM_PRESETS[entry.value]
			return (type(saved) == "table" and type(saved.settings) == "table")
				and string.format("%s: saved custom trainer setup", getTrainerCustomLabel(entry.value))
				or string.format("%s: empty slot", getTrainerCustomLabel(entry.value))
		end)
	end
	entry.button.MouseButton1Click:Connect(function()
		applyTrainerPreset(entry.value)
	end)
end

for _, entry in ipairs(tracerSliders.trainingSaveButtons) do
	miniHudLabels.bindTooltip(entry.button, function()
		local saved = TRAINER_CUSTOM_PRESETS[entry.value]
		return (type(saved) == "table" and type(saved.settings) == "table")
			and string.format("Overwrite %s with current trainer settings", getTrainerCustomLabel(entry.value))
			or string.format("Save current trainer settings into %s", getTrainerCustomLabel(entry.value))
	end)
	entry.button.MouseButton1Click:Connect(function()
		if saveTrainerCustomPreset(entry.value) then
			syncUiFromConfig()
			showToast("Aim Trainer", string.format("Saved current setup to %s", getTrainerCustomLabel(entry.value)), getTrainerPresetColor(entry.value))
		end
	end)
end

for slotName, button in pairs(tracerSliders.trainingRenameButtons) do
	miniHudLabels.bindTooltip(button, function()
		return string.format("Apply the name and badge fields to %s", getTrainerCustomLabel(slotName))
	end)
	button.MouseButton1Click:Connect(function()
		local renamed = renameTrainerCustomPreset(slotName, tracerSliders.trainingRenameInput.Text)
		local retagged = retagTrainerCustomPreset(slotName, tracerSliders.trainingBadgeInput.Text)
		if renamed and retagged then
			tracerSliders.trainingRenameInput.Text = ""
			tracerSliders.trainingBadgeInput.Text = ""
			styleTrainerPresetButtons()
			syncUiFromConfig()
			showToast("Aim Trainer", string.format("Updated %s [%s]", getTrainerCustomLabel(slotName), getTrainerCustomBadge(slotName)), getTrainerPresetColor(slotName))
		end
	end)
end

miniHudLabels.utility.controls.cameraFovSlider.reset.MouseButton1Click:Connect(function()
	CONFIG.cameraFov = DEFAULT_CAMERA_FOV
	setSliderState(miniHudLabels.utility.controls.cameraFovSlider, CONFIG.cameraFov)
	applyCameraFov()
	saveSettings()
	showToast("Camera FOV Reset", string.format("Camera %d", CONFIG.cameraFov), THEME.accent)
end)

tracerSliders.fovCircleSlider.reset.MouseButton1Click:Connect(function()
	CONFIG.fovRadius = DEFAULT_FOV_RADIUS
	setSliderState(tracerSliders.fovCircleSlider, CONFIG.fovRadius)
	updateCrosshair()
	saveSettings()
	showToast("FOV Circle Reset", string.format("Circle %d", CONFIG.fovRadius), THEME.accent)
end)

tracerSliders.crosshairStyleButton.MouseButton1Click:Connect(function()
	local currentIndex = table.find(CROSSHAIR_OPTIONS, CONFIG.crosshairStyle) or 1
	currentIndex = currentIndex % #CROSSHAIR_OPTIONS + 1
	CONFIG.crosshairStyle = CROSSHAIR_OPTIONS[currentIndex]
	tracerSliders.crosshairStyleButton.Text = string.format("< %s >", CONFIG.crosshairStyle)
	updateCrosshair()
	saveSettings()
	showToast("Setting Updated", string.format("Crosshair Style set to %s", CONFIG.crosshairStyle), THEME.accent)
end)

viewButtons.spectate.main.MouseButton1Click:Connect(function()
	local list = viewButtons.spectate.list
	local search = viewButtons.spectate.search
	local scroller = viewButtons.spectate.scroller
	list.Visible = not list.Visible

	if not list.Visible then
		return
	end

	local function rebuildSpectateList()
		local filter = search.Text:lower()

		for _, child in ipairs(scroller:GetChildren()) do
			if child:IsA("TextButton") or child:IsA("TextLabel") then
				child:Destroy()
			end
		end

		local candidates = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LOCAL_PLAYER and (filter == "" or player.Name:lower():find(filter, 1, true)) then
				table.insert(candidates, player)
			end
		end

		table.sort(candidates, function(a, b)
			return a.Name:lower() < b.Name:lower()
		end)

		if #candidates == 0 then
			create("TextLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Font = Enum.Font.GothamMedium,
				Size = UDim2.new(1, 0, 0, 18),
				Text = "No players",
				TextColor3 = THEME.muted,
				TextSize = 9,
				ZIndex = 21,
				Parent = scroller,
			})
			scroller.CanvasPosition = Vector2.new(0, 0)
			return
		end

		for _, player in ipairs(candidates) do
			local option = create("TextButton", {
				AutoButtonColor = false,
				BackgroundColor3 = player == viewState.spectateTarget and THEME.accentSoft or Color3.fromRGB(35, 40, 53),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 20),
				Font = Enum.Font.GothamBold,
				Text = truncateText(player.Name, 18),
				TextColor3 = THEME.text,
				TextSize = 9,
				ZIndex = 21,
				Parent = scroller,
			})
			addCorner(option, 4)
			addStroke(option, THEME.border, 0.35, 1)

			option.MouseButton1Click:Connect(function()
				setSpectateTarget(player)
				list.Visible = false
				showToast("View", string.format("Spectating %s", player.Name), THEME.accent)
			end)
		end

		scroller.CanvasPosition = Vector2.new(0, 0)
	end

	search.Text = ""
	rebuildSpectateList()

	if viewButtons.spectate.searchConnection then
		viewButtons.spectate.searchConnection:Disconnect()
	end

	viewButtons.spectate.searchConnection = search:GetPropertyChangedSignal("Text"):Connect(function()
		if list.Visible then
			rebuildSpectateList()
		end
	end)
end)

viewButtons.freeCam.MouseButton1Click:Connect(function()
	toggleFreeCam()
end)

do
	local function stepSpectate(direction)
		local candidates = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LOCAL_PLAYER then
				table.insert(candidates, player)
			end
		end

		if #candidates == 0 then
			setSpectateTarget(nil)
			showToast("View", "No players available to spectate", THEME.muted)
			return
		end

		table.sort(candidates, function(a, b)
			return a.Name:lower() < b.Name:lower()
		end)

		local index = 1
		for currentIndex, player in ipairs(candidates) do
			if player == viewState.spectateTarget then
				index = currentIndex
				break
			end
		end

		index = ((index - 1 + direction) % #candidates) + 1
		setSpectateTarget(candidates[index])
		showToast("View", string.format("Spectating %s", candidates[index].Name), THEME.accent)
	end

	viewButtons.nav.prev.MouseButton1Click:Connect(function()
		stepSpectate(-1)
	end)

	viewButtons.nav.next.MouseButton1Click:Connect(function()
		stepSpectate(1)
	end)
end

viewButtons.spectate.off.MouseButton1Click:Connect(function()
	setSpectateTarget(nil)
	viewButtons.spectate.list.Visible = false
	viewButtons.spectate.search.Text = ""
	showToast("View", "Spectate disabled", THEME.muted)
end)

viewButtons.reset.MouseButton1Click:Connect(function()
	viewState.spectateTarget = nil
	viewState.freeCamEnabled = false
	viewState.lookHeld = false
	viewState.moveForward = 0
	viewState.moveRight = 0
	viewState.moveUp = 0
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	setLocalMovementSuppressed(false)
	restoreLocalCamera()
	resetViewSettings()
	updateViewUi()
	updateMouseIconVisibility()
	setSliderState(viewButtons.speed, CONFIG.freeCamSpeed)
	saveSettings()
	showToast("View Reset", string.format("Freecam speed %d", CONFIG.freeCamSpeed), THEME.accent)
end)

playerButtons.reset.MouseButton1Click:Connect(function()
	resetPlayerSettings()
	stopFly()
	syncUiFromConfig()
	saveSettings()
	showToast("Player Reset", "Movement settings restored", THEME.accent)
end)

for _, entry in ipairs(crosshairColorButtons) do
	entry.button.MouseButton1Click:Connect(function()
		CONFIG.crosshairColor = entry.value
		setOptionButtonsState(crosshairColorButtons, CONFIG.crosshairColor)
		updateCrosshair()
		saveSettings()

		local accentColor = THEME.accent
		for _, option in ipairs(CROSSHAIR_COLOR_OPTIONS) do
			if option.name == CONFIG.crosshairColor then
				accentColor = option.color
				break
			end
		end

		showToast("Setting Updated", string.format("Crosshair Color set to %s", CONFIG.crosshairColor), accentColor)
	end)
end

do
	function updateTrainerHitWindowFromX(positionX)
		local bar = tracerSliders.trainingHitWindow.bar
		local relative = math.clamp(positionX - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
		local alpha = 0
		if bar.AbsoluteSize.X > 0 then
			alpha = relative / bar.AbsoluteSize.X
		end
		local value = math.floor(tracerSliders.trainingHitWindow.min + ((tracerSliders.trainingHitWindow.max - tracerSliders.trainingHitWindow.min) * alpha) + 0.5)
		value = math.clamp(value, tracerSliders.trainingHitWindow.min, tracerSliders.trainingHitWindow.max)

		if CONFIG.trainerHitWindow ~= value then
			CONFIG.trainerHitWindow = value
			saveSettings()
		end

		setSliderState(tracerSliders.trainingHitWindow, CONFIG.trainerHitWindow)
	end

	bindSliderDragStart(tracerSliders.trainingHitWindow.bar, updateTrainerHitWindowFromX)

	function updateTrainerChallengeDurationFromX(positionX)
		local bar = tracerSliders.trainingChallengeDuration.bar
		local relative = math.clamp(positionX - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
		local alpha = 0
		if bar.AbsoluteSize.X > 0 then
			alpha = relative / bar.AbsoluteSize.X
		end
		local value = math.floor(tracerSliders.trainingChallengeDuration.min + ((tracerSliders.trainingChallengeDuration.max - tracerSliders.trainingChallengeDuration.min) * alpha) + 0.5)
		value = math.clamp(value, tracerSliders.trainingChallengeDuration.min, tracerSliders.trainingChallengeDuration.max)

		if CONFIG.trainerChallengeDuration ~= value then
			CONFIG.trainerChallengeDuration = value
			saveSettings()
		end

		setSliderState(tracerSliders.trainingChallengeDuration, CONFIG.trainerChallengeDuration)
	end

	bindSliderDragStart(tracerSliders.trainingChallengeDuration.bar, updateTrainerChallengeDurationFromX)

	function updateTrainerTrackHoldFromX(positionX)
		local bar = tracerSliders.trainingTrackHoldTime.bar
		local relative = math.clamp(positionX - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
		local alpha = bar.AbsoluteSize.X > 0 and (relative / bar.AbsoluteSize.X) or 0
		local value = math.floor(tracerSliders.trainingTrackHoldTime.min + ((tracerSliders.trainingTrackHoldTime.max - tracerSliders.trainingTrackHoldTime.min) * alpha) + 0.5)
		value = math.clamp(value, tracerSliders.trainingTrackHoldTime.min, tracerSliders.trainingTrackHoldTime.max)
		if CONFIG.trainerTrackHoldTime ~= value then
			CONFIG.trainerTrackHoldTime = value
			saveSettings()
		end
		setSliderState(tracerSliders.trainingTrackHoldTime, CONFIG.trainerTrackHoldTime)
	end

	function updateTrainerTargetSpeedFromX(positionX)
		local bar = tracerSliders.trainingTargetSpeed.bar
		local relative = math.clamp(positionX - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
		local alpha = bar.AbsoluteSize.X > 0 and (relative / bar.AbsoluteSize.X) or 0
		local value = math.floor(tracerSliders.trainingTargetSpeed.min + ((tracerSliders.trainingTargetSpeed.max - tracerSliders.trainingTargetSpeed.min) * alpha) + 0.5)
		value = math.clamp(value, tracerSliders.trainingTargetSpeed.min, tracerSliders.trainingTargetSpeed.max)
		if CONFIG.trainerTargetSpeed ~= value then
			CONFIG.trainerTargetSpeed = value
			saveSettings()
		end
		setSliderState(tracerSliders.trainingTargetSpeed, CONFIG.trainerTargetSpeed)
	end

	bindSliderDragStart(tracerSliders.trainingTrackHoldTime.bar, updateTrainerTrackHoldFromX)

	bindSliderDragStart(tracerSliders.trainingTargetSpeed.bar, updateTrainerTargetSpeedFromX)

	bindSliderValueInput(tracerSliders.trainingHitWindow, function(typedValue)
		if typedValue == nil then
			return CONFIG.trainerHitWindow
		end
		return math.clamp(math.floor(typedValue + 0.5), tracerSliders.trainingHitWindow.min, tracerSliders.trainingHitWindow.max)
	end, function(nextValue)
		if CONFIG.trainerHitWindow ~= nextValue then
			CONFIG.trainerHitWindow = nextValue
			saveSettings()
		end
	end)

	bindSliderValueInput(tracerSliders.trainingChallengeDuration, function(typedValue)
		if typedValue == nil then
			return CONFIG.trainerChallengeDuration
		end
		return math.clamp(math.floor(typedValue + 0.5), tracerSliders.trainingChallengeDuration.min, tracerSliders.trainingChallengeDuration.max)
	end, function(nextValue)
		if CONFIG.trainerChallengeDuration ~= nextValue then
			CONFIG.trainerChallengeDuration = nextValue
			saveSettings()
		end
	end)

	bindSliderValueInput(tracerSliders.trainingTrackHoldTime, function(typedValue)
		if typedValue == nil then
			return CONFIG.trainerTrackHoldTime
		end
		return math.clamp(math.floor(typedValue + 0.5), tracerSliders.trainingTrackHoldTime.min, tracerSliders.trainingTrackHoldTime.max)
	end, function(nextValue)
		if CONFIG.trainerTrackHoldTime ~= nextValue then
			CONFIG.trainerTrackHoldTime = nextValue
			saveSettings()
		end
	end)

	bindSliderValueInput(tracerSliders.trainingTargetSpeed, function(typedValue)
		if typedValue == nil then
			return CONFIG.trainerTargetSpeed
		end
		return math.clamp(math.floor(typedValue + 0.5), tracerSliders.trainingTargetSpeed.min, tracerSliders.trainingTargetSpeed.max)
	end, function(nextValue)
		if CONFIG.trainerTargetSpeed ~= nextValue then
			CONFIG.trainerTargetSpeed = nextValue
			saveSettings()
		end
	end)

	tracerSliders.trainingReset.MouseButton1Click:Connect(function()
		miniHudLabels.utility.trainer.history = {}
		miniHudLabels.utility.trainer.lastResults = nil
		resetTrainerSession()
		showToast("Aim Trainer", "Drill reset", THEME.accent)
	end)
end

do
	local function updateCrosshairSizeFromX(positionX)
		local bar = tracerSliders.crosshairSizeSlider.bar
		local relative = math.clamp(positionX - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
		local alpha = 0
		if bar.AbsoluteSize.X > 0 then
			alpha = relative / bar.AbsoluteSize.X
		end

		local nearestValue = CROSSHAIR_SIZE_OPTIONS[1]
		local nearestDistance = math.huge
		for _, option in ipairs(CROSSHAIR_SIZE_OPTIONS) do
			local optionAlpha = 0
			if tracerSliders.crosshairSizeSlider.max > tracerSliders.crosshairSizeSlider.min then
				optionAlpha = (option - tracerSliders.crosshairSizeSlider.min) / (tracerSliders.crosshairSizeSlider.max - tracerSliders.crosshairSizeSlider.min)
			end
			local distance = math.abs(alpha - optionAlpha)
			if distance < nearestDistance then
				nearestDistance = distance
				nearestValue = option
			end
		end

		if CONFIG.crosshairSize ~= nearestValue then
			CONFIG.crosshairSize = nearestValue
			updateCrosshair()
			saveSettings()
			showToast("Setting Updated", string.format("Crosshair Size set to %d", CONFIG.crosshairSize), THEME.accent)
		end

		setSliderState(tracerSliders.crosshairSizeSlider, CONFIG.crosshairSize)
	end

	bindSliderDragStart(tracerSliders.crosshairSizeSlider.bar, updateCrosshairSizeFromX)

	bindSliderValueInput(tracerSliders.crosshairSizeSlider, function(typedValue)
		if typedValue == nil then
			return CONFIG.crosshairSize
		end

		local nearestValue = CROSSHAIR_SIZE_OPTIONS[1]
		local nearestDistance = math.huge
		for _, option in ipairs(CROSSHAIR_SIZE_OPTIONS) do
			local distance = math.abs(option - typedValue)
			if distance < nearestDistance then
				nearestDistance = distance
				nearestValue = option
			end
		end

		return nearestValue
	end, function(nextValue)
		if CONFIG.crosshairSize ~= nextValue then
			CONFIG.crosshairSize = nextValue
			updateCrosshair()
			saveSettings()
		end
	end)
end

do
	local function updateHeadDotSizeFromX(positionX)
		local bar = miniHudLabels.utility.displayToggles.headDotSize.bar
		local relative = math.clamp(positionX - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
		local alpha = 0
		if bar.AbsoluteSize.X > 0 then
			alpha = relative / bar.AbsoluteSize.X
		end

		local value = math.floor(miniHudLabels.utility.displayToggles.headDotSize.min + ((miniHudLabels.utility.displayToggles.headDotSize.max - miniHudLabels.utility.displayToggles.headDotSize.min) * alpha) + 0.5)
		value = math.clamp(value, miniHudLabels.utility.displayToggles.headDotSize.min, miniHudLabels.utility.displayToggles.headDotSize.max)

		if CONFIG.headDotSize ~= value then
			CONFIG.headDotSize = value
			refreshAllEsp()
			saveSettings()
			showToast("Setting Updated", string.format("Head Dot Size set to %d", CONFIG.headDotSize), THEME.accent)
		end

		setSliderState(miniHudLabels.utility.displayToggles.headDotSize, CONFIG.headDotSize)
	end

	bindSliderDragStart(miniHudLabels.utility.displayToggles.headDotSize.bar, updateHeadDotSizeFromX)

	bindSliderValueInput(miniHudLabels.utility.displayToggles.headDotSize, function(typedValue)
		if typedValue == nil then
			return CONFIG.headDotSize
		end

		return math.clamp(math.floor(typedValue + 0.5), miniHudLabels.utility.displayToggles.headDotSize.min, miniHudLabels.utility.displayToggles.headDotSize.max)
	end, function(nextValue)
		if CONFIG.headDotSize ~= nextValue then
			CONFIG.headDotSize = nextValue
			refreshAllEsp()
			saveSettings()
		end
	end)

	local function bindPercentSlider(slider, getCurrentValue, setCurrentValue, label)
		local function updateFromX(positionX)
			local bar = slider.bar
			local relative = math.clamp(positionX - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
			local alpha = 0
			if bar.AbsoluteSize.X > 0 then
				alpha = relative / bar.AbsoluteSize.X
			end

			local value = math.floor(slider.min + ((slider.max - slider.min) * alpha) + 0.5)
			value = math.clamp(value, slider.min, slider.max)

			if getCurrentValue() ~= value then
				setCurrentValue(value)
				refreshAllEsp()
				saveSettings()
				showToast("Setting Updated", string.format("%s set to %d%%", label, value), THEME.accent)
			end

			setSliderState(slider, getCurrentValue())
		end

		bindSliderDragStart(slider.bar, updateFromX)

		bindSliderValueInput(slider, function(typedValue)
			if typedValue == nil then
				return getCurrentValue()
			end

			return math.clamp(math.floor(typedValue + 0.5), slider.min, slider.max)
		end, function(nextValue)
			if getCurrentValue() ~= nextValue then
				setCurrentValue(nextValue)
				refreshAllEsp()
				saveSettings()
			end
		end)

		return updateFromX
	end

	bindPercentSlider(
		miniHudLabels.utility.displayToggles.fillTransparency,
		function()
			return math.floor((CONFIG.fillTransparency or 0) * 100 + 0.5)
		end,
		function(nextValue)
			CONFIG.fillTransparency = math.clamp(nextValue / 100, 0, 1)
		end,
		"Chams Fill"
	)

	bindPercentSlider(
		miniHudLabels.utility.displayToggles.outlineTransparency,
		function()
			return math.floor((CONFIG.outlineTransparency or 0) * 100 + 0.5)
		end,
		function(nextValue)
			CONFIG.outlineTransparency = math.clamp(nextValue / 100, 0, 1)
		end,
		"Chams Outline"
	)
end

local function fetchPublicServers(maxPages)
	local pagesLeft = math.max(1, maxPages or 1)
	local cursor = nil
	local servers = {}

	while pagesLeft > 0 do
		local success, response = pcall(function()
			local url = string.format(
				"https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s",
				game.PlaceId,
				cursor and ("&cursor=" .. HttpService:UrlEncode(cursor)) or ""
			)
			return HttpService:JSONDecode(game:HttpGet(url))
		end)

		if not success or not response or type(response.data) ~= "table" then
			return nil
		end

		for _, server in ipairs(response.data) do
			table.insert(servers, server)
		end

		cursor = response.nextPageCursor
		if not cursor then
			break
		end

		pagesLeft = pagesLeft - 1
	end

	return servers
end

local function hopToPublicServer(preferLowestPopulation)
	local servers = fetchPublicServers(3)
	if not servers then
		showToast("Player Utility", "Server lookup failed", THEME.muted)
		return
	end

	local candidates = {}
	for _, server in ipairs(servers) do
		if server.id ~= game.JobId and server.playing < server.maxPlayers then
			table.insert(candidates, server)
		end
	end

	if #candidates == 0 then
		showToast("Player Utility", "No open server found", THEME.muted)
		return
	end

	table.sort(candidates, function(a, b)
		if preferLowestPopulation and a.playing ~= b.playing then
			return a.playing < b.playing
		end

		if a.ping ~= nil and b.ping ~= nil and a.ping ~= b.ping then
			return a.ping < b.ping
		end

		return a.id < b.id
	end)

	local target = candidates[1]
	local success = pcall(function()
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, target.id, LOCAL_PLAYER)
	end)

	if not success then
		showToast("Player Utility", "Teleport failed", THEME.muted)
		return
	end

	showToast("Player Utility", preferLowestPopulation and string.format("Joining low-pop server (%d/%d)", target.playing, target.maxPlayers) or "Joining another server", THEME.accent)
end

miniHudLabels.utility.rejoin.MouseButton1Click:Connect(function()
	pcall(function()
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LOCAL_PLAYER)
	end)
end)

miniHudLabels.utility.hop.MouseButton1Click:Connect(function()
	hopToPublicServer(false)
end)

miniHudLabels.utility.emptyHop.MouseButton1Click:Connect(function()
	hopToPublicServer(true)
end)

miniHudLabels.utility.exportConfig.MouseButton1Click:Connect(function()
	local exportText = exportConfigString()
	miniHudLabels.utility.importedConfigText = exportText
	local copied = false
	if type(setclipboard) == "function" then
		pcall(function()
			setclipboard(exportText)
			copied = true
		end)
	end
	showToast("Settings", copied and "Config copied to clipboard" or "Config cached in session", copied and THEME.accent or THEME.focus)
end)

miniHudLabels.utility.importConfig.MouseButton1Click:Connect(function()
	local sourceText = miniHudLabels.utility.importedConfigText
	if type(getclipboard) == "function" then
		pcall(function()
			sourceText = getclipboard()
		end)
	end

	if not sourceText or sourceText == "" then
		showToast("Settings", "No config string available", THEME.muted)
		return
	end

	local success, payload = pcall(function()
		return HttpService:JSONDecode(sourceText)
	end)

	if not success or not applyImportedConfig(payload) then
		showToast("Settings", "Config import failed", THEME.muted)
		return
	end

	syncUiFromConfig()
	applyCameraFov()
	applyZoomLimitSetting()
	applyPerformanceSettings()
	refreshAllEsp()
	saveSettings()
	showToast("Settings", "Config imported", THEME.accent)
end)

local function saveNamedConfigFromInput()
	local slotName = normalizeConfigSlotName(miniHudLabels.utility.configNameInput and miniHudLabels.utility.configNameInput.Text)
	if not slotName then
		showToast("Settings", "Enter a config name first", THEME.muted)
		return
	end

	local success, reason = saveConfigSlot(slotName)
	if not success then
		showToast("Settings", reason or "Save failed", THEME.muted)
		return
	end

	if miniHudLabels.utility.configNameInput then
		miniHudLabels.utility.configNameInput.Text = slotName
	end
	refreshNamedConfigList()
	showToast("Settings", string.format("%s saved", slotName), THEME.accent)
end

miniHudLabels.utility.saveNamedConfig.MouseButton1Click:Connect(saveNamedConfigFromInput)
miniHudLabels.utility.configNameInput.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		saveNamedConfigFromInput()
	end
end)

miniHudLabels.utility.resetPositions.MouseButton1Click:Connect(function()
	resetOverlayPositions()
	showToast("Settings", "Overlay positions reset", THEME.accent)
end)

miniHudLabels.utility.resetDisplay.MouseButton1Click:Connect(function()
	resetDisplaySettings()
	syncUiFromConfig()
	refreshAllEsp()
	saveSettings()
	showToast("Settings", "Display settings reset", THEME.accent)
end)

miniHudLabels.utility.resetView.MouseButton1Click:Connect(function()
	resetViewSettings()
	syncUiFromConfig()
	applyCameraFov()
	applyZoomLimitSetting()
	updateViewUi()
	saveSettings()
	showToast("Settings", "View settings reset", THEME.accent)
end)

miniHudLabels.utility.resetPerformance.MouseButton1Click:Connect(function()
	resetPerformanceSettings()
	applyPerformanceSettings()
	syncUiFromConfig()
	saveSettings()
	showToast("Settings", "Performance settings reset", THEME.accent)
end)

miniHudLabels.utility.respawn.MouseButton1Click:Connect(function()
	local success = pcall(function()
		LOCAL_PLAYER:LoadCharacter()
	end)

	if not success then
		local character = LOCAL_PLAYER.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			pcall(function()
				humanoid.Health = 0
			end)
			pcall(function()
				humanoid:ChangeState(Enum.HumanoidStateType.Dead)
			end)
		elseif character then
			pcall(function()
				character:BreakJoints()
			end)
		end
	end

	showToast("Player Utility", "Respawn requested", THEME.accent)
end)

miniHudLabels.utility.tools.MouseButton1Click:Connect(function()
	pcall(function()
		local humanoid = getLocalHumanoid()
		if humanoid then
			humanoid:UnequipTools()
		end
	end)
	showToast("Player Utility", "Tools reset", THEME.accent)
end)

chrome.minimizeButton.MouseButton1Click:Connect(function()
	setMinimized(not uiMinimized)
end)

window:GetPropertyChangedSignal("Position"):Connect(function()
	if getgenv().__VYRS_ESP_ACTIVE_TOKEN ~= gui:GetAttribute("ActiveToken") then
		return
	end

	local position = window.Position
	if CONFIG.windowOffsetX ~= position.X.Offset or CONFIG.windowOffsetY ~= position.Y.Offset then
		CONFIG.windowOffsetX = position.X.Offset
		CONFIG.windowOffsetY = position.Y.Offset
		saveSettings()
	end
end)

Players.PlayerAdded:Connect(function(player)
	hookCharacter(player)
	refreshAllEsp()
end)

Players.PlayerRemoving:Connect(function(player)
	clearPlayerEsp(player)
	espObjects[player] = nil
	miniHudLabels.utility.targetTelemetry[player] = nil
	if player == viewState.spectateTarget then
		setSpectateTarget(nil)
	end
	if player == viewState.lockedFocusTarget then
		viewState.lockedFocusTarget = nil
	end
	miniHudLabels.utility.killCredit[player] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LOCAL_PLAYER then
		hookCharacter(player)
	end
end

do
	local function updateFovCircleFromX(positionX)
		local bar = tracerSliders.fovCircleSlider.bar
		local relative = math.clamp(positionX - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
		local alpha = 0
		if bar.AbsoluteSize.X > 0 then
			alpha = relative / bar.AbsoluteSize.X
		end

		local value = math.floor(tracerSliders.fovCircleSlider.min + ((tracerSliders.fovCircleSlider.max - tracerSliders.fovCircleSlider.min) * alpha) + 0.5)
		value = math.clamp(value, tracerSliders.fovCircleSlider.min, tracerSliders.fovCircleSlider.max)

		if CONFIG.fovRadius ~= value then
			CONFIG.fovRadius = value
			updateCrosshair()
			saveSettings()
		end

		setSliderState(tracerSliders.fovCircleSlider, CONFIG.fovRadius)
	end

	bindSliderDragStart(tracerSliders.fovCircleSlider.bar, updateFovCircleFromX)

	bindSliderValueInput(tracerSliders.fovCircleSlider, function(typedValue)
		if typedValue == nil then
			return CONFIG.fovRadius
		end

		return math.clamp(math.floor(typedValue + 0.5), tracerSliders.fovCircleSlider.min, tracerSliders.fovCircleSlider.max)
	end, function(nextValue)
		if CONFIG.fovRadius ~= nextValue then
			CONFIG.fovRadius = nextValue
			updateCrosshair()
			saveSettings()
		end
	end)
end

do
	local function updateCameraFovFromX(positionX)
		local bar = miniHudLabels.utility.controls.cameraFovSlider.bar
		local relative = math.clamp(positionX - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
		local alpha = 0
		if bar.AbsoluteSize.X > 0 then
			alpha = relative / bar.AbsoluteSize.X
		end

		local value = math.floor(miniHudLabels.utility.controls.cameraFovSlider.min + ((miniHudLabels.utility.controls.cameraFovSlider.max - miniHudLabels.utility.controls.cameraFovSlider.min) * alpha) + 0.5)
		value = math.clamp(value, miniHudLabels.utility.controls.cameraFovSlider.min, miniHudLabels.utility.controls.cameraFovSlider.max)

		if CONFIG.cameraFov ~= value then
			CONFIG.cameraFov = value
			applyCameraFov()
			saveSettings()
		end

		setSliderState(miniHudLabels.utility.controls.cameraFovSlider, CONFIG.cameraFov)
	end

	bindSliderDragStart(miniHudLabels.utility.controls.cameraFovSlider.bar, updateCameraFovFromX)

	bindSliderValueInput(miniHudLabels.utility.controls.cameraFovSlider, function(typedValue)
		if typedValue == nil then
			return CONFIG.cameraFov
		end

		return math.clamp(math.floor(typedValue + 0.5), miniHudLabels.utility.controls.cameraFovSlider.min, miniHudLabels.utility.controls.cameraFovSlider.max)
	end, function(nextValue)
		if CONFIG.cameraFov ~= nextValue then
			CONFIG.cameraFov = nextValue
			applyCameraFov()
			saveSettings()
		end
	end)
end

do
	local draggingCombatSlider = nil

	local function updateTracerSlider(entry, positionX)
		local slider = entry.slider
		local bar = slider.bar
		local relative = math.clamp(positionX - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
		local alpha = 0
		if bar.AbsoluteSize.X > 0 then
			alpha = relative / bar.AbsoluteSize.X
		end

		local value = math.floor(slider.min + ((slider.max - slider.min) * alpha) + 0.5)
		value = math.clamp(value, slider.min, slider.max)

		if CONFIG[entry.key] ~= value then
			CONFIG[entry.key] = value
			saveSettings()
			if entry.refreshEsp then
				refreshAllEsp()
			end
			if entry.refreshCrosshair then
				updateCrosshair()
			end
		end

		setSliderState(slider, CONFIG[entry.key])
	end

	for _, entry in ipairs({
		{ slider = tracerSliders.thickness, key = "tracerThickness", refreshEsp = true },
		{ slider = tracerSliders.transparency, key = "tracerTransparency", refreshEsp = true },
		{ slider = tracerSliders.maxDistance, key = "maxDistance", refreshEsp = true },
		{ slider = tracerSliders.fovThickness, key = "fovCircleThickness", refreshCrosshair = true },
		{ slider = tracerSliders.fovTransparency, key = "fovCircleTransparency", refreshCrosshair = true },
		{ slider = tracerSliders.crosshairThickness, key = "crosshairThickness", refreshCrosshair = true },
		{ slider = tracerSliders.crosshairGap, key = "crosshairGap", refreshCrosshair = true },
	}) do
		bindSliderDragStart(entry.slider.bar, function(positionX)
			draggingCombatSlider = entry
			updateTracerSlider(draggingCombatSlider, positionX)
		end, function()
			draggingCombatSlider = nil
		end)
	end

	for _, entry in ipairs({
		{ slider = tracerSliders.thickness, key = "tracerThickness", onChange = refreshAllEsp },
		{ slider = tracerSliders.transparency, key = "tracerTransparency", onChange = refreshAllEsp },
		{ slider = tracerSliders.maxDistance, key = "maxDistance", onChange = refreshAllEsp },
		{ slider = tracerSliders.fovThickness, key = "fovCircleThickness", onChange = updateCrosshair },
		{ slider = tracerSliders.fovTransparency, key = "fovCircleTransparency", onChange = updateCrosshair },
		{ slider = tracerSliders.crosshairThickness, key = "crosshairThickness", onChange = updateCrosshair },
		{ slider = tracerSliders.crosshairGap, key = "crosshairGap", onChange = updateCrosshair },
	}) do
		bindSliderValueInput(entry.slider, function(typedValue)
			if typedValue == nil then
				return CONFIG[entry.key]
			end

			return math.clamp(math.floor(typedValue + 0.5), entry.slider.min, entry.slider.max)
		end, function(nextValue)
			if CONFIG[entry.key] ~= nextValue then
				CONFIG[entry.key] = nextValue
				saveSettings()
				entry.onChange()
			end
		end)
	end
end

do
	local function updateFreeCamSpeedFromX(positionX)
		local bar = viewButtons.speed.bar
		local relative = math.clamp(positionX - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
		local alpha = 0
		if bar.AbsoluteSize.X > 0 then
			alpha = relative / bar.AbsoluteSize.X
		end

		local value = math.floor(viewButtons.speed.min + ((viewButtons.speed.max - viewButtons.speed.min) * alpha) + 0.5)
		value = math.clamp(value, viewButtons.speed.min, viewButtons.speed.max)

		if CONFIG.freeCamSpeed ~= value then
			CONFIG.freeCamSpeed = value
			saveSettings()
		end

		setSliderState(viewButtons.speed, CONFIG.freeCamSpeed)
	end

	bindSliderDragStart(viewButtons.speed.bar, updateFreeCamSpeedFromX)

	bindSliderValueInput(viewButtons.speed, function(typedValue)
		if typedValue == nil then
			return CONFIG.freeCamSpeed
		end

		return math.clamp(math.floor(typedValue + 0.5), viewButtons.speed.min, viewButtons.speed.max)
	end, function(nextValue)
		if CONFIG.freeCamSpeed ~= nextValue then
			CONFIG.freeCamSpeed = nextValue
			saveSettings()
		end
	end)
end

do
	local draggingPlayerSlider = nil

	local function updatePlayerSlider(entry, positionX)
		local slider = entry.slider
		local bar = slider.bar
		local relative = math.clamp(positionX - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
		local alpha = 0
		if bar.AbsoluteSize.X > 0 then
			alpha = relative / bar.AbsoluteSize.X
		end

		local value = math.floor(slider.min + ((slider.max - slider.min) * alpha) + 0.5)
		value = math.clamp(value, slider.min, slider.max)

		if CONFIG[entry.key] ~= value then
			CONFIG[entry.key] = value
			saveSettings()
			applyPlayerMovementState()
			updateViewUi()
		end

		setSliderState(slider, CONFIG[entry.key])
	end

	for _, entry in ipairs({
		{ slider = playerButtons.walkSpeed, key = "walkSpeed" },
		{ slider = playerButtons.flySpeed, key = "flySpeed" },
	}) do
		bindSliderDragStart(entry.slider.bar, function(positionX)
			draggingPlayerSlider = entry
			updatePlayerSlider(draggingPlayerSlider, positionX)
		end, function()
			draggingPlayerSlider = nil
		end)

		bindSliderValueInput(entry.slider, function(typedValue)
			if typedValue == nil then
				return CONFIG[entry.key]
			end

			return math.clamp(math.floor(typedValue + 0.5), entry.slider.min, entry.slider.max)
		end, function(nextValue)
			if CONFIG[entry.key] ~= nextValue then
				CONFIG[entry.key] = nextValue
				saveSettings()
				applyPlayerMovementState()
				updateViewUi()
			end
		end)
	end
end

UserInputService.JumpRequest:Connect(function()
	if getgenv().__VYRS_ESP_ACTIVE_TOKEN ~= gui:GetAttribute("ActiveToken") then
		return
	end

	if not CONFIG.infiniteJump or viewState.freeCamEnabled then
		return
	end

	local humanoid = getLocalHumanoid()
	if not humanoid or humanoid.Health <= 0 then
		return
	end

	local state = humanoid:GetState()
	if state == Enum.HumanoidStateType.Dead or state == Enum.HumanoidStateType.Seated then
		return
	end

	humanoid.Jump = true
	humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if getgenv().__VYRS_ESP_ACTIVE_TOKEN ~= gui:GetAttribute("ActiveToken") then
		return
	end

	if gameProcessed then
		return
	end

	local inputIsMouseButton = input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.MouseButton2
		or input.UserInputType == Enum.UserInputType.MouseButton3
	local allowMouseKeybindInput = not window.Visible

	if keybindController and (not inputIsMouseButton or allowMouseKeybindInput) and keybindController.handleInput(input) then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local trainer = ensureTrainerState()
		if trainer then
			trainer.spreadValue = math.min(36, trainer.spreadValue + 7)
			trainer.recoilKick = math.min(18, trainer.recoilKick + 6)
			trainer.recoilOffset = trainer.recoilOffset + Vector2.new(math.random(-4, 4), -math.random(4, 10))
		end
	end

	if CONFIG.clickTeleport and input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		local root = getLocalRoot()
		local mouse = LOCAL_PLAYER and LOCAL_PLAYER:GetMouse()
		if root and mouse and mouse.Hit then
			root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
			showToast("Player", "Teleported", THEME.accent)
			return
		end
	end

	if CONFIG.aimTrainerMode and CONFIG.trainerDrillType == "Click" and input.UserInputType == Enum.UserInputType.MouseButton1 then
		local trainer = ensureTrainerState()
		local clickPosition = getMouseScreenPosition(getCamera())
		if trainer and trainer.targetPosition and clickPosition then
			if (clickPosition - trainer.targetPosition).Magnitude <= CONFIG.trainerHitWindow then
				if trainer.targetSpawnAt and trainer.targetSpawnAt > 0 then
					recordTrainerClickSuccess(math.floor((tick() - trainer.targetSpawnAt) * 1000 + 0.5))
				end
				spawnTrainerTarget()
			else
				recordTrainerClickMiss()
			end
		end
	end

	if viewState.freeCamEnabled or CONFIG.fly then
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			if viewState.freeCamEnabled then
				viewState.lookHeld = true
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
			end
		elseif input.KeyCode == Enum.KeyCode.W then
			viewState.moveForward = 1
		elseif input.KeyCode == Enum.KeyCode.S then
			viewState.moveForward = -1
		elseif input.KeyCode == Enum.KeyCode.D then
			viewState.moveRight = 1
		elseif input.KeyCode == Enum.KeyCode.A then
			viewState.moveRight = -1
		elseif input.KeyCode == Enum.KeyCode.Space then
			viewState.moveUp = 1
		elseif input.KeyCode == Enum.KeyCode.LeftControl then
			viewState.moveUp = -1
		elseif input.KeyCode == Enum.KeyCode.Escape and viewState.freeCamEnabled then
			toggleFreeCam()
			return
		end
	end

	if input.KeyCode == CONFIG.quickHideKey then
		window.Visible = not window.Visible
		watermark.Visible = uiReady and window.Visible and not CONFIG.minimalMode
		miniHud.Visible = uiReady and window.Visible and CONFIG.showMiniHud
		showToast("Menu", window.Visible and "Menu shown" or "Menu hidden", window.Visible and THEME.accent or THEME.muted)
	elseif input.KeyCode == CONFIG.uiToggleKey then
		gui.Enabled = not gui.Enabled
		if not gui.Enabled then
			hideCrosshair()
		end
		if keybindController then
			keybindController.update()
		end
		updateMouseIconVisibility()
	elseif input.KeyCode == CONFIG.espToggleKey then
		setEspEnabled(not CONFIG.enabled)
	elseif input.KeyCode == CONFIG.panicKey then
		setEspEnabled(false)
		gui.Enabled = false
		hideCrosshair()
		if keybindController then
			keybindController.update()
		end
		updateMouseIconVisibility()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if getgenv().__VYRS_ESP_ACTIVE_TOKEN ~= gui:GetAttribute("ActiveToken") then
		return
	end

	local inputIsMouseButton = input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.MouseButton2
		or input.UserInputType == Enum.UserInputType.MouseButton3
	local allowMouseKeybindInput = not window.Visible

	if keybindController and keybindController.handleInputEnded and (not inputIsMouseButton or allowMouseKeybindInput) then
		keybindController.handleInputEnded(input)
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		viewState.lookHeld = false
		if viewState.freeCamEnabled then
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
	elseif input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S then
		viewState.moveForward = 0
	elseif input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.A then
		viewState.moveRight = 0
	elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftControl then
		viewState.moveUp = 0
	end
end)

local updateAccumulator = 0
local frameTaskErrorCounts = {}

local function runSafeFrameTask(taskName, taskFn, ...)
	local ok, err = pcall(taskFn, ...)
	if ok then
		return true
	end

	local count = (frameTaskErrorCounts[taskName] or 0) + 1
	frameTaskErrorCounts[taskName] = count
	if count <= 3 then
		warn(string.format("[0xVyrs] %s failed: %s", taskName, tostring(err)))
	end
	return false
end

RunService.RenderStepped:Connect(function(deltaTime)
	if getgenv().__VYRS_ESP_ACTIVE_TOKEN ~= gui:GetAttribute("ActiveToken") then
		return
	end

	if deltaTime > 0 then
		currentFps = (currentFps == 0) and (1 / deltaTime) or (currentFps * 0.85 + (1 / deltaTime) * 0.15)
	end

	local camera = getCamera()
	if viewState.freeCamEnabled and camera then
		setLocalMovementSuppressed(true)
		if viewState.lookHeld then
			local mouseDelta = UserInputService:GetMouseDelta()
			viewState.freeCamYaw = viewState.freeCamYaw - (mouseDelta.X * 0.0025)
			viewState.freeCamPitch = math.clamp(viewState.freeCamPitch - (mouseDelta.Y * 0.0025), -1.45, 1.45)
		end

		local rotation = CFrame.Angles(0, viewState.freeCamYaw, 0) * CFrame.Angles(viewState.freeCamPitch, 0, 0)
		local movement = Vector3.new(viewState.moveRight, viewState.moveUp, -viewState.moveForward)
		if movement.Magnitude > 1 then
			movement = movement.Unit
		end

		local speed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and (CONFIG.freeCamSpeed * 1.67) or CONFIG.freeCamSpeed
		local position = viewState.freeCamCFrame and viewState.freeCamCFrame.Position or camera.CFrame.Position
		position = position + rotation:VectorToWorldSpace(movement) * speed * deltaTime
		viewState.freeCamCFrame = CFrame.new(position) * rotation
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = viewState.freeCamCFrame
	elseif CONFIG.fly and camera then
		local root = getLocalRoot()
		local humanoid = getLocalHumanoid()
		if root and humanoid then
			local forward = camera.CFrame.LookVector
			if forward.Magnitude < 0.001 then
				forward = root.CFrame.LookVector
			end
			forward = forward.Unit

			local right = camera.CFrame.RightVector
			if right.Magnitude < 0.001 then
				right = root.CFrame.RightVector
			end
			right = right.Unit

			local inputVelocity = (right * viewState.moveRight) + (Vector3.yAxis * viewState.moveUp) + (forward * viewState.moveForward)
			if inputVelocity.Magnitude > 1 then
				inputVelocity = inputVelocity.Unit
			end

			local speedMultiplier = 1
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				speedMultiplier = FLY_BOOST_MULTIPLIER
			elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
				speedMultiplier = FLY_PRECISION_MULTIPLIER
			end

			local targetVelocity = inputVelocity * (CONFIG.flySpeed * speedMultiplier)
			local currentVelocity = viewState.flyVelocity or root.AssemblyLinearVelocity
			local blendSpeed = targetVelocity.Magnitude > currentVelocity.Magnitude and FLY_ACCELERATION or FLY_DECELERATION
			local alpha = math.clamp(deltaTime * blendSpeed, 0, 1)
			local blendedVelocity = currentVelocity:Lerp(targetVelocity, alpha)
			if targetVelocity.Magnitude < 0.01 and blendedVelocity.Magnitude < 1 then
				blendedVelocity = Vector3.zero
			end

			viewState.flyVelocity = blendedVelocity
			root.AssemblyLinearVelocity = blendedVelocity
			root.AssemblyAngularVelocity = Vector3.zero
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			humanoid.PlatformStand = false
			humanoid.AutoRotate = false

			local visualDirection = blendedVelocity
			if visualDirection.Magnitude > 0.05 then
				viewState.flyLookVector = visualDirection.Unit
			else
				viewState.flyLookVector = forward
			end

			if viewState.flyLookVector and viewState.flyLookVector.Magnitude > 0.05 then
				local targetCFrame = CFrame.lookAt(root.Position, root.Position + viewState.flyLookVector, Vector3.yAxis)
				root.CFrame = root.CFrame:Lerp(targetCFrame, math.clamp(deltaTime * 14, 0, 1))
			end
		end
	elseif viewState.spectateTarget then
		local targetCharacter = viewState.spectateTarget.Character
		local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
		if targetHumanoid then
			if camera and (camera.CameraType ~= Enum.CameraType.Custom or camera.CameraSubject ~= targetHumanoid) then
				camera.CameraType = Enum.CameraType.Custom
				camera.CameraSubject = targetHumanoid
			end
		else
			setSpectateTarget(nil)
		end
	end

	if not CONFIG.fly and not viewState.freeCamEnabled then
		applyPlayerMovementState()
	end

	if gui.Enabled then
		runSafeFrameTask("updateCrosshair", updateCrosshair)
	else
		hideCrosshair()
	end
	runSafeFrameTask("updateTrainerVisuals", updateTrainerVisuals, deltaTime)
	runSafeFrameTask("updateMouseIconVisibility", updateMouseIconVisibility)
	runSafeFrameTask("updatePerfStatsUi", updatePerfStatsUi)
	updateAccumulator = updateAccumulator + deltaTime
	if updateAccumulator >= updateInterval then
		updateAccumulator = 0
		runSafeFrameTask("refreshAllEsp", refreshAllEsp)
	end
end)

task.spawn(playIntroAnimation)
