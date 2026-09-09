local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local RobuxButton = require(ReplicatedStorage.Source.Features.App.UI.Components.RobuxButton)
local useGamepass = require(ReplicatedStorage.Source.Features.Monetization.Hooks.useGamepass)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local MonetizationServiceUtils = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceUtils)
local ShopContentFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopContentFrame)
local ShopFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopFrame)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local e = React.createElement

type GamepassFrameProps = {
	product: MonetizationServiceUtils.MonetizationProduct,
	Image: string,
	LayoutOrder: number,
	ImagePosition: UDim2,
	ImageSize: UDim2,
	Text: string,
	TitleGradient: ColorSequence,
	Description: string,
	StrokeColor: Color3,
	Frame: any,
}

local function GamepassFrame(props: GamepassFrameProps)
	return e(props.Frame, {
		Size = UDim2.fromOffset(376, 208),
		LayoutOrder = props.LayoutOrder,
	}, {
		e(TextLabel, {
			Text = props.Text,
			Size = UDim2.fromScale(1, 0.2),
			Position = UDim2.fromScale(0, 0),
			Stroke = { Thickness = 3, Color = props.StrokeColor },
			ZIndex = 3,
			Gradient = {
				Rotation = 90,
				Color = props.TitleGradient,
			},
			BackgroundTransparency = 0.7,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(26, 26, 26),
		}),

		e(TextLabel, {
			Text = props.Description,
			TextSize = 30,
			Size = UDim2.fromScale(0.6, 0.4),
			Position = UDim2.fromScale(0.67, 0.42),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Stroke = { Thickness = 2 },
			TextWrapped = true,
			ZIndex = 2,
		}),

		e("ImageLabel", {
			Image = props.Image,
			Size = props.ImageSize,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Position = props.ImagePosition,
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			ZIndex = 1,
		}),

		e(RobuxButton, {
			product = props.product,
			Position = UDim2.fromScale(0.89, 0.94),
			AnchorPoint = Vector2.new(1, 1),
			ZIndex = 3,
		}),
	}, props.children)
end

local function TripleCrates()
	local ownsDouble = useGamepass(Products.doubleCrates)

	return e(GamepassFrame, {
		product = Products.tripleCrates,
		LayoutOrder = 8,
		ImagePosition = UDim2.fromScale(0.02, 0.97),
		ImageSize = UDim2.fromScale(0.8, 0.8),
		Image = ImageIds.tripleCrate,
		Frame = ShopFrame.Orange,
		Text = "Triple Crates",
		Description = "Spawn 3 crates each click!",
		TitleGradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 38, 0)),
		}),
		StrokeColor = Color3.fromRGB(46, 7, 0),
	}, {
		if not ownsDouble
			then e("ImageButton", {
				ZIndex = 999,
				AutoButtonColor = false,
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 0.33,
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
			}, {
				e(TextLabel, {
					Text = "Must Buy Double\nCrates First",
					Size = UDim2.fromScale(0.75, 0.35),
					Position = UDim2.fromScale(0.5, 0.72),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Stroke = { Thickness = 4 },
					ZIndex = 2,
				}),

				e("ImageLabel", {
					Image = ImageIds.lock,
					Size = UDim2.fromScale(0.45, 0.45),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Position = UDim2.fromScale(0.33, 0.42),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
				}),
			})
			else nil,
	})
end

return function()
	return e(ShopContentFrame, {
		Text = "Gamepasses",
		LayoutOrder = 20,
	}, {
		e(GamepassFrame, {
			product = Products.superLuck,
			LayoutOrder = 1,
			ImagePosition = UDim2.fromScale(0.02, 0.97),
			ImageSize = UDim2.fromScale(0.8, 0.8),
			Image = ImageIds.luck,
			Frame = ShopFrame.Green,
			Text = "Super Luck",
			Description = "Boosts your luck!",
			TitleGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 34)),
			}),
			StrokeColor = Color3.fromRGB(0, 46, 15),
		}),

		e(GamepassFrame, {
			product = Products.ultraLuck,
			LayoutOrder = 2,
			ImagePosition = UDim2.fromScale(0.02, 0.97),
			ImageSize = UDim2.fromScale(0.8, 0.8),
			Image = ImageIds.superLuck,
			Frame = ShopFrame.Purple,
			Text = "Ultra Luck",
			Description = "Boosts your luck a ton!",
			TitleGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(195, 0, 255)),
			}),
			StrokeColor = Color3.fromRGB(20, 0, 46),
		}),

		e(GamepassFrame, {
			product = Products.doubleUnlockSpeed,
			LayoutOrder = 3,
			ImagePosition = UDim2.fromScale(0.02, 0.97),
			ImageSize = UDim2.fromScale(0.8, 0.8),
			Image = ImageIds.quickUnlock,
			Frame = ShopFrame.Blue,
			Text = "Quick Unlock",
			Description = "Double crate unlock speed!",
			TitleGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 170, 255)),
			}),
			StrokeColor = Color3.fromRGB(0, 46, 91),
		}),

		e(GamepassFrame, {
			product = Products.fastConveyor,
			LayoutOrder = 4,
			ImagePosition = UDim2.fromScale(0.02, 0.97),
			ImageSize = UDim2.fromScale(0.8, 0.8),
			Image = ImageIds.fastConveyor,
			Frame = ShopFrame.Red,
			Text = "Fast Conveyor",
			Description = "Speed up your conveyor!",
			TitleGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 30, 0)),
			}),
			StrokeColor = Color3.fromRGB(91, 3, 0),
		}),

		e(GamepassFrame, {
			product = Products.doubleDamage,
			LayoutOrder = 5,
			ImagePosition = UDim2.fromScale(0.02, 0.97),
			ImageSize = UDim2.fromScale(0.8, 0.8),
			Image = ImageIds.flex,
			Frame = ShopFrame.Gold,
			Text = "Double Damage",
			Description = "Do more damage!",
			TitleGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 187, 0)),
			}),
			StrokeColor = Color3.fromRGB(46, 31, 0),
		}),

		e(GamepassFrame, {
			product = Products.doubleMoney,
			LayoutOrder = 6,
			ImagePosition = UDim2.fromScale(0.02, 0.97),
			ImageSize = UDim2.fromScale(0.8, 0.8),
			Image = ImageIds.currency,
			Frame = ShopFrame.Green,
			Text = "Double Money",
			Description = "Earn more money!",
			TitleGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 34)),
			}),
			StrokeColor = Color3.fromRGB(0, 46, 15),
		}),

		e(GamepassFrame, {
			product = Products.doubleCrates,
			LayoutOrder = 7,
			ImagePosition = UDim2.fromScale(0.02, 0.97),
			ImageSize = UDim2.fromScale(0.8, 0.8),
			Image = ImageIds.doubleCrate,
			Frame = ShopFrame.Green,
			Text = "Double Crates",
			Description = "Spawn 2 crates each click!",
			TitleGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 34)),
			}),
			StrokeColor = Color3.fromRGB(0, 46, 15),
		}),

		e(TripleCrates),

		e(GamepassFrame, {
			product = Products.goldHunter,
			LayoutOrder = 9,
			ImagePosition = UDim2.fromScale(0.02, 0.97),
			ImageSize = UDim2.fromScale(0.8, 0.8),
			Image = ImageIds.mutations.gold,
			Frame = ShopFrame.Gold,
			Text = "Gold Hunter",
			Description = "More gold mutations!",
			TitleGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 187, 0)),
			}),
			StrokeColor = Color3.fromRGB(46, 31, 0),
		}),
		e(GamepassFrame, {
			product = Products.diamondHunter,
			LayoutOrder = 10,
			ImagePosition = UDim2.fromScale(0.02, 0.97),
			ImageSize = UDim2.fromScale(0.8, 0.8),
			Image = ImageIds.mutations.diamond,
			Frame = ShopFrame.Blue,
			Text = "Diamond Hunter",
			Description = "More diamond mutations!",
			TitleGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 170, 255)),
			}),
			StrokeColor = Color3.fromRGB(0, 46, 91),
		}),
	})
end
