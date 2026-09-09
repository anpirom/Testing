local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local PlotServiceUtils = {
	enums = {
		crateSpawnCooldown = 0.5,
		factConveyorSpeed = 1.5,
	},
}

function PlotServiceUtils.floorNodeToString(floor: number, node: number): string
	return tostring(floor) .. "_" .. tostring(node)
end

function PlotServiceUtils.stringToFloorNode(floorNodeStr: string): (number, number)
	local separatorIndex = string.find(floorNodeStr, "_")
	if not separatorIndex then
		error("Invalid floorNodeStr: " .. floorNodeStr)
	end

	local floorStr = string.sub(floorNodeStr, 1, separatorIndex - 1)
	local nodeStr = string.sub(floorNodeStr, separatorIndex + 1)

	local floor = tonumber(floorStr)
	local node = tonumber(nodeStr)

	if not floor or not node then
		error("Invalid floorNodeStr: " .. floorNodeStr)
	end

	return floor, node
end

function PlotServiceUtils.getTotalLevelCost(level: number): number
	local totalCost = 0
	for lvl = 1, level - 1 do
		totalCost += 100 * 1.5 ^ (lvl - 1)
	end
	return totalCost
end

function PlotServiceUtils.getUpgradeCost(towerData: DataTemplate.TowerData): number
	return 100 * 1.5 ^ (towerData.level - 1)
end

function PlotServiceUtils.getDamageMultiplier(level: number): number
	return 1 + (level - 1) * 0.25
end

function PlotServiceUtils.getScaleFromLevel(level: number): number
	return 1.6 - (10 / (10 + (level + 4)))
end

function PlotServiceUtils.getDps(towerData: DataTemplate.TowerData): number
	local damage = PlotServiceUtils.calcDamage(towerData)
	local firerate = PlotServiceUtils.calcFirerate(towerData)
	return damage * firerate
end

function PlotServiceUtils.calcDamage(towerData: DataTemplate.TowerData): number
	local mutations = towerData.mutations
	local towerInfo = Towers.getTowerInfo(towerData.itemId)
	local levelMult = PlotServiceUtils.getDamageMultiplier(towerData.level)
	local mult = 1
	if mutations and mutations.gold then
		mult += 0.5
	end

	if mutations and mutations.diamond then
		mult += 1.0
	end

	if mutations and mutations.volcano then
		mult += 0.75
	end

	return towerInfo.damage * levelMult * mult
end

function PlotServiceUtils.calcFirerate(towerData: DataTemplate.TowerData): number
	local mutations = towerData.mutations
	local towerInfo = Towers.getTowerInfo(towerData.itemId)
	local firerate = towerInfo.firerate
	local mult = 1

	if mutations and mutations.windy then
		mult += 0.33
	end

	return firerate * mult
end

return PlotServiceUtils
