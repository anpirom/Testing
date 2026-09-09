local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemButtonStroke = require(script.Parent.ItemButtonStroke)
local MutationIcons = require(script.Parent.MutationIcons)
local React = require(ReplicatedStorage.Packages.React)
local Abbreviate = require(ReplicatedStorage.Source.Core.UI.Abbreviate)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local useGamepass = require(ReplicatedStorage.Source.Features.Monetization.Hooks.useGamepass)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local PlotServiceUtils = require(ReplicatedStorage.Source.Features.Plots.PlotServiceUtils)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local e = React.createElement

type ItemIconProps = {
	Size: UDim2?,
	Rotation: number?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	ImageColor3: Color3?,
	itemData: DataTemplate.ItemData,
	children: React.ReactNode?,
	BackgroundTransparency: number?,
	BackgroundColor3: Color3?,
	equipped: boolean?,
	showStrength: boolean?,
	hideStroke: boolean?,
}

return function(props: ItemIconProps)
	local ownsDoubleDamage = useGamepass(Products.doubleDamage)
	local damageMult = if ownsDoubleDamage then 2 else 1
	local isTower = not props.itemData.crateId
	local info = if not isTower
		then Towers.getTowerInfo(props.itemData.crateId)
		else Towers.getTowerInfo(props.itemData.itemId)

	local iconSize = if isTower then UDim2.fromScale(1, 1) else UDim2.fromScale(0.9, 0.9)

	return e("Frame", {
		Size = props.Size,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		BackgroundTransparency = props.BackgroundTransparency or 0.2,
		BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(37, 38, 41),
		Rotation = props.Rotation,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0.1, 0),
		}),

		Icon = e("ImageLabel", {
			Image = if isTower then info.image else info.crateImage,
			Size = iconSize,
			ImageColor3 = props.ImageColor3 or Color3.fromRGB(255, 255, 255),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
		}),

		Background = e("ImageLabel", {
			Image = if isTower then info.image else info.crateImage,
			ImageTransparency = 0.7,
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			Size = iconSize,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.55),
			BackgroundTransparency = 1,
			ZIndex = 0,
		}),

		Quantity = if props.itemData.amt
			then e(TextLabel, {
				Text = "x" .. props.itemData.amt,
				AnchorPoint = Vector2.new(1, 1),
				TextXAlignment = Enum.TextXAlignment.Right,
				Position = UDim2.fromScale(0.95, 0.95),
				Size = UDim2.fromScale(0.66, 0.25),
				Stroke = {},
				ZIndex = 2,
			})
			else nil,

		Strength = if isTower and props.showStrength ~= false
			then e(TextLabel, {
				Text = if info.percentDamageOfBest
					then `💪 {math.round(info.percentDamageOfBest * 100)}%`
					else "💪 " .. Abbreviate(math.round(PlotServiceUtils.getDps(props.itemData) * damageMult)),
				AnchorPoint = Vector2.new(1, 1),
				TextXAlignment = Enum.TextXAlignment.Right,
				Position = UDim2.fromScale(0.95, 0.95),
				Size = UDim2.fromScale(0.9, 0.25),
				Stroke = {},
				ZIndex = 2,
				Gradient = {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 223, 93)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 121, 121)),
					}),
					Rotation = 90,
				},
			})
			else nil,

		Mutations = if props.itemData.mutations
			then e(MutationIcons, {
				mutations = props.itemData.mutations,
				Size = UDim2.fromScale(0.8, 0.2),
				Position = UDim2.fromScale(0.95, 0.05),
				AnchorPoint = Vector2.new(1, 0),
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				ZIndex = 3,
			})
			else nil,

		Fav = if props.itemData.fav
			then e("ImageLabel", {
				Image = ImageIds.heart,
				Size = UDim2.fromScale(0.25, 0.25),
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.fromScale(0.05, 0.2),
				BackgroundTransparency = 1,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				ZIndex = 3,
			})
			else nil,

		Stroke = if props.hideStroke
			then nil
			else e(ItemButtonStroke, { equipped = props.equipped, partData = props.itemData }),
	}, props.children)
end
