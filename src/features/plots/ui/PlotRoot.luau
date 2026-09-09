local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local CrateTimers = require(ReplicatedStorage.Source.Features.Plots.UI.Screens.CrateTimers)
local TowerUpgradeGui = require(ReplicatedStorage.Source.Features.Plots.UI.Screens.TowerUpgradeGui)
local e = React.createElement

return function()
	return e(React.Fragment, nil, {
		CrateTimer = e(CrateTimers),
		TowerUpgradeGui = e(TowerUpgradeGui),
	})
end
