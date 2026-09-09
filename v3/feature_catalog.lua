return function()
    return {
        categories = {
            visuals = {
                "enabled", "showNames", "showDistance", "distanceFade", "showHealth", "showWeapon",
                "showSkeleton", "showHeadDot", "headDotSize", "showFocusTarget", "showBoxes", "boxMode",
                "fillTransparency", "outlineTransparency", "maxDistance", "visibleColor", "hiddenColor", "fallbackEspColor",
            },
            targeting = {
                "threatMode", "focusLock", "visibilityCheck", "showTargetCard", "targetCardCompact",
                "spectateMode", "showLookDirection", "textStackMode",
            },
            tracers = {
                "showTracers", "tracerOriginMode", "tracerThickness", "tracerTransparency", "tracerStyle",
            },
            crosshair = {
                "showCrosshair", "showFovCircle", "crosshairStyle", "crosshairColor", "crosshairSize",
                "crosshairThickness", "crosshairGap", "fovRadius", "fovCircleThickness", "fovCircleTransparency",
            },
            trainer = {
                "aimTrainerMode", "trainerDrillType", "trainerReactionTimer", "trainerHitWindow",
                "trainerChallengeMode", "trainerChallengeDuration", "trainerShrinkingTargets",
                "trainerTrackHoldTime", "trainerTargetSpeed", "recoilVisualizer", "spreadVisualizer",
            },
            camera = {
                "cameraFov", "freeCamSpeed", "removeZoomLimit", "cameraRigPreset",
            },
            movement = {
                "walkSpeedEnabled", "walkSpeed", "infiniteJump", "noclip", "fly", "flySpeed", "clickTeleport",
            },
            interface = {
                "minimalMode", "showMiniHud", "keybindsEnabled", "showKeybindsUi", "autoLoadGamePreset",
                "windowOffsetX", "windowOffsetY", "miniHudOffsetX", "miniHudOffsetY",
                "keybindPanelOffsetX", "keybindPanelOffsetY", "targetCardOffsetX", "targetCardOffsetY",
            },
            performance = {
                "performanceMode", "simplifyMaterials", "hideTextures", "hideEffects", "disableShadows", "antiAfk",
            },
        },
        choices = {
            threatMode = { "Closest", "Visible", "Armed", "Smart" },
            boxMode = { "Chams", "Flat Chams", "Outline Chams", "Split Chams", "2D Box", "Health Box", "Corner Box", "Head Box", "3D Box" },
            tracerOriginMode = { "Bottom", "Center", "Mouse" },
            tracerStyle = { "Direct", "Elbow" },
            crosshairStyle = { "Cross", "Dot", "Circle" },
            crosshairColor = { "White", "Red", "Green", "Blue", "Pink", "Yellow", "Cyan" },
            trainerDrillType = { "Click", "Track" },
            textStackMode = { "Inline", "Stacked" },
            spectateMode = { "Direct", "Smooth" },
            cameraRigPreset = { "Low", "Mid", "High" },
        },
        aliases = {
            esp = "enabled",
            names = "showNames",
            distance = "showDistance",
            health = "showHealth",
            weapon = "showWeapon",
            skeleton = "showSkeleton",
            head = "showHeadDot",
            boxes = "showBoxes",
            box = "boxMode",
            focus = "focusLock",
            visibility = "visibilityCheck",
            tracers = "showTracers",
            crosshair = "showCrosshair",
            fovcircle = "showFovCircle",
            trainer = "aimTrainerMode",
            recoil = "recoilVisualizer",
            spread = "spreadVisualizer",
            zoomlimit = "removeZoomLimit",
            walkspeed = "walkSpeed",
            speed = "walkSpeed",
            jump = "infiniteJump",
            mini = "showMiniHud",
            look = "showLookDirection",
            afk = "antiAfk",
            perf = "performanceMode",
            targetcard = "showTargetCard",
        },
    }
end
