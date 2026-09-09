local ReplicatedStorage = game:GetService("ReplicatedStorage")
local useViewportSize = require(ReplicatedStorage.Source.Core.UI.Hooks.useViewportSize)

local SLOT_SIZE = 95
return function()
	local vpSize = useViewportSize()
	local scalar = math.sqrt(math.clamp(vpSize.X / 1500, 0, 1))
	return SLOT_SIZE * scalar
end
