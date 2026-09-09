local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local TowerAnimationUtils = require(script.Parent.TowerAnimationUtils)
local EnemyClient = require(ReplicatedStorage.Source.Features.Defense.Classes.EnemyClient)
local TowerClient = require(ReplicatedStorage.Source.Features.Defense.Classes.TowerClient)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)

type Tower = TowerClient.TowerClient
type Enemy = EnemyClient.EnemyClient

local XZ = Vector3.new(1, 0, 1)

return function(self: any, enemy: Enemy)
	TowerAnimationUtils.aimBoth(self.model, enemy:getPosition())
	local range = Towers.getTowerInfo(self.data.itemId).range
	TowerAnimationUtils.playSound(self, "Attack")

	self.attackCd = 1 / 3
	if self.enemyBeingAttacking == enemy.uniqueId then
		return
	end

	self.enemyBeingAttacking = enemy.uniqueId

	if self.attackConn then
		self.attackConn:Disconnect()
	end

	local rotates = self.model.Rotates
	local beam1: Beam = rotates.Start.Beams.Beam1
	local beam2: Beam = rotates.Start.Beams.Beam2
	local attach: Attachment = rotates.Start.End
	beam1.Enabled = true
	beam2.Enabled = true

	self.attackConn = RunService.Heartbeat:Connect(function(dt: number)
		self.attackCd -= dt
		local dist = ((self.cf.Position - enemy:getPosition()) * XZ).Magnitude * 0.95
		if self.attackCd <= 0 or dist > range then
			beam1.Enabled = false
			beam2.Enabled = false
			self.attackConn:Disconnect()
			self.attackConn = nil
		else
			attach.WorldCFrame = CFrame.new(enemy:getPosition())
		end
	end)
end
