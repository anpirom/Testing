local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.React)

return function()
	local value, setValue = React.useState(workspace.CurrentCamera.ViewportSize)

	React.useEffect(function()
		local function update()
			RunService.Heartbeat:Wait()
			setValue(workspace.CurrentCamera.ViewportSize)
		end

		update()
		local conn = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(update)

		return function()
			conn:Disconnect()
		end
	end, {})

	return value
end
