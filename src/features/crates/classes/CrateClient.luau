local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Networker = require(ReplicatedStorage.Packages.Networker)
local CrateSlice = require(ReplicatedStorage.Source.Features.Crates.CrateSlice)
local CrateBillboardGui = require(ReplicatedStorage.Source.Features.Crates.UI.Screens.CrateBillboardGui)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local RebirthUtils = require(ReplicatedStorage.Source.Features.Plots.Modules.RebirthUtils)
local TutorialServiceClient = require(ReplicatedStorage.Source.Features.Tutorial.TutorialServiceClient)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

type CrateData = DataTemplate.CrateData

local MIDPOINT = 24.75
local ENDPOINT = MIDPOINT * 2
local JUMP_POINT = ENDPOINT - 8
local PADDING = 8
local VELOCITY = 30

local function getStartPoint(index: number): number
	return (index - 1) * -PADDING
end

local function getGoal(index: number, cratesInBunch: number): number
	if cratesInBunch == 1 then
		return MIDPOINT
	elseif cratesInBunch == 2 then
		local goalOffset = if index == 1 then PADDING / 2 else -PADDING / 2
		return MIDPOINT + goalOffset
	elseif cratesInBunch == 3 then
		local goalOffset = PADDING - (index - 1) * PADDING
		return MIDPOINT + goalOffset
	end
	error("Invalid number of crates in bunch")
end

local Crate = {}
Crate.__index = Crate

export type Crate = typeof(setmetatable(
	{} :: {
		networker: Networker.Client,
		startCf: CFrame,
		index: number,
		crateData: CrateData,
		physicsEnabled: boolean,
		active: boolean,
		destroyed: boolean,
		speed: number,
		x: number,
		goalX: number,
		model: Model & any,
		velocity: Vector3,
		pos: Vector3,
		rot: Vector3,
		janitor: Janitor.Janitor,
		angularVelocity: Vector3,
		isLocalPlayer: boolean,
		updateConn: RBXScriptConnection,
		gui: BillboardGui,
	},
	Crate
))

function Crate.new(
	networker: Networker.Client,
	startCf: CFrame,
	index: number,
	cratesInBunch: number,
	crateData: CrateData,
	speed: number,
	isLocalPlayer: boolean
): Crate
	local self = setmetatable({
		networker = networker,
		startCf = startCf,
		crateData = crateData,
		index = index,
		active = false,
		destroyed = false,
		speed = speed,
		model = Towers.getCrateModel(crateData.crateId),
		x = getStartPoint(index),
		goalX = getGoal(index, cratesInBunch),
		physicsEnabled = false,
		velocity = Vector3.new(0, 0, 0),
		angularVelocity = Vector3.new(0, 0, 0),
		pos = Vector3.new(0, 0, 0),
		rot = Vector3.new(0, 0, 0),
		janitor = Janitor.new(),
		isLocalPlayer = isLocalPlayer,
	}, Crate)

	self.updateConn = RunService.Heartbeat:Connect(function(dt)
		self:update(dt)
	end)

	if self.isLocalPlayer then
		local highlight = Instance.new("Highlight")
		highlight.Parent = self.model
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillTransparency = 1
		highlight.OutlineColor = Color3.new(1, 1, 1)
		highlight.Enabled = false
		local prox = Instance.new("ProximityPrompt")
		prox.RequiresLineOfSight = false
		prox.MaxActivationDistance = 14
		prox.HoldDuration = 0.4
		prox.Parent = self.model.Main
		prox.ActionText = "Buy"

		prox.PromptShown:Connect(function()
			highlight.Enabled = true
		end)
		prox.PromptHidden:Connect(function()
			highlight.Enabled = false
		end)

		prox.Triggered:Connect(function()
			self:onBought()
		end)

		local rebirths: number = DataService:get("rebirths")
		local isMaxRebirths = RebirthUtils.isMaxedRebirths(rebirths)
		local reqId = if isMaxRebirths then "" else RebirthUtils.getRebirthTowerRequirement(rebirths)
		if crateData.crateId == reqId then
			local rebirthBillboard = ReplicatedStorage.Assets.VFX.RebirthCrateBillboard:Clone()
			rebirthBillboard.Parent = self.model.PrimaryPart
			self.janitor:Add(rebirthBillboard)
		end

		self.janitor:Add(prox)
		self.janitor:Add(highlight)
	end

	return self
end

function Crate.onBought(self: Crate)
	if not self.isLocalPlayer then
		return
	end

	self.networker:fire("buyCrate", self.index)
	TutorialServiceClient:nextStep("buyCrate")
end

function Crate.despawn(self: Crate)
	self.goalX = ENDPOINT
end

function Crate.update(self: Crate, dt: number)
	if self.destroyed then
		return
	end

	local maxDist = self.goalX - self.x
	if maxDist == 0 then
		return
	end

	dt *= self.speed
	local moveDist = math.clamp(VELOCITY * dt, -maxDist, maxDist)
	self.x += moveDist
	self.model:PivotTo(self.startCf * CFrame.new(self.x, 0, 0))

	if not self.active and self.x >= 0 then
		self.active = true
		self.model.Parent = workspace
		self.gui = CrateBillboardGui.new(self.crateData)
		self.gui.Parent = self.model.PrimaryPart
	end

	if not self.physicsEnabled and self.x >= JUMP_POINT then
		self.physicsEnabled = true
		self.velocity = Vector3.new(0, 35, 0)
		self.angularVelocity = Vector3.new(0, -4 * math.pi, 0)
	end

	if self.physicsEnabled then
		self.velocity += Vector3.new(0, -300 * dt, 0)
		self.rot += self.angularVelocity * dt
		self.pos += self.velocity * dt
		local cf = CFrame.new(self.pos) * CFrame.Angles(self.rot.X, self.rot.Y, self.rot.Z)
		self.model:PivotTo(self.model:GetPivot() * cf)
	end

	if self.x >= ENDPOINT then
		self:destroy()
	end
end

function Crate.destroy(self: Crate)
	CrateSlice.actions.removeCrate(self.model.Root)
	self.model:Destroy()
	self.destroyed = true
	self.updateConn:Disconnect()
	self.janitor:Destroy()
	if self.gui then
		self.gui:Destroy()
	end
end

return Crate
