local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local Tiers = require(ReplicatedStorage.Source.Game.Items.Tiers)

local e = React.createElement
local EQUIPPED_TRANSPARENCY = NumberSequence.new(0)
local DEFAULT_TRANSPARENCY = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.5, 1),
	NumberSequenceKeypoint.new(1, 0),
})

type ItemButtonStrokeProps = {
	equipped: boolean?,
	partData: DataTemplate.ItemData,
}

return function(props: ItemButtonStrokeProps)
	local info = if props.partData.crateId
		then Towers.getTowerInfo(props.partData.crateId)
		else Towers.getTowerInfo(props.partData.itemId)
	local tier = Tiers.getTierForOdds(info.odds)

	return e("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Thickness = 2,
	}, {
		Gradient = e("UIGradient", {
			Color = tier.gradient,
			Rotation = 90,
			Transparency = if props.equipped then EQUIPPED_TRANSPARENCY else DEFAULT_TRANSPARENCY,
		}),
	})
end
