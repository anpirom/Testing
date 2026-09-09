local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local MonetizationServiceClient = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceClient)
local MonetizationServiceUtils = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceUtils)
type Product = MonetizationServiceUtils.MonetizationProduct

return function(product: Product): boolean
	local owns, setOwns = React.useState(MonetizationServiceClient:ownsGamepass(product :: any))

	React.useEffect(function()
		local conn = MonetizationServiceClient:getProductInfoChangedSignal(product):Connect(function()
			setOwns(MonetizationServiceClient:ownsGamepass(product :: any))
		end)

		return function()
			conn:Disconnect()
		end
	end, { product })

	return owns
end
