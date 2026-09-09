local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local Networker = require(ReplicatedStorage.Packages.Networker)
local SettingsServiceUtils = require(ReplicatedStorage.Source.Features.Settings.SettingsServiceUtils)

local convertPathToSettingPath = SettingsServiceUtils.convertPathToSettingPath
local SettingsServiceServer = {}

local specialSettings = {}

function SettingsServiceServer.init(self: SettingsServiceServer)
	self.networker = Networker.server.new("SettingsService", self, { self.set })
end

function SettingsServiceServer:get(player: Player, path: string | { string }): any
	return DataService:get(player, convertPathToSettingPath(path))
end

function SettingsServiceServer:set(player: Player, path: string | { string }, value: any, dontReplicate: boolean?): ()
	local settingPath = convertPathToSettingPath(path)
	local currentValue = DataService:get(player, settingPath)
	local settingConcatPath = table.concat(settingPath, ".")
	local specialSettingFunction = specialSettings[settingConcatPath]
	if not specialSettingFunction and typeof(value) ~= typeof(currentValue) then
		assert(currentValue ~= nil, `Setting '{settingConcatPath}' does not exist`)
		error(`Mismatched types when setting setting value for '{settingConcatPath}'`)
	elseif specialSettingFunction and not specialSettingFunction(player, value, settingPath) then
		return
	end

	DataService:set(player, settingPath, value, dontReplicate ~= false)
end

type SettingsServiceServer = typeof(SettingsServiceServer) & {
	networker: Networker.Server,
}

return SettingsServiceServer :: SettingsServiceServer
