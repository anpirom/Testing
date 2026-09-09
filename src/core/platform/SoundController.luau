local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local SoundController = {}

type SoundInfo = {
	SoundId: string,
	Volume: number?,
	Looped: boolean?,
	PlaybackRegion: NumberRange?,
	LoopRegion: NumberRange?,
}

local cachedSounds: { [string]: Sound } = {}

local function newSound(SoundInfo: SoundInfo, parent: Instance?): Sound
	local sound = Instance.new("Sound")
	if SoundInfo.LoopRegion or SoundInfo.PlaybackRegion then
		sound.PlaybackRegionsEnabled = true
	end

	for property, value in SoundInfo do
		sound[property] = value
	end

	sound.Parent = parent or SoundService
	cachedSounds[SoundInfo.SoundId] = sound
	return sound
end

function SoundController:Load(SoundInfo: SoundInfo)
	if cachedSounds[SoundInfo.SoundId] then
		return
	end

	newSound(SoundInfo)
end

function SoundController:Play(SoundInfo: any)
	if not RunService:IsRunning() then
		return
	end

	local sound = cachedSounds[SoundInfo.SoundId] or newSound(SoundInfo)
	sound:Play()
end

return SoundController
