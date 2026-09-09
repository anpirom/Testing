local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local Charm = require(ReplicatedStorage.Packages.Charm)
local React = require(ReplicatedStorage.Packages.React)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local InventorySlice = require(ReplicatedStorage.Source.Features.Inventory.InventorySlice)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

local SLOT_SIZE = 95
local camera = workspace.CurrentCamera

return function(uniqueId: string, isHotbar: boolean?)
	local visible, setVisible = React.useState(false)
	React.useEffect(function()
		local current = false
		local function calc()
			local itemData: DataTemplate.ItemData = DataService:get({ "inventory", uniqueId })
			if not itemData then
				return false
			end

			local isCrate = itemData.crateId ~= nil
			local itemInfo = if isCrate
				then Towers.getTowerInfo(itemData.crateId)
				else Towers.getTowerInfo(itemData.itemId)

			if isCrate and itemData.amt <= 0 then
				return false
			end

			if InventorySlice.state.draggingItemUniqueId() == uniqueId then
				return false
			end

			local tab = InventorySlice.state.tab()
			if tab == "crates" and not isCrate then
				return false
			elseif tab == "towers" and isCrate then
				return false
			elseif tab == "favorites" and not itemData.fav then
				return false
			end

			local searchQuery = InventorySlice.state.searchQuery()
			if searchQuery then
				local name = itemInfo.name:lower()
				if isCrate then
					name ..= " crate"
				end
				local query = searchQuery:lower()
				if not string.find(name, query) then
					return false
				end
			end

			for _, equippedUniqueId in DataService:get("plotNodes") do
				if equippedUniqueId == uniqueId then
					return false
				end
			end

			if not isHotbar then
				local hotbarIndex = table.find(DataService:get("hotbar"), uniqueId)
				if hotbarIndex then
					local screenSize = camera.ViewportSize
					local scalar = math.sqrt(math.clamp(screenSize.X / 1500, 0, 1))
					local slotsShown = (screenSize.X * 0.6) // (SLOT_SIZE * scalar)
					if hotbarIndex <= slotsShown then
						return false
					end
				end
			end

			return true
		end

		local function update()
			local newVisible = calc()
			if current == newVisible then
				return
			end

			InventorySlice.state.numItemsVisible(function(prev)
				return prev + (if current then -1 else 1)
			end)

			current = newVisible
			setVisible(newVisible)
		end

		update()
		local itemDataConn = DataService:getChangedSignal({ "inventory", uniqueId }):Connect(update)
		local equippedConn = DataService:getChangedSignal("plotNodes"):Connect(update)
		local hotbarConn = DataService:getChangedSignal("hotbar"):Connect(update)
		local draggingDiscon = Charm.subscribe(InventorySlice.state.draggingItemUniqueId, update)
		local tabDiscon = Charm.subscribe(InventorySlice.state.tab, update)
		local searchDiscon = Charm.subscribe(InventorySlice.state.searchQuery, update)
		local vpConn = camera:GetPropertyChangedSignal("ViewportSize"):Connect(update)

		return function()
			itemDataConn:Destroy()
			equippedConn:Destroy()
			hotbarConn:Destroy()
			draggingDiscon()
			tabDiscon()
			searchDiscon()
			vpConn:Disconnect()
		end
	end, {})

	return visible
end
