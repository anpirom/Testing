local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local ColorTweaker = require(ReplicatedStorage.Source.Core.Platform.ColorTweaker)
local UITypes = require(ReplicatedStorage.Source.Core.UI.UITypes)
local e = React.createElement

type StudFrameProps = UITypes.GenericUIProps & {
	Gradient: ColorSequence,
	children: React.ReactNode?,
}

local function Background(props: UITypes.ImageLabelProps)
	local safeProps = Sift.Dictionary.copy(props)
	safeProps.Image = "rbxassetid://12055407192"
	safeProps.ScaleType = Enum.ScaleType.Tile
	safeProps.TileSize = UDim2.fromOffset(50, 50)
	safeProps.BorderSizePixel = 0
	return e("ImageLabel", safeProps)
end

return function(props: StudFrameProps)
	props.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	local safeProps = Sift.Dictionary.removeKeys(props, "Gradient")
	return e("Frame", safeProps, {
		Stroke = e("UIStroke", {
			Color = Color3.fromRGB(0, 0, 0),
			Thickness = 4,
			LineJoinMode = Enum.LineJoinMode.Miter,
		}),

		StrokeInner = e("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Thickness = 4,
			LineJoinMode = Enum.LineJoinMode.Miter,
		}, {
			Gradient = e("UIGradient", {
				Color = ColorTweaker.tweakColorSequence(
					props.Gradient,
					{ saturationBoost = 0.66, valueBoost = 2, primaryColor = ColorTweaker.enums.primaryColors.master }
				),
				Rotation = 90,
			}),
		}),

		Gradient = e("UIGradient", {
			Color = props.Gradient,
			Rotation = 90,
		}),

		Studs = e(Background, {
			Size = UDim2.new(1, -8, 1, -8),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ImageColor3 = props.studColor,
			ZIndex = -1,
			ImageTransparency = 0.2,
		}),
	}, props.children)
end
