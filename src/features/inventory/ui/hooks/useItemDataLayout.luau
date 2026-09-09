local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

return function(itemData: DataTemplate.ItemData)
	return React.useMemo(function()
		if itemData.crateId then
			return -Towers.getTowerInfo(itemData.crateId).layoutOrder
		else
			return 1e3 - Towers.getTowerInfo(itemData.itemId).layoutOrder
		end
	end, { itemData })
end
