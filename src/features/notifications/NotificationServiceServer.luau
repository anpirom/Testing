local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Networker = require(ReplicatedStorage.Packages.Networker)
local RetryAsync = require(ReplicatedStorage.Source.Core.Platform.RetryAsync)

type GlobalPayloadData = {
	type: string,
	message: string,
	color: { R: number, G: number, B: number }?,
}

type GlobalPayload = {
	Data: GlobalPayloadData,
}

local NotificationServiceServer = {}

function NotificationServiceServer.init(self: NotificationServiceServer)
	self.networker = Networker.server.new("NotificationService", self)

	task.spawn(function()
		return RetryAsync(function()
			MessagingService:SubscribeAsync("GlobalNotifications", function(payload)
				self:_handleGlobalNotification(payload.Data)
			end)
		end, 10, 4, 2)
	end)
end

function NotificationServiceServer.sendNotification(
	self: NotificationServiceServer,
	player: Player,
	image: string,
	amount: number
): ()
	self.networker:fire(player, "serverNotification", {
		Image = image,
		Amount = amount,
	})
end

function NotificationServiceServer.sendGlobalMessage(
	_self: NotificationServiceServer,
	message: string,
	color: Color3?
): ()
	task.spawn(function()
		pcall(function()
			local payload: GlobalPayloadData = {
				type = "message",
				message = message,
				color = if color
					then { R = math.round(color.R * 255), G = math.round(color.G * 255), B = math.round(color.B * 255) }
					else nil,
			}

			MessagingService:PublishAsync("GlobalNotifications", payload)
		end)
	end)
end

function NotificationServiceServer._handleGlobalNotification(
	self: NotificationServiceServer,
	data: GlobalPayloadData
): ()
	if data.type == "message" then
		self.networker:fireAll("globalMessage", data)
	end
end

type NotificationServiceServer = typeof(NotificationServiceServer) & {
	networker: Networker.Server,
}

return NotificationServiceServer :: NotificationServiceServer
