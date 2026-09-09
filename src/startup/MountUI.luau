local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local TopBarButtons = require(ReplicatedStorage.Source.Features.App.UI.Hud.TopBarButtons)
local RootUI = require(ReplicatedStorage.Source.Features.App.UI.RootUI)
local e = React.createElement

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

return function()
	local container = Instance.new("ScreenGui")
	container.Name = "React"
	container.IgnoreGuiInset = true
	container.ResetOnSpawn = false
	container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	container.ClipToDeviceSafeArea = false
	container.Parent = playerGui
	local root = ReactRoblox.createRoot(container)
	local app = e(RootUI)
	root:render(app)
	TopBarButtons()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end
