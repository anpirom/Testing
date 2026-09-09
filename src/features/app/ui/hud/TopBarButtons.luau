local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Topbarplus = require(ReplicatedStorage.Packages.Topbarplus)
local Menu = require(ReplicatedStorage.Source.Features.App.UI.Menus.Menu)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)

return function()
	local settingsButton = Topbarplus.new()
	settingsButton:setImage(ImageIds.settingsWhite)
	settingsButton:setImageRatio(1)
	settingsButton:setImageScale(0.6)
	settingsButton:oneClick(true)
	settingsButton:align("Left")
	settingsButton:bindEvent("selected", function()
		Menu.setOpenedMenu("SettingsMenu")
	end)

	return function()
		settingsButton:destroy()
	end
end
