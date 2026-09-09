local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local Networker = require(ReplicatedStorage.Packages.Networker)
local Signal = require(ReplicatedStorage.Packages.Signal)
local InventoryServiceUtils = require(ReplicatedStorage.Source.Features.Inventory.InventoryServiceUtils)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

type CrateData = DataTemplate.CrateData
type TowerData = DataTemplate.TowerData

local InventoryServiceServer = {}

function InventoryServiceServer.init(self: InventoryServiceServer)
	self.itemSoldSignal = Signal.new()
	self.networker = Networker.server.new("InventoryService", self, {
		self.setHotBarUniqueId,
		self.equipItem,
		self.unequipItem,
		self.sell,
		self.setItemFav,
	})
end

function InventoryServiceServer.setItemFav(
	_self: InventoryServiceServer,
	player: Player,
	uniqueId: string,
	fav: boolean
)
	if not DataService:get(player, { "inventory", uniqueId }) then
		return
	end

	if fav ~= true then
		fav = false
	end

	DataService:set(player, { "inventory", uniqueId, "fav" }, fav, true)
end

function InventoryServiceServer.sell(self: InventoryServiceServer, player: Player, uniqueIds: { string })
	for _, uniqueId in uniqueIds do
		local itemData: DataTemplate.ItemData? = DataService:get(player, { "inventory", uniqueId })
		if not itemData then
			continue
		end

		local sellPrice = InventoryServiceUtils.getSellValue(itemData)
		DataService:set(player, { "inventory", uniqueId }, nil)
		DataService:update(player, { "currency" }, function(prev: number)
			return prev + sellPrice
		end)
		self.itemSoldSignal:Fire(player, uniqueId)
	end
end

function InventoryServiceServer.unequipItem(self: InventoryServiceServer, player: Player)
	self.networker:fireAll("setPlayerItem", player, nil)
end

function InventoryServiceServer.equipItem(self: InventoryServiceServer, player: Player, uniqueId: string)
	local itemData = DataService:get(player, { "inventory", uniqueId })
	if not itemData then
		return
	end

	self.networker:fireAll("setPlayerItem", player, itemData)
end

function InventoryServiceServer.addCrate(_self: InventoryServiceServer, player: Player, crateData: CrateData): string
	local crateKey = InventoryServiceUtils.getCrateKey(crateData)
	local prevCrateData: DataTemplate.ItemData = DataService:get(player, { "inventory", crateKey })

	if not prevCrateData then
		DataService:set(player, { "inventory", crateKey }, {
			crateId = crateData.crateId,
			amt = crateData.amt or 1,
			mutations = crateData.mutations,
		})
	else
		DataService:update(player, { "inventory", crateKey, "amt" }, function(prev: number?)
			return (prev or 0) + (crateData.amt or 1)
		end)
	end

	return crateKey
end

function InventoryServiceServer.addTower(
	_self: InventoryServiceServer,
	player: Player,
	towerData: DataTemplate.TowerData
): string
	local uniqueId = HttpService:GenerateGUID(false)
	DataService:set(player, { "inventory", uniqueId }, towerData)

	local towerTier = if towerData.mutations and towerData.mutations.diamond
		then "diamond"
		elseif towerData.mutations and towerData.mutations.gold then "gold"
		else "normal"

	local hasObtained = DataService:get(player, { "towerIndex", towerTier, towerData.itemId }) == true
	if not hasObtained then
		DataService:set(player, { "towerIndex", towerTier, towerData.itemId }, true)
	end

	return uniqueId
end

function InventoryServiceServer.setHotBarUniqueId(
	_self: InventoryServiceServer,
	player: Player,
	index: number,
	uniqueId: string?
)
	assert(type(uniqueId) == "string" or uniqueId == nil, "uniqueId must be a string or nil")
	assert(index >= 1 and index <= 9, "index must be between 1 and 9")
	DataService:set(player, { "hotbar", index }, uniqueId or "NULL")
end

function InventoryServiceServer.addToHotBar(self: InventoryServiceServer, player: Player, uniqueId: string): ()
	self.networker:fire(player, "addToHotbar", uniqueId)
end

function InventoryServiceServer.hasUnlockedTower(
	_self: InventoryServiceServer,
	player: Player,
	towerId: string
): boolean
	return DataService:get(player, { "towerIndex", "normal", towerId })
		or DataService:get(player, { "towerIndex", "gold", towerId })
		or DataService:get(player, { "towerIndex", "diamond", towerId })
end

type InventoryServiceServer = typeof(InventoryServiceServer) & {
	networker: Networker.Server,
	itemSoldSignal: Signal.Signal<Player, string>,
}

return InventoryServiceServer :: InventoryServiceServer
