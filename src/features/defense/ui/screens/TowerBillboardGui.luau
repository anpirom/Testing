local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Abbreviate = require(ReplicatedStorage.Source.Core.UI.Abbreviate)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local Mutations = require(ReplicatedStorage.Source.Features.Mutations.Modules.Mutations)
local PlotServiceUtils = require(ReplicatedStorage.Source.Features.Plots.PlotServiceUtils)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local Tiers = require(ReplicatedStorage.Source.Game.Items.Tiers)

export type TowerGui = BillboardGui & {
	Dps: Frame & {
		TextLabel: TextLabel & {
			Gradient: UIGradient,
			Stroke: UIStroke,
		},
	},
	Rarity: Frame & {
		TextLabel: TextLabel & {
			Gradient: UIGradient,
			Stroke: UIStroke,
		},
	},
	TowerName: Frame & {
		TextLabel: TextLabel & {
			Stroke: UIStroke,
		},
	},
	Mutations: Frame & {},
}

local TowerBillboardGui = {}

function TowerBillboardGui.new(towerData: DataTemplate.TowerData, dmgMult: number?, bestDps: number?): TowerGui
	local gui = ReplicatedStorage.Assets.VFX.TowerBillboard:Clone()
	TowerBillboardGui.update(gui, towerData, dmgMult, bestDps)
	return gui
end

function TowerBillboardGui.update(
	gui: TowerGui,
	towerData: DataTemplate.TowerData,
	dmgMult: number?,
	bestDps: number?
): ()
	local info = Towers.getTowerInfo(towerData.itemId)
	local rarityTier = Tiers.getTierForOdds(info.odds)
	local scale = PlotServiceUtils.getScaleFromLevel(towerData.level)
	gui.StudsOffsetWorldSpace = Vector3.new(0, info.height * scale, 0)
	gui.TowerName.TextLabel.Text = info.name
	gui.Rarity.TextLabel.Text = rarityTier.name
	gui.Rarity.TextLabel.Gradient.Color = rarityTier.gradient
	if info.percentDamageOfBest and not bestDps then
		gui.Dps.TextLabel.Text = `💪 {math.round(info.percentDamageOfBest * 100)}% of Best`
	elseif info.percentDamageOfBest and bestDps then
		gui.Dps.TextLabel.Text = `💪 {Abbreviate(bestDps * info.percentDamageOfBest * (dmgMult or 1))}`
	else
		gui.Dps.TextLabel.Text = `💪 {Abbreviate(PlotServiceUtils.getDps(towerData) * (dmgMult or 1))}`
	end
	for mutation, _ in Mutations.mutations do
		local hasMutation = towerData.mutations and towerData.mutations[mutation]
		local mutationImg = gui.Mutations:FindFirstChild(mutation)
		if mutationImg and not hasMutation then
			mutationImg:Destroy()
		elseif not mutationImg and hasMutation then
			local img = Instance.new("ImageLabel")
			img.Name = mutation
			img.Size = UDim2.fromScale(1, 1)
			img.BackgroundTransparency = 1
			img.SizeConstraint = Enum.SizeConstraint.RelativeYY
			img.Image = ImageIds.mutations[mutation]
			img.Parent = gui.Mutations
		end
	end
end

return TowerBillboardGui
