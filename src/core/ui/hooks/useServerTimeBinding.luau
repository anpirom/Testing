local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local React = require(ReplicatedStorage.Packages.React)
local serverTimeAtom = require(script.Parent.serverTimeAtom)

return function()
	local serverTime: React.Binding<number>, setServerTime = React.useBinding(serverTimeAtom())

	React.useEffect(function()
		return Charm.subscribe(serverTimeAtom, function(newTime)
			setServerTime(newTime)
		end)
	end, {})

	return serverTime
end
