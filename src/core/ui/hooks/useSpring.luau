local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Ripple = require(ReplicatedStorage.Packages.Ripple)

type Binding<T> = React.Binding<T>
type Animatable = Ripple.Animatable
type Spring<T> = Ripple.Spring<T>
type SpringOptions<T> = Ripple.SpringOptions<T>

local function useSpring<T>(initialValue: T, initialOptions: SpringOptions<T>?, initialGoal: T?): (Binding<T>, Spring<T>)
	local value, setValue = React.useBinding(initialValue)
	local springRef = React.useRef((nil :: any) :: Spring<T>)

	if not springRef.current then
		springRef.current = Ripple.createSpring(initialValue, initialOptions)
	end

	React.useEffect(function()
		local disconnect = springRef.current:onChange(setValue)

		if not initialOptions or initialOptions.start ~= false then
			springRef.current:start()
		end

		if initialGoal ~= nil then
			springRef.current:setGoal(initialGoal)
		end

		return function()
			springRef.current:stop()
			disconnect()
		end
	end, {})

	return value, springRef.current
end

return useSpring
