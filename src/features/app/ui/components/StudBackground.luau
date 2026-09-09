local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local UITypes = require(ReplicatedStorage.Source.Core.UI.UITypes)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local e = React.createElement

local DEFAULTS = {
	TileSize = UDim2.fromOffset(100, 100),
}

return function(props: UITypes.ImageLabelProps)
	local safeProps = Sift.Dictionary.copy(props)
	safeProps.Image = ImageIds.studBackground
	safeProps.ScaleType = Enum.ScaleType.Tile
	safeProps.TileSize = props.TileSize or DEFAULTS.TileSize
	safeProps.BorderSizePixel = 0
	return e("ImageLabel", safeProps)
end
