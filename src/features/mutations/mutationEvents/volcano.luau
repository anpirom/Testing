local ReplicatedStorage = game:GetService("ReplicatedStorage")
return function(completionTime: number)
	local model = ReplicatedStorage.Assets.WeatherEvents.volcano:Clone()
	model.Parent = workspace

	task.delay(completionTime - os.time(), function()
		model:Destroy()
	end)
end
