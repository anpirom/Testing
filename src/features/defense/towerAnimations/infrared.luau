local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local TowerAnimationUtils = require(script.Parent.TowerAnimationUtils)
local EnemyClient = require(ReplicatedStorage.Source.Features.Defense.Classes.EnemyClient)
local TowerClient = require(ReplicatedStorage.Source.Features.Defense.Classes.TowerClient)

type Tower = TowerClient.TowerClient
type Enemy = EnemyClient.EnemyClient

return function(self: any, enemy: Enemy)
	TowerAnimationUtils.playSound(self, "Attack")

	if not self.bolts then
		self.bolts = ReplicatedStorage.Assets.VFX.RedLightningBolts:Clone()
		self.bolts.Parent = workspace
		self.janitor:Add(self.bolts)
		self.janitor:Add(function()
			self.bolts = nil
		end)
	end

	local enemies = { enemy }
	local startPoint = self.model.Start.Position
	table.sort(enemies, function(a, b)
		local distanceA = (a:getPosition() - startPoint).Magnitude
		local distanceB = (b:getPosition() - startPoint).Magnitude
		return distanceA < distanceB
	end)

	for i = 1, #enemies, 1 do
		local enemyPos = enemies[i]:getPosition()
		local bolt = self.bolts[tostring(i)]
		local startPos: Vector3
		if i > 1 then
			local prevBolt: Part = self.bolts[tostring(i - 1)]
			startPos = prevBolt.CFrame:PointToWorldSpace(Vector3.new(0, -prevBolt.Size.Y / 2, 0))
		else
			startPos = startPoint
		end

		local midpoint = (startPos + enemyPos) / 2
		bolt.Size = Vector3.new(0.7, (startPos - enemyPos).Magnitude, 0.7)
		bolt.CFrame = CFrame.new(midpoint, enemyPos) * CFrame.Angles(math.pi / 2, math.rad(math.random(0, 360)), 0)
		bolt.Transparency = 0
	end

	for i = #enemies + 1, 3, 1 do
		self.bolts[tostring(i)].Transparency = 1
	end

	self.attackTimer = 0.33

	if self.attackConnection then
		return
	end

	self.attackConnection = RunService.Heartbeat:Connect(function(dt: number)
		self.attackTimer -= dt
		if self.attackTimer <= 0 then
			self.attackConnection:Disconnect()
			self.attackConnection = nil
			for _, bolt in self.bolts:GetChildren() do
				bolt.Transparency = 1
			end
		end
	end)
end
