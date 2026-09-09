local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Abbreviate = require(ReplicatedStorage.Source.Core.UI.Abbreviate)
local PlotServiceUtils = require(ReplicatedStorage.Source.Features.Plots.PlotServiceUtils)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

local TowerSurfaceGui = {}

function TowerSurfaceGui.new(towerData: DataTemplate.TowerData?): SurfaceGui
	local gui = ReplicatedStorage.Assets.Misc.TowerUpgradeGui:Clone()
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	TowerSurfaceGui.update(gui, towerData)

	local enterConn = gui.Button.MouseEnter:Connect(function()
		TweenService:Create(gui.Button.UIScale, TweenInfo.new(0.2), { Scale = 1.1 }):Play()
	end)

	local leaveConn = gui.Button.MouseLeave:Connect(function()
		TweenService:Create(gui.Button.UIScale, TweenInfo.new(0.2), { Scale = 1 }):Play()
	end)

	return gui, function()
		enterConn:Disconnect()
		leaveConn:Disconnect()
		gui:Destroy()
	end
end

function TowerSurfaceGui.update(gui, towerData: any?): ()
	if not towerData or towerData.crateId then
		gui.Enabled = false
		return
	end

	gui.Button.Cost.TextLabel.Text = "$" .. Abbreviate(PlotServiceUtils.getUpgradeCost(towerData))
	gui.Button.Lvl.TextLabel.Text = `Lvl {towerData.level}  →  Lvl {towerData.level + 1}`
	gui.Enabled = true
end

return TowerSurfaceGui
