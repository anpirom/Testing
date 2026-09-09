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
