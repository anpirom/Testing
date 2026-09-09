local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local EnemyClient = require(ReplicatedStorage.Source.Features.Defense.Classes.EnemyClient)
local TowerClient = require(ReplicatedStorage.Source.Features.Defense.Classes.TowerClient)

type Tower = TowerClient.TowerClient
type Enemy = EnemyClient.EnemyClient

local XZ = Vector3.new(1, 0, 1)
local RANGE = 25

return function(self: any, enemy: Enemy)
	--TowerAnimationUtils.playSound(self, "Attack")

	self.attackCd = 0.4
	if self.enemyBeingAttacking == enemy.uniqueId then
		return
	end

	self.enemyBeingAttacking = enemy.uniqueId

	if self.attackingConn then
		self.attackingConn:Disconnect()
	end

	local start = self.model.Start :: Instance
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
		else
			attach.WorldCFrame = CFrame.new(enemy:getPosition())
		end
	end)
end
