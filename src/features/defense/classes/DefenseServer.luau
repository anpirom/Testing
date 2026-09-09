local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local FriendServiceServer = require(ServerScriptService.Features.Friends.FriendServiceServer)
local MonetizationServiceServer = require(ServerScriptService.Features.Monetization.MonetizationServiceServer)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local EnemyServer = require(script.Parent.EnemyServer)
local TowerServer = require(script.Parent.TowerServer)
local Networker = require(ReplicatedStorage.Packages.Networker)
local Enemies = require(ReplicatedStorage.Source.Features.Defense.Modules.Enemies)
local PathUtils = require(ReplicatedStorage.Source.Features.Defense.Modules.PathUtils)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local PlotServiceUtils = require(ReplicatedStorage.Source.Features.Plots.PlotServiceUtils)

type TowerServer = TowerServer.TowerServer
type EnemyServer = EnemyServer.EnemyServer
type Path = PathUtils.Path

local BURN_COOLDOWN = 0.2
local POISON_COOLDOWN = 1
local SPAWN_COOLDOWN = 3
local SORT_COOLDOWN = 1
local DefenseServer = {}
DefenseServer.__index = DefenseServer

export type DefenseServer = typeof(setmetatable(
	{} :: {
		paths: { Path },
		towers: { { [string]: TowerServer } },
		enemies: { { EnemyServer } },
		index: number,
		player: Player,
		bestDps: number,
		networker: Networker.Server,
		updateConn: RBXScriptConnection?,
		sortCooldown: number,
		burnCooldown: number,
		poisonCooldown: number,
		strength: { number },
		spawnCd: number,
		janitor: Janitor.Janitor,
		damageMult: number,
		currencyMult: number,
	},
	DefenseServer
))

function DefenseServer.new(index: number, player: Player): DefenseServer
	local self = setmetatable({
		towers = {},
		enemies = {},
		strength = {},
		paths = {},
		index = index,
		player = player,
		bestDps = 0,
		sortCooldown = SORT_COOLDOWN,
		burnCooldown = BURN_COOLDOWN,
		poisonCooldown = POISON_COOLDOWN,
		spawnCd = SPAWN_COOLDOWN,
		damageMult = if MonetizationServiceServer:ownsGamepass(player, Products.doubleDamage) then 2 else 1,
		currencyMult = if MonetizationServiceServer:ownsGamepass(player, Products.doubleMoney) then 2 else 1,
		janitor = Janitor.new(),
	}, DefenseServer) :: DefenseServer

	self.networker = Networker.server.new("Defense" .. index, self, {})
	self.networker:addRecipient(player)
	self:start()

	local doubleDmgChangedSignal = MonetizationServiceServer:getPassOwnshipChanged(player, Products.doubleDamage)
	local doubleMoneyChangedSignal = MonetizationServiceServer:getPassOwnshipChanged(player, Products.doubleMoney)

	self.networker:setRecipients("damageMult", self.damageMult)
	self.janitor:Add(doubleDmgChangedSignal:Connect(function(owns)
		self.damageMult = if owns then 2 else 1
		self.networker:setRecipients("damageMult", self.damageMult)
		for _, towers in self.towers do
			for _, tower in towers do
				tower.damageMult = self.damageMult
			end
		end
	end))

	self.networker:setRecipients("currencyMult", self.currencyMult)
	self.janitor:Add(doubleMoneyChangedSignal:Connect(function(owns)
		self.currencyMult = if owns then 2 else 1
		self.networker:setRecipients("currencyMult", self.currencyMult)
	end))

	return self
end

function DefenseServer.spawnEnemy(self: DefenseServer, floor: number)
	local strength = math.max(self.strength[floor] or 1, 1) * self.damageMult
	local enemyStats = Enemies.getEnemyForStrength(strength)
	local enemy = EnemyServer.new(floor, enemyStats)
	self:addEnemy(enemy)
end

function DefenseServer.strengthChanged(self: DefenseServer)
	local numFloors = #self.paths
	local strength: { number } = table.create(numFloors, 0)

	local totalPercentageOfBest = {}
	local bestDps = 0
	for floor, towers in self.towers do
		local totalPercentageOfBestOnThisFloor = 0
		for _, tower in towers do
			if tower.towerInfo.percentDamageOfBest then
				totalPercentageOfBestOnThisFloor += tower.towerInfo.percentDamageOfBest
				continue
			end

			local dps = PlotServiceUtils.getDps(tower.data)
			tower.dps = dps
			strength[floor] += dps

			if dps > bestDps then
				bestDps = dps
			end
		end
		totalPercentageOfBest[floor] = totalPercentageOfBestOnThisFloor
	end

	for floor, towers in self.towers do
		local percentageOfBestOnThisFloor = totalPercentageOfBest[floor]
		strength[floor] += percentageOfBestOnThisFloor * bestDps
		for _, tower in towers do
			tower.bestDps = bestDps
		end
	end

	self.bestDps = bestDps
	self.strength = strength
	self.networker:fireRecipients("bestDpsUpdated", bestDps)
end

function DefenseServer.updatePaths(self: DefenseServer, defenseModel: Model & any)
	local paths = PathUtils.calcPaths(defenseModel)
	self.paths = paths

	for floor, enemies in self.enemies do
		for _, enemy in enemies do
			enemy.path = paths[floor]
		end
	end

	self.networker:fireRecipients("pathsUpdated", paths)
end

function DefenseServer.start(self: DefenseServer)
	if self.updateConn then
		return
	end

	self.updateConn = RunService.Heartbeat:Connect(function(dt)
		self:update(dt)
	end)
end

function DefenseServer.stop(self: DefenseServer)
	if self.updateConn then
		self.updateConn:Disconnect()
		self.updateConn = nil
	end
end

function DefenseServer.removeAll(self: DefenseServer)
	for _, towers in self.towers do
		for uniqueId, _ in towers do
			self:removeTower(uniqueId)
		end
	end
end

function DefenseServer.removeTower(self: DefenseServer, uniqueId: string)
	local floor: number
	for f, towers in self.towers do
		if towers[uniqueId] then
			floor = f
			break
		end
	end

	if not floor then
		return
	end

	local tower = self.towers[floor][uniqueId]
	if not tower then
		warn("Attempted to remove non-existent tower: " .. uniqueId)
		return
	end
	self.towers[floor][uniqueId] = nil
	self.networker:fireAll("towerRemoved", floor, tower.node)
	self:strengthChanged()
end

function DefenseServer.getTowers(self: DefenseServer)
	local towers = {}
	for _, floorTowers in self.towers do
		for _, tower in floorTowers do
			table.insert(towers, { floor = tower.floor, node = tower.node, data = tower.data, cf = tower.cf })
		end
	end
	return towers
end

function DefenseServer.addTower(
	self: DefenseServer,
	uniqueId: string,
	tower: TowerServer,
	fromLoad: boolean?,
	fromCrate: boolean?
)
	if not self.enemies[tower.floor] then
		self.enemies[tower.floor] = {}
	end
	if not self.towers[tower.floor] then
		self.towers[tower.floor] = {}
	end

	tower.damageMult = self.damageMult
	tower.enemies = self.enemies[tower.floor]
	tower.networker = self.networker
	tower.bestDps = self.bestDps

	if fromCrate then
		tower.cd = 5
	end

	self.towers[tower.floor][uniqueId] = tower
	if not (fromLoad or fromCrate) then
		self.networker:fireAll("towerAdded", tower.floor, tower.node, tower.cf, tower.data)
	end
	self:strengthChanged()
end

function DefenseServer.addEnemy(self: DefenseServer, enemy: EnemyServer)
	if not self.enemies[enemy.floor] then
		self.enemies[enemy.floor] = {}
	end

	enemy.path = self.paths[enemy.floor]
	table.insert(self.enemies[enemy.floor], enemy)
	self.networker:fireRecipients("enemyAdded", enemy.floor, enemy.uniqueId, enemy.baseStats)
end

function DefenseServer.rewardEnemy(self: DefenseServer, enemy: EnemyServer)
	if not DataService:hasProfile(self.player) then
		return
	end

	local rebirths: number = DataService:get(self.player, "rebirths")
	local numFriends = FriendServiceServer:getFriendCount(self.player)
	local ownsStarterPack = MonetizationServiceServer:ownsGamepass(self.player, Products.starterPack)
	local reward =
		math.round(Enemies.getEnemyReward(enemy.maxHealth, rebirths, ownsStarterPack, numFriends) * self.currencyMult)
	DataService:update(self.player, "currency", function(amt: number)
		return amt + reward
	end)

	DataService:update(self.player, { "stats", "enemiesKilled" }, function(amt: number)
		return amt + 1
	end, true)

	DataService:update(self.player, { "stats", "totalCurrency" }, function(amt: number)
		return amt + reward
	end, true)
end

function DefenseServer.bleedEnemies(self: DefenseServer, bleedType: string): (boolean, { [string]: { number } })
	local bleeds = {}
	local didBleed = false

	for _, enemies in self.enemies do
		for i = #enemies, 1, -1 do
			local enemy = enemies[i]
			if enemy.dead then
				continue
			end

			local damage = enemy[bleedType](enemy)
			if not damage then
				continue
			end

			didBleed = true
			damage = tostring(damage)
			if not bleeds[damage] then
				bleeds[damage] = { enemy.uniqueId }
			else
				table.insert(bleeds[damage], enemy.uniqueId)
			end
		end
	end

	return didBleed, bleeds
end

function DefenseServer.burnEnemies(self: DefenseServer)
	local didBleed, bleeds = self:bleedEnemies("burn")
	if didBleed then
		self.networker:fireRecipients("burn", bleeds)
	end
end

function DefenseServer.poisonEnemies(self: DefenseServer)
	local didBleed, bleeds = self:bleedEnemies("poison")
	if didBleed then
		self.networker:fireRecipients("poison", bleeds)
	end
end

function DefenseServer.update(self: DefenseServer, dt: number): ()
	self.spawnCd -= dt
	self.burnCooldown -= dt
	self.poisonCooldown -= dt

	if self.spawnCd <= 0 then
		for floor, _ in self.paths do
			self:spawnEnemy(floor)
		end
		self.spawnCd = SPAWN_COOLDOWN
	end

	if self.burnCooldown <= 0 then
		self:burnEnemies()
		self.burnCooldown = BURN_COOLDOWN
	end

	if self.poisonCooldown <= 0 then
		self:poisonEnemies()
		self.poisonCooldown = POISON_COOLDOWN
	end
	for _, enemies in self.enemies do
		for i = #enemies, 1, -1 do
			local enemy = enemies[i]
			enemy:update(dt)

			if enemy.dead then
				table.remove(enemies, i)
				if enemy.killed then
					self:rewardEnemy(enemy)
				end
			elseif enemy.dist >= self.paths[enemy.floor].length then
				enemy.dead = true
				table.remove(enemies, i)
			end
		end
	end

	for _, towers in self.towers do
		for _, tower in towers do
			tower:update(dt)
		end
	end

	self.sortCooldown -= dt
	if self.sortCooldown <= 0 then
		for _, enemies in self.enemies do
			table.sort(enemies, function(a: EnemyServer, b: EnemyServer): boolean
				return a.dist > b.dist
			end)
		end
		self.sortCooldown = SORT_COOLDOWN
	end
end

function DefenseServer.destroy(self: DefenseServer)
	self.networker:destroy()
	self:stop()
	self.janitor:Destroy()
end

return DefenseServer
