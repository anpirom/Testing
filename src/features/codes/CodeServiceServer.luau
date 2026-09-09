local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local Networker = require(ReplicatedStorage.Packages.Networker)
local ServicePlayerData = require(ReplicatedStorage.Packages.ServicePlayerData)
local CodeServiceUtils = require(ReplicatedStorage.Source.Features.Codes.CodeServiceUtils)

type Code = {
	reward: string | { string },
	params: { any } | { { any } } | nil,
	userIds: { number }?,
	active: boolean,
	expiration: number?,
	uses: number?,
}

type Codes = { [string]: Code }
type InventoryCodes = { [string]: boolean }
type RewardCallbacks = { [string]: (...any?) -> () }

local DATA_STORE_KEY = "Codes"
local UPDATE_FREQUENCY = 60
local REDEEM_ENUMS = CodeServiceUtils.REDEEM_ENUMS

local PLAYER_DATA_TEMPLATE = {
	redeeming = false,
}

type PlayerData = {
	redeeming: boolean,
}

local CodeService = {
	debug = false,
	dataStore = DataStoreService:GetDataStore("Codes"),
}

local function log(...)
	if CodeService.debug then
		print(...)
	end
end

function CodeService.init(self: CodeService, rewardCallbacks: RewardCallbacks): ()
	self.rewardCallbacks = rewardCallbacks
	self.networker = Networker.server.new("CodeService", self, { self.redeem })
	self.codes = {}
	self.playerData = ServicePlayerData.new(PLAYER_DATA_TEMPLATE)

	task.spawn(function()
		while true do
			self:update()
			task.wait(UPDATE_FREQUENCY)
		end
	end)
end

function CodeService.update(self: CodeService): ()
	log("Updating codes")
	local s, result = pcall(function()
		return self.dataStore:GetAsync(DATA_STORE_KEY)
	end)

	if not s then
		warn("Failed to get codes", result)
		return
	end

	self.codes = result
	log("Updated codes", result)
end

function CodeService.listActiveCodes(self: CodeService): ()
	for name, code in self.codes do
		if
			code.active
			and (not code.expiration or code.expiration > os.time())
			and (not code.uses or code.uses > 0)
		then
			print(name, code)
		end
	end
end

function CodeService.addUserIdsToCode(self: CodeService, code: string, userIds: { number }): ()
	code = string.lower(code)
	print("Adding user ids to code", code, userIds)
	local s, e = pcall(function()
		self.dataStore:UpdateAsync(DATA_STORE_KEY, function(codes: Codes)
			if not codes or not codes[code] then
				error("Code not found" .. code)
				return
			end

			local users = codes[code].userIds or {}
			for _, userId in ipairs(userIds) do
				if not table.find(users, userId) then
					table.insert(users, userId)
				end
			end
			codes[code].userIds = users
			return codes
		end)
	end)

	if s then
		print("Successfully added user ids to code", code)
	else
		warn("Failed to add user ids to code", e)
	end

	self:update()
end

function CodeService.add(self: CodeService, code: string, info: Code): ()
	code = string.lower(code)
	print("Adding code", code, info)
	info.active = true
	local s, e = pcall(function()
		self.dataStore:UpdateAsync(DATA_STORE_KEY, function(codes: Codes)
			if not codes then
				codes = {}
			end

			if codes[code] then
				error("Code already exists: " .. code)
				return
			end

			codes[code] = info
			return codes
		end)
	end)

	if s then
		print("Successfully added code", code)
	else
		warn("Failed to add code", e)
	end

	self:update()
end

function CodeService.remove(self: CodeService, code: string): ()
	code = string.lower(code)
	print("Removing code", code)
	local s, e = pcall(function()
		self.dataStore:UpdateAsync(DATA_STORE_KEY, function(codes: Codes)
			codes[code] = nil
			return codes
		end)
	end)

	if s then
		print("Successfully removed code", code)
	else
		warn("Failed to remove code", e)
	end

	self:update()
end

function CodeService.deactivate(self: CodeService, code: string): ()
	code = string.lower(code)
	print("Deactivating code", code)
	local s, e = pcall(function()
		self.dataStore:UpdateAsync(DATA_STORE_KEY, function(codes: Codes)
			if not codes or not codes[code] then
				error("Code not found" .. code)
				return
			end

			codes[code].active = false
			return codes
		end)
	end)

	if s then
		print("Successfully deactivated code", code)
	else
		warn("Failed to deactivate code", e)
	end

	self:update()
end

function CodeService.hasRedeemedCode(_self: CodeService, player: Player, code: string): boolean
	local alreadyRedeemedCodes = DataService:get(player, "_codes")
	if alreadyRedeemedCodes and alreadyRedeemedCodes[code] then
		return true
	end

	return false
end

function CodeService._redeem(self: CodeService, player: Player, codeId: string): number
	local code = self.codes[codeId]
	if not code then
		return REDEEM_ENUMS.invalid
	end

	local isExpired = code.expiration and code.expiration < os.time()
	if not code.active or isExpired then
		return REDEEM_ENUMS.expired
	end

	if code.uses and code.uses <= 0 then
		return REDEEM_ENUMS.outOfUses
	end

	if self:hasRedeemedCode(player, codeId) then
		return REDEEM_ENUMS.alreadyRedeemed
	end

	if code.userIds then
		local userId = player.UserId
		local index = table.find(code.userIds, userId)
		if not index then
			return REDEEM_ENUMS.wrongUser
		end
	end

	if not code.uses then
		return REDEEM_ENUMS.success
	end

	local s, e = pcall(function()
		self.dataStore:UpdateAsync(DATA_STORE_KEY, function(codes: Codes)
			if not codes or not codes[codeId] then
				error("Code not found" .. codeId)
				return
			end

			local uses = codes[codeId].uses
			if not uses then
				return
			end

			codes[codeId].uses = uses - 1
			return codes
		end)
	end)

	if not s then
		warn("Failed to decrement uses", e)
		return REDEEM_ENUMS.err
	end

	return REDEEM_ENUMS.success
end

function CodeService.reward(self: CodeService, player: Player, reward: string, ...: any?): number?
	log("Rewarding player", player, reward, ...)
	local callback = self.rewardCallbacks[reward]
	if not callback then
		warn("No callback found for reward", reward)
		return
	end

	return callback(player, ...)
end

function CodeService.redeem(self: CodeService, player: Player, code: string)
	local playerData = self.playerData:get(player)
	if playerData.redeeming then
		return REDEEM_ENUMS.err
	end
	playerData.redeeming = true

	code = string.lower(code)
	local redeemStatus = self:_redeem(player, code)
	log("Redeem status", redeemStatus)
	if redeemStatus ~= REDEEM_ENUMS.success then
		playerData.redeeming = false
		return redeemStatus
	end

	log("Updating player codes")
	DataService:update(player, "_codes", function(codes: InventoryCodes)
		if not codes then
			codes = {}
		end

		codes[code] = true
		return codes
	end)

	playerData.redeeming = false

	local codeInfo = self.codes[code]

	local rewardTbl = codeInfo.reward
	local paramsTbl = codeInfo.params
	if type(codeInfo.reward) == "string" then
		rewardTbl = { rewardTbl }
		paramsTbl = { paramsTbl }
	end

	for i = 1, #rewardTbl do
		local reward = rewardTbl[i]
		local params = paramsTbl[i]
		local s, e = pcall(self.reward, self, player, reward, params[1], params[2], params[3], params[4], params[5])
		if not s then
			warn("Failed to reward player", player, codeInfo.reward, e)
			return REDEEM_ENUMS.err
		end
	end

	return REDEEM_ENUMS.success
end

type CodeService = typeof(CodeService) & {
	networker: Networker.Server,
	codes: Codes,
	debug: boolean,
	dataStore: DataStore,
	rewardCallbacks: RewardCallbacks,
	playerData: ServicePlayerData.ServicePlayerData<PlayerData>,
}

return CodeService :: CodeService
