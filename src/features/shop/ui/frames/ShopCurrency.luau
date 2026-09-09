local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local FormatCurrency = require(ReplicatedStorage.Source.Core.UI.FormatCurrency)
local useDataState = require(ReplicatedStorage.Source.Core.UI.Hooks.useDataState)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local RobuxButton = require(ReplicatedStorage.Source.Features.App.UI.Components.RobuxButton)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local ShopUtils = require(ReplicatedStorage.Source.Features.Shop.ShopUtils)
local ShopContentFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopContentFrame)
local ShopFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopFrame)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local e = React.createElement

local function MoneyFrame(props)
	local rebriths = useDataState("rebirths")
	local amt = ShopUtils.getCurrencyAmtFromRebirth(props.tier, rebriths)
	return e(ShopFrame.Green, {
		Size = UDim2.fromOffset(376, 190),
		LayoutOrder = props.LayoutOrder,
	}, {
		e(TextLabel, {
			Text = props.Text,
			Size = UDim2.fromScale(1, 0.2),
			Position = UDim2.fromScale(0, 0),
			Stroke = { Thickness = 3 },
			ZIndex = 3,
			BackgroundTransparency = 0.7,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(26, 26, 26),
		}),

		e(TextLabel, {
			Size = UDim2.fromScale(1, 0.35),
			Text = "+" .. FormatCurrency(amt),
			Position = UDim2.fromScale(0.5, 0.4),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Stroke = { Thickness = 4, Color = Color3.fromRGB(24, 55, 7) },
			Gradient = {
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(226, 255, 192)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 255, 0)),
				}),
			},
		}),

		e(RobuxButton, {
			product = props.product,
			Position = UDim2.fromScale(0.5, 0.94),
			AnchorPoint = Vector2.new(0.5, 1),
			ZIndex = 3,
		}),
	})
end

local function LargeMoneyFrame(props)
	local rebriths = useDataState("rebirths")
	local amt = ShopUtils.getCurrencyAmtFromRebirth(props.tier, rebriths)
	return e(ShopFrame.Green, {
		Size = UDim2.fromOffset(768, 190),
		LayoutOrder = props.LayoutOrder,
	}, {
		e("ImageLabel", {
			Image = ImageIds.currency,
			Size = UDim2.fromScale(0.7, 0.7),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Position = UDim2.fromScale(0.05, 0.6),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
		}),

		e("ImageLabel", {
			Image = ImageIds.currency,
			Size = UDim2.fromScale(0.7, 0.7),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Position = UDim2.fromScale(0.95, 0.6),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
		}),

		e(TextLabel, {
			Text = props.Text,
			Size = UDim2.fromScale(1, 0.2),
			Position = UDim2.fromScale(0, 0),
			Stroke = { Thickness = 3 },
			ZIndex = 3,
			BackgroundTransparency = 0.7,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(26, 26, 26),
		}),

		e(TextLabel, {
			Size = UDim2.fromScale(1, 0.35),
			Text = "+" .. FormatCurrency(amt),
			Position = UDim2.fromScale(0.5, 0.4),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Stroke = { Thickness = 4, Color = Color3.fromRGB(24, 55, 7) },
			Gradient = {
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(226, 255, 192)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 255, 0)),
				}),
			},
		}),

		e(RobuxButton, {
			Scale = 1.2,
			product = props.product,
			Position = UDim2.fromScale(0.5, 0.94),
			AnchorPoint = Vector2.new(0.5, 1),
			ZIndex = 3,
		}),
	})
end

return function()
	return e(ShopContentFrame, {
		Text = "Money",
		LayoutOrder = 30,
	}, {
		e(MoneyFrame, {
			LayoutOrder = 1,
			tier = 1,
			product = Products.currency1,
			Text = "Small",
		}),

		e(MoneyFrame, {
			LayoutOrder = 2,
			tier = 2,
			product = Products.currency2,
			Text = "Medium",
		}),

		e(LargeMoneyFrame, {
			LayoutOrder = 3,
			tier = 3,
			product = Products.currency3,
			Text = "TONS of Money!!",
		}),
	})
end
