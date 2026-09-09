return function(context)
    local Bridge = context.Bridge
    local Catalog = context.Catalog
    local UserInputService = context.UserInputService
    local UiParent = context.UiParent
    local TweenService = game:GetService("TweenService")
    local GuiService = game:GetService("GuiService")

    local theme = {
        window = Color3.fromRGB(8, 8, 8),
        terminal = Color3.fromRGB(2, 3, 3),
        title = Color3.fromRGB(22, 22, 22),
        titleHover = Color3.fromRGB(35, 35, 35),
        border = Color3.fromRGB(74, 74, 74),
        divider = Color3.fromRGB(39, 43, 42),
        row = Color3.fromRGB(8, 10, 10),
        rowHover = Color3.fromRGB(17, 21, 20),
        text = Color3.fromRGB(229, 232, 230),
        muted = Color3.fromRGB(132, 140, 137),
        accent = Color3.fromRGB(91, 221, 137),
        cyan = Color3.fromRGB(89, 198, 226),
        warning = Color3.fromRGB(238, 193, 84),
        error = Color3.fromRGB(238, 103, 103),
        off = Color3.fromRGB(151, 157, 155),
    }

    local FULL_SIZE = UDim2.new(0, 920, 0, 550)
    local FOLDED_SIZE = UDim2.new(0, 920, 0, 31)
    local OPEN_TIME = 0.12
    local FOLD_TIME = 0.11

    local connections = {}
    local alive = true
    local folded = true
    local animating = false
    local visible = true
    local dragging = false
    local dragStart
    local startPosition
    local currentCategory = "quick"
    local history = {}
    local historyIndex = 1
    local lineObjects = {}
    local controlObjects = {}
    local lineCount = 0
    local pendingBindFeature = nil

    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(connections, connection)
        return connection
    end

    local function create(className, props)
        local object = Instance.new(className)
        for key, value in pairs(props or {}) do object[key] = value end
        return object
    end

    local function mono(parent, text, size, color, alignment)
        return create("TextLabel", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Font = Enum.Font.Code,
            Text = text or "",
            TextColor3 = color or theme.text,
            TextSize = size or 13,
            TextWrapped = false,
            TextXAlignment = alignment or Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = parent,
        })
    end

    local existing = UiParent:FindFirstChild("VyrsConsole3")
    if existing then existing:Destroy() end

    local gui = create("ScreenGui", {
        Name = "VyrsConsole3",
        IgnoreGuiInset = false,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999999,
        Parent = UiParent,
    })

    local window = create("Frame", {
        Name = "ConsoleWindow",
        Active = true,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = theme.window,
        BorderColor3 = theme.border,
        BorderSizePixel = 1,
        ClipsDescendants = true,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = FOLDED_SIZE,
        Parent = gui,
    })

    local titleBar = create("Frame", {
        Active = true,
        BackgroundColor3 = theme.title,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = window,
    })

    local icon = mono(titleBar, ">_", 13, theme.accent)
    icon.Position = UDim2.new(0, 9, 0, 0)
    icon.Size = UDim2.new(0, 26, 1, 0)

    local title = mono(titleBar, "0xVyrs ESP Console.exe", 13, theme.text)
    title.Position = UDim2.new(0, 38, 0, 0)
    title.Size = UDim2.new(1, -140, 1, 0)

    local minimize = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0), AutoButtonColor = false,
        BackgroundColor3 = theme.title, BorderSizePixel = 0,
        Font = Enum.Font.Code, Position = UDim2.new(1, -42, 0, 0),
        Size = UDim2.new(0, 42, 1, 0), Text = "_",
        TextColor3 = theme.text, TextSize = 14, Parent = titleBar,
    })
    local close = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0), AutoButtonColor = false,
        BackgroundColor3 = theme.title, BorderSizePixel = 0,
        Font = Enum.Font.Code, Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 42, 1, 0), Text = "X",
        TextColor3 = theme.text, TextSize = 13, Parent = titleBar,
    })

    local body = create("Frame", {
        Active = true, BackgroundColor3 = theme.terminal, BorderSizePixel = 0,
        Position = UDim2.new(0, 4, 0, 34), Size = UDim2.new(1, -8, 1, -38), Parent = window,
    })
    local status = mono(body, " ENGINE: INITIALISING", 11, theme.muted)
    status.BackgroundColor3 = Color3.fromRGB(13, 14, 14)
    status.BackgroundTransparency = 0
    status.Size = UDim2.new(1, 0, 0, 24)

    local terminalPane = create("Frame", {
        Active = true, BackgroundColor3 = theme.terminal, BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 25), Size = UDim2.new(0.55, -1, 1, -25), Parent = body,
    })
    create("Frame", {
        BackgroundColor3 = theme.divider, BorderSizePixel = 0,
        Position = UDim2.new(0.55, 0, 0, 25), Size = UDim2.new(0, 1, 1, -25), Parent = body,
    })
    local controlsPane = create("Frame", {
        Active = true, BackgroundColor3 = Color3.fromRGB(5, 6, 6), BorderSizePixel = 0,
        Position = UDim2.new(0.55, 1, 0, 25), Size = UDim2.new(0.45, -1, 1, -25), Parent = body,
    })

    local output = create("ScrollingFrame", {
        Active = true, AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.terminal, BorderSizePixel = 0,
        CanvasSize = UDim2.new(), Position = UDim2.new(0, 8, 0, 6),
        ScrollBarImageColor3 = theme.border, ScrollBarThickness = 4,
        Size = UDim2.new(1, -16, 1, -52), Parent = terminalPane,
    })
    create("UIListLayout", { Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder, Parent = output })

    local inputRow = create("Frame", {
        Active = true, BackgroundColor3 = theme.terminal, BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 1, -40), Size = UDim2.new(1, -16, 0, 34), Parent = terminalPane,
    })
    local prompt = mono(inputRow, "C:\\0xVyrs>", 14, theme.accent)
    prompt.Size = UDim2.new(0, 92, 1, 0)
    local input = create("TextBox", {
        BackgroundTransparency = 1, BorderSizePixel = 0, ClearTextOnFocus = false,
        Font = Enum.Font.Code, MultiLine = false, PlaceholderText = "type 'help' for commands",
        PlaceholderColor3 = Color3.fromRGB(88, 94, 92), Position = UDim2.new(0, 96, 0, 0),
        Size = UDim2.new(1, -96, 1, 0), Text = "", TextColor3 = theme.text,
        TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = inputRow,
    })

    local controlsHeader = mono(controlsPane, " QUICK CONTROLS", 12, theme.cyan)
    controlsHeader.Position = UDim2.new(0, 8, 0, 3)
    controlsHeader.Size = UDim2.new(1, -16, 0, 20)

    local categoryBar = create("Frame", {
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0, 25), Size = UDim2.new(1, -16, 0, 50), Parent = controlsPane,
    })
    local controlsScroll = create("ScrollingFrame", {
        Active = true, AutomaticCanvasSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
        BorderSizePixel = 0, CanvasSize = UDim2.new(), Position = UDim2.new(0, 8, 0, 79),
        ScrollBarImageColor3 = theme.border, ScrollBarThickness = 4,
        Size = UDim2.new(1, -16, 1, -87), Parent = controlsPane,
    })
    create("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = controlsScroll })

    local quickKeys = {
        "enabled", "showNames", "showHealth", "showDistance", "showWeapon", "showBoxes", "boxMode",
        "showTracers", "showSkeleton", "visibilityCheck", "showTargetCard", "showCrosshair", "showFovCircle",
        "focusLock", "fly", "noclip", "infiniteJump", "walkSpeedEnabled", "performanceMode",
    }
    local numberSteps = {
        maxDistance = 100, headDotSize = 1, tracerThickness = 1, tracerTransparency = 5,
        crosshairSize = 1, crosshairThickness = 1, crosshairGap = 1, fovRadius = 5,
        fovCircleThickness = 1, fovCircleTransparency = 5, trainerHitWindow = 1,
        trainerChallengeDuration = 5, trainerTrackHoldTime = 0.25, trainerTargetSpeed = 5,
        cameraFov = 5, freeCamSpeed = 5, walkSpeed = 2, flySpeed = 5,
        fillTransparency = 0.05, outlineTransparency = 0.05,
    }

    local function scrollBottom()
        task.defer(function()
            if output.Parent then
                output.CanvasPosition = Vector2.new(0, math.max(0, output.AbsoluteCanvasSize.Y - output.AbsoluteSize.Y))
            end
        end)
    end

    local function writeLine(text, color)
        lineCount += 1
        local line = mono(output, tostring(text or ""), 13, color or theme.text)
        line.AutomaticSize = Enum.AutomaticSize.Y
        line.Size = UDim2.new(1, -8, 0, 18)
        line.TextWrapped = true
        line.TextYAlignment = Enum.TextYAlignment.Top
        line.LayoutOrder = lineCount
        table.insert(lineObjects, line)
        if #lineObjects > 180 then
            local first = table.remove(lineObjects, 1)
            if first then first:Destroy() end
        end
        scrollBottom()
        return line
    end

    local function valueToText(value)
        if typeof(value) == "Color3" then
            return string.format("#%02X%02X%02X", math.floor(value.R*255+.5), math.floor(value.G*255+.5), math.floor(value.B*255+.5))
        end
        return tostring(value)
    end

    local function normalizeKey(name)
        local raw = tostring(name or "")
        if Bridge:has(raw) then return raw end
        local lower = string.lower(raw)
        local alias = Catalog.aliases[lower]
        if alias and Bridge:has(alias) then return alias end
        for key in pairs(Bridge:all()) do if string.lower(key) == lower then return key end end
        return nil
    end

    local function splitArgs(text)
        local args, current, quote = {}, "", nil
        for i = 1, #text do
            local char = text:sub(i,i)
            if quote then
                if char == quote then quote = nil else current ..= char end
            elseif char == '"' or char == "'" then quote = char
            elseif char:match("%s") then
                if current ~= "" then table.insert(args,current) current = "" end
            else current ..= char end
        end
        if current ~= "" then table.insert(args,current) end
        return args
    end

    local function parseColor(text)
        local hex = tostring(text):match("^#?([%da-fA-F][%da-fA-F][%da-fA-F][%da-fA-F][%da-fA-F][%da-fA-F])$")
        if hex then return Color3.fromRGB(tonumber(hex:sub(1,2),16),tonumber(hex:sub(3,4),16),tonumber(hex:sub(5,6),16)) end
        local r,g,b = tostring(text):match("^(%d+),(%d+),(%d+)$")
        if r then return Color3.fromRGB(math.clamp(tonumber(r),0,255),math.clamp(tonumber(g),0,255),math.clamp(tonumber(b),0,255)) end
    end

    local function parseValue(key, raw)
        local current = Bridge:get(key)
        local kind = typeof(current)
        if kind == "boolean" then
            local v = string.lower(tostring(raw))
            if v=="on" or v=="true" or v=="1" or v=="yes" then return true end
            if v=="off" or v=="false" or v=="0" or v=="no" then return false end
            return nil,"expected on/off"
        elseif kind == "number" then
            local n = tonumber(raw); if n == nil then return nil,"expected a number" end; return n
        elseif kind == "Color3" then
            local c = parseColor(raw); if not c then return nil,"expected #RRGGBB or r,g,b" end; return c
        elseif kind == "string" then
            local choices = Catalog.choices[key]
            if choices then
                for _,choice in ipairs(choices) do if string.lower(choice)==string.lower(tostring(raw)) then return choice end end
                return nil,"choices: "..table.concat(choices,", ")
            end
            return tostring(raw)
        end
        return nil,"unsupported value type"
    end

    local function clearControls()
        for _,object in ipairs(controlObjects) do if object and object.Parent then object:Destroy() end end
        controlObjects = {}
    end
    local function track(object) table.insert(controlObjects,object) return object end

    local function addHeading(text)
        local h = track(mono(controlsScroll, "[ "..text.." ]", 11, theme.cyan))
        h.Size = UDim2.new(1,-4,0,24)
        return h
    end

    local function addActionRow(labelText, action, arg)
        local row = track(create("TextButton", {
            AutoButtonColor=false, BackgroundColor3=theme.row, BorderSizePixel=0,
            Font=Enum.Font.Code, Size=UDim2.new(1,-4,0,29), Text="  "..labelText,
            TextColor3=theme.text, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left, Parent=controlsScroll,
        }))
        connect(row.MouseEnter,function() if row.Parent then row.BackgroundColor3=theme.rowHover end end)
        connect(row.MouseLeave,function() if row.Parent then row.BackgroundColor3=theme.row end end)
        connect(row.MouseButton1Click,function()
            local ok,result = Bridge:call(action,arg)
            writeLine(ok and (labelText.." : OK") or (labelText.." : "..tostring(result)), ok and theme.accent or theme.error)
        end)
        return row
    end

    local function addControlRow(key)
        if not Bridge:has(key) then return end
        local value = Bridge:get(key)
        local kind = typeof(value)
        local row = track(create("Frame", { Active=true, BackgroundColor3=theme.row, BorderSizePixel=0, Size=UDim2.new(1,-4,0,29), Parent=controlsScroll }))
        local name = mono(row,key,11,theme.text); name.Position=UDim2.new(0,7,0,0); name.Size=UDim2.new(.54,-7,1,0)
        local valueLabel = mono(row,valueToText(value),11,theme.muted,Enum.TextXAlignment.Right)
        valueLabel.Position=UDim2.new(.54,0,0,0); valueLabel.Size=UDim2.new(.46,-8,1,0)
        local function refresh()
            if not row.Parent then return end
            local current = Bridge:get(key)
            if typeof(current)=="boolean" then
                valueLabel.Text=current and "[ ON ]" or "[ OFF ]"; valueLabel.TextColor3=current and theme.accent or theme.off
            else valueLabel.Text="< "..valueToText(current).." >"; valueLabel.TextColor3=theme.cyan end
        end
        if kind=="boolean" then
            local button=create("TextButton",{AutoButtonColor=false,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.fromScale(1,1),Text="",Parent=row})
            connect(button.MouseEnter,function() if row.Parent then row.BackgroundColor3=theme.rowHover end end)
            connect(button.MouseLeave,function() if row.Parent then row.BackgroundColor3=theme.row end end)
            connect(button.MouseButton1Click,function() local ok,err=Bridge:set(key,not Bridge:get(key)); if not ok then writeLine(tostring(err),theme.error) end; refresh() end)
        elseif kind=="string" and Catalog.choices[key] then
            local left=create("TextButton",{AutoButtonColor=false,BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(.54,0,0,0),Size=UDim2.new(.1,0,1,0),Font=Enum.Font.Code,Text="<",TextColor3=theme.cyan,TextSize=13,Parent=row})
            local right=create("TextButton",{AnchorPoint=Vector2.new(1,0),AutoButtonColor=false,BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(1,0,0,0),Size=UDim2.new(.1,0,1,0),Font=Enum.Font.Code,Text=">",TextColor3=theme.cyan,TextSize=13,Parent=row})
            valueLabel.Position=UDim2.new(.64,0,0,0); valueLabel.Size=UDim2.new(.26,0,1,0); valueLabel.TextXAlignment=Enum.TextXAlignment.Center
            local function cycle(dir)
                local choices=Catalog.choices[key]; local idx=table.find(choices,Bridge:get(key)) or 1; idx=((idx-1+dir)%#choices)+1; Bridge:set(key,choices[idx]); refresh()
            end
            connect(left.MouseButton1Click,function() cycle(-1) end); connect(right.MouseButton1Click,function() cycle(1) end)
        elseif kind=="number" then
            local left=create("TextButton",{AutoButtonColor=false,BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(.54,0,0,0),Size=UDim2.new(.1,0,1,0),Font=Enum.Font.Code,Text="-",TextColor3=theme.cyan,TextSize=13,Parent=row})
            local right=create("TextButton",{AnchorPoint=Vector2.new(1,0),AutoButtonColor=false,BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(1,0,0,0),Size=UDim2.new(.1,0,1,0),Font=Enum.Font.Code,Text="+",TextColor3=theme.cyan,TextSize=13,Parent=row})
            valueLabel.Position=UDim2.new(.64,0,0,0); valueLabel.Size=UDim2.new(.26,0,1,0); valueLabel.TextXAlignment=Enum.TextXAlignment.Center
            local step=numberSteps[key] or math.max(1,math.abs(value)*.1)
            connect(left.MouseButton1Click,function() Bridge:set(key,Bridge:get(key)-step); refresh() end)
            connect(right.MouseButton1Click,function() Bridge:set(key,Bridge:get(key)+step); refresh() end)
        end
        refresh()
    end

    local function renderSystem()
        addHeading("ACTIONS")
        addActionRow("FREECAM", "freecam")
        addActionRow("RESET VIEW", "resetview")
        addActionRow("RESPAWN", "respawn")
        addActionRow("RESET TOOLS", "tools")
        addActionRow("REJOIN", "rejoin")
        addActionRow("SERVER HOP", "serverhop")
        addActionRow("LOW POP SERVER", "emptyhop")
        addActionRow("EXPORT CONFIG", "export")
        addActionRow("IMPORT CLIPBOARD", "import")
        addActionRow("RESET DISPLAY", "resetdisplay")
        addActionRow("RESET VIEW SETTINGS", "resetviewsettings")
        addActionRow("RESET PERFORMANCE", "resetperformance")
        addActionRow("RESET POSITIONS", "resetpositions")

        addHeading("PRESETS")
        for _,preset in ipairs(Bridge:listPresets()) do
            local row=track(create("TextButton",{AutoButtonColor=false,BackgroundColor3=theme.row,BorderSizePixel=0,Font=Enum.Font.Code,Size=UDim2.new(1,-4,0,29),Text=string.format("  [%02d] %s",preset.index,preset.name),TextColor3=theme.text,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=controlsScroll}))
            connect(row.MouseButton1Click,function() local ok,err=Bridge:applyPreset(preset.index); writeLine(ok and ("preset applied: "..preset.name) or tostring(err),ok and theme.accent or theme.error) end)
        end

        addHeading("CONFIGS")
        local cfgRow=track(create("Frame",{BackgroundColor3=theme.row,BorderSizePixel=0,Size=UDim2.new(1,-4,0,31),Parent=controlsScroll}))
        local cfgInput=create("TextBox",{BackgroundColor3=theme.terminal,BorderColor3=theme.divider,BorderSizePixel=1,ClearTextOnFocus=false,Font=Enum.Font.Code,Position=UDim2.new(0,5,0,4),Size=UDim2.new(.65,-8,1,-8),PlaceholderText="config name",PlaceholderColor3=theme.muted,Text="",TextColor3=theme.text,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=cfgRow})
        local saveBtn=create("TextButton",{AutoButtonColor=false,BackgroundColor3=theme.terminal,BorderColor3=theme.divider,BorderSizePixel=1,Position=UDim2.new(.65,1,0,4),Size=UDim2.new(.35,-6,1,-8),Font=Enum.Font.Code,Text="[SAVE]",TextColor3=theme.accent,TextSize=11,Parent=cfgRow})
        connect(saveBtn.MouseButton1Click,function() local name=cfgInput.Text:match("^%s*(.-)%s*$"); if name=="" then return end; local ok,err=Bridge:saveConfig(name); writeLine(ok and ("saved config: "..name) or tostring(err),ok and theme.accent or theme.error); if ok then task.defer(function() if currentCategory=="system" then context.requestRender("system") end end) end end)
        for _,name in ipairs(Bridge:listConfigs()) do
            local row=track(create("Frame",{BackgroundColor3=theme.row,BorderSizePixel=0,Size=UDim2.new(1,-4,0,29),Parent=controlsScroll}))
            local label=mono(row,name,11,theme.text); label.Position=UDim2.new(0,7,0,0); label.Size=UDim2.new(.55,-7,1,0)
            local load=create("TextButton",{AutoButtonColor=false,BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(.56,0,0,0),Size=UDim2.new(.22,0,1,0),Font=Enum.Font.Code,Text="[LOAD]",TextColor3=theme.accent,TextSize=10,Parent=row})
            local del=create("TextButton",{AutoButtonColor=false,BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(.78,0,0,0),Size=UDim2.new(.22,0,1,0),Font=Enum.Font.Code,Text="[DEL]",TextColor3=theme.error,TextSize=10,Parent=row})
            connect(load.MouseButton1Click,function() local ok,err=Bridge:loadConfig(name); writeLine(ok and ("loaded config: "..name) or tostring(err),ok and theme.accent or theme.error) end)
            connect(del.MouseButton1Click,function() local ok,err=Bridge:deleteConfig(name); writeLine(ok and ("deleted config: "..name) or tostring(err),ok and theme.warning or theme.error); if ok then context.requestRender("system") end end)
        end

        addHeading("KEYBINDS")
        for _,bind in ipairs(Bridge:listKeybinds()) do
            local row=track(create("Frame",{BackgroundColor3=theme.row,BorderSizePixel=0,Size=UDim2.new(1,-4,0,29),Parent=controlsScroll}))
            local label=mono(row,bind.feature,10,theme.text); label.Position=UDim2.new(0,7,0,0); label.Size=UDim2.new(.52,-7,1,0)
            local keyBtn=create("TextButton",{AutoButtonColor=false,BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(.52,0,0,0),Size=UDim2.new(.26,0,1,0),Font=Enum.Font.Code,Text="["..bind.key.."]",TextColor3=theme.cyan,TextSize=10,Parent=row})
            local modeBtn=create("TextButton",{AutoButtonColor=false,BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(.78,0,0,0),Size=UDim2.new(.22,0,1,0),Font=Enum.Font.Code,Text=bind.mode,TextColor3=theme.muted,TextSize=9,Parent=row})
            connect(keyBtn.MouseButton1Click,function() pendingBindFeature=bind.feature; keyBtn.Text="[PRESS KEY]"; writeLine("press a key for "..bind.feature,theme.cyan) end)
            connect(modeBtn.MouseButton1Click,function() local nextMode=bind.mode=="Hold" and "Toggle" or "Hold"; Bridge:setKeybind(bind.feature,bind.key,nextMode); context.requestRender("system") end)
        end

        addHeading("SPECTATE")
        addActionRow("LOCAL / OFF", "spectate", "off")
        for _,player in ipairs(Bridge:listPlayers()) do addActionRow(player.displayName.."  @"..player.name,"spectate",player.name) end
    end

    local categoryButtons={}
    local categories={
        {"quick","Q"},{"visuals","VIS"},{"targeting","TGT"},{"tracers","TRC"},{"crosshair","XH"},
        {"trainer","TRN"},{"camera","CAM"},{"movement","MOV"},{"performance","PERF"},{"system","SYS"},
    }

    local function renderCategory(category)
        currentCategory=category
        clearControls()
        controlsScroll.CanvasPosition=Vector2.zero
        controlsHeader.Text=" "..string.upper(category=="quick" and "QUICK CONTROLS" or category)
        if category=="system" then renderSystem() else
            local keys=category=="quick" and quickKeys or Catalog.categories[category] or {}
            for _,key in ipairs(keys) do addControlRow(key) end
        end
        for id,button in pairs(categoryButtons) do
            button.TextColor3=id==category and theme.accent or theme.muted
            button.BackgroundColor3=id==category and theme.rowHover or theme.terminal
        end
    end
    context.requestRender=renderCategory

    for index,entry in ipairs(categories) do
        local col=(index-1)%5; local rowIndex=math.floor((index-1)/5)
        local button=create("TextButton",{AutoButtonColor=false,BackgroundColor3=theme.terminal,BorderColor3=theme.divider,BorderSizePixel=1,Position=UDim2.new(col/5,0,rowIndex*.5,0),Size=UDim2.new(.2,-2,.5,-1),Font=Enum.Font.Code,Text="["..entry[2].."]",TextColor3=theme.muted,TextSize=10,Parent=categoryBar})
        categoryButtons[entry[1]]=button
        connect(button.MouseButton1Click,function() renderCategory(entry[1]) end)
    end

    local function commandHelp()
        writeLine("Commands",theme.cyan)
        writeLine("  panel <category> | status | features [category]")
        writeLine("  get <feature> | set <feature> <value> | toggle <feature>")
        writeLine("  preset list | preset <name/index>")
        writeLine("  config list|save|load|delete <name> | config export|import")
        writeLine("  bind list | bind <feature> <key> [toggle|hold]")
        writeLine("  spectate <player|off> | freecam | rejoin | serverhop | emptyhop")
        writeLine("  respawn | tools | panic | clear | hide")
    end

    local function showFeatures(category)
        local list=Catalog.categories[string.lower(category or "")]
        if not list then writeLine("groups: visuals targeting tracers crosshair trainer camera movement interface performance",theme.cyan); return end
        for _,key in ipairs(list) do if Bridge:has(key) then writeLine(string.format("  %-27s %s",key,valueToText(Bridge:get(key)))) end end
    end

    local function runCommand(commandText)
        local trimmed=tostring(commandText or ""):match("^%s*(.-)%s*$") or ""
        if trimmed=="" then return end
        writeLine("C:\\0xVyrs> "..trimmed,theme.accent)
        local args=splitArgs(trimmed); local command=string.lower(args[1] or ""); table.remove(args,1)
        if command=="help" or command=="?" then commandHelp()
        elseif command=="clear" or command=="cls" then for _,line in ipairs(lineObjects) do if line then line:Destroy() end end; lineObjects={}; lineCount=0
        elseif command=="status" then local s=Bridge:status(); writeLine(string.format("engine=%s version=%s tracked=%s visible=%s refresh=%.2fms",s.engine,s.version,s.tracked,s.visible,s.refreshMs or 0),theme.cyan); writeLine("focus="..tostring(s.focused or "none").." freecam="..tostring(s.freecam))
        elseif command=="features" or command=="list" then showFeatures(args[1])
        elseif command=="panel" then local p=string.lower(args[1] or "quick"); if p=="perf" then p="performance" elseif p=="move" then p="movement" elseif p=="target" then p="targeting" end; if p=="quick" or p=="system" or Catalog.categories[p] then renderCategory(p) else writeLine("unknown panel",theme.error) end
        elseif command=="get" then local key=normalizeKey(args[1]); if key then writeLine(key.." = "..valueToText(Bridge:get(key)),theme.cyan) else writeLine("unknown feature",theme.error) end
        elseif command=="toggle" then local key=normalizeKey(args[1]); if key and typeof(Bridge:get(key))=="boolean" then local ok,err=Bridge:set(key,not Bridge:get(key)); writeLine(ok and (key.." = "..tostring(Bridge:get(key))) or tostring(err),ok and theme.accent or theme.error); renderCategory(currentCategory) else writeLine("unknown/non-boolean feature",theme.error) end
        elseif command=="set" then local key=normalizeKey(args[1]); if not key or not args[2] then writeLine("usage: set <feature> <value>",theme.warning) else local value,err=parseValue(key,table.concat(args," ",2)); if value==nil and err then writeLine(err,theme.warning) else local ok,e=Bridge:set(key,value); writeLine(ok and (key.." = "..valueToText(Bridge:get(key))) or tostring(e),ok and theme.accent or theme.error); renderCategory(currentCategory) end end
        elseif command=="preset" then if string.lower(args[1] or "") == "list" or not args[1] then for _,p in ipairs(Bridge:listPresets()) do writeLine(string.format("  %02d  %s",p.index,p.name)) end else local ok,err=Bridge:applyPreset(table.concat(args," ")); writeLine(ok and "preset applied" or tostring(err),ok and theme.accent or theme.error); renderCategory(currentCategory) end
        elseif command=="config" then local sub=string.lower(args[1] or "list"); table.remove(args,1); local name=table.concat(args," "); if sub=="list" then for _,n in ipairs(Bridge:listConfigs()) do writeLine("  "..n) end elseif sub=="save" then local ok,e=Bridge:saveConfig(name); writeLine(ok and "config saved" or tostring(e),ok and theme.accent or theme.error) elseif sub=="load" then local ok,e=Bridge:loadConfig(name); writeLine(ok and "config loaded" or tostring(e),ok and theme.accent or theme.error) elseif sub=="delete" or sub=="del" then local ok,e=Bridge:deleteConfig(name); writeLine(ok and "config deleted" or tostring(e),ok and theme.warning or theme.error) elseif sub=="export" or sub=="import" then local ok,e=Bridge:call(sub); writeLine(ok and ("config "..sub.." ok") or tostring(e),ok and theme.accent or theme.error) end
        elseif command=="bind" then if string.lower(args[1] or "") == "list" or not args[1] then for _,b in ipairs(Bridge:listKeybinds()) do writeLine(string.format("  %-22s %-10s %s",b.feature,b.key,b.mode)) end else local feature=args[1]; local key=args[2]; local mode=args[3]; if not key then pendingBindFeature=feature; writeLine("press a key for "..feature,theme.cyan) else local ok,e=Bridge:setKeybind(feature,key,mode); writeLine(ok and "bind updated" or tostring(e),ok and theme.accent or theme.error) end end
        elseif command=="spectate" then local ok,e=Bridge:call("spectate",table.concat(args," ")); writeLine(ok and "spectate updated" or tostring(e),ok and theme.accent or theme.error)
        elseif command=="freecam" or command=="rejoin" or command=="serverhop" or command=="emptyhop" or command=="respawn" or command=="tools" or command=="export" or command=="import" or command=="resetview" then local ok,e=Bridge:call(command,table.concat(args," ")); writeLine(ok and (command.." ok") or tostring(e),ok and theme.accent or theme.error)
        elseif command=="panic" then Bridge:panic(); renderCategory(currentCategory); writeLine("panic state applied",theme.warning)
        elseif command=="hide" or command=="exit" then return "hide"
        else local key=normalizeKey(command); if key and #args==0 and typeof(Bridge:get(key))=="boolean" then Bridge:set(key,not Bridge:get(key)); renderCategory(currentCategory); writeLine(key.." = "..tostring(Bridge:get(key)),theme.accent) else writeLine("'"..command.."' is not recognised. Type 'help'.",theme.error) end end
    end

    local function tweenWindow(size,duration,direction)
        local tween=TweenService:Create(window,TweenInfo.new(duration,Enum.EasingStyle.Quad,direction or Enum.EasingDirection.Out),{Size=size}); tween:Play(); return tween
    end
    local function unfold(capture)
        if animating then return end; animating=true; gui.Enabled=true; visible=true; body.Visible=true; minimize.Text="_"
        tweenWindow(FULL_SIZE,OPEN_TIME):Completed:Wait(); folded=false; animating=false
        if capture then task.defer(function() if gui.Enabled then input:CaptureFocus() end end) end
    end
    local function fold(hideAfter)
        if animating then return end; animating=true; input:ReleaseFocus(); tweenWindow(FOLDED_SIZE,FOLD_TIME,Enum.EasingDirection.In):Completed:Wait(); folded=true; body.Visible=false; minimize.Text="□"; animating=false
        if hideAfter then gui.Enabled=false; visible=false end
    end

    connect(minimize.MouseButton1Click,function() if folded then task.spawn(function() unfold(true) end) else task.spawn(function() fold(false) end) end end)
    connect(close.MouseButton1Click,function() task.spawn(function() fold(true) end) end)
    connect(close.MouseEnter,function() close.BackgroundColor3=Color3.fromRGB(176,43,43) end); connect(close.MouseLeave,function() close.BackgroundColor3=theme.title end)
    connect(minimize.MouseEnter,function() minimize.BackgroundColor3=theme.titleHover end); connect(minimize.MouseLeave,function() minimize.BackgroundColor3=theme.title end)

    local function insideWindow(position)
        local p,s=window.AbsolutePosition,window.AbsoluteSize
        return position.X>=p.X and position.X<=p.X+s.X and position.Y>=p.Y and position.Y<=p.Y+s.Y
    end
    local function interactiveAt(position)
        local ok,objects=pcall(function() return GuiService:GetGuiObjectsAtPosition(position.X,position.Y) end)
        if not ok then return false end
        for _,object in ipairs(objects) do
            if object:IsDescendantOf(window) and (object:IsA("TextButton") or object:IsA("TextBox")) then return true end
        end
        return false
    end

    connect(UserInputService.InputBegan,function(event,processed)
        if pendingBindFeature and event.KeyCode~=Enum.KeyCode.Unknown then
            local keyText=tostring(event.KeyCode):gsub("Enum.KeyCode.",""):upper()
            local feature=pendingBindFeature; pendingBindFeature=nil
            local ok,err=Bridge:setKeybind(feature,keyText,nil)
            writeLine(ok and (feature.." bound to "..keyText) or tostring(err),ok and theme.accent or theme.error)
            if currentCategory=="system" then renderCategory("system") end
            return
        end
        if event.KeyCode==Enum.KeyCode.RightShift then
            if gui.Enabled and not folded then task.spawn(function() fold(true) end) else gui.Enabled=true; visible=true; body.Visible=false; window.Size=FOLDED_SIZE; folded=true; task.spawn(function() unfold(true) end) end
            return
        end
        if event.UserInputType==Enum.UserInputType.MouseButton1 and gui.Enabled and insideWindow(event.Position) and not interactiveAt(event.Position) then
            dragging=true; dragStart=event.Position; startPosition=window.Position; input:ReleaseFocus(); return
        end
        if processed or not gui.Enabled or folded or not input:IsFocused() then return end
        if event.KeyCode==Enum.KeyCode.Up and #history>0 then historyIndex=math.max(1,historyIndex-1); input.Text=history[historyIndex] or ""; input.CursorPosition=#input.Text+1
        elseif event.KeyCode==Enum.KeyCode.Down and #history>0 then historyIndex=math.min(#history+1,historyIndex+1); input.Text=history[historyIndex] or ""; input.CursorPosition=#input.Text+1 end
    end)
    connect(UserInputService.InputChanged,function(event) if dragging and event.UserInputType==Enum.UserInputType.MouseMovement then local delta=event.Position-dragStart; window.Position=UDim2.new(startPosition.X.Scale,startPosition.X.Offset+delta.X,startPosition.Y.Scale,startPosition.Y.Offset+delta.Y) end end)
    connect(UserInputService.InputEnded,function(event) if event.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)

    connect(input.FocusLost,function(enterPressed)
        if not enterPressed then return end
        local text=input.Text; input.Text=""
        if text:match("%S") then table.insert(history,text); if #history>50 then table.remove(history,1) end; historyIndex=#history+1 end
        local result=runCommand(text)
        if result=="hide" then task.spawn(function() fold(true) end) elseif gui.Enabled and not folded then task.defer(function() input:CaptureFocus() end) end
    end)

    renderCategory("quick")
    task.spawn(function()
        while alive and gui.Parent do
            local s=Bridge:status()
            status.Text=string.format(" ENGINE: %s   VERSION: %s   TRACKED: %s   VISIBLE: %s   REFRESH: %.2fms",string.upper(s.engine or "unknown"),s.version or "?",tostring(s.tracked or 0),tostring(s.visible or 0),tonumber(s.refreshMs) or 0)
            task.wait(.5)
        end
    end)

    task.spawn(function()
        unfold(false)
        local boot={
            {"0xVyrs Runtime [3.2]",theme.text},
            {"[ OK ] engine pack loaded",theme.accent},
            {"[ OK ] terminal controls ready",theme.accent},
            {"Type 'help' for commands or use the controls on the right.",theme.cyan},
            {"",theme.text},
        }
        for _,item in ipairs(boot) do if not alive then return end; writeLine(item[1],item[2]); task.wait(.012) end
        task.defer(function() if gui.Enabled and not folded then input:CaptureFocus() end end)
    end)

    return {
        gui=gui, write=writeLine, run=runCommand, renderCategory=renderCategory,
        destroy=function()
            alive=false
            for _,connection in ipairs(connections) do pcall(function() connection:Disconnect() end) end
            connections={}
            if gui then gui:Destroy() end
        end,
        isVisible=function() return visible end,
    }
end
