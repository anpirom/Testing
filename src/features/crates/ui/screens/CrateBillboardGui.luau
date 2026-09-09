local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Abbreviate = require(ReplicatedStorage.Source.Core.UI.Abbreviate)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local Mutations = require(ReplicatedStorage.Source.Features.Mutations.Modules.Mutations)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local Tiers = require(ReplicatedStorage.Source.Game.Items.Tiers)

export type CrateGui = BillboardGui & {
	Rarity: TextLabel & {
		Gradient: UIGradient,
		Stroke: UIStroke,
	},
	CrateName: TextLabel & {
		Stroke: UIStroke,
	},
	Cost: TextLabel & {
		Stroke: UIStroke,
	},
	Mutations: Frame & {},
}

local CrateBillboardGui = {}

function CrateBillboardGui.new(crateData: DataTemplate.CrateData, hideCost: boolean?): CrateGui
	local gui = ReplicatedStorage.Assets.VFX.CrateBillboard:Clone()
	CrateBillboardGui.update(gui, crateData, hideCost)
	return gui
end

function CrateBillboardGui.update(gui: CrateGui, crateData: DataTemplate.CrateData, hideCost: boolean?): ()
	local info = Towers.getTowerInfo(crateData.crateId)
	local rarityTier = Tiers.getTierForOdds(info.odds)
	--gui.StudsOffsetWorldSpace = Vector3.new(0, info.height * scale, 0)
	local isLuckyBlock = info.isLuckyBlock
	gui.CrateName.Text = if isLuckyBlock then info.name else info.name .. " Crate"
	gui.Rarity.Text = rarityTier.name
	gui.Rarity.Gradient.Color = rarityTier.gradient
	gui.Cost.Text = `${Abbreviate(info.crateCost)}`
	gui.Cost.Visible = not hideCost
	for mutation, _ in Mutations.mutations do
		local hasMutation = crateData.mutations and crateData.mutations[mutation]
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

return CrateBillboardGui
