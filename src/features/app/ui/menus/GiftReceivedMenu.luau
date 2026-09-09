local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local DisplayNameWithIcons = require(ReplicatedStorage.Source.Core.UI.DisplayNameWithIcons)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local StudButton = require(ReplicatedStorage.Source.Features.App.UI.Components.StudButton)
local MonetizationServiceClient = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceClient)
local ShopSlice = require(ReplicatedStorage.Source.Features.Shop.ShopSlice)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local Menu = require(script.Parent.Menu)
local e = React.createElement

local function Content()
	local receivedData = ReactCharm.useAtom(ShopSlice.state.giftReceivedData)
	if not receivedData then
		return nil
	end

	local playerName = "UNKNOWN"
	local sender = Players:GetPlayerByUserId(receivedData.giftData.fromUserId)
	if sender then
		playerName = DisplayNameWithIcons(sender)
	end

	local product = receivedData.product
	local productInfo = MonetizationServiceClient:getProductInfo(product)

	return e(React.Fragment, nil, {
		e(TextLabel, {
			Text = `{playerName} has gifted you:\n<font size="60">{productInfo.Name}</font>`,
			TextSize = 30,
			TextScaled = false,
			Size = UDim2.fromScale(0.8, 0.4),
			Position = UDim2.fromScale(0.5, 0.24),
			AnchorPoint = Vector2.new(0.5, 0),
			RichText = true,
			Stroke = { Thickness = 2 },
		}),

		e(StudButton.Green, {
			Text = "Claim",
			Size = UDim2.fromOffset(120, 50),
			Position = UDim2.fromScale(0.5, 0.75),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Activated = function()
				Menu.setOpenedMenu(nil)
				ShopSlice.state.giftReceivedData(nil)
			end,
		}),
	})
end

return function()
	return e(Menu.Component, {
		menuName = "GiftReceivedMenu",
		Title = "Gift Received",
		From = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromOffset(450, 300),
		Prefix = {
			Image = ImageIds.shoppingCart,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		},
	}, {
		e(Content),
	})
end
