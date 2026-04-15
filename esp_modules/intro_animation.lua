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
