local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Networker = require(ReplicatedStorage.Packages.Networker)
local CodeServiceUtils = require(script.Parent.CodeServiceUtils)

local CodeServiceClient = {}

function CodeServiceClient.init(self: CodeServiceClient): ()
	self.networker = Networker.client.new("CodeService", self)
end

function CodeServiceClient.redeem(self: CodeServiceClient, code: string): (boolean, string)
	local response = self.networker:fetch("redeem", code)
	local success = response == CodeServiceUtils.REDEEM_ENUMS.success
	local str = CodeServiceUtils.ERROR_CODES[response] or "Unknown Error!"
	return success, str
end

type CodeServiceClient = typeof(CodeServiceClient) & {
	networker: Networker.Client,
}

return CodeServiceClient :: CodeServiceClient
