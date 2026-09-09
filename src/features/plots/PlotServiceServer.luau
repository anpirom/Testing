local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local InventoryServiceServer = require(ServerScriptService.Features.Inventory.InventoryServiceServer)
local NotificationServiceServer = require(ServerScriptService.Features.Notifications.NotificationServiceServer)
local PlotServer = require(ServerScriptService.Features.Plots.Classes.PlotServer)
local Networker = require(ReplicatedStorage.Packages.Networker)
local ServicePlayerData = require(ReplicatedStorage.Packages.ServicePlayerData)
local IsUserInGroup = require(ReplicatedStorage.Source.Core.Platform.IsUserInGroup)
local RebirthUtils = require(ReplicatedStorage.Source.Features.Plots.Modules.RebirthUtils)
local PlotTypes = require(ReplicatedStorage.Source.Features.Plots.PlotTypes)
local ShopUtils = require(ReplicatedStorage.Source.Features.Shop.ShopUtils)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

type Plot = PlotServer.PlotServer
type PlotSpawn = PlotTypes.PlotSpawn

local PlotServiceServer = {}

local PLAYER_DATA_TEMPLATE = {
	plot = nil,
}

type PlayerData = {
	plot: Plot,
}

function PlotServiceServer.init(self: PlotServiceServer)
	self.networker =
		Networker.server.new("PlotService", self, { self.rebirth, self.tpToBase, self.tpToSell, self.claimGroupLoot })
	self.playerData = ServicePlayerData.new(PLAYER_DATA_TEMPLATE :: PlayerData, self)
	self.plotSpawns = {}

	for _, plotSpawn: BasePart in CollectionService:GetTagged("PlotSpawn") do
		plotSpawn.Transparency = 1
		local index = plotSpawn:GetAttribute("Index") :: number
		local fakePlot: Model & any = ReplicatedStorage.Assets.Misc.Plot:Clone()
		local fakeDefense: Model = ReplicatedStorage.Assets.PlotDefenses["1"]:Clone()
		fakeDefense:PivotTo(fakePlot.DefenseSpawn.CFrame)
		fakeDefense.Parent = fakePlot
		local fakeConveyor: Model = ReplicatedStorage.Assets.Conveyors["1"]:Clone()
		fakeConveyor:PivotTo(fakePlot.ConveyorSpawn.CFrame)
		fakeConveyor.Parent = fakePlot

		for _, desc in fakePlot:GetDescendants() do
			if desc:IsA("BillboardGui") then
				desc.Enabled = false
			end
		end

		fakePlot:PivotTo(plotSpawn.CFrame)
		fakePlot.Parent = workspace
		self.plotSpawns[index] = { part = plotSpawn, index = index, fakePlot = fakePlot, owner = nil }
	end
end

function PlotServiceServer.claimPlot(self: PlotServiceServer, player: Player): PlotSpawn?
	while player.Parent do
		for _, plotSpawn in self.plotSpawns do
			if plotSpawn.owner then
				if plotSpawn.owner == player then
					return
				end
				continue
			end

			plotSpawn.fakePlot.Parent = ServerStorage
			plotSpawn.owner = player
			return plotSpawn
		end
		task.wait(1)
	end

	return
end

function PlotServiceServer.playerAdded(self: PlotServiceServer, player: Player, playerData: PlayerData)
	local plotSpawn = self:claimPlot(player)
	if not plotSpawn then
		return
	end

	DataService:waitForData(player)
	local plot = PlotServer.new(plotSpawn, player)
	playerData.plot = plot
	self.networker:fireAll("initPlot", plot:get())

	for _, otherPlayer in Players:GetPlayers() do
		if player == otherPlayer then
			continue
		end

		local otherPlayerPlot = self:getPlotFromPlayer(otherPlayer)
		if otherPlayerPlot then
			self.networker:fire(player, "initPlot", otherPlayerPlot:get())
		end
	end
end

function PlotServiceServer.playerRemoving(self: PlotServiceServer, player: Player, playerData: PlayerData)
	local plot = playerData.plot
	if not plot then
		return
	end

	local index = plot.index
	plot:destroy()
	local plotSpawn = self.plotSpawns[index]
	if plotSpawn.owner == player then
		plotSpawn.owner = nil
		plotSpawn.fakePlot.Parent = workspace
	end

	self.networker:fireAll("removePlot", index)
end

function PlotServiceServer.rebirth(_self: PlotServiceServer, player: Player): (boolean | any, string?)
	local rebirths: number = DataService:get(player, "rebirths")
	if RebirthUtils.isMaxedRebirths(rebirths) then
		return false, "Max rebirths reached"
	end

	local reqs = RebirthUtils.getRequirements(rebirths)
	if DataService:get(player, "currency") < reqs.currency then
		return false, "Not enough money"
	end

	local hasUnlockedTower = InventoryServiceServer:hasUnlockedTower(player, reqs.towerId)
	if not hasUnlockedTower then
		return false, "Required tower not unlocked"
	end

	DataService:set(player, "currency", 0)
	DataService:update(player, "rebirths", function(oldRebirths: number)
		return oldRebirths + 1
	end)

	return RebirthUtils.rebirthRewards[rebirths + 1]
end

function PlotServiceServer.tpToBase(self: PlotServiceServer, player: Player)
	local playerData = self.playerData:get(player)
	if not playerData then
		return
	end

	local plot = playerData.plot
	if not plot then
		return
	end

	plot:tpChar()
end

function PlotServiceServer.tpToSell(_self: PlotServiceServer, player: Player)
	local sellTpPart = CollectionService:GetTagged("SellTp")[1] :: BasePart
	local char = player.Character
	if char then
		char:PivotTo(sellTpPart.CFrame)
	end
end

function PlotServiceServer.getPlotFromPlayer(self: PlotServiceServer, player: Player): Plot?
	local playerData = self.playerData:get(player)
	if not playerData then
		return
	end

	return playerData.plot
end

function PlotServiceServer.instaOpenCrate(self: PlotServiceServer, player: Player, n: number): boolean
	local plot = self:getPlotFromPlayer(player)
	if not plot then
		return false
	end

	local instaOpenInfo: DataTemplate.InstaOpenCrates = DataService:get(player, "instaOpenCrates")
	local unprocessedCrateInfo = instaOpenInfo[n]
	if not unprocessedCrateInfo then
		warn("No unprocessed crate info for n =", n)
		return false
	end

	plot:openCrate(unprocessedCrateInfo.floor, unprocessedCrateInfo.node)
	DataService:set(player, { "instaOpenCrates", n }, nil)

	return true
end

function PlotServiceServer.boughtProductCrate(self: PlotServiceServer, player: Player, n: number): boolean
	local plot = self:getPlotFromPlayer(player)
	if not plot then
		return false
	end

	local conveyorBoughtCrate: DataTemplate.ConveyorBoughtCrate = DataService:get(player, { "conveyorBoughtCrates", n })
	if not conveyorBoughtCrate then
		warn("No conveyor bought crate info for n =", n)
		return false
	end

	plot.conveyor:crateProductBought(conveyorBoughtCrate)
	DataService:set(player, { "conveyorBoughtCrates", n }, nil)

	return true
end

function PlotServiceServer:claimGroupLoot(player: Player)
	if DataService:get(player, "groupLootClaimed") then
		return
	end

	if not IsUserInGroup(player.UserId, 15794692) then
		return
	end

	DataService:set(player, "groupLootClaimed", true)

	local currencyReward =
		math.round(1e3 + ShopUtils.getCurrencyAmtFromRebirth(1, DataService:get(player, "rebirths")) / 3)
	DataService:update(player, "currency", function(amt: number)
		return amt + currencyReward
	end)

	NotificationServiceServer:sendNotification(player, ImageIds.luck, 1)
	NotificationServiceServer:sendNotification(player, ImageIds.currency, currencyReward)

	return true
end

type PlotServiceServer = typeof(PlotServiceServer) & {
	plotSpawns: { PlotSpawn },
	networker: Networker.Server,
	playerData: ServicePlayerData.ServicePlayerData<PlayerData>,
}

return PlotServiceServer :: PlotServiceServer
