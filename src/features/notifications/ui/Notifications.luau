local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SoundController = require(ReplicatedStorage.Source.Core.Platform.SoundController)
local Abbreviate = require(ReplicatedStorage.Source.Core.UI.Abbreviate)
local useSpring = require(ReplicatedStorage.Source.Core.UI.Hooks.useSpring)
local AutoScaledFrame = require(ReplicatedStorage.Source.Core.UI.Primitives.AutoScaledFrame)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local ShopFrame = require(ReplicatedStorage.Source.Features.Shop.UI.Components.ShopFrame)
local Sounds = require(ReplicatedStorage.Source.Game.Assets.Sounds)
local atom = Charm.atom
local e: typeof(React.createElement) = React.createElement

type Atom<T> = Charm.Atom<T>

type NotificationProps = {
	Image: string,
	Amount: number,
	id: string?,
}

local notificaitonId = 0
local activeNotifications: Atom<{ [string]: NotificationProps }> = atom({})

local function addNotification(props: NotificationProps)
	SoundController:Play(Sounds.ui.notification)
	notificaitonId += 1
	local id = tostring(notificaitonId)
	props.id = id
	activeNotifications(function(notifications)
		return Sift.Dictionary.set(notifications, id, props)
	end)
end

local function NotificationComponent(props: NotificationProps & { id: string })
	local size, spring = useSpring(UDim2.fromScale(0, 0), { frequency = 3, damping = 0.6 }, UDim2.fromScale(1, 1))

	React.useEffect(function()
		local discon
		local thread = task.delay(5, function()
			spring:setGoal(UDim2.fromScale(0, 0))
			discon = spring:onComplete(function()
				activeNotifications(function(notifications)
					return Sift.Dictionary.removeKey(notifications, props.id)
				end)
			end)
		end)

		return function()
			if discon then
				discon()
			end
			if thread then
				task.cancel(thread)
			end
		end
	end, {})

	return e(ShopFrame.Grey, {
		Size = size,
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
	}, {
		e("ImageLabel", {
			Image = props.Image,
			Size = UDim2.fromScale(0.8, 0.8),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
		}),

		e(TextLabel, {
			Text = "x" .. Abbreviate(props.Amount),
			Size = UDim2.fromScale(1, 0.3),
			Position = UDim2.fromScale(0.5, 0.85),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Stroke = { Color = Color3.new(0, 0, 0), Thickness = 2 },
		}),
	})
end

local function Screen()
	local notificationProps = ReactCharm.useAtom(activeNotifications)
	return e(AutoScaledFrame, {
		Size = UDim2.fromOffset(1000, 90),
		Position = UDim2.fromScale(0.5, 0.75),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 999999,
	}, {
		e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4),
		}),
		Sift.Dictionary.map(notificationProps, function(props)
			return e(NotificationComponent, props)
		end),
	})
end

return {
	addNotification = addNotification,
	Screen = Screen,
}
