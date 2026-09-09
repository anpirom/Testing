local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TowerAnimationUtils = require(script.Parent.TowerAnimationUtils)
local EnemyClient = require(ReplicatedStorage.Source.Features.Defense.Classes.EnemyClient)
local TowerClient = require(ReplicatedStorage.Source.Features.Defense.Classes.TowerClient)

type Tower = TowerClient.TowerClient
type Enemy = EnemyClient.EnemyClient

local BEAM_BULLET_PROPS = {}

return function(self: Tower & any, enemy: Enemy)
	TowerAnimationUtils.aimBoth(self.model, enemy:getPosition())
	local beam = self.model.Rotates.Start.Attachment.Beam :: Beam
	TowerAnimationUtils.beamBullet(beam, enemy, BEAM_BULLET_PROPS)
	TowerAnimationUtils.playSound(self, "Attack")
end
