local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local SettingsServiceUtils = require(script.Parent.SettingsServiceUtils)
local Networker = require(ReplicatedStorage.Packages.Networker)

local convertPathToSettingPath = SettingsServiceUtils.convertPathToSettingPath
local SettingsServiceClient = {}

function SettingsServiceClient.init(self: SettingsServiceClient)
	self.networker = Networker.client.new("SettingsService", self)
end

function SettingsServiceClient.set(self: SettingsServiceClient, path: string | { string }, value: any): ()
	DataService:set(convertPathToSettingPath(path), value)
	if RunService:IsRunning() then
		self.networker:fire("set", path, value)
	end
end

function SettingsServiceClient.get(_self: SettingsServiceClient, path: string | { string }): any
	return DataService:get(convertPathToSettingPath(path))
end

function SettingsServiceClient:subscribe(path: string | { string }, callback: (any) -> ()): ()
	local value = DataService:get(convertPathToSettingPath(path))
	callback(value)
	DataService:getChangedSignal(convertPathToSettingPath(path)):Connect(function(newValue)
		callback(newValue)
	end)
end

type SettingsServiceClient = typeof(SettingsServiceClient) & {
	networker: Networker.Client,
}

return SettingsServiceClient :: SettingsServiceClient
