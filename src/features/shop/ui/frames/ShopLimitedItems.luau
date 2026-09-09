local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local RainbowGradient = require(ReplicatedStorage.Source.Core.UI.Components.RainbowGradient)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local RobuxButton = require(ReplicatedStorage.Source.Features.App.UI.Components.RobuxButton)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local ShopContentFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopContentFrame)
local ShopFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopFrame)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)

local e = React.createElement

local function LimitedFrame(props)
	return e(ShopFrame.Blue, {
		Size = UDim2.fromOffset(376, 380),
		LayoutOrder = props.LayoutOrder,
	}, {
		Title = e(TextLabel, {
			Text = props.Title,
			Size = UDim2.fromScale(1, 0.125),
			Position = UDim2.fromScale(0, 0),
			Stroke = { Thickness = 3, Color = Color3.fromRGB(0, 0, 0) },
			ZIndex = 3,
		}, {
			Gradient = e(RainbowGradient),
		}),

		Icon = e("ImageLabel", {
			Image = props.Image,
			Size = UDim2.fromScale(0.9, 0.9),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Position = props.ImagePosition,
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			ZIndex = 0,
		}),

		Description = e(TextLabel, {
			Text = props.Description,
			TextSize = 30,
			Size = UDim2.fromScale(0.9, 0.2),
			Position = UDim2.fromScale(0.5, 0.85),
			AnchorPoint = Vector2.new(0.5, 1),
			Stroke = { Thickness = 2 },
			TextWrapped = true,
			ZIndex = 2,
		}),

		RbxButton = e(RobuxButton, {
			Scale = 1.2,
			Position = UDim2.fromScale(0.5, 0.975),
			AnchorPoint = Vector2.new(0.5, 1),
			product = props.product,
		}),
	})
end

local function OPLimitedFrame()
	return e(ShopFrame.Blue, {
		Size = UDim2.fromOffset(768, 260),
		LayoutOrder = 3,
	}, {
		Title = e(TextLabel, {
			Text = "Pyramidium Tower",
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.fromScale(0.66, 0.24),
			Position = UDim2.fromScale(0.02, 0),
			Stroke = { Thickness = 4, Color = Color3.fromRGB(0, 0, 0) },
			ZIndex = 3,
		}, {
			Gradient = e(RainbowGradient),
		}),

		OP = e(TextLabel, {
			Text = "SUPER LIMITED",
			Size = UDim2.fromScale(0.8, 0.19),
			Position = UDim2.fromScale(0.02, 0.2),
			TextXAlignment = Enum.TextXAlignment.Left,
			Stroke = { Thickness = 3, Color = Color3.fromRGB(0, 0, 0) },
			ZIndex = 3,
		}),

		Icon = e("ImageLabel", {
			Image = ImageIds.pyraStroke,
			Size = UDim2.fromScale(1.25, 1.25),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Position = UDim2.fromScale(1, 0.525),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			ZIndex = 0,
		}),

		Description = e(TextLabel, {
			Text = "200% OF YOUR BEST",
			Size = UDim2.fromScale(0.9, 0.19),
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromScale(0.02, 0.7),
			AnchorPoint = Vector2.new(0, 1),
			Stroke = { Thickness = 3 },
			ZIndex = 2,
		}),

		RbxButton = e(RobuxButton, {
			Scale = 1.2,
			Position = UDim2.fromScale(0.1, 0.955),
			AnchorPoint = Vector2.new(0, 1),
			product = Products.pyramidiumTower,
		}),
	})
end

return function()
	return e(ShopContentFrame, {
		Text = "Limited Towers",
		LayoutOrder = 10,
	}, {
		e(LimitedFrame, {
			Title = "Overdrive Tower",
			Description = "110% OF YOUR BEST",
			LayoutOrder = 1,
			Image = ImageIds.overdriveStroke,
			ImagePosition = UDim2.fromScale(0.5, 0),
			product = Products.overdriveTower,
		}),

		e(LimitedFrame, {
			Title = "Eradicator Tower",
			Description = "135% OF YOUR BEST",
			LayoutOrder = 2,
			Image = ImageIds.eradStroke,
			ImagePosition = UDim2.fromScale(0.5, 0),
			product = Products.eradicatorTower,
		}),

		e(OPLimitedFrame),
	})
end
