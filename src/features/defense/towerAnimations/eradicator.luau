local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ripple = require(ReplicatedStorage.Packages.Ripple)
local TowerAnimationUtils = require(script.Parent.TowerAnimationUtils)
local EnemyClient = require(ReplicatedStorage.Source.Features.Defense.Classes.EnemyClient)
local TowerClient = require(ReplicatedStorage.Source.Features.Defense.Classes.TowerClient)

type Tower = TowerClient.TowerClient
type Enemy = EnemyClient.EnemyClient

local inputOptions = {
	dampingRatio = 0.5,
	frequency = 6,
	start = true,
}

local IMPULSE = 50
local PROJECTILE_SPEED = 8

return function(self: Tower & any, enemy: Enemy)
	TowerAnimationUtils.aimBoth(self.model, enemy:getPosition())
	TowerAnimationUtils.playSound(self, "Attack")
	local start = self.model.Rotates.Barrel.Start.Position
	TowerAnimationUtils.projectileBullet(start, enemy:getPosition(), PROJECTILE_SPEED, "EradicatorProjectile")

	local spring = self.spring :: Ripple.Spring<number>
	if not spring then
		local barrel = self.model.Rotates.Barrel
		local rotatesRoot: BasePart = self.model.Rotates.Root
		local newSpring = Ripple.createSpring(0, inputOptions)
		self.janitor:Add(newSpring:onChange(function(v)
			barrel:PivotTo(rotatesRoot:GetPivot() * CFrame.new(math.clamp(v, -4, 4), 0, 0))
		end))
		self.spring = newSpring
		spring = newSpring
	end

	spring:impulse(IMPULSE)
end
