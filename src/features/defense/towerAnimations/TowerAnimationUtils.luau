local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Signal = require(ReplicatedStorage.Packages.Signal)
local EnemyClient = require(ReplicatedStorage.Source.Features.Defense.Classes.EnemyClient)
local TowerClient = require(ReplicatedStorage.Source.Features.Defense.Classes.TowerClient)
local VFX = ReplicatedStorage.Assets.VFX

local ROTATION_OFFSET = CFrame.Angles(0, math.rad(-90), 0)
local BEAM_OFFSET_START = -0.1
local BEAM_OFFSET_END = 0.12
local BEAM_BULLET_SPEED = 2

local cachedAttachments: { Attachment } = {}
local TowerAnimationUtils = {}

local function getAttachment(): Attachment
	if #cachedAttachments > 0 then
		return table.remove(cachedAttachments) :: Attachment
	else
		local attachment = Instance.new("Attachment")
		attachment.Parent = workspace
		return attachment
	end
end

local function recycleAttachment(attachment: Attachment): ()
	table.insert(cachedAttachments, attachment)
end

function TowerAnimationUtils.loopSound(tower: TowerClient.TowerClient, soundName: string): ()
	local sound = tower.model.PrimaryPart:FindFirstChild(soundName) :: Sound
	assert(sound, "Sound not found: " .. soundName .. " for " .. tower.data.itemId)
	if sound.Playing then
		return
	end
	sound.Looped = true
	sound:Play()
end

function TowerAnimationUtils.stopSound(tower: TowerClient.TowerClient, soundName: string): ()
	local sound = tower.model.PrimaryPart:FindFirstChild(soundName) :: Sound
	assert(sound, "Sound not found: " .. soundName .. " for " .. tower.data.itemId)
	if sound.Playing then
		sound:Stop()
	end
end

function TowerAnimationUtils.playSound(tower: TowerClient.TowerClient, soundName: string, overideLength: number?): ()
	local sound = tower.model.PrimaryPart:FindFirstChild(soundName) :: Sound
	assert(sound, "Sound not found: " .. soundName .. " for " .. tower.data.itemId)
	if not sound.Playing or sound.TimePosition > sound.TimeLength * (overideLength or 0.5) then
		sound:Play()
	end
end

function TowerAnimationUtils.aimBot(model: any, target: Vector3): ()
	local rotates = model:FindFirstChild("Rotates") :: any
	local pos = rotates:GetPivot().Position
	local groundTarget = Vector3.new(target.X, pos.Y, target.Z)
	rotates:PivotTo(CFrame.lookAt(pos, groundTarget) * ROTATION_OFFSET)
end

function TowerAnimationUtils.aim(model: any, target: Vector3): ()
	local rotates = model:FindFirstChild("Rotates") :: any
	local pos = rotates:GetPivot().Position
	local groundTarget = Vector3.new(target.X, pos.Y, target.Z)
	rotates:PivotTo(CFrame.lookAt(pos, groundTarget) * ROTATION_OFFSET)

	local top = rotates:FindFirstChild("Top") :: any?
	if not top then
		return
	end

	local topPos = top:GetPivot().Position
	top:PivotTo(CFrame.lookAt(topPos, target) * ROTATION_OFFSET)
end

function TowerAnimationUtils.aimBoth(model: any, target: Vector3): ()
	local rotates = model:FindFirstChild("Rotates") :: any
	local pos = rotates:GetPivot().Position
	rotates:PivotTo(CFrame.lookAt(pos, target) * ROTATION_OFFSET)
end

function TowerAnimationUtils.beamEnemy(beam: Beam, enemy: EnemyClient.EnemyClient, useAttachment1: boolean?): () -> ()
	local attachment: Attachment
	local diedConn: Signal.Connection?
	local pos = enemy:getPosition()

	local function setNewAttachment()
		attachment = getAttachment()
		if useAttachment1 then
			beam.Attachment1 = attachment
		else
			beam.Attachment0 = attachment
		end
		attachment.WorldCFrame = CFrame.new(pos)
	end

	local function cleanup()
		beam.Enabled = false

		if attachment then
			recycleAttachment(attachment)
		end

		if diedConn then
			diedConn:Disconnect()
			diedConn = nil
		end
	end

	if not enemy or enemy.dead then
		setNewAttachment()
	else
		local enemyAttachment = enemy.model:FindFirstChild("RootAttachment", true) :: Attachment
		if useAttachment1 then
			beam.Attachment1 = enemyAttachment
		else
			beam.Attachment0 = enemyAttachment
		end
		diedConn = enemy.destroyed:Once(function()
			pos = enemy:getPosition()
			setNewAttachment()
		end)
	end

	beam.Enabled = true
	return cleanup
end

type BeamBulletProps = {
	speedMod: number?,
	useAttachment1: boolean?,
	offsetEnd: number?,
	offsetStart: number?,
}

function TowerAnimationUtils.beamBullet(beam: Beam, enemy: EnemyClient.EnemyClient, props: BeamBulletProps): ()
	local animationConnection: RBXScriptConnection
	local cleanup = TowerAnimationUtils.beamEnemy(beam, enemy, props.useAttachment1)
	local beamOffset = props.offsetStart or BEAM_OFFSET_START
	local offsetEnd = props.offsetEnd or BEAM_OFFSET_END
	beam:SetTextureOffset(beamOffset)
	local speed = if props.speedMod then props.speedMod * BEAM_BULLET_SPEED else BEAM_BULLET_SPEED
	local inverted = beamOffset > offsetEnd

	animationConnection = RunService.Heartbeat:Connect(function(dt: number)
		if (inverted and beamOffset <= offsetEnd) or (not inverted and beamOffset > offsetEnd) then
			cleanup()
			animationConnection:Disconnect()
			return
		end
		beamOffset += dt * speed
		beam:SetTextureOffset(beamOffset)
	end)
end

function TowerAnimationUtils.projectileBullet(
	startPos: Vector3,
	target: Vector3,
	speed: number,
	projectileName: string
): ()
	local projectile = VFX[projectileName]:Clone() :: BasePart
	projectile.Parent = workspace.CurrentCamera
	local connection: RBXScriptConnection
	local progress = 0

	connection = RunService.Heartbeat:Connect(function(dt: number)
		progress += speed * dt
		if progress >= 1 then
			projectile:Destroy()
			connection:Disconnect()
			return
		end

		projectile:PivotTo(CFrame.lookAt(startPos:Lerp(target, progress), target))
	end)
end

return TowerAnimationUtils
