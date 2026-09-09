local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ripple = require(ReplicatedStorage.Packages.Ripple)
local TowerAnimationUtils = require(script.Parent.TowerAnimationUtils)
local EnemyClient = require(ReplicatedStorage.Source.Features.Defense.Classes.EnemyClient)
local TowerClient = require(ReplicatedStorage.Source.Features.Defense.Classes.TowerClient)

type Tower = TowerClient.TowerClient
type Enemy = EnemyClient.EnemyClient

local inputOptions = {
	dampingRatio = 0.66,
	frequency = 8,
	start = true,
}

local BEAM_BULLET_PROPS = {}
local IMPULSE = 20

return function(self: any, enemy: Enemy)
	TowerAnimationUtils.aimBoth(self.model, enemy:getPosition())
	self.left = not self.left
	local left = self.left

	local barrel = if left then self.model.Rotates.BarrelLeft else self.model.Rotates.BarrelRight
	local beam = barrel.Start.Attachment.Beam :: Beam
	TowerAnimationUtils.beamBullet(beam, enemy, BEAM_BULLET_PROPS)
	TowerAnimationUtils.playSound(self, "Attack")

	local springName = if left then "leftSpring" else "rightSpring"
	local spring = self[springName] :: Ripple.Spring<number>
	if not spring then
		local root: BasePart = self.model.Rotates.Root
		local newSpring = Ripple.createSpring(0, inputOptions)
		self.janitor:Add(newSpring:onChange(function(v)
			barrel:PivotTo(root:GetPivot() * CFrame.new(math.clamp(v, -3, 3), 0, 0))
		end))
		self[springName] = newSpring
		spring = newSpring
	end

	spring:impulse(IMPULSE)
end
