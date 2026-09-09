return function(context)
    local runtime = assert(context.Runtime, "missing runtime")
    local EntityFactory = assert(context.EntityFactory, "missing entity factory")
    local Bridge = assert(runtime.bridge, "missing bridge")
    local Terminal = assert(runtime.terminal, "missing terminal")
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
    local shared = (type(getgenv) == "function" and getgenv()) or _G

    local alive = true
    local connections = {}
    local selectedPlayerName = nil
    local profileWriteToken = 0
    local emaFps = 60
    local adaptiveProfile = "quality"
    local entityController = nil
    local extensionUi = nil

    local raw = {
        has = Bridge.has,
        get = Bridge.get,
        all = Bridge.all,
        set = Bridge.set,
        call = Bridge.call,
        cleanup = Bridge.cleanup,
        panic = Bridge.panic,
        listPresets = Bridge.listPresets,
        applyPreset = Bridge.applyPreset,
    }

    local virtual = {
        adaptiveRenderer = true,
        autoGameProfiles = true,
        entityEsp = true,
        entityAutoScan = true,
        entityNames = true,
        entityHealth = true,
        entityDistance = true,
        entityMaxDistance = 1500,
    }

    local virtualKeys = {}
    for key in pairs(virtual) do virtualKeys[key] = true end

    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(connections, connection)
        return connection
    end

    local function write(text, color)
        if Terminal and type(Terminal.write) == "function" then
            pcall(Terminal.write, tostring(text or ""), color)
        end
    end

    local function getLocalRoot()
        local character = LocalPlayer and LocalPlayer.Character
        if not character then return nil end
        return character:FindFirstChild("HumanoidRootPart")
            or character:FindFirstChild("UpperTorso")
            or character:FindFirstChild("Torso")
    end

    local function findPlayer(name)
        local wanted = string.lower(tostring(name or ""))
        if wanted == "" then return nil end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and (string.lower(player.Name) == wanted or string.lower(player.DisplayName) == wanted) then
                return player
            end
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local username = string.lower(player.Name)
                local display = string.lower(player.DisplayName)
                if string.find(username, wanted, 1, true) == 1 or string.find(display, wanted, 1, true) == 1 then
                    return player
                end
            end
        end
        return nil
    end

    local function heldTool(character)
        if not character then return "None" end
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Tool") then return child.Name end
        end
        return "None"
    end

    local function visibleToLocal(character, root)
        local originRoot = getLocalRoot()
        if not originRoot or not character or not root then return false end
        local direction = root.Position - originRoot.Position
        if direction.Magnitude <= 0.01 then return true end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Blacklist
        params.FilterDescendantsInstances = { LocalPlayer.Character, character }
        params.IgnoreWater = true
        local result = Workspace:Raycast(originRoot.Position, direction, params)
        return result == nil
    end

    local function movementState(root, humanoid)
        if not root then return "Unknown" end
        local velocity = root.AssemblyLinearVelocity
        if humanoid and humanoid.FloorMaterial == Enum.Material.Air then
            return velocity.Y > 1 and "Jumping" or "Falling"
        end
        local speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
        if speed > 18 then return "Sprinting" end
        if speed > 2 then return "Moving" end
        return "Idle"
    end

    function Bridge:inspectPlayer(name)
        local player = findPlayer(name)
        if not player then return nil, "player not found" end
        local character = player.Character
        local root = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"))
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local localRoot = getLocalRoot()
        local distance = root and localRoot and (root.Position - localRoot.Position).Magnitude or math.huge
        local team = player.Team and player.Team.Name or (player.Neutral and "Neutral" or tostring(player.TeamColor))
        return {
            name = player.Name,
            displayName = player.DisplayName,
            distance = distance,
            health = humanoid and humanoid.Health or 0,
            maxHealth = humanoid and humanoid.MaxHealth or 0,
            visible = visibleToLocal(character, root),
            tool = heldTool(character),
            movement = movementState(root, humanoid),
            team = team,
        }
    end

    local function dependencyState(key)
        if key == "performanceMode" then
            local children = { "simplifyMaterials", "hideTextures", "hideEffects", "disableShadows" }
            local on = 0
            for _, child in ipairs(children) do if raw.get(Bridge, child) == true then on = on + 1 end end
            if raw.get(Bridge, "performanceMode") == true and on == #children then return "FULL" end
            if on > 0 then return "CUSTOM" end
            return "OFF"
        end
        if key == "esp" or key == "enabled" then
            return raw.get(Bridge, "enabled") and "ON" or "OFF"
        end
        return nil
    end
    Bridge.dependencyState = dependencyState

    function Bridge:has(key)
        if virtualKeys[key] then return true end
        return raw.has(self, key)
    end

    function Bridge:get(key)
        if virtualKeys[key] then return virtual[key] end
        return raw.get(self, key)
    end

    function Bridge:all()
        local result = {}
        local original = raw.all(self)
        for key, value in pairs(original) do result[key] = value end
        for key, value in pairs(virtual) do result[key] = value end
        return result
    end

    local PROFILE_FILE = "VyrsESP_game_profiles.json"

    local function canUseFileApi()
        return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
    end

    local function encodeValue(value)
        local kind = typeof(value)
        if kind == "boolean" or kind == "number" or kind == "string" then return value end
        if kind == "Color3" then return { __type = "Color3", r = value.R, g = value.G, b = value.B } end
        return nil
    end

    local function decodeValue(value)
        if type(value) == "table" and value.__type == "Color3" then
            return Color3.new(tonumber(value.r) or 0, tonumber(value.g) or 0, tonumber(value.b) or 0)
        end
        return value
    end

    local function loadProfileStore()
        if not canUseFileApi() or not isfile(PROFILE_FILE) then return { places = {} } end
        local ok, decoded = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(PROFILE_FILE)) end)
        if ok and type(decoded) == "table" then
            decoded.places = type(decoded.places) == "table" and decoded.places or {}
            return decoded
        end
        return { places = {} }
    end

    local function saveProfileStore(store)
        if not canUseFileApi() then return false end
        return pcall(function() writefile(PROFILE_FILE, game:GetService("HttpService"):JSONEncode(store)) end)
    end

    local function snapshotConfig()
        local settings = {}
        local original = raw.all(Bridge)
        for key, value in pairs(original) do
            local encoded = encodeValue(value)
            if encoded ~= nil then settings[key] = encoded end
        end
        local virtualCopy = {}
        for key, value in pairs(virtual) do virtualCopy[key] = value end
        return { settings = settings, virtual = virtualCopy, savedAt = os.time() }
    end

    local function saveGameProfileNow()
        if not virtual.autoGameProfiles or not canUseFileApi() then return false end
        local store = loadProfileStore()
        store.places[tostring(game.PlaceId)] = snapshotConfig()
        return saveProfileStore(store)
    end

    local function scheduleGameProfileSave()
        if not virtual.autoGameProfiles or not canUseFileApi() then return end
        profileWriteToken = profileWriteToken + 1
        local token = profileWriteToken
        task.delay(0.45, function()
            if alive and token == profileWriteToken then saveGameProfileNow() end
        end)
    end

    local function loadGameProfileNow()
        if not virtual.autoGameProfiles or not canUseFileApi() then return false, "profile storage unavailable" end
        local store = loadProfileStore()
        local profile = store.places[tostring(game.PlaceId)]
        if type(profile) ~= "table" then return false, "no profile saved for this game" end

        if type(profile.virtual) == "table" then
            for key, value in pairs(profile.virtual) do
                if virtualKeys[key] and typeof(value) == typeof(virtual[key]) then virtual[key] = value end
            end
        end
        if type(profile.settings) == "table" then
            for key, encoded in pairs(profile.settings) do
                if raw.has(Bridge, key) then
                    local value = decodeValue(encoded)
                    local current = raw.get(Bridge, key)
                    if typeof(value) == typeof(current) then pcall(raw.set, Bridge, key, value) end
                end
            end
        end
        return true
    end

    local function applyDependencyRules(key, value)
        if key == "focusLock" and value == true then
            if raw.has(Bridge, "enabled") then pcall(raw.set, Bridge, "enabled", true) end
            if raw.has(Bridge, "showFocusTarget") then pcall(raw.set, Bridge, "showFocusTarget", true) end
        elseif key == "aimTrainerMode" and value == true then
            if raw.has(Bridge, "showCrosshair") then pcall(raw.set, Bridge, "showCrosshair", true) end
        elseif key == "showFovCircle" and value == true then
            if raw.has(Bridge, "showCrosshair") then pcall(raw.set, Bridge, "showCrosshair", true) end
        elseif key == "fly" and value == true then
            local camera = Workspace.CurrentCamera
            if camera and camera.CameraType == Enum.CameraType.Scriptable then pcall(raw.call, Bridge, "freecam") end
        end
    end

    function Bridge:set(key, value)
        if virtualKeys[key] then
            if typeof(value) ~= typeof(virtual[key]) then return false, "expected " .. typeof(virtual[key]) end
            if key == "entityMaxDistance" then value = math.clamp(value, 100, 10000) end
            virtual[key] = value
            if key == "adaptiveRenderer" and value == false then shared.__VYRS_ADAPTIVE_PROFILE = nil end
            if key == "entityAutoScan" and value == true and entityController then pcall(function() entityController:rescan() end) end
            scheduleGameProfileSave()
            return true
        end

        applyDependencyRules(key, value)
        local ok, err = raw.set(self, key, value)
        if ok then scheduleGameProfileSave() end
        return ok, err
    end

    local presetDefinitions = {
        { name="Minimal", description="Names, health and distance with the lightest visual workload.", settings={ enabled=true, showNames=true, showHealth=true, showDistance=true, showWeapon=false, showSkeleton=false, showHeadDot=false, showBoxes=false, showTracers=false, showTargetCard=false, visibilityCheck=false, showCrosshair=false, showFovCircle=false, performanceMode=false } },
        { name="Standard", description="Balanced everyday ESP configuration.", settings={ enabled=true, showNames=true, showHealth=true, showDistance=true, showWeapon=true, showSkeleton=false, showHeadDot=false, showBoxes=true, boxMode="Chams", showTracers=false, showTargetCard=true, visibilityCheck=true, showCrosshair=false, performanceMode=false } },
        { name="Full ESP", description="All major ESP visuals enabled.", settings={ enabled=true, showNames=true, showHealth=true, showDistance=true, showWeapon=true, showSkeleton=true, showHeadDot=true, showFocusTarget=true, showBoxes=true, boxMode="Split Chams", showTracers=true, showTargetCard=true, visibilityCheck=true, showLookDirection=true, performanceMode=false } },
        { name="Performance", description="Low-cost ESP plus the reversible performance profile.", settings={ enabled=true, showNames=true, showHealth=true, showDistance=true, showWeapon=false, showSkeleton=false, showHeadDot=false, showBoxes=true, boxMode="Chams", showTracers=false, showTargetCard=false, visibilityCheck=false, performanceMode=true } },
        { name="Visual Only", description="ESP visuals enabled with movement, trainer and camera utilities disabled.", settings={ enabled=true, showNames=true, showHealth=true, showDistance=true, showWeapon=true, showBoxes=true, showSkeleton=true, showTracers=true, visibilityCheck=true, aimTrainerMode=false, walkSpeedEnabled=false, infiniteJump=false, noclip=false, fly=false, clickTeleport=false } },
        { name="Custom 1", description="User-saved custom preset slot.", customSlot="__vyrs_custom_1" },
        { name="Custom 2", description="User-saved custom preset slot.", customSlot="__vyrs_custom_2" },
    }

    function Bridge:listPresets()
        local result = {}
        for index, preset in ipairs(presetDefinitions) do table.insert(result, { index=index, name=preset.name, description=preset.description }) end
        return result
    end

    local function applyPresetSettings(settings)
        for key, value in pairs(settings or {}) do
            if Bridge:has(key) then
                local ok, err = Bridge:set(key, value)
                if not ok then return false, key .. ": " .. tostring(err) end
            end
        end
        return true
    end

    function Bridge:applyPreset(identifier)
        local index = tonumber(identifier)
        if not index then
            local wanted = string.lower(tostring(identifier or ""))
            for i, preset in ipairs(presetDefinitions) do if string.lower(preset.name) == wanted then index = i break end end
        end
        local preset = index and presetDefinitions[index] or nil
        if not preset then return false, "preset not found" end
        if preset.customSlot then
            local ok, err = self:loadConfig(preset.customSlot)
            if ok then scheduleGameProfileSave() end
            return ok, err or (ok and "custom preset loaded" or nil)
        end
        local ok, err = applyPresetSettings(preset.settings)
        if ok then scheduleGameProfileSave() end
        return ok, err
    end

    function Bridge:saveCustomPreset(slot)
        local index = tonumber(slot)
        if index ~= 1 and index ~= 2 then return false, "slot must be 1 or 2" end
        return self:saveConfig("__vyrs_custom_" .. tostring(index))
    end

    local function searchFeatures(query)
        local wanted = string.lower(tostring(query or ""))
        local matches = {}
        if wanted == "" then return matches end
        for key, value in pairs(Bridge:all()) do
            local haystack = string.lower(key .. " " .. tostring(value))
            if string.find(haystack, wanted, 1, true) then table.insert(matches, { key=key, value=value }) end
        end
        table.sort(matches, function(a, b) return a.key < b.key end)
        return matches
    end
    Bridge.searchFeatures = searchFeatures

    local function doctorReport()
        local tests = {}
        local function add(name, pass, detail, warning) table.insert(tests, { name=name, pass=pass, detail=detail, warning=warning }) end
        add("runtime bridge", type(runtime.bridge) == "table", "bridge available")
        add("terminal ui", Terminal.gui and Terminal.gui.Parent ~= nil, "VyrsConsole3 mounted")
        add("camera", Workspace.CurrentCamera ~= nil, "current camera available")
        add("player scanner", type(Bridge.status) == "function", "tracking runtime callable")
        add("adaptive renderer", not virtual.adaptiveRenderer or shared.__VYRS_ADAPTIVE_PROFILE ~= nil, virtual.adaptiveRenderer and tostring(shared.__VYRS_ADAPTIVE_PROFILE) or "disabled")
        add("entity adapters", entityController ~= nil, entityController and (tostring(entityController:count()) .. " entities discovered") or "unavailable")
        add("cleanup path", type(runtime.destroy) == "function" and type(Bridge.cleanup) == "function", "unload path available")
        add("profile storage", canUseFileApi(), canUseFileApi() and "file API available" or "file API unavailable", not canUseFileApi())

        local passCount = 0
        local lines = { "0xVyrs doctor" }
        for _, test in ipairs(tests) do
            if test.pass then passCount = passCount + 1 end
            local tag = test.pass and "PASS" or (test.warning and "WARN" or "FAIL")
            table.insert(lines, string.format("[%s] %-18s %s", tag, test.name, test.detail or ""))
        end
        table.insert(lines, string.format("%d/%d core checks passed", passCount, #tests))
        return table.concat(lines, "\n")
    end
    Bridge.doctor = doctorReport

    local previousCall = Bridge.call
    function Bridge:call(action, argument)
        action = string.lower(tostring(action or ""))
        if action == "doctor" then
            return true, doctorReport()
        elseif action == "search" then
            local matches = searchFeatures(argument)
            if #matches == 0 then return true, "no matching features" end
            local lines = {}
            for index, item in ipairs(matches) do
                if index > 30 then table.insert(lines, "...more results omitted") break end
                table.insert(lines, string.format("%-28s %s", item.key, tostring(item.value)))
            end
            return true, table.concat(lines, "\n")
        elseif action == "unload" then
            task.defer(function()
                if runtime and type(runtime.destroy) == "function" then runtime:destroy() end
                if shared.__VYRS_V33_ACTIVE_RUNTIME == runtime then shared.__VYRS_V33_ACTIVE_RUNTIME = nil end
            end)
            return true, "unloading"
        elseif action == "restart" then
            local restart = shared.__VYRS_V33_RESTART
            if type(restart) ~= "function" then return false, "restart handler unavailable" end
            task.defer(restart)
            return true, "restarting"
        elseif action == "savegameprofile" then
            return saveGameProfileNow(), canUseFileApi() and nil or "profile storage unavailable"
        elseif action == "loadgameprofile" then
            return loadGameProfileNow()
        elseif action == "freecam" then
            local camera = Workspace.CurrentCamera
            if camera and camera.CameraType ~= Enum.CameraType.Scriptable and raw.get(Bridge, "fly") == true then pcall(raw.set, Bridge, "fly", false) end
        end
        return previousCall(self, action, argument)
    end

    local function chooseAdaptiveProfile(fps)
        local current = adaptiveProfile
        if current == "quality" then
            if fps < 55 then current = "balanced" end
        elseif current == "balanced" then
            if fps >= 65 then current = "quality" elseif fps < 38 then current = "performance" end
        else
            if fps >= 46 then current = "balanced" end
        end
        adaptiveProfile = current
        shared.__VYRS_ADAPTIVE_PROFILE = virtual.adaptiveRenderer and current or nil
    end

    local adaptiveAccumulator = 0
    connect(RunService.RenderStepped, function(deltaTime)
        if not alive or deltaTime <= 0 then return end
        local fps = 1 / deltaTime
        emaFps = emaFps * 0.9 + fps * 0.1
        adaptiveAccumulator = adaptiveAccumulator + deltaTime
        if adaptiveAccumulator >= 0.5 then
            adaptiveAccumulator = 0
            if virtual.adaptiveRenderer then chooseAdaptiveProfile(emaFps) else shared.__VYRS_ADAPTIVE_PROFILE = nil end
        end
    end)
    chooseAdaptiveProfile(emaFps)

    entityController = EntityFactory({ Bridge=Bridge, GetVirtual=function(key) return virtual[key] end })
    runtime.entities = entityController

    local function create(className, props)
        local object = Instance.new(className)
        for key, value in pairs(props or {}) do object[key] = value end
        return object
    end

    local theme = {
        terminal=Color3.fromRGB(2,3,3), row=Color3.fromRGB(8,10,10), rowHover=Color3.fromRGB(17,21,20), border=Color3.fromRGB(39,43,42),
        text=Color3.fromRGB(229,232,230), muted=Color3.fromRGB(132,140,137), accent=Color3.fromRGB(91,221,137), cyan=Color3.fromRGB(89,198,226),
        warning=Color3.fromRGB(238,193,84), error=Color3.fromRGB(238,103,103),
    }

    local function mono(parent, text, size, color, alignment)
        return create("TextLabel", { BackgroundTransparency=1, BorderSizePixel=0, Font=Enum.Font.Code, Text=text or "", TextColor3=color or theme.text, TextSize=size or 11, TextXAlignment=alignment or Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Center, Parent=parent })
    end

    local function buildExtensionUi()
        local gui = Terminal.gui
        if not gui or not gui.Parent then return nil end
        local controlsHeader = nil
        for _, object in ipairs(gui:GetDescendants()) do
            if object:IsA("TextLabel") and string.find(object.Text or "", "QUICK CONTROLS", 1, true) then controlsHeader=object break end
        end
        if not controlsHeader then return nil end
        local controlsPane = controlsHeader.Parent
        local baseScroll, categoryBar = nil, nil
        for _, child in ipairs(controlsPane:GetChildren()) do
            if child:IsA("ScrollingFrame") then baseScroll=child end
            if child:IsA("Frame") then
                for _, descendant in ipairs(child:GetDescendants()) do
                    if descendant:IsA("TextButton") and descendant.Text == "[Q]" then categoryBar=child break end
                end
            end
        end
        if not baseScroll or not categoryBar then return nil end

        categoryBar.Position=UDim2.new(0,8,0,54)
        baseScroll.Position=UDim2.new(0,8,0,108)
        baseScroll.Size=UDim2.new(1,-16,1,-116)

        local searchRow=create("Frame",{Name="V33SearchRow",BackgroundColor3=theme.terminal,BorderSizePixel=0,Position=UDim2.new(0,8,0,25),Size=UDim2.new(1,-16,0,25),Parent=controlsPane})
        local search=create("TextBox",{BackgroundColor3=theme.terminal,BorderColor3=theme.border,BorderSizePixel=1,ClearTextOnFocus=false,Font=Enum.Font.Code,PlaceholderText="search features...",PlaceholderColor3=theme.muted,Position=UDim2.new(0,0,0,0),Size=UDim2.new(0.56,-3,1,0),Text="",TextColor3=theme.text,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=searchRow})
        local playersButton=create("TextButton",{AutoButtonColor=false,BackgroundColor3=theme.terminal,BorderColor3=theme.border,BorderSizePixel=1,Font=Enum.Font.Code,Position=UDim2.new(0.56,1,0,0),Size=UDim2.new(0.22,-2,1,0),Text="[PLY]",TextColor3=theme.cyan,TextSize=10,Parent=searchRow})
        local v33Button=create("TextButton",{AutoButtonColor=false,BackgroundColor3=theme.terminal,BorderColor3=theme.border,BorderSizePixel=1,Font=Enum.Font.Code,Position=UDim2.new(0.78,1,0,0),Size=UDim2.new(0.22,-1,1,0),Text="[V33]",TextColor3=theme.accent,TextSize=10,Parent=searchRow})
        local overlay=create("ScrollingFrame",{Name="V33Overlay",Active=true,AutomaticCanvasSize=Enum.AutomaticSize.Y,BackgroundColor3=Color3.fromRGB(5,6,6),BorderSizePixel=0,CanvasSize=UDim2.new(),Position=baseScroll.Position,ScrollBarImageColor3=theme.border,ScrollBarThickness=4,Size=baseScroll.Size,Visible=false,Parent=controlsPane})
        create("UIListLayout",{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder,Parent=overlay})

        local overlayObjects, inspectorLabels = {}, {}
        local mode="base"
        local function clearOverlay() for _,object in ipairs(overlayObjects) do if object and object.Parent then object:Destroy() end end overlayObjects={} inspectorLabels={} end
        local function track(object) table.insert(overlayObjects,object) return object end
        local function heading(text) local label=track(mono(overlay,"[ "..text.." ]",11,theme.cyan)); label.Size=UDim2.new(1,-4,0,24); return label end
        local function actionRow(text,callback,color)
            local row=track(create("TextButton",{AutoButtonColor=false,BackgroundColor3=theme.row,BorderSizePixel=0,Font=Enum.Font.Code,Size=UDim2.new(1,-4,0,29),Text="  "..text,TextColor3=color or theme.text,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=overlay}))
            connect(row.MouseButton1Click,callback); return row
        end
        local function settingRow(key)
            local row=track(create("TextButton",{AutoButtonColor=false,BackgroundColor3=theme.row,BorderSizePixel=0,Font=Enum.Font.Code,Size=UDim2.new(1,-4,0,29),Text="",Parent=overlay}))
            local label=mono(row,key,11,theme.text); label.Position=UDim2.new(0,7,0,0); label.Size=UDim2.new(0.58,-7,1,0)
            local valueLabel=mono(row,"",11,theme.muted,Enum.TextXAlignment.Right); valueLabel.Position=UDim2.new(0.58,0,0,0); valueLabel.Size=UDim2.new(0.42,-8,1,0)
            local function refresh()
                local current=Bridge:get(key)
                if typeof(current)=="boolean" then valueLabel.Text=current and "[ ON ]" or "[ OFF ]"; valueLabel.TextColor3=current and theme.accent or theme.muted
                else valueLabel.Text=tostring(current); valueLabel.TextColor3=theme.cyan end
            end
            connect(row.MouseButton1Click,function()
                local current=Bridge:get(key)
                if typeof(current)=="boolean" then local ok,err=Bridge:set(key,not current); if not ok then write(err,theme.error) end; refresh()
                elseif typeof(current)=="number" then write("Use: set "..key.." <value>",theme.cyan)
                else write(key.." = "..tostring(current),theme.cyan) end
            end)
            refresh(); return row
        end

        local function showBase() mode="base"; clearOverlay(); overlay.Visible=false; categoryBar.Visible=true; baseScroll.Visible=true end
        local function showSearch(query)
            mode="search"; clearOverlay(); categoryBar.Visible=false; baseScroll.Visible=false; overlay.Visible=true; heading("SEARCH: "..tostring(query))
            local matches=searchFeatures(query)
            if #matches==0 then local empty=track(mono(overlay,"  no matching features",11,theme.muted)); empty.Size=UDim2.new(1,-4,0,28); return end
            for index,item in ipairs(matches) do if index>40 then break end; settingRow(item.key) end
        end
        local function updateInspectorLabels()
            if mode~="players" or not selectedPlayerName then return end
            local info=Bridge:inspectPlayer(selectedPlayerName); if not info then return end
            if inspectorLabels.title then inspectorLabels.title.Text=string.format("%s  @%s",info.displayName,info.name) end
            if inspectorLabels.meta1 then inspectorLabels.meta1.Text=string.format("HP %.0f/%.0f   DIST %.0f",info.health,info.maxHealth,info.distance) end
            if inspectorLabels.meta2 then inspectorLabels.meta2.Text=string.format("VISIBLE %s   TOOL %s",info.visible and "YES" or "NO",info.tool) end
            if inspectorLabels.meta3 then inspectorLabels.meta3.Text=string.format("%s   TEAM %s",info.movement,tostring(info.team)) end
        end
        local function showPlayers()
            mode="players"; search.Text=""; clearOverlay(); categoryBar.Visible=false; baseScroll.Visible=false; overlay.Visible=true; heading("PLAYER INSPECTOR")
            local detail=track(create("Frame",{BackgroundColor3=theme.row,BorderSizePixel=0,Size=UDim2.new(1,-4,0,104),Parent=overlay}))
            inspectorLabels.title=mono(detail,selectedPlayerName and selectedPlayerName or "No player selected",12,theme.accent); inspectorLabels.title.Position=UDim2.new(0,8,0,5); inspectorLabels.title.Size=UDim2.new(1,-16,0,20)
            inspectorLabels.meta1=mono(detail,"--",10,theme.text); inspectorLabels.meta1.Position=UDim2.new(0,8,0,27); inspectorLabels.meta1.Size=UDim2.new(1,-16,0,16)
            inspectorLabels.meta2=mono(detail,"--",10,theme.text); inspectorLabels.meta2.Position=UDim2.new(0,8,0,44); inspectorLabels.meta2.Size=UDim2.new(1,-16,0,16)
            inspectorLabels.meta3=mono(detail,"--",10,theme.muted); inspectorLabels.meta3.Position=UDim2.new(0,8,0,61); inspectorLabels.meta3.Size=UDim2.new(1,-16,0,16)
            local spectate=create("TextButton",{AutoButtonColor=false,BackgroundTransparency=1,BorderSizePixel=0,Font=Enum.Font.Code,Position=UDim2.new(0,8,0,80),Size=UDim2.new(0.31,0,0,20),Text="[SPECTATE]",TextColor3=theme.cyan,TextSize=10,Parent=detail})
            local focus=create("TextButton",{AutoButtonColor=false,BackgroundTransparency=1,BorderSizePixel=0,Font=Enum.Font.Code,Position=UDim2.new(0.34,0,0,80),Size=UDim2.new(0.28,0,0,20),Text="[FOCUS]",TextColor3=theme.accent,TextSize=10,Parent=detail})
            local clear=create("TextButton",{AutoButtonColor=false,BackgroundTransparency=1,BorderSizePixel=0,Font=Enum.Font.Code,Position=UDim2.new(0.65,0,0,80),Size=UDim2.new(0.31,-8,0,20),Text="[CLEAR]",TextColor3=theme.muted,TextSize=10,Parent=detail})
            connect(spectate.MouseButton1Click,function() if selectedPlayerName then Bridge:call("spectate",selectedPlayerName) end end)
            connect(focus.MouseButton1Click,function() if selectedPlayerName then local ok,err=Bridge:call("focus",selectedPlayerName); if not ok then write(err,theme.error) end end end)
            connect(clear.MouseButton1Click,function() selectedPlayerName=nil; Bridge:call("spectate","off"); Bridge:call("focusclear"); showPlayers() end)
            heading("PLAYERS")
            for _,player in ipairs(Bridge:listPlayers()) do actionRow(player.displayName.."  @"..player.name,function() selectedPlayerName=player.name; showPlayers() end,selectedPlayerName==player.name and theme.accent or theme.text) end
            updateInspectorLabels()
        end
        local function showV33()
            mode="v33"; search.Text=""; clearOverlay(); categoryBar.Visible=false; baseScroll.Visible=false; overlay.Visible=true
            heading("V3.3 RUNTIME"); settingRow("adaptiveRenderer")
            local profileLabel=track(mono(overlay,"  adaptive profile: "..string.upper(adaptiveProfile),10,theme.cyan)); profileLabel.Size=UDim2.new(1,-4,0,24)
            settingRow("autoGameProfiles")
            actionRow("SAVE GAME PROFILE NOW",function() local ok,err=Bridge:call("savegameprofile"); write(ok and "game profile saved" or tostring(err),ok and theme.accent or theme.error) end)
            actionRow("LOAD GAME PROFILE",function() local ok,err=Bridge:call("loadgameprofile"); write(ok and "game profile loaded" or tostring(err),ok and theme.accent or theme.error) end)
            heading("ENTITY ADAPTERS"); settingRow("entityEsp"); settingRow("entityAutoScan"); settingRow("entityNames"); settingRow("entityHealth"); settingRow("entityDistance"); settingRow("entityMaxDistance")
            local entityLabel=track(mono(overlay,"  discovered entities: "..tostring(entityController and entityController:count() or 0),10,theme.muted)); entityLabel.Size=UDim2.new(1,-4,0,24)
            actionRow("RESCAN ENTITIES",function() if entityController then entityController:rescan(); showV33() end end)
            heading("CUSTOM PRESETS")
            actionRow("SAVE CUSTOM 1",function() local ok,err=Bridge:saveCustomPreset(1); write(ok and "Custom 1 saved" or tostring(err),ok and theme.accent or theme.error) end)
            actionRow("SAVE CUSTOM 2",function() local ok,err=Bridge:saveCustomPreset(2); write(ok and "Custom 2 saved" or tostring(err),ok and theme.accent or theme.error) end)
            actionRow("LOAD CUSTOM 1",function() local ok,err=Bridge:applyPreset("Custom 1"); write(ok and "Custom 1 loaded" or tostring(err),ok and theme.accent or theme.error) end)
            actionRow("LOAD CUSTOM 2",function() local ok,err=Bridge:applyPreset("Custom 2"); write(ok and "Custom 2 loaded" or tostring(err),ok and theme.accent or theme.error) end)
            heading("DEPENDENCIES")
            local dependency=track(mono(overlay,"  performance: "..dependencyState("performanceMode"),10,theme.muted)); dependency.Size=UDim2.new(1,-4,0,24)
            heading("SYSTEM")
            actionRow("DOCTOR SELF-TEST",function() local _,report=Bridge:call("doctor"); write(report,theme.cyan) end,theme.cyan)
            actionRow("RESTART RUNTIME",function() Bridge:call("restart") end,theme.warning)
            actionRow("UNLOAD COMPLETELY",function() Bridge:call("unload") end,theme.error)
        end

        connect(search:GetPropertyChangedSignal("Text"),function()
            local query=search.Text:match("^%s*(.-)%s*$") or ""
            if query=="" then if mode=="search" then showBase() end else showSearch(query) end
        end)
        connect(playersButton.MouseButton1Click,showPlayers); connect(v33Button.MouseButton1Click,showV33)
        for _,object in ipairs(categoryBar:GetDescendants()) do if object:IsA("TextButton") then connect(object.MouseButton1Click,showBase) end end
        task.spawn(function() while alive and gui.Parent do if mode=="players" then updateInspectorLabels() end task.wait(0.5) end end)

        return { destroy=function()
            if searchRow then searchRow:Destroy() end
            if overlay then overlay:Destroy() end
            if categoryBar and categoryBar.Parent then categoryBar.Position=UDim2.new(0,8,0,25); categoryBar.Visible=true end
            if baseScroll and baseScroll.Parent then baseScroll.Position=UDim2.new(0,8,0,79); baseScroll.Size=UDim2.new(1,-16,1,-87); baseScroll.Visible=true end
        end }
    end

    extensionUi=buildExtensionUi()

    if virtual.autoGameProfiles then
        task.defer(function() local ok=loadGameProfileNow(); if ok then write("[v3.3] per-game profile loaded",theme.accent) end end)
    end

    local previousCleanup=Bridge.cleanup
    function Bridge:cleanup()
        if not alive then return end
        alive=false
        profileWriteToken=profileWriteToken+1
        shared.__VYRS_ADAPTIVE_PROFILE=nil
        if extensionUi and extensionUi.destroy then pcall(extensionUi.destroy) end
        if entityController and entityController.destroy then pcall(function() entityController:destroy() end) end
        for _,connection in ipairs(connections) do pcall(function() connection:Disconnect() end) end
        connections={}
        pcall(previousCleanup,self)
        if shared.__VYRS_ENTITY_ADAPTERS==entityController then shared.__VYRS_ENTITY_ADAPTERS=nil end
        if shared.__VYRS_V33_ENHANCEMENTS==runtime.enhancements then shared.__VYRS_V33_ENHANCEMENTS=nil end
    end

    runtime.version="3.3-alpha.1"
    runtime.enhancements={ virtual=virtual, saveGameProfile=saveGameProfileNow, loadGameProfile=loadGameProfileNow, doctor=doctorReport, search=searchFeatures }
    shared.__VYRS_V33_ENHANCEMENTS=runtime.enhancements
    return runtime
end
