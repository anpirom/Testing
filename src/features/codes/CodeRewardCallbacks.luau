local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local NotificationServiceServer = require(ServerScriptService.Features.Notifications.NotificationServiceServer)

local DataService = require(ReplicatedStorage.Packages.DataService).server
local callbacks = {}

function callbacks.currency(player: Player, amount: number)
	DataService:update(player, "currency", function(currentAmount: number)
		return currentAmount + amount
	end)
	NotificationServiceServer:sendNotification(player, ImageIds.currency, amount)
end

return callbacks
