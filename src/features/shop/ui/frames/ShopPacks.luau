local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local RobuxButton = require(ReplicatedStorage.Source.Features.App.UI.Components.RobuxButton)
local StudButton = require(ReplicatedStorage.Source.Features.App.UI.Components.StudButton)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local ItemIcon = require(ReplicatedStorage.Source.Features.Inventory.UI.Components.ItemIcon)
local useGamepass = require(ReplicatedStorage.Source.Features.Monetization.Hooks.useGamepass)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local MonetizationServiceClient = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceClient)
local ShopContentFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopContentFrame)
local ShopFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopFrame)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)

local e = React.createElement

local function LuckyBlockFrame(props)
	local info = Towers.getTowerInfo(props.id)
	local luck: number = info.luck

	return e(props.Frame, {
		Size = UDim2.fromOffset(368 * 2 / 3, 380),
		LayoutOrder = props.LayoutOrder,
	}, {
		Title = e(TextLabel, {
			Text = "Lucky Block",
			Size = UDim2.fromScale(1, 0.125),
			Position = UDim2.fromScale(0, 0),
			Stroke = { Thickness = 3, Color = Color3.fromRGB(0, 0, 0) },
			ZIndex = 3,
		}),

		Sub = e(TextLabel, {
			Text = props.SubText,
			Size = UDim2.fromScale(1, 0.1),
			Position = UDim2.fromScale(0, 0.125),
			Stroke = { Thickness = 3, Color = Color3.fromRGB(0, 0, 0) },
			ZIndex = 3,
			Gradient = {
				Color = props.SubTextGradient,
				Rotation = -90,
			},
		}),

		Icon = e("ImageLabel", {
			Image = info.crateImage,
			Size = UDim2.fromScale(0.9, 0.9),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
		}),

		Description = e(TextLabel, {
			Text = `X{luck} LUCK!`,
			TextSize = 30,
			Size = UDim2.fromScale(0.9, 0.2),
			Position = UDim2.fromScale(0.5, 0.89),
			AnchorPoint = Vector2.new(0.5, 1),
			Stroke = { Thickness = 3 },
			TextWrapped = true,
			ZIndex = 2,
		}),

		RbxButton = e(RobuxButton, {
			Scale = 0.95,
			Position = UDim2.fromScale(0.5, 0.975),
			AnchorPoint = Vector2.new(0.5, 1),
			product = props.product,
			ButtonSize = UDim2.fromScale(0.8, 1),
		}, {
			e(StudButton.Green, {
				hoverScale = 1.1,
				Size = UDim2.fromScale(0.9, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				LayoutOrder = 3,
				Activated = function()
					MonetizationServiceClient:promptProduct(props.threeProduct)
				end,
			}, {
				e(TextLabel, {
					Text = "X3",
					Stroke = {},
					Size = UDim2.fromScale(0.9, 0.6),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
				}),
			}),
		}),
	})
end

local function StarterPack()
	local owns = useGamepass(Products.starterPack)
	if owns then
		return nil
	end

	return e(ShopFrame.Blue, {
		Size = UDim2.fromOffset(768, 200),
		LayoutOrder = 0,
	}, {
		Title = e(TextLabel, {
			Text = "Starter Pack",
			Size = UDim2.fromScale(1, 0.225),
			Position = UDim2.fromScale(0, 0),
			Stroke = { Thickness = 3, Color = Color3.fromRGB(0, 0, 0) },
			ZIndex = 3,
		}),

		worthText = e(TextLabel, {
			Text = "\u{E002}349",
			Size = UDim2.fromOffset(200, 45),
			Position = UDim2.fromScale(0.66, 0.4),
			Stroke = { Thickness = 3, Color = Color3.fromRGB(0, 0, 0) },
			ZIndex = 3,
		}, {
			e("Frame", {
				Size = UDim2.new(0.7, 0, 0, 5),
				Position = UDim2.fromScale(0.5, 0.45),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Rotation = -6,
				BackgroundColor3 = Color3.fromRGB(255, 0, 0),
				BorderSizePixel = 0,
			}),
		}),

		content = e("Frame", {
			Size = UDim2.fromOffset(480, 135),
			Position = UDim2.fromScale(0.03, 0.92),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
		}, {
			e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 20),
			}),

			e(ShopFrame.Grey, {
				Size = UDim2.fromScale(0.75, 0.75),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				LayoutOrder = 1,
			}, {
				e(TextLabel, {
					Text = "TESLA TOWER",
					Size = UDim2.fromScale(1.2, 0.25),
					Position = UDim2.fromScale(0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Stroke = { Thickness = 3 },
					ZIndex = 99,
				}),

				e(ItemIcon, {
					itemData = { itemId = "tesla", level = 1 },
					Size = UDim2.fromScale(0.95, 0.95),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					hideStroke = true,
				}),
			}),

			e(ShopFrame.Grey, {
				Size = UDim2.fromScale(0.75, 0.75),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				LayoutOrder = 2,
			}, {
				e(TextLabel, {
					Text = "ORB CRATE",
					Size = UDim2.fromScale(1.1, 0.25),
					Position = UDim2.fromScale(0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Stroke = { Thickness = 3 },
					ZIndex = 99,
				}),

				e(ItemIcon, {
					itemData = { crateId = "orbOfLight", amt = 1 },
					Size = UDim2.fromScale(0.95, 0.95),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					hideStroke = true,
				}),
			}),

			e(ShopFrame.Grey, {
				Size = UDim2.fromScale(0.75, 0.75),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				LayoutOrder = 3,
			}, {
				e(TextLabel, {
					Text = "MONEY",
					Size = UDim2.fromScale(1.1, 0.25),
					Position = UDim2.fromScale(0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Stroke = { Thickness = 3 },
					ZIndex = 99,
				}),

				e("ImageLabel", {
					Image = ImageIds.currency,
					Size = UDim2.fromScale(0.8, 0.8),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
				}),

				e(TextLabel, {
					Text = "$100k",
					Size = UDim2.fromScale(1.1, 0.25),
					Position = UDim2.fromScale(0.5, 0.95),
					AnchorPoint = Vector2.new(0.5, 1),
					Stroke = { Thickness = 3 },
					ZIndex = 99,
					Gradient = {
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromRGB(226, 255, 192)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 255, 0)),
						}),
						Rotation = 90,
					},
				}),
			}),

			e(ShopFrame.Grey, {
				Size = UDim2.fromScale(0.75, 0.75),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				LayoutOrder = 4,
			}, {
				e(TextLabel, {
					Text = "MONEY BONUS",
					Size = UDim2.fromScale(1.1, 0.25),
					Position = UDim2.fromScale(0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Stroke = { Thickness = 3 },
					ZIndex = 99,
				}),

				e("ImageLabel", {
					Image = ImageIds.currency,
					Size = UDim2.fromScale(0.8, 0.8),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
				}),

				e("ImageLabel", {
					Image = ImageIds.upgrade,
					Size = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.75, 0.33),
					BackgroundTransparency = 1,
					ZIndex = 2,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
				}),

				e(TextLabel, {
					Text = "+10%",
					Size = UDim2.fromScale(1.1, 0.25),
					Position = UDim2.fromScale(0.5, 0.95),
					AnchorPoint = Vector2.new(0.5, 1),
					Stroke = { Thickness = 3 },
					ZIndex = 99,
					Gradient = {
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromRGB(226, 255, 192)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 255, 0)),
						}),
						Rotation = 90,
					},
				}),
			}),
		}),

		btn = e(RobuxButton, {
			Scale = 1.1,
			Position = UDim2.fromScale(0.933, 0.925),
			AnchorPoint = Vector2.new(1, 1),
			product = Products.starterPack,
		}),
	})
end

return function()
	return e(ShopContentFrame, {
		Text = "Exclusive Packs",
		LayoutOrder = 0,
	}, {
		e(StarterPack),

		e(LuckyBlockFrame, {
			Frame = ShopFrame.Gold,
			id = "luckyBlock1",
			product = Products.luckyBlock1,
			threeProduct = Products.threeLuckyBlock1,
			SubText = "EXOTIC",
			SubTextGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0)),
			}),
		}),
		e(LuckyBlockFrame, {
			Frame = ShopFrame.Red,
			id = "luckyBlock2",
			product = Products.luckyBlock2,
			threeProduct = Products.threeLuckyBlock2,
			SubText = "SECRET",
			SubTextGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 85, 85)),
			}),
		}),
		e(LuckyBlockFrame, {
			Frame = ShopFrame.Purple,
			id = "luckyBlock3",
			product = Products.luckyBlock3,
			threeProduct = Products.threeLuckyBlock3,
			SubText = "DIVINE",
			SubTextGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 0, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 85, 255)),
			}),
		}),
	})
end
