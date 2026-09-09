local mutations = {
	gold = {
		name = "Gold",
		description = "Increases damage",
		value = 1,
		odds = 1 / 25,
	},

	diamond = {
		name = "Diamond",
		description = "Greatly increases damage",
		value = 2,
		odds = 1 / 250,
	},

	windy = {
		name = "Windy",
		description = "Increases attack speed",
		value = 3,
		odds = 1 / 10,
	},

	inferno = {
		name = "Inferno",
		description = "Adds burn damage over time",
		value = 4,
		odds = 1 / 10,
	},

	radioactive = {
		name = "Radioactive",
		description = "Attacks poison enemies",
		value = 5,
		odds = 1 / 10,
	},

	volcano = {
		name = "Volcano",
		description = "Increases damage",
		value = 6,
		odds = 1 / 20,
	},
}

local mutationValues = {}
for key, mutation in mutations do
	assert(mutation.value ~= nil, "Mutation must have a value")
	assert(
		mutationValues[mutation.value] == nil,
		"Duplicate mutation value: " .. mutation.value .. " for mutation " .. key
	)
	mutationValues[mutation.value] = key
end

local Mutations = {
	mutations = mutations,
	sortedMutations = mutationValues :: { string },
}

function Mutations.getByValue(value: number)
	return mutations[mutationValues[value]]
end

return Mutations
