local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local CodeRewardCallbacks = require(ReplicatedStorage.Source.Features.Codes.CodeRewardCallbacks)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local _ProductServerCallbacks = require(ServerScriptService.Features.Monetization.Modules.ProductServerCallbacks)
local AutoRejoinServiceServer = require(ServerScriptService.Features.AutoRejoin.AutoRejoinServiceServer)
local CodeServiceServer = require(ServerScriptService.Features.Codes.CodeServiceServer)
local FriendServiceServer = require(ServerScriptService.Features.Friends.FriendServiceServer)
local InventoryServiceServer = require(ServerScriptService.Features.Inventory.InventoryServiceServer)
local LeaderboardServiceServer = require(ServerScriptService.Features.Leaderboards.LeaderboardServiceServer)
local MonetizationServiceServer = require(ServerScriptService.Features.Monetization.MonetizationServiceServer)
local MutationServiceServer = require(ServerScriptService.Features.Mutations.MutationServiceServer)
local NotificationServiceServer = require(ServerScriptService.Features.Notifications.NotificationServiceServer)
local PlotServiceServer = require(ServerScriptService.Features.Plots.PlotServiceServer)
local SettingsServiceServer = require(ServerScriptService.Features.Settings.SettingsServiceServer)
local TutorialServiceServer = require(ServerScriptService.Features.Tutorial.TutorialServiceServer)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

function DataService:onPlayerInit(_player, data)
	print(data)
	data.sessionStart = os.time()
end

DataService:addPlayerRemovingCallback(function(_player, data)
	local playTime = os.time() - data.sessionStart
	data.stats.timePlayed += playTime
	print(data)
end)

DataService:init({
	template = DataTemplate,
	profileStoreIndex = "OFFICIAL",
	useMock = false,
	resetData = false,
	dontSave = false,
})

MonetizationServiceServer:init({
	products = Products,
	canAwardGamepasses = true,
	freePassesGroupRank = 255,
	groupId = 15794692,
})

CodeServiceServer:init(CodeRewardCallbacks :: any)
PlotServiceServer:init()
InventoryServiceServer:init()
MutationServiceServer:init()
LeaderboardServiceServer:init()
AutoRejoinServiceServer:init()
NotificationServiceServer:init()
FriendServiceServer:init()
TutorialServiceServer:init()
SettingsServiceServer:init()
