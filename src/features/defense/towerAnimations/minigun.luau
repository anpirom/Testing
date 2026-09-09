local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local TowerAnimationUtils = require(script.Parent.TowerAnimationUtils)
local EnemyClient = require(ReplicatedStorage.Source.Features.Defense.Classes.EnemyClient)
local TowerClient = require(ReplicatedStorage.Source.Features.Defense.Classes.TowerClient)
local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)

type Tower = TowerClient.TowerClient
type Enemy = EnemyClient.EnemyClient

local XZ = Vector3.new(1, 0, 1)
local BARREL_SPEED = 4 * 360

return function(self: any, enemy: Enemy)
	TowerAnimationUtils.aim(self.model, enemy:getPosition())
	local range = Towers.getTowerInfo(self.data.itemId).range
	TowerAnimationUtils.playSound(self, "Attack")

	if not self.barrelAngle then
		self.barrelAngle = 0
	end

	self.attackCd = 1 / 3
	if self.enemyBeingAttacking == enemy.uniqueId then
		return
	end

	self.enemyBeingAttacking = enemy.uniqueId

	if self.attackConn then
		self.attackConn:Disconnect()
	end

	local barrelRoot = self.model.Rotates.Top.BarrelRoot
	local barrels = self.model.Rotates.Top.Barrels
	local beam: Beam = barrelRoot.Beam
	local attach: Attachment = barrelRoot.End
	beam.Enabled = true

	self.attackConn = RunService.Heartbeat:Connect(function(dt: number)
		self.attackCd -= dt
		self.barrelAngle = (self.barrelAngle + dt * BARREL_SPEED) % 360
		local dist = ((self.cf.Position - enemy:getPosition()) * XZ).Magnitude * 0.95
		if self.attackCd <= 0 or dist > range then
			beam.Enabled = false
			self.attackConn:Disconnect()
			self.attackConn = nil
		else
			attach.WorldCFrame = CFrame.new(enemy:getPosition())
			barrels:PivotTo(barrelRoot:GetPivot() * CFrame.Angles(math.rad(self.barrelAngle), 0, 0))
		end
	end)
end
