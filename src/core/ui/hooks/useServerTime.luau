local ReplicatedStorage = game:GetService("ReplicatedStorage")

local serverTimeAtom = require(script.Parent.serverTimeAtom)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)

return function()
	return ReactCharm.useAtom(serverTimeAtom)
end
