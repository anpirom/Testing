local rebirthRewards = {
	[1] = {
		towerSlots = 2,
	},
	[2] = {
		towerSlots = 2,
		floors = 1,
	},
	[3] = {
		towerSlots = 2,
	},
	[4] = {
		towerSlots = 2,
	},
	[5] = {
		towerSlots = 2,
	},
	[6] = {
		towerSlots = 2,
	},
	[7] = {
		towerSlots = 2,
	},
	[8] = {
		towerSlots = 2,
	},
	[9] = {
		towerSlots = 2,
	},
}

local rebirthRequirements = {
	[1] = {
		towerId = "harpoon",
		currency = 5e3,
	},
	[2] = {
		towerId = "tesla",
		currency = 100e3,
	},
	[3] = {
		towerId = "laserBlaster",
		currency = 2e6,
	},
	[4] = {
		towerId = "plasmaCannon",
		currency = 30e6,
	},
	[5] = {
		towerId = "volcano",
		currency = 200e6,
	},
	[6] = {
		towerId = "orbOfDarkness",
		currency = 676e6,
	},
	[7] = {
		towerId = "overseer",
		currency = 4e9,
	},
	[8] = {
		towerId = "phantom",
		currency = 22e9,
	},
	[9] = {
		towerId = "dualshot",
		currency = 150e9,
	},
}

local RebirthUtils = {
	rebirthRewards = rebirthRewards,
}

function RebirthUtils.getRebirthCost(rebirths: number)
	return rebirthRequirements[math.min(rebirths + 1, #rebirthRequirements)].currency
end

function RebirthUtils.getRebirthTowerRequirement(rebirths: number)
	return rebirthRequirements[rebirths + 1].towerId
end

function RebirthUtils.isMaxedRebirths(rebirths: number)
	return rebirths >= #rebirthRequirements
end

function RebirthUtils.getRequirements(rebirths: number)
	local currency = RebirthUtils.getRebirthCost(rebirths)
	local towerIdReq = RebirthUtils.getRebirthTowerRequirement(rebirths)
	return {
		towerId = towerIdReq,
		currency = currency,
	}
end

return RebirthUtils
