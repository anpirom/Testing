local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.React)
local useDataState = require(ReplicatedStorage.Source.Core.UI.Hooks.useDataState)
local AutoScaledFrame = require(ReplicatedStorage.Source.Core.UI.Primitives.AutoScaledFrame)
local Button = require(ReplicatedStorage.Source.Core.UI.Primitives.Button)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local Menu = require(ReplicatedStorage.Source.Features.App.UI.Menus.Menu)
local RebirthUtils = require(ReplicatedStorage.Source.Features.Plots.Modules.RebirthUtils)
local ShopFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopFrame)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local e = React.createElement

type SideBarButtonProps = {
	Position: UDim2,
	Text: string,
	Image: string,
	IconScale: number?,
	Activated: () -> (),
	children: any,
}

local function SideBarButton(props: SideBarButtonProps)
	local iconScale = props.IconScale or 1
	return e(Button, {
		hoverScale = 1.1,
		Size = UDim2.fromOffset(80, 80),
		Position = props.Position,
		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Activated = props.Activated,
	}, {
		Stroke = e("UIStroke", {
			Thickness = 2.5,
			Color = Color3.new(0, 0, 0),
		}),

		Title = e(TextLabel, {
			Text = props.Text,
			Size = UDim2.fromScale(1, 0.275),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.975),
			Stroke = {},
			ZIndex = 2,
		}),

		Icon = e("ImageLabel", {
			Size = UDim2.fromScale(iconScale, iconScale),
			Position = UDim2.fromScale(0.5, 0.475),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = props.Image,
		}),
	}, props.children)
end

local RAINBOW_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 127, 0)),
	ColorSequenceKeypoint.new(0.34, Color3.fromRGB(255, 255, 0)),
	ColorSequenceKeypoint.new(0.51, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.68, Color3.fromRGB(0, 255, 255)),
	ColorSequenceKeypoint.new(0.85, Color3.fromRGB(0, 0, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255)),
})

local function ShopButton()
	local rot, setRot = React.useBinding(0)
	React.useEffect(function()
		local connection
		connection = RunService.Heartbeat:Connect(function(dt)
			setRot((rot:getValue() + dt * 15) % 360)
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	return e(Button, {
		hoverScale = 1.1,
		Size = UDim2.fromOffset(200, 70),
		Position = UDim2.fromScale(0.595, 0.438),
		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Activated = function()
			Menu.setOpenedMenu("Shop")
		end,
	}, {
		Stroke = e("UIStroke", {
			Thickness = 4,
			Color = Color3.fromRGB(241, 245, 245),
		}, {
			Gradient = e("UIGradient", {
				Color = RAINBOW_GRADIENT,
				Rotation = rot,
			}),
		}),

		Title = e(TextLabel, {
			Text = "Shop",
			Size = UDim2.fromScale(0.6, 0.6),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.65, 0.5),
			Stroke = { Thickness = 3 },
			ZIndex = 2,
		}),

		Icon = e("ImageLabel", {
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Position = UDim2.fromScale(0.02, 0.495),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Image = ImageIds.shoppingCart,
		}),
	})
end

local function RebirthNotiButton()
	local rebirths: number = useDataState("rebirths")
	local currency = useDataState("currency")
	local towerIndex = useDataState("towerIndex")

	if RebirthUtils.isMaxedRebirths(rebirths) then
		return nil
	end

	local reqs = RebirthUtils.getRequirements(rebirths)
	local currencyReqMet = currency >= reqs.currency
	local towerReqMet = towerIndex.normal[reqs.towerId]
		or towerIndex.gold[reqs.towerId]
		or towerIndex.diamond[reqs.towerId]
	local canRebirth = currencyReqMet and towerReqMet

	if not canRebirth then
		return nil
	end

	return e(ShopFrame.Red, {
		Size = UDim2.fromScale(0.35, 0.35),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Position = UDim2.new(1, -2, 0, 2),
		AnchorPoint = Vector2.new(1, 0),
	}, {
		e(TextLabel, {
			Text = "!",
			Size = UDim2.fromScale(1, 1),
			Stroke = {},
		}),
	})
end

return function()
	return e(AutoScaledFrame, {
		Size = UDim2.fromOffset(180, 800),
		Position = UDim2.fromScale(0.005, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
	}, {
		Shop = e(ShopButton),

		Rebirth = e(SideBarButton, {
			Position = UDim2.fromScale(0.75, 0.55),
			Text = "Rebirth",
			IconScale = 0.925,
			Image = ImageIds.rebirth,
			Activated = function()
				Menu.setOpenedMenu("RebirthMenu")
			end,
		}, e(RebirthNotiButton)),

		Index = e(SideBarButton, {
			Position = UDim2.fromScale(0.25, 0.55),
			Text = "Index",
			IconScale = 0.925,
			Image = ImageIds.index,
			Activated = function()
				Menu.setOpenedMenu("IndexMenu")
			end,
		}),
	})
end
