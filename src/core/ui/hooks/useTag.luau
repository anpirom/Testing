local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

return function(tag: string): Instance?
	local instance, setInstance = React.useState(CollectionService:GetTagged(tag)[1])
	local ref = React.useRef(instance)

	React.useEffect(function()
		local addedConn = CollectionService:GetInstanceAddedSignal(tag):Connect(function(newInstance)
			if ref.current ~= nil then
				warn(
					`useTag: Multiple instances with tag "{tag}" detected.\nuseTag should only be used with tags that have a single instance.`
				)
				return
			end
			setInstance(newInstance)
			ref.current = newInstance
		end)

		local removedConn = CollectionService:GetInstanceRemovedSignal(tag):Connect(function(removedInstance)
			if removedInstance == ref.current then
				setInstance(nil)
				ref.current = nil
			end
		end)

		return function()
			addedConn:Disconnect()
			removedConn:Disconnect()
		end
	end, { tag })

	return instance
end
