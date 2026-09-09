local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SocialService = game:GetService("SocialService")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local FormatCurrency = require(ReplicatedStorage.Source.Core.UI.FormatCurrency)
local FormatTime = require(ReplicatedStorage.Source.Core.UI.FormatTime)
local useServerTimeBinding = require(ReplicatedStorage.Source.Core.UI.Hooks.useServerTimeBinding)
local AutoScaledFrame = require(ReplicatedStorage.Source.Core.UI.Primitives.AutoScaledFrame)
local Button = require(ReplicatedStorage.Source.Core.UI.Primitives.Button)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local FriendServiceClient = require(ReplicatedStorage.Source.Features.Friends.FriendServiceClient)
local MutationEvents = require(ReplicatedStorage.Source.Features.Mutations.Modules.MutationEvents)
local MutationSlice = require(ReplicatedStorage.Source.Features.Mutations.MutationSlice)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local e = React.createElement

local CURRENCY_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(226, 255, 192)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 255, 0)),
})

local function CurrencyCounter()
	local txt, setTxt = React.useBinding(FormatCurrency(DataService:get("currency")))
	React.useEffect(function()
		local goal: number = math.round(DataService:get("currency"))
		local current: number = goal
		local updateConn
		local changedConn = DataService:getChangedSignal("currency"):Connect(function(newGoal: number)
			goal = math.round(newGoal)
			if updateConn then
				return
			end

			updateConn = RunService.Heartbeat:Connect(function(dt: number)
				local dist = goal - current
				local speed = if dist < 0 then 4 else 2
				current = math.lerp(current, goal, dt * speed)

				if math.abs(dist) < 1 then
					current = goal
					updateConn:Disconnect()
					updateConn = nil
				end

				setTxt(FormatCurrency(current))
			end)
		end)

		return function()
			changedConn:Destroy()
			if updateConn then
				updateConn:Disconnect()
			end
		end
	end, {})

	return e(TextLabel, {
		Text = txt,
		Size = UDim2.fromOffset(400, 56),
		Position = UDim2.fromOffset(5, 0),
		AnchorPoint = Vector2.new(0, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		Stroke = { Thickness = 3, Color = Color3.fromRGB(24, 55, 7) },
		Gradient = {
			Rotation = 90,
			Color = CURRENCY_GRADIENT,
		},
	})
end

local function FriendBoostCounter()
	local numFriends = ReactCharm.useAtom(FriendServiceClient.friendCount)
	local percent = numFriends * 0.10

	return e(Button, {
		hoverScale = 1,
		Size = UDim2.fromOffset(300, 40),
		Position = UDim2.new(0, 5, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Activated = function()
			SocialService:PromptGameInvite(Players.LocalPlayer)
		end,
	}, {
		e(TextLabel, {
			Text = `Friend Boost +{math.round(percent * 100)}%`,
			Size = UDim2.fromOffset(400, 40),
			TextXAlignment = Enum.TextXAlignment.Left,
			Stroke = { Thickness = 3 },
		}),
	})
end

type EventTimerProps = {
	eventId: string,
	completionTime: number,
}

local function EventTimer(props: EventTimerProps)
	local serverTime = useServerTimeBinding()
	local hovered, setHovered = React.useState(false)
	local remainingTimeTxt = serverTime:map(function(currentTime)
		return FormatTime(math.max(0, props.completionTime - currentTime))
	end)

	local visible = serverTime:map(function(currentTime)
		return currentTime < props.completionTime
	end)

	return e(Button, {
		Image = ImageIds.mutations[props.eventId],
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = visible,
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		OnEnter = function()
			setHovered(true)
		end,
		OnLeave = function()
			setHovered(false)
		end,
	}, {
		Timer = e(TextLabel, {
			Text = remainingTimeTxt,
			Size = UDim2.fromScale(1, 0.3),
			Position = UDim2.fromScale(0.5, 0.9),
			AnchorPoint = Vector2.new(0.5, 1),
			TextXAlignment = Enum.TextXAlignment.Center,
			Stroke = { Thickness = 3 },
		}),

		Info = if hovered
			then e("Frame", {
				Size = UDim2.fromOffset(200, 50),
				Position = UDim2.fromScale(0.8, 0),
				AnchorPoint = Vector2.new(1, 1),
				BackgroundColor3 = Color3.fromRGB(235, 242, 245),
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),

				Stroke = e("UIStroke", {
					Thickness = 2,
					Color = Color3.fromRGB(0, 0, 0),
				}),

				TextLabel = e(TextLabel, {
					Text = MutationEvents.getEvent(props.eventId).description,
					Size = UDim2.fromScale(0.8, 0.8),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Stroke = { Thickness = 2 },
				}),
			})
			else nil,
	})
end

local function EventTimers()
	local timers = ReactCharm.useAtom(MutationSlice.states.activeEvents)

	return e(
		"Frame",
		{
			Size = UDim2.fromOffset(300, 70),
			Position = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = 1,
		},
		{
			Layout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4),
			}),
		},
		Sift.Dictionary.map(timers, function(completionTime: number, eventId: string)
			return e(EventTimer, {
				eventId = eventId,
				completionTime = completionTime,
			})
		end)
	)
end

return function()
	return e(AutoScaledFrame, {
		Size = UDim2.fromOffset(1494, 90),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -8),
		BackgroundTransparency = 1,
	}, {
		CurrencyCounter = e(CurrencyCounter),
		FriendBoostCounter = e(FriendBoostCounter),
		EventTimers = e(EventTimers),
	})
end
