local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local VfxUtils = require(ReplicatedStorage.Source.Core.Platform.VfxUtils)
local TowerAnimationUtils = require(script.Parent.TowerAnimationUtils)
local EnemyClient = require(ReplicatedStorage.Source.Features.Defense.Classes.EnemyClient)
local TowerClient = require(ReplicatedStorage.Source.Features.Defense.Classes.TowerClient)

type Tower = TowerClient.TowerClient
type Enemy = EnemyClient.EnemyClient

local SPEED = 2
local ROTATION = CFrame.Angles(math.rad(90), 0, 0)

return function(self: Tower & any, enemy: Enemy)
	local pos = enemy:getPosition()
	TowerAnimationUtils.playSound(self, "Attack")

	local offset = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)
	local startPos = self.model.Start.Position + offset
	local bullet = VfxUtils.getVfx("DarkTerraBullet") :: BasePart
	bullet.CFrame = CFrame.lookAt(startPos, pos) * ROTATION

	local conn
	local rotation = bullet.CFrame.Rotation
	local progress = 0
	conn = RunService.Heartbeat:Connect(function(dt: number)
		progress = math.min(progress + dt * SPEED, 1)
		local currentPos = bullet:GetPivot().Position:Lerp(enemy:getPosition(), progress)
		bullet:PivotTo(CFrame.new(currentPos) * rotation)
		if progress >= 0.45 then
			VfxUtils.cacheVfx("DarkTerraBullet", bullet)
			conn:Disconnect()
		end
	end)
end
