local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Charm = require(ReplicatedStorage.Packages.Charm)

local function getTime(): number
	if RunService:IsRunning() then
		return math.round(workspace:GetServerTimeNow())
	end
	return os.time()
end

local t: Charm.Atom<number> = Charm.atom(getTime())
local TIME_GET_CD = 60
local lastTimeGet = t()

task.spawn(function()
	while true do
		task.wait(1)
		t(t() + 1)
		if t() - lastTimeGet >= TIME_GET_CD then
			t(getTime())
			lastTimeGet = t()
		end
	end
end)

return t
