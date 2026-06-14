--[[
	Drawing and player ESP rendering helpers for 0xVyrs.
	Kept out of esp.lua to avoid Lua's 200-local-register chunk limit.
]]

return function(context)
	local CONFIG = context.CONFIG
	local LOCAL_PLAYER = context.LOCAL_PLAYER
	local THEME = context.THEME
	local DEV_TAG_TEXT = context.DEV_TAG_TEXT
	local DRAWING_SUPPORT = context.DRAWING_SUPPORT
	local SKELETON_CONNECTIONS = context.SKELETON_CONNECTIONS
	local BOX_3D_EDGES = context.BOX_3D_EDGES
	local drawingSupported = context.drawingSupported
	local espObjects = context.espObjects
	local create = context.create
	local addCorner = context.addCorner
	local createDrawing = context.createDrawing
	local removeDrawingObject = context.removeDrawingObject
	local getCharacterRoot = context.getCharacterRoot
	local getEffectiveBoxMode = context.getEffectiveBoxMode
	local isChamsBoxMode = context.isChamsBoxMode
	local isFocusedTarget = context.isFocusedTarget
	local getCamera = context.getCamera
	local getHeldToolName = context.getHeldToolName
	local getTracerOrigin = context.getTracerOrigin
	local getMouseScreenPosition = context.getMouseScreenPosition
	local updateMouseIconVisibility = context.updateMouseIconVisibility
	local CROSSHAIR_COLOR_OPTIONS = context.CROSSHAIR_COLOR_OPTIONS
	local gui = context.gui
	local window = context.window
	local UserInputService = context.UserInputService
	local viewState = context.viewState

	local crosshairObjects = {}
	local fovCircleObject
	local defaultMouseIcon
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

local clearEntry = function(entry)
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
		removeDrawingObject(entry.tracer)
		entry.tracer = nil
	end

	if entry.tracerBranch then
		entry.tracerBranch.Visible = false
		removeDrawingObject(entry.tracerBranch)
		entry.tracerBranch = nil
	end

	if entry.headDot then
		entry.headDot.Visible = false
		removeDrawingObject(entry.headDot)
		entry.headDot = nil
	end

	if entry.box then
		entry.box.Visible = false
		removeDrawingObject(entry.box)
		entry.box = nil
	end

	if entry.cornerLines then
		for _, line in ipairs(entry.cornerLines) do
			line.Visible = false
			removeDrawingObject(line)
		end
		entry.cornerLines = nil
	end

	if entry.healthBoxLines then
		for _, line in ipairs(entry.healthBoxLines) do
			line.Visible = false
			removeDrawingObject(line)
		end
		entry.healthBoxLines = nil
	end

	if entry.box3DLines then
		for _, line in ipairs(entry.box3DLines) do
			line.Visible = false
			removeDrawingObject(line)
		end
		entry.box3DLines = nil
	end

	if entry.box3DCornerLines then
		for _, line in ipairs(entry.box3DCornerLines) do
			line.Visible = false
			removeDrawingObject(line)
		end
		entry.box3DCornerLines = nil
	end

	if entry.skeletonLines then
		for _, line in ipairs(entry.skeletonLines) do
			line.Visible = false
			removeDrawingObject(line)
		end
		entry.skeletonLines = nil
	end

	if entry.lookArrowLines then
		for _, line in ipairs(entry.lookArrowLines) do
			line.Visible = false
			removeDrawingObject(line)
		end
		entry.lookArrowLines = nil
	end

end

local clearPlayerEsp = function(player)
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

local function ensureHealthLines(entry)
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
				removeDrawingObject(line)
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
				removeDrawingObject(line)
			end
			entry.cornerLines = nil
			return nil
		end
	end

	return entry.cornerLines
end

local function ensureBoxLines(entry, key, count)
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
				removeDrawingObject(line)
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
				removeDrawingObject(line)
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
				removeDrawingObject(line)
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
					removeDrawingObject(object)
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
			removeDrawingObject(object)
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

updateMouseIconVisibility = function()
	local customCrosshairActive = gui.Enabled and CONFIG.showCrosshair
	local shouldShowMouseIcon = window.Visible or not customCrosshairActive
	if UserInputService.MouseIconEnabled ~= shouldShowMouseIcon then
		UserInputService.MouseIconEnabled = shouldShowMouseIcon
	end

	local mouse = LOCAL_PLAYER and LOCAL_PLAYER:GetMouse()
	if mouse then
		if defaultMouseIcon == nil then
			defaultMouseIcon = mouse.Icon or ""
		end
		mouse.Icon = shouldShowMouseIcon and defaultMouseIcon or ""
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

local function getPartScreenBounds(camera, part)
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

local function getBoundingBoxViewportCorners(camera, character)
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

local function render3DBoxEdges(lines, corners, color, thickness)
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

local function render3DCornerEdges(lines, corners, color, thickness)
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

local function updateBillboardEsp(entry, player, character, distance, focusTarget, showDevTag, devRainbowColor, espColor, distanceFade)
	if not (CONFIG.showNames or CONFIG.showDistance or CONFIG.showHealth or showDevTag) then
		if entry.billboard then
			entry.billboard:Destroy()
			entry.billboard = nil
			entry.title = nil
			entry.healthBack = nil
			entry.healthFill = nil
			entry.devRing = nil
		end
		return
	end

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
end

local function updateTracerEsp(entry, root, camera, tracerColor, focusTarget, distance, distanceFade)
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
end

local function updateHeadDotEsp(entry, character, camera, distanceFade, outlineColor, showDevTag, devRainbowColor)
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


	return {
		getEspEntry = getEspEntry,
		clearEntry = clearEntry,
		clearPlayerEsp = clearPlayerEsp,
		resetAllBoxEspVisuals = resetAllBoxEspVisuals,
		ensureHighlight = ensureHighlight,
		updateBoxEsp = updateBoxEsp,
		updateSkeletonEsp = updateSkeletonEsp,
		updateLookDirectionEsp = updateLookDirectionEsp,
		isPlayerVisible = isPlayerVisible,
		getDisplayColor = getDisplayColor,
		getDistanceFade = getDistanceFade,
		getRainbowColor = getRainbowColor,
		updateBillboardEsp = updateBillboardEsp,
		updateTracerEsp = updateTracerEsp,
		updateHeadDotEsp = updateHeadDotEsp,
		updateCrosshair = updateCrosshair,
		hideCrosshair = hideCrosshair,
		updateMouseIconVisibility = updateMouseIconVisibility,
	}
end
