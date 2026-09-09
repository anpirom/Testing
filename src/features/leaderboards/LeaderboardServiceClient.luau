local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LeaderboardServiceUtils = require(script.Parent.LeaderboardServiceUtils)
local LeaderboardSlice = require(script.Parent.LeaderboardSlice)
local Networker = require(ReplicatedStorage.Packages.Networker)
local LeaderboardServiceClient = {}

type LeaderboardData = LeaderboardServiceUtils.LeaderboardData

function LeaderboardServiceClient.init(self: LeaderboardServiceClient)
	self.networker = Networker.client.new("LeaderboardService", self)

	task.spawn(function()
		local leaderboards: { [string]: LeaderboardData } = self.networker:fetch("getLeaderboards")
		LeaderboardSlice.states.crateRollsLeaderboard(leaderboards.crateRollsLeaderboard)
		LeaderboardSlice.states.killsLeaderboard(leaderboards.killsLeaderboard)
		LeaderboardSlice.states.currencyLeaderboard(leaderboards.currencyLeaderboard)
	end)
end

function LeaderboardServiceClient.leaderboardUpdated(
	_self: LeaderboardServiceClient,
	key: string,
	leaderboardData: LeaderboardData
)
	LeaderboardSlice.states[key](leaderboardData)
end

type LeaderboardServiceClient = typeof(LeaderboardServiceClient) & {
	networker: Networker.Client,
}

return LeaderboardServiceClient :: LeaderboardServiceClient
