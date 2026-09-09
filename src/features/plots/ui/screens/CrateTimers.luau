local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local FormatTime = require(ReplicatedStorage.Source.Core.UI.FormatTime)
local useServerTimeBinding = require(ReplicatedStorage.Source.Core.UI.Hooks.useServerTimeBinding)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local useGamepass = require(ReplicatedStorage.Source.Features.Monetization.Hooks.useGamepass)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local PlotSlice = require(ReplicatedStorage.Source.Features.Plots.PlotSlice)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local Tiers = require(ReplicatedStorage.Source.Game.Items.Tiers)
local e = React.createElement

type CrateTimerProps = {
	root: BasePart,
	crateData: DataTemplate.CrateNode,
}

local function CrateTimer(props: CrateTimerProps)
	local crateInfo = Towers.getTowerInfo(props.crateData.crateId)
	local ownsQuickUnlock = useGamepass(Products.doubleUnlockSpeed)
	local tier = Tiers.getTierForOdds(crateInfo.odds)
	local timeToOpen = crateInfo.crateOpenTime
	local crateOpenTime = props.crateData.timeBuilt + timeToOpen
	local serverTime = useServerTimeBinding()
	local text = serverTime:map(function(t)
		local timePassed = t - props.crateData.timeBuilt
		if ownsQuickUnlock then
			timePassed *= 2
		end

		local tLeft = math.ceil(crateOpenTime - props.crateData.timeBuilt - timePassed)
		if tLeft <= 0 then
			return "Ready!"
		end
		return FormatTime(tLeft) .. " Left"
	end)

	local barSize = serverTime:map(function(t)
		local timePassed = t - props.crateData.timeBuilt
		if ownsQuickUnlock then
			timePassed *= 2
		end
		local tLeft = math.ceil(crateOpenTime - props.crateData.timeBuilt - timePassed)
		local percent = math.clamp(tLeft / timeToOpen, 0, 1)
		return UDim2.fromScale(1 - percent, 1)
	end)

	return e("BillboardGui", {
		LightInfluence = 0,
		Adornee = props.root,
		StudsOffsetWorldSpace = Vector3.new(0, 8, 0),
		Size = UDim2.fromScale(7, 3.5),
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		AlwaysOnTop = true,
		MaxDistance = 200,
	}, {
		CrateName = e(TextLabel, {
			Text = crateInfo.name .. " Crate",
			Size = UDim2.fromScale(1, 0.325),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.6),
			Stroke = { Thickness = 0.1, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize },
		}),

		Rarity = e(TextLabel, {
			Text = tier.name,
			Gradient = { Color = tier.gradient, Rotation = 90 },
			Size = UDim2.fromScale(1, 0.45),
			Stroke = { Thickness = 0.1, StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize },
			Position = UDim2.fromScale(0.5, 0.1),
			AnchorPoint = Vector2.new(0.5, 0.5),
		}),

		Timer = e("Frame", {
			Size = UDim2.fromScale(1, 0.35),
			Position = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Color3.fromRGB(59, 63, 77),
		}, {
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(14, 14, 15),
				Thickness = 0.1,
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			}),

			Timer = e(TextLabel, {
				Text = text,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Stroke = {},
				ZIndex = 2,
				Size = UDim2.fromScale(1, 1),
			}),

			Bar = e("Frame", {
				Size = barSize,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0, 0),
			}, {
				e("UIGradient", {
					Color = ColorSequence.new(Color3.fromRGB(159, 252, 255), Color3.fromRGB(28, 119, 255)),
					Rotation = 90,
				}),
			}),
		}),
	})
end

return function()
	local cratesData = ReactCharm.useAtom(PlotSlice.states.crates)
	local crates = {}
	for root, crateData in cratesData do
		crates[root] = e(CrateTimer, {
			root = root,
			crateData = crateData,
		})
	end

	return crates
end
