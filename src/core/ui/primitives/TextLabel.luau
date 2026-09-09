--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local UITypes = require(ReplicatedStorage.Source.Core.UI.UITypes)
local e: typeof(React.createElement) = React.createElement

type CanBeBinding<T> = UITypes.CanBeBinding<T>
type TextLabelConstructor = (props: TextLabelProps) -> React.ReactNode?

type Stroke = {
	Thickness: CanBeBinding<number>?,
	Color: CanBeBinding<Color3>?,
	Transparency: CanBeBinding<number>?,
	StrokeSizingMode: CanBeBinding<Enum.StrokeSizingMode>?,
}

type DropShadow = {
	Offset: UDim2?,
	Color: CanBeBinding<Color3>?,
	Transparency: CanBeBinding<number>?,
}

type Gradient = {
	Color: CanBeBinding<ColorSequence>?,
	Transparency: CanBeBinding<NumberSequence>?,
	Rotation: CanBeBinding<number>?,
}

type TextImage = {
	Image: CanBeBinding<string>?,
	Size: CanBeBinding<UDim2>?,
	HorizontalAlignment: CanBeBinding<Enum.HorizontalAlignment>?,
	VerticalAlignment: CanBeBinding<Enum.VerticalAlignment>?,
	Padding: CanBeBinding<UDim>?,
	SizeConstraint: CanBeBinding<Enum.SizeConstraint>?,
	ImageColor3: CanBeBinding<Color3>?,
	ImageTransparency: CanBeBinding<number>?,
}

export type TextLabelProps = UITypes.GenericUIProps & {
	Text: CanBeBinding<string>?,
	TextColor3: CanBeBinding<Color3>?,
	TextSize: CanBeBinding<number>?,
	TextTransparency: CanBeBinding<number>?,
	Font: CanBeBinding<Enum.Font>?,
	TextScaled: CanBeBinding<boolean>?,
	TextXAlignment: CanBeBinding<Enum.TextXAlignment>?,
	TextYAlignment: CanBeBinding<Enum.TextYAlignment>?,
	TextWrapped: CanBeBinding<boolean>?,
	RichText: CanBeBinding<boolean>?,
	Stroke: Stroke?,
	DropShadow: DropShadow?,
	Gradient: Gradient?,
	Prefix: TextImage?,
	Suffix: TextImage?,
	children: React.ReactNode?,
}

local TEXTLABEL_DEFAULTS = {
	BackgroundTransparency = 1,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.BuilderSansExtraBold,
	TextScaled = true,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	ZIndex = 1,
}

local DROP_SHADOW_DEFAULTS = {
	Offset = UDim2.fromOffset(0, 4),
	Color = Color3.fromRGB(0, 0, 0),
	Transparency = 0,
}

local STROKE_DEFAULTS = {
	Thickness = 2,
	Color = Color3.fromRGB(0, 0, 0),
	Transparency = 0,
}

local TextLabel = React.forwardRef(function(props: TextLabelProps, ref: any)
	return e("Frame", {
		BackgroundTransparency = props.BackgroundTransparency or 1,
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		ZIndex = props.ZIndex,
		Rotation = props.Rotation,
		BackgroundColor3 = props.BackgroundColor3,
		LayoutOrder = props.LayoutOrder,
		Visible = props.Visible,
		SizeConstraint = props.SizeConstraint,
		AutomaticSize = props.AutomaticSize,
	}, {
		TextLabel = e("TextLabel", {
			Text = props.Text,
			TextColor3 = props.TextColor3 or TEXTLABEL_DEFAULTS.TextColor3,
			TextSize = props.TextSize,
			TextScaled = if props.TextSize then false else (props.TextScaled or TEXTLABEL_DEFAULTS.TextScaled),
			Font = props.Font or TEXTLABEL_DEFAULTS.Font,
			TextTransparency = props.TextTransparency,
			TextXAlignment = props.TextXAlignment,
			TextYAlignment = props.TextYAlignment,
			TextWrapped = props.TextWrapped,
			AutomaticSize = props.AutomaticSize or (if props.Prefix or props.Suffix then Enum.AutomaticSize.X else nil),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Size = if props.Prefix or props.Suffix then UDim2.fromScale(0, 1) else UDim2.fromScale(1, 1),
			ZIndex = 1,
			LayoutOrder = 1,
			RichText = props.RichText,
			ref = ref,
		}, {
			Stroke = if props.Stroke then e("UIStroke", Sift.Dictionary.merge(STROKE_DEFAULTS, props.Stroke)) else nil,
			Gradient = if props.Gradient then e("UIGradient", props.Gradient) else nil,
		}, props.children),

		DropShadow = if props.DropShadow
			then e("TextLabel", {
				Text = props.Text,
				TextColor3 = props.DropShadow.Color or DROP_SHADOW_DEFAULTS.Color,
				TextSize = props.TextSize,
				TextScaled = if props.TextSize then false else (props.TextScaled or TEXTLABEL_DEFAULTS.TextScaled),
				Font = props.Font or TEXTLABEL_DEFAULTS.Font,
				TextTransparency = props.DropShadow.Transparency or DROP_SHADOW_DEFAULTS.Transparency,
				TextXAlignment = props.TextXAlignment,
				TextYAlignment = props.TextYAlignment,
				TextWrapped = props.TextWrapped,
				Position = UDim2.fromScale(0.5, 0.5) + (props.DropShadow.Offset or DROP_SHADOW_DEFAULTS.Offset),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				RichText = props.RichText,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 0,
			})
			else nil,

		Layout = if props.Prefix or props.Suffix
			then e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = if props.Prefix and props.Prefix.HorizontalAlignment
					then props.Prefix.HorizontalAlignment
					elseif props.Suffix and props.Suffix.HorizontalAlignment then props.Suffix.HorizontalAlignment
					else Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = if props.Prefix and props.Prefix.Padding
					then props.Prefix.Padding
					elseif props.Suffix and props.Suffix.Padding then props.Suffix.Padding
					else UDim.new(0, 4),
			})
			else nil,

		Prefix = if props.Prefix
			then e("ImageLabel", {
				BackgroundTransparency = 1,
				Size = props.Prefix.Size or UDim2.fromScale(1, 1),
				SizeConstraint = props.Prefix.SizeConstraint or Enum.SizeConstraint.RelativeYY,
				LayoutOrder = 0,
				ScaleType = Enum.ScaleType.Fit,
				Image = props.Prefix.Image,
				ImageColor3 = props.Prefix.ImageColor3,
				ImageTransparency = props.Prefix.ImageTransparency,
			})
			else nil,

		Suffix = if props.Suffix
			then e("ImageLabel", {
				BackgroundTransparency = 1,
				Size = props.Suffix.Size or UDim2.fromScale(1, 1),
				SizeConstraint = props.Suffix.SizeConstraint or Enum.SizeConstraint.RelativeYY,
				LayoutOrder = 2,
				ScaleType = Enum.ScaleType.Fit,
				Image = props.Suffix.Image,
				ImageColor3 = props.Suffix.ImageColor3,
				ImageTransparency = props.Suffix.ImageTransparency,
			})
			else nil,
	})
end)

return (TextLabel :: any) :: TextLabelConstructor
