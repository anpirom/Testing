local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local ItemIcon = require(script.Parent.ItemIcon)
local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local Button = require(ReplicatedStorage.Source.Core.UI.Primitives.Button)
local InventoryServiceClient = require(ReplicatedStorage.Source.Features.Inventory.InventoryServiceClient)
local InventorySlice = require(ReplicatedStorage.Source.Features.Inventory.InventorySlice)
local useInventoryItemVisibility =
	require(ReplicatedStorage.Source.Features.Inventory.UI.Hooks.useInventoryItemVisibility)
local useItemDataLayout = require(ReplicatedStorage.Source.Features.Inventory.UI.Hooks.useItemDataLayout)
local useItemDragger = require(ReplicatedStorage.Source.Features.Inventory.UI.Hooks.useItemDragger)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local e = React.createElement

type InventoryButtonProps = {
	itemData: DataTemplate.ItemData,
	uniqueId: string,
}

return function(props: InventoryButtonProps)
	local uniqueId = props.uniqueId
	local holdingTimeStart, setHoldingTimeStart = React.useState(nil :: number?)
	local setDragStart = useItemDragger(uniqueId)
	local equippedUniqueId = ReactCharm.useAtom(InventorySlice.state.equippedItemUniqueId)
	local visible = useInventoryItemVisibility(uniqueId, false)
	local layoutOrder = useItemDataLayout(props.itemData)
	if not visible then
		return nil
	end

	return e(Button, {
		hoverScale = 1,
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
		Activated = function()
			local isEquipped = equippedUniqueId == uniqueId
			if isEquipped then
				InventoryServiceClient:unequipItem()
			else
				InventoryServiceClient:equipItem(uniqueId)
			end
		end,
		OnLeave = function()
			setHoldingTimeStart(nil)
		end,
		OnUp = function()
			setHoldingTimeStart(nil)
			if not holdingTimeStart then
				return
			end

			local heldTime = os.clock() - holdingTimeStart
			if heldTime >= 1 and not InventorySlice.state.draggingItemUniqueId() then
				InventoryServiceClient:faveItem(uniqueId)
			end
		end,
		OnDown = function()
			local loc = UserInputService:GetMouseLocation()
			setDragStart(loc)
			setHoldingTimeStart(os.clock())
		end,
	}, {
		Icon = e(ItemIcon, {
			Size = UDim2.fromScale(1, 1),
			itemData = props.itemData,
			equipped = equippedUniqueId == uniqueId,
		}),
	})
end
