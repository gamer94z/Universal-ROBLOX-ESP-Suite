return function(context)
    local Bridge = assert(context.Bridge, "missing bridge")
    local GetVirtual = assert(context.GetVirtual, "missing virtual getter")
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
    local shared = (type(getgenv) == "function" and getgenv()) or _G

    local alive = true
    local connections = {}
    local entities = setmetatable({}, { __mode = "k" })
    local visuals = setmetatable({}, { __mode = "k" })
    local adapters = {}
    local adapterAccumulator = 0
    local renderAccumulator = 0

    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(connections, connection)
        return connection
    end

    local function getRoot(model)
        if not model or not model:IsA("Model") then return nil end
        return model:FindFirstChild("HumanoidRootPart")
            or model:FindFirstChild("UpperTorso")
            or model:FindFirstChild("Torso")
            or model:FindFirstChild("Root")
            or model.PrimaryPart
    end

    local function getHumanoid(model)
        return model and model:FindFirstChildOfClass("Humanoid") or nil
    end

    local function localRoot()
        local character = LocalPlayer and LocalPlayer.Character
        return character and getRoot(character) or nil
    end

    local function isPlayerCharacter(model)
        if not model then return false end
        local ok, player = pcall(function() return Players:GetPlayerFromCharacter(model) end)
        return ok and player ~= nil
    end

    local function candidate(model, trustedAdapter)
        if not model or not model:IsA("Model") or not model.Parent then return false end
        if isPlayerCharacter(model) then return false end
        local root = getRoot(model)
        if not root then return false end
        if trustedAdapter then return true end
        return getHumanoid(model) ~= nil
    end

    local function addEntity(model, sourceName, trustedAdapter)
        if not candidate(model, trustedAdapter) then return false end
        local data = entities[model]
        if not data then
            data = { source = sourceName or "auto", trusted = trustedAdapter == true, addedAt = os.clock() }
            entities[model] = data
        else
            if sourceName then data.source = sourceName end
            if trustedAdapter then data.trusted = true end
        end
        return true
    end

    local function clearVisual(model)
        local visual = visuals[model]
        if visual then
            for _, object in pairs(visual) do
                if typeof(object) == "Instance" then pcall(function() object:Destroy() end) end
            end
            visuals[model] = nil
        end
    end

    local function ensureVisual(model)
        local visual = visuals[model]
        if visual and visual.highlight and visual.highlight.Parent then return visual end
        clearVisual(model)

        local root = getRoot(model)
        if not root then return nil end

        local highlight = Instance.new("Highlight")
        highlight.Name = "VyrsEntityHighlight"
        highlight.Adornee = model
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.78
        highlight.OutlineTransparency = 0.05
        highlight.Parent = model

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "VyrsEntityBillboard"
        billboard.Adornee = model:FindFirstChild("Head") or root
        billboard.AlwaysOnTop = true
        billboard.LightInfluence = 0
        billboard.Size = UDim2.new(0, 220, 0, 42)
        billboard.StudsOffset = Vector3.new(0, 3.2, 0)
        billboard.Parent = model

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.BorderSizePixel = 0
        label.Font = Enum.Font.Code
        label.Size = UDim2.fromScale(1, 1)
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0.45
        label.TextSize = 13
        label.TextWrapped = true
        label.Parent = billboard

        visual = { highlight = highlight, billboard = billboard, label = label }
        visuals[model] = visual
        return visual
    end

    local function effectiveColor()
        local ok, color = pcall(function() return Bridge:get("fallbackEspColor") end)
        if ok and typeof(color) == "Color3" then return color end
        return Color3.fromRGB(91, 221, 137)
    end

    local function updateEntity(model, data, origin)
        if not model.Parent or not candidate(model, data and data.trusted) then
            clearVisual(model)
            entities[model] = nil
            return
        end

        local root = getRoot(model)
        local humanoid = getHumanoid(model)
        if not root then
            clearVisual(model)
            entities[model] = nil
            return
        end
        if humanoid and humanoid.Health <= 0 then
            clearVisual(model)
            return
        end

        local maxDistance = tonumber(GetVirtual("entityMaxDistance")) or 1500
        local distance = origin and (root.Position - origin.Position).Magnitude or math.huge
        local enabled = Bridge:get("enabled") == true and GetVirtual("entityEsp") == true and distance <= maxDistance
        if not enabled then
            clearVisual(model)
            return
        end

        local visual = ensureVisual(model)
        if not visual then return end

        local color = effectiveColor()
        visual.highlight.Enabled = true
        visual.highlight.FillColor = color
        visual.highlight.OutlineColor = color

        local text = {}
        if GetVirtual("entityNames") then table.insert(text, model.Name) end
        if GetVirtual("entityHealth") and humanoid then
            table.insert(text, string.format("HP %.0f/%.0f", humanoid.Health, humanoid.MaxHealth))
        end
        if GetVirtual("entityDistance") then
            table.insert(text, string.format("%.0f studs", distance))
        end
        visual.billboard.Enabled = #text > 0
        visual.label.Text = table.concat(text, "  |  ")
        visual.label.TextColor3 = color
    end

    local function scanAutomatic()
        if not GetVirtual("entityAutoScan") then return end
        for _, item in ipairs(Workspace:GetDescendants()) do
            if item:IsA("Humanoid") and item.Parent and item.Parent:IsA("Model") then
                addEntity(item.Parent, "auto", false)
            end
        end
    end

    local function pollAdapters()
        for name, resolver in pairs(adapters) do
            local ok, result = pcall(resolver)
            if ok and type(result) == "table" then
                for _, model in ipairs(result) do
                    if typeof(model) == "Instance" then addEntity(model, name, true) end
                end
            end
        end
    end

    local function profileInterval()
        local profile = shared.__VYRS_ADAPTIVE_PROFILE
        if profile == "performance" then return 1 / 12 end
        if profile == "balanced" then return 1 / 20 end
        return 1 / 30
    end

    connect(Workspace.DescendantAdded, function(item)
        if not alive or not GetVirtual("entityAutoScan") then return end
        if item:IsA("Humanoid") and item.Parent and item.Parent:IsA("Model") then
            task.defer(function() if alive then addEntity(item.Parent, "auto", false) end end)
        elseif item:IsA("Model") then
            task.defer(function() if alive then addEntity(item, "auto", false) end end)
        end
    end)

    connect(RunService.Heartbeat, function(deltaTime)
        if not alive then return end
        renderAccumulator = renderAccumulator + deltaTime
        adapterAccumulator = adapterAccumulator + deltaTime

        if adapterAccumulator >= 2 then
            adapterAccumulator = 0
            pollAdapters()
        end

        if renderAccumulator < profileInterval() then return end
        renderAccumulator = 0

        local origin = localRoot()
        for model, data in pairs(entities) do updateEntity(model, data, origin) end
    end)

    task.defer(scanAutomatic)

    local controller = {}

    function controller:registerAdapter(name, resolver)
        if type(name) ~= "string" or name == "" or type(resolver) ~= "function" then
            return false, "adapter requires a name and resolver function"
        end
        adapters[name] = resolver
        return true
    end

    function controller:registerFolder(name, folder)
        if typeof(folder) ~= "Instance" then return false, "folder instance required" end
        return self:registerAdapter(name, function()
            local result = {}
            for _, child in ipairs(folder:GetChildren()) do
                if child:IsA("Model") then table.insert(result, child) end
            end
            return result
        end)
    end

    function controller:count()
        local count = 0
        for model in pairs(entities) do if model and model.Parent then count = count + 1 end end
        return count
    end

    function controller:rescan()
        scanAutomatic()
        pollAdapters()
    end

    function controller:destroy()
        if not alive then return end
        alive = false
        for _, connection in ipairs(connections) do pcall(function() connection:Disconnect() end) end
        connections = {}
        for model in pairs(visuals) do clearVisual(model) end
        entities = setmetatable({}, { __mode = "k" })
        adapters = {}
    end

    shared.__VYRS_ENTITY_ADAPTERS = controller
    return controller
end
