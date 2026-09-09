local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local Charm = require(ReplicatedStorage.Packages.Charm)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Networker = require(ReplicatedStorage.Packages.Networker)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Menu = require(ReplicatedStorage.Source.Features.App.UI.Menus.Menu)
local ConveyorClient = require(ReplicatedStorage.Source.Features.Conveyor.ConveyorClient)
local TouchPad = require(ReplicatedStorage.Source.Features.Conveyor.Modules.TouchPad)
local CrateOpenVfx = require(ReplicatedStorage.Source.Features.Crates.Modules.CrateOpenVfx)
local LuckyBlockOpenVfx = require(ReplicatedStorage.Source.Features.Crates.Modules.LuckyBlockOpenVfx)
local DefenseClient = require(ReplicatedStorage.Source.Features.Defense.Classes.DefenseClient)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local InventoryServiceClient = require(ReplicatedStorage.Source.Features.Inventory.InventoryServiceClient)
local InventoryServiceUtils = require(ReplicatedStorage.Source.Features.Inventory.InventoryServiceUtils)
local InventorySlice = require(ReplicatedStorage.Source.Features.Inventory.InventorySlice)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local MonetizationServiceClient = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceClient)
local PlotServiceUtils = require(ReplicatedStorage.Source.Features.Plots.PlotServiceUtils)
local PlotSlice = require(ReplicatedStorage.Source.Features.Plots.PlotSlice)
local PlotTypes = require(ReplicatedStorage.Source.Features.Plots.PlotTypes)
local TowerUpgradeSurfaceGui = require(ReplicatedStorage.Source.Features.Plots.UI.Components.TowerUpgradeSurfaceGui)
local TutorialServiceClient = require(ReplicatedStorage.Source.Features.Tutorial.TutorialServiceClient)
local ConveyorUpgrades = require(ReplicatedStorage.Source.Game.Items.ConveyorUpgrades)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

local PlotClient = {}
PlotClient.__index = PlotClient

type ClientNode = PlotTypes.ClientNode
type Node = PlotTypes.Node
type TowerData = DataTemplate.TowerData

export type PlotClient = typeof(setmetatable(
	{} :: {
		cf: CFrame,
		index: number,
		player: Player,
		plotModel: Model & any,
		janitor: Janitor.Janitor,
		nodes: { { ClientNode } },
		defense: DefenseClient.DefenseClient,
		rebirths: number,
		defenseJanitor: Janitor.Janitor,
		networker: Networker.Client,
		nodesUpdated: Signal.Signal<number, number>,
		conveyor: ConveyorClient.ConveyorClient,
		isReplicated: boolean,
	},
	PlotClient
))

function PlotClient.new(plotData: PlotTypes.PlotData): PlotClient
	local self: PlotClient = setmetatable({
		cf = plotData.cf,
		index = plotData.index,
		player = plotData.player,
		plotModel = plotData.plotModel,
		nodes = plotData.nodes,
		rebirths = plotData.rebirths,
		janitor = Janitor.new(),
		defenseJanitor = Janitor.new(),
		nodesUpdated = Signal.new(),
		isReplicated = plotData.player == Players.LocalPlayer,
	}, PlotClient) :: any

	self.defense = DefenseClient.new(plotData.index, plotData.player, plotData.towers, self.isReplicated)
	self.defense.currencyMult = plotData.currencyMult
	self.defense.damageMult = plotData.damageMult
	self.defense.bestDps = plotData.bestDps
	self.defense:pathsUpdated(plotData.paths)
	self.networker = Networker.client.new("Plot" .. plotData.index, self :: any)
	self.conveyor =
		ConveyorClient.new(self.index, self.plotModel, plotData.conveyorModel, self.player, plotData.conveyorLevel)
	self:loadDefense(plotData.nodes)

	self.plotModel.StarterPack.StarterPackRoot.BillboardGui.Cost.Text =
		MonetizationServiceClient:getProductInfo(Products.starterPack).CostText
	self.janitor:Add(MonetizationServiceClient:getProductInfoChangedSignal(Products.starterPack):Connect(function()
		local info = MonetizationServiceClient:getProductInfo(Products.starterPack)
		self.plotModel.StarterPack.StarterPackRoot.BillboardGui.Cost.Text = info.CostText
	end))

	self.janitor:Add(TouchPad.new(self.plotModel.StarterPack.Hitbox, function()
		if not MonetizationServiceClient:ownsGamepass(Products.starterPack :: any) then
			MonetizationServiceClient:promptProduct(Products.starterPack :: any)
		end
	end))

	self.plotModel.LikeReward.LikeRewardRoot.BillboardGui.Cost.Visible = DataService:get("groupLootClaimed")
	self.janitor:Add(DataService:getChangedSignal("groupLootClaimed"):Connect(function()
		self.plotModel.LikeReward.LikeRewardRoot.BillboardGui.Cost.Visible = DataService:get("groupLootClaimed")
	end))

	self.janitor:Add(TouchPad.new(self.plotModel.LikeReward.Hitbox, function()
		if not DataService:get("groupLootClaimed") then
			Menu.setOpenedMenu("LikeMenu")
		end
	end))

	return self
end

function PlotClient.attemptBuild(self: PlotClient, floor: number, node: number)
	local equippedItemUniqueId = InventorySlice.state.equippedItemUniqueId()
	if not equippedItemUniqueId then
		return
	end

	self.networker:fire("requestBuild", floor, node, equippedItemUniqueId)
	local data = DataService:get({ "inventory", equippedItemUniqueId }) :: DataTemplate.ItemData
	if not data or data.itemId or (data.crateId and data.amt <= 0) then
		InventoryServiceClient:unequipItem()
	end

	TutorialServiceClient:nextStep("placeCrate")
end

function PlotClient.loadDefense(self: PlotClient, nodes: { { ClientNode } }?)
	self.defenseJanitor:Cleanup()
	if nodes then
		self:setNodes(nodes)
	end

	if self.player ~= Players.LocalPlayer then
		return
	end

	for floor, floorNodes in self.nodes do
		for nodeIndex, node in floorNodes do
			self:_initProxForNode(node, floor, nodeIndex)
		end
	end
end

function PlotClient.setNodes(self: PlotClient, nodes: { { Node } })
	for floorIndex, floor in nodes do
		for nodeIndex, node in floor do
			self:setNode(floorIndex, nodeIndex, node)
		end
	end
end

function PlotClient.setNode(self: PlotClient, floor: number, node: number, nodeData: Node, fromCrate: boolean?)
	if not self.nodes[floor] then
		self.nodes[floor] = {}
	end

	local current = self.nodes[floor][node]
	if current and current.model then
		PlotSlice.actions.removeCrate(current.root)
		current.model:Destroy()
	end

	local clientNode: ClientNode = nodeData :: any
	if nodeData.data and nodeData.data.crateId then
		local crateModel = InventoryServiceUtils.getModel(nodeData.data :: any)
		crateModel:PivotTo(nodeData.cf * CFrame.new(0, 1, 0))
		crateModel.Parent = self.plotModel
		clientNode.model = crateModel
		PlotSlice.actions.addCrate(nodeData.root, nodeData.data)
	end

	if fromCrate and self.isReplicated then
		clientNode.crateOpening = true
	end

	self.nodes[floor][node] = clientNode
	self.nodesUpdated:Fire(floor, node)
end

function PlotClient.crateOpened(self: PlotClient, floor: number, node: number, towerData: TowerData, towerCf: CFrame)
	local nodeData = self.nodes[floor][node]
	local crateModel = nodeData.model
	PlotSlice.actions.removeCrate(nodeData.root)
	local crateInfo = Towers.getTowerInfo(nodeData.data.crateId)
	local isLuckyBlock = crateInfo.isLuckyBlock
	nodeData.data = nil
	nodeData.model = nil :: any
	nodeData.crateOpening = true
	self.nodesUpdated:Fire(floor, node)
	local rebirths = self.rebirths

	if self.isReplicated then
		if isLuckyBlock then
			LuckyBlockOpenVfx(
				nodeData.cf,
				crateModel,
				towerData,
				crateInfo.luck * ConveyorUpgrades[self.conveyor.level()].luck
			)
		else
			CrateOpenVfx(nodeData.cf, crateModel, towerData)
		end
	else
		crateModel:Destroy()
	end

	self.nodes[floor][node].crateOpening = false
	if self.rebirths ~= rebirths then
		return
	end

	self.nodesUpdated:Fire(floor, node)

	self.defense:towerAdded(floor, node, towerCf, towerData)
end

function PlotClient._initProxForNode(self: PlotClient, node: ClientNode, floor: number, nodeIndex: number)
	local root = node.root
	local attach = Instance.new("Attachment")
	attach.CFrame = CFrame.new(0, 4, 0)
	attach.Parent = root
	local prox = Instance.new("ProximityPrompt")
	prox.RequiresLineOfSight = false
	prox.MaxActivationDistance = 10
	prox.HoldDuration = 0.5
	prox.Parent = attach

	local upgradePart = Instance.new("Part")
	upgradePart.Size = Vector3.new(6, 3, 0.001)
	upgradePart.Transparency = 1
	upgradePart.Anchored = true
	upgradePart.CanCollide = false
	upgradePart.Name = "UpgradePart"
	upgradePart.CFrame = root.CFrame * CFrame.new(0, 1.33, -5.5) * CFrame.Angles(math.rad(25), 0, 0)
	upgradePart.Parent = root.Parent

	local upgradeSurfaceGui, guiCleanup = TowerUpgradeSurfaceGui.new()
	upgradeSurfaceGui.AlwaysOnTop = true
	upgradeSurfaceGui.MaxDistance = 60
	upgradeSurfaceGui.Adornee = upgradePart
	upgradeSurfaceGui.Button.Activated:Connect(function()
		self.networker:fire("requestUpgrade", floor, nodeIndex)
		TutorialServiceClient:nextStep("upgradeTower")
	end)

	local function update(f: number?, n: number?)
		local data = self.nodes[floor][nodeIndex].data
		if f == floor and n == nodeIndex then
			TowerUpgradeSurfaceGui.update(upgradeSurfaceGui, data)
			--[[if data then
				local upgradeData = table.clone(data) :: any
				upgradeData.floor = floor
				upgradeData.node = nodeIndex
				print("setting upgrade data")
				task.wait()
				PlotSlice.actions.setTowerUpgrade(upgradePart, upgradeData)
			else
				print("setting to nil")
				PlotSlice.actions.setTowerUpgrade(upgradePart, nil)
			end]]

			if data and data.itemId then
				local scale = 1.25 * (PlotServiceUtils.getScaleFromLevel(data.level) - 0.75)
				upgradePart.CFrame = root.CFrame * CFrame.new(0, 1.33, -5.5 - scale) * CFrame.Angles(math.rad(25), 0, 0)
			end
		end

		local tutCompleted = TutorialServiceClient:hasCompletedTutorial()
		local shouldBeEnabled = not self.nodes[floor][nodeIndex].crateOpening
		if not shouldBeEnabled then
			upgradeSurfaceGui.Enabled = false
		end
		prox.Enabled = shouldBeEnabled
		if not tutCompleted and nodeIndex ~= 4 then
			prox.Enabled = false
		end

		if data and data.crateId and (tutCompleted or TutorialServiceClient:getStep() == "openCrate") then
			prox.ActionText = "Open"
		elseif data and not data.crateId and tutCompleted then
			prox.ActionText = "Remove"
		elseif InventorySlice.state.equippedItemUniqueId() ~= nil then
			prox.ActionText = "Place"
		else
			prox.Enabled = false
		end
	end

	prox.Triggered:Connect(function()
		if prox.ActionText == "Open" then
			self.networker:fire("requestOpenCrate", floor, nodeIndex)
			TutorialServiceClient:nextStep("openCrate")
		elseif prox.ActionText == "Remove" then
			self.networker:fire("requestRemove", floor, nodeIndex)
		elseif prox.ActionText == "Place" then
			self:attemptBuild(floor, nodeIndex)
		end
	end)

	update(floor, nodeIndex)
	self.defenseJanitor:Add(attach)
	self.defenseJanitor:Add(prox)
	self.defenseJanitor:Add(self.nodesUpdated:Connect(update))
	self.defenseJanitor:Add(DataService:getChangedSignal({ "tutorial" }):Connect(update))
	self.defenseJanitor:Add(Charm.subscribe(InventorySlice.state.equippedItemUniqueId, update))
	self.defenseJanitor:Add(function()
		PlotSlice.actions.setTowerUpgrade(upgradePart, nil)
		upgradePart:Destroy()
	end)
	self.defenseJanitor:Add(guiCleanup)

	if
		self.player == Players.LocalPlayer
		and not TutorialServiceClient:hasCompletedTutorial()
		and nodeIndex == 4
		and floor == 1
	then
		root:AddTag("TutorialNode")
		upgradePart:AddTag("TutorialUpgrader")
	end
end

function PlotClient.setReplication(self: PlotClient, isReplicated: boolean)
	if self.isReplicated == isReplicated then
		return
	end

	self.networker:fire("setReplication", isReplicated)
	self.defense.isReplicated = isReplicated
	self.isReplicated = isReplicated

	if isReplicated then
		self.defense:start()
		return
	end

	self.defense:stop()

	--clear enemies
	for _, enemy in self.defense.enemies do
		enemy:destroy()
	end
	self.defense.enemies = {}

	--clear conveyor
	for _, crate in self.conveyor.crates do
		crate:destroy()
	end
	for _, recoverable in self.conveyor.recoverableCrates do
		recoverable.Model:Destroy()
	end
	self.conveyor.crates = {}
	self.conveyor.recoverableCrates = {}
end

function PlotClient.destroy(self: PlotClient)
	self.networker:destroy()
	self.janitor:Destroy()
	self.plotModel:Destroy()
	self.defense:destroy()
	self.defenseJanitor:Destroy()
	self.conveyor:destroy()
end

return PlotClient
