local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

export type CanBeBinding<T> = T | React.Binding<T>
export type Children = React.ReactNode | { React.ReactNode } | any

export type GenericUIProps = {
	Active: CanBeBinding<boolean>?,
	BackgroundTransparency: CanBeBinding<number>?,
	Size: CanBeBinding<UDim2>?,
	Position: CanBeBinding<UDim2>?,
	AnchorPoint: CanBeBinding<Vector2>?,
	ScaleType: CanBeBinding<Enum.ScaleType>?,
	BackgroundColor3: CanBeBinding<Color3>?,
	ClipsDescendants: CanBeBinding<boolean>?,
	LayoutOrder: CanBeBinding<number>?,
	ZIndex: CanBeBinding<number>?,
	Visible: CanBeBinding<boolean>?,
	Rotation: CanBeBinding<number>?,
	SizeConstraint: CanBeBinding<Enum.SizeConstraint>?,
	AutomaticSize: CanBeBinding<Enum.AutomaticSize>?,
}

export type ImageLabelProps = GenericUIProps & {
	Image: CanBeBinding<string>?,
	ImageColor3: CanBeBinding<Color3>?,
	ImageTransparency: CanBeBinding<number>?,
	ImageRectOffset: CanBeBinding<Vector2>?,
	ImageRectSize: CanBeBinding<Vector2>?,
	SliceCenter: CanBeBinding<Rect>?,
	TileSize: CanBeBinding<UDim2>?,
}

return nil
