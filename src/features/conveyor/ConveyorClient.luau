local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Networker = require(ReplicatedStorage.Packages.Networker)
local Ripple = require(ReplicatedStorage.Packages.Ripple)
local SoundController = require(ReplicatedStorage.Source.Core.Platform.SoundController)
local Abbreviate = require(ReplicatedStorage.Source.Core.UI.Abbreviate)
local TouchPad = require(ReplicatedStorage.Source.Features.Conveyor.Modules.TouchPad)
local CrateClient = require(ReplicatedStorage.Source.Features.Crates.Classes.CrateClient)
local CrateBillboardGui = require(ReplicatedStorage.Source.Features.Crates.UI.Screens.CrateBillboardGui)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local MonetizationServiceClient = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceClient)
local PlotServiceUtils = require(ReplicatedStorage.Source.Features.Plots.PlotServiceUtils)
local TutorialServiceClient = require(ReplicatedStorage.Source.Features.Tutorial.TutorialServiceClient)
local Sounds = require(ReplicatedStorage.Source.Game.Assets.Sounds)
local ConveyorUpgrades = require(ReplicatedStorage.Source.Game.Items.ConveyorUpgrades)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

local DEFAULT_TEXTURE_SPEED = 3.6
local TEXTURE_TIME = 1.1
local CRATE_SPAWN_CD = PlotServiceUtils.enums.crateSpawnCooldown

local ConveyorClient = {}
ConveyorClient.__index = ConveyorClient

type Crate = CrateClient.Crate
type CrateData = DataTemplate.CrateData
type RecoverableCrate = {
	crateData: CrateData,
	index: number,
	Model: Model,
}

export type ConveyorClient = typeof(setmetatable(
	{} :: {
		level: Charm.Atom<number>,
		player: Player,
		crates: { Crate },
		recoverableCrates: { RecoverableCrate },
		plotModel: Model & any,
		crateSpawnCf: CFrame,
		model: (Model & any)?,
		janitor: Janitor.Janitor,
		modelJanitor: Janitor.Janitor,
		buttonSpring: Ripple.Spring<number>,
		conveyorSpeed: Charm.Atom<number>,
		timeOfLastCrateSpawn: number,
		networker: Networker.Client,
		speedMultiplier: number,
		speedThread: thread?,
	},
	ConveyorClient
))

function ConveyorClient.new(
	index: number,
	plotModel: Model & any,
	conveyorModel: (Model & any)?,
	player: Player,
	level: number
): ConveyorClient
	local self = setmetatable({
		level = Charm.atom(level),
		player = player,
		crateSpawnCf = plotModel.CrateStart.CFrame,
		crates = {},
		recoverableCrates = {},
		plotModel = plotModel,
		model = conveyorModel,
		janitor = Janitor.new(),
		modelJanitor = Janitor.new(),
		buttonSpring = Ripple.createSpring(0, { start = true, damping = 0.5, frequency = 6 }),
		conveyorSpeed = Charm.atom(0),
		timeOfLastCrateSpawn = 0,
		speedMultiplier = 1,
	}, ConveyorClient)

	self.networker = Networker.client.new("Conveyor" .. index, self :: any)
	if conveyorModel then
		self:setModel(conveyorModel)
	end

	self:initPads()
	if player == Players.LocalPlayer then
		self:initSpawnButton()
	end

	return self
end

function ConveyorClient.setLevel(self: ConveyorClient, level: number)
	self.level(level)
end

function ConveyorClient.crateBought(self: ConveyorClient, index: number)
	local crate = self.crates[index]
	if crate then
		crate:destroy()
		self.crates[index] = nil
	end
end

function ConveyorClient.attemptCrateSpawn(self: ConveyorClient)
	if os.clock() - self.timeOfLastCrateSpawn < CRATE_SPAWN_CD then
		return
	end

	if not TutorialServiceClient:hasCompletedTutorial() and TutorialServiceClient:getStep() ~= "clickConveyorSpawn" then
		return
	end

	SoundController:Play(Sounds.ui.click)
	self.timeOfLastCrateSpawn = os.clock()
	self.networker:fire("spawnCrate")
	self.buttonSpring:setGoal(0.5)
	local disconnect
	disconnect = self.buttonSpring:onComplete(function()
		disconnect()
		self.buttonSpring:setGoal(0)
	end)

	TutorialServiceClient:nextStep("clickConveyorSpawn")
end

local function getRecoverableOffset(index: number, max: number)
	local PADDING = 3
	local MIDPOINT = (max - 1) * PADDING / 2
	local goalOffset = PADDING - (index - 1) * PADDING
	return MIDPOINT + goalOffset
end

function ConveyorClient.updateRecoverableCrates(self: ConveyorClient, recoverableCrates: { RecoverableCrate }): ()
	for _, recoverableCrate in self.recoverableCrates do
		recoverableCrate.Model:Destroy()
	end

	self.recoverableCrates = recoverableCrates
	local numCrates = #recoverableCrates
	for i, recoverableCrate in self.recoverableCrates do
		recoverableCrate.Model:ScaleTo(0.5)
		local cf = CFrame.new(getRecoverableOffset(i, numCrates) - 3, 3, -4.5)
		recoverableCrate.Model:PivotTo(self.plotModel.Pads.RecoverPad.Bottom.CFrame * cf)
		recoverableCrate.Model.Parent = workspace
	end
end

function ConveyorClient.cratesChanged(self: ConveyorClient, crateDatas: { CrateData })
	local recoverableCrates = {}
	for i, prevCrate in self.crates do
		prevCrate:despawn()

		local recoverableModel = Towers.getCrateModel(prevCrate.crateData.crateId)
		local gui = CrateBillboardGui.new(prevCrate.crateData)
		gui.Parent = recoverableModel.PrimaryPart

		recoverableCrates[i] = {
			crateData = prevCrate.crateData,
			index = prevCrate.index,
			Model = recoverableModel,
		}
	end
	self:updateRecoverableCrates(recoverableCrates)

	local isLocalPlayer = self.player == Players.LocalPlayer
	self.crates = {}
	self.conveyorSpeed(DEFAULT_TEXTURE_SPEED * self.speedMultiplier)

	for i, crateData in crateDatas do
		local crate = CrateClient.new(
			self.networker,
			self.crateSpawnCf,
			i,
			#crateDatas,
			crateData,
			self.speedMultiplier,
			isLocalPlayer
		)

		self.crates[i] = crate
	end

	if self.speedThread then
		task.cancel(self.speedThread)
	end

	self.speedThread = task.delay(TEXTURE_TIME / self.speedMultiplier, function()
		self.conveyorSpeed(0)
		self.speedThread = nil
	end)

	if isLocalPlayer and not TutorialServiceClient:hasCompletedTutorial() then
		self.crates[1].model:AddTag("TutorialCrate")
	end
end

function ConveyorClient.initPads(self: ConveyorClient)
	local upgradePad = self.plotModel.Pads.ConveyorUpgradePad
	local textLabel = upgradePad:FindFirstChild("Cost", true) :: TextLabel

	local function updateText()
		local level = self.level()
		local upgradeInfo = ConveyorUpgrades[level + 1]
		if not upgradeInfo then
			textLabel.Text = "MAXED"
		else
			textLabel.Text = Abbreviate(upgradeInfo.cost)
		end
	end

	updateText()
	self.janitor:Add(Charm.subscribe(self.level, updateText))

	if self.player ~= Players.LocalPlayer then
		return
	end

	self.janitor:Add(TouchPad.new(upgradePad.Button, function()
		self.networker:fire("requestUpgrade")
	end))

	self.plotModel.Pads.RecoverPad.Bottom.BillboardGui.Cost.Text =
		MonetizationServiceClient:getProductInfo(Products.recoverCrate).CostText
	self.janitor:Add(MonetizationServiceClient:getProductInfoChangedSignal(Products.recoverCrate):Connect(function()
		local info = MonetizationServiceClient:getProductInfo(Products.recoverCrate)
		self.plotModel.Pads.RecoverPad.Bottom.BillboardGui.Cost.Text = info.CostText
	end))

	self.janitor:Add(TouchPad.new(self.plotModel.Pads.RecoverPad.Button, function()
		if #self.recoverableCrates > 0 then
			MonetizationServiceClient:promptProduct(Products.recoverCrate :: any)
		end
	end))
end

function ConveyorClient.initSpawnButton(self: ConveyorClient)
	local button = self.plotModel:FindFirstChild("SpawnerButton", true) :: BasePart
	button:AddTag("ConveyorSpawner")
	local originalCFrame = button.CFrame

	self.buttonSpring:onChange(function(v: number)
		button.CFrame = originalCFrame * CFrame.new(0, 0, -math.min(v, 0.5))
	end)

	local clicker = Instance.new("ClickDetector")
	clicker.Parent = button
	clicker.MouseClick:Connect(function()
		self:attemptCrateSpawn()
	end)

	self.janitor:Add(clicker)
end

function ConveyorClient.setModel(self: ConveyorClient, model: Model & any)
	self.modelJanitor:Cleanup()
	self.model = model

	local conveyorBeam = model:FindFirstChild("ConveyorBeam", true) :: Beam
	conveyorBeam.TextureSpeed = self.conveyorSpeed()
	self.modelJanitor:Add(Charm.subscribe(self.conveyorSpeed, function(speed: number)
		conveyorBeam.TextureSpeed = speed
	end))
end

function ConveyorClient.destroy(self: ConveyorClient)
	self.janitor:Destroy()
	self.modelJanitor:Destroy()
	self.networker:destroy()
	if self.speedThread then
		task.cancel(self.speedThread)
	end
	for _, crate in self.crates do
		crate:destroy()
	end
	for _, recoverable in self.recoverableCrates do
		recoverable.Model:Destroy()
	end
end

return ConveyorClient
