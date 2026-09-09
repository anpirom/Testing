local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local useDataState = require(ReplicatedStorage.Source.Core.UI.Hooks.useDataState)
local useSpring = require(ReplicatedStorage.Source.Core.UI.Hooks.useSpring)
local AutoScaledFrame = require(ReplicatedStorage.Source.Core.UI.Primitives.AutoScaledFrame)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local TutorialInstructions = require(ReplicatedStorage.Source.Features.Tutorial.Modules.TutorialInstructions)
local e = React.createElement

return function()
	local completed = useDataState({ "tutorial", "completed" })
	local step: string? = useDataState({ "tutorial", "step" })
	local binding, spring = useSpring(0.5, { dampingRatio = 0.8, frequency = 1 }, 1)

	React.useEffect(function()
		spring:impulse(5)
	end, { step })

	if completed or not step then
		return
	end

	local instruction = TutorialInstructions[step]
	if not instruction or not instruction.text then
		return
	end

	return e(AutoScaledFrame, {
		Size = UDim2.fromOffset(1000, 50),
		Position = UDim2.fromScale(0.5, 0.2),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ZIndex = 999,
	}, {
		e("Frame", {
			Size = binding:map(function(value)
				return UDim2.fromScale(value, value)
			end),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		}, {
			e("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.5, 0),
					NumberSequenceKeypoint.new(1, 1),
				}),
			}),

			e(TextLabel, {
				Size = UDim2.fromScale(1, 0.8),
				Position = UDim2.fromScale(0, 0.5),
				AnchorPoint = Vector2.new(0, 0.5),
				Text = instruction.text:upper(),
				Stroke = {},
			}),
		}),
	})
end
