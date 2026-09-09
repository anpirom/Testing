local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
local atom = Charm.atom

type CrateNode = DataTemplate.CrateNode
type Atom<T> = Charm.Atom<T>

local crates: Atom<{ [BasePart]: CrateNode }> = atom({})
local rebirthReward: Atom<any?> = atom(nil)
local towerUpgrades: Atom<{ [BasePart]: DataTemplate.TowerData }> = atom({})
local characterFloor: Atom<number> = atom(1)

local actions = {
	addCrate = function(root: BasePart, crateData: CrateNode)
		crates(function(prev)
			return Sift.Dictionary.set(prev, root, crateData)
		end)
	end,

	removeCrate = function(root: BasePart)
		if crates()[root] == nil then
			return
		end

		crates(function(prev)
			return Sift.Dictionary.removeKey(prev, root)
		end)
	end,

	setTowerUpgrade = function(root: BasePart, itemData: any)
		if itemData and itemData.crateId then
			itemData = nil
		end

		if itemData and itemData.itemId and Towers.getTowerInfo(itemData.itemId).percentDamageOfBest then
			itemData = nil
		end

		if towerUpgrades()[root] == itemData then
			return
		end

		towerUpgrades(function(prev)
			return Sift.Dictionary.set(prev, root, itemData)
		end)
	end,
}

return {
	actions = actions,
	states = {
		crates = crates,
		rebirthReward = rebirthReward,
		towerUpgrades = towerUpgrades,
		characterFloor = characterFloor,
	},
}
