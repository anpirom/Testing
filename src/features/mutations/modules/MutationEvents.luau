export type MutationEvent = {
	name: string,
	weight: number,
	odds: number,
	color: Color3,
	description: string,
}

local events = {
	windy = {
		name = "Windy",
		weight = 1e3,
		color = Color3.fromRGB(135, 206, 235),
		description = "Chance to roll windy mutation, which increases attack speed.",
	},

	inferno = {
		name = "Inferno",
		weight = 1e3,
		color = Color3.fromRGB(255, 69, 0),
		description = "Chance to roll inferno mutation, which causes attacks to burn.",
	},

	radioactive = {
		name = "Radioactive",
		weight = 800,
		color = Color3.fromRGB(124, 252, 0),
		description = "Chance to roll radioactive mutation, which causes attacks to poison.",
	},

	volcano = {
		name = "Volcano",
		weight = 500,
		color = Color3.fromRGB(252, 8, 0),
		description = "Chance to roll volcano mutation, which makes attacks stronger.",
	},
}

-- cloudy - range
-- meteor - dmg
-- lightning - dmg

local totalWeight = 0
local sortedEvents = {}
for key, event in events do
	totalWeight += event.weight
	table.insert(sortedEvents, key)
end

table.sort(sortedEvents, function(a: string, b: string): boolean
	return events[a].weight > events[b].weight
end)

for _, event in events do
	event.odds = event.weight / totalWeight
end

local Events = {}

function Events.rollEventId(roll: number, luck: number?): string
	local sum = 0
	for i = #sortedEvents, 1, -1 do
		local event = sortedEvents[i]
		local chance = 1 - (1 - events[event].odds) ^ (luck or 1)
		sum += chance
		if roll <= sum then
			return event
		end
	end

	return sortedEvents[1]
end

function Events.getEvent(eventId: string): MutationEvent
	assert(events[eventId], "Invalid event ID: " .. eventId)
	return events[eventId]
end

return Events
