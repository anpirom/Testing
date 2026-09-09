local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local Mutations = require(ReplicatedStorage.Source.Features.Mutations.Modules.Mutations)
local PlotServiceUtils = require(ReplicatedStorage.Source.Features.Plots.PlotServiceUtils)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)
type ItemData = DataTemplate.ItemData

local InventoryServiceUtils = {}

function InventoryServiceUtils.getModel(itemData: ItemData): Model
	if itemData.crateId then
		return Towers.getCrateModel(itemData.crateId)
	elseif itemData.itemId then
		return Towers.getTowerModel(itemData.itemId, itemData.mutations)
	end
	error("No model found for itemData")
end

function InventoryServiceUtils.getToolModel(itemData: ItemData): (Model, WeldConstraint)
	local model = InventoryServiceUtils.getModel(itemData)
	local root = model.PrimaryPart :: BasePart
	assert(root, "Model must have a PrimaryPart")
	model.Parent = workspace
	for _, part in model:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end
		part.CanCollide = false
		part.Massless = true
		part.Anchored = false
		local joints = part:GetJoints()
		if part ~= root and (not joints or not joints[1]) then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = root
			weld.Part1 = part
			weld.Parent = part
		end
	end

	local rootWeld = Instance.new("WeldConstraint")
	rootWeld.Part0 = root
	rootWeld.Parent = root

	return model, rootWeld
end

function InventoryServiceUtils.getCrateKey(crateData: DataTemplate.CrateData): string
	local mutationKey = ""
	if crateData.mutations then
		for _, mutation in Mutations.sortedMutations do
			if crateData.mutations[mutation] then
				local sub = string.sub(mutation, 1, 4)
				mutationKey ..= sub .. "_"
			end
		end
	end

	return crateData.crateId .. "_" .. mutationKey
end

function InventoryServiceUtils.getSellValue(itemData: ItemData): number
	if itemData.crateId then
		local crateInfo = Towers.getTowerInfo(itemData.crateId)
		return crateInfo.crateCost * itemData.amt / 2
	else
		local towerInfo = Towers.getTowerInfo(itemData.itemId)
		local baseValue = towerInfo.crateCost / 1.5
		local levelCost = PlotServiceUtils.getTotalLevelCost(itemData.level)
		local total = baseValue + levelCost / 2
		return math.floor(total)
	end
end

return InventoryServiceUtils
