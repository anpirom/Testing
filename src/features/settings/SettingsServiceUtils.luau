local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local SettingsServiceUtils = {}

function SettingsServiceUtils.convertPathToSettingPath(path: string | { string }): { string }
	if type(path) == "string" then
		return { "settings", path }
	elseif path[1] == "settings" then
		return path
	else
		return Sift.Array.insert(path, 1, "settings")
	end
end

return SettingsServiceUtils
