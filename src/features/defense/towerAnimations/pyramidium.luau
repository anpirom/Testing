local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local VfxUtils = require(ReplicatedStorage.Source.Core.Platform.VfxUtils)
local EnemyClient = require(ReplicatedStorage.Source.Features.Defense.Classes.EnemyClient)
local TowerAnimationUtils = require(script.Parent.TowerAnimationUtils)

local SPEED = 4
local ROTATION = CFrame.Angles(math.rad(-90), 0, 0)

type Enemy = EnemyClient.EnemyClient

local proximities = {}

return function(self: any, enemy: Enemy): ()
	local pos = enemy:getPosition()
	TowerAnimationUtils.playSound(self, "Attack")
	--[[if not TowerAnimationUtils.vfxEnabled() then
		return
	end]]

	for _, prox in proximities do
		if (prox - pos).Magnitude < 1 then
			return
		end
	end

	proximities[enemy.uniqueId] = pos

	local startPos = pos + Vector3.new(0, 9, 0) * enemy.scale
	local bullet = VfxUtils.getVfx("PyramidiumBullet") :: BasePart
	bullet.CFrame = CFrame.lookAt(startPos, pos) * ROTATION
	local startCf = bullet.CFrame

	local conn
	local rotation = bullet.CFrame.Rotation
	local progress = 0
	conn = RunService.Heartbeat:Connect(function(dt: number)
		progress = math.min(progress + dt * SPEED, 1)
		local currentPos = startCf.Position:Lerp(enemy:getPosition(), progress)
		bullet:PivotTo(CFrame.new(currentPos) * rotation)
		if progress >= 0.8 then
			proximities[enemy.uniqueId] = nil
			VfxUtils.cacheVfx("PyramidiumBullet", bullet)
			conn:Disconnect()
		end
	end)
end
