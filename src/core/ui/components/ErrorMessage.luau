local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local useSpring = require(ReplicatedStorage.Source.Core.UI.Hooks.useSpring)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local e = React.createElement
local atom = Charm.atom

local errors: Charm.Atom<{ string }> = atom({})
local id = 0

type ErrorMessageProps = {
	i: number,
	message: string,
}

local function ErrorMessage(props: ErrorMessageProps)
	local sizeSpringBinding, sizeSpring =
		useSpring(UDim2.fromScale(0, 0), { frequency = 2.5, damping = 1 }, UDim2.fromScale(1, 1))

	React.useEffect(function()
		local d2
		local thread = task.delay(3, function()
			sizeSpring:setGoal(UDim2.fromScale(0, 0))
			d2 = sizeSpring:onComplete(function()
				errors(function(current: { string })
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

	return e("Frame", {
		LayoutOrder = props.i,
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

		Txt = e(TextLabel, {
			Text = props.message,
			Size = UDim2.fromScale(1, 1),
			TextColor3 = Color3.fromRGB(255, 0, 0),
			Stroke = {
				Color = Color3.fromRGB(87, 0, 0),
				Thickness = 2,
			},
		}),
	})
end

local Component = function()
	local currentErrors = ReactCharm.useAtom(errors)

	local errorMessages = React.useMemo(function()
		local tbl = {}

		for i, message in currentErrors do
			tbl[i] = e(ErrorMessage, {
				i = i,
				message = message,
			})
		end

		return tbl
	end, { currentErrors })

	if next(errorMessages) == nil then
		return nil
	end

	return e("Frame", {
		Size = UDim2.new(0.55, 0, 0, 30),
		Position = UDim2.fromScale(0.5, 0.7),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 1,
		ZIndex = 2 ^ 31 - 1,
	}, {
		errorMessages,
		e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.1, 0),
		}),
	})
end

local function add(message: string)
	id += 1
	errors(function(current: { string })
		return Sift.Dictionary.set(current, id, message)
	end)
end

return {
	Component = Component,
	add = add,
}
