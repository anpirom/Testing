local NULL = "NULL"

export type CrateData = {
	crateId: string,
	amt: number,
	mutations: Mutations?,
	fav: boolean?,
}

export type Mutations = {
	gold: boolean?,
	diamond: boolean?,
	inferno: boolean?,
	windy: boolean?,
	radioactive: boolean?,
	volcano: boolean?,
}

export type TowerData = {
	itemId: string,
	level: number,
	fav: boolean?,
	mutations: Mutations?,
}

export type ItemData = CrateData & TowerData

export type CrateNode = {
	crateId: string,
	timeBuilt: number,
	mutations: Mutations?,
}

export type NodeData = CrateNode & TowerData
export type PlotNode = CrateNode & string
export type PlotNodes = { [string]: PlotNode }

export type OccupiedNode = CrateNode & string
export type OccupiedNodes = { [string]: OccupiedNode }

export type UnprocessedInstaCrate = {
	floor: number,
	node: number,
	n: number,
}

export type InstaOpenCrates = { [number]: UnprocessedInstaCrate }

export type ConveyorBoughtCrate = {
	conveyorIndex: number,
	n: number,
	crateId: string,
	mutations: Mutations?,
}

return {
	currency = 100,
	rebirths = 0,
	conveyorLevel = 1,
	instaOpenCrates = {},
	conveyorBoughtCrates = {},
	towerIndex = {
		normal = {},
		gold = {},
		diamond = {},
	},
	plotNodes = {},
	inventory = {},
	hotbar = { NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL },
	tutorial = {
		step = "joinInit",
		completed = false,
	},
	stats = {
		crateRolls = 0,
		cratesOpened = 0,
		enemiesKilled = 0,
		totalCurrency = 0,
		timePlayed = 0,
		robuxSpent = 0,
	},
	settings = {
		music = true,
	},
}
