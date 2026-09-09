local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local useSpring = require(ReplicatedStorage.Source.Core.UI.Hooks.useSpring)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local e = React.createElement
local atom = Charm.atom

local messages: Charm.Atom<{ TextLabel.TextLabelProps }> = atom({})
local id = 0

type NotificationMessageProps = {
	i: number,
	props: TextLabel.TextLabelProps,
}

local function ErrorMessage(props: NotificationMessageProps)
	local sizeSpringBinding, sizeSpring =
		useSpring(UDim2.fromScale(0, 0), { frequency = 2.5, damping = 1 }, UDim2.fromScale(1, 1))

	React.useEffect(function()
		local d2
		local thread = task.delay(6, function()
			sizeSpring:setGoal(UDim2.fromScale(0, 0))
			d2 = sizeSpring:onComplete(function()
				messages(function(current: { TextLabel.TextLabelProps })
					return Sift.Dictionary.removeKey(current, props.i)
				end)
			end)
		end)

		return function()
			if thread then
				task.cancel(thread)
			end
			if d2 then
				d2()
			end
		end
	end, {})

	props.props.Size = props.props.Size or UDim2.fromScale(1, 1)
	return e("Frame", {
		LayoutOrder = -props.i,
		Size = sizeSpringBinding,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.25,
	}, {
		Gradient = e("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.33, 0.5),
				NumberSequenceKeypoint.new(0.66, 0.5),
				NumberSequenceKeypoint.new(1, 1),
			}),
		}),

		Txt = e(TextLabel, props.props),
	})
end

local Component = function()
	local currentMessages = ReactCharm.useAtom(messages)

	local errorMessages = React.useMemo(function()
		local tbl = {}

		for i, props in currentMessages do
			tbl[i] = e(ErrorMessage, {
				i = i,
				props = props,
			})
		end

		return tbl
	end, { currentMessages })

	if next(errorMessages) == nil then
		return nil
	end

	return e("Frame", {
		Size = UDim2.new(0.55, 0, 0, 42),
		Position = UDim2.fromScale(0.5, 0.25),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		ZIndex = 2 ^ 31 - 1,
	}, {
		errorMessages,
		e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.1, 0),
		}),
	})
end

local function add(props: TextLabel.TextLabelProps)
	id += 1
	messages(function(current: { TextLabel.TextLabelProps })
		return Sift.Dictionary.set(current, id, props)
	end)
end

return {
	Component = Component,
	add = add,
}
