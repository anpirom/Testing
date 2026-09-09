local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Networker = require(ReplicatedStorage.Packages.Networker)
local ServicePlayerData = require(ReplicatedStorage.Packages.ServicePlayerData)

local FriendServiceServer = {}

local DATA_TEMPLATE = {
	friendsInServer = 0,
}

type PlayerData = typeof(DATA_TEMPLATE)

function FriendServiceServer.init(self: FriendServiceServer)
	self.playerData = ServicePlayerData.new(DATA_TEMPLATE, self)
	self.networker = Networker.server.new("FriendService", self, { self.getFriendCount })
end

function FriendServiceServer.playerAdded(self: FriendServiceServer)
	self:updateAllFriends()
end

function FriendServiceServer.playerRemoving(self: FriendServiceServer)
	self:updateAllFriends()
end

function FriendServiceServer.updateAllFriends(self: FriendServiceServer)
	for _, player in Players:GetPlayers() do
		self:countFriends(player)
	end
end

function FriendServiceServer.getFriendCount(self: FriendServiceServer, player: Player)
	return self.playerData:get(player).friendsInServer
end

function FriendServiceServer.countFriends(self: FriendServiceServer, player: Player)
	local amount = 0
	for _, friend in Players:GetPlayers() do
		if friend == player then
			continue
		end

		pcall(function()
			if player:IsFriendsWithAsync(friend.UserId) then
				amount += 1
			end
		end)
	end

	self.playerData:get(player).friendsInServer = amount
	self.networker:fire(player, "setFriendCount", amount)
end

type FriendServiceServer = typeof(FriendServiceServer) & {
	networker: Networker.Server,
	playerData: ServicePlayerData.ServicePlayerData<PlayerData>,
}

return FriendServiceServer :: FriendServiceServer
