local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LOCAL_PLAYER = Players.LocalPlayer

local CONFIG = {
	enabled = true,
	showNames = true,
	showDistance = true,
	showHealth = true,
	showWeapon = true,
	showSkeleton = false,
	showFocusTarget = true,
	visibilityCheck = true,
	showTracers = true,
	boxMode = "Highlight",
	compactMode = false,
	showMiniHud = true,
	fallbackEspColor = Color3.fromRGB(255, 2, 127),
	visibleColor = Color3.fromRGB(117, 255, 160),
	hiddenColor = Color3.fromRGB(255, 116, 116),
	fillTransparency = 0.3,
	outlineTransparency = 0,
	maxDistance = 2500,
	panelTitle = "0xVyrs",
	panelSubtitle = " Panel",
	version = "0.0.1",
	uiToggleKey = Enum.KeyCode.RightShift,
	quickHideKey = Enum.KeyCode.K,
	espToggleKey = Enum.KeyCode.F4,
	panicKey = Enum.KeyCode.End,
}

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
local visibleEnemyCount = 0
local PRESETS
local currentPresetIndex = 2
local SETTING_KEYS
local toastLayer

local function canUseFileApi()
	return type(isfile) == "function" and type(readfile) == "function" and type(writefile) == "function"
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

	for _, key in ipairs(SETTING_KEYS) do
		if decoded[key] ~= nil then
			CONFIG[key] = decoded[key]
		end
	end

	if decoded.currentPresetIndex and PRESETS[decoded.currentPresetIndex] then
		currentPresetIndex = decoded.currentPresetIndex
	end
end

local function saveSettings()
	if not canUseFileApi() then
		return
	end

	local payload = {
		currentPresetIndex = currentPresetIndex,
	}

	for _, key in ipairs(SETTING_KEYS) do
		payload[key] = CONFIG[key]
	end

	local success = pcall(function()
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
}

local miniHudLabels = {}

local gui = create("ScreenGui", {
	Name = "ESPGUI",
	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = CoreGui,
})

local miniHud = create("Frame", {
	AnchorPoint = Vector2.new(1, 0),
	BackgroundColor3 = Color3.fromRGB(18, 22, 32),
	BorderSizePixel = 0,
	Position = UDim2.new(1, -16, 0, 16),
	Size = UDim2.new(0, 196, 0, 118),
	ZIndex = 12,
	Parent = gui,
})
addCorner(miniHud, 10)
addStroke(miniHud, THEME.border, 0.25, 1)

create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 27, 38)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 18, 26)),
	}),
	Rotation = 90,
	Parent = miniHud,
})

local miniHudTitle = makeLabel(miniHud, "0xVyrs Live", 11, THEME.text, Enum.Font.GothamBold)
miniHudTitle.Position = UDim2.new(0, 10, 0, 8)
miniHudTitle.Size = UDim2.new(1, -20, 0, 14)
miniHudTitle.ZIndex = 13

local miniHudSub = makeLabel(miniHud, "Combat Snapshot", 9, THEME.muted, Enum.Font.GothamMedium)
miniHudSub.Position = UDim2.new(0, 10, 0, 22)
miniHudSub.Size = UDim2.new(1, -20, 0, 12)
miniHudSub.ZIndex = 13

local miniHudBody = create("Frame", {
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 10, 0, 42),
	Size = UDim2.new(1, -20, 0, 64),
	ZIndex = 13,
	Parent = miniHud,
})

create("UIListLayout", {
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = miniHudBody,
})

local function createMiniHudRow(title)
	local row = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Size = UDim2.new(1, 0, 0, 15),
		ZIndex = 13,
		Parent = miniHudBody,
	})

	local left = makeLabel(row, title, 9, THEME.muted, Enum.Font.GothamBold)
	left.Size = UDim2.new(0.39, 0, 1, 0)
	left.ZIndex = 13

	local right = makeLabel(row, "--", 8, THEME.text, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
	right.AnchorPoint = Vector2.new(1, 0)
	right.Position = UDim2.new(1, 0, 0, 0)
	right.Size = UDim2.new(0.61, 0, 1, 0)
	right.ZIndex = 13

	return right
end

miniHudLabels.status = createMiniHudRow("STATUS")
miniHudLabels.fps = createMiniHudRow("FPS")
miniHudLabels.targets = createMiniHudRow("TARGETS")
miniHudLabels.focus = createMiniHudRow("FOCUS")
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

local introOverlay = create("Frame", {
	BackgroundColor3 = Color3.fromRGB(10, 12, 18),
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 20,
	Parent = gui,
})

local introCard = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(18, 22, 32),
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 20),
	Size = UDim2.new(0, 0, 0, 0),
	ZIndex = 21,
	Parent = introOverlay,
})
addCorner(introCard, 16)
addStroke(introCard, THEME.border, 0.2, 1)

local introGlow = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = THEME.accent,
	BackgroundTransparency = 0.9,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(1.25, 0, 1.35, 0),
	ZIndex = 20,
	Parent = introCard,
})
addCorner(introGlow, 999)

local introKicker = makeLabel(introCard, "SYSTEM ONLINE", 10, THEME.accent, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
introKicker.AnchorPoint = Vector2.new(0.5, 0)
introKicker.Position = UDim2.new(0.5, 0, 0, 18)
introKicker.Size = UDim2.new(1, -30, 0, 16)
introKicker.TextTransparency = 1
introKicker.ZIndex = 22

local introTitle = makeLabel(introCard, "Welcome to 0xVyrs ESP Suite", 20, THEME.text, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
introTitle.AnchorPoint = Vector2.new(0.5, 0.5)
introTitle.Position = UDim2.new(0.5, 0, 0.5, -2)
introTitle.Size = UDim2.new(1, -30, 0, 30)
introTitle.TextTransparency = 1
introTitle.ZIndex = 22

local introSub = makeLabel(introCard, "Adaptive overlays primed", 11, THEME.muted, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
introSub.AnchorPoint = Vector2.new(0.5, 1)
introSub.Position = UDim2.new(0.5, 0, 1, -18)
introSub.Size = UDim2.new(1, -30, 0, 16)
introSub.TextTransparency = 1
introSub.ZIndex = 22

local window = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = THEME.window,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 392, 0, 462),
	Active = true,
	Draggable = true,
	Parent = gui,
})
addCorner(window, 9)
addStroke(window, THEME.border, 0.2, 1)
window.Visible = false

local expandedWindowSize = UDim2.new(0, 392, 0, 462)
local minimizedWindowSize = UDim2.new(0, 392, 0, 96)
local compactWindowSize = UDim2.new(0, 340, 0, 394)
local compactMinimizedWindowSize = UDim2.new(0, 340, 0, 86)
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
}

local BOX_MODE_OPTIONS = { "Highlight", "2D Box", "Corner Box" }
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
	"showHealth",
	"showWeapon",
	"showSkeleton",
	"showFocusTarget",
	"visibilityCheck",
	"showTracers",
	"boxMode",
	"compactMode",
	"showMiniHud",
	"maxDistance",
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

local topBar = create("Frame", {
	BackgroundColor3 = THEME.header,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	Size = UDim2.new(1, 0, 0, 108),
	Parent = window,
})
addCorner(topBar, 9)

local minimizeButton = create("TextButton", {
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
	Parent = topBar,
})
addCorner(minimizeButton, 4)
addStroke(minimizeButton, THEME.border, 0.25, 1)

create("Frame", {
	BackgroundColor3 = Color3.fromRGB(56, 62, 78),
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 1, -1),
	Size = UDim2.new(1, 0, 0, 1),
	Parent = topBar,
})

local glow = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundColor3 = THEME.accent,
	BackgroundTransparency = 0.9,
	BorderSizePixel = 0,
	Position = UDim2.new(0.58, 0, 0, -28),
	Size = UDim2.new(0.95, 0, 0, 140),
	Parent = topBar,
})
addCorner(glow, 120)

local brand = create("Frame", {
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 12, 0, 12),
	Size = UDim2.new(0, 186, 0, 42),
	Parent = topBar,
})

local brandKicker = makeLabel(brand, "TACTICAL ESP SUITE", 9, THEME.accent, Enum.Font.GothamBold)
brandKicker.Size = UDim2.new(1, 0, 0, 12)

local brandTitle = makeLabel(brand, CONFIG.panelTitle, 21, THEME.text, Enum.Font.GothamBlack)
brandTitle.AutomaticSize = Enum.AutomaticSize.X
brandTitle.Position = UDim2.new(0, 0, 0, 9)
brandTitle.Size = UDim2.new(0, 0, 0, 20)

local brandSub = makeLabel(brand, "Adaptive overlays and combat info", 9, THEME.muted, Enum.Font.GothamMedium)
brandSub.Position = UDim2.new(0, 1, 0, 32)
brandSub.Size = UDim2.new(0, 186, 0, 12)

local infoPanel = create("Frame", {
	AnchorPoint = Vector2.new(1, 0),
	BackgroundColor3 = Color3.fromRGB(33, 37, 49),
	BorderSizePixel = 0,
	Position = UDim2.new(1, -42, 0, 12),
	Size = UDim2.new(0, 138, 0, 58),
	Parent = topBar,
})
addCorner(infoPanel, 8)
addStroke(infoPanel, THEME.border, 0.35, 1)

local infoContent = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(1, -10, 0, 48),
	Parent = infoPanel,
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

createInfoRow(infoContent, 1, "PLAYER", LOCAL_PLAYER and LOCAL_PLAYER.Name or "Player")
createInfoRow(infoContent, 25, "VERSION", CONFIG.version)

local tabBar = create("Frame", {
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 12, 0, 78),
	Size = UDim2.new(1, -24, 0, 18),
	Parent = topBar,
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
	local page = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
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
	display = createPage(),
	combat = createPage(),
}

local tabButtons = {}
local activeTab = "control"

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
	activeTab = tabName
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

local actionRow = create("Frame", {
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 0, 36),
	Parent = pages.control,
})

local applyButton = create("TextButton", {
	BackgroundColor3 = Color3.fromRGB(35, 40, 53),
	BorderSizePixel = 0,
	Font = Enum.Font.GothamMedium,
	Size = UDim2.new(0.62, -3, 1, 0),
	Text = "APPLY ESP",
	TextColor3 = THEME.text,
	TextSize = 12,
	Parent = actionRow,
})
addCorner(applyButton, 8)
addStroke(applyButton, THEME.border, 0.2, 1)

local killButton = create("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	BackgroundColor3 = Color3.fromRGB(34, 63, 101),
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Position = UDim2.new(1, 0, 0, 0),
	Size = UDim2.new(0.38, 0, 1, 0),
	Text = "KILL",
	TextColor3 = Color3.fromRGB(252, 241, 211),
	TextSize = 12,
	Parent = actionRow,
})
addCorner(killButton, 8)
addStroke(killButton, THEME.accent, 0.1, 1)

local controlHeaderRow, controlHeaderValue = createStatusRow(pages.control, "CONTROL", "ACTIVE")
controlHeaderRow.BackgroundColor3 = THEME.panelAlt
controlHeaderValue.TextColor3 = THEME.accent
local perfRow, perfStats = createPerfRow(pages.control)

local displayHeaderRow, displayHeaderValue = createStatusRow(pages.display, "DISPLAY", "ACTIVE")
displayHeaderRow.BackgroundColor3 = THEME.panelAlt
displayHeaderValue.TextColor3 = THEME.accent

local combatHeaderRow, combatHeaderValue = createStatusRow(pages.combat, "COMBAT", "ACTIVE")
combatHeaderRow.BackgroundColor3 = THEME.panelAlt
combatHeaderValue.TextColor3 = THEME.accent

local espColorStatusRow, espColorStatusValue = createStatusRow(pages.display, "ESP COLOR", "AUTO TEAM")

local enabledRow, enabledToggle = createToggleRow(pages.control, "ESP ENABLED", CONFIG.enabled)
local presetRow, presetButton = createCycleRow(pages.control, "PRESET", PRESETS[currentPresetIndex].name)
local teamCheckStatusRow, teamCheckStatusValue = createStatusRow(pages.control, "TEAM CHECK", "ALWAYS ON")
local quickHideRow, quickHideValue = createStatusRow(pages.control, "QUICK HIDE", keyCodeToText(CONFIG.quickHideKey))
local miniHudRow, miniHudToggle = createToggleRow(pages.control, "MINI HUD", CONFIG.showMiniHud)
local compactRow, compactToggle = createToggleRow(pages.control, "COMPACT MODE", CONFIG.compactMode)
local saveStatusRow, saveStatusValue = createStatusRow(pages.control, "SETTINGS", canUseFileApi() and "AUTO SAVE" or "MEMORY")

local namesRow, namesToggle = createToggleRow(pages.display, "NAME ABOVE HEAD", CONFIG.showNames)
local distanceRow, distanceToggle = createToggleRow(pages.display, "SHOW DISTANCE", CONFIG.showDistance)
local healthRow, healthToggle = createToggleRow(pages.display, "SHOW HEALTH", CONFIG.showHealth)
local weaponRow, weaponToggle = createToggleRow(pages.display, "SHOW WEAPON", CONFIG.showWeapon)
local skeletonRow, skeletonToggle = createToggleRow(pages.display, "SKELETON ESP", CONFIG.showSkeleton)
local focusTargetRow, focusTargetToggle = createToggleRow(pages.display, "FOCUS TARGET", CONFIG.showFocusTarget)
local boxModeRow, boxModeButton = createCycleRow(pages.display, "BOX MODE", CONFIG.boxMode)

local visibilityRow, visibilityToggle = createToggleRow(pages.combat, "HEAT VISION", CONFIG.visibilityCheck)
local tracersRow, tracersToggle = createToggleRow(pages.combat, "TRACERS", CONFIG.showTracers)

local maxDistanceRow = createRow(pages.combat, 30)
local maxDistanceLabel = makeLabel(maxDistanceRow, "MAX DISTANCE", 11, THEME.muted, Enum.Font.GothamMedium)
maxDistanceLabel.Position = UDim2.new(0, 10, 0, 0)
maxDistanceLabel.Size = UDim2.new(0, 110, 1, 0)

local espObjects = {}
local drawingSupported = DRAWING_SUPPORT.line
local focusedPlayer = nil

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

	return CONFIG.boxMode
end

local function isFocusedTarget(player)
	return CONFIG.showFocusTarget and focusedPlayer == player
end

local function getTracerColor(player)
	return CONFIG.visibilityCheck and CONFIG.hiddenColor or CONFIG.visibleColor
end

local function getHeldToolName(character)
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Tool") then
			return child.Name
		end
	end

	return nil
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

local function getCamera()
	return workspace.CurrentCamera
end

local function getCharacterRoot(character)
	return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
end

local function getTracerOrigin(camera)
	local localCharacter = LOCAL_PLAYER.Character
	if localCharacter then
		local localHead = localCharacter:FindFirstChild("Head")
		local localRoot = getCharacterRoot(localCharacter)
		local originPart = localHead or localRoot
		if originPart then
			local worldOrigin = originPart.Position
			if localHead then
				worldOrigin = worldOrigin + Vector3.new(0, 0.35, 0)
			end

			local screenPoint, visible = camera:WorldToViewportPoint(worldOrigin)
			if visible then
				return Vector2.new(screenPoint.X, screenPoint.Y)
			end
		end
	end

	return nil
end

local function getEspEntry(player)
	local entry = espObjects[player]
	if entry then
		return entry
	end

	entry = {}
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
	end

	if entry.tracer then
		entry.tracer.Visible = false
		entry.tracer:Remove()
		entry.tracer = nil
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
	for index, connection in ipairs(SKELETON_CONNECTIONS) do
		local fromPart = character:FindFirstChild(connection[1])
		local toPart = character:FindFirstChild(connection[2])
		local line = lines[index]

		if fromPart and toPart then
			local fromPoint = camera:WorldToViewportPoint(fromPart.Position)
			local toPoint = camera:WorldToViewportPoint(toPart.Position)
			if fromPoint.Z > 0 and toPoint.Z > 0 then
				line.Visible = true
				line.Color = color
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

local function updatePlayerEsp(player)
	local entry = getEspEntry(player)

	if not CONFIG.enabled or not isEnemyCandidate(player) then
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
	local focusTarget = isFocusedTarget(player)
	local tracerColor = focusTarget and THEME.focus or (CONFIG.visibilityCheck and displayColor or getTracerColor(player))
	local camera = getCamera()
	local effectiveBoxMode = getEffectiveBoxMode()
	local outlineColor = focusTarget and THEME.focus or (CONFIG.visibilityCheck and displayColor or espColor)

	local highlight = ensureHighlight(entry, character)
	highlight.FillColor = espColor
	highlight.FillTransparency = effectiveBoxMode == "Highlight" and CONFIG.fillTransparency or 1
	highlight.OutlineColor = outlineColor
	highlight.OutlineTransparency = effectiveBoxMode == "Highlight" and CONFIG.outlineTransparency or 1

	if camera then
		updateBoxEsp(entry, camera, character, outlineColor)
		updateSkeletonEsp(entry, camera, character, outlineColor)
	end

	if CONFIG.showNames or CONFIG.showDistance or CONFIG.showHealth then
		local _, title = ensureBillboard(entry, character)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local labelParts = {}

		if CONFIG.showNames then
			table.insert(labelParts, player.Name)
		end

		if CONFIG.showDistance then
			table.insert(labelParts, string.format("[%dm]", distance))
		end

		if CONFIG.showHealth and humanoid then
			table.insert(labelParts, string.format("[%d HP]", math.max(0, math.floor(humanoid.Health))))
		end

		if CONFIG.showWeapon then
			local heldTool = getHeldToolName(character)
			if heldTool then
				table.insert(labelParts, "[" .. heldTool .. "]")
			end
		end

		title.Text = focusTarget and ("[TARGET] " .. table.concat(labelParts, " ")) or table.concat(labelParts, " ")
		title.TextColor3 = focusTarget and THEME.focus or espColor

		if entry.healthBack and entry.healthFill and humanoid then
			local healthPercent = 0
			if humanoid.MaxHealth > 0 then
				healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
			end

			entry.healthBack.Visible = CONFIG.showHealth
			entry.healthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
			entry.healthFill.BackgroundColor3 = focusTarget and THEME.focus or espColor
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
			tracer.From = tracerOrigin
			tracer.To = Vector2.new(screenPoint.X, screenPoint.Y)
		else
			tracer.Visible = false
		end
	elseif entry.tracer then
		entry.tracer.Visible = false
	end
end

local function updatePerfStatsUi()
	if not perfStats then
		return
	end

	perfStats.fps.Text = tostring(math.max(0, math.floor(currentFps + 0.5)))
	perfStats.visible.Text = tostring(visibleEnemyCount)
	perfStats.tracked.Text = tostring(trackedEnemyCount)
	perfStats.update.Text = string.format("%.1fms", lastRefreshMs)

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
end

local function refreshAllEsp()
	local refreshStart = os.clock()
	visibleEnemyCount = 0
	trackedEnemyCount = 0
	focusedPlayer = nil
	local focusedDistance = math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LOCAL_PLAYER then
			local character = player.Character
			local root = character and getCharacterRoot(character)
			local localCharacter = LOCAL_PLAYER.Character
			local localRoot = localCharacter and getCharacterRoot(localCharacter)
			if character and root and localRoot and isEnemyCandidate(player) then
				trackedEnemyCount = trackedEnemyCount + 1
				local distance = (root.Position - localRoot.Position).Magnitude
				if distance <= CONFIG.maxDistance and isPlayerVisible(character, root) then
					visibleEnemyCount = visibleEnemyCount + 1
					if distance < focusedDistance then
						focusedDistance = distance
						focusedPlayer = player
					end
				end
			end
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LOCAL_PLAYER then
			pcall(function()
				updatePlayerEsp(player)
			end)
		end
	end

	lastRefreshMs = (os.clock() - refreshStart) * 1000
	updatePerfStatsUi()

end

local function clearAllEsp()
	for player, entry in pairs(espObjects) do
		clearEntry(entry)
		espObjects[player] = nil
	end
end

local function hookCharacter(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.2)
		refreshAllEsp()
	end)
end

local function bindToggle(button, configKey)
	button.MouseButton1Click:Connect(function()
		CONFIG[configKey] = not CONFIG[configKey]
		setToggleState(button, CONFIG[configKey])
		if configKey == "showMiniHud" then
			miniHud.Visible = CONFIG.showMiniHud and window.Visible
		end
		refreshAllEsp()
		saveSettings()
		showToast("Setting Updated", string.format("%s %s", formatSettingName(configKey), CONFIG[configKey] and "enabled" or "disabled"), CONFIG[configKey] and THEME.accent or THEME.muted)
	end)
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
	showToast("ESP", state and "ESP enabled" or "ESP disabled", state and THEME.accent or THEME.muted)
end

local function applyCompactMode(state)
	CONFIG.compactMode = state
	infoPanel.Visible = not state
	brandSub.Visible = not state
	topBar.Size = state and UDim2.new(1, 0, 0, 82) or UDim2.new(1, 0, 0, 108)
	tabBar.Position = state and UDim2.new(0, 12, 0, 50) or UDim2.new(0, 12, 0, 78)
	content.Position = state and UDim2.new(0, 0, 0, 82) or UDim2.new(0, 0, 0, 108)
	content.Size = state and UDim2.new(1, 0, 1, -82) or UDim2.new(1, 0, 1, -108)
	brand.Size = state and UDim2.new(0, 170, 0, 28) or UDim2.new(0, 186, 0, 42)
	brandTitle.TextSize = state and 19 or 21
	brandTitle.Position = state and UDim2.new(0, 0, 0, 8) or UDim2.new(0, 0, 0, 9)
	brandKicker.Visible = not state
	glow.Visible = not state
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
	minimizeButton.Text = state and "+" or "-"
end

local function playIntroAnimation()
	local cardIn = TweenService:Create(introCard, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 360, 0, 126),
		Position = UDim2.new(0.5, 0, 0.5, 0),
	})
	local glowIn = TweenService:Create(introGlow, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.94,
	})
	local kickerIn = TweenService:Create(introKicker, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
	})
	local titleIn = TweenService:Create(introTitle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
	})
	local subIn = TweenService:Create(introSub, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
	})

	cardIn:Play()
	glowIn:Play()
	cardIn.Completed:Wait()
	kickerIn:Play()
	titleIn:Play()
	subIn:Play()

	task.wait(1.2)

	local fadeInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	TweenService:Create(introOverlay, fadeInfo, {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(introCard, fadeInfo, {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 320, 0, 110),
		Position = UDim2.new(0.5, 0, 0.5, -8),
	}):Play()
	TweenService:Create(introGlow, fadeInfo, {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(introKicker, fadeInfo, {
		TextTransparency = 1,
	}):Play()
	TweenService:Create(introTitle, fadeInfo, {
		TextTransparency = 1,
	}):Play()
	TweenService:Create(introSub, fadeInfo, {
		TextTransparency = 1,
	}):Play()

	task.delay(0.45, function()
		if introOverlay then
			introOverlay:Destroy()
		end
	end)

	activeTab = "control"
	setActiveTab("control")
	window.Visible = true
	miniHud.Visible = CONFIG.showMiniHud
	syncUiFromConfig()
	applyCompactMode(CONFIG.compactMode)
	setActiveTab("control")
	setMinimized(false)
	refreshAllEsp()
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

bindToggle(enabledToggle, "enabled")
bindToggle(namesToggle, "showNames")
bindToggle(distanceToggle, "showDistance")
bindToggle(healthToggle, "showHealth")
bindToggle(weaponToggle, "showWeapon")
bindToggle(skeletonToggle, "showSkeleton")
bindToggle(focusTargetToggle, "showFocusTarget")
bindToggle(visibilityToggle, "visibilityCheck")
bindToggle(tracersToggle, "showTracers")
bindToggle(miniHudToggle, "showMiniHud")

compactToggle.MouseButton1Click:Connect(function()
	applyCompactMode(not CONFIG.compactMode)
	setToggleState(compactToggle, CONFIG.compactMode)
	setMinimized(uiMinimized)
	showToast("Setting Updated", string.format("%s %s", "Compact Mode", CONFIG.compactMode and "enabled" or "disabled"), CONFIG.compactMode and THEME.accent or THEME.muted)
end)

local function syncUiFromConfig()
	setToggleState(enabledToggle, CONFIG.enabled)
	setToggleState(namesToggle, CONFIG.showNames)
	setToggleState(distanceToggle, CONFIG.showDistance)
	setToggleState(healthToggle, CONFIG.showHealth)
	setToggleState(weaponToggle, CONFIG.showWeapon)
	setToggleState(skeletonToggle, CONFIG.showSkeleton)
	setToggleState(focusTargetToggle, CONFIG.showFocusTarget)
	setToggleState(visibilityToggle, CONFIG.visibilityCheck)
	setToggleState(tracersToggle, CONFIG.showTracers)
	setToggleState(miniHudToggle, CONFIG.showMiniHud)
	setToggleState(compactToggle, CONFIG.compactMode)
	boxModeButton.Text = getEffectiveBoxMode()
	presetButton.Text = PRESETS[currentPresetIndex].name
	saveStatusValue.Text = canUseFileApi() and "AUTO SAVE" or "MEMORY"
	miniHud.Visible = CONFIG.showMiniHud
end

presetButton.MouseButton1Click:Connect(function()
	currentPresetIndex = currentPresetIndex % #PRESETS + 1
	PRESETS[currentPresetIndex].apply()
	syncUiFromConfig()
	refreshAllEsp()
	saveSettings()
end)

boxModeButton.MouseButton1Click:Connect(function()
	local currentIndex = table.find(BOX_MODE_OPTIONS, CONFIG.boxMode) or 1
	currentIndex = currentIndex % #BOX_MODE_OPTIONS + 1
	CONFIG.boxMode = BOX_MODE_OPTIONS[currentIndex]
	boxModeButton.Text = CONFIG.boxMode
	refreshAllEsp()
	saveSettings()
end)

applyButton.MouseButton1Click:Connect(function()
	setEspEnabled(true)
end)

killButton.MouseButton1Click:Connect(function()
	setEspEnabled(false)
end)

minimizeButton.MouseButton1Click:Connect(function()
	setMinimized(not uiMinimized)
end)

Players.PlayerAdded:Connect(function(player)
	hookCharacter(player)
	refreshAllEsp()
end)

Players.PlayerRemoving:Connect(function(player)
	clearPlayerEsp(player)
	espObjects[player] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LOCAL_PLAYER then
		hookCharacter(player)
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == CONFIG.quickHideKey then
		window.Visible = not window.Visible
		miniHud.Visible = window.Visible and CONFIG.showMiniHud
		showToast("Menu", window.Visible and "Menu shown" or "Menu hidden", window.Visible and THEME.accent or THEME.muted)
	elseif input.KeyCode == CONFIG.uiToggleKey then
		gui.Enabled = not gui.Enabled
	elseif input.KeyCode == CONFIG.espToggleKey then
		setEspEnabled(not CONFIG.enabled)
	elseif input.KeyCode == CONFIG.panicKey then
		setEspEnabled(false)
		gui.Enabled = false
	end
end)

local updateAccumulator = 0
RunService.RenderStepped:Connect(function(deltaTime)
	if deltaTime > 0 then
		currentFps = (currentFps == 0) and (1 / deltaTime) or (currentFps * 0.85 + (1 / deltaTime) * 0.15)
	end
	updateAccumulator = updateAccumulator + deltaTime
	if updateAccumulator >= updateInterval then
		updateAccumulator = 0
		refreshAllEsp()
	end
end)

task.spawn(playIntroAnimation)
