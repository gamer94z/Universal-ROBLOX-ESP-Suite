return function(context)
	local env = (type(getgenv) == "function" and getgenv())
		or (type(getfenv) == "function" and getfenv(0))
		or _G

	local previousConnections = env.__VYRS_ESP_OVERLAY_CONNECTIONS
	if type(previousConnections) == "table" then
		for _, connection in ipairs(previousConnections) do
			if connection and type(connection.Disconnect) == "function" then
				pcall(function()
					connection:Disconnect()
				end)
			end
		end
	end

	local connections = {}
	env.__VYRS_ESP_OVERLAY_CONNECTIONS = connections

	local function connect(signal, callback)
		local connection = signal:Connect(callback)
		table.insert(connections, connection)
		return connection
	end

	local releaseTrack = {
		latestVersion = "1.7-dev.0",
		title = "Interface rebuild",
		notes = {
			"New dashboard shell and sidebar navigation.",
			"Fast boot animation with no per-frame intro effects.",
			"Cleaner controls, sliders and status surfaces.",
			"Runtime UI work and player tracking reduced.",
		},
	}

	local surface = Color3.fromRGB(18, 21, 28)
	local surfaceRaised = Color3.fromRGB(23, 27, 36)
	local control = Color3.fromRGB(31, 36, 47)

	local function getViewportSize()
		local camera = workspace.CurrentCamera
		return camera and camera.ViewportSize or Vector2.new(1920, 1080)
	end

	local function getOverlayConfigKeys(overlayId)
		if overlayId == "miniHud" then
			return "miniHudOffsetX", "miniHudOffsetY"
		elseif overlayId == "keybindPanel" then
			return "keybindPanelOffsetX", "keybindPanelOffsetY"
		elseif overlayId == "targetCard" then
			return "targetCardOffsetX", "targetCardOffsetY"
		end
		return nil, nil
	end

	local function getDefaultOverlayPosition(frame, overlayId)
		local viewport = getViewportSize()
		if overlayId == "miniHud" then
			return viewport.X - frame.AbsoluteSize.X - 16, 16
		elseif overlayId == "keybindPanel" then
			return 16, 98
		elseif overlayId == "targetCard" then
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

	local function bindOverlayDrag(frame, overlayId, handle)
		local dragging = false
		local dragStart
		local startPosition

		handle.Active = true
		connect(handle.InputBegan, function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			dragging = true
			dragStart = input.Position
			startPosition = frame.AbsolutePosition

			connect(input.Changed, function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end)

		connect(context.userInputService.InputChanged, function(input)
			if not dragging or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch) then
				return
			end

			local delta = input.Position - dragStart
			setOverlayPosition(frame, overlayId, startPosition.X + delta.X, startPosition.Y + delta.Y, false)
		end)
	end

	local function makeOverlayDraggable(frame, overlayId, dragHandle)
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
		frame.Draggable = false
		local handle = dragHandle
		if not handle then
			handle = context.create("TextButton", {
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 0, math.min(42, math.max(24, frame.AbsoluteSize.Y))),
				Text = "",
				ZIndex = (frame.ZIndex or 1) + 10,
				Parent = frame,
			})
		end

		bindOverlayDrag(frame, overlayId, handle)
		connect(frame:GetPropertyChangedSignal("Position"), function()
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
		local row = context.createRow(parent, 150)
		row.BackgroundColor3 = surfaceRaised

		local kicker = context.makeLabel(row, "BUILD", 8, context.theme.accent, Enum.Font.GothamBold)
		kicker.Position = UDim2.new(0, 12, 0, 10)
		kicker.Size = UDim2.new(0, 50, 0, 10)

		local headline = context.makeLabel(row, releaseTrack.title, 14, context.theme.text, Enum.Font.GothamBold)
		headline.Position = UDim2.new(0, 12, 0, 23)
		headline.Size = UDim2.new(1, -126, 0, 18)

		local statusBadge = context.create("TextLabel", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = context.theme.accentSoft,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -12, 0, 12),
			Size = UDim2.new(0, 94, 0, 24),
			Font = Enum.Font.GothamBold,
			Text = "DEV BUILD",
			TextColor3 = context.theme.text,
			TextSize = 8,
			Parent = row,
		})
		context.addCorner(statusBadge, 7)
		context.addStroke(statusBadge, context.theme.accent, 0.4, 1)

		local versionLine = context.makeLabel(row, "", 9, context.theme.muted, Enum.Font.GothamMedium)
		versionLine.Position = UDim2.new(0, 12, 0, 45)
		versionLine.Size = UDim2.new(1, -24, 0, 14)

		local notesHolder = context.create("Frame", {
			BackgroundColor3 = surface,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 12, 0, 64),
			Size = UDim2.new(1, -24, 0, 74),
			Parent = row,
		})
		context.addCorner(notesHolder, 8)

		local notes = {}
		for index, noteText in ipairs(releaseTrack.notes) do
			local note = context.makeLabel(notesHolder, "• " .. noteText, 8, context.theme.muted, Enum.Font.GothamMedium)
			note.Position = UDim2.new(0, 10, 0, 5 + ((index - 1) * 16))
			note.Size = UDim2.new(1, -20, 0, 14)
			notes[index] = note
		end

		return {
			row = row,
			status = statusBadge,
			current = versionLine,
			latest = versionLine,
			headline = headline,
			notes = notes,
		}
	end

	local function updateReleasePanel(panel)
		if not panel or not panel.status then
			return
		end

		local comparison = compareSemanticVersions(context.config.version, releaseTrack.latestVersion)
		local upToDate = comparison >= 0
		panel.current.Text = string.format("Current %s  •  development channel", tostring(context.config.version))
		panel.headline.Text = releaseTrack.title
		panel.status.Text = upToDate and "CURRENT" or "OUTDATED"
		panel.status.BackgroundColor3 = upToDate and context.theme.accentSoft or Color3.fromRGB(92, 76, 28)
	end

	local function bindUpdatePanel(panel)
		updateReleasePanel(panel)
	end

	return {
		buildUpdatePanel = buildUpdatePanel,
		bindUpdatePanel = bindUpdatePanel,
		makeOverlayDraggable = makeOverlayDraggable,
		resetOverlayPosition = resetOverlayPosition,
		updateReleasePanel = updateReleasePanel,
	}
end
