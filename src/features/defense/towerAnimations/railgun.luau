local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local TowerAnimationUtils = require(script.Parent.TowerAnimationUtils)
local VfxUtils = require(ReplicatedStorage.Source.Core.Platform.VfxUtils)
local EnemyClient = require(ReplicatedStorage.Source.Features.Defense.Classes.EnemyClient)

local ATTACK_SPEED = 0.15
local ATTACK_TWEEN_INFO = TweenInfo.new(ATTACK_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local FADE_OUT_TWEEN_INFO = TweenInfo.new(ATTACK_SPEED / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local ROTATION = CFrame.Angles(0, math.rad(180), 0)
local RANGE = 25

return function(self, enemy: EnemyClient.EnemyClient): ()
	TowerAnimationUtils.playSound(self, "Attack")
	TowerAnimationUtils.aim(self.model, enemy:getPosition())

	local pos = self.cf.Position
	local start = self.model.Rotates.Top.Start
	local lookVector = (enemy:getPosition() - pos).Unit
	local endPoint = pos + lookVector * RANGE * 1.2
	local bullet = VfxUtils.getVfx("RailgunBullet") :: BasePart

	local startCf = CFrame.new(start.Position, endPoint) * ROTATION
	local midPoint = start.Position + (endPoint - start.Position) / 2
	bullet.Size = Vector3.new(3, 3, 0.2)
	bullet.CFrame = startCf
	bullet.Transparency = 0

	local tween = TweenService:Create(bullet, ATTACK_TWEEN_INFO, {
		Size = Vector3.new(3, 3, (start.Position - endPoint).Magnitude),
		CFrame = CFrame.new(midPoint, endPoint) * ROTATION,
	})

	tween:Play()

	task.wait(ATTACK_SPEED / 2)
	TweenService:Create(bullet, FADE_OUT_TWEEN_INFO, {
		Transparency = 1,
	})

	task.wait(ATTACK_SPEED / 2)
	VfxUtils.cacheVfx("RailgunBullet", bullet)
end
