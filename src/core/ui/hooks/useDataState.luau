local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local React = require(ReplicatedStorage.Packages.React)

return function(path: string | { string }, defered: boolean?)
	local key = if type(path) == "string" then path else table.concat(path, ".")
	local value, setValue = React.useState(DataService:get(path))

	React.useEffect(function()
		local mostRecent = nil
		local thread = nil
		local function update(new: any)
			if not defered then
				setValue(if type(new) == "table" then table.clone(new) else new)
				return
			end

			mostRecent = new
			if thread then
				return
			end

			thread = task.defer(function()
				setValue(if type(mostRecent) == "table" then table.clone(mostRecent) else mostRecent)
				mostRecent = nil
				thread = nil
			end)
		end

		local conn = DataService:getChangedSignal(path):Connect(update)

		return function()
			conn:Disconnect()
			if thread then
				task.cancel(thread)
			end
		end
	end, { key })

	return value
end
