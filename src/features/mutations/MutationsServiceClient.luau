local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local MutationServiceUtils = require(script.Parent.MutationServiceUtils)
local MutationSlice = require(script.Parent.MutationSlice)
local Networker = require(ReplicatedStorage.Packages.Networker)
local NotificationMessage = require(ReplicatedStorage.Source.Core.UI.Components.NotificationMessage)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local MonetizationServiceClient = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceClient)
local MutationEvents = require(ReplicatedStorage.Source.Features.Mutations.Modules.MutationEvents)
local ImageIds = require(ReplicatedStorage.Source.Game.Assets.ImageIds)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

type Mutations = DataTemplate.Mutations

local MutationServiceClient = {}

function MutationServiceClient.init(self: MutationServiceClient)
	self.networker = Networker.client.new("MutationService", self)

	Charm.subscribe(MutationSlice.states.activeEvents, function(new, old)
		for eventId, completionTime in new do
			local changed = old[eventId] ~= completionTime
			if not changed or workspace:GetServerTimeNow() > completionTime then
				continue
			end

			local eventInfo = MutationEvents.getEvent(eventId)
			NotificationMessage.add({
				Text = eventInfo.name .. " event has started!",
				Gradient = {
					Rotation = 90,
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
						ColorSequenceKeypoint.new(1, eventInfo.color),
					}),
				},
				Stroke = { Thickness = 3, Color = eventInfo.color:Lerp(Color3.new(0, 0, 0), 0.7) },
				Prefix = {
					Image = ImageIds.mutations[eventId],
				},
			})
		end
	end)

	task.spawn(function()
		local eventData = self.networker:fetch("requestEventData")
		MutationSlice.states.activeEvents(eventData)
	end)
end

function MutationServiceClient.getActiveEvents(_self: MutationServiceClient): { string }
	local activeEventIds: { string } = {}
	for eventId, completionTime in MutationSlice.states.activeEvents() do
		if completionTime > workspace:GetServerTimeNow() then
			table.insert(activeEventIds, eventId)
		end
	end
	return activeEventIds
end

function MutationServiceClient.rollMutations(self: MutationServiceClient): Mutations?
	local goldHunterPass = MonetizationServiceClient:ownsGamepass(Products.goldHunter :: any)
	local diamondHunterPass = MonetizationServiceClient:ownsGamepass(Products.diamondHunter :: any)
	return MutationServiceUtils.rollMutations(self:getActiveEvents(), goldHunterPass, diamondHunterPass)
end

function MutationServiceClient.activeEventsUpdated(_self: MutationServiceClient, activeEvents: { [string]: number })
	MutationSlice.states.activeEvents(activeEvents)
end

type MutationServiceClient = typeof(MutationServiceClient) & {
	networker: Networker.Client,
}

return MutationServiceClient :: MutationServiceClient
