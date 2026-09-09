local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local atom = Charm.atom

type Atom<T> = Charm.Atom<T>
local backpackOpen = atom(false)
local draggingItemUniqueId = atom(nil :: string?)
local hoveredSlot = atom(nil :: number?)
local originalSlot = atom(nil :: number?)
local equippedItemUniqueId = atom(nil :: string?)
local tab: Atom<string> = atom("all")
local searchQuery: Atom<string?> = atom(nil)
local numItemsVisible: Atom<number> = atom(0)
local inventoryScrollable: Atom<boolean> = atom(true)

local actions = {
	toggleBackpack = function()
		backpackOpen(function(prev)
			return not prev
		end)
	end,
}

return {
	actions = actions,
	state = {
		backpackOpen = backpackOpen,
		draggingItemUniqueId = draggingItemUniqueId,
		hoveredSlot = hoveredSlot,
		originalSlot = originalSlot,
		equippedItemUniqueId = equippedItemUniqueId,
		tab = tab,
		searchQuery = searchQuery,
		inventoryScrollable = inventoryScrollable,
		numItemsVisible = numItemsVisible,
	},
}
