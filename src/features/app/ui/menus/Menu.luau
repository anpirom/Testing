local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Charm = require(ReplicatedStorage.Packages.Charm)
local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local Ripple = require(ReplicatedStorage.Packages.Ripple)
local Button = require(ReplicatedStorage.Source.Core.UI.Primitives.Button)
local SlideOutFrame = require(ReplicatedStorage.Source.Core.UI.Primitives.SlideOutFrame)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local StudBackground = require(ReplicatedStorage.Source.Features.App.UI.Components.StudBackground)
local Screen = require(ReplicatedStorage.Source.Features.App.UI.Screens.Screen)
local e = React.createElement

local openedMenu = Charm.atom(nil :: string?)
local hasInitialized = false

local function init()
	if not RunService:IsRunning() then
		return function() end
	end

	if hasInitialized then
		warn("Menu module has already been initialized!")
		return
	end

	hasInitialized = true
	local blur = Instance.new("BlurEffect")
	blur.Size = 0
	blur.Name = "MenuBlur"
	blur.Parent = Lighting
	local camera = workspace.CurrentCamera
	local spring = Ripple.createSpring(0, { frequency = 3, dampingRatio = 0.8, start = true })
	spring:onChange(function(value)
		blur.Size = value * 16
		camera.FieldOfView = 70 - value * 10
	end)

	local discon = Charm.subscribe(function()
		return openedMenu() or Screen.openedScreen()
	end, function(menuName)
		if menuName then
			spring:setGoal(1)
		else
			spring:setGoal(0)
		end
	end)

	return function()
		discon()
		blur:Destroy()
		spring:destroy()
	end
end

local function setOpenedMenu(menuName: string?)
	if openedMenu() == menuName then
		openedMenu(nil)
	else
		openedMenu(menuName)
	end
end

type MenuProps = {
	menuName: string,
	children: React.ReactNode?,
	Title: string?,
	Prefix: any?,
	Size: UDim2?,
	From: UDim2?,
	To: UDim2?,
	OnOpen: (() -> ())?,
	OnClose: (() -> ())?,
}

local function Menu(props: MenuProps)
	local openedScreen = ReactCharm.useAtom(Screen.openedScreen)
	local firstTimeRef = React.useRef(true)
	local isOpen = ReactCharm.useAtom(function()
		return openedMenu() == props.menuName
	end)

	React.useEffect(function()
		if firstTimeRef.current then
			firstTimeRef.current = false
			return
		end

		if isOpen and props.OnOpen then
			props.OnOpen()
		elseif not isOpen and props.OnClose then
			props.OnClose()
		end
	end, { isOpen })

	return e(SlideOutFrame, {
		Shown = isOpen and openedScreen == nil,
		From = props.From or UDim2.fromScale(0.5, 0.5),
		To = props.To or UDim2.fromScale(0.5, -0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = props.Size or UDim2.fromOffset(600, 400),
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BackgroundTransparency = 0.5,
	}, {
		Stroke = e("UIStroke", {
			Thickness = 3,
			Color = Color3.fromRGB(20, 20, 20),
		}),

		Content = e("Frame", {
			Size = UDim2.new(1, 0, 1, -50),
			Position = UDim2.fromScale(0, 1),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
		}, props.children),

		TopBar = e(StudBackground, {
			Size = UDim2.new(1, 0, 0, 50),
			Position = UDim2.fromScale(0, 0),
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		}, {
			Title = e(TextLabel, {
				Text = props.Title,
				Size = UDim2.fromScale(0.8, 0.8),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.01, 0.5),
				Stroke = { Thickness = 3, Color = Color3.fromRGB(20, 20, 20) },
				TextXAlignment = Enum.TextXAlignment.Left,
				Prefix = props.Prefix,
			}),

			Stroke = e("UIStroke", {
				Thickness = 3,
				Color = Color3.fromRGB(20, 20, 20),
			}),

			Gradient = e("UIGradient", {
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(0.21, Color3.fromRGB(71, 230, 255)),
					ColorSequenceKeypoint.new(0.87, Color3.fromRGB(10, 143, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 68, 117)),
				}),
			}),
		}),

		X = e(Button, {
			hoverScale = 1,
			Size = UDim2.fromOffset(50, 50),
			Position = UDim2.fromScale(1, 0),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			ZIndex = 2,
			Activated = function()
				if openedMenu() == props.menuName then
					openedMenu(nil)
				end
			end,
		}, {
			Text = e(TextLabel, {
				Text = "X",
				Size = UDim2.fromScale(0.85, 0.85),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Stroke = { Thickness = 3, Color = Color3.fromRGB(117, 4, 4) },
			}),

			Bg = e(StudBackground, {
				Size = UDim2.new(1, 0, 0, 50),
				Position = UDim2.fromScale(0, 0),
				ImageColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			}, {

				Stroke = e("UIStroke", {
					Thickness = 3,
					Color = Color3.fromRGB(20, 20, 20),
				}),

				Gradient = e("UIGradient", {
					Rotation = 90,
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
						ColorSequenceKeypoint.new(0.15, Color3.fromRGB(255, 71, 71)),
						ColorSequenceKeypoint.new(0.87, Color3.fromRGB(255, 10, 10)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(117, 4, 4)),
					}),
				}),
			}),
		}),
	})
end

if RunService:IsRunning() then
	init()
end

return {
	init = init,
	openedMenu = openedMenu,
	setOpenedMenu = setOpenedMenu,
	Component = Menu,
}
