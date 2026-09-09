local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local Networker = require(ReplicatedStorage.Packages.Networker)
local Notifications = require(ReplicatedStorage.Source.Features.Notifications.UI.Notifications)
local NotificationServiceClient = {}

function NotificationServiceClient.init(self: NotificationServiceClient)
	self.networker = Networker.client.new("NotificationService", self)
end

function NotificationServiceClient:serverNotification(props)
	Notifications.addNotification(props)
end

function NotificationServiceClient:globalMessage(data)
	--[[if not SettingsServiceClient:get("globalAnnouncements") then
		return
	end]]

	local color: Color3
	if data.color then
		color = Color3.fromRGB(data.color.R, data.color.G, data.color.B)
	else
		color = Color3.new(1, 1, 1)
	end

	local r, g, b = math.round(color.R * 255), math.round(color.G * 255), math.round(color.B * 255)

	local TextChannel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral") :: TextChannel
	TextChannel:DisplaySystemMessage(`<font color="rgb({r}, {g}, {b})">{data.message}</font>`)
end

type NotificationServiceClient = typeof(NotificationServiceClient) & {
	networker: Networker.Client,
}

return NotificationServiceClient :: NotificationServiceClient
