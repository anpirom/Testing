local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TowerAnimationUtils = require(script.Parent.TowerAnimationUtils)
local EnemyClient = require(ReplicatedStorage.Source.Features.Defense.Classes.EnemyClient)
local TowerClient = require(ReplicatedStorage.Source.Features.Defense.Classes.TowerClient)

type Tower = TowerClient.TowerClient
type Enemy = EnemyClient.EnemyClient

local BEAM_BULLET_PROPS = { speedMod = 0.5 }

return function(self: Tower & any, enemy: Enemy)
	local beam = self.model.Center.Start.Beam :: Beam
	local emitter = self.model.Center.Start.Slashes :: ParticleEmitter
	emitter:Emit(5)
	TowerAnimationUtils.beamBullet(beam, enemy, BEAM_BULLET_PROPS)
	TowerAnimationUtils.playSound(self, "Attack")
end
