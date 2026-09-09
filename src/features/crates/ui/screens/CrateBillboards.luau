local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Abbreviate = require(ReplicatedStorage.Source.Core.UI.Abbreviate)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local CrateSlice = require(ReplicatedStorage.Source.Features.Crates.CrateSlice)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local Tiers = require(ReplicatedStorage.Source.Game.Items.Tiers)
local e = React.createElement

local function CrateBillboard(props: { instance: Instance, crateId: string })
	local crateInfo = Towers.getTowerInfo(props.crateId)
	local tierData = Tiers.getTierForOdds(crateInfo.odds)
	return e("BillboardGui", {
		Adornee = props.instance,
		AlwaysOnTop = true,
		ExtentsOffsetWorldSpace = Vector3.new(0, 11, 0),
		Size = UDim2.fromScale(15, 5),
	}, {
		Layout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Tier = e(TextLabel, {
			Text = tierData.name,
			Size = UDim2.fromScale(1, 0.36),
			LayoutOrder = 1,
			Stroke = {},
			Gradient = {
				Rotation = 90,
				Color = tierData.gradient,
			},
		}),

		CrateName = e(TextLabel, {
			Text = crateInfo.name .. " Crate",
			Size = UDim2.fromScale(1, 0.28),
			LayoutOrder = 2,
			Stroke = {},
		}),

		Cost = e(TextLabel, {
			Text = `${Abbreviate(crateInfo.crateCost)}`,
			Size = UDim2.fromScale(1, 0.36),
			LayoutOrder = 3,
			Stroke = {},
			Gradient = {
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(226, 255, 192)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 255, 0)),
				}),
			},
		}),
	})
end

return function()
	local crates = ReactCharm.useAtom(CrateSlice.state.crates)
	return e(
		React.Fragment,
		nil,
		Sift.Dictionary.map(crates, function(crateId, instance)
			return e(CrateBillboard, { instance = instance, crateId = crateId })
		end)
	)
end
