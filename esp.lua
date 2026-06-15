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

local SHARED_ENV = (type(getgenv) == "function" and getgenv())
	or (type(getfenv) == "function" and getfenv(0))
	or _G

SHARED_ENV.__VYRS_ESP_ACTIVE_TOKEN = tostring(os.clock())

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
	version = "1.5",
	telemetryUrl = "https://YOUR-RAILWAY-APP.up.railway.app/api/ping",
	telemetryHeartbeatSeconds = 60,
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

local function removeDrawingObject(object)
	if not object then
		return
	end

	local removeMethod = object.Remove or object.Destroy
	if type(removeMethod) == "function" then
		pcall(removeMethod, object)
	end
end

local function supportsDrawing(kind)
	local object = createDrawing(kind)
	if not object then
		return false
	end

	removeDrawingObject(object)
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
local espRuntimeState = {
	visibleEnemyCount = 0,
	trackedEnemyCount = 0,
	lastRefreshMs = 0,
	updateInterval = 1 / 30,
	focusedPlayer = nil,
}
local PRESETS
local currentPresetIndex = 2
local SETTING_KEYS
local toastLayer
local uiReady = false
local syncUiFromConfig
local getCharacterRoot
local applyConfigToggleState
local updateMouseIconVisibility
local pages
local tabButtons
local createNoteRow
local createOptionButtonsRow
local createPerfRow
local createRow
local createSliderRow
local createSpectateRow
local createStatusRow
local createTabButton
local createToggleRow
local createKeybindRow
local createCycleRow
local setActiveTab
local setOptionButtonsState
local setSliderState
local setToggleState
local applySliderVisual
local bindSliderValueInput
local bindToggle
local setEspEnabled
local resetOverlayPositions
local clearEntry
local clearPlayerEsp
local refreshAllEsp
local clearAllEsp
local resetAllBoxEspVisuals
local trackingRuntime
local viewRuntime
local performanceRuntime
local statusRuntime
local applyZoomLimitSetting
local setLocalMovementSuppressed
local restoreLocalCamera
local updateViewUi
local setSpectateTarget
local toggleFreeCam
local applyCameraFov
local getMouseScreenPosition
local getTracerOrigin
local applyPerformanceSettings
local updatePerfStatsUi
local updateCrosshair
local hideCrosshair
local loadedTrainerRecords
local loadedTrainerCustomPresets
local keybindController
local overlayTools
local loadConfigSlot
local deleteConfigSlot
local getConfigSlotNames
local playerEspRenderer
local keybindState = {
	toggleButtonsByConfig = {},
}
local KEYBINDS_MODULE_SOURCE = nil
local UI_FRAMEWORK_MODULE_SOURCE = nil
local TRACKING_RUNTIME_MODULE_SOURCE = nil
local VIEW_RUNTIME_MODULE_SOURCE = nil
local PERFORMANCE_RUNTIME_MODULE_SOURCE = nil
local STATUS_RUNTIME_MODULE_SOURCE = nil
local RUNTIME_HOOKS_MODULE_SOURCE = nil
local OVERLAY_TOOLS_MODULE_SOURCE = nil
local PLAYER_ESP_MODULE_SOURCE = nil
local DRAWING_ESP_MODULE_SOURCE = nil
local INTRO_ANIMATION_MODULE_SOURCE = nil

local function canUseFileApi()
	return type(isfile) == "function" and type(readfile) == "function" and type(writefile) == "function"
end

local function requireLocalModule(modulePath, fallbackSource)
	if type(loadstring) ~= "function" then
		return nil
	end

	local source = fallbackSource
	local loadErrors = {}
	local fileName = tostring(modulePath):match("[^\\/]+$")

	if type(readfile) == "function" then
		local candidates = {}
		local seen = {}

		local function addCandidate(path)
			if type(path) == "string" and path ~= "" and not seen[path] then
				seen[path] = true
				table.insert(candidates, path)
			end
		end

		addCandidate(modulePath)

		local relativeModulePath = tostring(modulePath):match("(esp_modules[\\/].+)$")
		if relativeModulePath then
			local slashPath = relativeModulePath:gsub("\\", "/")
			local backslashPath = relativeModulePath:gsub("/", "\\")
			addCandidate(slashPath)
			addCandidate("./" .. slashPath)
			addCandidate(backslashPath)
			addCandidate(".\\" .. backslashPath)
		end

		if fileName then
			local customModuleDir = SHARED_ENV and SHARED_ENV.__VYRS_ESP_MODULE_DIR
			if type(customModuleDir) == "string" and customModuleDir ~= "" then
				local normalizedDir = customModuleDir:gsub("[\\/]+$", "")
				addCandidate(normalizedDir .. "/" .. fileName)
				addCandidate(normalizedDir .. "\\" .. fileName)
			end

			addCandidate("esp_modules/" .. fileName)
			addCandidate("esp_modules\\" .. fileName)
			addCandidate("ESP/esp_modules/" .. fileName)
			addCandidate("ESP\\esp_modules\\" .. fileName)
		end

		for _, candidate in ipairs(candidates) do
			local success, result = pcall(function()
				return readfile(candidate)
			end)
			if success and type(result) == "string" and result ~= "" then
				source = result
				break
			elseif not success then
				table.insert(loadErrors, string.format("%s: %s", candidate, tostring(result)))
			end
		end
	end

	if (type(source) ~= "string" or source == "") and fileName and type(game.HttpGet) == "function" then
		local baseUrl = SHARED_ENV and SHARED_ENV.__VYRS_ESP_MODULE_BASE_URL
		if type(baseUrl) ~= "string" or baseUrl == "" then
			baseUrl = "https://raw.githubusercontent.com/gamer94z/Universal-ROBLOX-ESP-Suite/main/esp_modules"
		end
		baseUrl = baseUrl:gsub("/+$", "")

		local url = baseUrl .. "/" .. fileName
		local success, result = pcall(function()
			return game:HttpGet(url)
		end)
		if success and type(result) == "string" and result ~= "" then
			source = result
		else
			table.insert(loadErrors, string.format("%s: %s", url, tostring(result)))
		end
	end

	if type(source) ~= "string" or source == "" then
		if #loadErrors > 0 then
			warn("[0xVyrs] Module read failed: " .. table.concat(loadErrors, " | "))
		end
		return nil
	end

	local success, result = pcall(function()
		local chunk = loadstring(source)
		return chunk and chunk()
	end)

	if success then
		return result
	end

	warn(string.format("[0xVyrs] Module compile failed for %s: %s", tostring(modulePath), tostring(result)))
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
gui:SetAttribute("ActiveToken", SHARED_ENV.__VYRS_ESP_ACTIVE_TOKEN)

create("UIScale", {
	Scale = 0.94,
	Parent = gui,
})

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
	Draggable = false,
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
currentFps = 0

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

do
local function getTelemetryRequest()
	return (syn and syn.request)
		or (http and http.request)
		or http_request
		or request
end

local function isTelemetryUrlConfigured()
	return type(CONFIG.telemetryUrl) == "string"
		and CONFIG.telemetryUrl:match("^https://")
		and not CONFIG.telemetryUrl:find("YOUR%-RAILWAY%-APP", 1, true)
end

local function sendTelemetryPing(eventName, sessionId, startedAt)
	local requestFn = getTelemetryRequest()
	if not requestFn or not isTelemetryUrlConfigured() then
		return false
	end

	local payload = {
		event = eventName,
		sessionId = sessionId,
		version = tostring(CONFIG.version),
		placeId = tostring(game.PlaceId),
		jobId = tostring(game.JobId or ""),
		uptime = math.max(0, math.floor(os.clock() - startedAt)),
		clientTime = os.time(),
	}

	local ok = pcall(function()
		requestFn({
			Url = CONFIG.telemetryUrl,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
				["X-0xVyrs-Version"] = tostring(CONFIG.version),
			},
			Body = HttpService:JSONEncode(payload),
		})
	end)

	return ok
end

local function startTelemetry()
	if not isTelemetryUrlConfigured() then
		return
	end

	local sessionId = HttpService:GenerateGUID(false)
	local startedAt = os.clock()

	task.spawn(function()
		sendTelemetryPing("launch", sessionId, startedAt)
		while SHARED_ENV.__VYRS_ESP_ACTIVE_TOKEN do
			task.wait(math.max(15, tonumber(CONFIG.telemetryHeartbeatSeconds) or 60))
			if SHARED_ENV.__VYRS_ESP_ACTIVE_TOKEN ~= gui:GetAttribute("ActiveToken") then
				break
			end
			sendTelemetryPing("heartbeat", sessionId, startedAt)
		end
	end)
end

startTelemetry()
end

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

chrome.dragHandle = create("TextButton", {
	AutoButtonColor = false,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, -52, 0, 46),
	Text = "",
	ZIndex = 5,
	Parent = chrome.topBar,
})

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

local function getViewportSize()
	local camera = workspace.CurrentCamera
	return camera and camera.ViewportSize or Vector2.new(1920, 1080)
end

local function setWindowTopLeft(topLeft, size)
	local viewport = getViewportSize()
	local width = size and size.X.Offset or window.AbsoluteSize.X
	local height = size and size.Y.Offset or window.AbsoluteSize.Y
	local maxX = math.max(0, viewport.X - width)
	local maxY = math.max(0, viewport.Y - height)
	local x = math.clamp(math.floor(topLeft.X + 0.5), 0, maxX)
	local y = math.clamp(math.floor(topLeft.Y + 0.5), 0, maxY)
	local centerX = x + (width * 0.5)
	local centerY = y + (height * 0.5)

	window.AnchorPoint = Vector2.new(0.5, 0.5)
	window.Position = UDim2.new(0.5, centerX - (viewport.X * 0.5), 0.5, centerY - (viewport.Y * 0.5))
end

local function bindWindowDrag(handle)
	local dragging = false
	local dragStart
	local startTopLeft

	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		dragging = true
		dragStart = input.Position
		startTopLeft = window.AbsolutePosition

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch) then
			return
		end

		local delta = input.Position - dragStart
		setWindowTopLeft(Vector2.new(startTopLeft.X + delta.X, startTopLeft.Y + delta.Y), window.Size)
	end)
end

bindWindowDrag(chrome.dragHandle)

local uiFrameworkFactory = requireLocalModule("C:\\Users\\alexl\\Desktop\\ESP\\esp_modules\\ui_framework.lua", UI_FRAMEWORK_MODULE_SOURCE)
local uiFramework = type(uiFrameworkFactory) == "function" and uiFrameworkFactory({
	create = create,
	addCorner = addCorner,
	addStroke = addStroke,
	makeLabel = makeLabel,
	TweenService = TweenService,
	theme = THEME,
	colorOptions = CROSSHAIR_COLOR_OPTIONS,
	tabBar = tabBar,
	pagesContainer = pagesContainer,
}) or nil

if not uiFramework then
	error("Failed to load ui framework module")
end

pages = uiFramework.pages
tabButtons = uiFramework.tabButtons
createNoteRow = uiFramework.createNoteRow
createOptionButtonsRow = uiFramework.createOptionButtonsRow
createPerfRow = uiFramework.createPerfRow
createRow = uiFramework.createRow
createSliderRow = uiFramework.createSliderRow
createSpectateRow = uiFramework.createSpectateRow
createStatusRow = uiFramework.createStatusRow
createTabButton = uiFramework.createTabButton
createToggleRow = uiFramework.createToggleRow
createKeybindRow = uiFramework.createKeybindRow
createCycleRow = uiFramework.createCycleRow
setActiveTab = uiFramework.setActiveTab
setOptionButtonsState = uiFramework.setOptionButtonsState
setSliderState = uiFramework.setSliderState
setToggleState = uiFramework.setToggleState
applySliderVisual = uiFramework.applySliderVisual
bindSliderValueInput = uiFramework.bindSliderValueInput

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

do
	local function collapseControlRow(guiObject)
		local row = guiObject and guiObject.Parent
		if row then
			row.Visible = false
			row.Size = UDim2.new(1, 0, 0, 0)
		end
	end

	collapseControlRow(viewButtons.speed and viewButtons.speed.bar)
end

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
miniHudLabels.bindTooltip(viewButtons.status, "Shows whether you are on local view or spectating.")
miniHudLabels.bindTooltip(viewButtons.spectate.main, "Open the player list to spectate another character.")
miniHudLabels.bindTooltip(viewButtons.spectate.off, "Immediately return from spectate to your own camera.")
miniHudLabels.bindTooltip(viewButtons.freeCam, "Free Cam is disabled in this build.")
miniHudLabels.bindTooltip(viewButtons.speed.bar, "Free Cam speed is retained for old configs but not used.")
miniHudLabels.bindTooltip(viewButtons.reset, "Restores spectate and view settings.")
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

local function addRiskWarning(control, tooltipText)
	local row = control and control.Parent
	if not row or row:FindFirstChild("RiskWarning") then
		return
	end

	local warning = create("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBlack,
		Name = "RiskWarning",
		Position = UDim2.new(1, -72, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 14),
		Text = "▲",
		TextColor3 = Color3.fromRGB(255, 92, 92),
		TextSize = 12,
		TextStrokeColor3 = Color3.fromRGB(32, 8, 8),
		TextStrokeTransparency = 0.2,
		ZIndex = math.max(row.ZIndex or 1, control.ZIndex or 1) + 3,
		Parent = row,
	})

	local function updateWarningPosition()
		if not row.Parent or not control.Parent or row.AbsoluteSize.X <= 0 then
			return
		end

		local controlLeft = control.AbsolutePosition.X - row.AbsolutePosition.X
		local x = math.clamp(controlLeft - 12, 84, math.max(84, row.AbsoluteSize.X - 22))
		warning.Position = UDim2.new(0, x, 0.5, 0)
	end

	task.defer(updateWarningPosition)
	row:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateWarningPosition)
	control:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateWarningPosition)
	control:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateWarningPosition)
	miniHudLabels.bindTooltip(warning, tooltipText or "Use with caution. This feature may be risky in some games.")
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

addRiskWarning(viewButtons.freeCam, "Use with caution. Free Cam is disabled here because scriptable camera movement is commonly flagged.")
addRiskWarning(viewButtons.removeZoomLimit, "Use with caution. Camera changes can be noticeable in some games.")
addRiskWarning(playerButtons.walkSpeedToggle, "Use with caution. Movement speed changes can be detected by some games.")
addRiskWarning(playerButtons.walkSpeed.bar, "Use with caution. Higher speed values can be detected by some games.")
addRiskWarning(playerButtons.infiniteJump, "Use with caution. Repeated airborne jumps can be detected by some games.")
addRiskWarning(playerButtons.noclip, "Use with caution. Collision bypass can be detected by some games.")
addRiskWarning(playerButtons.fly, "Use with caution. Flight is a high-risk movement feature.")
addRiskWarning(playerButtons.flySpeed.bar, "Use with caution. Higher flight speed values can be detected by some games.")
addRiskWarning(playerButtons.clickTeleport, "Use with caution. Teleporting movement is a high-risk feature.")

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
miniHudLabels.utility.targetTelemetry = {}
local performanceCache = {
	parts = {},
	textures = {},
	effects = {},
	lighting = nil,
}
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
	return CONFIG.showFocusTarget and espRuntimeState.focusedPlayer == player
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
	setLocalMovementSuppressed(false)
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
	if SHARED_ENV.__VYRS_ESP_ACTIVE_TOKEN ~= gui:GetAttribute("ActiveToken") then
		return
	end

	if activeSliderDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
		activeSliderDrag.update(input.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if SHARED_ENV.__VYRS_ESP_ACTIVE_TOKEN ~= gui:GetAttribute("ActiveToken") then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 and activeSliderDrag then
		clearActiveSliderDrag()
	end
end)


do
	local viewFactory = requireLocalModule("C:\\Users\\alexl\\Desktop\\ESP\\esp_modules\\view_runtime.lua", VIEW_RUNTIME_MODULE_SOURCE)
	if type(viewFactory) == "function" then
		viewRuntime = viewFactory({
			CONFIG = CONFIG,
			LOCAL_PLAYER = LOCAL_PLAYER,
			UserInputService = UserInputService,
			viewState = viewState,
			viewButtons = viewButtons,
			playerButtons = playerButtons,
			THEME = THEME,
			truncateText = truncateText,
			getCamera = getCamera,
			getLocalHumanoid = getLocalHumanoid,
			getMouseLocation = function()
				return UserInputService:GetMouseLocation()
			end,
			setToggleState = function(button, state)
				return setToggleState(button, state)
			end,
			setSliderState = function(slider, value)
				return setSliderState(slider, value)
			end,
			updateMouseIconVisibility = function()
				return updateMouseIconVisibility()
			end,
			showToast = showToast,
			updateKeybindController = function()
				if keybindController then
					keybindController.update()
				end
			end,
		})
	end
end

if viewRuntime then
	applyZoomLimitSetting = viewRuntime.applyZoomLimitSetting
	setLocalMovementSuppressed = viewRuntime.setLocalMovementSuppressed
	restoreLocalCamera = viewRuntime.restoreLocalCamera
	updateViewUi = viewRuntime.updateViewUi
	setSpectateTarget = viewRuntime.setSpectateTarget
	toggleFreeCam = viewRuntime.toggleFreeCam
	applyCameraFov = viewRuntime.applyCameraFov
	getMouseScreenPosition = viewRuntime.getMouseScreenPosition
	getTracerOrigin = viewRuntime.getTracerOrigin
end

function getCharacterRoot(character)
	return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
end

do
	local performanceFactory = requireLocalModule("C:\\Users\\alexl\\Desktop\\ESP\\esp_modules\\performance_runtime.lua", PERFORMANCE_RUNTIME_MODULE_SOURCE)
	if type(performanceFactory) == "function" then
		performanceRuntime = performanceFactory({
			CONFIG = CONFIG,
			Lighting = Lighting,
			workspace = workspace,
			performanceCache = performanceCache,
		})
	end
end

if performanceRuntime then
	applyPerformanceSettings = performanceRuntime.applyPerformanceSettings
end

local drawingEsp

do
	local drawingFactory = requireLocalModule("C:\\Users\\alexl\\Desktop\\ESP\\esp_modules\\drawing_esp.lua", DRAWING_ESP_MODULE_SOURCE)
	if type(drawingFactory) == "function" then
		drawingEsp = drawingFactory({
			CONFIG = CONFIG,
			LOCAL_PLAYER = LOCAL_PLAYER,
			THEME = THEME,
			DEV_TAG_TEXT = DEV_TAG_TEXT,
			DRAWING_SUPPORT = DRAWING_SUPPORT,
			SKELETON_CONNECTIONS = SKELETON_CONNECTIONS,
			BOX_3D_EDGES = BOX_3D_EDGES,
			drawingSupported = drawingSupported,
			espObjects = espObjects,
			create = create,
			addCorner = addCorner,
			createDrawing = createDrawing,
			removeDrawingObject = removeDrawingObject,
			getCharacterRoot = getCharacterRoot,
			getEffectiveBoxMode = getEffectiveBoxMode,
			isChamsBoxMode = isChamsBoxMode,
			isFocusedTarget = isFocusedTarget,
			getCamera = getCamera,
			getHeldToolName = getHeldToolName,
			getTracerOrigin = getTracerOrigin,
			getMouseScreenPosition = getMouseScreenPosition,
			updateMouseIconVisibility = updateMouseIconVisibility,
			CROSSHAIR_COLOR_OPTIONS = CROSSHAIR_COLOR_OPTIONS,
			gui = gui,
			window = window,
			UserInputService = UserInputService,
			viewState = viewState,
		})
	end
end

if type(drawingEsp) ~= "table" then
	error("[0xVyrs] drawing_esp module failed to load")
end

clearEntry = drawingEsp.clearEntry
clearPlayerEsp = drawingEsp.clearPlayerEsp
resetAllBoxEspVisuals = drawingEsp.resetAllBoxEspVisuals
updateCrosshair = drawingEsp.updateCrosshair
hideCrosshair = drawingEsp.hideCrosshair
updateMouseIconVisibility = drawingEsp.updateMouseIconVisibility
do
	local playerEspFactory = requireLocalModule("C:\\Users\\alexl\\Desktop\\ESP\\esp_modules\\player_esp.lua", PLAYER_ESP_MODULE_SOURCE)
	if type(playerEspFactory) == "function" then
		local playerEspModule = playerEspFactory({
			CONFIG = CONFIG,
			LOCAL_PLAYER = LOCAL_PLAYER,
			THEME = THEME,
			DEV_TAG_DISTANCE = DEV_TAG_DISTANCE,
			getEspEntry = drawingEsp.getEspEntry,
			clearEntry = clearEntry,
			shouldTrackPlayer = shouldTrackPlayer,
			getCharacterRoot = getCharacterRoot,
			getEspColor = getEspColor,
			isPlayerVisible = drawingEsp.isPlayerVisible,
			getDisplayColor = drawingEsp.getDisplayColor,
			getDistanceFade = drawingEsp.getDistanceFade,
			isFocusedTarget = isFocusedTarget,
			isDevPlayer = isDevPlayer,
			getRainbowColor = drawingEsp.getRainbowColor,
			getTargetThreatData = getTargetThreatData,
			getTracerColor = getTracerColor,
			getCamera = getCamera,
			getEffectiveBoxMode = getEffectiveBoxMode,
			ensureHighlight = drawingEsp.ensureHighlight,
			updateBoxEsp = drawingEsp.updateBoxEsp,
			updateSkeletonEsp = drawingEsp.updateSkeletonEsp,
			updateLookDirectionEsp = drawingEsp.updateLookDirectionEsp,
			updateBillboardEsp = drawingEsp.updateBillboardEsp,
			updateTracerEsp = drawingEsp.updateTracerEsp,
			updateHeadDotEsp = drawingEsp.updateHeadDotEsp,
		})
		if type(playerEspModule) == "table" and type(playerEspModule.updatePlayerEsp) == "function" then
			playerEspRenderer = playerEspModule.updatePlayerEsp
		end
	end
end

local function updatePlayerEsp(player, precomputed)
	if playerEspRenderer then
		return playerEspRenderer(player, precomputed)
	end

	clearEntry(drawingEsp.getEspEntry(player))
end

do
	local statusFactory = requireLocalModule("C:\\Users\\alexl\\Desktop\\ESP\\esp_modules\\status_runtime.lua", STATUS_RUNTIME_MODULE_SOURCE)
	if type(statusFactory) == "function" then
		statusRuntime = statusFactory({
			CONFIG = CONFIG,
			THEME = THEME,
			LOCAL_PLAYER = LOCAL_PLAYER,
			gui = gui,
			uiReady = function()
				return uiReady
			end,
			espRuntimeState = espRuntimeState,
			miniHudLabels = miniHudLabels,
			tracerSliders = tracerSliders,
			getCurrentFps = function()
				return currentFps
			end,
			truncateText = truncateText,
			getCharacterRoot = getCharacterRoot,
			getHeldToolName = getHeldToolName,
			getActiveTrainerPresetName = getActiveTrainerPresetName,
			getTrainerPresetColor = getTrainerPresetColor,
		})
	end
end

if statusRuntime then
	updatePerfStatsUi = statusRuntime.updatePerfStatsUi
end

if type(updatePerfStatsUi) ~= "function" then
	updatePerfStatsUi = function()
	end
end

do
	local trackingFactory = requireLocalModule("C:\\Users\\alexl\\Desktop\\ESP\\esp_modules\\tracking_runtime.lua", TRACKING_RUNTIME_MODULE_SOURCE)
	if type(trackingFactory) == "function" then
		trackingRuntime = trackingFactory({
			CONFIG = CONFIG,
			LOCAL_PLAYER = LOCAL_PLAYER,
			Players = Players,
			state = espRuntimeState,
			viewState = viewState,
			clearEntry = clearEntry,
			clearPlayerEsp = clearPlayerEsp,
			espObjects = espObjects,
			getCharacterRoot = getCharacterRoot,
			shouldTrackPlayer = shouldTrackPlayer,
			getHeldToolName = getHeldToolName,
			isPlayerVisible = drawingEsp.isPlayerVisible,
			getTargetThreatData = getTargetThreatData,
			updatePlayerEsp = updatePlayerEsp,
			updatePerfStatsUi = updatePerfStatsUi,
			getCurrentFps = function()
				return currentFps
			end,
		})
	end
end

refreshAllEsp = function()
	if trackingRuntime and trackingRuntime.refreshAllEsp then
		return trackingRuntime.refreshAllEsp()
	end
end

clearAllEsp = function()
	if trackingRuntime and trackingRuntime.clearAllEsp then
		return trackingRuntime.clearAllEsp()
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

bindToggle = function(button, configKey)
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

setEspEnabled = function(state)
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

miniHudLabels.utility.applyMinimalMode = function(state, skipSave)
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

miniHudLabels.utility.setMinimized = function(state)
	local topLeft = window.AbsolutePosition
	local nextSize

	uiMinimized = state
	content.Visible = not state
	if CONFIG.minimalMode then
		nextSize = state and minimalMinimizedWindowSize or minimalWindowSize
	else
		nextSize = state and minimizedWindowSize or expandedWindowSize
	end
	window.Size = nextSize
	setWindowTopLeft(topLeft, nextSize)
	chrome.minimizeButton.Text = state and "+" or "-"
end

resetOverlayPositions = function()
	if overlayTools and overlayTools.resetOverlayPosition then
		overlayTools.resetOverlayPosition(miniHud, "miniHud")
		overlayTools.resetOverlayPosition(tracerSliders.targetCard, "targetCard")
	end
	if keybindController and keybindController.resetPosition then
		keybindController.resetPosition()
	end
end

miniHudLabels.utility.finalizeIntroStartup = function()
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
			miniHudLabels.utility.applyMinimalMode(CONFIG.minimalMode)
			setActiveTab("control")
			miniHudLabels.utility.setMinimized(false)

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

miniHudLabels.utility.playIntroAnimation = function()
	if introController and introController.play then
		introController.play(miniHudLabels.utility.finalizeIntroStartup)
	else
		miniHudLabels.utility.finalizeIntroStartup()
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

keybindState.toggleButtonsByConfig.enabled = miniHudLabels.utility.controls.enabledToggle
keybindState.toggleButtonsByConfig.showNames = miniHudLabels.utility.displayToggles.names
keybindState.toggleButtonsByConfig.showDistance = miniHudLabels.utility.displayToggles.distance
keybindState.toggleButtonsByConfig.distanceFade = miniHudLabels.utility.displayToggles.fade
keybindState.toggleButtonsByConfig.showHealth = miniHudLabels.utility.displayToggles.health
keybindState.toggleButtonsByConfig.showWeapon = miniHudLabels.utility.displayToggles.weapon
keybindState.toggleButtonsByConfig.showSkeleton = miniHudLabels.utility.displayToggles.skeleton
keybindState.toggleButtonsByConfig.showHeadDot = miniHudLabels.utility.displayToggles.headDot
keybindState.toggleButtonsByConfig.showFocusTarget = miniHudLabels.utility.displayToggles.focus
keybindState.toggleButtonsByConfig.showBoxes = miniHudLabels.utility.displayToggles.boxes
keybindState.toggleButtonsByConfig.showTargetCard = miniHudLabels.utility.displayToggles.targetCard
keybindState.toggleButtonsByConfig.targetCardCompact = miniHudLabels.utility.displayToggles.targetCardCompact
keybindState.toggleButtonsByConfig.visibilityCheck = tracerSliders.visibilityToggle
keybindState.toggleButtonsByConfig.showTracers = tracerSliders.tracersToggle
keybindState.toggleButtonsByConfig.focusLock = tracerSliders.focusLock
keybindState.toggleButtonsByConfig.showLookDirection = tracerSliders.lookDirectionToggle
keybindState.toggleButtonsByConfig.showCrosshair = tracerSliders.crosshairToggle
keybindState.toggleButtonsByConfig.showFovCircle = tracerSliders.fovCircleToggle
keybindState.toggleButtonsByConfig.aimTrainerMode = tracerSliders.trainingToggle
keybindState.toggleButtonsByConfig.trainerReactionTimer = tracerSliders.trainingReactionToggle
keybindState.toggleButtonsByConfig.trainerChallengeMode = tracerSliders.trainingChallengeToggle
keybindState.toggleButtonsByConfig.trainerShrinkingTargets = tracerSliders.trainingShrinkingToggle
keybindState.toggleButtonsByConfig.recoilVisualizer = tracerSliders.recoilVisualizerToggle
keybindState.toggleButtonsByConfig.spreadVisualizer = tracerSliders.spreadVisualizerToggle
keybindState.toggleButtonsByConfig.showMiniHud = miniHudLabels.utility.controls.miniHudToggle
keybindState.toggleButtonsByConfig.removeZoomLimit = viewButtons.removeZoomLimit
keybindState.toggleButtonsByConfig.walkSpeedEnabled = playerButtons.walkSpeedToggle
keybindState.toggleButtonsByConfig.infiniteJump = playerButtons.infiniteJump
keybindState.toggleButtonsByConfig.noclip = playerButtons.noclip
keybindState.toggleButtonsByConfig.fly = playerButtons.fly
keybindState.toggleButtonsByConfig.clickTeleport = playerButtons.clickTeleport
keybindState.toggleButtonsByConfig.antiAfk = miniHudLabels.utility.antiAfk
keybindState.toggleButtonsByConfig.autoLoadGamePreset = miniHudLabels.utility.autoLoadGamePreset
keybindState.toggleButtonsByConfig.performanceMode = miniHudLabels.utility.performanceToggles.mode
keybindState.toggleButtonsByConfig.simplifyMaterials = miniHudLabels.utility.performanceToggles.materials
keybindState.toggleButtonsByConfig.hideTextures = miniHudLabels.utility.performanceToggles.textures
keybindState.toggleButtonsByConfig.hideEffects = miniHudLabels.utility.performanceToggles.effects
keybindState.toggleButtonsByConfig.disableShadows = miniHudLabels.utility.performanceToggles.shadows

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
	miniHudLabels.utility.applyMinimalMode(not CONFIG.minimalMode)
	setToggleState(miniHudLabels.utility.controls.minimalToggle, CONFIG.minimalMode)
	miniHudLabels.utility.setMinimized(uiMinimized)
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
			removeDrawingObject(segment)
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
	miniHudLabels.utility.applyMinimalMode(CONFIG.minimalMode, true)
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
	if keybindController then
		keybindController.update()
	end
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
do
	local hooksFactory = requireLocalModule("C:\\Users\\alexl\\Desktop\\ESP\\esp_modules\\runtime_hooks.lua", RUNTIME_HOOKS_MODULE_SOURCE)
	if type(hooksFactory) == "function" then
		local hooksModule = hooksFactory({
			CONFIG = CONFIG,
			THEME = THEME,
			SHARED_ENV = SHARED_ENV,
			gui = gui,
			window = window,
			watermark = watermark,
			miniHud = miniHud,
			miniHudLabels = miniHudLabels,
			chrome = chrome,
			Players = Players,
			LOCAL_PLAYER = LOCAL_PLAYER,
			UserInputService = UserInputService,
			RunService = RunService,
			tracerSliders = tracerSliders,
			viewButtons = viewButtons,
			playerButtons = playerButtons,
			viewState = viewState,
			espRuntimeState = espRuntimeState,
			espObjects = espObjects,
			saveNamedConfigFromInput = saveNamedConfigFromInput,
			resetOverlayPositions = resetOverlayPositions,
			resetDisplaySettings = resetDisplaySettings,
			resetViewSettings = resetViewSettings,
			resetPerformanceSettings = resetPerformanceSettings,
			syncUiFromConfig = syncUiFromConfig,
			refreshAllEsp = refreshAllEsp,
			saveSettings = saveSettings,
			showToast = showToast,
			applyCameraFov = applyCameraFov,
			applyZoomLimitSetting = applyZoomLimitSetting,
			updateViewUi = updateViewUi,
			applyPerformanceSettings = applyPerformanceSettings,
			getLocalHumanoid = getLocalHumanoid,
			hookCharacter = hookCharacter,
			clearPlayerEsp = clearPlayerEsp,
			setSpectateTarget = setSpectateTarget,
			bindSliderDragStart = bindSliderDragStart,
			bindSliderValueInput = bindSliderValueInput,
			setSliderState = setSliderState,
			updateCrosshair = updateCrosshair,
			updateTrainerVisuals = updateTrainerVisuals,
			applyPlayerMovementState = applyPlayerMovementState,
			ensureTrainerState = ensureTrainerState,
			getMouseScreenPosition = getMouseScreenPosition,
			getCamera = getCamera,
			recordTrainerClickSuccess = recordTrainerClickSuccess,
			spawnTrainerTarget = spawnTrainerTarget,
			recordTrainerClickMiss = recordTrainerClickMiss,
			getLocalRoot = getLocalRoot,
			setEspEnabled = setEspEnabled,
			hideCrosshair = hideCrosshair,
			updateMouseIconVisibility = updateMouseIconVisibility,
			getKeybindController = function()
				return keybindController
			end,
			toggleFreeCam = toggleFreeCam,
			setLocalMovementSuppressed = setLocalMovementSuppressed,
			getCurrentFps = function()
				return currentFps
			end,
			setCurrentFps = function(value)
				currentFps = value
			end,
			FLY_ACCELERATION = FLY_ACCELERATION,
			FLY_DECELERATION = FLY_DECELERATION,
			FLY_PRECISION_MULTIPLIER = FLY_PRECISION_MULTIPLIER,
			FLY_BOOST_MULTIPLIER = FLY_BOOST_MULTIPLIER,
			toggleMinimized = function()
				miniHudLabels.utility.setMinimized(not uiMinimized)
			end,
			isUiReady = function()
				return uiReady
			end,
			updatePerfStatsUi = updatePerfStatsUi,
		})
		if type(hooksModule) == "table" and type(hooksModule.setup) == "function" then
			hooksModule.setup()
		end
	else
		warn("[0xVyrs] Failed to load runtime hooks module")
	end
end

task.spawn(miniHudLabels.utility.playIntroAnimation)

