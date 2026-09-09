local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Mutations = require(ReplicatedStorage.Source.Features.Mutations.Modules.Mutations)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

type Mutations = DataTemplate.Mutations

local MutationServiceUtils = {}

function MutationServiceUtils.rollMutations(
	activeEvents: { string },
	goldHunterPass: boolean,
	diamondHunterPass: boolean
): Mutations?
	local luck = 1
	local mutations = {}

	for _, eventId in activeEvents do
		local roll = math.random()
		local eventRollChance = Mutations.mutations[eventId].odds
		local chance = 1 - (1 - eventRollChance) ^ luck
		if roll < chance then
			mutations[eventId] = true
		end
	end

	local diamondChance = 1 - (1 - Mutations.mutations.diamond.odds) ^ luck
	local goldChance = 1 - (1 - Mutations.mutations.gold.odds) ^ luck

	if diamondHunterPass then
		diamondChance *= 2
	end

	if goldHunterPass then
		goldChance *= 2
	end

	if math.random() < diamondChance then
		mutations.diamond = true
	elseif math.random() < goldChance then
		mutations.gold = true
	end

	if next(mutations) == nil then
		return nil
	end

	return mutations
end

return MutationServiceUtils
