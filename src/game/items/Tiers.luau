export type TierData = {
	name: string,
	odds: number,
	gradient: ColorSequence,
	tierId: string,
}

local tiers = {
	common = {
		name = "Common",
		odds = 1,
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200)),
		}),
	},

	uncommon = {
		name = "Uncommon",
		odds = 1 / 10,
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(172, 255, 134)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 0)),
		}),
	},

	rare = {
		name = "Rare",
		odds = 1 / 50,
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(134, 221, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 200)),
		}),
	},

	epic = {
		name = "Epic",
		odds = 1 / 300,
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 134, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 0, 200)),
		}),
	},

	legendary = {
		name = "Legendary",
		odds = 1 / 2e3,
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 204, 102)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 102, 0)),
		}),
	},

	mythic = {
		name = "Mythic",
		odds = 1 / 13e3,
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 75, 75)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 0)),
		}),
	},

	divine = {
		name = "Divine",
		odds = 1 / 75e3,
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(187, 39, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 192, 118)),
		}),
	},

	exotic = {
		name = "Exotic",
		odds = 1 / 600e3,
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 150)),
		}),
	},

	ascended = {
		name = "Ascended",
		odds = 1 / 4e6,
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 0, 0)),
		}),
	},

	eternal = {
		name = "Eternal",
		odds = 1 / 25e6,
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 150)),
		}),
	},
}

local sortedTiers = {}
for tierId, tierData in tiers do
	tierData.tierId = tierId
	table.insert(sortedTiers, { tierId = tierId, data = tierData })
end
table.sort(sortedTiers, function(a, b)
	return a.data.odds > b.data.odds
end)

local Tiers = {}

function Tiers.getTierForOdds(odds: number): TierData
	for i = #sortedTiers, 1, -1 do
		local tier = sortedTiers[i]
		if odds <= tier.data.odds then
			return tier.data
		end
	end

	return sortedTiers[1].data
end

function Tiers.getTierData(tierId: string): TierData
	return tiers[tierId]
end

return Tiers
