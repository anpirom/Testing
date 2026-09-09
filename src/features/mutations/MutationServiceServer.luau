local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local MonetizationServiceServer = require(ServerScriptService.Features.Monetization.MonetizationServiceServer)
local Networker = require(ReplicatedStorage.Packages.Networker)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local MutationEvents = require(ReplicatedStorage.Source.Features.Mutations.Modules.MutationEvents)
local MutationServiceUtils = require(ReplicatedStorage.Source.Features.Mutations.MutationServiceUtils)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

type Mutations = DataTemplate.Mutations

local MutationServiceServer = {}

local EVENT_DURATION = 5 * 60
local EVENT_COOLDOWN = 15 * 60
local completedEvents: { [number]: boolean } = {}

local function getEventFromHash(eventHash: number): string
	local rng = Random.new(eventHash)
	local roll = rng:NextNumber()
	return MutationEvents.rollEventId(roll, 1)
end

function MutationServiceServer.init(self: MutationServiceServer)
	self.networker = Networker.server.new("MutationService", self, { self.requestEventData })
	self.activeEvents = {}

	task.spawn(function()
		while true do
			local t = math.round(os.time())
			local eventHash = t // EVENT_COOLDOWN
			if not completedEvents[eventHash] then
				completedEvents[eventHash] = true
				local eventCompletionTime = eventHash * EVENT_COOLDOWN + EVENT_DURATION
				local eventId = getEventFromHash(eventHash)
				task.spawn(self.startEvent, self, eventId, eventCompletionTime)
			end
			task.wait(1)
		end
	end)
end

function MutationServiceServer.getActiveEvents(self: MutationServiceServer): { string }
	local activeEventIds: { string } = {}
	local currentTime = os.time()
	for eventId, completionTime in self.activeEvents do
		if completionTime > currentTime then
			table.insert(activeEventIds, eventId)
		else
			self.activeEvents[eventId] = nil
		end
	end
	return activeEventIds
end

function MutationServiceServer.startEvent(self: MutationServiceServer, eventId: string, completionTime: number)
	if completionTime <= os.time() then
		return
	end

	local mutationModule = require(ReplicatedStorage.Source.Features.Mutations.MutationEvents[eventId])
	mutationModule(completionTime)

	self.activeEvents[eventId] = completionTime
	self.networker:fireAll("activeEventsUpdated", self.activeEvents)
end

function MutationServiceServer.requestEventData(self: MutationServiceServer, _player: Player): { [string]: number }
	self:getActiveEvents() -- Clean up expired events
	return self.activeEvents
end

function MutationServiceServer.rollMutations(self: MutationServiceServer, player: Player): Mutations?
	local activeEvents = self:getActiveEvents()
	local goldHunterPass = MonetizationServiceServer:ownsGamepass(player, Products.goldHunter)
	local diamondHunterPass = MonetizationServiceServer:ownsGamepass(player, Products.diamondHunter)
	return MutationServiceUtils.rollMutations(activeEvents, goldHunterPass, diamondHunterPass)
end

type MutationServiceServer = typeof(MutationServiceServer) & {
	networker: Networker.Server,
	activeEvents: { [string]: number },
}

return MutationServiceServer :: MutationServiceServer
