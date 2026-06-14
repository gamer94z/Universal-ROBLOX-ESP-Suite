return function(context)
	local CONFIG = context.CONFIG
	local Lighting = context.Lighting
	local workspace = context.workspace
	local performanceCache = context.performanceCache

	local function cacheLighting()
		if not performanceCache.lighting then
			performanceCache.lighting = {
				GlobalShadows = Lighting.GlobalShadows,
				FogEnd = Lighting.FogEnd,
				Brightness = Lighting.Brightness,
			}
		end
	end

	local function restorePartAppearance(part)
		local cached = performanceCache.parts[part]
		if cached and part.Parent then
			part.Material = cached.Material
			part.Reflectance = cached.Reflectance
		end
		performanceCache.parts[part] = nil
	end

	local function restoreTextureAppearance(item)
		local cached = performanceCache.textures[item]
		if cached and item.Parent then
			item.Transparency = cached.Transparency
		end
		performanceCache.textures[item] = nil
	end

	local function restoreEffectAppearance(item)
		local cached = performanceCache.effects[item]
		if cached and item.Parent and (item:IsA("ParticleEmitter") or item:IsA("Trail") or item:IsA("Beam") or item:IsA("Smoke") or item:IsA("Fire") or item:IsA("Sparkles")) then
			item.Enabled = cached.Enabled
		end
		performanceCache.effects[item] = nil
	end

	local function applyPerformanceSettings()
		local performanceRequested = CONFIG.performanceMode or CONFIG.simplifyMaterials or CONFIG.hideTextures or CONFIG.hideEffects or CONFIG.disableShadows
		local hasCachedChanges = performanceCache.lighting ~= nil
			or next(performanceCache.parts) ~= nil
			or next(performanceCache.textures) ~= nil
			or next(performanceCache.effects) ~= nil

		if CONFIG.performanceMode then
			CONFIG.simplifyMaterials = true
			CONFIG.hideTextures = true
			CONFIG.hideEffects = true
			CONFIG.disableShadows = true
		end

		if not performanceRequested and not hasCachedChanges then
			return
		end

		cacheLighting()

		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant:IsA("BasePart") then
				if CONFIG.simplifyMaterials then
					if not performanceCache.parts[descendant] then
						performanceCache.parts[descendant] = {
							Material = descendant.Material,
							Reflectance = descendant.Reflectance,
						}
					end
					descendant.Material = Enum.Material.SmoothPlastic
					descendant.Reflectance = 0
				else
					restorePartAppearance(descendant)
				end
			elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
				if CONFIG.hideTextures then
					if not performanceCache.textures[descendant] then
						performanceCache.textures[descendant] = {
							Transparency = descendant.Transparency,
						}
					end
					descendant.Transparency = 1
				else
					restoreTextureAppearance(descendant)
				end
			elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("Smoke") or descendant:IsA("Fire") or descendant:IsA("Sparkles") then
				if CONFIG.hideEffects then
					if not performanceCache.effects[descendant] then
						performanceCache.effects[descendant] = {
							Enabled = descendant.Enabled,
						}
					end
					descendant.Enabled = false
				end
			end
		end

		for item in pairs(performanceCache.parts) do
			if not item.Parent or not CONFIG.simplifyMaterials then
				restorePartAppearance(item)
			end
		end

		for item in pairs(performanceCache.textures) do
			if not item.Parent or not CONFIG.hideTextures then
				restoreTextureAppearance(item)
			end
		end

		for item, cached in pairs(performanceCache.effects) do
			if not item.Parent then
				performanceCache.effects[item] = nil
			elseif not CONFIG.hideEffects then
				item.Enabled = cached.Enabled
				performanceCache.effects[item] = nil
			end
		end

		if performanceCache.lighting then
			if CONFIG.disableShadows then
				Lighting.GlobalShadows = false
				Lighting.FogEnd = 100000
				Lighting.Brightness = math.max(Lighting.Brightness, 2)
			else
				Lighting.GlobalShadows = performanceCache.lighting.GlobalShadows
				Lighting.FogEnd = performanceCache.lighting.FogEnd
				Lighting.Brightness = performanceCache.lighting.Brightness
			end
		end
	end

	return {
		applyPerformanceSettings = applyPerformanceSettings,
	}
end
