local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local LeaderboardSlice = require(ReplicatedStorage.Source.Features.Leaderboards.LeaderboardSlice)
local LeaderboardSurfaceGui =
	require(ReplicatedStorage.Source.Features.Leaderboards.UI.Components.LeaderboardSurfaceGui)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local e = React.createElement

return function()
	return e(React.Fragment, nil, {
		CrateLeaderboard = e(LeaderboardSurfaceGui, {
			tag = "CrateLeaderboard",
			leaderboardData = LeaderboardSlice.states.crateRollsLeaderboard,
			prefix = {
				Image = Towers.getTowerInfo("crossbow").crateImage,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
			},
			gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 202, 87)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(65, 26, 0)),
			}),
		}),

		KillsLeaderboard = e(LeaderboardSurfaceGui, {
			tag = "KillsLeaderboard",
			leaderboardData = LeaderboardSlice.states.killsLeaderboard,
			prefix = {
				Image = "rbxassetid://135416232303660",
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
			},
			gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 154, 154)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 30)),
			}),
		}),

		CurrencyLeaderboard = e(LeaderboardSurfaceGui, {
			tag = "CurrencyLeaderboard",
			leaderboardData = LeaderboardSlice.states.currencyLeaderboard,
			prefix = {
				Image = ImageIds.currency,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
			},
			gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(211, 255, 154)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(37, 100, 0)),
			}),
		}),
	})
end
