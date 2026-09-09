local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local UITypes = require(ReplicatedStorage.Source.Core.UI.UITypes)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local e = React.createElement

type MutationIconsProps = UITypes.GenericUIProps & {
	mutations: DataTemplate.Mutations,
	HorizontalAlignment: Enum.HorizontalAlignment?,
	VerticalAlignment: Enum.VerticalAlignment?,
	FillDirection: Enum.FillDirection?,
}

local CUSTOM_PROPS = {
	"mutations",
	"HorizontalAlignment",
	"VerticalAlignment",
	"FillDirection",
}

return function(props: MutationIconsProps)
	local safeProps = Sift.Dictionary.removeKeys(props, unpack(CUSTOM_PROPS))
	safeProps.BackgroundTransparency = safeProps.BackgroundTransparency or 1
	return e(
		"Frame",
		safeProps,
		{
			Layout = e("UIListLayout", {
				FillDirection = props.FillDirection or Enum.FillDirection.Horizontal,
				HorizontalAlignment = props.HorizontalAlignment or Enum.HorizontalAlignment.Center,
				VerticalAlignment = props.VerticalAlignment or Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4),
			}),
		},
		Sift.Dictionary.map(props.mutations, function(owned: boolean, mutationName: string)
			if not owned then
				return nil
			end

			return e("ImageLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = ImageIds.mutations[mutationName],
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
			}),
				mutationName
		end)
	)
end
