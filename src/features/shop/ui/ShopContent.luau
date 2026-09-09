local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ShopCodes = require(ReplicatedStorage.Source.Features.Shop.UI.Frames.ShopCodes)
local ShopCurrency = require(ReplicatedStorage.Source.Features.Shop.UI.Frames.ShopCurrency)
local ShopGamepasses = require(ReplicatedStorage.Source.Features.Shop.UI.Frames.ShopGamepasses)
local ShopLimitedItems = require(ReplicatedStorage.Source.Features.Shop.UI.Frames.ShopLimitedItems)
local ShopPacks = require(ReplicatedStorage.Source.Features.Shop.UI.Frames.ShopPacks)
local e = React.createElement

return function()
	return e(React.Fragment, nil, {
		Gamepasses = e(ShopGamepasses),
		Packs = e(ShopPacks),
		LimitedItems = e(ShopLimitedItems),
		Currency = e(ShopCurrency),
		Codes = e(ShopCodes),
	})
end
