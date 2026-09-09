local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local XZ = Vector3.new(1, 0, 1)
local DEBOUNCE_DISTANCE = 7
local TouchPad = {}

function TouchPad.new(part: BasePart, onTouched: () -> ())
	local self = {
		part = part,
		debounce = false,
		changeConn = nil,
		diedConn = nil,
	}

	local function reset()
		self.debounce = false
		if self.changeConn then
			self.changeConn:Disconnect()
			self.changeConn = nil
		end
		if self.diedConn then
			self.diedConn:Disconnect()
			self.diedConn = nil
		end
	end

	local function attempt(character: Model & any)
		if self.debounce or character.Humanoid.Health <= 0 then
			return
		end

		reset()
		self.debounce = true
		onTouched()

		self.diedConn = character.Humanoid.Died:Connect(reset)
		self.changeConn = RunService.Heartbeat:Connect(function()
			local pos = character:GetPivot().Position
			local mag = ((part.Position - pos) * XZ).Magnitude
			if mag > DEBOUNCE_DISTANCE then
				reset()
			end
		end)
	end

	local touchConn = part.Touched:Connect(function(otherPart: BasePart)
		local character = otherPart.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if not player or player ~= Players.LocalPlayer then
			return
		end

		attempt(character)
	end)

	return function()
		touchConn:Disconnect()
		reset()
	end
end

return TouchPad
