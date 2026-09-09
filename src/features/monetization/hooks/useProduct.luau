local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local MonetizationServiceClient = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceClient)
local MonetizationServiceUtils = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceUtils)
type Product = MonetizationServiceUtils.MonetizationProduct

return function(product: Product)
	local value, setValue = React.useState(product)

	React.useEffect(function()
		local conn = MonetizationServiceClient:getProductInfoChangedSignal(product):Connect(function()
			setValue(table.clone(product))
		end)

		return function()
			conn:Disconnect()
		end
	end, { product })

	return value
end
