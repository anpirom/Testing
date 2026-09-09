local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local UITypes = require(ReplicatedStorage.Source.Core.UI.UITypes)
local e: typeof(React.createElement) = React.createElement

local DEFAULTS = {
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
}

type ImageLabelProps = UITypes.ImageLabelProps & {
	children: React.ReactNode?,
}

return React.forwardRef(function(props: ImageLabelProps, ref: any)
	local defaultedProps = Sift.Dictionary.merge(DEFAULTS, props)
	defaultedProps.ref = ref
	defaultedProps.children = nil
	return e("ImageLabel", defaultedProps, props.children)
end)
