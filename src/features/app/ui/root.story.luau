local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local RootUI = require(script.Parent.RootUI)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local Menu = require(ReplicatedStorage.Source.Features.App.UI.Menus.Menu)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local MonetizationServiceClient = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceClient)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local e = React.createElement

return function(parent)
	DataService:init(DataTemplate)
	MonetizationServiceClient:init(Products)
	local root = ReactRoblox.createRoot(parent)
	local app = e(RootUI)
	root:render(app)

	local menuCleanup = Menu.init()
	Menu.setOpenedMenu("LikeMenu")

	return function()
		menuCleanup()
		root:unmount()
	end
end
