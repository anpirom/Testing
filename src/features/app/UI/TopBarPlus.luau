local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Topbarplus=require(ReplicatedStorage.Packages.Topbarplus)

return function()
	local settingsButton=Topbarplus.new()
	settingsButton:setImageRatio(1)
	settingsButton:setImageScale(0.6)
	settingsButton:oneClick(true)
	settingsButton:align("Left")
	settingsButton:bindEvent("selected",function()
		print("Settings button clicked")
	end)
	return function()
		settingsButton:destroy()
	end
end