local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Ripple = require(ReplicatedStorage.Packages.Ripple)
local SoundController = require(ReplicatedStorage.Source.Core.Platform.SoundController)
local VfxUtils = require(ReplicatedStorage.Source.Core.Platform.VfxUtils)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local TowerBillboardGui = require(ReplicatedStorage.Source.Features.Defense.UI.Screens.TowerBillboardGui)
local PlotServiceUtils = require(ReplicatedStorage.Source.Features.Plots.PlotServiceUtils)
local Sounds = require(ReplicatedStorage.Source.Game.Assets.Sounds)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

local IMPULSE_STRENGTH = 10

return function(nodeCf: CFrame, model: Model, towerData: DataTemplate.TowerData): ()
	local janitor = Janitor.new()
	local originalCf = model:GetPivot()
	local heightSpring = Ripple.createSpring(0, { dampingRatio = 0.7, frequency = 1, start = true })
	local rotX = Ripple.createSpring(0, { dampingRatio = 0.2, frequency = 3.5, start = true })
	local rotZ = Ripple.createSpring(0, { dampingRatio = 0.2, frequency = 3.5, start = true })
	local size = Ripple.createSpring(1, { dampingRatio = 0.4, frequency = 2, start = true })
	janitor:Add(heightSpring, "destroy")
	janitor:Add(rotX, "destroy")
	janitor:Add(rotZ, "destroy")
	janitor:Add(size, "destroy")
	rotX:setGoal(0)
	rotZ:setGoal(0)
	heightSpring:setGoal(4)
	local hasReachPeakTransparency = false
	SoundController:Play(Sounds.misc.crateUnlock)

	local function update()
		local height = heightSpring:getPosition()
		local angle = CFrame.Angles(rotX:getPosition(), 0, rotZ:getPosition())
		local cf = originalCf * CFrame.new(0, height, 0) * angle
		model:PivotTo(cf)
		model:ScaleTo(size:getPosition())

		if hasReachPeakTransparency then
			return
		end

		local transparency = math.clamp(size:getPosition() - 1, 0, 1)
		if transparency >= 1 then
			hasReachPeakTransparency = true
		end
		for _, part in model:GetDescendants() do
			if part:IsA("BasePart") then
				part.Color = part.Color:Lerp(Color3.new(1, 1, 1), transparency / 2)
				part.Transparency = transparency
			end
		end
	end

	heightSpring:onChange(update)
	rotX:onChange(update)
	rotZ:onChange(update)

	task.delay(0.5, function()
		SoundController:Play(Sounds.misc.crateCharge)
	end)

	task.delay(0.67, function()
		size:setGoal(0.6, { dampingRatio = 0.9, frequency = 0.3, start = true })
		task.wait(2)
		size:setGoal(2, { dampingRatio = 0.4, frequency = 2, start = true })
	end)

	task.delay(2.75, function()
		local towerModel = Towers.getTowerModel(towerData.itemId, towerData.mutations)
		local gui = TowerBillboardGui.new(towerData)
		gui.Parent = towerModel.PrimaryPart
		towerModel:PivotTo(model:GetPivot())
		towerModel:ScaleTo(0.001)
		towerModel.Parent = workspace
		VfxUtils.emitAllAtPosition("CrateOpen", model:GetPivot().Position)
		SoundController:Play(Sounds.misc.rollEnd)

		local towerCf = Ripple.createSpring(towerModel:GetPivot(), { dampingRatio = 1, frequency = 2, start = true })
		towerCf:setGoal(nodeCf * CFrame.new(0, 0.5, 0))
		local towerScale = Ripple.createSpring(0.001, { dampingRatio = 0.5, frequency = 2, start = true })
		towerScale:setGoal(PlotServiceUtils.getScaleFromLevel(towerData.level))

		towerCf:onChange(function(v)
			towerModel:PivotTo(v)
		end)

		towerScale:onChange(function(v)
			towerModel:ScaleTo(v)
		end)

		janitor:Add(towerCf, "destroy")
		janitor:Add(towerScale, "destroy")
		janitor:Add(towerModel)
	end)

	local function jiggle(strength: number)
		local angle = math.random() * math.pi * 2
		local x, z = math.cos(angle), math.sin(angle)
		rotX:impulse(IMPULSE_STRENGTH * x * strength)
		rotZ:impulse(IMPULSE_STRENGTH * z * strength)
	end

	task.wait(0.1)

	for i = 1, 10, 1 do
		task.wait(0.25)
		jiggle(math.max(i / 10, 0.5))
	end

	task.wait(2)
	janitor:Destroy()
end
