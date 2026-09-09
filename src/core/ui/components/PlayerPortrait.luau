local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement
type PlayerPortraitProps = {
	userId: number?,
	Size: UDim2,
	Position: UDim2,
	StrokeColor: Color3?,
	SizeConstraint: Enum.SizeConstraint?,
	AnchorPoint: Vector2?,
}

return function(props)
	local userId = props.userId
	local imageId = if userId
		then `https://www.roblox.com/headshot-thumbnail/image?userId={userId}&width=128&height=128&format=png`
		else ""

	return e("Frame", {
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		SizeConstraint = props.SizeConstraint,
	}, {
		e(
			"ImageLabel",
			{
				Size = UDim2.fromScale(0.8, 0.8),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = imageId or "",
				ScaleType = Enum.ScaleType.Fit,
			},
			e("UICorner", {
				CornerRadius = UDim.new(1, 0),
			})
		),

		e("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
		e("UIStroke", {
			Color = props.StrokeColor or Color3.fromRGB(79, 79, 79),
			Thickness = 2,
		}),
	})
end

