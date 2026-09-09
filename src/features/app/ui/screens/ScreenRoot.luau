local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local e = React.createElement

local capturedScreens = {}
for _, module in script.Parent:GetChildren() do
	if module:IsA("ModuleScript") and module.Name ~= "Screen" and module ~= script then
		capturedScreens[module.Name] = require(module)
	end
end

return function()
	return e(
		React.Fragment,
		nil,
		Sift.Dictionary.map(capturedScreens, function(screenModule, name)
			return e(screenModule), name
		end),
		{}
	)
end
