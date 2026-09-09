local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local UITypes = require(ReplicatedStorage.Source.Core.UI.UITypes)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local e = React.createElement

return function(props: UITypes.GenericUIProps)
	local safeProps = Sift.Dictionary.copy(props)
	safeProps.Image = ImageIds.insetFrame
	safeProps.ScaleType = Enum.ScaleType.Slice
	safeProps.SliceCenter = Rect.new(31, 33, 109, 99)
	safeProps.BackgroundTransparency = 1
	return e("ImageLabel", safeProps, safeProps.children)
end
