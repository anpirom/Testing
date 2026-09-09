local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Menu = require(script.Parent.Menu)
local React = require(ReplicatedStorage.Packages.React)
local Abbreviate = require(ReplicatedStorage.Source.Core.UI.Abbreviate)
local useDataState = require(ReplicatedStorage.Source.Core.UI.Hooks.useDataState)
local TextLabel = require(ReplicatedStorage.Source.Core.UI.Primitives.TextLabel)
local InsetFrame = require(ReplicatedStorage.Source.Features.App.UI.Components.InsetFrame)
local StudButton = require(ReplicatedStorage.Source.Features.App.UI.Components.StudButton)
local TransparentFrame = require(ReplicatedStorage.Source.Features.App.UI.Components.TransparentFrame)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local RebirthUtils = require(ReplicatedStorage.Source.Features.Plots.Modules.RebirthUtils)
local PlotServiceClient = require(ReplicatedStorage.Source.Features.Plots.PlotServiceClient)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local Tiers = require(ReplicatedStorage.Source.Game.Items.Tiers)
local e = React.createElement

local function ClaimedCheckMark()
	return e("ImageLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Image = ImageIds.checkmark,
		ZIndex = 9,
	})
end

local function RequirementsFrame()
	local rebirths: number = useDataState("rebirths")
	local currency = useDataState("currency")
	local towerIndex = useDataState("towerIndex")

	if RebirthUtils.isMaxedRebirths(rebirths) then
		return e(InsetFrame, {
			Size = UDim2.new(0.9, 0, 0, 160),
			Position = UDim2.fromScale(0.5, 0.075),
			AnchorPoint = Vector2.new(0.5, 0),
		}, {
			e(TextLabel, {
				Text = "MAXED",
				Size = UDim2.fromScale(1, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Stroke = { Thickness = 3 },
			}),
		})
	end

	local reqs = RebirthUtils.getRequirements(rebirths)
	local towerInfo = Towers.getTowerInfo(reqs.towerId)
	local tier = Tiers.getTierForOdds(towerInfo.odds)
	local currencyReqMet = currency >= reqs.currency
	local towerReqMet = towerIndex.normal[reqs.towerId]
		or towerIndex.gold[reqs.towerId]
		or towerIndex.diamond[reqs.towerId]

	return e(InsetFrame, {
		Size = UDim2.new(0.9, 0, 0, 160),
		Position = UDim2.fromScale(0.5, 0.075),
		AnchorPoint = Vector2.new(0.5, 0),
	}, {
		Layout = e("UIListLayout", {
			Padding = UDim.new(0, 20),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		TowerReq = e(TransparentFrame, {
			Size = UDim2.fromScale(0.7, 0.7),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			LayoutOrder = 2,
		}, {
			Tier = e(TextLabel, {
				Text = tier.name,
				Size = UDim2.fromScale(1, 0.3),
				Position = UDim2.fromScale(0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Stroke = { Thickness = 2 },
				ZIndex = 2,
				Gradient = {
					Rotation = 90,
					Color = tier.gradient,
				},
			}),

			Tower = e(TextLabel, {
				Text = towerInfo.name,
				Size = UDim2.fromScale(1, 0.25),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 1),
				ZIndex = 2,
				Stroke = {},
			}),

			Icon = e("ImageLabel", {
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = towerInfo.image,
				ImageColor3 = if towerReqMet then Color3.fromRGB(51, 51, 51) else Color3.fromRGB(255, 255, 255),
			}),

			Background = e("ImageLabel", {
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromScale(0.5, 0.55),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				ImageColor3 = Color3.fromRGB(0, 0, 0),
				ImageTransparency = 0.4,
				Image = towerInfo.image,
				ZIndex = 0,
			}),

			Checkmark = if towerReqMet then e(ClaimedCheckMark) else nil,
		}),

		CurrencyReq = e(TransparentFrame, {
			Size = UDim2.fromScale(0.7, 0.7),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			LayoutOrder = 1,
		}, {
			Checkmark = if currencyReqMet then e(ClaimedCheckMark) else nil,

			Currency = e(TextLabel, {
				Text = "$" .. Abbreviate(reqs.currency),
				Size = UDim2.fromScale(1, 0.3),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0),
				ZIndex = 2,
				Stroke = {},
				Gradient = {
					Rotation = 90,
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(226, 255, 192)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 255, 0)),
					}),
				},
			}),

			Text = e(TextLabel, {
				Text = "Money",
				Size = UDim2.fromScale(1, 0.25),
				Position = UDim2.fromScale(0.5, 1),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Stroke = { Thickness = 2 },
				ZIndex = 2,
			}),

			Icon = e("ImageLabel", {
				Size = UDim2.fromScale(0.9, 0.9),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = ImageIds.currency,
				ImageColor3 = if currencyReqMet then Color3.fromRGB(51, 51, 51) else Color3.fromRGB(255, 255, 255),
			}),
		}),
	})
end

local function RewardsFrame()
	local rebirths: number = useDataState("rebirths")
	local rewards = RebirthUtils.rebirthRewards[rebirths + 1]

	if not rewards then
		return e(InsetFrame, {
			Size = UDim2.new(0.9, 0, 0, 160),
			Position = UDim2.fromScale(0.5, 0.48),
			AnchorPoint = Vector2.new(0.5, 0),
		}, {
			e(TextLabel, {
				Text = "MAXED",
				Size = UDim2.fromScale(1, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Stroke = { Thickness = 3 },
			}),
		})
	end

	return e(InsetFrame, {
		Size = UDim2.new(0.9, 0, 0, 160),
		Position = UDim2.fromScale(0.5, 0.48),
		AnchorPoint = Vector2.new(0.5, 0),
	}, {
		Layout = e("UIListLayout", {
			Padding = UDim.new(0, 20),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Slots = e(TransparentFrame, {
			Size = UDim2.fromScale(0.7, 0.7),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			LayoutOrder = 2,
		}, {
			Currency = e(TextLabel, {
				Text = "Tower Slot",
				Size = UDim2.fromScale(1.1, 0.3),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0),
				ZIndex = 2,
				Stroke = {},
				Gradient = {
					Rotation = 90,
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(192, 255, 255)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 110, 255)),
					}),
				},
			}),

			Text = e(TextLabel, {
				Text = "+" .. rewards.towerSlots,
				Size = UDim2.fromScale(1, 0.3),
				Position = UDim2.fromScale(0.5, 0.95),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Stroke = { Thickness = 3 },
				ZIndex = 2,
			}),

			Icon = e("ImageLabel", {
				Size = UDim2.fromScale(0.9, 0.9),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = ImageIds.extraSlot,
			}),
		}),

		Floors = if rewards.floors
			then e(TransparentFrame, {
				Size = UDim2.fromScale(0.7, 0.7),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				LayoutOrder = 3,
			}, {
				Currency = e(TextLabel, {
					Text = "Extra Floor",
					Size = UDim2.fromScale(1.1, 0.3),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0),
					ZIndex = 2,
					Stroke = {},
					Gradient = {
						Rotation = 90,
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromRGB(192, 255, 255)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 110, 255)),
						}),
					},
				}),

				Text = e(TextLabel, {
					Text = "+" .. rewards.floors,
					Size = UDim2.fromScale(1, 0.3),
					Position = UDim2.fromScale(0.5, 0.95),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Stroke = { Thickness = 3 },
					ZIndex = 2,
				}),

				Icon = e("ImageLabel", {
					Size = UDim2.fromScale(0.9, 0.9),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = ImageIds.floorSlot,
				}),
			})
			else nil,

		CurrencyMult = e(TransparentFrame, {
			Size = UDim2.fromScale(0.7, 0.7),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			LayoutOrder = 1,
		}, {

			Currency = e(TextLabel, {
				Text = "+10%",
				Size = UDim2.fromScale(1, 0.3),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0),
				ZIndex = 2,
				Stroke = {},
				Gradient = {
					Rotation = 90,
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(226, 255, 192)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 255, 0)),
					}),
				},
			}),

			Text = e(TextLabel, {
				Text = "Money Bonus",
				Size = UDim2.fromScale(1, 0.25),
				Position = UDim2.fromScale(0.5, 1),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Stroke = { Thickness = 2 },
				ZIndex = 2,
			}),

			Icon = e("ImageLabel", {
				Size = UDim2.fromScale(0.9, 0.9),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = ImageIds.currency,
			}),
		}),
	})
end

local function RebirthButton()
	local rebirths: number = useDataState("rebirths")
	local isMaxed = RebirthUtils.isMaxedRebirths(rebirths)
	return e(StudButton.Green, {
		Text = if isMaxed then "MAXED" else "Rebirth!",
		Size = UDim2.fromOffset(200, 60),
		Position = UDim2.fromScale(0.5, 0.88),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Activated = function()
			if isMaxed then
				return
			end
			PlotServiceClient:rebirth()
		end,
	})
end

return function()
	return e(Menu.Component, {
		menuName = "RebirthMenu",
		Title = "Rebirth",
		From = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromOffset(600, 530),
		Prefix = {
			Image = ImageIds.rebirth,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		},
	}, {
		RequirementsTitle = e(TextLabel, {
			Text = "- YOU NEED -",
			Size = UDim2.new(1, 0, 0, 38),
			Position = UDim2.fromScale(0.5, 0.007),
			AnchorPoint = Vector2.new(0.5, 0),
			Stroke = { Thickness = 3 },
		}),

		Requirements = e(RequirementsFrame),

		RewardsTitle = e(TextLabel, {
			Text = "- REWARDS -",
			Size = UDim2.new(1, 0, 0, 38),
			Position = UDim2.fromScale(0.5, 0.41),
			AnchorPoint = Vector2.new(0.5, 0),
			Stroke = { Thickness = 3 },
			Gradient = {
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 233, 162)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 187, 0)),
				}),
			},
		}),

		Rewards = e(RewardsFrame),

		Button = e(RebirthButton),

		Warning = e(TextLabel, {
			Text = "[ ! ]  Money is RESET, eveything else is kept! [ ! ]",
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.fromScale(0.5, 0.97),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Stroke = { Thickness = 2, Color = Color3.fromRGB(102, 0, 0) },
			TextColor3 = Color3.fromRGB(255, 46, 46),
		}),
	})
end
