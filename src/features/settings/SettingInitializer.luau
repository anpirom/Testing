local SoundService = game:GetService("SoundService")

local SettingsServiceClient = require(script.Parent.SettingsServiceClient)

return function()
	SettingsServiceClient:subscribe("music", function(on: boolean)
		SoundService.Music.Volume = if on then 0.25 else 0
	end)
end
