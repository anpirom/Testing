local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ripple = require(ReplicatedStorage.Packages.Ripple)
local TowerAnimationUtils = require(script.Parent.TowerAnimationUtils)
local EnemyClient = require(ReplicatedStorage.Source.Features.Defense.Classes.EnemyClient)
local TowerClient = require(ReplicatedStorage.Source.Features.Defense.Classes.TowerClient)

type Tower = TowerClient.TowerClient
type Enemy = EnemyClient.EnemyClient

local inputOptions = {
	dampingRatio = 0.6,
	frequency = 6,
	start = true,
}

local BEAM_BULLET_PROPS = {
	speedMod = -2,
	offsetEnd = 0,
	offsetStart = 0.92,
	useAttachment1 = true,
}
local IMPULSE = 100

return function(self: Tower & any, enemy: Enemy)
	TowerAnimationUtils.aim(self.model, enemy:getPosition())
	local beam = self.model.Rotates.Top.Barrel.Start.Attachment.Beam :: Beam
	TowerAnimationUtils.beamBullet(beam, enemy, BEAM_BULLET_PROPS)
	TowerAnimationUtils.playSound(self, "Attack")

	local spring = self.spring :: Ripple.Spring<number>
	if not spring then
		local barrel = self.model.Rotates.Top.Barrel
		local topRoot: BasePart = self.model.Rotates.Top.Root
		local newSpring = Ripple.createSpring(0, inputOptions)
		self.janitor:Add(newSpring:onChange(function(v)
			barrel:PivotTo(topRoot:GetPivot() * CFrame.new(math.clamp(v, -3, 3), 0, 0))
		end))
		self.spring = newSpring
		spring = newSpring
	end

	spring:impulse(IMPULSE)
end
