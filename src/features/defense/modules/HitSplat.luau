local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Ripple = require(ReplicatedStorage.Packages.Ripple)
local FormatCurrency = require(ReplicatedStorage.Source.Core.UI.FormatCurrency)

local DEFAULT_EMIT_COUNT = 10
local HitSplat = ReplicatedStorage.Assets.VFX.HitSplat
local cachedInstances = {}

type HitSplat = typeof(HitSplat)

return function(position: Vector3, primaryColor: Color3, currencyReward: number): ()
	local hitsplat: HitSplat = cachedInstances[#cachedInstances]
	if hitsplat then
		table.remove(cachedInstances, #cachedInstances)
	else
		hitsplat = HitSplat:Clone()
	end

	hitsplat.Position = position

	local h_p, s_p, v_p = Color3.toHSV(primaryColor)
	local primaryColorSequence = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHSV(h_p, s_p, v_p)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(h_p, s_p, v_p * 0.5)),
	})

	local h_s, s_s, v_s = Color3.toHSV(primaryColor)
	local secondaryColorSequence = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHSV(h_s, s_s * 0.7, v_s * 0.5)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(h_s, s_s * 0.7, v_s * 0.2)),
	})

	hitsplat.Primary.Color = primaryColorSequence
	hitsplat.Secondary.Color = secondaryColorSequence

	hitsplat.Parent = workspace
	hitsplat.Primary:Emit(DEFAULT_EMIT_COUNT)
	hitsplat.Secondary:Emit(DEFAULT_EMIT_COUNT)
	hitsplat.Coins:Play()
	hitsplat.Pop:Play()

	local gui = hitsplat.CurrencyRewardGui
	local textLabel = gui.TextLabel
	textLabel.Text = FormatCurrency(0)

	local spring = Ripple.createSpring(0, { dampingRatio = 0.4, frequency = 2.5, start = true })
	spring:setGoal(0.8)
	spring:onChange(function(v)
		textLabel.Size = UDim2.fromScale(1, v)
	end)

	local progress = 0
	local fadeOutProgress = 0
	local updateConn
	updateConn = RunService.Heartbeat:Connect(function(dt)
		if progress >= 1.3 then
			fadeOutProgress += dt * 3
			local transparency = math.clamp(fadeOutProgress, 0, 1)
			textLabel.TextTransparency = transparency
			textLabel.Stroke.Transparency = transparency
			if fadeOutProgress >= 1 then
				updateConn:Disconnect()
				updateConn = nil
			end
			return
		end

		progress += dt * 1.5
		local transparency = 1 - math.clamp(progress * 3, 0, 1)
		textLabel.TextTransparency = transparency
		textLabel.Stroke.Transparency = transparency

		local amt = math.lerp(0, currencyReward, progress)
		textLabel.Text = FormatCurrency(amt)

		if progress >= 1 then
			textLabel.Text = FormatCurrency(currencyReward)
		end
	end)

	task.delay(2, function()
		hitsplat.Parent = nil
		table.insert(cachedInstances, hitsplat)
		spring:destroy()
		if updateConn then
			updateConn:Disconnect()
			updateConn = nil
		end
	end)
end
