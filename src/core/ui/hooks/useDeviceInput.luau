local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.React)

return function()
	local currentInput, setCurrentInput = React.useState(UserInputService.PreferredInput)

	React.useEffect(function()
		local conn = UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
			setCurrentInput(UserInputService.PreferredInput)
		end)

		return function()
			conn:Disconnect()
		end
	end, { currentInput })

	return currentInput
end
