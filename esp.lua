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
	cameraFov = 70,
	freeCamSpeed = 72,
	removeZoomLimit = false,
	boxMode = "Highlight",
	compactMode = false,
	showMiniHud = true,
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
	version = "1.3.4",
	windowOffsetX = 0,
	windowOffsetY = 0,
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
	muted = Color3.fromRGB(142, 149, 168),
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
local DEV_USER_ID = 10006170169
local DEV_TAG_TEXT = "0xVyrs [DEV]"
local DEV_TAG_DISTANCE = 125
local DEFAULT_FOV_RADIUS = 60
local DEFAULT_CAMERA_FOV = 70
local visibleEnemyCount = 0
local PRESETS
local currentPresetIndex = 2
local SETTING_KEYS
local toastLayer
local syncUiFromConfig
local getCharacterRoot
local applyConfigToggleState
local keybindController
local keybindState = {
	toggleButtonsByConfig = {},
}
local KEYBINDS_MODULE_SOURCE = [==[
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
	if decoded.placeConfigs and decoded.placeConfigs[tostring(game.PlaceId)] and decoded.placeConfigs[tostring(game.PlaceId)].settings and decoded.autoLoadGamePreset ~= false then
		configSource = decoded.placeConfigs[tostring(game.PlaceId)].settings
		keybindSource = decoded.placeConfigs[tostring(game.PlaceId)].featureKeybinds or keybindSource
		bindModeSource = decoded.placeConfigs[tostring(game.PlaceId)].featureKeybindModes or bindModeSource
	end

	for _, key in ipairs(SETTING_KEYS) do
		if configSource[key] ~= nil then
			CONFIG[key] = configSource[key]
		end
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
		payload[key] = CONFIG[key]
	end

	payload.featureKeybinds = payload.featureKeybinds or {}
	for featureId, keyText in pairs(FEATURE_KEYBINDS) do
		payload.featureKeybinds[featureId] = keyText
	end
	payload.featureKeybindModes = payload.featureKeybindModes or {}
	for featureId, modeText in pairs(FEATURE_KEYBIND_MODES) do
		payload.featureKeybindModes[featureId] = modeText
	end

	payload.placeConfigs = payload.placeConfigs or {}
	payload.placeConfigs[tostring(game.PlaceId)] = {
		currentPresetIndex = currentPresetIndex,
		settings = {},
	}

	for _, key in ipairs(SETTING_KEYS) do
		payload.placeConfigs[tostring(game.PlaceId)].settings[key] = CONFIG[key]
	end
	payload.placeConfigs[tostring(game.PlaceId)].featureKeybinds = payload.placeConfigs[tostring(game.PlaceId)].featureKeybinds or {}
	for featureId, keyText in pairs(FEATURE_KEYBINDS) do
		payload.placeConfigs[tostring(game.PlaceId)].featureKeybinds[featureId] = keyText
	end
	payload.placeConfigs[tostring(game.PlaceId)].featureKeybindModes = payload.placeConfigs[tostring(game.PlaceId)].featureKeybindModes or {}
	for featureId, modeText in pairs(FEATURE_KEYBIND_MODES) do
		payload.placeConfigs[tostring(game.PlaceId)].featureKeybindModes[featureId] = modeText
	end

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
	AnchorPoint = Vector2.new(1, 0),
	BackgroundColor3 = Color3.fromRGB(18, 22, 32),
	BorderSizePixel = 0,
	Position = UDim2.new(1, -16, 0, 16),
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
miniHud.Visible = CONFIG.showMiniHud

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
	guiObject.MouseEnter:Connect(function()
		miniHudLabels.tooltipLabel.Text = text
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

local intro = {}
intro.overlay = create("Frame", {
	BackgroundColor3 = Color3.fromRGB(10, 12, 18),
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 20,
	Parent = gui,
})

intro.card = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(18, 22, 32),
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 20),
	Size = UDim2.new(0, 0, 0, 0),
	ZIndex = 21,
	Parent = intro.overlay,
})
addCorner(intro.card, 16)
addStroke(intro.card, THEME.border, 0.2, 1)

intro.ring = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 120, 0, 120),
	ZIndex = 20,
	Parent = intro.overlay,
})
addCorner(intro.ring, 999)
addStroke(intro.ring, THEME.accent, 0.15, 2)

intro.glow = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = THEME.accent,
	BackgroundTransparency = 0.84,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(1.28, 0, 1.4, 0),
	ZIndex = 20,
	Parent = intro.card,
})
addCorner(intro.glow, 999)

intro.sound = create("Sound", {
	Name = "IntroHit",
	SoundId = "rbxassetid://1839701476",
	Volume = 2.2,
	PlaybackSpeed = 1,
	RollOffMaxDistance = 100,
	Parent = gui,
})

intro.kicker = makeLabel(intro.card, "SYSTEM ONLINE", 10, THEME.accent, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
intro.kicker.AnchorPoint = Vector2.new(0.5, 0)
intro.kicker.Position = UDim2.new(0.5, 0, 0, 18)
intro.kicker.Size = UDim2.new(1, -30, 0, 16)
intro.kicker.TextTransparency = 1
intro.kicker.ZIndex = 22

intro.title = makeLabel(intro.card, "Welcome to 0xVyrs ESP Suite", 20, THEME.text, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
intro.title.AnchorPoint = Vector2.new(0.5, 0.5)
intro.title.Position = UDim2.new(0.5, 0, 0.5, -2)
intro.title.Size = UDim2.new(1, -30, 0, 30)
intro.title.TextTransparency = 1
intro.title.ZIndex = 22

intro.sub = makeLabel(intro.card, "Adaptive overlays primed", 11, THEME.muted, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
intro.sub.AnchorPoint = Vector2.new(0.5, 1)
intro.sub.Position = UDim2.new(0.5, 0, 1, -18)
intro.sub.Size = UDim2.new(1, -30, 0, 16)
intro.sub.TextTransparency = 1
intro.sub.ZIndex = 22

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
local compactWindowSize = UDim2.new(0, 428, 0, 528)
local compactMinimizedWindowSize = UDim2.new(0, 428, 0, 86)
local uiMinimized = false
local updateInterval = 1 / 30
local currentFps = 0
local trackedEnemyCount = 0
local lastRefreshMs = 0

PRESETS = {
	{
		name = "Legit",
		apply = function()
			CONFIG.showNames = true
			CONFIG.showDistance = true
			CONFIG.showHealth = false
			CONFIG.showWeapon = false
			CONFIG.visibilityCheck = false
			CONFIG.showTracers = false
			CONFIG.boxMode = "Highlight"
		end,
	},
	{
		name = "Combat",
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
			CONFIG.boxMode = "Highlight"
			CONFIG.tracerStyle = "Direct"
		end,
	},
	{
		name = "Performance",
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
			CONFIG.boxMode = "Highlight"
		end,
	},
}

local BOX_MODE_OPTIONS = { "Highlight", "2D Box", "Corner Box" }
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
	"cameraFov",
	"freeCamSpeed",
	"removeZoomLimit",
	"boxMode",
	"compactMode",
	"showMiniHud",
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
	"maxDistance",
	"windowOffsetX",
	"windowOffsetY",
}

loadSettings()
CONFIG.enabled = true
CONFIG.showSkeleton = false
CONFIG.boxMode = "Highlight"

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
	view = createPage(),
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
		entry.button.BackgroundColor3 = selected and THEME.accentSoft or Color3.fromRGB(35, 40, 53)
		entry.button.TextColor3 = selected and THEME.text or THEME.muted

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
			stroke.Transparency = selected and 0.15 or 0.65
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

do
	local headerRow, headerValue = createStatusRow(pages.control, "CONTROL", "ACTIVE")
	headerRow.BackgroundColor3 = THEME.panelAlt
	headerValue.TextColor3 = THEME.accent
end

miniHudLabels.perfStats = select(2, createPerfRow(pages.control))

do
	local row = createRow(pages.control, 30)
	local holder = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 5),
		Size = UDim2.new(1, -20, 0, 20),
		Parent = row,
	})

	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = holder,
	})

	miniHudLabels.utility.controlTabs = {}

	for _, item in ipairs({
		{ key = "general", label = "GENERAL", width = 86 },
		{ key = "utility", label = "UTILITY", width = 78 },
		{ key = "keybinds", label = "KEYBINDS", width = 84 },
	}) do
		miniHudLabels.utility.controlTabs[item.key] = create("TextButton", {
			AutoButtonColor = false,
			BackgroundColor3 = item.key == "general" and THEME.accentSoft or Color3.fromRGB(35, 40, 53),
			BorderSizePixel = 0,
			Size = UDim2.new(0, item.width, 1, 0),
			Font = Enum.Font.GothamBold,
			Text = item.label,
			TextColor3 = item.key == "general" and THEME.text or THEME.muted,
			TextSize = 9,
			Parent = holder,
		})
		addCorner(miniHudLabels.utility.controlTabs[item.key], 999)
		addStroke(miniHudLabels.utility.controlTabs[item.key], THEME.border, item.key == "general" and 0.15 or 0.5, 1)
	end

	local body = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = pages.control,
	})

	create("UIListLayout", {
		Padding = UDim.new(0, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = body,
	})

	for _, item in ipairs({ "general", "utility", "keybinds" }) do
		miniHudLabels.utility.controlTabs[item .. "Page"] = create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			Visible = item == "general",
			Parent = body,
		})

		create("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = miniHudLabels.utility.controlTabs[item .. "Page"],
		})
	end

	miniHudLabels.utility.setControlTab = function(tabName)
		for _, item in ipairs({ "general", "utility", "keybinds" }) do
			local selected = item == tabName
			miniHudLabels.utility.controlTabs[item].BackgroundColor3 = selected and THEME.accentSoft or Color3.fromRGB(35, 40, 53)
			miniHudLabels.utility.controlTabs[item].TextColor3 = selected and THEME.text or THEME.muted
			miniHudLabels.utility.controlTabs[item .. "Page"].Visible = selected
			local stroke = miniHudLabels.utility.controlTabs[item]:FindFirstChildOfClass("UIStroke")
			if stroke then
				stroke.Transparency = selected and 0.15 or 0.5
			end
		end
	end

	miniHudLabels.utility.controlTabs.general.MouseButton1Click:Connect(function()
		miniHudLabels.utility.setControlTab("general")
	end)

	miniHudLabels.utility.controlTabs.utility.MouseButton1Click:Connect(function()
		miniHudLabels.utility.setControlTab("utility")
	end)

	miniHudLabels.utility.controlTabs.keybinds.MouseButton1Click:Connect(function()
		miniHudLabels.utility.setControlTab("keybinds")
	end)
end

do
	local headerRow, headerValue = createStatusRow(pages.display, "DISPLAY", "ACTIVE")
	headerRow.BackgroundColor3 = THEME.panelAlt
	headerValue.TextColor3 = THEME.accent
end

local tracerSliders = {}

do
	local headerRow, headerValue = createStatusRow(pages.combat, "COMBAT", "ACTIVE")
	headerRow.BackgroundColor3 = THEME.panelAlt
	headerValue.TextColor3 = THEME.accent
end

do
	local row = createRow(pages.combat, 30)
	local holder = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 5),
		Size = UDim2.new(1, -20, 0, 20),
		Parent = row,
	})

	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = holder,
	})

	tracerSliders.tabs = {}

	for _, item in ipairs({
		{ key = "targeting", label = "TARGET" },
		{ key = "tracers", label = "TRACERS" },
		{ key = "crosshair", label = "CROSSHAIR" },
	}) do
		tracerSliders.tabs[item.key] = create("TextButton", {
			AutoButtonColor = false,
			BackgroundColor3 = item.key == "targeting" and THEME.accentSoft or Color3.fromRGB(35, 40, 53),
			BorderSizePixel = 0,
			Size = UDim2.new(0, item.key == "crosshair" and 86 or 74, 1, 0),
			Font = Enum.Font.GothamBold,
			Text = item.label,
			TextColor3 = item.key == "targeting" and THEME.text or THEME.muted,
			TextSize = 9,
			Parent = holder,
		})
		addCorner(tracerSliders.tabs[item.key], 999)
		addStroke(tracerSliders.tabs[item.key], THEME.border, item.key == "targeting" and 0.15 or 0.5, 1)
	end

	local body = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = pages.combat,
	})

	create("UIListLayout", {
		Padding = UDim.new(0, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = body,
	})

	for _, item in ipairs({ "targeting", "tracers", "crosshair" }) do
		tracerSliders.tabs[item .. "Page"] = create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			Visible = item == "targeting",
			Parent = body,
		})

		create("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = tracerSliders.tabs[item .. "Page"],
		})
	end

	tracerSliders.setCombatTab = function(tabName)
		for _, item in ipairs({ "targeting", "tracers", "crosshair" }) do
			local selected = item == tabName
			tracerSliders.tabs[item].BackgroundColor3 = selected and THEME.accentSoft or Color3.fromRGB(35, 40, 53)
			tracerSliders.tabs[item].TextColor3 = selected and THEME.text or THEME.muted
			tracerSliders.tabs[item .. "Page"].Visible = selected
			local stroke = tracerSliders.tabs[item]:FindFirstChildOfClass("UIStroke")
			if stroke then
				stroke.Transparency = selected and 0.15 or 0.5
			end
		end
	end

	tracerSliders.tabs.targeting.MouseButton1Click:Connect(function()
		tracerSliders.setCombatTab("targeting")
	end)

	tracerSliders.tabs.tracers.MouseButton1Click:Connect(function()
		tracerSliders.setCombatTab("tracers")
	end)

	tracerSliders.tabs.crosshair.MouseButton1Click:Connect(function()
		tracerSliders.setCombatTab("crosshair")
	end)
end

do
	local headerRow, headerValue = createStatusRow(pages.view, "VIEW", "ACTIVE")
	headerRow.BackgroundColor3 = THEME.panelAlt
	headerValue.TextColor3 = THEME.accent
end

do
	local headerRow, headerValue = createStatusRow(pages.performance, "PERFORMANCE", "LOCAL")
	headerRow.BackgroundColor3 = THEME.panelAlt
	headerValue.TextColor3 = THEME.accent
end

createStatusRow(pages.display, "ESP COLOR", "AUTO TEAM")

local enabledToggle = select(2, createToggleRow(pages.control, "ESP ENABLED", CONFIG.enabled))
local presetButton = select(2, createCycleRow(pages.control, "PRESET", PRESETS[currentPresetIndex].name))
miniHudLabels.utility.teamCheckRow = createStatusRow(pages.control, "TEAM CHECK", "ALWAYS ON")
miniHudLabels.utility.quickHideRow = createStatusRow(pages.control, "QUICK HIDE", keyCodeToText(CONFIG.quickHideKey))
local cameraFovSlider = createSliderRow(pages.control, "CAMERA FOV", CONFIG.cameraFov, 40, 120)
cameraFovSlider.reset = select(2, createCycleRow(pages.control, "RESET CAMERA", "DEFAULT"))
local miniHudToggle = select(2, createToggleRow(pages.control, "MINI HUD", CONFIG.showMiniHud))
local compactToggle = select(2, createToggleRow(pages.control, "COMPACT MODE", CONFIG.compactMode))
miniHudLabels.utility.antiAfk = select(2, createToggleRow(pages.control, "ANTI AFK", CONFIG.antiAfk))
miniHudLabels.utility.autoLoadGamePreset = select(2, createToggleRow(pages.control, "AUTO LOAD PLACE PRESET", CONFIG.autoLoadGamePreset))
miniHudLabels.saveStatusValue = select(2, createStatusRow(pages.control, "SETTINGS", canUseFileApi() and "AUTO SAVE" or "MEMORY"))

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
	local row = createRow(pages.control, 30)
	local resetDisplay = create("TextButton", {
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(0, 10, 0.5, -10),
		Size = UDim2.new(0.31, -4, 0, 20),
		Text = "RST DSP",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(resetDisplay, 4)
	addStroke(resetDisplay, THEME.border, 0.35, 1)

	local resetView = create("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(0.5, 0, 0.5, -10),
		Size = UDim2.new(0.31, -4, 0, 20),
		Text = "RST VIEW",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(resetView, 4)
	addStroke(resetView, THEME.border, 0.35, 1)

	local resetPerf = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(1, -10, 0.5, -10),
		Size = UDim2.new(0.31, -4, 0, 20),
		Text = "RST PERF",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(resetPerf, 4)
	addStroke(resetPerf, THEME.border, 0.35, 1)

	miniHudLabels.utility.resetDisplay = resetDisplay
	miniHudLabels.utility.resetView = resetView
	miniHudLabels.utility.resetPerformance = resetPerf
end

do
	local row = createRow(pages.control, 30)
	local rejoin = create("TextButton", {
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(0, 10, 0.5, -10),
		Size = UDim2.new(0.48, -6, 0, 20),
		Text = "REJOIN",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(rejoin, 4)
	addStroke(rejoin, THEME.border, 0.35, 1)

	local hop = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(35, 40, 53),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(1, -10, 0.5, -10),
		Size = UDim2.new(0.48, -6, 0, 20),
		Text = "SERVER HOP",
		TextColor3 = THEME.text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(hop, 4)
	addStroke(hop, THEME.border, 0.35, 1)

	miniHudLabels.utility.rejoin = rejoin
	miniHudLabels.utility.hop = hop
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
	select(1, miniHudLabels.utility.teamCheckRow).Parent = miniHudLabels.utility.controlTabs.generalPage
	select(1, miniHudLabels.utility.quickHideRow).Parent = miniHudLabels.utility.controlTabs.generalPage
	enabledToggle.Parent.Parent = miniHudLabels.utility.controlTabs.generalPage
	presetButton.Parent.Parent = miniHudLabels.utility.controlTabs.generalPage
	cameraFovSlider.bar.Parent.Parent = miniHudLabels.utility.controlTabs.generalPage
	cameraFovSlider.reset.Parent.Parent = miniHudLabels.utility.controlTabs.generalPage
	miniHudToggle.Parent.Parent = miniHudLabels.utility.controlTabs.generalPage
	compactToggle.Parent.Parent = miniHudLabels.utility.controlTabs.generalPage

	miniHudLabels.utility.antiAfk.Parent.Parent = miniHudLabels.utility.controlTabs.utilityPage
	miniHudLabels.utility.autoLoadGamePreset.Parent.Parent = miniHudLabels.utility.controlTabs.utilityPage
	miniHudLabels.saveStatusValue.Parent.Parent = miniHudLabels.utility.controlTabs.utilityPage
	miniHudLabels.utility.rejoin.Parent.Parent = miniHudLabels.utility.controlTabs.utilityPage
	miniHudLabels.utility.hop.Parent.Parent = miniHudLabels.utility.controlTabs.utilityPage
	miniHudLabels.utility.respawn.Parent.Parent = miniHudLabels.utility.controlTabs.utilityPage
	miniHudLabels.utility.tools.Parent.Parent = miniHudLabels.utility.controlTabs.utilityPage
	miniHudLabels.utility.exportConfig.Parent.Parent = miniHudLabels.utility.controlTabs.utilityPage
	miniHudLabels.utility.resetDisplay.Parent.Parent = miniHudLabels.utility.controlTabs.utilityPage
	miniHudLabels.utility.setControlTab("general")
end

local displayToggles = {
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
}
displayToggles.targetCard = select(2, createToggleRow(pages.display, "TARGET CARD", CONFIG.showTargetCard))
displayToggles.targetCardCompact = select(2, createToggleRow(pages.display, "TARGET CARD COMPACT", CONFIG.targetCardCompact))
displayToggles.textStack = select(2, createCycleRow(pages.display, "TEXT STACK", CONFIG.textStackMode))

tracerSliders.visibilityToggle = select(2, createToggleRow(pages.combat, "HEAT VISION", CONFIG.visibilityCheck))
tracerSliders.tracersToggle = select(2, createToggleRow(pages.combat, "TRACERS", CONFIG.showTracers))
tracerSliders.tracerOriginButton = select(2, createCycleRow(pages.combat, "TRACER ORIGIN", CONFIG.tracerOriginMode))
tracerSliders.style = select(2, createCycleRow(pages.combat, "TRACER STYLE", CONFIG.tracerStyle))
do
	local row = createRow(pages.combat, 76)
	row.BackgroundColor3 = THEME.panelAlt
	tracerSliders.targetCard = row
	row.AnchorPoint = Vector2.new(1, 0)
	row.Position = UDim2.new(1, -16, 0, 176)
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
	tracerSliders.setCombatTab("targeting")
end

miniHudLabels.bindTooltip(displayToggles.boxes, "Turns all box and highlight ESP on or off without losing your selected box style.")
miniHudLabels.bindTooltip(displayToggles.boxMode, "Cycles the box style used when box ESP is enabled.")
miniHudLabels.bindTooltip(displayToggles.headDotSize.bar, "Controls how small or aggressive the head dot marker appears.")
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

local viewButtons = {
	status = select(2, createStatusRow(pages.view, "STATUS", "LOCAL")),
	spectate = createSpectateRow(pages.view),
	nav = {},
	freeCam = select(2, createToggleRow(pages.view, "FREE CAM", false)),
	removeZoomLimit = select(2, createToggleRow(pages.view, "REMOVE ZOOM LIMIT", CONFIG.removeZoomLimit)),
	speed = createSliderRow(pages.view, "FREECAM SPEED", CONFIG.freeCamSpeed, 24, 160),
	reset = select(2, createCycleRow(pages.view, "RESET VIEW", "DEFAULT")),
}

miniHudLabels.bindTooltip(viewButtons.removeZoomLimit, "Removes the default local camera zoom cap so you can scroll farther out.")

do
	local row = createRow(pages.view, 30)
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

local performanceToggles = {
	mode = select(2, createToggleRow(pages.performance, "BOOST MODE", CONFIG.performanceMode)),
	materials = select(2, createToggleRow(pages.performance, "LOW MATERIALS", CONFIG.simplifyMaterials)),
	textures = select(2, createToggleRow(pages.performance, "HIDE TEXTURES", CONFIG.hideTextures)),
	effects = select(2, createToggleRow(pages.performance, "HIDE EFFECTS", CONFIG.hideEffects)),
	shadows = select(2, createToggleRow(pages.performance, "DISABLE SHADOWS", CONFIG.disableShadows)),
}

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
	if CONFIG.boxMode == "2D Box" and not DRAWING_SUPPORT.square then
		return "Highlight"
	end

	if CONFIG.boxMode == "Corner Box" and not DRAWING_SUPPORT.line then
		return "Highlight"
	end

	if not CONFIG.showBoxes then
		return nil
	end

	return CONFIG.boxMode
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

local function getTargetThreatData(player, character, root, localRoot, visible)
	local nearbyThreats = 0
	local groupRadius = 28
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= LOCAL_PLAYER and otherPlayer ~= player and (not isSameTeam(otherPlayer) or otherPlayer.UserId == DEV_USER_ID) then
			local otherCharacter = otherPlayer.Character
			local otherRoot = otherCharacter and getCharacterRoot(otherCharacter)
			if otherRoot and (otherRoot.Position - root.Position).Magnitude <= groupRadius then
				nearbyThreats = nearbyThreats + 1
			end
		end
	end

	local distance = localRoot and (root.Position - localRoot.Position).Magnitude or math.huge
	local distanceFactor = 0
	if distance < math.huge then
		distanceFactor = math.clamp((CONFIG.maxDistance - distance) / math.max(CONFIG.maxDistance, 1), 0, 1)
	end

	local heldTool = getHeldToolName(character)
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

local function exportConfigString()
	local payload = {
		currentPresetIndex = currentPresetIndex,
		placeId = game.PlaceId,
		settings = {},
	}

	for _, key in ipairs(SETTING_KEYS) do
		payload.settings[key] = CONFIG[key]
	end

	return HttpService:JSONEncode(payload)
end

local function applyImportedConfig(payload)
	if type(payload) ~= "table" or type(payload.settings) ~= "table" then
		return false
	end

	for _, key in ipairs(SETTING_KEYS) do
		if payload.settings[key] ~= nil then
			CONFIG[key] = payload.settings[key]
		end
	end

	if payload.currentPresetIndex and PRESETS[payload.currentPresetIndex] then
		currentPresetIndex = payload.currentPresetIndex
	end

	return true
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
	CONFIG.boxMode = "Highlight"
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

local function getTracerOrigin(camera)
	if CONFIG.tracerOriginMode == "Center" then
		return Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y * 0.5)
	end

	if CONFIG.tracerOriginMode == "Crosshair" then
		local mouseLocation = UserInputService:GetMouseLocation()
		if mouseLocation then
			return Vector2.new(
				math.clamp(mouseLocation.X, 0, camera.ViewportSize.X),
				math.clamp(mouseLocation.Y, 0, camera.ViewportSize.Y)
			)
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
	if CONFIG.performanceMode then
		CONFIG.simplifyMaterials = true
		CONFIG.hideTextures = true
		CONFIG.hideEffects = true
		CONFIG.disableShadows = true
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
	local shouldShowMouseIcon = viewState.freeCamEnabled or (window.Visible and not CONFIG.showCrosshair)
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

	local mouseLocation = UserInputService:GetMouseLocation()
	local viewport = camera.ViewportSize
	if not mouseLocation or not viewport then
		hideCrosshair()
		updateMouseIconVisibility()
		return
	end

	local centerX = math.clamp(mouseLocation.X, 0, viewport.X)
	local centerY = math.clamp(mouseLocation.Y, 0, viewport.Y)
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

local function updateBoxEsp(entry, camera, character, color)
	local effectiveBoxMode = getEffectiveBoxMode()

	if effectiveBoxMode == "Highlight" then
		hideBoxes(entry)
		return
	end

	local minX, minY, maxX, maxY = getCharacterScreenBounds(camera, character)
	if not minX then
		hideBoxes(entry)
		return
	end

	if effectiveBoxMode == "2D Box" then
		local box = ensureBox(entry)
		if not box then
			hideBoxes(entry)
			return
		end
		hideBoxes(entry)
		local root = getCharacterRoot(character)
		local localRoot = LOCAL_PLAYER.Character and getCharacterRoot(LOCAL_PLAYER.Character)
		local distance = (root and localRoot) and (root.Position - localRoot.Position).Magnitude or CONFIG.maxDistance
		box.Thickness = math.clamp(2.6 - ((distance / math.max(CONFIG.maxDistance, 1)) * 1.4), 1, 2.6)
		box.Visible = true
		box.Color = color
		box.Position = Vector2.new(minX, minY)
		box.Size = Vector2.new(math.max(maxX - minX, 2), math.max(maxY - minY, 2))
	elseif effectiveBoxMode == "Corner Box" then
		local lines = ensureCornerLines(entry)
		if not lines then
			hideBoxes(entry)
			return
		end
		if entry.box then
			entry.box.Visible = false
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
			local root = getCharacterRoot(character)
			local localRoot = LOCAL_PLAYER.Character and getCharacterRoot(LOCAL_PLAYER.Character)
			local distance = (root and localRoot) and (root.Position - localRoot.Position).Magnitude or CONFIG.maxDistance
			line.Thickness = math.clamp(2.8 - ((distance / math.max(CONFIG.maxDistance, 1)) * 1.5), 1, 2.8)
			line.From = segment[1]
			line.To = segment[2]
		end
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

local function updatePlayerEsp(player)
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

	local distance = (root.Position - localRoot.Position).Magnitude
	if distance > CONFIG.maxDistance then
		clearEntry(entry)
		return
	end

	local espColor = getEspColor(player)
	local visible = isPlayerVisible(character, root)
	local displayColor = getDisplayColor(espColor, visible)
	local distanceFade = getDistanceFade(distance)
	local focusTarget = isFocusedTarget(player)
	local showDevTag = isDevPlayer(player) and distance <= DEV_TAG_DISTANCE
	local devRainbowColor = showDevTag and getRainbowColor() or nil
	local telemetry = getTargetThreatData(player, character, root, localRoot, visible)
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
		highlight.FillTransparency = effectiveBoxMode == "Highlight" and math.clamp(CONFIG.fillTransparency + ((1 - distanceFade) * 0.45), 0, 1) or 1
		highlight.OutlineTransparency = effectiveBoxMode == "Highlight" and math.clamp(CONFIG.outlineTransparency + ((1 - distanceFade) * 0.35), 0, 1) or 1
	end
	highlight.OutlineColor = outlineColor

	if camera then
		updateBoxEsp(entry, camera, character, outlineColor)
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
		local targetCardHeight = CONFIG.targetCardCompact and 58 or 76
		if tracerSliders.targetCard then
			local anchorYOffset = (miniHud.Visible and miniHud.AbsoluteSize.Y or 0) + 12
			tracerSliders.targetCard.Position = UDim2.new(1, -16, 0, 16 + anchorYOffset)
			tracerSliders.targetCard.Size = UDim2.new(0, 228, 0, targetCardHeight)
			tracerSliders.targetCard.Visible = gui.Enabled and CONFIG.showTargetCard
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
				tracerSliders.targetInfoMeta2.Visible = not CONFIG.targetCardCompact
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
				tracerSliders.targetInfoMeta2.Visible = not CONFIG.targetCardCompact
			end
			if tracerSliders.targetBadge then
				tracerSliders.targetBadge.Text = "NO LOCK"
				tracerSliders.targetBadge.TextColor3 = THEME.muted
				tracerSliders.targetBadge.BackgroundColor3 = Color3.fromRGB(35, 40, 53)
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

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LOCAL_PLAYER then
			local character = player.Character
			local root = character and getCharacterRoot(character)
			local localCharacter = LOCAL_PLAYER.Character
			local localRoot = localCharacter and getCharacterRoot(localCharacter)
			if character and root and localRoot and shouldTrackPlayer(player) then
				trackedEnemyCount = trackedEnemyCount + 1
				local distance = (root.Position - localRoot.Position).Magnitude
				if distance <= CONFIG.maxDistance then
					local visible = isPlayerVisible(character, root)
					local telemetry = getTargetThreatData(player, character, root, localRoot, visible)
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
						threatScore = (getHeldToolName(character) and 100000 or 0) + (visible and 10000 or 0) - distance
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
				local character = player.Character
				local root = character and getCharacterRoot(character)
				local localCharacter = LOCAL_PLAYER.Character
				local localRoot = localCharacter and getCharacterRoot(localCharacter)
				local distance = (root and localRoot) and (root.Position - localRoot.Position).Magnitude or 0
				if distance > (CONFIG.maxDistance * 0.7) and math.floor(tick() * 4) % 2 == 1 then
					return
				end
				updatePlayerEsp(player)
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
		attachCharacterSignals(player.Character)
		refreshAllEsp()
	end)

	player.CharacterAppearanceLoaded:Connect(function()
		task.wait(0.1)
		refreshAllEsp()
	end)

	if player.Character then
		attachCharacterSignals(player.Character)
	end
end

local function bindToggle(button, configKey)
	button.MouseButton1Click:Connect(function()
		applyConfigToggleState(configKey, not CONFIG[configKey])
	end)
end

applyConfigToggleState = function(configKey, nextState, suppressToast)
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
		miniHud.Visible = CONFIG.showMiniHud and window.Visible
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
	end

	refreshAllEsp()
	saveSettings()
	updateMouseIconVisibility()
	if keybindController then
		keybindController.update()
	end

	if not suppressToast then
		showToast("Setting Updated", string.format("%s %s", formatSettingName(configKey), CONFIG[configKey] and "enabled" or "disabled"), CONFIG[configKey] and THEME.accent or THEME.muted)
	end
end

local function setEspEnabled(state)
	CONFIG.enabled = state
	setToggleState(enabledToggle, state)
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

local function applyCompactMode(state)
	CONFIG.compactMode = state
	chrome.infoPanel.Visible = not state
	chrome.brandSub.Visible = not state
	chrome.topBar.Size = state and UDim2.new(1, 0, 0, 82) or UDim2.new(1, 0, 0, 108)
	tabBar.Position = state and UDim2.new(0, 12, 0, 50) or UDim2.new(0, 12, 0, 78)
	content.Position = state and UDim2.new(0, 0, 0, 82) or UDim2.new(0, 0, 0, 108)
	content.Size = state and UDim2.new(1, 0, 1, -82) or UDim2.new(1, 0, 1, -108)
	chrome.brand.Size = state and UDim2.new(0, 170, 0, 28) or UDim2.new(0, 186, 0, 42)
	chrome.brandTitle.TextSize = state and 19 or 21
	chrome.brandTitle.Position = state and UDim2.new(0, 0, 0, 8) or UDim2.new(0, 0, 0, 9)
	chrome.brandKicker.Visible = not state
	chrome.glow.Visible = not state
	saveSettings()
end

local function setMinimized(state)
	uiMinimized = state
	content.Visible = not state
	if CONFIG.compactMode then
		window.Size = state and compactMinimizedWindowSize or compactWindowSize
	else
		window.Size = state and minimizedWindowSize or expandedWindowSize
	end
	chrome.minimizeButton.Text = state and "+" or "-"
end

local function playIntroAnimation()
	pcall(function()
		intro.sound.TimePosition = 0
		intro.sound:Play()
	end)

	local ringIn = TweenService:Create(intro.ring, TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 250, 0, 250),
		BackgroundTransparency = 1,
	})
	local cardIn = TweenService:Create(intro.card, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 368, 0, 128),
		Position = UDim2.new(0.5, 0, 0.5, 0),
	})
	local glowIn = TweenService:Create(intro.glow, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.92,
	})
	local kickerIn = TweenService:Create(intro.kicker, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
	})
	local titleIn = TweenService:Create(intro.title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
	})
	local subIn = TweenService:Create(intro.sub, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
	})
	local cardSettle = TweenService:Create(intro.card, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 356, 0, 124),
		Position = UDim2.new(0.5, 0, 0.5, -2),
	})

	ringIn:Play()
	cardIn:Play()
	glowIn:Play()
	cardIn.Completed:Wait()
	cardSettle:Play()
	kickerIn:Play()
	titleIn:Play()
	subIn:Play()

	task.wait(1.35)

	local fadeInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	TweenService:Create(intro.overlay, fadeInfo, {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(intro.card, fadeInfo, {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 320, 0, 112),
		Position = UDim2.new(0.5, 0, 0.5, -8),
	}):Play()
	TweenService:Create(intro.glow, fadeInfo, {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(intro.ring, fadeInfo, {
		Size = UDim2.new(0, 340, 0, 340),
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(intro.kicker, fadeInfo, {
		TextTransparency = 1,
	}):Play()
	TweenService:Create(intro.title, fadeInfo, {
		TextTransparency = 1,
	}):Play()
	TweenService:Create(intro.sub, fadeInfo, {
		TextTransparency = 1,
	}):Play()

	task.delay(0.45, function()
		if intro.overlay then
			intro.overlay:Destroy()
		end
	end)

	setActiveTab("control")
	window.Position = UDim2.new(0.5, CONFIG.windowOffsetX, 0.5, CONFIG.windowOffsetY)
	window.Visible = true
	miniHud.Visible = CONFIG.showMiniHud
	syncUiFromConfig()
	applyCameraFov()
	applyZoomLimitSetting()
	miniHudLabels.utility.applyAntiAfk()
	applyPerformanceSettings()
	applyCompactMode(CONFIG.compactMode)
	setActiveTab("control")
	setMinimized(false)
	refreshAllEsp()
	updateMouseIconVisibility()
	if keybindController then
		keybindController.update()
	end
end

createTabButton("control", "CONTROL").MouseButton1Click:Connect(function()
	setActiveTab("control")
end)

createTabButton("display", "DISPLAY").MouseButton1Click:Connect(function()
	setActiveTab("display")
end)

createTabButton("combat", "COMBAT").MouseButton1Click:Connect(function()
	setActiveTab("combat")
end)

createTabButton("view", "VIEW").MouseButton1Click:Connect(function()
	setActiveTab("view")
end)

createTabButton("performance", "PERF").MouseButton1Click:Connect(function()
	setActiveTab("performance")
end)

bindToggle(enabledToggle, "enabled")
bindToggle(displayToggles.names, "showNames")
bindToggle(displayToggles.distance, "showDistance")
bindToggle(displayToggles.fade, "distanceFade")
bindToggle(displayToggles.health, "showHealth")
bindToggle(displayToggles.weapon, "showWeapon")
bindToggle(displayToggles.skeleton, "showSkeleton")
bindToggle(displayToggles.headDot, "showHeadDot")
bindToggle(displayToggles.focus, "showFocusTarget")
bindToggle(displayToggles.boxes, "showBoxes")
bindToggle(displayToggles.targetCard, "showTargetCard")
bindToggle(displayToggles.targetCardCompact, "targetCardCompact")
bindToggle(tracerSliders.visibilityToggle, "visibilityCheck")
bindToggle(tracerSliders.tracersToggle, "showTracers")
bindToggle(tracerSliders.focusLock, "focusLock")
bindToggle(tracerSliders.lookDirectionToggle, "showLookDirection")
bindToggle(tracerSliders.crosshairToggle, "showCrosshair")
bindToggle(tracerSliders.fovCircleToggle, "showFovCircle")
bindToggle(miniHudToggle, "showMiniHud")
bindToggle(viewButtons.removeZoomLimit, "removeZoomLimit")
bindToggle(miniHudLabels.utility.antiAfk, "antiAfk")
bindToggle(miniHudLabels.utility.autoLoadGamePreset, "autoLoadGamePreset")
bindToggle(performanceToggles.mode, "performanceMode")
bindToggle(performanceToggles.materials, "simplifyMaterials")
bindToggle(performanceToggles.textures, "hideTextures")
bindToggle(performanceToggles.effects, "hideEffects")
bindToggle(performanceToggles.shadows, "disableShadows")

for configKey, button in pairs({
	enabled = enabledToggle,
	showNames = displayToggles.names,
	showDistance = displayToggles.distance,
	distanceFade = displayToggles.fade,
	showHealth = displayToggles.health,
	showWeapon = displayToggles.weapon,
	showSkeleton = displayToggles.skeleton,
	showHeadDot = displayToggles.headDot,
	showFocusTarget = displayToggles.focus,
	showBoxes = displayToggles.boxes,
	showTargetCard = displayToggles.targetCard,
	targetCardCompact = displayToggles.targetCardCompact,
	visibilityCheck = tracerSliders.visibilityToggle,
	showTracers = tracerSliders.tracersToggle,
	focusLock = tracerSliders.focusLock,
	showLookDirection = tracerSliders.lookDirectionToggle,
	showCrosshair = tracerSliders.crosshairToggle,
	showFovCircle = tracerSliders.fovCircleToggle,
	showMiniHud = miniHudToggle,
	removeZoomLimit = viewButtons.removeZoomLimit,
	antiAfk = miniHudLabels.utility.antiAfk,
	autoLoadGamePreset = miniHudLabels.utility.autoLoadGamePreset,
	performanceMode = performanceToggles.mode,
	simplifyMaterials = performanceToggles.materials,
	hideTextures = performanceToggles.textures,
	hideEffects = performanceToggles.effects,
	disableShadows = performanceToggles.shadows,
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
			makeLabel = makeLabel,
			saveSettings = saveSettings,
			setToggleState = setToggleState,
			showToast = showToast,
			theme = THEME,
			toggleFreeCam = toggleFreeCam,
			userInputService = UserInputService,
			viewState = viewState,
		})
		keybindController.buildRows(miniHudLabels.utility.controlTabs.keybindsPage)
	end
end

compactToggle.MouseButton1Click:Connect(function()
	applyCompactMode(not CONFIG.compactMode)
	setToggleState(compactToggle, CONFIG.compactMode)
	setMinimized(uiMinimized)
	showToast("Setting Updated", string.format("%s %s", "Compact Mode", CONFIG.compactMode and "enabled" or "disabled"), CONFIG.compactMode and THEME.accent or THEME.muted)
end)

syncUiFromConfig = function()
	setToggleState(enabledToggle, CONFIG.enabled)
	setToggleState(displayToggles.names, CONFIG.showNames)
	setToggleState(displayToggles.distance, CONFIG.showDistance)
	setToggleState(displayToggles.fade, CONFIG.distanceFade)
	setToggleState(displayToggles.health, CONFIG.showHealth)
	setToggleState(displayToggles.weapon, CONFIG.showWeapon)
	setToggleState(displayToggles.skeleton, CONFIG.showSkeleton)
	setToggleState(displayToggles.headDot, CONFIG.showHeadDot)
	setSliderState(displayToggles.headDotSize, CONFIG.headDotSize)
	setToggleState(displayToggles.focus, CONFIG.showFocusTarget)
	setToggleState(displayToggles.boxes, CONFIG.showBoxes)
	setToggleState(displayToggles.targetCard, CONFIG.showTargetCard)
	setToggleState(displayToggles.targetCardCompact, CONFIG.targetCardCompact)
	displayToggles.textStack.Text = CONFIG.textStackMode
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
	setToggleState(miniHudToggle, CONFIG.showMiniHud)
	setToggleState(viewButtons.removeZoomLimit, CONFIG.removeZoomLimit)
	setToggleState(miniHudLabels.utility.antiAfk, CONFIG.antiAfk)
	setToggleState(miniHudLabels.utility.autoLoadGamePreset, CONFIG.autoLoadGamePreset)
	setToggleState(performanceToggles.mode, CONFIG.performanceMode)
	setToggleState(performanceToggles.materials, CONFIG.simplifyMaterials)
	setToggleState(performanceToggles.textures, CONFIG.hideTextures)
	setToggleState(performanceToggles.effects, CONFIG.hideEffects)
	setToggleState(performanceToggles.shadows, CONFIG.disableShadows)
	setToggleState(compactToggle, CONFIG.compactMode)
	setSliderState(tracerSliders.fovCircleSlider, CONFIG.fovRadius)
	setSliderState(cameraFovSlider, CONFIG.cameraFov)
	tracerSliders.crosshairStyleButton.Text = string.format("< %s >", CONFIG.crosshairStyle)
	setOptionButtonsState(crosshairColorButtons, CONFIG.crosshairColor)
	setSliderState(tracerSliders.crosshairThickness, CONFIG.crosshairThickness)
	setSliderState(tracerSliders.crosshairSizeSlider, CONFIG.crosshairSize)
	setSliderState(tracerSliders.crosshairGap, CONFIG.crosshairGap)
	displayToggles.boxMode.Text = getEffectiveBoxMode()
	presetButton.Text = PRESETS[currentPresetIndex].name
	miniHudLabels.saveStatusValue.Text = canUseFileApi() and "AUTO SAVE" or "MEMORY"
	miniHud.Visible = CONFIG.showMiniHud
	updateViewUi()
end

presetButton.MouseButton1Click:Connect(function()
	currentPresetIndex = currentPresetIndex % #PRESETS + 1
	PRESETS[currentPresetIndex].apply()
	syncUiFromConfig()
	applyPerformanceSettings()
	refreshAllEsp()
	saveSettings()
end)

displayToggles.boxMode.MouseButton1Click:Connect(function()
	local currentIndex = table.find(BOX_MODE_OPTIONS, CONFIG.boxMode) or 1
	currentIndex = currentIndex % #BOX_MODE_OPTIONS + 1
	CONFIG.boxMode = BOX_MODE_OPTIONS[currentIndex]
	displayToggles.boxMode.Text = CONFIG.boxMode
	refreshAllEsp()
	saveSettings()
end)

displayToggles.textStack.MouseButton1Click:Connect(function()
	local options = { "Inline", "Stacked" }
	local currentIndex = table.find(options, CONFIG.textStackMode) or 1
	currentIndex = currentIndex % #options + 1
	CONFIG.textStackMode = options[currentIndex]
	displayToggles.textStack.Text = CONFIG.textStackMode
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

cameraFovSlider.reset.MouseButton1Click:Connect(function()
	CONFIG.cameraFov = DEFAULT_CAMERA_FOV
	setSliderState(cameraFovSlider, CONFIG.cameraFov)
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
	local draggingCrosshairSize = false

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

	tracerSliders.crosshairSizeSlider.bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingCrosshairSize = true
			updateCrosshairSizeFromX(input.Position.X)
		end
	end)

	tracerSliders.crosshairSizeSlider.bar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingCrosshairSize = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if draggingCrosshairSize and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateCrosshairSizeFromX(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingCrosshairSize = false
		end
	end)

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
	local draggingHeadDotSize = false

	local function updateHeadDotSizeFromX(positionX)
		local bar = displayToggles.headDotSize.bar
		local relative = math.clamp(positionX - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
		local alpha = 0
		if bar.AbsoluteSize.X > 0 then
			alpha = relative / bar.AbsoluteSize.X
		end

		local value = math.floor(displayToggles.headDotSize.min + ((displayToggles.headDotSize.max - displayToggles.headDotSize.min) * alpha) + 0.5)
		value = math.clamp(value, displayToggles.headDotSize.min, displayToggles.headDotSize.max)

		if CONFIG.headDotSize ~= value then
			CONFIG.headDotSize = value
			refreshAllEsp()
			saveSettings()
			showToast("Setting Updated", string.format("Head Dot Size set to %d", CONFIG.headDotSize), THEME.accent)
		end

		setSliderState(displayToggles.headDotSize, CONFIG.headDotSize)
	end

	displayToggles.headDotSize.bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingHeadDotSize = true
			updateHeadDotSizeFromX(input.Position.X)
		end
	end)

	displayToggles.headDotSize.bar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingHeadDotSize = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if draggingHeadDotSize and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateHeadDotSizeFromX(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingHeadDotSize = false
		end
	end)

	bindSliderValueInput(displayToggles.headDotSize, function(typedValue)
		if typedValue == nil then
			return CONFIG.headDotSize
		end

		return math.clamp(math.floor(typedValue + 0.5), displayToggles.headDotSize.min, displayToggles.headDotSize.max)
	end, function(nextValue)
		if CONFIG.headDotSize ~= nextValue then
			CONFIG.headDotSize = nextValue
			refreshAllEsp()
			saveSettings()
		end
	end)
end

miniHudLabels.utility.rejoin.MouseButton1Click:Connect(function()
	pcall(function()
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LOCAL_PLAYER)
	end)
end)

miniHudLabels.utility.hop.MouseButton1Click:Connect(function()
	local success, response = pcall(function()
		return HttpService:JSONDecode(game:HttpGet(string.format(
			"https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100",
			game.PlaceId
		)))
	end)

	if not success or not response or not response.data then
		showToast("Player Utility", "Server hop failed", THEME.muted)
		return
	end

	for _, server in ipairs(response.data) do
		if server.id ~= game.JobId and server.playing < server.maxPlayers then
			pcall(function()
				game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, LOCAL_PLAYER)
			end)
			return
		end
	end

	showToast("Player Utility", "No open server found", THEME.muted)
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
	local draggingFovCircle = false

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

	tracerSliders.fovCircleSlider.bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingFovCircle = true
			updateFovCircleFromX(input.Position.X)
		end
	end)

	tracerSliders.fovCircleSlider.bar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingFovCircle = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if draggingFovCircle and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateFovCircleFromX(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingFovCircle = false
		end
	end)

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
	local draggingCameraFov = false

	local function updateCameraFovFromX(positionX)
		local bar = cameraFovSlider.bar
		local relative = math.clamp(positionX - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
		local alpha = 0
		if bar.AbsoluteSize.X > 0 then
			alpha = relative / bar.AbsoluteSize.X
		end

		local value = math.floor(cameraFovSlider.min + ((cameraFovSlider.max - cameraFovSlider.min) * alpha) + 0.5)
		value = math.clamp(value, cameraFovSlider.min, cameraFovSlider.max)

		if CONFIG.cameraFov ~= value then
			CONFIG.cameraFov = value
			applyCameraFov()
			saveSettings()
		end

		setSliderState(cameraFovSlider, CONFIG.cameraFov)
	end

	cameraFovSlider.bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingCameraFov = true
			updateCameraFovFromX(input.Position.X)
		end
	end)

	cameraFovSlider.bar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingCameraFov = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if draggingCameraFov and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateCameraFovFromX(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingCameraFov = false
		end
	end)

	bindSliderValueInput(cameraFovSlider, function(typedValue)
		if typedValue == nil then
			return CONFIG.cameraFov
		end

		return math.clamp(math.floor(typedValue + 0.5), cameraFovSlider.min, cameraFovSlider.max)
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
		entry.slider.bar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				draggingCombatSlider = entry
				updateTracerSlider(entry, input.Position.X)
			end
		end)

		entry.slider.bar.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				draggingCombatSlider = nil
			end
		end)
	end

	UserInputService.InputChanged:Connect(function(input)
		if draggingCombatSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateTracerSlider(draggingCombatSlider, input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingCombatSlider = nil
		end
	end)

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
	local draggingFreeCamSpeed = false

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

	viewButtons.speed.bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingFreeCamSpeed = true
			updateFreeCamSpeedFromX(input.Position.X)
		end
	end)

	viewButtons.speed.bar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingFreeCamSpeed = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if draggingFreeCamSpeed and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateFreeCamSpeedFromX(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingFreeCamSpeed = false
		end
	end)

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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if getgenv().__VYRS_ESP_ACTIVE_TOKEN ~= gui:GetAttribute("ActiveToken") then
		return
	end

	if gameProcessed then
		return
	end

	if keybindController and keybindController.handleInput(input) then
		return
	end

	if viewState.freeCamEnabled then
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			viewState.lookHeld = true
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
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
		elseif input.KeyCode == Enum.KeyCode.Escape then
			toggleFreeCam()
			return
		end
	end

	if input.KeyCode == CONFIG.quickHideKey then
		window.Visible = not window.Visible
		miniHud.Visible = window.Visible and CONFIG.showMiniHud
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

	if keybindController and keybindController.handleInputEnded then
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

	if gui.Enabled then
		updateCrosshair()
	else
		hideCrosshair()
	end
	updateMouseIconVisibility()
	updatePerfStatsUi()
	updateAccumulator = updateAccumulator + deltaTime
	if updateAccumulator >= updateInterval then
		updateAccumulator = 0
		refreshAllEsp()
	end
end)

task.spawn(playIntroAnimation)
