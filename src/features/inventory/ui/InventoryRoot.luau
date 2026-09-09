local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local DraggedItem = require(ReplicatedStorage.Source.Features.Inventory.UI.Screens.DraggedItem)
local InventoryHud = require(ReplicatedStorage.Source.Features.Inventory.UI.Screens.InventoryHud)
local e = React.createElement

return function()
	return e(React.Fragment, nil, {
		InventoryBottom = e(InventoryHud),
		DraggedItem = e(DraggedItem),
	})
end
