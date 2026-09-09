local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ColorTweaker = require(ReplicatedStorage.Source.Core.Platform.ColorTweaker)
local Abbreviate = require(ReplicatedStorage.Source.Core.UI.Abbreviate)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
export type TowerInfo = {
	name: string,
	image: string,
	crateImage: string,
	crateCost: number,
	crateOpenTime: number,
	weight: number,
	damage: number,
	range: number,
	firerate: number,
	odds: number,
	id: string,
	height: number,
	layoutOrder: number,
	hidden: boolean?,
	isLuckyBlock: boolean?,
	percentDamageOfBest: number?,
	luck: number?,
}

local towers = {
	crossbow = {
		name = "Crossbow",
		image = "rbxassetid://137282012852812",
		crateImage = "rbxassetid://92040501256272",
		crateOpenTime = 3,
		crateCost = 100, --x12
		weight = 10e9,
		damage = 4,
		range = 25,
		firerate = 2,
		height = 6,
	},

	catapult = {
		name = "Catapult",
		image = "rbxassetid://83891927108386",
		crateImage = "rbxassetid://106355486794326",
		crateOpenTime = 10,
		crateCost = 250, --x16
		weight = 4e9,
		damage = 15,
		range = 25,
		firerate = 1,
		height = 6,
	},

	cannon = {
		name = "Cannon",
		image = "rbxassetid://71141124599337",
		crateImage = "rbxassetid://135070263716258",
		crateOpenTime = 30,
		crateCost = 1e3, --x38
		weight = 1.5e9,
		damage = 40,
		range = 25,
		firerate = 0.66,
		height = 6.5,
	},

	harpoon = {
		name = "Harpoon",
		image = "rbxassetid://137268285026540",
		crateImage = "rbxassetid://72492711846524",
		crateOpenTime = 60,
		crateCost = 3e3, --x50
		weight = 600e6,
		damage = 40,
		range = 25,
		firerate = 1.5,
		height = 8,
	},

	turret = {
		name = "Turret",
		image = "rbxassetid://120894736547855",
		crateImage = "rbxassetid://70665389038956",
		crateOpenTime = 90,
		crateCost = 8e3, --x66
		weight = 187e6,
		damage = 120,
		range = 25,
		firerate = 1,
		height = 7,
	},

	minigun = {
		name = "Minigun",
		image = "rbxassetid://109830357002566",
		crateImage = "rbxassetid://119950507122000",
		crateOpenTime = 2 * 60,
		crateCost = 25e3, --x90
		weight = 64e6,
		damage = 66,
		range = 25,
		firerate = 4,
		height = 7,
	},

	tesla = {
		name = "Tesla",
		image = "rbxassetid://103187875630362",
		crateImage = "rbxassetid://136054785134449",
		crateOpenTime = 3 * 60,
		crateCost = 60e3,
		weight = 28e6,
		damage = 500,
		range = 25,
		firerate = 1,
		height = 10,
	},

	orbOfLight = {
		name = "Orb of Light",
		image = "rbxassetid://135703405395373",
		crateImage = "rbxassetid://115551403938538",
		crateOpenTime = 5 * 60,
		crateCost = 400e3,
		weight = 16e6,
		damage = 1200,
		range = 25,
		firerate = 0.85,
		height = 9.5,
	},

	laserBlaster = {
		name = "Laser Blaster",
		image = "rbxassetid://88729081935706",
		crateImage = "rbxassetid://88495801126575",
		crateOpenTime = 7.5 * 60,
		crateCost = 1.75e6,
		weight = 7.5e6,
		damage = 1600,
		range = 25,
		firerate = 1.25,
		height = 8.5,
	},

	flamethrower = {
		name = "Flamethrower",
		image = "rbxassetid://88926794711093",
		crateImage = "rbxassetid://90654635690164",
		crateOpenTime = 10 * 60,
		crateCost = 6.7e6,
		weight = 4e6,
		damage = 912,
		range = 25,
		firerate = 4.2,
		height = 8,
	},

	plasmaCannon = {
		name = "Plasma Cannon",
		image = "rbxassetid://108066246307037",
		crateImage = "rbxassetid://96169247372637",
		crateOpenTime = 15 * 60,
		crateCost = 24e6,
		weight = 2.1e6,
		damage = 8e3,
		range = 25,
		firerate = 1,
		height = 8.5,
	},

	infrared = {
		name = "Infrared",
		image = "rbxassetid://129041646281210",
		crateImage = "rbxassetid://133478531453014",
		crateOpenTime = 20 * 60,
		crateCost = 55e6,
		weight = 1e6,
		damage = 10.5e3,
		range = 25,
		firerate = 1.5,
		height = 14,
	},

	volcano = {
		name = "Volcano",
		image = "rbxassetid://129284682759076",
		crateImage = "rbxassetid://111356018956419",
		crateOpenTime = 25 * 60,
		crateCost = 120e6,
		weight = 500e3,
		damage = 7.8e3,
		range = 25,
		firerate = 4.2,
		height = 10,
	},

	darkTerra = {
		name = "Dark Terra",
		image = "rbxassetid://123999583651842",
		crateImage = "rbxassetid://87019068271372",
		crateOpenTime = 30 * 60,
		crateCost = 267e6,
		weight = 250e3,
		damage = 10.5e3,
		range = 25,
		firerate = 6,
		height = 10,
	},

	orbOfDarkness = {
		name = "Orb of Darkness",
		image = "rbxassetid://80196609282103",
		crateImage = "rbxassetid://93915998308839",
		crateOpenTime = 35 * 60,
		crateCost = 550e6,
		weight = 125e3,
		damage = 125e3,
		range = 25,
		firerate = 1,
		height = 14,
	},

	hydroBlaster = {
		name = "Hydro Blaster",
		image = "rbxassetid://77458757609902",
		crateImage = "rbxassetid://111555494255092",
		crateOpenTime = 40 * 60,
		crateCost = 1.2e9,
		weight = 63e3,
		damage = 61e3,
		range = 25,
		firerate = 4.2,
		height = 10,
	},

	overseer = {
		name = "Overseer",
		image = "rbxassetid://85069178841415",
		crateImage = "rbxassetid://137874098885716",
		crateOpenTime = 45 * 60,
		crateCost = 3.1e9,
		weight = 30e3,
		damage = 205e3,
		range = 25,
		firerate = 2.5,
		height = 17,
	},

	obliterator = {
		name = "Obliterator",
		image = "rbxassetid://102897043398524",
		crateImage = "rbxassetid://97926957163960",
		crateOpenTime = 50 * 60,
		crateCost = 7.6e9,
		weight = 15e3,
		damage = 261e3,
		range = 25,
		firerate = 4,
		height = 9,
	},

	phantom = {
		name = "Phantom",
		image = "rbxassetid://112711416437129",
		crateImage = "rbxassetid://125664701404192",
		crateOpenTime = 55 * 60,
		crateCost = 18e9,
		weight = 8e3,
		damage = 475e3,
		range = 25,
		firerate = 4.2,
		height = 11,
	},

	protonSniper = {
		name = "Proton Sniper",
		image = "rbxassetid://71267814543164",
		crateImage = "rbxassetid://121324063838249",
		crateOpenTime = 60 * 60,
		crateCost = 45e9,
		weight = 4e3,
		damage = 4.3e6,
		range = 25,
		firerate = 1,
		height = 9,
	},

	dualshot = {
		name = "Dualshot",
		image = "rbxassetid://119923869478094",
		crateImage = "rbxassetid://119078506264377",
		crateOpenTime = 70 * 60,
		crateCost = 140e9,
		weight = 2e3,
		damage = 4.2e6,
		range = 25,
		firerate = 2,
		height = 9,
	},

	superTesla = {
		name = "Super Tesla",
		image = "rbxassetid://89220675611412",
		crateImage = "rbxassetid://98772576870574",
		crateOpenTime = 80 * 60,
		crateCost = 425e9,
		weight = 1e3,
		damage = 16.7e6,
		range = 25,
		firerate = 1,
		height = 17,
	},

	railgun = {
		name = "Railgun",
		image = "rbxassetid://130781208461690",
		crateImage = "rbxassetid://71411355602861",
		crateOpenTime = 90 * 60,
		crateCost = 1.2e12,
		weight = 500,
		damage = 43e6,
		range = 25,
		firerate = 0.75,
		height = 9,
	},

	overdrive = {
		name = "Overdrive",
		image = "rbxassetid://139408627674878",
		crateImage = "",
		crateOpenTime = 0,
		crateCost = 0,
		weight = 0,
		damage = 1,
		percentDamageOfBest = 1.10,
		range = 25,
		firerate = 4,
		height = 14,
	},

	eradicator = {
		name = "Eradicator",
		image = "rbxassetid://91921018694227",
		crateImage = "",
		crateOpenTime = 0,
		crateCost = 0,
		weight = 0,
		damage = 1,
		percentDamageOfBest = 1.35,
		range = 25,
		firerate = 1,
		height = 12,
	},

	pyramidium = {
		name = "Pyramidium",
		image = "rbxassetid://98593813513836",
		crateImage = "",
		crateOpenTime = 0,
		crateCost = 0,
		weight = 0,
		damage = 1,
		percentDamageOfBest = 2.0,
		range = 25,
		firerate = 6,
		height = 12,
	},

	luckyBlock1 = {
		name = "Lucky Block",
		image = "rbxassetid://139800799913497",
		crateImage = "rbxassetid://139800799913497",
		crateOpenTime = 0,
		crateCost = 0,
		weight = 0,
		hidden = true,
		isLuckyBlock = true,
		luck = 100,
	},

	luckyBlock2 = {
		name = "Lucky Block",
		image = "rbxassetid://87990645026992",
		crateImage = "rbxassetid://87990645026992",
		crateOpenTime = 0,
		crateCost = 0,
		weight = 0,
		hidden = true,
		isLuckyBlock = true,
		luck = 500,
	},

	luckyBlock3 = {
		name = "Lucky Block",
		image = "rbxassetid://122795423201439",
		crateImage = "rbxassetid://122795423201439",
		crateOpenTime = 0,
		crateCost = 0,
		weight = 0,
		hidden = true,
		isLuckyBlock = true,
		luck = 1000,
	},
}

local totalWeight = 0
for _, towerInfo in towers do
	totalWeight += towerInfo.weight
end

local sortedTowers = {}
for towerId, towerInfo in towers do
	towerInfo.odds = towerInfo.weight / totalWeight
	towerInfo.id = towerId
	table.insert(sortedTowers, towerInfo)
end

table.sort(sortedTowers, function(a, b)
	return a.weight > b.weight
end)

for i, tower in sortedTowers do
	tower.layoutOrder = i
end

local Towers = {
	towers = towers,
	sortedTowers = sortedTowers,
}

function Towers.rollTowerId(luck: number): string
	local roll = math.random()
	local sum = 0
	for i = #sortedTowers, 1, -1 do
		local tower = sortedTowers[i]
		local chance = 1 - (1 - towers[tower.id].odds) ^ luck
		sum += chance
		if roll <= sum then
			return tower.id
		end
	end

	return sortedTowers[1].id
end

local DIAMOND_TWEAK: ColorTweaker.Tweak = {
	primaryColor = ColorTweaker.enums.primaryColors.master,
	valueBoost = 1.5,
	saturationBoost = 4,
	forcedhue = 0.55,
}

local GOLDEN_TWEAK: ColorTweaker.Tweak = {
	primaryColor = ColorTweaker.enums.primaryColors.master,
	valueBoost = 1.2,
	saturationBoost = 4,
	forcedhue = 0.133,
}

function Towers.getTowerModel(towerId: string, mutations: DataTemplate.Mutations?): Model
	assert(towers[towerId], "Invalid tower ID" .. towerId)
	local model = ReplicatedStorage.Assets.Towers[towerId]:Clone()
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end

	if mutations and mutations.diamond then
		ColorTweaker.fromContainer(model, DIAMOND_TWEAK)
	elseif mutations and mutations.gold then
		ColorTweaker.fromContainer(model, GOLDEN_TWEAK)
	end

	return model
end

function Towers.getCrateModel(crateId: string): Model
	assert(towers[crateId], "Invalid crate ID" .. crateId)
	local model = ReplicatedStorage.Assets.Crates[crateId]:Clone()
	return model
end

function Towers.getTowerInfo(towerId: string): TowerInfo
	assert(towers[towerId], "Invalid towerId: " .. towerId)
	return towers[towerId]
end

local function _listOdds()
	print("--------------------------------")
	for _, tower in sortedTowers do
		print(
			"1/"
				.. Abbreviate(math.ceil(1 / tower.odds))
				.. " "
				.. math.round(tower.odds * 10000) / 100
				.. "% "
				.. tower.name
		)
	end
end

return Towers
