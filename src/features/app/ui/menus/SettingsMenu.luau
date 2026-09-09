local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Menu = require(script.Parent.Menu)
local React = require(ReplicatedStorage.Packages.React)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local StudButton = require(ReplicatedStorage.Source.Features.App.UI.Components.StudButton)
local useSetting = require(ReplicatedStorage.Source.Features.Settings.Hooks.useSetting)
local ShopFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopFrame)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local e = React.createElement

type SettingFrameProps = {
	Text: string,
	path: string | { string },
	LayoutOrder: number,
}

local function SettingFrame(props: SettingFrameProps)
	local value, setValue = useSetting(props.path)
	return e(ShopFrame.Grey, {
		Size = UDim2.new(1, 0, 0, 60),
		LayoutOrder = props.LayoutOrder,
	}, {
		Title = e(TextLabel, {
			Text = props.Text,
			Size = UDim2.fromScale(0.8, 0.7),
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromScale(0.02, 0.5),
			AnchorPoint = Vector2.new(0, 0.5),
			Stroke = { Thickness = 3 },
		}),

		Btn = e(if value then StudButton.Green else StudButton.Red, {
			Size = UDim2.fromOffset(100, 40),
			Position = UDim2.fromScale(0.875, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Text = if value then "On" else "Off",
			Activated = function()
				setValue(not value)
			end,
		}),
	})
end

return function()
	return e(Menu.Component, {
		menuName = "SettingsMenu",
		Title = "Settings",
		From = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromOffset(600, 530),
		Prefix = {
			Image = ImageIds.settings,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		},
	}, {
		ScrollingFrame = e("ScrollingFrame", {
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 0,
			ScrollBarImageTransparency = 1,
			Size = UDim2.fromOffset(590, 470),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0,
		}, {
			Layout = e("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 10),
				Wraps = true,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				FillDirection = Enum.FillDirection.Horizontal,
			}),

			Padding = e("UIPadding", {
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 6),
				PaddingLeft = UDim.new(0, 6),
				PaddingRight = UDim.new(0, 6),
			}),

			music = e(SettingFrame, {
				Text = "Music",
				path = "music",
				LayoutOrder = 1,
			}),
		}),
	})
end
