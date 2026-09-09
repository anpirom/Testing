local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Container = ReplicatedStorage.Assets.VFX
local VfxUtils = {}
local cachedVfx = {}

function VfxUtils.getVfx(vfxName: string): Instance
	local cachedTbl = cachedVfx[vfxName]
	if cachedTbl and #cachedTbl > 0 then
		local vfx = table.remove(cachedTbl)
		vfx.Parent = workspace.CurrentCamera
		return vfx
	end

	local vfxTemplate = Container:FindFirstChild(vfxName)
	assert(vfxTemplate, "Vfx template not found for " .. vfxName)

	local vfx = vfxTemplate:Clone()
	vfx.Parent = workspace.CurrentCamera
	return vfx
end

function VfxUtils.cacheVfx(vfxName: string, vfx: Instance): ()
	vfx.Parent = nil
	if cachedVfx[vfxName] then
		table.insert(cachedVfx[vfxName], vfx)
	else
		cachedVfx[vfxName] = { vfx }
	end
end

function VfxUtils.emitAllAtPosition(vfxName: string, position: Vector3, playSounds: boolean?): ()
	local vfx = VfxUtils.getVfx(vfxName)
	vfx.Position = position
	playSounds = if playSounds == nil then true else playSounds

	local longestLifeTime = 0
	for _, emitter in vfx:GetDescendants() do
		if playSounds and emitter:IsA("Sound") then
			emitter:Play()
			continue
		elseif not emitter:IsA("ParticleEmitter") then
			continue
		end
		emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		local emitterLifeTime = emitter.Lifetime.Max
		if emitterLifeTime > longestLifeTime then
			longestLifeTime = emitterLifeTime
		end
	end

	task.delay(longestLifeTime, function()
		VfxUtils.cacheVfx(vfxName, vfx)
	end)
end

function VfxUtils.clearCache(): ()
	for _, vfxList in pairs(cachedVfx) do
		for _, vfx in ipairs(vfxList) do
			vfx:Destroy()
		end
	end
	cachedVfx = {}
end

task.spawn(function()
	while true do
		task.wait(5)
		VfxUtils.clearCache()
	end
end)

return VfxUtils
