local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BottomBar = require(script.Parent.BottomBar)
local LeftSideBar = require(script.Parent.LeftSideBar)
local TopBar = require(script.Parent.TopBar)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

return function()
	return e(React.Fragment, nil, {
		BottomBar = e(BottomBar),
		LeftSideBar = e(LeftSideBar),
		TopBar = e(TopBar),
	})
end
