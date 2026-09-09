local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local Networker = require(ReplicatedStorage.Packages.Networker)
local leaderboardPairs = require(ReplicatedStorage.Source.Core.Util.leaderboardPairs)
local LeaderboardServiceUtils = require(ReplicatedStorage.Source.Features.Leaderboards.LeaderboardServiceUtils)

type LeaderboardEntry = LeaderboardServiceUtils.LeaderboardEntry
type LeaderboardData = LeaderboardServiceUtils.LeaderboardData

local PREFIX = "PRE"
local UPDATE_INTERVAL = 60
local killsOrderedDataStore = DataStoreService:GetOrderedDataStore(PREFIX .. "KillsLeaderboard")
local currencyOrderedDataStore = DataStoreService:GetOrderedDataStore(PREFIX .. "CurrencyLeaderboard")
local crateRollsOrderedDataStore = DataStoreService:GetOrderedDataStore(PREFIX .. "CrateRollsLeaderboard")
local dataStores = {
	currencyLeaderboard = currencyOrderedDataStore,
	killsLeaderboard = killsOrderedDataStore,
	crateRollsLeaderboard = crateRollsOrderedDataStore,
}

local LeaderboardServiceServer = {}

function LeaderboardServiceServer.init(self: LeaderboardServiceServer)
	self.currencyLeaderboard = {}
	self.killsLeaderboard = {}
	self.crateRollsLeaderboard = {}
	self.networker = Networker.server.new("LeaderboardService", self, { self.getLeaderboards })

	task.spawn(function()
		task.wait(5)
		while true do
			self:update()
			task.wait(UPDATE_INTERVAL)
		end
	end)
end

function LeaderboardServiceServer.updatePlayers(_self: LeaderboardServiceServer)
	for _, player in Players:GetPlayers() do
		if not DataService:hasProfile(player) then
			continue
		end

		local kills = math.round(DataService:get(player, { "stats", "enemiesKilled" }))
		local currency = math.round(DataService:get(player, { "stats", "totalCurrency" }))
		local crateRolls = math.round(DataService:get(player, { "stats", "crateRolls" }))

		local success, err = pcall(function()
			killsOrderedDataStore:SetAsync(player.UserId, kills)
			currencyOrderedDataStore:SetAsync(player.UserId, currency)
			crateRollsOrderedDataStore:SetAsync(player.UserId, crateRolls)
		end)

		if not success then
			warn(err)
		end
	end
end

function LeaderboardServiceServer.updateLeaderboard(
	_self: LeaderboardServiceServer,
	dataStore: OrderedDataStore
): LeaderboardData?
	local success, pages = pcall(function()
		return dataStore:GetSortedAsync(false, 100)
	end)

	if not success then
		warn(pages)
		return
	end

	local leaderboardData: LeaderboardData = {}
	for userId, value in leaderboardPairs(pages) do
		userId = tonumber(userId)
		local username = "[Failed To Load]"
		local profileImage = ""
		pcall(function()
			username = Players:GetNameFromUserIdAsync(userId)
			profileImage =
				Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
		end)

		local entry: LeaderboardEntry = {
			userId = userId,
			username = username,
			profileImageId = profileImage,
			value = value,
		}

		table.insert(leaderboardData, entry)
	end

	return leaderboardData
end

function LeaderboardServiceServer.getLeaderboards(self: LeaderboardServiceServer)
	return {
		currencyLeaderboard = self.currencyLeaderboard,
		killsLeaderboard = self.killsLeaderboard,
		crateRollsLeaderboard = self.crateRollsLeaderboard,
	}
end

function LeaderboardServiceServer.update(self: LeaderboardServiceServer)
	self:updatePlayers()

	for key, dataStore in dataStores do
		local leaderboardData = self:updateLeaderboard(dataStore)
		if leaderboardData then
			self[key] = leaderboardData
			self.networker:fireAll("leaderboardUpdated", key, leaderboardData)
		end
	end
end

type LeaderboardServiceServer = typeof(LeaderboardServiceServer) & {
	networker: Networker.Server,
	currencyLeaderboard: LeaderboardData,
	killsLeaderboard: LeaderboardData,
	crateRollsLeaderboard: LeaderboardData,
}

return LeaderboardServiceServer :: LeaderboardServiceServer
