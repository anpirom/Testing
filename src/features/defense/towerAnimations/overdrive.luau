local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local TowerAnimationUtils = require(script.Parent.TowerAnimationUtils)
local EnemyClient = require(ReplicatedStorage.Source.Features.Defense.Classes.EnemyClient)
local TowerClient = require(ReplicatedStorage.Source.Features.Defense.Classes.TowerClient)

type Tower = TowerClient.TowerClient
type Enemy = EnemyClient.EnemyClient

local XZ = Vector3.new(1, 0, 1)
local RANGE = 25
local OFFSET = Vector3.new(0, 1, 0)

return function(self: any, enemy: Enemy)
	TowerAnimationUtils.aimBoth(self.model, enemy:getPosition() + OFFSET)
	TowerAnimationUtils.loopSound(self, "Attack")

	self.attackCd = 0.4
	if self.enemyBeingAttacking == enemy.uniqueId then
		return
	end

	self.enemyBeingAttacking = enemy.uniqueId

	if self.attackingConn then
		self.attackingConn:Disconnect()
	end

	local start = self.model.Rotates.Start :: Instance
	local attach = start.End :: Attachment

	start.Beam.Enabled = true
	self.attackingConn = RunService.Heartbeat:Connect(function(dt: number)
		self.attackCd -= dt
		local dist = ((self.cf.Position - enemy:getPosition()) * XZ).Magnitude * 0.95
		if self.attackCd <= 0 or dist > RANGE then
			self.enemyBeingAttacking = nil
			self.attackingConn:Disconnect()
			self.attackingConn = nil
			start.Beam.Enabled = false
			TowerAnimationUtils.stopSound(self, "Attack")
		else
			attach.WorldCFrame = CFrame.new(enemy:getPosition() + OFFSET)
		end
	end)
end
