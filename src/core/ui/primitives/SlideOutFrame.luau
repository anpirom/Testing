local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AutoScaledFrame = require(script.Parent.AutoScaledFrame)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local useSpring = require(ReplicatedStorage.Source.Core.UI.Hooks.useSpring)
local e = React.createElement

type SlideOutProps = AutoScaledFrame.AutoScaledFrameProps & {
	Shown: boolean,
	From: UDim2,
	To: UDim2,
	Frequency: number?,
	Damping: number?,
}

local CUSTOM_SLIDE_OUT_PROPS = { "Shown", "From", "To", "Frequency", "Damping" }

local SlideOutFrame = React.forwardRef(function(props: SlideOutProps, ref)
	local shown = props.Shown
	local from, to = props.From, props.To
	local mounted, setMounted = React.useState(shown)
	local pos, spring = useSpring(if shown then from else to, {
		frequency = props.Frequency or 5,
		dampingRatio = props.Damping or 0.8,
	})

	local safeProps = Sift.Dictionary.removeKeys(props, unpack(CUSTOM_SLIDE_OUT_PROPS))
	safeProps.ref = ref
	safeProps.Position = pos

	React.useEffect(function()
		if shown then
			return
		end

		spring:setGoal(to)
		local discon = spring:onComplete(function()
			if not shown then
				setMounted(false)
			end
		end)

		return discon
	end, { shown, to })

	React.useEffect(function()
		if not shown then
			return
		end

		if not mounted then
			setMounted(true)
			return
		end

		spring:setPosition(to)
		spring:setGoal(from)
	end, { shown, mounted, from, to })

	if not mounted then
		return nil
	end

	return e(AutoScaledFrame, safeProps)
end)

return (SlideOutFrame :: any) :: (props: SlideOutProps) -> React.ReactNode?
