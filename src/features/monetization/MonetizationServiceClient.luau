local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local Networker = require(ReplicatedStorage.Packages.Networker)
local Signal = require(ReplicatedStorage.Packages.Signal)
local FormatTime = require(ReplicatedStorage.Source.Core.UI.FormatTime)
local MonetizationServiceUtils = require(script.Parent.MonetizationServiceUtils)

type GiftData = MonetizationServiceUtils.GiftData
type Product = MonetizationServiceUtils.MonetizationProduct
type MonetizationProduct = Product & {
	_infoUpdated: Signal.Signal<>,
	_productInfo: {
		Name: string,
		Description: string,
		PriceInRobux: number,
		CostText: string,
	},
}
type PolicyInfo = {
	AreAdsAllowed: boolean,
	ArePaidRandomItemsRestricted: boolean,
	AllowedExternalLinkReferences: { string },
	IsContentSharingAllowed: boolean,
	IsEligibleToPurchaseCommerceProduct: boolean,
	IsEligibleToPurchaseSubscription: boolean,
	IsPaidItemTradingAllowed: boolean,
	IsSubjectToChinaPolicies: boolean,
}

type ProductInfo = {
	Name: string,
	Description: string,
	PriceInRobux: number,
	CostText: string,
}

local GAMEPASS_DATA_KEY = "__gamepasses"
local ONE_TIME_PURCHASES_DATA_KEY = "__oneTimePurchases"
local PURCHASE_COOLDOWNS_KEY = "__purchaseCooldowns"
local RETRY_DELAY = 5
local MAX_RETRIES = 5

local player = Players.LocalPlayer
local MonetizationServiceClient = {
	giftReceived = Signal.new(),
	policyInfoChanged = Signal.new(),
	policyInfo = {
		AreAdsAllowed = false,
		ArePaidRandomItemsRestricted = true,
		AllowedExternalLinkReferences = {},
		IsContentSharingAllowed = false,
		IsEligibleToPurchaseCommerceProduct = false,
		IsEligibleToPurchaseSubscription = false,
		IsPaidItemTradingAllowed = false,
		IsSubjectToChinaPolicies = true,
	},
}

local LOADING_PRODUCT_INFO = {
	Name = "Loading",
	Description = "Loading",
	PriceInRobux = 0,
	CostText = "Loading",
}

local UNKNOWN_PRODUCT_INFO = {
	Name = "Unknown",
	Description = "Unknown",
	PriceInRobux = -1,
	CostText = "Unknown",
}

local function getProductInfo(product: MonetizationProduct, retryCount: number?): ProductInfo
	if not RunService:IsRunning() then
		return table.clone(UNKNOWN_PRODUCT_INFO)
	end

	local infoType = if product.isPass then Enum.InfoType.GamePass else Enum.InfoType.Product
	local ok, result = pcall(MarketplaceService.GetProductInfoAsync, MarketplaceService, product.id, infoType)
	if not ok then
		if not retryCount or retryCount < MAX_RETRIES then
			task.wait(RETRY_DELAY)
			retryCount = (retryCount or 0) + 1
			warn("Failed to get product info for product", product.key, "retrying...", result, "attempt", retryCount)
			return getProductInfo(product, retryCount)
		end
		warn("Failed to get product info for product", product.key, "giving up:", result)
		return table.clone(UNKNOWN_PRODUCT_INFO)
	end

	return result
end

function MonetizationServiceClient._initProduct(
	self: MonetizationServiceClient,
	key: string,
	product: MonetizationProduct
): ()
	product.key = key
	product._infoUpdated = Signal.new()
	product._productInfo = table.clone(LOADING_PRODUCT_INFO)
	product._productInfo = getProductInfo(product)

	local function update()
		if
			(product.isPass and self:ownsGamepass(product))
			or (product.oneTimePurchase and self:ownsOneTimePurchase(product))
		then
			product._productInfo.CostText = "Owned"
		elseif product.purchaseCooldown and self:isProductOnCooldown(product) then
			local timeRemaining = self:getProductCooldownRemaining(product)
			product._productInfo.CostText = "Cooldown: " .. FormatTime(timeRemaining)
		elseif product.disabled then
			product._productInfo.CostText = "Disabled"
		elseif product.random and self.policyInfo.ArePaidRandomItemsRestricted then
			product._productInfo.CostText = "Locked"
		else
			product._productInfo.CostText = "\u{E002}" .. tostring(product._productInfo.PriceInRobux)
		end
		product._infoUpdated:Fire()
	end

	update()
	self.policyInfoChanged:Connect(update)
	if product.isPass then
		DataService:getChangedSignal({ GAMEPASS_DATA_KEY, tostring(product.id) }):Connect(update)
	end

	DataService:getChangedSignal(ONE_TIME_PURCHASES_DATA_KEY):Connect(update)
	DataService:getChangedSignal(PURCHASE_COOLDOWNS_KEY):Connect(update)

	if product.purchaseCooldown and product.purchaseCooldown > 0 then
		task.spawn(function()
			while true do
				update()
				task.wait(1)
			end
		end)
	end
end

function MonetizationServiceClient._initProducts(
	self: MonetizationServiceClient,
	products: { [string]: MonetizationProduct }
): ()
	for key, product in products do
		task.spawn(function()
			self:_initProduct(key, product)
		end)
	end
end

function MonetizationServiceClient.init(self: MonetizationServiceClient, products: { [string]: Product }): ()
	self.products = products :: any
	self.networker = Networker.client.new("MonetizationService", self)
	self:_initProducts(products :: any)

	task.spawn(function()
		if not RunService:IsRunning() then
			return
		end

		local ok, result = pcall(PolicyService.GetPolicyInfoForPlayerAsync, PolicyService, player)
		while not ok do
			warn("Failed to get policy info for player:", result)
			task.wait(10)
			ok, result = pcall(PolicyService.GetPolicyInfoForPlayerAsync, PolicyService, player)
		end
		self.policyInfo = result
		self.policyInfoChanged:Fire()
	end)
end

function MonetizationServiceClient._receivedGift(self: MonetizationServiceClient, giftData: GiftData): ()
	local product = self.products[giftData.productKey]
	self.giftReceived:Fire(product, giftData)
end

function MonetizationServiceClient:getProductInfoChangedSignal(product: Product): Signal.Signal<>
	return (product :: MonetizationProduct)._infoUpdated
end

function MonetizationServiceClient.getProductInfo(
	self: MonetizationServiceClient,
	productOrId: Product | number
): ProductInfo
	local product: Product = if typeof(productOrId) == "number"
		then self:getProductFromId(productOrId :: any)
		else productOrId
	return (product :: MonetizationProduct)._productInfo
end

function MonetizationServiceClient:getProductCostString(product: Product): string
	return (product :: MonetizationProduct)._productInfo.CostText
end

function MonetizationServiceClient.getProductFromId(
	self: MonetizationServiceClient,
	productId: number
): MonetizationProduct
	for _, product in self.products do
		if product.id == productId or product.giftId == productId then
			return product
		end
	end
	error("No product for product id " .. productId)
end

function MonetizationServiceClient:ownsOneTimePurchase(product: MonetizationProduct): boolean
	if not product.oneTimePurchase then
		warn("Product is not a one-time purchase:", product.key)
		return false
	end

	local oneTimePurchases = DataService:get(ONE_TIME_PURCHASES_DATA_KEY)
	return oneTimePurchases ~= nil and oneTimePurchases[tostring(product.id)]
end

function MonetizationServiceClient:isProductOnCooldown(product: MonetizationProduct): boolean
	return self:getProductCooldownRemaining(product) > 0
end

function MonetizationServiceClient:getProductCooldownRemaining(product: MonetizationProduct): number
	if not product.purchaseCooldown then
		warn("Product does not have a cooldown:", product.key)
		return 0
	end

	local purchaseCooldowns = DataService:get(PURCHASE_COOLDOWNS_KEY)
	if not purchaseCooldowns then
		return 0
	end

	local purchaseTime = purchaseCooldowns[tostring(product.id)]
	if not purchaseTime then
		return 0
	end

	local timeSincePurchase = workspace:GetServerTimeNow() - purchaseTime
	local remaining = product.purchaseCooldown - timeSincePurchase
	return math.max(0, remaining)
end

function MonetizationServiceClient:ownsGamepass(product: MonetizationProduct): boolean
	local gamepasses = DataService:get(GAMEPASS_DATA_KEY)
	return gamepasses ~= nil and gamepasses[tostring(product.id)]
end

function MonetizationServiceClient.promptProduct(self: MonetizationServiceClient, product: MonetizationProduct): ()
	if product.disabled then
		warn("Product is disabled:", product.key)
		return
	end

	if product.random and self.policyInfo.ArePaidRandomItemsRestricted then
		warn("Cannot purchase random items due to policy restrictions")
		return
	end

	if product.oneTimePurchase and self:ownsOneTimePurchase(product) then
		return
	end

	if product.purchaseCooldown and self:isProductOnCooldown(product) then
		return
	end

	if product.isPass then
		MarketplaceService:PromptGamePassPurchase(player, product.id)
	else
		MarketplaceService:PromptProductPurchase(player, product.id)
	end
end

function MonetizationServiceClient.promptGift(
	self: MonetizationServiceClient,
	userId: number,
	product: MonetizationProduct
): (boolean, string?)
	local s, e = self.networker:fetch("promptGift", userId, product.giftId)
	return s, e
end

type MonetizationServiceClient = typeof(MonetizationServiceClient) & {
	networker: Networker.Client,
	products: { [string]: MonetizationProduct },
	giftReceived: Signal.Signal<(product: MonetizationProduct, giftData: GiftData) -> ()>,
	policyInfo: PolicyInfo,
	policyInfoChanged: Signal.Signal<>,
}

return MonetizationServiceClient :: MonetizationServiceClient
