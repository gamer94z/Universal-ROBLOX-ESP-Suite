return function(context)
    local CONFIG = context.CONFIG
    local LOCAL_PLAYER = context.LOCAL_PLAYER
    local UserInputService = context.UserInputService
    local viewState = context.viewState
    local viewButtons = context.viewButtons
    local playerButtons = context.playerButtons
    local THEME = context.THEME
    local truncateText = context.truncateText
    local getCamera = context.getCamera
    local getLocalHumanoid = context.getLocalHumanoid
    local getMouseLocation = context.getMouseLocation
    local setToggleState = context.setToggleState
    local setSliderState = context.setSliderState
    local updateMouseIconVisibility = context.updateMouseIconVisibility
    local showToast = context.showToast

    local function applyZoomLimitSetting()
        if not LOCAL_PLAYER then return end
        if viewState.defaultMinZoomDistance == nil then
            viewState.defaultMinZoomDistance = LOCAL_PLAYER.CameraMinZoomDistance
        end
        if viewState.defaultMaxZoomDistance == nil then
            viewState.defaultMaxZoomDistance = LOCAL_PLAYER.CameraMaxZoomDistance
        end
        if CONFIG.removeZoomLimit then
            LOCAL_PLAYER.CameraMinZoomDistance = 0.5
            LOCAL_PLAYER.CameraMaxZoomDistance = 100000
        else
            LOCAL_PLAYER.CameraMinZoomDistance = viewState.defaultMinZoomDistance
            LOCAL_PLAYER.CameraMaxZoomDistance = viewState.defaultMaxZoomDistance
        end
    end

    local function setLocalMovementSuppressed(state)
        local humanoid = getLocalHumanoid()
        if state then
            if not viewState.controls then
                local success, controls = pcall(function()
                    return require(LOCAL_PLAYER.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
                end)
                if success then viewState.controls = controls end
            end
            if viewState.controls then
                pcall(function() viewState.controls:Disable() end)
            end
            if humanoid then
                if not viewState.humanoidState or viewState.humanoidState.humanoid ~= humanoid then
                    viewState.humanoidState = {
                        humanoid = humanoid,
                        walkSpeed = humanoid.WalkSpeed,
                        jumpPower = humanoid.JumpPower,
                        jumpHeight = humanoid.JumpHeight,
                        autoRotate = humanoid.AutoRotate,
                    }
                end
                humanoid.WalkSpeed = 0
                humanoid.JumpPower = 0
                humanoid.JumpHeight = 0
                humanoid.AutoRotate = false
                humanoid:Move(Vector3.zero, true)
            end
        else
            if viewState.controls then
                pcall(function() viewState.controls:Enable() end)
            end
            local cached = viewState.humanoidState
            if cached and cached.humanoid and cached.humanoid.Parent then
                cached.humanoid.WalkSpeed = cached.walkSpeed
                cached.humanoid.JumpPower = cached.jumpPower
                cached.humanoid.JumpHeight = cached.jumpHeight
                cached.humanoid.AutoRotate = cached.autoRotate
            end
            viewState.humanoidState = nil
        end
    end

    local function restoreLocalCamera()
        local camera = getCamera()
        if not camera then return end
        local humanoid = getLocalHumanoid()
        camera.CameraType = Enum.CameraType.Custom
        if humanoid then camera.CameraSubject = humanoid end
    end

    local function updateViewUi()
        if viewButtons.status then
            if viewState.freeCamEnabled then
                viewButtons.status.Text = "FREE CAM"
                viewButtons.status.TextColor3 = THEME.accent
            elseif viewState.spectateTarget then
                viewButtons.status.Text = truncateText(viewState.spectateTarget.Name, 14)
                viewButtons.status.TextColor3 = THEME.focus
            else
                viewButtons.status.Text = "LOCAL"
                viewButtons.status.TextColor3 = THEME.text
            end
        end
        if viewButtons.spectate then
            viewButtons.spectate.main.Text = viewState.spectateTarget and truncateText(viewState.spectateTarget.Name, 14) or "SELECT"
        end
        if viewButtons.freeCam then setToggleState(viewButtons.freeCam, viewState.freeCamEnabled) end
        if viewButtons.speed then setSliderState(viewButtons.speed, CONFIG.freeCamSpeed) end
        if playerButtons.status then
            local states = {}
            if CONFIG.walkSpeedEnabled then table.insert(states, string.format("SPD %d", CONFIG.walkSpeed)) end
            if CONFIG.infiniteJump then table.insert(states, "INF JUMP") end
            if CONFIG.fly then table.insert(states, "FLY") end
            if CONFIG.noclip then table.insert(states, "NOCLIP") end
            if CONFIG.clickTeleport then table.insert(states, "CLICK TP") end
            playerButtons.status.Text = #states > 0 and table.concat(states, " | ") or "LOCAL"
            playerButtons.status.TextColor3 = #states > 0 and THEME.accent or THEME.text
        end
    end

    local function disableFreeCam(restore)
        viewState.freeCamEnabled = false
        viewState.lookHeld = false
        viewState.moveForward = 0
        viewState.moveRight = 0
        viewState.moveUp = 0
        viewState.freeCamCFrame = nil
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        setLocalMovementSuppressed(false)
        if restore ~= false then restoreLocalCamera() end
    end

    local function setSpectateTarget(player)
        local camera = getCamera()
        viewState.spectateTarget = player
        if viewState.freeCamEnabled then disableFreeCam(false) end
        if camera and player and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                camera.CameraType = Enum.CameraType.Custom
                camera.CameraSubject = humanoid
            end
        elseif not viewState.freeCamEnabled then
            restoreLocalCamera()
        end
        updateViewUi()
    end

    local function toggleFreeCam()
        local camera = getCamera()
        if not camera then
            showToast("View", "Camera unavailable", THEME.muted)
            return
        end

        if viewState.freeCamEnabled then
            disableFreeCam(true)
            updateViewUi()
            updateMouseIconVisibility()
            if context.updateKeybindController then context.updateKeybindController() end
            showToast("View", "Free Cam disabled", THEME.muted)
            return
        end

        viewState.spectateTarget = nil
        viewState.freeCamEnabled = true
        viewState.lookHeld = false
        viewState.moveForward = 0
        viewState.moveRight = 0
        viewState.moveUp = 0
        viewState.freeCamCFrame = camera.CFrame

        local pitch, yaw = camera.CFrame:ToOrientation()
        viewState.freeCamPitch = pitch
        viewState.freeCamYaw = yaw

        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = viewState.freeCamCFrame
        setLocalMovementSuppressed(true)
        updateViewUi()
        updateMouseIconVisibility()
        if context.updateKeybindController then context.updateKeybindController() end
        showToast("View", "Free Cam enabled | RMB look | WASD move | Space/Ctrl vertical", THEME.accent)
    end

    local function applyCameraFov()
        local camera = getCamera()
        if camera and math.abs(camera.FieldOfView - CONFIG.cameraFov) > 0.05 then
            camera.FieldOfView = CONFIG.cameraFov
        end
    end

    local function getMouseScreenPosition(camera)
        camera = camera or workspace.CurrentCamera
        if not camera then return nil end
        local viewport = camera.ViewportSize
        if not viewport then return nil end
        local mouseLocation = getMouseLocation()
        if typeof(mouseLocation) == "Vector2" and mouseLocation.X == mouseLocation.X and mouseLocation.Y == mouseLocation.Y then
            return Vector2.new(math.clamp(mouseLocation.X, 0, viewport.X), math.clamp(mouseLocation.Y, 0, viewport.Y))
        end
        local mouse = LOCAL_PLAYER and LOCAL_PLAYER:GetMouse()
        if mouse and tonumber(mouse.X) and tonumber(mouse.Y) then
            return Vector2.new(math.clamp(mouse.X, 0, viewport.X), math.clamp(mouse.Y, 0, viewport.Y))
        end
        return Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
    end

    local function getTracerOrigin(camera)
        if CONFIG.tracerOriginMode == "Center" then
            return Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y * 0.5)
        end
        if CONFIG.tracerOriginMode == "Mouse" or CONFIG.tracerOriginMode == "Crosshair" then
            local mousePosition = getMouseScreenPosition(camera)
            if mousePosition then return mousePosition end
        end
        return Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y - 24)
    end

    return {
        applyZoomLimitSetting = applyZoomLimitSetting,
        setLocalMovementSuppressed = setLocalMovementSuppressed,
        restoreLocalCamera = restoreLocalCamera,
        updateViewUi = updateViewUi,
        setSpectateTarget = setSpectateTarget,
        toggleFreeCam = toggleFreeCam,
        applyCameraFov = applyCameraFov,
        getMouseScreenPosition = getMouseScreenPosition,
        getTracerOrigin = getTracerOrigin,
    }
end
