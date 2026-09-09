local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Networker = require(ReplicatedStorage.Packages.Networker)
local SafeTeleport = require(ReplicatedStorage.Source.Core.Platform.SafeTeleport)

local PLACE_ID = game.PlaceId

local AutoRejoinServer = {}

function AutoRejoinServer:init()
	self.networker = Networker.server.new("AutoRejoinService", self, { self.autoRejoin })
end

function AutoRejoinServer:autoRejoin(player: Player)
	if RunService:IsStudio() then
		return
	end

	SafeTeleport(PLACE_ID, { player })
end

return AutoRejoinServer
