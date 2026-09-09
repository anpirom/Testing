local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

return function(ref)
	local absSize, setAbsSize = React.useState(Vector2.new(0, 0))

	React.useEffect(function()
		if not ref.current then
			return
		end

		setAbsSize(ref.current.AbsoluteSize)
		local conn = ref.current:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			setAbsSize(ref.current.AbsoluteSize)
		end)

		return function()
			conn:Disconnect()
		end
	end, { ref.current })

	return absSize
end
