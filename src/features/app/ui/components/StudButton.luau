local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StudBackground = require(script.Parent.StudBackground)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Button = require(ReplicatedStorage.Source.Core.UI.Primitives.Button)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local e = React.createElement

type StudButtonProps = Button.ButtonProps & {
	StudSize: number?,
	Text: string?,
	StrokeColor: Color3?,
	StrokeThickness: number?,
	StudGradient: ColorSequence?,
}

local CUSTOM_PROPS = {
	"StudSize",
	"Text",
	"StrokeColor",
	"StrokeThickness",
	"StudGradient",
}

local StudButton = function(props: StudButtonProps)
	local safeProps = Sift.Dictionary.removeKeys(props, unpack(CUSTOM_PROPS))
	safeProps.hoverScale = props.hoverScale or 1.1
	return e(Button, safeProps, {
		Background = e(StudBackground, {
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			TileSize = if props.StudSize then UDim2.fromOffset(props.StudSize, props.StudSize) else nil,
			Size = UDim2.fromScale(1, 1),
		}, {
			Gradient = e("UIGradient", {
				Rotation = 90,
				Color = props.StudGradient,
			}),
		}),

		Stroke = e("UIStroke", {
			Thickness = props.StrokeThickness or 3,
			Color = props.StrokeColor or Color3.new(0, 0, 0),
		}),

		Text = if props.Text
			then e(TextLabel, {
				Text = props.Text,
				Size = UDim2.fromScale(0.95, 0.7),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Stroke = {},
			})
			else nil,
	}, props.children)
end

local GREEN_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.21, Color3.fromRGB(108, 255, 71)),
	ColorSequenceKeypoint.new(0.87, Color3.fromRGB(51, 255, 10)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 117, 4)),
})

local WHITE_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200)),
})

local BLUE_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.21, Color3.fromRGB(71, 108, 255)),
	ColorSequenceKeypoint.new(0.87, Color3.fromRGB(10, 51, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 40, 117)),
})

local TEAL_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.21, Color3.fromRGB(71, 255, 216)),
	ColorSequenceKeypoint.new(0.87, Color3.fromRGB(10, 205, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 117, 157)),
})

local GOLD_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.21, Color3.fromRGB(255, 211, 108)),
	ColorSequenceKeypoint.new(0.87, Color3.fromRGB(255, 215, 57)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(201, 107, 0)),
})

local BLACK_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 100, 100)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
})

local PURPLE_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.21, Color3.fromRGB(178, 71, 255)),
	ColorSequenceKeypoint.new(0.87, Color3.fromRGB(105, 10, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(57, 4, 117)),
})

local function Purple(props: StudButtonProps)
	return e(
		StudButton,
		Sift.Dictionary.merge(props, {
			StudGradient = PURPLE_GRADIENT,
		})
	)
end

local function Green(props: StudButtonProps)
	return e(
		StudButton,
		Sift.Dictionary.merge(props, {
			StudGradient = GREEN_GRADIENT,
		})
	)
end

local function White(props: StudButtonProps)
	return e(
		StudButton,
		Sift.Dictionary.merge(props, {
			StudGradient = WHITE_GRADIENT,
		})
	)
end

local function Blue(props: StudButtonProps)
	return e(
		StudButton,
		Sift.Dictionary.merge(props, {
			StudGradient = BLUE_GRADIENT,
		})
	)
end

local function Gold(props: StudButtonProps)
	return e(
		StudButton,
		Sift.Dictionary.merge(props, {
			StudGradient = GOLD_GRADIENT,
		})
	)
end

local function Teal(props: StudButtonProps)
	return e(
		StudButton,
		Sift.Dictionary.merge(props, {
			StudGradient = TEAL_GRADIENT,
		})
	)
end

local function Black(props: StudButtonProps)
	return e(
		StudButton,
		Sift.Dictionary.merge(props, {
			StudGradient = BLACK_GRADIENT,
		})
	)
end

local function Red(props: StudButtonProps)
	return e(
		StudButton,
		Sift.Dictionary.merge(props, {
			StudGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(0.21, Color3.fromRGB(255, 71, 71)),
				ColorSequenceKeypoint.new(0.87, Color3.fromRGB(255, 10, 10)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(117, 4, 4)),
			}),
		})
	)
end

return {
	Green = Green,
	Component = StudButton,
	White = White,
	Blue = Blue,
	Gold = Gold,
	Teal = Teal,
	Purple = Purple,
	Black = Black,
	Red = Red,
}
