local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LeaderboardServiceUtils = require(script.Parent.LeaderboardServiceUtils)
local Charm = require(ReplicatedStorage.Packages.Charm)
local atom = Charm.atom

type Atom<T> = Charm.Atom<T>
type LeaderboardData = LeaderboardServiceUtils.LeaderboardData

local crateRollsLeaderboard: Atom<LeaderboardData> = atom({})
local killsLeaderboard: Atom<LeaderboardData> = atom({})
local currencyLeaderboard: Atom<LeaderboardData> = atom({})

local actions = {}

return {
	actions = actions,
	states = {
		crateRollsLeaderboard = crateRollsLeaderboard,
		killsLeaderboard = killsLeaderboard,
		currencyLeaderboard = currencyLeaderboard,
	},
}
