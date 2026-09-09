local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SoundController = require(ReplicatedStorage.Source.Core.Platform.SoundController)
local useSpring = require(ReplicatedStorage.Source.Core.UI.Hooks.useSpring)
local UITypes = require(ReplicatedStorage.Source.Core.UI.UITypes)
local Sounds = require(ReplicatedStorage.Source.Game.Assets.Sounds)
local e: typeof(React.createElement) = React.createElement

export type ButtonProps = UITypes.ImageLabelProps & {
	hoverScale: number?,
	children: React.ReactNode?,
	Activated: (() -> ())?,
	OnEnter: (() -> ())?,
	OnLeave: (() -> ())?,
	OnDown: (() -> ())?,
	OnUp: (() -> ())?,
}

type ButtonConstructor = (props: ButtonProps) -> React.ReactNode?

local CUSTOM_PROPS = { "hoverScale", "Activated", "OnEnter", "OnLeave", "OnDown", "OnUp" }

local DEFAULTS = {
	BackgroundTransparency = 1,
	AutoButtonColor = false,
}

local Button = React.forwardRef(function(props: ButtonProps, ref: any)
	local hoverScale = props.hoverScale or 1.2
	local scale, scaleMotion = useSpring(1, { frequency = 5, dampingRatio = 0.7 })
	local safeProps = Sift.Dictionary.removeKeys(props, table.unpack(CUSTOM_PROPS))
	safeProps.ref = ref
	safeProps.BackgroundTransparency = safeProps.BackgroundTransparency or DEFAULTS.BackgroundTransparency
	safeProps.AutoButtonColor = safeProps.AutoButtonColor or DEFAULTS.AutoButtonColor
	safeProps.children = nil

	safeProps[React.Event.MouseEnter] = function()
		SoundController:Play(Sounds.ui.hover)
		scaleMotion:setGoal(hoverScale)
		if props.OnEnter then
			props.OnEnter()
		end
	end

	safeProps[React.Event.MouseLeave] = function()
		scaleMotion:setGoal(1)
		if props.OnLeave then
			props.OnLeave()
		end
	end

	safeProps[React.Event.MouseButton1Down] = function()
		SoundController:Play(Sounds.ui.mouseDown)
		if props.OnDown then
			props.OnDown()
		end
	end

	safeProps[React.Event.MouseButton1Up] = function()
		SoundController:Play(Sounds.ui.mouseUp)
		if props.OnUp then
			props.OnUp()
		end
	end

	safeProps[React.Event.Activated] = props.Activated

	return e("ImageButton", safeProps, e("UIScale", { Scale = scale }), props.children)
end)

return (Button :: any) :: ButtonConstructor
