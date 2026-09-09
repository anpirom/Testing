local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local useViewportSize = require(ReplicatedStorage.Source.Core.UI.Hooks.useViewportSize)
local e = React.createElement

local STUDIO_SIZE = Vector2.new(1500, 803)

type AutoScaledFrameConstructor = (props: AutoScaledFrameProps) -> React.ReactNode?
export type AutoScaledFrameProps = {
	ScaleFactor: number?,
	MinSize: Vector2?,
	Size: UDim2,
	Position: UDim2?,
	Rotation: number?,
	AnchorPoint: Vector2?,
	BackgroundTransparency: number?,
	BackgroundColor3: Color3?,
	LayoutOrder: number?,
	ZIndex: number?,
	Visible: boolean?,
	children: React.ReactNode?,
}

local AutoScaledFrame = React.forwardRef(function(props: AutoScaledFrameProps, ref: React.Ref<any>)
	local screenSize = useViewportSize()
	local minSize = props.MinSize or Vector2.zero
	local scaleFactor = props.ScaleFactor or 1
	local scaleBinding, setScale = React.useBinding(scaleFactor)
	local minScale = React.useMemo(function()
		return math.max(minSize.X / props.Size.X.Offset, minSize.Y / props.Size.Y.Offset)
	end, { screenSize, minSize, props.Size })

	React.useEffect(function()
		local newScale = scaleFactor * math.min(screenSize.X / STUDIO_SIZE.X, screenSize.Y / STUDIO_SIZE.Y)
		setScale(math.max(newScale, minScale))
	end, { screenSize, minSize, scaleFactor })

	return e("Frame", {
		Visible = props.Visible,
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Rotation = props.Rotation,
		ZIndex = props.ZIndex,
		BackgroundTransparency = props.BackgroundTransparency or 1,
		BackgroundColor3 = props.BackgroundColor3,
		LayoutOrder = props.LayoutOrder,
		ref = ref,
	}, {
		e("UIScale", {
			Scale = scaleBinding,
		}),
		props.children,
	})
end)

return (AutoScaledFrame :: any) :: AutoScaledFrameConstructor
