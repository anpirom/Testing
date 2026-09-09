local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Networker = require(ReplicatedStorage.Packages.Networker)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local PlotServiceUtils = require(ReplicatedStorage.Source.Features.Plots.PlotServiceUtils)
local EnemyServer = require(script.Parent.EnemyServer)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

local BURN_DAMAGE = 0.5
local POISON_DAMAGE = 0.1
local XZ = Vector3.new(1, 0, 1)
local MAX_HEIGHT_DIFF = 6

local TowerServer = {}
TowerServer.__index = TowerServer

type TowerData = DataTemplate.TowerData
type EnemyServer = EnemyServer.EnemyServer

export type TowerServer = typeof(setmetatable(
	{} :: {
		floor: number,
		node: number,
		data: TowerData,
		cf: CFrame,
		pos: Vector3,
		cd: number,
		towerInfo: Towers.TowerInfo,
		enemies: { EnemyServer },
		networker: Networker.Server,
		dps: number,
		firerate: number,
		dmg: number,
		damageMult: number,
		bestDps: number,
	},
	TowerServer
))

function TowerServer.new(floor: number, node: number, cf: CFrame, data: TowerData): TowerServer
	local self = setmetatable({
		floor = floor,
		node = node,
		data = data,
		cf = cf,
		pos = cf.Position,
		towerInfo = Towers.getTowerInfo(data.itemId),
		dmg = PlotServiceUtils.calcDamage(data),
		firerate = PlotServiceUtils.calcFirerate(data),
		damageMult = 1,
		enemies = nil :: any,
		networker = nil :: any,
		bestDps = nil :: any,
	}, TowerServer)

	self.cd = 1 / self.firerate
	self.dps = self.dmg * self.firerate

	return self
end

function TowerServer.attack(self: TowerServer, enemy: EnemyServer): ()
	local damage = if self.towerInfo.percentDamageOfBest and self.bestDps
		then (self.towerInfo.percentDamageOfBest * self.bestDps * self.damageMult) / self.firerate
		else PlotServiceUtils.calcDamage(self.data) * self.damageMult
	enemy:damage(damage)
	self.cd = 1 / self.firerate
	self.networker:fireRecipients("towerAttack", self.floor, self.node, enemy.uniqueId, damage)

	if self.data.mutations and self.data.mutations.inferno then
		enemy:addBurn(damage * BURN_DAMAGE)
	end
	if self.data.mutations and self.data.mutations.radioactive then
		enemy:addPoison(damage * POISON_DAMAGE)
	end
end

function TowerServer.update(self: TowerServer, dt: number): ()
	self.cd -= dt
	if self.cd > 0 then
		return
	end

	for _, enemy in self.enemies do
		local dist = ((enemy.pos - self.pos) * XZ).Magnitude
		local heightDiff = math.abs(enemy.pos.Y - self.pos.Y)
		if dist > self.towerInfo.range + enemy.radius or heightDiff > MAX_HEIGHT_DIFF then
			continue
		end

		self:attack(enemy)
		break
	end
end

return TowerServer
