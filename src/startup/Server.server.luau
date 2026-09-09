local Players = game:GetService("Players")
Players.PlayerAdded:Connect(function(ply)
    print("Player joined: " .. ply.Name)
end)