local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local InsetFrame = require(ReplicatedStorage.Source.Features.App.UI.Components.InsetFrame)
local StudButton = require(ReplicatedStorage.Source.Features.App.UI.Components.StudButton)
local PlotServiceClient = require(ReplicatedStorage.Source.Features.Plots.PlotServiceClient)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local Menu = require(script.Parent.Menu)
local e = React.createElement

return function()
	return e(Menu.Component, {
		menuName = "LikeMenu",
		Title = "Like + Group Rewards!",
		From = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromOffset(550, 400),
		Prefix = {
			Image = ImageIds.upgrade,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		},
	}, {
		e(TextLabel, {
			Text = "Enjoying the game?",
			Size = UDim2.fromScale(1, 0.175),
			Position = UDim2.fromScale(0.5, 0.1),
			AnchorPoint = Vector2.new(0.5, 0),
			Stroke = { Thickness = 2 },
		}),

		e(InsetFrame, {
			Size = UDim2.fromScale(0.8, 0.275),
			Position = UDim2.fromScale(0.5, 0.3),
			AnchorPoint = Vector2.new(0.5, 0),
		}, {
			e(TextLabel, {
				Text = "Like the game and join the group for more luck and money!",
				Size = UDim2.fromScale(0.9, 0.9),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Stroke = { Thickness = 1 },
				TextWrapped = true,
				TextSize = 30,
			}),
		}),

		e(StudButton.Green, {
			Size = UDim2.fromOffset(200, 66),
			Position = UDim2.fromScale(0.75, 0.725),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Text = "Confirm",
			Activated = function()
				Menu.setOpenedMenu(nil)
				PlotServiceClient:claimGroupLoot()
			end,
		}),

		e(StudButton.White, {
			Size = UDim2.fromOffset(200, 66),
			Position = UDim2.fromScale(0.25, 0.725),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Text = "Close",
			Activated = function()
				Menu.setOpenedMenu(nil)
				PlotServiceClient:claimGroupLoot()
			end,
		}),
	})
end
