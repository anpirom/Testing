local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enemies = require(ReplicatedStorage.Source.Features.Defense.Modules.Enemies)
local PathUtils = require(ReplicatedStorage.Source.Features.Defense.Modules.PathUtils)
local EnemyServer = {}
EnemyServer.__index = EnemyServer

local BURN_TICKS = 6
type EnemyStats = Enemies.EnemyStats

export type EnemyServer = typeof(setmetatable(
	{} :: {
		floor: number,
		dist: number,
		pos: Vector3,
		health: number,
		speed: number,
		maxHealth: number,
		dead: boolean,
		killed: boolean,
		path: any,
		uniqueId: number,
		baseStats: EnemyStats,
		radius: number,
		burnBuffer: { number },
		burnBufferIndex: number,
		poisonDamage: number,
	},
	EnemyServer
))

local uniqueIdCounter = 0
local function getUniqueId(): number
	uniqueIdCounter += 1
	return uniqueIdCounter
end

function EnemyServer.new(floor: number, enemyStats: EnemyStats): EnemyServer
	local self = setmetatable({
		floor = floor,
		baseStats = enemyStats,
		uniqueId = getUniqueId(),
		radius = enemyStats.size * 3,
		dist = 0,
		pos = Vector3.new(),
		dead = false,
		killed = false,
		health = enemyStats.health,
		maxHealth = enemyStats.health,
		poisonDamage = 0,
		speed = enemyStats.speed,
		burnBuffer = table.create(BURN_TICKS, 0),
		burnBufferIndex = 1,
	}, EnemyServer)

	return self
end

function EnemyServer.damage(self: EnemyServer, amt: number): number
	self.health -= amt
	if self.health <= 0 then
		self.dead = true
		self.killed = true
	end
	return amt
end

function EnemyServer.addPoison(self: EnemyServer, damage: number): ()
	if damage <= 0 then
		return
	end

	self.poisonDamage += damage
end

function EnemyServer.addBurn(self: EnemyServer, damage: number): ()
	if damage <= 0 then
		return
	end

	local burnDamage = math.ceil(damage / BURN_TICKS) -- deal damage over 6 ticks
	for i = 1, BURN_TICKS do
		self.burnBuffer[i] += burnDamage
	end
end

function EnemyServer.burn(self: EnemyServer): number?
	local damage = self.burnBuffer[self.burnBufferIndex]
	self.burnBuffer[self.burnBufferIndex] = 0
	self.burnBufferIndex = (self.burnBufferIndex % BURN_TICKS) + 1

	if damage == 0 then
		return nil
	end

	return self:damage(damage)
end

function EnemyServer.poison(self: EnemyServer): number?
	if self.poisonDamage == 0 then
		return nil
	end

	return self:damage(self.poisonDamage)
end

function EnemyServer.update(self: EnemyServer, dt: number): ()
	self.dist += self.speed * dt
	self.pos = PathUtils.getPosFromDist(self.path, self.dist)
end

return EnemyServer
