local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
export type PlotSpawn = { part: BasePart, index: number, fakePlot: Model, owner: Player? }

export type Node = {
	root: BasePart,
	cf: CFrame,
	data: DataTemplate.NodeData?,
}

export type PlotData = {
	cf: CFrame,
	index: number,
	player: Player,
	plotModel: Model & any,
	nodes: { { Node } },
	paths: any,
	conveyorModel: (Model & any)?,
	crateOpening: boolean?,
	conveyorLevel: number,
	currencyMult: number,
	damageMult: number,
	bestDps: number,
	rebirths: number,
	towers: { { floor: number, node: Node, data: DataTemplate.TowerData, cf: CFrame } },
}

export type ClientNode = Node & {
	model: Model & any,
	crateOpening: boolean?,
}

return nil
