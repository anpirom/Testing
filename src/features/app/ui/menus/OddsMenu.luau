local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Menu = require(script.Parent.Menu)
local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local InsetFrame = require(ReplicatedStorage.Source.Features.App.UI.Components.InsetFrame)
local StudButton = require(ReplicatedStorage.Source.Features.App.UI.Components.StudButton)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local ConveyorUpgrades = require(ReplicatedStorage.Source.Game.Items.ConveyorUpgrades)
local e = React.createElement

local selectedConveyor = Charm.atom(1)
local selectedCrate = Charm.atom("wooden")

local function ConveyorButton(props)
	local selectedIndex = ReactCharm.useAtom(selectedConveyor)
	local isSelected = selectedIndex == props.index
	return e(if isSelected then StudButton.Green else StudButton.White, {
		Size = UDim2.new(1, 0, 0, 60),
		LayoutOrder = props.index,
		Text = `Level {props.index}\nLuck: {ConveyorUpgrades[props.index].luck}`,
		Activated = function()
			selectedConveyor(props.index)
		end,
	})
end

local function ConveyorCrate(props)
	local info = Crates.getCrateInfo(props.index)
	local selectedIndex = ReactCharm.useAtom(selectedConveyor)
	local conveyorLuck = ConveyorUpgrades[selectedIndex].luck

	local chance = 0
	local usedUpChance = 0
	for i = #Crates.sortedCrates, 1, -1 do
		local crate = Crates.sortedCrates[i]
		local crateChance = math.clamp(1 - (1 - Crates.getCrateInfo(crate.id).odds) ^ conveyorLuck, 0, 1 - usedUpChance)
		if i == info.layoutOrder then
			chance = crateChance
		end
		usedUpChance += crateChance
	end

	return e(InsetFrame, {
		Size = UDim2.new(1, 0, 0, 80),
		LayoutOrder = math.round(10000 - chance * 10000),
	}, {
		Icon = e("ImageLabel", {
			Size = UDim2.fromOffset(64, 64),
			Position = UDim2.fromScale(0.05, 0.5),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Image = info.image,
		}),

		Odds = e(TextLabel, {
			Text = `{math.round(chance * 10000) / 100}%`,
			Size = UDim2.fromScale(0.5, 0.5),
			TextXAlignment = Enum.TextXAlignment.Right,
			Position = UDim2.fromScale(0.4, 0.25),
			AnchorPoint = Vector2.new(0, 0),
			Stroke = { Thickness = 2 },
		}),
	})
end

local function ConveyorsFrame()
	return e(InsetFrame, {
		Size = UDim2.fromScale(0.45, 0.9),
		Position = UDim2.fromScale(0.02, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),
	}, {
		Title = e(TextLabel, {
			Text = "Conveyors",
			Size = UDim2.new(1, 0, 0, 24),
			Position = UDim2.fromScale(0.5, 0.01),
			AnchorPoint = Vector2.new(0.5, 1),
			Stroke = { Thickness = 2 },
		}),

		ConveyorsSelector = e(
			"ScrollingFrame",
			{
				Size = UDim2.fromScale(0.4, 0.95),
				Position = UDim2.fromScale(0.04, 0.5),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0, 0.5),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				ScrollBarThickness = 0,
				BorderSizePixel = 0,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
			},
			{
				Layout = e("UIListLayout", {
					Padding = UDim.new(0, 10),
					FillDirection = Enum.FillDirection.Vertical,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				Padding = e("UIPadding", {
					PaddingTop = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
				}),
			},
			Sift.Dictionary.map(ConveyorUpgrades, function(upgradeData: any, index: number)
				return e(ConveyorButton, { upgradeData = upgradeData, index = index }), index
			end)
		),

		ConveyorCrates = e(
			"ScrollingFrame",
			{
				Size = UDim2.fromScale(0.5, 0.95),
				Position = UDim2.fromScale(0.96, 0.5),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0.5),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				ScrollBarThickness = 0,
				BorderSizePixel = 0,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
			},
			{
				Layout = e("UIListLayout", {
					Padding = UDim.new(0, 0),
					FillDirection = Enum.FillDirection.Vertical,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				Padding = e("UIPadding", {
					PaddingTop = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 1),
					PaddingRight = UDim.new(0, 1),
				}),
			},
			Sift.Dictionary.map(Crates.crates, function(data: any, index: number)
				return e(ConveyorCrate, { data = data, index = index }), index
			end)
		),
	})
end

local function CrateTower(props)
	local selectedIndex = ReactCharm.useAtom(selectedCrate)
	local towerInfo = Towers.getTowerInfo(props.index)
	local crateInfo = Crates.getCrateInfo(selectedIndex)
	local crateLuck = crateInfo.luck

	local chance = 0
	local usedUpChance = 0
	for i = #Towers.sortedTowers, 1, -1 do
		local tower = Towers.sortedTowers[i]
		local towerChance = math.clamp(1 - (1 - tower.odds) ^ crateLuck, 0, 1 - usedUpChance)
		if i == towerInfo.layoutOrder then
			chance = towerChance
		end
		usedUpChance += towerChance
	end

	return e(InsetFrame, {
		Size = UDim2.new(1, 0, 0, 80),
		LayoutOrder = math.round(10000 - chance * 10000),
	}, {
		Icon = e("ImageLabel", {
			Size = UDim2.fromOffset(64, 64),
			Position = UDim2.fromScale(0.05, 0.5),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Image = towerInfo.image,
		}),

		Name = e(TextLabel, {
			Text = towerInfo.name,
			Size = UDim2.fromScale(1, 0.2),
			Position = UDim2.fromScale(0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			Stroke = { Thickness = 2 },
		}),

		Odds = e(TextLabel, {
			Text = `{math.round(chance * 10000) / 100}%`,
			Size = UDim2.fromScale(0.5, 0.5),
			TextXAlignment = Enum.TextXAlignment.Right,
			Position = UDim2.fromScale(0.4, 0.75),
			AnchorPoint = Vector2.new(0, 1),
			Stroke = { Thickness = 2 },
		}),
	})
end

local function CrateButton(props)
	local selectedIndex = ReactCharm.useAtom(selectedCrate)
	local isSelected = selectedIndex == props.index
	return e(if isSelected then StudButton.Green else StudButton.White, {
		Size = UDim2.new(1, 0, 0, 60),
		LayoutOrder = props.data.layoutOrder,
		Activated = function()
			selectedCrate(props.index)
		end,
	}, {
		e("ImageLabel", {
			Size = UDim2.fromOffset(48, 48),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = Crates.getCrateInfo(props.index).image,
		}),
	})
end

local function CratesFrame()
	return e(InsetFrame, {
		Size = UDim2.fromScale(0.45, 0.9),
		Position = UDim2.fromScale(0.52, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),
	}, {
		Title = e(TextLabel, {
			Text = "Crates",
			Size = UDim2.new(1, 0, 0, 24),
			Position = UDim2.fromScale(0.5, 0.01),
			AnchorPoint = Vector2.new(0.5, 1),
			Stroke = { Thickness = 2 },
		}),

		CratesList = e(
			"ScrollingFrame",
			{
				Size = UDim2.fromScale(0.3, 0.95),
				Position = UDim2.fromScale(0.05, 0.5),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0, 0.5),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				ScrollBarThickness = 0,
				BorderSizePixel = 0,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
			},
			{
				Layout = e("UIListLayout", {
					Padding = UDim.new(0, 10),
					FillDirection = Enum.FillDirection.Vertical,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				Padding = e("UIPadding", {
					PaddingTop = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
				}),
			},
			Sift.Dictionary.map(Crates.crates, function(data: any, index: string)
				return e(CrateButton, { data = data, index = index }), index
			end)
		),

		TowerList = e(
			"ScrollingFrame",
			{
				Size = UDim2.fromScale(0.6, 0.95),
				Position = UDim2.fromScale(0.95, 0.5),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0.5),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 0,
				BorderSizePixel = 0,
			},
			{
				Layout = e("UIListLayout", {
					Padding = UDim.new(0, 0),
					FillDirection = Enum.FillDirection.Vertical,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				Padding = e("UIPadding", {
					PaddingTop = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 1),
					PaddingRight = UDim.new(0, 1),
				}),
			},
			Sift.Dictionary.map(Towers.towers, function(data: any, index: string)
				return e(CrateTower, { data = data, index = index }), index
			end)
		),
	})
end

return function()
	if true then
		return nil
	end

	return e(Menu.Component, {
		menuName = "OddsMenu",
		Title = "Odds",
		From = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromOffset(700, 530),
		Prefix = {
			Image = Crates.getCrateInfo("wooden").image,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		},
	}, {
		Conveyors = e(ConveyorsFrame),
		Crates = e(CratesFrame),
	})
end
