local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local StudFrame = require(ReplicatedStorage.Source.Features.App.UI.Components.StudFrame)
local e = React.createElement

local GOLD = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 235, 192)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 212, 69)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 137, 27)),
})

local GREEN = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(192, 255, 192)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(69, 255, 69)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(27, 255, 27)),
})

local BLUE = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 247, 255)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(69, 227, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 153, 255)),
})

local PURPLE = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 192, 255)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 69, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 27, 255)),
})

local RED = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 192, 192)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 69, 69)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 27, 27)),
})

local ORANGE = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 224, 192)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 144, 69)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 94, 27)),
})

local GREY = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(224, 224, 224)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(144, 144, 144)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(94, 94, 94)),
})

local function gold(props)
	local newProps = Sift.Dictionary.set(props, "Gradient", GOLD)
	return e(StudFrame, newProps, props.children)
end

local function green(props)
	local newProps = Sift.Dictionary.set(props, "Gradient", GREEN)
	return e(StudFrame, newProps, props.children)
end

local function blue(props)
	local newProps = Sift.Dictionary.set(props, "Gradient", BLUE)
	return e(StudFrame, newProps, props.children)
end

local function purple(props)
	local newProps = Sift.Dictionary.set(props, "Gradient", PURPLE)
	return e(StudFrame, newProps, props.children)
end

local function red(props)
	local newProps = Sift.Dictionary.set(props, "Gradient", RED)
	return e(StudFrame, newProps, props.children)
end

local function orange(props)
	local newProps = Sift.Dictionary.set(props, "Gradient", ORANGE)
	return e(StudFrame, newProps, props.children)
end

local function grey(props)
	local newProps = Sift.Dictionary.set(props, "Gradient", GREY)
	return e(StudFrame, newProps, props.children)
end

return {
	Gold = gold,
	Green = green,
	Blue = blue,
	Purple = purple,
	Red = red,
	Orange = orange,
	Grey = grey,
}
