local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local UITypes = require(ReplicatedStorage.Source.Core.UI.UITypes)
local e = React.createElement

return function(
	props: UITypes.GenericUIProps & { children: React.ReactNode?, Thickness: number?, StrokeColor: Color3? }
)
	local safeProps = Sift.Dictionary.removeKeys(props, "Thickness", "StrokeColor")
	safeProps.BackgroundTransparency = 0.5
	safeProps.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	return e("Frame", safeProps, {
		Stroke = e("UIStroke", {
			Thickness = props.Thickness or 3,
			Color = props.StrokeColor or Color3.fromRGB(20, 20, 20),
		}),
	}, props.children)
end
