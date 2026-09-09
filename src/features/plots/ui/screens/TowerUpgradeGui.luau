local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local Abbreviate = require(ReplicatedStorage.Source.Core.UI.Abbreviate)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local StudButton = require(ReplicatedStorage.Source.Features.App.UI.Components.StudButton)
local PlotServiceClient = require(ReplicatedStorage.Source.Features.Plots.PlotServiceClient)
local PlotServiceUtils = require(ReplicatedStorage.Source.Features.Plots.PlotServiceUtils)
local PlotSlice = require(ReplicatedStorage.Source.Features.Plots.PlotSlice)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local e = React.createElement

type TowerUpgradeGuiProps = {
	root: BasePart,
	towerData: DataTemplate.TowerData & { floor: number, node: number },
}

local function TowerUpgradeGui(props: TowerUpgradeGuiProps)
	return e("SurfaceGui", {
		Adornee = props.root,
		Face = Enum.NormalId.Front,
		PixelsPerStud = 50,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		LightInfluence = 0,
		SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
	}, {
		Button = e(StudButton.Green, {
			Size = UDim2.fromScale(0.85, 0.6),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			StrokeThickness = 7,
			Activated = function()
				PlotServiceClient:requestUpgrade(props.towerData.floor, props.towerData.node)
			end,
		}, {
			Cost = e(TextLabel, {
				Text = "$" .. Abbreviate(PlotServiceUtils.getUpgradeCost(props.towerData)),
				Size = UDim2.fromScale(0.85, 0.64),
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0.02),
				Stroke = { Thickness = 4 },
			}),

			Lvl = e(TextLabel, {
				Text = `Lvl {props.towerData.level}  →  Lvl {props.towerData.level + 1}`,
				Size = UDim2.fromScale(0.85, 0.34),
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.fromScale(0.5, 0.98),
				Stroke = { Thickness = 4 },
			}),

			Upgrade = e("ImageLabel", {
				Size = UDim2.fromScale(0.62, 0.62),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.45),
				Image = ImageIds.upgrade,
				BackgroundTransparency = 1,
			}),
		}),
	})
end

return function()
	local towersData = ReactCharm.useAtom(PlotSlice.states.towerUpgrades)
	local upgrades = {}
	for root, towerData in towersData do
		upgrades[root] = e(TowerUpgradeGui, {
			root = root,
			towerData = towerData,
		})
	end

	return upgrades
end
