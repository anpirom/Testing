local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local useDataState = require(ReplicatedStorage.Source.Core.UI.Hooks.useDataState)
local SettingsServiceClient = require(ReplicatedStorage.Source.Features.Settings.SettingsServiceClient)
local SettingsServiceUtils = require(ReplicatedStorage.Source.Features.Settings.SettingsServiceUtils)

return function(path: string | { string })
	local settingsPath = React.useMemo(function()
		return SettingsServiceUtils.convertPathToSettingPath(path)
	end, { path })

	local value = useDataState(settingsPath)

	local setValue = React.useCallback(function(newValue)
		SettingsServiceClient:set(path, newValue)
	end, { settingsPath })

	return value, setValue
end
