local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local VfxUtils = require(ReplicatedStorage.Source.Core.Platform.VfxUtils)
local TowerAnimationUtils = require(script.Parent.TowerAnimationUtils)
local EnemyClient = require(ReplicatedStorage.Source.Features.Defense.Classes.EnemyClient)
local TowerClient = require(ReplicatedStorage.Source.Features.Defense.Classes.TowerClient)

type Tower = TowerClient.TowerClient
type Enemy = EnemyClient.EnemyClient

--local BASE_FIRE_RATE = 1
local BULLET_SPEED = 5
local ANGULAR_VELOCITY = math.rad(360) * 3
local RESET_ANGULAR_VELOCITY = math.rad(360)
local ENEMY_OFFSET = Vector3.new(0, 0.5, 0)
local ANGLE_OFFSET = math.rad(90 - 25)
local HEIGHT = 4

return function(self: Tower & any, enemy: Enemy)
	TowerAnimationUtils.playSound(self, "Attack")
	local speed = 1
	local pos = enemy:getPosition()
	local rotates = self.model.Rotates :: Model
	TowerAnimationUtils.aimBot(self.model, pos)

	local top = rotates.Top :: Model
	local bullet = VfxUtils.getVfx("CatapultProjectile") :: BasePart
	bullet.CFrame = CFrame.new()

	local startingCf = rotates:GetPivot()
	local angle = 0
	local mag: number = (rotates.Root.Position - (enemy:getPosition() + ENEMY_OFFSET)).Magnitude
	local goalAngle = math.acos(HEIGHT / mag) + ANGLE_OFFSET

	local function reset()
		VfxUtils.cacheVfx("CatapultProjectile", bullet)
		local resetConn: RBXScriptConnection
		goalAngle = 0
		resetConn = RunService.Heartbeat:Connect(function(dt: number)
			angle = math.max(goalAngle, angle - RESET_ANGULAR_VELOCITY * dt * speed)
			top:PivotTo(startingCf * CFrame.Angles(0, 0, angle))
			if angle <= goalAngle then
				resetConn:Disconnect()
				if top.Projectile then
					top.Projectile.Transparency = 0
				end
			end
		end)
	end

	local function projectile()
		if not top.Projectile then
			return
		end

		bullet.CFrame = top.Projectile.CFrame
		top.Projectile.Transparency = 1
		local startPos = bullet.Position
		local bulletRot = bullet.CFrame.Rotation
		local bulletConn: RBXScriptConnection
		local progress = 0
		bulletConn = RunService.Heartbeat:Connect(function(dt: number)
			progress = math.min(progress + dt * speed * BULLET_SPEED, 1)
			local currentPos = startPos:Lerp(enemy:getPosition() + ENEMY_OFFSET, progress)
			bullet:PivotTo(CFrame.new(currentPos) * bulletRot)
			if progress >= 1 then
				bulletConn:Disconnect()
				reset()
			end
		end)
	end

	local conn: RBXScriptConnection
	conn = RunService.Heartbeat:Connect(function(dt: number)
		angle = math.min(goalAngle, angle + ANGULAR_VELOCITY * dt * speed)
		top:PivotTo(startingCf * CFrame.Angles(0, 0, angle))
		if angle >= goalAngle then
			conn:Disconnect()
			projectile()
		end
	end)
end
