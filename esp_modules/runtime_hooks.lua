return function(context)
	local CONFIG = context.CONFIG
	local THEME = context.THEME
	local SHARED_ENV = context.SHARED_ENV
	local gui = context.gui
	local window = context.window
	local watermark = context.watermark
	local miniHud = context.miniHud
	local miniHudLabels = context.miniHudLabels
	local chrome = context.chrome
	local Players = context.Players
	local LOCAL_PLAYER = context.LOCAL_PLAYER
	local UserInputService = context.UserInputService
	local RunService = context.RunService
	local tracerSliders = context.tracerSliders
	local viewButtons = context.viewButtons
	local playerButtons = context.playerButtons
	local viewState = context.viewState
	local espRuntimeState = context.espRuntimeState
	local espObjects = context.espObjects
	local saveNamedConfigFromInput = context.saveNamedConfigFromInput
	local resetOverlayPositions = context.resetOverlayPositions
	local resetDisplaySettings = context.resetDisplaySettings
	local resetViewSettings = context.resetViewSettings
	local resetPerformanceSettings = context.resetPerformanceSettings
	local syncUiFromConfig = context.syncUiFromConfig
	local refreshAllEsp = context.refreshAllEsp
	local saveSettings = context.saveSettings
	local showToast = context.showToast
	local applyCameraFov = context.applyCameraFov
	local applyZoomLimitSetting = context.applyZoomLimitSetting
	local updateViewUi = context.updateViewUi
	local applyPerformanceSettings = context.applyPerformanceSettings
	local getLocalHumanoid = context.getLocalHumanoid
	local hookCharacter = context.hookCharacter
	local clearPlayerEsp = context.clearPlayerEsp
	local setSpectateTarget = context.setSpectateTarget
	local bindSliderDragStart = context.bindSliderDragStart
	local bindSliderValueInput = context.bindSliderValueInput
	local setSliderState = context.setSliderState
	local updateCrosshair = context.updateCrosshair
	local updateTrainerVisuals = context.updateTrainerVisuals
	local applyPlayerMovementState = context.applyPlayerMovementState
	local ensureTrainerState = context.ensureTrainerState
	local getMouseScreenPosition = context.getMouseScreenPosition
	local getCamera = context.getCamera
	local recordTrainerClickSuccess = context.recordTrainerClickSuccess
	local spawnTrainerTarget = context.spawnTrainerTarget
	local recordTrainerClickMiss = context.recordTrainerClickMiss
	local getLocalRoot = context.getLocalRoot
	local setEspEnabled = context.setEspEnabled
	local hideCrosshair = context.hideCrosshair
	local updateMouseIconVisibility = context.updateMouseIconVisibility
	local getKeybindController = context.getKeybindController
	local toggleFreeCam = context.toggleFreeCam
	local setLocalMovementSuppressed = context.setLocalMovementSuppressed

	local function isActiveToken()
		return SHARED_ENV.__VYRS_ESP_ACTIVE_TOKEN == gui:GetAttribute("ActiveToken")
	end

	local function runSafeFrameTask(errorCounts, taskName, taskFn, ...)
		local ok, err = pcall(taskFn, ...)
		if ok then
			return true
		end

		local count = (errorCounts[taskName] or 0) + 1
		errorCounts[taskName] = count
		if count <= 3 then
			warn(string.format("[0xVyrs] %s failed: %s", taskName, tostring(err)))
		end
		return false
	end

	local function setup()
		miniHudLabels.utility.configNameInput.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				saveNamedConfigFromInput()
			end
		end)

		miniHudLabels.utility.resetPositions.MouseButton1Click:Connect(function()
			resetOverlayPositions()
			showToast("Settings", "Overlay positions reset", THEME.accent)
		end)

		miniHudLabels.utility.resetDisplay.MouseButton1Click:Connect(function()
			resetDisplaySettings()
			syncUiFromConfig()
			refreshAllEsp()
			saveSettings()
			showToast("Settings", "Display settings reset", THEME.accent)
		end)

		miniHudLabels.utility.resetView.MouseButton1Click:Connect(function()
			resetViewSettings()
			syncUiFromConfig()
			applyCameraFov()
			applyZoomLimitSetting()
			updateViewUi()
			saveSettings()
			showToast("Settings", "View settings reset", THEME.accent)
		end)

		miniHudLabels.utility.resetPerformance.MouseButton1Click:Connect(function()
			resetPerformanceSettings()
			applyPerformanceSettings()
			syncUiFromConfig()
			saveSettings()
			showToast("Settings", "Performance settings reset", THEME.accent)
		end)

		miniHudLabels.utility.respawn.MouseButton1Click:Connect(function()
			local success = pcall(function()
				LOCAL_PLAYER:LoadCharacter()
			end)

			if not success then
				local character = LOCAL_PLAYER.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					pcall(function()
						humanoid.Health = 0
					end)
					pcall(function()
						humanoid:ChangeState(Enum.HumanoidStateType.Dead)
					end)
				elseif character then
					pcall(function()
						character:BreakJoints()
					end)
				end
			end

			showToast("Player Utility", "Respawn requested", THEME.accent)
		end)

		miniHudLabels.utility.tools.MouseButton1Click:Connect(function()
			pcall(function()
				local humanoid = getLocalHumanoid()
				if humanoid then
					humanoid:UnequipTools()
				end
			end)
			showToast("Player Utility", "Tools reset", THEME.accent)
		end)

		chrome.minimizeButton.MouseButton1Click:Connect(function()
			context.toggleMinimized()
		end)

		window:GetPropertyChangedSignal("Position"):Connect(function()
			if not isActiveToken() then
				return
			end

			local position = window.Position
			if CONFIG.windowOffsetX ~= position.X.Offset or CONFIG.windowOffsetY ~= position.Y.Offset then
				CONFIG.windowOffsetX = position.X.Offset
				CONFIG.windowOffsetY = position.Y.Offset
				saveSettings()
			end
		end)

		Players.PlayerAdded:Connect(function(player)
			hookCharacter(player)
			refreshAllEsp()
		end)

		Players.PlayerRemoving:Connect(function(player)
			clearPlayerEsp(player)
			espObjects[player] = nil
			miniHudLabels.utility.targetTelemetry[player] = nil
			if player == viewState.spectateTarget then
				setSpectateTarget(nil)
			end
			if player == viewState.lockedFocusTarget then
				viewState.lockedFocusTarget = nil
			end
			miniHudLabels.utility.killCredit[player] = nil
		end)

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LOCAL_PLAYER then
				hookCharacter(player)
			end
		end

		do
			local function updateFovCircleFromX(positionX)
				local bar = tracerSliders.fovCircleSlider.bar
				local relative = math.clamp(positionX - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
				local alpha = 0
				if bar.AbsoluteSize.X > 0 then
					alpha = relative / bar.AbsoluteSize.X
				end

				local value = math.floor(tracerSliders.fovCircleSlider.min + ((tracerSliders.fovCircleSlider.max - tracerSliders.fovCircleSlider.min) * alpha) + 0.5)
				value = math.clamp(value, tracerSliders.fovCircleSlider.min, tracerSliders.fovCircleSlider.max)

				if CONFIG.fovRadius ~= value then
					CONFIG.fovRadius = value
					updateCrosshair()
					saveSettings()
				end

				setSliderState(tracerSliders.fovCircleSlider, CONFIG.fovRadius)
			end

			bindSliderDragStart(tracerSliders.fovCircleSlider.bar, updateFovCircleFromX)
			bindSliderValueInput(tracerSliders.fovCircleSlider, function(typedValue)
				if typedValue == nil then
					return CONFIG.fovRadius
				end
				return math.clamp(math.floor(typedValue + 0.5), tracerSliders.fovCircleSlider.min, tracerSliders.fovCircleSlider.max)
			end, function(nextValue)
				if CONFIG.fovRadius ~= nextValue then
					CONFIG.fovRadius = nextValue
					updateCrosshair()
					saveSettings()
				end
			end)
		end

		do
			local function updateCameraFovFromX(positionX)
				local bar = miniHudLabels.utility.controls.cameraFovSlider.bar
				local relative = math.clamp(positionX - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
				local alpha = 0
				if bar.AbsoluteSize.X > 0 then
					alpha = relative / bar.AbsoluteSize.X
				end

				local value = math.floor(miniHudLabels.utility.controls.cameraFovSlider.min + ((miniHudLabels.utility.controls.cameraFovSlider.max - miniHudLabels.utility.controls.cameraFovSlider.min) * alpha) + 0.5)
				value = math.clamp(value, miniHudLabels.utility.controls.cameraFovSlider.min, miniHudLabels.utility.controls.cameraFovSlider.max)

				if CONFIG.cameraFov ~= value then
					CONFIG.cameraFov = value
					applyCameraFov()
					saveSettings()
				end

				setSliderState(miniHudLabels.utility.controls.cameraFovSlider, CONFIG.cameraFov)
			end

			bindSliderDragStart(miniHudLabels.utility.controls.cameraFovSlider.bar, updateCameraFovFromX)
			bindSliderValueInput(miniHudLabels.utility.controls.cameraFovSlider, function(typedValue)
				if typedValue == nil then
					return CONFIG.cameraFov
				end
				return math.clamp(math.floor(typedValue + 0.5), miniHudLabels.utility.controls.cameraFovSlider.min, miniHudLabels.utility.controls.cameraFovSlider.max)
			end, function(nextValue)
				if CONFIG.cameraFov ~= nextValue then
					CONFIG.cameraFov = nextValue
					applyCameraFov()
					saveSettings()
				end
			end)
		end

		do
			local draggingCombatSlider = nil

			local function updateTracerSlider(entry, positionX)
				local slider = entry.slider
				local bar = slider.bar
				local relative = math.clamp(positionX - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
				local alpha = 0
				if bar.AbsoluteSize.X > 0 then
					alpha = relative / bar.AbsoluteSize.X
				end

				local value = math.floor(slider.min + ((slider.max - slider.min) * alpha) + 0.5)
				value = math.clamp(value, slider.min, slider.max)

				if CONFIG[entry.key] ~= value then
					CONFIG[entry.key] = value
					saveSettings()
					if entry.refreshEsp then
						refreshAllEsp()
					end
					if entry.refreshCrosshair then
						updateCrosshair()
					end
				end

				setSliderState(slider, CONFIG[entry.key])
			end

			for _, entry in ipairs({
				{ slider = tracerSliders.thickness, key = "tracerThickness", refreshEsp = true },
				{ slider = tracerSliders.transparency, key = "tracerTransparency", refreshEsp = true },
				{ slider = tracerSliders.maxDistance, key = "maxDistance", refreshEsp = true },
				{ slider = tracerSliders.fovThickness, key = "fovCircleThickness", refreshCrosshair = true },
				{ slider = tracerSliders.fovTransparency, key = "fovCircleTransparency", refreshCrosshair = true },
				{ slider = tracerSliders.crosshairThickness, key = "crosshairThickness", refreshCrosshair = true },
				{ slider = tracerSliders.crosshairGap, key = "crosshairGap", refreshCrosshair = true },
			}) do
				bindSliderDragStart(entry.slider.bar, function(positionX)
					draggingCombatSlider = entry
					updateTracerSlider(draggingCombatSlider, positionX)
				end, function()
					draggingCombatSlider = nil
				end)
			end

			for _, entry in ipairs({
				{ slider = tracerSliders.thickness, key = "tracerThickness", onChange = refreshAllEsp },
				{ slider = tracerSliders.transparency, key = "tracerTransparency", onChange = refreshAllEsp },
				{ slider = tracerSliders.maxDistance, key = "maxDistance", onChange = refreshAllEsp },
				{ slider = tracerSliders.fovThickness, key = "fovCircleThickness", onChange = updateCrosshair },
				{ slider = tracerSliders.fovTransparency, key = "fovCircleTransparency", onChange = updateCrosshair },
				{ slider = tracerSliders.crosshairThickness, key = "crosshairThickness", onChange = updateCrosshair },
				{ slider = tracerSliders.crosshairGap, key = "crosshairGap", onChange = updateCrosshair },
			}) do
				bindSliderValueInput(entry.slider, function(typedValue)
					if typedValue == nil then
						return CONFIG[entry.key]
					end
					return math.clamp(math.floor(typedValue + 0.5), entry.slider.min, entry.slider.max)
				end, function(nextValue)
					if CONFIG[entry.key] ~= nextValue then
						CONFIG[entry.key] = nextValue
						saveSettings()
						entry.onChange()
					end
				end)
			end
		end

		do
			local function updateFreeCamSpeedFromX(positionX)
				local bar = viewButtons.speed.bar
				local relative = math.clamp(positionX - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
				local alpha = 0
				if bar.AbsoluteSize.X > 0 then
					alpha = relative / bar.AbsoluteSize.X
				end
				local value = math.floor(viewButtons.speed.min + ((viewButtons.speed.max - viewButtons.speed.min) * alpha) + 0.5)
				value = math.clamp(value, viewButtons.speed.min, viewButtons.speed.max)

				if CONFIG.freeCamSpeed ~= value then
					CONFIG.freeCamSpeed = value
					saveSettings()
				end

				setSliderState(viewButtons.speed, CONFIG.freeCamSpeed)
			end

			bindSliderDragStart(viewButtons.speed.bar, updateFreeCamSpeedFromX)
			bindSliderValueInput(viewButtons.speed, function(typedValue)
				if typedValue == nil then
					return CONFIG.freeCamSpeed
				end
				return math.clamp(math.floor(typedValue + 0.5), viewButtons.speed.min, viewButtons.speed.max)
			end, function(nextValue)
				if CONFIG.freeCamSpeed ~= nextValue then
					CONFIG.freeCamSpeed = nextValue
					saveSettings()
				end
			end)
		end

		do
			local draggingPlayerSlider = nil

			local function updatePlayerSlider(entry, positionX)
				local slider = entry.slider
				local bar = slider.bar
				local relative = math.clamp(positionX - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
				local alpha = 0
				if bar.AbsoluteSize.X > 0 then
					alpha = relative / bar.AbsoluteSize.X
				end
				local value = math.floor(slider.min + ((slider.max - slider.min) * alpha) + 0.5)
				value = math.clamp(value, slider.min, slider.max)

				if CONFIG[entry.key] ~= value then
					CONFIG[entry.key] = value
					saveSettings()
					applyPlayerMovementState()
					updateViewUi()
				end

				setSliderState(slider, CONFIG[entry.key])
			end

			for _, entry in ipairs({
				{ slider = playerButtons.walkSpeed, key = "walkSpeed" },
				{ slider = playerButtons.flySpeed, key = "flySpeed" },
			}) do
				bindSliderDragStart(entry.slider.bar, function(positionX)
					draggingPlayerSlider = entry
					updatePlayerSlider(draggingPlayerSlider, positionX)
				end, function()
					draggingPlayerSlider = nil
				end)

				bindSliderValueInput(entry.slider, function(typedValue)
					if typedValue == nil then
						return CONFIG[entry.key]
					end
					return math.clamp(math.floor(typedValue + 0.5), entry.slider.min, entry.slider.max)
				end, function(nextValue)
					if CONFIG[entry.key] ~= nextValue then
						CONFIG[entry.key] = nextValue
						saveSettings()
						applyPlayerMovementState()
						updateViewUi()
					end
				end)
			end
		end

		UserInputService.JumpRequest:Connect(function()
			if not isActiveToken() then
				return
			end
			if not CONFIG.infiniteJump or viewState.freeCamEnabled then
				return
			end
			local humanoid = getLocalHumanoid()
			if not humanoid or humanoid.Health <= 0 then
				return
			end
			local state = humanoid:GetState()
			if state == Enum.HumanoidStateType.Dead or state == Enum.HumanoidStateType.Seated then
				return
			end
			humanoid.Jump = true
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end)

		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not isActiveToken() then
				return
			end

			local inputIsMouseButton = input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.MouseButton2
				or input.UserInputType == Enum.UserInputType.MouseButton3
			local allowMouseKeybindInput = not window.Visible
			local keybindController = getKeybindController()

			if keybindController and (not inputIsMouseButton or allowMouseKeybindInput) and keybindController.handleInput(input) then
				return
			end

			if gameProcessed then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local trainer = ensureTrainerState()
				if trainer then
					trainer.spreadValue = math.min(36, trainer.spreadValue + 7)
					trainer.recoilKick = math.min(18, trainer.recoilKick + 6)
					trainer.recoilOffset = trainer.recoilOffset + Vector2.new(math.random(-4, 4), -math.random(4, 10))
				end
			end

			if CONFIG.clickTeleport and input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				local root = getLocalRoot()
				local mouse = LOCAL_PLAYER and LOCAL_PLAYER:GetMouse()
				if root and mouse and mouse.Hit then
					root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
					showToast("Player", "Teleported", THEME.accent)
					return
				end
			end

			if CONFIG.aimTrainerMode and CONFIG.trainerDrillType == "Click" and input.UserInputType == Enum.UserInputType.MouseButton1 then
				local trainer = ensureTrainerState()
				local clickPosition = getMouseScreenPosition(getCamera())
				if trainer and trainer.targetPosition and clickPosition then
					if (clickPosition - trainer.targetPosition).Magnitude <= CONFIG.trainerHitWindow then
						if trainer.targetSpawnAt and trainer.targetSpawnAt > 0 then
							recordTrainerClickSuccess(math.floor((tick() - trainer.targetSpawnAt) * 1000 + 0.5))
						end
						spawnTrainerTarget()
					else
						recordTrainerClickMiss()
					end
				end
			end

			if viewState.freeCamEnabled or CONFIG.fly then
				if input.UserInputType == Enum.UserInputType.MouseButton2 then
					if viewState.freeCamEnabled then
						viewState.lookHeld = true
						UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
					end
				elseif input.KeyCode == Enum.KeyCode.W then
					viewState.moveForward = 1
				elseif input.KeyCode == Enum.KeyCode.S then
					viewState.moveForward = -1
				elseif input.KeyCode == Enum.KeyCode.D then
					viewState.moveRight = 1
				elseif input.KeyCode == Enum.KeyCode.A then
					viewState.moveRight = -1
				elseif input.KeyCode == Enum.KeyCode.Space then
					viewState.moveUp = 1
				elseif input.KeyCode == Enum.KeyCode.LeftControl then
					viewState.moveUp = -1
				elseif input.KeyCode == Enum.KeyCode.Escape and viewState.freeCamEnabled then
					toggleFreeCam()
					return
				end
			end

			if input.KeyCode == CONFIG.quickHideKey then
				window.Visible = not window.Visible
				watermark.Visible = context.isUiReady() and window.Visible and not CONFIG.minimalMode
				miniHud.Visible = context.isUiReady() and window.Visible and CONFIG.showMiniHud
				showToast("Menu", window.Visible and "Menu shown" or "Menu hidden", window.Visible and THEME.accent or THEME.muted)
			elseif input.KeyCode == CONFIG.uiToggleKey then
				gui.Enabled = not gui.Enabled
				if not gui.Enabled then
					hideCrosshair()
				end
				if keybindController then
					keybindController.update()
				end
				updateMouseIconVisibility()
			elseif input.KeyCode == CONFIG.espToggleKey then
				setEspEnabled(not CONFIG.enabled)
			elseif input.KeyCode == CONFIG.panicKey then
				setEspEnabled(false)
				gui.Enabled = false
				hideCrosshair()
				if keybindController then
					keybindController.update()
				end
				updateMouseIconVisibility()
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if not isActiveToken() then
				return
			end

			local inputIsMouseButton = input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.MouseButton2
				or input.UserInputType == Enum.UserInputType.MouseButton3
			local allowMouseKeybindInput = not window.Visible
			local keybindController = getKeybindController()

			if keybindController and keybindController.handleInputEnded and (not inputIsMouseButton or allowMouseKeybindInput) then
				keybindController.handleInputEnded(input)
			end

			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				viewState.lookHeld = false
				if viewState.freeCamEnabled then
					UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				end
			elseif input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S then
				viewState.moveForward = 0
			elseif input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.A then
				viewState.moveRight = 0
			elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftControl then
				viewState.moveUp = 0
			end
		end)

		local updateAccumulator = 0
		local frameTaskErrorCounts = {}

		RunService.RenderStepped:Connect(function(deltaTime)
			if not isActiveToken() then
				return
			end

			if deltaTime > 0 then
				local currentFps = context.getCurrentFps()
				currentFps = (currentFps == 0) and (1 / deltaTime) or (currentFps * 0.85 + (1 / deltaTime) * 0.15)
				context.setCurrentFps(currentFps)
			end

			local camera = getCamera()
			if viewState.freeCamEnabled and camera then
				setLocalMovementSuppressed(true)
				if viewState.lookHeld then
					local mouseDelta = UserInputService:GetMouseDelta()
					viewState.freeCamYaw = viewState.freeCamYaw - (mouseDelta.X * 0.0025)
					viewState.freeCamPitch = math.clamp(viewState.freeCamPitch - (mouseDelta.Y * 0.0025), -1.45, 1.45)
				end

				local rotation = CFrame.Angles(0, viewState.freeCamYaw, 0) * CFrame.Angles(viewState.freeCamPitch, 0, 0)
				local movement = Vector3.new(viewState.moveRight, viewState.moveUp, -viewState.moveForward)
				if movement.Magnitude > 1 then
					movement = movement.Unit
				end

				local speed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and (CONFIG.freeCamSpeed * 1.67) or CONFIG.freeCamSpeed
				local position = viewState.freeCamCFrame and viewState.freeCamCFrame.Position or camera.CFrame.Position
				position = position + rotation:VectorToWorldSpace(movement) * speed * deltaTime
				viewState.freeCamCFrame = CFrame.new(position) * rotation
				camera.CameraType = Enum.CameraType.Scriptable
				camera.CFrame = viewState.freeCamCFrame
			elseif CONFIG.fly and camera then
				local root = getLocalRoot()
				local humanoid = getLocalHumanoid()
				if root and humanoid and humanoid.Health > 0 then
					local forward = camera.CFrame.LookVector
					if forward.Magnitude < 0.001 then
						forward = root.CFrame.LookVector
					end
					forward = forward.Unit

					local right = camera.CFrame.RightVector
					if right.Magnitude < 0.001 then
						right = root.CFrame.RightVector
					end
					right = right.Unit

					local inputVelocity = (right * viewState.moveRight) + (Vector3.yAxis * viewState.moveUp) + (forward * viewState.moveForward)
					if inputVelocity.Magnitude > 1 then
						inputVelocity = inputVelocity.Unit
					end

					local speedMultiplier = 1
					if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
						speedMultiplier = context.FLY_BOOST_MULTIPLIER or 1.75
					elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
						speedMultiplier = context.FLY_PRECISION_MULTIPLIER or 0.35
					end

					local targetVelocity = inputVelocity * (CONFIG.flySpeed * speedMultiplier)
					local currentVelocity = viewState.flyVelocity or root.AssemblyLinearVelocity
					local blendSpeed = targetVelocity.Magnitude > currentVelocity.Magnitude and (context.FLY_ACCELERATION or 10) or (context.FLY_DECELERATION or 14)
					local alpha = math.clamp(deltaTime * blendSpeed, 0, 1)
					local blendedVelocity = currentVelocity:Lerp(targetVelocity, alpha)
					if targetVelocity.Magnitude < 0.01 and blendedVelocity.Magnitude < 1 then
						blendedVelocity = Vector3.zero
					end

					viewState.flyVelocity = blendedVelocity
					root.AssemblyLinearVelocity = blendedVelocity
					root.AssemblyAngularVelocity = Vector3.zero
					humanoid:ChangeState(Enum.HumanoidStateType.Physics)
					humanoid.PlatformStand = false
					humanoid.AutoRotate = false

					local visualDirection = blendedVelocity
					if visualDirection.Magnitude > 0.05 then
						viewState.flyLookVector = visualDirection.Unit
					else
						viewState.flyLookVector = forward
					end

					if viewState.flyLookVector and viewState.flyLookVector.Magnitude > 0.05 then
						local targetCFrame = CFrame.lookAt(root.Position, root.Position + viewState.flyLookVector, Vector3.yAxis)
						root.CFrame = root.CFrame:Lerp(targetCFrame, math.clamp(deltaTime * 14, 0, 1))
					end
				end
			elseif viewState.spectateTarget then
				local targetCharacter = viewState.spectateTarget.Character
				local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
				if targetHumanoid then
					if camera and (camera.CameraType ~= Enum.CameraType.Custom or camera.CameraSubject ~= targetHumanoid) then
						camera.CameraType = Enum.CameraType.Custom
						camera.CameraSubject = targetHumanoid
					end
				else
					setSpectateTarget(nil)
				end
			end

			if not CONFIG.fly and not viewState.freeCamEnabled then
				setLocalMovementSuppressed(false)
				applyPlayerMovementState()
			end

			runSafeFrameTask(frameTaskErrorCounts, "applyCameraFov", applyCameraFov)
			runSafeFrameTask(frameTaskErrorCounts, "applyPerformanceSettings", applyPerformanceSettings)
			if gui.Enabled then
				runSafeFrameTask(frameTaskErrorCounts, "updateCrosshair", updateCrosshair)
			else
				hideCrosshair()
			end
			runSafeFrameTask(frameTaskErrorCounts, "updateTrainerVisuals", updateTrainerVisuals, deltaTime)
			runSafeFrameTask(frameTaskErrorCounts, "updateViewUi", updateViewUi)
			runSafeFrameTask(frameTaskErrorCounts, "updateMouseIconVisibility", updateMouseIconVisibility)
			runSafeFrameTask(frameTaskErrorCounts, "updatePerfStatsUi", context.updatePerfStatsUi)
			updateAccumulator = updateAccumulator + deltaTime
			if updateAccumulator >= espRuntimeState.updateInterval then
				updateAccumulator = 0
				runSafeFrameTask(frameTaskErrorCounts, "refreshAllEsp", refreshAllEsp)
			end
		end)
	end

	return {
		setup = setup,
	}
end
