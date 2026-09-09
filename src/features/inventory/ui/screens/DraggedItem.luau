local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local useDataState = require(ReplicatedStorage.Source.Core.UI.Hooks.useDataState)
local useSpring = require(ReplicatedStorage.Source.Core.UI.Hooks.useSpring)
local useViewportSize = require(ReplicatedStorage.Source.Core.UI.Hooks.useViewportSize)
local InventoryServiceClient = require(ReplicatedStorage.Source.Features.Inventory.InventoryServiceClient)
local InventorySlice = require(ReplicatedStorage.Source.Features.Inventory.InventorySlice)
local ItemIcon = require(ReplicatedStorage.Source.Features.Inventory.UI.Components.ItemIcon)
local e = React.createElement

local SLOT_SIZE = 75

local function DraggedItemFrame(props)
	local itemData = useDataState({ "inventory", props.draggedUniqueId })
	local vpSize = useViewportSize()
	local pos, spring = useSpring(UserInputService:GetMouseLocation(), { dampingRatio = 0.5, frequency = 3 })

	React.useEffect(function()
		local connection = UserInputService.InputChanged:Connect(function(input)
			if not InventorySlice.state.draggingItemUniqueId() then
				return
			end

			local inset = GuiService:GetGuiInset()
			local mousePos = Vector2.new(input.Position.X, input.Position.Y) + inset
			if mousePos.Y > vpSize.Y - 95 then
				InventorySlice.state.inventoryScrollable(false)
			end

			spring:setGoal(mousePos)
		end)

		local endConn = UserInputService.InputEnded:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				local slot = InventorySlice.state.hoveredSlot()
				local uniqueId = props.draggedUniqueId
				InventoryServiceClient:moveItem(uniqueId, slot)
				InventorySlice.state.draggingItemUniqueId(nil)
				InventorySlice.state.hoveredSlot(nil)
				InventorySlice.state.inventoryScrollable(true)
			end
		end)

		return function()
			connection:Disconnect()
			endConn:Disconnect()
		end
	end, { vpSize })

	return e(ItemIcon, {
		Rotation = 15,
		itemData = itemData,
		Size = UDim2.fromOffset(SLOT_SIZE, SLOT_SIZE),
		Position = pos:map(function(p)
			return UDim2.fromOffset(p.X - SLOT_SIZE / 2, p.Y - SLOT_SIZE / 2)
		end),
	})
end

return function()
	local draggedUniqueId = ReactCharm.useAtom(InventorySlice.state.draggingItemUniqueId)
	if not draggedUniqueId then
		return nil
	end

	return e(DraggedItemFrame, { draggedUniqueId = draggedUniqueId })
end
