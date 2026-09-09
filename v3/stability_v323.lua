return function(runtime)
    if type(runtime) ~= "table" or type(runtime.bridge) ~= "table" then
        error("[0xVyrs v3.2.3] stability patch requires a runtime bridge")
    end

    local bridge = runtime.bridge
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
    local Workspace = game:GetService("Workspace")
    local shared = (type(getgenv) == "function" and getgenv()) or _G

    local rawSet = bridge.set
    local rawCall = bridge.call
    local rawPanic = bridge.panic
    local rawCleanup = bridge.cleanup
    local rawStatus = bridge.status

    local collisionCache = setmetatable({}, { __mode = "k" })
    local noclipDescendantConnection = nil
    local characterConnection = nil
    local walkSpeedBaseline = nil

    local performanceChildren = {
        "simplifyMaterials",
        "hideTextures",
        "hideEffects",
        "disableShadows",
    }
    local performanceChildLookup = {}
    for _, key in ipairs(performanceChildren) do performanceChildLookup[key] = true end

    local function getCharacter()
        return LocalPlayer and LocalPlayer.Character or nil
    end

    local function getHumanoid()
        local character = getCharacter()
        return character and character:FindFirstChildOfClass("Humanoid") or nil
    end

    local function getRoot()
        local character = getCharacter()
        if not character then return nil end
        return character:FindFirstChild("HumanoidRootPart")
            or character:FindFirstChild("UpperTorso")
            or character:FindFirstChild("Torso")
    end

    local function stopNoclipListener()
        if noclipDescendantConnection then
            pcall(function() noclipDescendantConnection:Disconnect() end)
            noclipDescendantConnection = nil
        end
    end

    local function rememberCollision(part)
        if part and part:IsA("BasePart") and collisionCache[part] == nil then
            collisionCache[part] = part.CanCollide
        end
    end

    local function captureNoclipState()
        stopNoclipListener()
        local character = getCharacter()
        if not character then return end

        for _, item in ipairs(character:GetDescendants()) do
            rememberCollision(item)
        end
        noclipDescendantConnection = character.DescendantAdded:Connect(function(item)
            rememberCollision(item)
        end)
    end

    local function restoreNoclipState()
        stopNoclipListener()
        for part, originalCanCollide in pairs(collisionCache) do
            if part and part.Parent then
                pcall(function() part.CanCollide = originalCanCollide end)
            end
            collisionCache[part] = nil
        end
    end

    local function captureWalkSpeed()
        local humanoid = getHumanoid()
        if humanoid then walkSpeedBaseline = humanoid.WalkSpeed end
    end

    local function restoreWalkSpeed()
        local humanoid = getHumanoid()
        if humanoid and walkSpeedBaseline ~= nil then
            pcall(function() humanoid.WalkSpeed = walkSpeedBaseline end)
        end
        walkSpeedBaseline = nil
    end

    local function stopFlyState()
        local humanoid = getHumanoid()
        local root = getRoot()
        if humanoid then
            pcall(function() humanoid.PlatformStand = false end)
            pcall(function() humanoid.AutoRotate = true end)
            pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Running) end)
        end
        if root then
            pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
            pcall(function() root.AssemblyAngularVelocity = Vector3.zero end)
        end
    end

    local function cameraLooksFreecam()
        local camera = Workspace.CurrentCamera
        return camera and camera.CameraType == Enum.CameraType.Scriptable
    end

    function bridge:set(key, value)
        local oldValue = self:get(key)

        if key == "walkSpeedEnabled" and value == true and oldValue ~= true then
            captureWalkSpeed()
        elseif key == "noclip" and value == true and oldValue ~= true then
            captureNoclipState()
        end

        if key == "performanceMode" then
            if value == true then
                local ok, err = rawSet(self, key, true)
                if not ok then return false, err end
                for _, childKey in ipairs(performanceChildren) do
                    local childOk, childErr = rawSet(self, childKey, true)
                    if not childOk then return false, childErr end
                end
            else
                for _, childKey in ipairs(performanceChildren) do
                    local childOk, childErr = rawSet(self, childKey, false)
                    if not childOk then return false, childErr end
                end
                local ok, err = rawSet(self, key, false)
                if not ok then return false, err end
            end
            return true
        end

        if performanceChildLookup[key] and value == false and self:get("performanceMode") == true then
            local modeOk, modeErr = rawSet(self, "performanceMode", false)
            if not modeOk then return false, modeErr end
        end

        local ok, err = rawSet(self, key, value)
        if not ok then return false, err end

        if key == "walkSpeedEnabled" and value == false then
            restoreWalkSpeed()
        elseif key == "noclip" and value == false then
            restoreNoclipState()
        elseif key == "fly" and value == false then
            stopFlyState()
        end

        return true
    end

    function bridge:call(action, argument)
        action = string.lower(tostring(action or ""))

        if action == "resetview" and cameraLooksFreecam() then
            pcall(function() rawCall(self, "freecam") end)
        end

        return rawCall(self, action, argument)
    end

    function bridge:status()
        local result = rawStatus(self)
        result.freecam = cameraLooksFreecam()
        return result
    end

    function bridge:panic()
        rawPanic(self)
        if cameraLooksFreecam() then
            pcall(function() rawCall(self, "freecam") end)
        end
        restoreWalkSpeed()
        restoreNoclipState()
        stopFlyState()
    end

    function bridge:cleanup()
        rawCleanup(self)
        restoreWalkSpeed()
        restoreNoclipState()
        stopFlyState()
        if characterConnection then
            pcall(function() characterConnection:Disconnect() end)
            characterConnection = nil
        end
        if shared.__VYRS_PERF_DESC_CONN and type(shared.__VYRS_PERF_DESC_CONN.Disconnect) == "function" then
            pcall(function() shared.__VYRS_PERF_DESC_CONN:Disconnect() end)
            shared.__VYRS_PERF_DESC_CONN = nil
        end
    end

    characterConnection = LocalPlayer.CharacterAdded:Connect(function()
        walkSpeedBaseline = nil
        restoreNoclipState()
        if bridge:get("noclip") == true then
            task.defer(captureNoclipState)
        end
    end)

    runtime.version = "3.2.3"
    return runtime
end
