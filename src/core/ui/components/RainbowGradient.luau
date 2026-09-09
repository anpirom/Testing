local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.React)

local RAINBOW_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 127, 0)),
	ColorSequenceKeypoint.new(0.34, Color3.fromRGB(255, 255, 0)),
	ColorSequenceKeypoint.new(0.51, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.68, Color3.fromRGB(0, 255, 255)),
	ColorSequenceKeypoint.new(0.85, Color3.fromRGB(0, 0, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255)),
})

return function()
	local rot, setRot = React.useBinding(0)
	React.useEffect(function()
		local connection
		connection = RunService.Heartbeat:Connect(function(dt)
			setRot((rot:getValue() + dt * 15) % 360)
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	return React.createElement("UIGradient", {
		Color = RAINBOW_GRADIENT,
		Rotation = rot,
	})
end
