local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Menu = require(script.Parent.Menu)
local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local ErrorMessage = require(ReplicatedStorage.Source.Core.UI.Components.ErrorMessage)
local PlayerPortrait = require(ReplicatedStorage.Source.Core.UI.Components.PlayerPortrait)
local DisplayNameWithIcons = require(ReplicatedStorage.Source.Core.UI.DisplayNameWithIcons)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local StudButton = require(ReplicatedStorage.Source.Features.App.UI.Components.StudButton)
local MonetizationServiceClient = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceClient)
local ShopSlice = require(ReplicatedStorage.Source.Features.Shop.ShopSlice)
local ShopFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopFrame)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local e = React.createElement

type PlayerCardProps = {
	Player: Player,
	LayoutOrder: number,
}

local function PlayerCard(props: PlayerCardProps)
	local product = ReactCharm.useAtom(ShopSlice.state.giftingProduct)
	if not product then
		return nil
	end

	return e(ShopFrame.Grey, {
		Size = UDim2.new(1, 0, 0, 60),
		LayoutOrder = props.LayoutOrder,
	}, {
		Portrait = e(PlayerPortrait, {
			Size = UDim2.fromScale(0.6767, 0.6767),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Position = UDim2.fromScale(0.05, 0.5),
			AnchorPoint = Vector2.new(0, 0.5),
			userId = props.Player.UserId,
		}),

		Title = e(TextLabel, {
			Text = DisplayNameWithIcons(props.Player),
			Size = UDim2.fromScale(0.8, 0.7),
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromScale(0.02, 0.5),
			AnchorPoint = Vector2.new(0, 0.5),
			Stroke = { Thickness = 3 },
		}),

		Btn = e(StudButton.Green, {
			Size = UDim2.fromOffset(100, 40),
			Position = UDim2.fromScale(0.875, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Text = "Gift",
			Activated = function()
				local success, err = MonetizationServiceClient:promptGift(props.Player.UserId, product)
				if not success then
					ErrorMessage.add(err or "Failed to send gift.")
				end
			end,
		}),
	})
end

local function PlayersList()
	local players, setPlayers = React.useState(Players:GetPlayers())
	React.useEffect(function()
		local addedConn = Players.PlayerAdded:Connect(function()
			setPlayers(Players:GetPlayers())
		end)

		local removedConn = Players.PlayerRemoving:Connect(function()
			setPlayers(Players:GetPlayers())
		end)

		return function()
			addedConn:Disconnect()
			removedConn:Disconnect()
		end
	end, {})

	return e("ScrollingFrame", {
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.95, 0.9),
		BackgroundTransparency = 1,
		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
		ScrollBarImageTransparency = 1,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, {
		e("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),

		Sift.Array.map(players, function(player: Player, index: number)
			if player == Players.LocalPlayer then
				return nil
			end

			return e(PlayerCard, {
				Player = player,
				LayoutOrder = index,
			})
		end),
	})
end

return function()
	return e(Menu.Component, {
		menuName = "GiftingMenu",
		Title = "Gift",
		From = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromOffset(600, 530),
		OnClose = function()
			Menu.setOpenedMenu("Shop")
		end,
		Prefix = {
			Image = ImageIds.shoppingCart,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		},
	}, {
		e(PlayersList),
	})
end
