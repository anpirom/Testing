local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local TowerBillboardGui = require(ReplicatedStorage.Source.Features.Defense.UI.Screens.TowerBillboardGui)
local PlotServiceUtils = require(ReplicatedStorage.Source.Features.Plots.PlotServiceUtils)
local PlotSlice = require(ReplicatedStorage.Source.Features.Plots.PlotSlice)
local EnemyClient = require(script.Parent.EnemyClient)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local TowerClient = {}
TowerClient.__index = TowerClient

type TowerData = DataTemplate.TowerData

export type TowerClient = typeof(setmetatable(
	{} :: {
		floor: number,
		node: number,
		data: TowerData,
		cf: CFrame,
		model: Model & any,
		attackAnim: any,
		janitor: Janitor.Janitor,
		gui: TowerBillboardGui.TowerGui,
		damageMult: number,
		bestDps: number,
	},
	TowerClient
))

function TowerClient.new(
	floor: number,
	node: number,
	cf: CFrame,
	data: TowerData,
	damageMult: number,
	bestDps: number
): TowerClient
	local self = setmetatable({
		floor = floor,
		node = node,
		data = data,
		cf = cf,
		janitor = Janitor.new(),
		damageMult = damageMult,
		bestDps = bestDps,
	}, TowerClient)

	self:loadModel()
	local attackAnimModule = script.Parent.Parent.TowerAnimations:FindFirstChild(data.itemId)
	if attackAnimModule then
		self.attackAnim = require(attackAnimModule)
	end

	return self
end

function TowerClient.loadModel(self: TowerClient)
	local model = Towers.getTowerModel(self.data.itemId, self.data.mutations)
	model.Parent = workspace
	model:PivotTo(self.cf * CFrame.new(0, 0.5, 0))
	self.model = model
	self.model:ScaleTo(PlotServiceUtils.getScaleFromLevel(self.data.level))
	local gui = TowerBillboardGui.new(self.data, self.damageMult, self.bestDps)
	gui.Parent = model.PrimaryPart
	self.gui = gui
	self:charFloorChanged()

	self.janitor:Add(Charm.subscribe(PlotSlice.states.characterFloor, function()
		self:charFloorChanged()
	end))
end

function TowerClient.setDamageMult(self: TowerClient, damageMult: number): ()
	self.damageMult = damageMult
	TowerBillboardGui.update(self.gui, self.data, damageMult, self.bestDps)
end

function TowerClient.charFloorChanged(self: TowerClient)
	local floor = PlotSlice.states.characterFloor()
	local visible = floor == self.floor
	self.gui.Enabled = visible
	for _, part in self.model:GetDescendants() do
		if part:IsA("BasePart") then
			local originalCastShadow = part:GetAttribute("OriginalCastShadow")
			if originalCastShadow == nil then
				part:SetAttribute("OriginalCastShadow", part.CastShadow)
			end
			part.CastShadow = originalCastShadow and visible
		end
	end
end

function TowerClient.setBestDps(self: TowerClient, bestDps: number): ()
	self.bestDps = bestDps
	TowerBillboardGui.update(self.gui, self.data, self.damageMult, self.bestDps)
end

function TowerClient.setData(self: TowerClient, data: TowerData): ()
	self.data = data
	self.model:ScaleTo(PlotServiceUtils.getScaleFromLevel(data.level))
	TowerBillboardGui.update(self.gui, data, self.damageMult, self.bestDps)
end

function TowerClient.attack(self: TowerClient, enemy: EnemyClient.EnemyClient, damage: number): ()
	enemy:damage(damage)
	if self.attackAnim then
		self.attackAnim(self, enemy)
	end
end

function TowerClient.destroy(self: TowerClient): ()
	self.janitor:Destroy()
	if self.model then
		self.model:Destroy()
	end
end

return TowerClient
