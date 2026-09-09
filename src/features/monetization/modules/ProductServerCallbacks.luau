local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local InventoryServiceServer = require(ServerScriptService.Features.Inventory.InventoryServiceServer)
local NotificationServiceServer = require(ServerScriptService.Features.Notifications.NotificationServiceServer)
local PlotServiceServer = require(ServerScriptService.Features.Plots.PlotServiceServer)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local ShopUtils = require(ReplicatedStorage.Source.Features.Shop.ShopUtils)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)

Products.starterPack.callback = function(player: Player)
	InventoryServiceServer:addToHotBar(
		player,
		InventoryServiceServer:addCrate(player, {
			crateId = "orbOfLight",
			amt = 1,
		})
	)

	InventoryServiceServer:addToHotBar(
		player,
		InventoryServiceServer:addTower(player, {
			itemId = "tesla",
			level = 1,
		})
	)

	DataService:update(player, "currency", function(amt: number)
		return amt + 100e3
	end)

	NotificationServiceServer:sendNotification(player, Towers.getTowerInfo("tesla").image, 1)
	NotificationServiceServer:sendNotification(player, Towers.getTowerInfo("orbOfLight").crateImage, 1)
	NotificationServiceServer:sendNotification(player, ImageIds.currency, 100e3)
end

local function instaCallback(player: Player, n: number): ()
	PlotServiceServer:instaOpenCrate(player, n)
end

for i = 1, 10 do
	Products["insta" .. i].callback = function(player: Player)
		instaCallback(player, i)
	end
end

local function crateCallback(player: Player, n: number): ()
	PlotServiceServer:boughtProductCrate(player, n)
end

for i = 1, 9 do
	Products["crate" .. i].callback = function(player: Player)
		crateCallback(player, i)
	end
end

Products.currency1.callback = function(player: Player)
	local rebirths: number = DataService:get(player, "rebirths")
	DataService:update(player, "currency", function(amt: number)
		return amt + ShopUtils.getCurrencyAmtFromRebirth(1, rebirths)
	end)
end

Products.currency2.callback = function(player: Player)
	local rebirths: number = DataService:get(player, "rebirths")
	DataService:update(player, "currency", function(amt: number)
		return amt + ShopUtils.getCurrencyAmtFromRebirth(2, rebirths)
	end)
end

Products.currency3.callback = function(player: Player)
	local rebirths: number = DataService:get(player, "rebirths")
	DataService:update(player, "currency", function(amt: number)
		return amt + ShopUtils.getCurrencyAmtFromRebirth(3, rebirths)
	end)
end

local function luckyBlockCallback(player: Player, id: string, amt: number): ()
	InventoryServiceServer:addCrate(player, {
		crateId = id,
		amt = amt,
	})

	local info = Towers.getTowerInfo(id)
	NotificationServiceServer:sendNotification(player, info.crateImage, amt)
end

for i = 1, 3, 1 do
	local id = "luckyBlock" .. i
	Products["luckyBlock" .. i].callback = function(player: Player)
		return luckyBlockCallback(player, id, 1)
	end
	Products["threeLuckyBlock" .. i].callback = function(player: Player)
		return luckyBlockCallback(player, id, 3)
	end
end

Products.recoverCrate.callback = function(player: Player)
	local plot = PlotServiceServer:getPlotFromPlayer(player)
	if not plot then
		return false
	end

	return plot.conveyor:recoverCrates()
end

Products.pyramidiumTower.callback = function(player: Player)
	InventoryServiceServer:addToHotBar(
		player,
		InventoryServiceServer:addTower(player, {
			itemId = "pyramidium",
			level = 1,
		})
	)

	NotificationServiceServer:sendNotification(player, Towers.getTowerInfo("pyramidium").image, 1)
end

Products.eradicatorTower.callback = function(player: Player)
	InventoryServiceServer:addToHotBar(
		player,
		InventoryServiceServer:addTower(player, {
			itemId = "eradicator",
			level = 1,
		})
	)

	NotificationServiceServer:sendNotification(player, Towers.getTowerInfo("eradicator").image, 1)
end

Products.overdriveTower.callback = function(player: Player)
	InventoryServiceServer:addToHotBar(
		player,
		InventoryServiceServer:addTower(player, {
			itemId = "overdrive",
			level = 1,
		})
	)

	NotificationServiceServer:sendNotification(player, Towers.getTowerInfo("overdrive").image, 1)
end

return nil
