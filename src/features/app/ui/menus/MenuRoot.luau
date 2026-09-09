local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local e = React.createElement

local capturedMenus = {}
for _, module in script.Parent:GetChildren() do
	if module:IsA("ModuleScript") and module.Name ~= "Menu" and module ~= script then
		capturedMenus[module.Name] = require(module)
	end
end

return function()
	return e(
		React.Fragment,
		nil,
		Sift.Dictionary.map(capturedMenus, function(menuModule, name)
			return e(menuModule), name
		end),
		{}
	)
end
