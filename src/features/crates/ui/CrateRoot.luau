local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local CrateBillboards = require(ReplicatedStorage.Source.Features.Crates.UI.Screens.CrateBillboards)
local e = React.createElement

return function()
	return e(React.Fragment, nil, {
		CrateBillboard = e(CrateBillboards),
	})
end
