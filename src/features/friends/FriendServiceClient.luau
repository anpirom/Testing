local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Networker = require(ReplicatedStorage.Packages.Networker)

local FriendServiceClient = {
	friendCount = Charm.atom(0),
}

function FriendServiceClient.init(self: FriendServiceClient)
	self.networker = Networker.client.new("FriendService", self)
	task.spawn(function()
		self.friendCount(self.networker:fetch("getFriendCount"))
	end)
end

function FriendServiceClient.setFriendCount(self: FriendServiceClient, count: number)
	self.friendCount(count)
end

type FriendServiceClient = typeof(FriendServiceClient) & {
	networker: Networker.Client,
}

return FriendServiceClient :: FriendServiceClient
