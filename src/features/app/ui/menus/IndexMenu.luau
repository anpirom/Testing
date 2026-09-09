local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local useDataState = require(ReplicatedStorage.Source.Core.UI.Hooks.useDataState)
local Button = require(ReplicatedStorage.Source.Core.UI.Primitives.Button)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local StudButton = require(ReplicatedStorage.Source.Features.App.UI.Components.StudButton)
local Menu = require(ReplicatedStorage.Source.Features.App.UI.Menus.Menu)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local ItemIcon = require(ReplicatedStorage.Source.Features.Inventory.UI.Components.ItemIcon)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local Tiers = require(ReplicatedStorage.Source.Game.Items.Tiers)
local e = React.createElement

local towerTierAtom = Charm.atom("normal")

type TowerIndexProps = {
	towerId: string,
	towerInfo: Towers.TowerInfo,
}

local function TowerIndex(props: TowerIndexProps)
	local towerTier = ReactCharm.useAtom(towerTierAtom)
	local unlocked = useDataState("towerIndex")[towerTier][props.towerId] ~= nil
	local tier = Tiers.getTierForOdds(props.towerInfo.odds)

	return e(Button, {
		hoverScale = 1.1,
		LayoutOrder = props.towerInfo.layoutOrder,
		BackgroundTransparency = 1,
	}, {
		Icon = e(ItemIcon, {
			ImageColor3 = if unlocked then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(0, 0, 0),
			Size = UDim2.fromScale(1, 1),
			itemData = {
				itemId = props.towerId,
				level = 1,
				mutations = {
					gold = towerTier == "gold",
					diamond = towerTier == "diamond",
				},
			},
			equipped = true,
			showStrength = false,
		}, {
			TowerName = e(TextLabel, {
				Text = if not unlocked then "???" else props.towerInfo.name,
				Size = UDim2.fromScale(0.9, 0.175),
				Position = UDim2.fromScale(0.5, 0.975),
				AnchorPoint = Vector2.new(0.5, 1),
				Stroke = { Thickness = 2 },
				ZIndex = 2,
			}),

			Rarity = e(TextLabel, {
				Text = tier.name,
				Size = UDim2.fromScale(0.9, 0.2),
				Position = UDim2.fromScale(0.5, 0.7),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Stroke = { Thickness = 2 },
				Gradient = {
					Color = tier.gradient,
					Rotation = 90,
				},
			}),
		}),
	})
end

local function AllTowers()
	return Sift.Dictionary.map(Towers.towers, function(towerInfo: Towers.TowerInfo, towerId: string)
		if towerInfo.isLuckyBlock then
			return nil
		end
		return e(TowerIndex, {
			towerId = towerId,
			towerInfo = towerInfo,
		})
	end)
end

return function()
	return e(Menu.Component, {
		menuName = "IndexMenu",
		Title = "Index",
		From = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromOffset(600, 530),
		Prefix = {
			Image = ImageIds.index,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		},
	}, {
		SideButtons = e("Frame", {
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.fromScale(1.05, 0),
			Size = UDim2.fromOffset(160, 400),
			BackgroundTransparency = 1,
		}, {
			Layout = e("UIListLayout", {
				Padding = UDim.new(0, 10),
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			Normal = e(StudButton.White, {
				Size = UDim2.fromOffset(160, 50),
				Text = "NORMAL",
				LayoutOrder = 1,
				Activated = function()
					towerTierAtom("normal")
				end,
			}),

			Gold = e(StudButton.Gold, {
				Size = UDim2.fromOffset(160, 50),
				Text = "GOLD",
				LayoutOrder = 2,
				Activated = function()
					towerTierAtom("gold")
				end,
			}),

			Diamond = e(StudButton.Teal, {
				Size = UDim2.fromOffset(160, 50),
				Text = "DIAMOND",
				LayoutOrder = 3,
				Activated = function()
					towerTierAtom("diamond")
				end,
			}),
		}),

		ScrollingFrame = e("ScrollingFrame", {
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 1),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			ScrollBarThickness = 0,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			BorderSizePixel = 0,
			CanvasSize = UDim2.fromOffset(0, 0),
		}, {
			Padding = e("UIPadding", {
				PaddingTop = UDim.new(0, 20),
				PaddingBottom = UDim.new(0, 20),
				PaddingLeft = UDim.new(0, 20),
				PaddingRight = UDim.new(0, 20),
			}),

			GridLayout = e("UIGridLayout", {
				CellSize = UDim2.fromOffset(120, 120),
				CellPadding = UDim2.fromOffset(10, 10),
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		}, e(AllTowers)),
	})
end
