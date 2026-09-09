local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Networker = require(ReplicatedStorage.Packages.Networker)

local enabled = false
local lastInput = os.time()
local timerThread: thread?
local AUTO_REJOIN_TIME = 17 * 60

local AutoRejoinClient = {
	networker = nil,
}

function AutoRejoinClient:init()
	self.networker = Networker.client.new("AutoRejoinService", self)
	self:enable()
end

function AutoRejoinClient.enable()
	enabled = true
	if timerThread then
		return
	end

	lastInput = os.time()
	timerThread = task.spawn(function()
		while enabled do
			if os.time() - lastInput >= AUTO_REJOIN_TIME then
				AutoRejoinClient.networker:fire("autoRejoin")
			end
			task.wait(5)
		end
	end)
end

function AutoRejoinClient.disable()
	enabled = false
	if timerThread then
		task.cancel(timerThread)
		timerThread = nil
	end
end

UserInputService.InputEnded:Connect(function()
	lastInput = os.time()
end)

return AutoRejoinClient
