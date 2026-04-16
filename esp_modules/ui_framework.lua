return function(context)
	local create = context.create
	local addCorner = context.addCorner
	local addStroke = context.addStroke
	local makeLabel = context.makeLabel
	local TweenService = context.TweenService
	local theme = context.theme
	local tabBar = context.tabBar
	local pagesContainer = context.pagesContainer
	local colorOptions = context.colorOptions or {}

	local function createPage()
		local page = create("ScrollingFrame", {
			Active = true,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarImageColor3 = theme.accent,
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
			BackgroundColor3 = theme.panel,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, height or 28),
			Parent = parent,
		})
		addCorner(row, 8)
		addStroke(row, theme.border, 0.45, 1)
		return row
	end

	local function createStatusRow(parent, labelText, valueText)
		local row = createRow(parent, 24)
		local label = makeLabel(row, labelText, 11, theme.muted, Enum.Font.GothamMedium)
		label.Position = UDim2.new(0, 10, 0, 0)
		label.Size = UDim2.new(0, 120, 1, 0)

		local value = makeLabel(row, valueText, 11, theme.text, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
		value.AnchorPoint = Vector2.new(1, 0)
		value.Position = UDim2.new(1, -10, 0, 0)
		value.Size = UDim2.new(0, 132, 1, 0)
		return row, value
	end

	local function createNoteRow(parent, text)
		local row = createRow(parent, 26)
		row.BackgroundColor3 = theme.panelAlt
		local label = makeLabel(row, text, 9, theme.muted, Enum.Font.GothamMedium)
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
				BackgroundColor3 = theme.panelAlt,
				BorderSizePixel = 0,
				Parent = statHolder,
			})
			addCorner(cell, 6)

			local title = makeLabel(cell, item.title, 8, theme.muted, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
			title.Position = UDim2.new(0, 0, 0, 2)
			title.Size = UDim2.new(1, 0, 0, 10)

			local value = makeLabel(cell, "--", 10, theme.text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
			value.Position = UDim2.new(0, 0, 0, 12)
			value.Size = UDim2.new(1, 0, 1, -12)

			stats[item.key] = value
		end

		return row, stats
	end

	local function createCycleRow(parent, labelText, valueText)
		local row = createRow(parent, 30)
		local label = makeLabel(row, labelText, 10, theme.muted, Enum.Font.GothamMedium)
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
			TextColor3 = theme.text,
			TextSize = 10,
			Parent = row,
		})
		addCorner(valueButton, 4)
		addStroke(valueButton, theme.border, 0.25, 1)
		return row, valueButton
	end

	local function createToggleRow(parent, labelText, defaultState)
		local row = createRow(parent, 30)
		local label = makeLabel(row, labelText, 10, theme.muted, Enum.Font.GothamMedium)
		label.Position = UDim2.new(0, 10, 0, 0)
		label.Size = UDim2.new(0, 186, 1, 0)

		local button = create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			AutoButtonColor = false,
			BackgroundColor3 = defaultState and theme.accentSoft or Color3.fromRGB(35, 40, 53),
			BorderSizePixel = 0,
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.new(0, 46, 0, 20),
			Font = Enum.Font.GothamBold,
			Text = defaultState and "ON" or "OFF",
			TextColor3 = defaultState and Color3.fromRGB(228, 241, 255) or theme.muted,
			TextSize = 9,
			Parent = row,
		})
		addCorner(button, 999)
		addStroke(button, theme.accent, defaultState and 0.15 or 0.65, 1)
		return row, button
	end

	local function createKeybindRow(parent, labelText, valueText)
		local row = createRow(parent, 30)
		local label = makeLabel(row, labelText, 10, theme.muted, Enum.Font.GothamMedium)
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
			TextColor3 = theme.text,
			TextSize = 9,
			Parent = row,
		})
		addCorner(button, 999)
		addStroke(button, theme.accent, 0.55, 1)
		return row, button
	end

	local function createOptionButtonsRow(parent, labelText, options, selectedValue, formatter)
		local row = createRow(parent, 52)

		local label = makeLabel(row, labelText, 10, theme.muted, Enum.Font.GothamMedium)
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
			local textColor = option == selectedValue and theme.text or theme.muted
			local button = create("TextButton", {
				AutoButtonColor = false,
				BackgroundColor3 = option == selectedValue and theme.accentSoft or Color3.fromRGB(35, 40, 53),
				BorderSizePixel = 0,
				Size = UDim2.new(0, math.max(32, 18 + (#text * 6)), 1, 0),
				Font = Enum.Font.GothamBold,
				Text = text,
				TextColor3 = textColor,
				TextSize = 9,
				Parent = holder,
			})
			addCorner(button, 999)
			addStroke(button, theme.accent, option == selectedValue and 0.15 or 0.65, 1)
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
			local backgroundColor = selected and theme.accentSoft or Color3.fromRGB(35, 40, 53)
			local textColor = selected and theme.text or theme.muted
			local strokeTransparency = selected and 0.15 or 0.65

			if entry.button:GetAttribute("TrainerPresetButton") then
				local presetColor = entry.button:GetAttribute("PresetColor")
				if typeof(presetColor) == "Color3" then
					backgroundColor = selected and presetColor:Lerp(Color3.fromRGB(255, 255, 255), 0.22) or presetColor:Lerp(Color3.fromRGB(20, 24, 33), 0.7)
					textColor = selected and theme.text or presetColor
					strokeTransparency = selected and 0.08 or 0.45
				end
			end

			entry.button.BackgroundColor3 = backgroundColor
			entry.button.TextColor3 = textColor

			if type(entry.value) == "string" then
				for _, colorOption in ipairs(colorOptions) do
					if colorOption.name == entry.value then
						entry.button.TextColor3 = selected and theme.text or colorOption.color
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

		local label = makeLabel(row, labelText, 10, theme.muted, Enum.Font.GothamMedium)
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
			TextColor3 = theme.text,
			TextSize = 10,
			Parent = row,
		})
		addCorner(valueLabel, 4)
		addStroke(valueLabel, theme.border, 0.35, 1)

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
		addStroke(bar, theme.border, 0.35, 1)

		local fill = create("Frame", {
			BackgroundColor3 = theme.accent,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 1, 0),
			Parent = bar,
		})
		addCorner(fill, 999)

		local knob = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = theme.text,
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

		local label = makeLabel(row, "SPECTATE", 10, theme.muted, Enum.Font.GothamMedium)
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
			TextColor3 = theme.text,
			TextSize = 9,
			ZIndex = 14,
			Parent = row,
		})
		addCorner(offButton, 4)
		addStroke(offButton, theme.border, 0.35, 1)

		local mainButton = create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			AutoButtonColor = false,
			BackgroundColor3 = Color3.fromRGB(35, 40, 53),
			BorderSizePixel = 0,
			Position = UDim2.new(1, -58, 0.5, 0),
			Size = UDim2.new(0, 120, 0, 20),
			Font = Enum.Font.GothamBold,
			Text = "SELECT",
			TextColor3 = theme.text,
			TextSize = 9,
			ZIndex = 14,
			Parent = row,
		})
		addCorner(mainButton, 4)
		addStroke(mainButton, theme.border, 0.25, 1)

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
		addStroke(list, theme.border, 0.2, 1)

		local searchBox = create("TextBox", {
			BackgroundColor3 = Color3.fromRGB(35, 40, 53),
			BorderSizePixel = 0,
			ClearTextOnFocus = false,
			Font = Enum.Font.GothamMedium,
			PlaceholderColor3 = theme.muted,
			PlaceholderText = "Search player",
			Position = UDim2.new(0, 6, 0, 6),
			Size = UDim2.new(1, -12, 0, 22),
			Text = "",
			TextColor3 = theme.text,
			TextSize = 10,
			ZIndex = 21,
			Parent = list,
		})
		addCorner(searchBox, 4)
		addStroke(searchBox, theme.border, 0.35, 1)

		local scroller = create("ScrollingFrame", {
			Active = true,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0, 6, 0, 34),
			ScrollBarImageColor3 = theme.accent,
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
			TextColor3 = theme.muted,
			TextSize = 10,
			Parent = tabBar,
		})
		addCorner(button, 999)
		addStroke(button, theme.border, 0.5, 1)
		tabButtons[tabName] = button
		return button
	end

	local function setActiveTab(tabName)
		for name, page in pairs(pages) do
			page.Visible = name == tabName
		end

		for name, button in pairs(tabButtons) do
			local selected = name == tabName
			button.BackgroundColor3 = selected and theme.accentSoft or Color3.fromRGB(35, 40, 53)
			button.TextColor3 = selected and theme.text or theme.muted
			local stroke = button:FindFirstChildOfClass("UIStroke")
			if stroke then
				stroke.Transparency = selected and 0.15 or 0.5
			end
		end
	end

	local function setToggleState(button, state)
		button.Text = state and "ON" or "OFF"
		button.TextColor3 = state and Color3.fromRGB(228, 241, 255) or theme.muted
		button.BackgroundColor3 = state and theme.accentSoft or Color3.fromRGB(35, 40, 53)

		local stroke = button:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Transparency = state and 0.15 or 0.55
		end
	end

	return {
		pages = pages,
		tabButtons = tabButtons,
		createNoteRow = createNoteRow,
		createOptionButtonsRow = createOptionButtonsRow,
		createPerfRow = createPerfRow,
		createRow = createRow,
		createSliderRow = createSliderRow,
		createSpectateRow = createSpectateRow,
		createStatusRow = createStatusRow,
		createTabButton = createTabButton,
		createToggleRow = createToggleRow,
		createKeybindRow = createKeybindRow,
		createCycleRow = createCycleRow,
		setActiveTab = setActiveTab,
		setOptionButtonsState = setOptionButtonsState,
		setSliderState = setSliderState,
		setToggleState = setToggleState,
		applySliderVisual = applySliderVisual,
		bindSliderValueInput = bindSliderValueInput,
	}
end
