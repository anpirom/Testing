local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Abbreviate = require(ReplicatedStorage.Source.Core.UI.Abbreviate)
local Enemies = require(ReplicatedStorage.Source.Features.Defense.Modules.Enemies)
local HitSplat = require(ReplicatedStorage.Source.Features.Defense.Modules.HitSplat)
local PathUtils = require(ReplicatedStorage.Source.Features.Defense.Modules.PathUtils)
local FriendServiceClient = require(ReplicatedStorage.Source.Features.Friends.FriendServiceClient)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local MonetizationServiceClient = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceClient)

local MODEL_OFFSET = CFrame.new(0, 0.125, 0) * CFrame.Angles(0, math.rad(-90), 0)
local ANIMATION_SPEED = 5.5

local EnemyClient = {}
EnemyClient.__index = EnemyClient

export type EnemyClient = typeof(setmetatable(
	{} :: {
		dist: number,
		uniqueId: number,
		cf: CFrame,
		health: number,
		info: Enemies.EnemyInfo,
		maxHealth: number,
		speed: number,
		model: Model & any,
		scale: number,
		dead: boolean,
		reachedEnd: boolean,
		path: PathUtils.Path,
		hpBar: BillboardGui & any,
		destroyed: Signal.Signal<>,
		baseStats: Enemies.EnemyStats,
		track: AnimationTrack,
		floor: number,
		burnVfx: ParticleEmitter?,
		poisonVfx: ParticleEmitter?,
		rewardMult: number,
	},
	EnemyClient
))

function EnemyClient.new(
	floor: number,
	enemyStats: Enemies.EnemyStats,
	uniqueId: number,
	path: PathUtils.Path,
	rewardMult: number
): EnemyClient
	local self = setmetatable({
		floor = floor,
		dist = 0,
		path = path,
		baseStats = enemyStats,
		uniqueId = uniqueId,
		cf = PathUtils.getCFrameFromDist(path, 0),
		health = enemyStats.health,
		speed = enemyStats.speed,
		scale = enemyStats.size,
		dead = false,
		maxHealth = enemyStats.health,
		reachedEnd = false,
		destroyed = Signal.new(),
		rewardMult = rewardMult,
	}, EnemyClient)

	local index = enemyStats.x
	local info = Enemies.getEnemyInfo(index)
	self.info = info
	local model = Enemies.getEnemyModel(index, enemyStats.type)
	model.Name = "Enemy_" .. uniqueId
	model:PivotTo(self.cf * MODEL_OFFSET)
	model.Parent = workspace
	local track: AnimationTrack = model.AnimationController:LoadAnimation(info.animation)
	self.track = track
	track.Looped = true
	track:Play(nil, nil, enemyStats.speed / ANIMATION_SPEED)
	self.model = model
	self.hpBar = model.EnemyHealthBillboard
	self:updateHpBar()

	return self
end

local GREEN = Color3.fromRGB(98, 255, 0)
local RED = Color3.fromRGB(255, 47, 10)

local function percentToGradient(percent: number): ColorSequence
	if percent >= 0.995 then
		return ColorSequence.new(GREEN)
	elseif percent <= 0.005 then
		return ColorSequence.new(RED)
	end

	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, GREEN),
		ColorSequenceKeypoint.new(percent - 0.001, GREEN),
		ColorSequenceKeypoint.new(percent + 0.001, RED),
		ColorSequenceKeypoint.new(1, RED),
	})
end

function EnemyClient.updateSpeed(self: EnemyClient, newSpeed: number): ()
	self.speed = newSpeed
	self.track:AdjustSpeed(self.speed / ANIMATION_SPEED)
end

function EnemyClient.updateHpBar(self: EnemyClient): ()
	local healthPercent = math.clamp(self.health / self.maxHealth, 0, 1)
	local hpText = Abbreviate(self.health) .. " / " .. Abbreviate(self.maxHealth)
	self.hpBar.Frame.Health.Text = hpText
	self.hpBar.Frame.Bar.UIGradient.Color = percentToGradient(healthPercent)
end

function EnemyClient.damage(self: EnemyClient, amt: number): ()
	self.health -= amt
	if self.health <= 0 then
		self.dead = true
		local color = self.info.color
		local ownsStarterPack = MonetizationServiceClient:ownsGamepass(Products.starterPack :: any)
		local reward = Enemies.getEnemyReward(
			self.maxHealth,
			DataService.client:get("rebirths"),
			ownsStarterPack,
			FriendServiceClient.friendCount()
		) * self.rewardMult
		HitSplat(self:getPosition(), color, reward)
	else
		self:updateHpBar()
	end
end

function EnemyClient.update(self: EnemyClient, dt: number): ()
	self.dist += dt * self.speed
	self.cf = PathUtils.getCFrameFromDist(self.path, self.dist)

	if self.model then
		self.model:PivotTo(self.cf * MODEL_OFFSET)
	end

	if self.dist >= self.path.length then
		self.reachedEnd = true
	end
end

function EnemyClient.getPosition(self: EnemyClient): Vector3
	return self.cf.Position
end

function EnemyClient.burn(self: EnemyClient, damage: number): ()
	self:damage(damage)
	if self.dead then
		return
	end

	if not self.burnVfx then
		local burnVfx = ReplicatedStorage.Assets.VFX.EnemyBurn:Clone()
		burnVfx.Parent = self.model:FindFirstChild("RootAttachment", true)
		self.burnVfx = burnVfx
	end

	(self.burnVfx :: any):Emit(1)
end

function EnemyClient.poison(self: EnemyClient, damage: number): ()
	self:damage(damage)
	if self.dead then
		return
	end

	if not self.poisonVfx then
		local poisonVfx = ReplicatedStorage.Assets.VFX.EnemyPoison:Clone()
		poisonVfx.Parent = (self.model:FindFirstChild("RootAttachment", true) :: any).Parent
		poisonVfx.Enabled = true
		self.poisonVfx = poisonVfx
	end
end

function EnemyClient.destroy(self: EnemyClient): ()
	self.destroyed:Fire()
	if self.model then
		self.model:Destroy()
	end
	self.destroyed:Destroy()
end

return EnemyClient
