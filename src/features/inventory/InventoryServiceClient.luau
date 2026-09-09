local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local InventoryServiceUtils = require(script.Parent.InventoryServiceUtils)
local InventorySlice = require(script.Parent.InventorySlice)
local Networker = require(ReplicatedStorage.Packages.Networker)
local Sift = require(ReplicatedStorage.Packages.Sift)
local CrateBillboardGui = require(ReplicatedStorage.Source.Features.Crates.UI.Screens.CrateBillboardGui)
local TowerBillboardGui = require(ReplicatedStorage.Source.Features.Defense.UI.Screens.TowerBillboardGui)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local MonetizationServiceClient = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceClient)
local PlotServiceUtils = require(ReplicatedStorage.Source.Features.Plots.PlotServiceUtils)
local PlotSlice = require(ReplicatedStorage.Source.Features.Plots.PlotSlice)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

local RENDER_TOOL_DISTANCE = 100
local UPDATE_INTERVAL = 1
local HOLD_ANIMATION = ReplicatedStorage.Assets.Animations.HoldItem :: Animation

local NUMBER_KEYCODES = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6,
	[Enum.KeyCode.Seven] = 7,
	[Enum.KeyCode.Eight] = 8,
	[Enum.KeyCode.Nine] = 9,
}

local InventoryServiceClient = {}

function InventoryServiceClient.init(self: InventoryServiceClient)
	self.equippedItems = {}
	self.networker = Networker.client.new("InventoryService", self)
	self.holdTrack = nil

	task.spawn(function()
		local function updateAnim(char)
			if self.holdTrack then
				self.holdTrack:Destroy()
			end
			local humanoid = char:WaitForChild("Humanoid") :: Humanoid
			local animationTrack = humanoid.Animator:LoadAnimation(HOLD_ANIMATION) :: AnimationTrack
			self.holdTrack = animationTrack

			if self:hasItemEquipped() then
				animationTrack:Play()
			end
		end

		local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
		updateAnim(char)

		Players.LocalPlayer.CharacterAdded:Connect(updateAnim)
	end)

	task.spawn(function()
		while true do
			task.wait(UPDATE_INTERVAL)
			self:update()
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		local num = NUMBER_KEYCODES[input.KeyCode]
		if num then
			local uniqueId = DataService:get({ "hotbar", num })
			if not uniqueId or uniqueId == "NULL" then
				return
			end

			local equippedUniqueId = InventorySlice.state.equippedItemUniqueId()
			if uniqueId ~= equippedUniqueId then
				self:equipItem(uniqueId)
			else
				self:unequipItem()
			end
		end

		if input.KeyCode == Enum.KeyCode.Backquote or input.KeyCode == Enum.KeyCode.G then
			InventorySlice.actions.toggleBackpack()
		end
	end)

	local function isUniqueIdBuilt(uniqueId: string): boolean
		for _, uId in DataService:get("plotNodes") do
			if uniqueId == uId then
				return true
			end
		end
		return false
	end

	DataService:getChangedSignal("plotNodes"):Connect(function()
		for index, uniqueId in DataService:get("hotbar") do
			local data = DataService:get({ "inventory", uniqueId })
			if not data or (data.amt and data.amt <= 0) then
				self.networker:fire("setHotBarUniqueId", index, nil)
				DataService:set({ "hotbar", index }, "NULL")
				if InventorySlice.state.equippedItemUniqueId() == uniqueId then
					self:unequipItem()
				end
				continue
			end

			if not isUniqueIdBuilt(uniqueId) then
				continue
			end

			self.networker:fire("setHotBarUniqueId", index, nil)
			DataService:set({ "hotbar", index }, "NULL")
			if InventorySlice.state.equippedItemUniqueId() == uniqueId then
				self:unequipItem()
			end
		end
	end)
end

function InventoryServiceClient.sell(self: InventoryServiceClient, uniqueIdsDict: { [string]: boolean })
	local equippedUniqueId = InventorySlice.state.equippedItemUniqueId()
	local uniqueIds = Sift.Dictionary.keys(uniqueIdsDict)
	if uniqueIdsDict[equippedUniqueId] then
		self:unequipItem()
	end
	self.networker:fire("sell", uniqueIds)
end

function InventoryServiceClient.addToHotbar(self: InventoryServiceClient, uniqueId: string)
	for _, slotUniqueId in DataService:get("hotbar") do
		if slotUniqueId == uniqueId then
			if not self:hasItemEquipped() then
				self:equipItem(uniqueId)
			end
			return
		end
	end

	for index, slotUniqueId in DataService:get("hotbar") do
		if slotUniqueId == "NULL" then
			DataService:set({ "hotbar", index }, uniqueId)
			self.networker:fire("setHotBarUniqueId", index, uniqueId)
			if not self:hasItemEquipped() then
				self:equipItem(uniqueId)
			end
			return
		end
	end
end

function InventoryServiceClient.hasItemEquipped(self: InventoryServiceClient): boolean
	local equippedItem = self.equippedItems[Players.LocalPlayer]
	return equippedItem and equippedItem.itemData ~= nil
end

function InventoryServiceClient.setPlayerItem(
	self: InventoryServiceClient,
	player: Player,
	itemData: DataTemplate.ItemData?
)
	local equippedItem = self.equippedItems[player]
	if not equippedItem then
		self.equippedItems[player] = { itemData = itemData, model = nil }
		return
	end

	if itemData and equippedItem.itemData and Sift.Dictionary.equalsDeep(itemData, equippedItem.itemData) then
		return
	end

	if equippedItem.model then
		equippedItem.model:Destroy()
	end

	self.equippedItems[player] = { itemData = itemData, model = nil }
end

function InventoryServiceClient.equipItem(self: InventoryServiceClient, uniqueId: string)
	local itemData = DataService:get({ "inventory", uniqueId })
	self:setPlayerItem(Players.LocalPlayer, itemData)
	InventorySlice.state.equippedItemUniqueId(uniqueId)
	self.networker:fire("equipItem", uniqueId)
	if self.holdTrack then
		self.holdTrack:Play()
	end
	self:update()
end

function InventoryServiceClient.unequipItem(self: InventoryServiceClient)
	self:setPlayerItem(Players.LocalPlayer, nil)
	self.networker:fire("unequipItem")
	InventorySlice.state.equippedItemUniqueId(nil)
	if self.holdTrack then
		self.holdTrack:Stop()
	end
end

function InventoryServiceClient.dragItem(self: InventoryServiceClient, uniqueId: string)
	local hotbarIndex = table.find(DataService:get("hotbar"), uniqueId)
	if hotbarIndex then
		self.networker:fire("setHotBarUniqueId", hotbarIndex, nil)
		DataService:set({ "hotbar", hotbarIndex }, "NULL")
		InventorySlice.state.originalSlot(hotbarIndex)
	end
	InventorySlice.state.backpackOpen(true)
	InventorySlice.state.draggingItemUniqueId(uniqueId)
end

function InventoryServiceClient.faveItem(self: InventoryServiceClient, uniqueId: string)
	if not DataService:get({ "inventory", uniqueId }) then
		return
	end

	local itemData = DataService:update({ "inventory", uniqueId }, function(data: DataTemplate.ItemData)
		return Sift.Dictionary.set(data, "fav", not data.fav)
	end)

	self.networker:fire("setItemFav", uniqueId, itemData.fav)
end

function InventoryServiceClient.moveItem(self: InventoryServiceClient, uniqueId: string, targetSlot: number?)
	if not targetSlot then
		return
	end

	local currentUniqueId = DataService:get({ "hotbar", targetSlot })
	local originalSlot = InventorySlice.state.originalSlot()
	if originalSlot and currentUniqueId then -- swap items
		DataService:set({ "hotbar", originalSlot }, currentUniqueId)
		self.networker:fire("setHotBarUniqueId", originalSlot, currentUniqueId)
		InventorySlice.state.originalSlot(nil)
	end
	DataService:set({ "hotbar", targetSlot }, uniqueId)
	self.networker:fire("setHotBarUniqueId", targetSlot, uniqueId)
end

local FLOOR_HEIGHT = 22
local CHAR_HEIGHT = 4
function InventoryServiceClient.update(self: InventoryServiceClient)
	local char = Players.LocalPlayer.Character
	if not char then
		return
	end

	local pos = char:GetPivot().Position
	local floor = math.max(1, 1 + (pos.Y - CHAR_HEIGHT) // FLOOR_HEIGHT)
	PlotSlice.states.characterFloor(floor)

	for player, equippedItem in self.equippedItems do
		if not equippedItem.itemData or equippedItem.model then
			continue
		end

		local pChar = player.Character
		if not pChar then
			continue
		end

		local dist = (pos - pChar:GetPivot().Position).Magnitude
		if dist > RENDER_TOOL_DISTANCE then
			continue
		end

		local model, rootWeld = InventoryServiceUtils.getToolModel(equippedItem.itemData)
		equippedItem.model = model
		model:PivotTo(pChar.Head.CFrame * CFrame.new(0, 1.33, 0))
		rootWeld.Part1 = pChar.Head
		model.Parent = pChar
		if equippedItem.itemData.itemId then
			model:ScaleTo(PlotServiceUtils.getScaleFromLevel(equippedItem.itemData.level))
			local dmgMult = if MonetizationServiceClient:ownsGamepass(Products.doubleDamage :: any) then 2 else 1
			local gui = TowerBillboardGui.new(equippedItem.itemData, dmgMult)
			gui.Parent = model.PrimaryPart
		else
			local crateGui = CrateBillboardGui.new(equippedItem.itemData, true)
			crateGui.Parent = model.PrimaryPart
		end
	end
end

type InventoryServiceClient = typeof(InventoryServiceClient) & {
	networker: Networker.Client,
	holdTrack: AnimationTrack?,
	equippedItems: { [Player]: {
		itemData: DataTemplate.ItemData?,
		model: Model & any,
	} },
}

return InventoryServiceClient :: InventoryServiceClient
