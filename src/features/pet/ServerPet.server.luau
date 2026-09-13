local petClass = require("@game/ServerScriptService/Core/Classes/petClass")
local Players = game:GetService("Players")

type Player = typeof(Players.LocalPlayer)

Players.PlayerAdded:Connect(function(ply: Player)
	task.wait(3.25)
    local pet = petClass.new({
        owner = ply,
        ModelName = "Naruto",
        damage = 100,
		displayName = "Naruto",
		VisibilityState = "All",
	})
	
end)
