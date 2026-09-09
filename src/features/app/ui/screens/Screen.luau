local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local useSpring = require(ReplicatedStorage.Source.Core.UI.Hooks.useSpring)
local e = React.createElement

local openedScreen = Charm.atom(nil :: string?)

local function setOpenedScreen(screenName: string?)
	openedScreen(screenName)
end

type ScreenProps = {
	screenName: string,
	children: React.ReactNode?,
}

local function Screen(props: ScreenProps)
	local isOpen = ReactCharm.useAtom(function()
		return openedScreen() == props.screenName
	end)

	if isOpen then
		return nil
	end

	return e(React.Fragment, nil, props.children)
end

local function useScreenSpring(screenName: string)
	local binding, spring =
		useSpring(if openedScreen() == screenName then 1 else 0, { frequency = 3, dampingRatio = 0.7 })

	React.useEffect(function()
		return Charm.subscribe(openedScreen, function(newScreen)
			if newScreen == screenName then
				spring:setGoal(1)
			else
				spring:setGoal(0)
			end
		end)
	end, {})

	return binding
end

return {
	openedScreen = openedScreen,
	setOpenedScreen = setOpenedScreen,
	Component = Screen,
	useScreenSpring = useScreenSpring,
}
