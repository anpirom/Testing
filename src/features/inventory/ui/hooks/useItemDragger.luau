local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.React)
local InventoryServiceClient = require(ReplicatedStorage.Source.Features.Inventory.InventoryServiceClient)

return function(uniqueId: string)
	local dragStart, setDragStart = React.useState(nil :: Vector2?)

	React.useEffect(function()
		if not dragStart then
			return
		end

		local changedConn = UserInputService.InputChanged:Connect(function(input)
			local pos = Vector2.new(input.Position.X, input.Position.Y) + GuiService:GetGuiInset()
			local delta = pos - dragStart
			local distance = delta.Magnitude
			if distance > 20 then
				setDragStart(nil)
				InventoryServiceClient:dragItem(uniqueId)
			end
		end)

		local inputEndedConn = UserInputService.InputEnded:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				setDragStart(nil)
			end
		end)

		return function()
			inputEndedConn:Disconnect()
			changedConn:Disconnect()
		end
	end, { dragStart, uniqueId })

	return setDragStart
end
