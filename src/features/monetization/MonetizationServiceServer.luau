local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local Networker = require(ReplicatedStorage.Packages.Networker)
local ServicePlayerData = require(ReplicatedStorage.Packages.ServicePlayerData)
local Signal = require(ReplicatedStorage.Packages.Signal)
local MonetizationServiceUtils = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceUtils)

type GiftData = MonetizationServiceUtils.GiftData
type MonetizationProduct = MonetizationServiceUtils.MonetizationProduct
type MonetizationOptions = {
	products: { [string]: MonetizationProduct },
	groupId: number?,
	freePassesGroupRank: number?,
	canAwardGamepasses: boolean?,
}

type ReceiptInfo = {
	PurchaseId: string,
	PlayerId: number,
	ProductId: number,
	PlaceIdWherePurchased: number,
	CurrencySpent: number,
	CurrencyType: string,
}

local PLAYER_DATA_TEMPLATE = {
	giftingTo = nil :: number?,
}
type PlayerData = typeof(PLAYER_DATA_TEMPLATE)

local GAMEPASS_DATA_KEY = "__gamepasses"
local ONE_TIME_PURCHASES_DATA_KEY = "__oneTimePurchases"
local PURCHASE_COOLDOWNS_KEY = "__purchaseCooldowns"
local GIFT_RECEIVER_DATA_KEY = "__giftReceiver"
local GIFT_GLOBAL_CALLBACK_KEY = "gift"

local MonetizationServiceServer = {
	gamePassAwarded = Signal.new(),
	productProcessed = Signal.new(),
}

function MonetizationServiceServer.init(self: MonetizationService, options: MonetizationOptions): ()
	self.options = options
	self.networker = Networker.server.new("MonetizationService", self, { self.promptGift })
	self.playerData = ServicePlayerData.new(PLAYER_DATA_TEMPLATE, self)

	for key, product in options.products do
		product.key = key
	end

	DataService:addGlobalCallback(GIFT_GLOBAL_CALLBACK_KEY, function(player: Player, data: GiftData)
		return self:receiveGift(player, data)
	end)

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(
		function(player: Player, gamepassId: number, wasPurchased: boolean)
			if
				not wasPurchased
				or self.options.canAwardGamepasses == false
				or self:ownsGamepass(player, gamepassId)
			then
				return
			end

			self:awardGamepass(player, gamepassId)
		end
	)

	MarketplaceService.ProcessReceipt = function(receiptInfo: ReceiptInfo)
		local result = self:_processDeveloperProduct(receiptInfo)
		local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if player then
			self.playerData:get(player).giftingTo = nil
		end
		return result
	end

	MarketplaceService.PromptProductPurchaseFinished:Connect(
		function(userId: number, _productId: number, _wasPurchased: boolean)
			local player = Players:GetPlayerByUserId(userId)
			if player then
				self.playerData:get(player).giftingTo = nil
			end
		end
	)
end

function MonetizationServiceServer.playerAdded(self: MonetizationService, player: Player): ()
	DataService:waitForData(player)
	DataService:set(player, GIFT_RECEIVER_DATA_KEY, nil)
	if self.options.canAwardGamepasses == false then
		return
	end

	local groupRank = 0
	if self.options.groupId then
		pcall(function()
			groupRank = player:GetRankInGroupAsync(self.options.groupId)
		end)
	end

	local qualifiesForFreePasses = self.options.freePassesGroupRank and groupRank >= self.options.freePassesGroupRank

	for _, product in self.options.products do
		if product.disabled or not product.isPass then
			continue
		end

		local gamepassId = product.id
		local alreadyOwns = self:ownsGamepass(player, gamepassId)
		if alreadyOwns then
			continue
		end

		local owns = qualifiesForFreePasses or self:ownsGamepassAsync(player.UserId, gamepassId)
		if owns then
			self:awardGamepass(player, gamepassId)
		end
	end
end

function MonetizationServiceServer.getProductFromId(self: MonetizationService, productId: number): MonetizationProduct?
	for _, product in self.options.products do
		if product.id == productId or product.giftId == productId then
			return product
		end
	end
	return nil
end

function MonetizationServiceServer.awardGamepass(self: MonetizationService, player: Player, gamepassId: number): ()
	local product = self:getProductFromId(gamepassId)
	if not product then
		warn("No product for gamepass id", gamepassId)
		return
	end

	assert(product.isPass, "Product is not a gamepass: " .. product.key)

	self:getGamePasses(player) -- ensure table exists
	DataService:set(player, { GAMEPASS_DATA_KEY, tostring(gamepassId) }, true)

	local callback = product.callback
	if callback then
		local success, result = pcall(callback, player)
		if not success then
			warn("Failed to process gamepass callback for product", product.key, result)
			return
		end
	end

	self.gamePassAwarded:Fire(player, product)
end

function MonetizationServiceServer.isProductIdGift(self: MonetizationService, productId: number): boolean
	local product = self:getProductFromId(productId)
	if not product then
		return false
	end
	return product.giftId == productId
end

function MonetizationServiceServer:getGamePasses(player: Player): { [string]: boolean? }
	local gamepasses: { [string]: boolean? } = DataService:get(player, GAMEPASS_DATA_KEY)
	if not gamepasses then
		gamepasses = {}
		DataService:set(player, GAMEPASS_DATA_KEY, gamepasses)
	end
	return gamepasses
end

function MonetizationServiceServer.receiveGift(self: MonetizationService, player: Player, data: GiftData): ()
	self.networker:fire(player, "_receivedGift", data)
	local product = self.options.products[data.productKey]
	assert(product, "No product for product key " .. data.productKey)

	if product.isPass then
		self:awardGamepass(player, product.id)
		return true
	end

	local callback = product.callback
	if callback then
		local success, result = pcall(callback, player)
		if not success then
			warn("Failed to process gift callback for product", product.key, result)
			return nil
		end
		return result
	end

	return nil
end

function MonetizationServiceServer._attemptLocalGift(
	self: MonetizationService,
	player: Player,
	product: MonetizationProduct
): boolean
	local userId = self.playerData:get(player).giftingTo
	if not userId or player.UserId == userId then
		return false
	end

	local receiver = Players:GetPlayerByUserId(userId)
	if not receiver or not DataService:hasProfile(receiver) then
		return false
	end

	self:receiveGift(receiver, {
		fromUserId = player.UserId,
		productKey = product.key,
		date = os.time(),
	})

	return true
end

function MonetizationServiceServer.promptGift(
	self: MonetizationService,
	player: Player,
	userId: number,
	productId: number
): (boolean, string?)
	local playerData = self.playerData:get(player)
	local isGifting = playerData.giftingTo ~= nil
	if isGifting then
		return false, "Already gifting to someone, please wait."
	end

	local product = self:getProductFromId(productId)
	assert(product, "No product for product id " .. productId)
	if not product.giftId then
		return false, "Product has no gift"
	end

	local receiver = Players:GetPlayerByUserId(userId)
	if not receiver then
		return false, "Receiver not found"
	end

	if receiver == player then
		return false, "Cannot gift to yourself"
	end

	if product.isPass and self:ownsGamepass(receiver, product.id) then
		return false, "Receiver already owns gamepass"
	end

	if product.oneTimePurchase and self:ownsOneTimePurchase(receiver, product) then
		return false, "Receiver already owns one-time purchase"
	end

	if product.purchaseCooldown and not self:canBuyCooldownProduct(receiver, product) then
		return false, "Receiver cannot buy this product yet"
	end

	playerData.giftingTo = userId
	MarketplaceService:PromptProductPurchase(player, product.giftId)
	return true
end

function MonetizationServiceServer.promptProduct(
	self: MonetizationService,
	player: Player,
	product: MonetizationProduct
): (boolean, string?)
	if product.isPass then
		if self:ownsGamepass(player, product) then
			return false, "Already own gamepass"
		end
		MarketplaceService:PromptGamePassPurchase(player, product.id)
		return true
	else
		if product.oneTimePurchase and self:ownsOneTimePurchase(player, product) then
			return false, "Already own one-time purchase"
		end

		if product.purchaseCooldown and not self:canBuyCooldownProduct(player, product) then
			return false, "Cannot buy this product yet"
		end

		MarketplaceService:PromptProductPurchase(player, product.id)
		return true
	end
end

function MonetizationServiceServer._attemptGift(
	self: MonetizationService,
	player: Player,
	product: MonetizationProduct
): boolean
	local giftReceiverUserId: number? = self.playerData:get(player).giftingTo
	assert(giftReceiverUserId, "No gift receiver for player")
	--assert(player.UserId ~= giftReceiverUserId, "Cannot gift to yourself")

	local alreadyOwns = self:ownsGamepassAsync(giftReceiverUserId, product.id)
	if alreadyOwns then
		return false
	end

	return DataService:sendGlobalMessage(GIFT_GLOBAL_CALLBACK_KEY, giftReceiverUserId, {
		fromUserId = player.UserId,
		productKey = product.key,
		date = os.time(),
	})
end

function MonetizationServiceServer.ownsOneTimePurchase(
	_self: MonetizationService,
	player: Player,
	product: MonetizationProduct
): boolean
	local oneTimePurchases = DataService:get(player, ONE_TIME_PURCHASES_DATA_KEY) :: { [string]: boolean }?
	if not oneTimePurchases then
		return false
	end
	return oneTimePurchases[tostring(product.id)] == true
end

function MonetizationServiceServer.canBuyCooldownProduct(
	_self: MonetizationService,
	player: Player,
	product: MonetizationProduct
): boolean
	if not product.purchaseCooldown or product.purchaseCooldown <= 0 then
		return true
	end

	local cooldowns = DataService:get(player, PURCHASE_COOLDOWNS_KEY) :: { [string]: number }?
	if not cooldowns then
		return true
	end

	local lastPurchaseTime = cooldowns[tostring(product.id)]
	if not lastPurchaseTime then
		return true
	end

	local timeSincePurchase = os.time() - lastPurchaseTime
	return timeSincePurchase >= product.purchaseCooldown
end

function MonetizationServiceServer._processDeveloperProduct(
	self: MonetizationService,
	receiptInfo: ReceiptInfo
): Enum.ProductPurchaseDecision
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if not DataService:waitForData(player) then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local id = receiptInfo.ProductId
	local product = self:getProductFromId(id)
	if not product then
		warn("No product for productId", id)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local isGift = self:isProductIdGift(id)
	local oneTimePurchase = product.oneTimePurchase
	if not isGift and oneTimePurchase and self:ownsOneTimePurchase(player, product) then
		warn("Player has already purchased one-time product", product.id)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local hasCooldown = product.purchaseCooldown and product.purchaseCooldown > 0
	if not isGift and hasCooldown and not self:canBuyCooldownProduct(player, product) then
		warn("Player has already purchased time-limited product", product.id)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if product.disabled then
		warn("Product is disabled", id)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local callback
	if isGift then
		callback = function()
			if not self:_attemptLocalGift(player, product) then
				return self:_attemptGift(player, product)
			end
			return true
		end
	else
		callback = product.callback
		if not callback then
			warn("No callback for developer product", product.key)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
	end

	local success, result = pcall(callback, player)
	if not success then
		warn("Failed to process developer product", result)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	--true or nil is fine
	if result == false then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if not isGift and oneTimePurchase then
		if not DataService:get(player, ONE_TIME_PURCHASES_DATA_KEY) then
			DataService:set(player, ONE_TIME_PURCHASES_DATA_KEY, {})
		end
		DataService:set(player, { ONE_TIME_PURCHASES_DATA_KEY, tostring(product.id) }, true)
	end

	if not isGift and hasCooldown then
		if not DataService:get(player, PURCHASE_COOLDOWNS_KEY) then
			DataService:set(player, PURCHASE_COOLDOWNS_KEY, {})
		end
		DataService:set(player, { PURCHASE_COOLDOWNS_KEY, tostring(product.id) }, os.time())
	end

	self.productProcessed:Fire(player, receiptInfo)

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

function MonetizationServiceServer:ownsGamepassAsync(
	userId: number,
	gamepassIdOrProduct: number | MonetizationProduct
): boolean
	local id = if typeof(gamepassIdOrProduct) == "number"
		then gamepassIdOrProduct
		else (gamepassIdOrProduct :: MonetizationProduct).id
	local success, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(userId, id)
	end)
	if not success then
		warn("Failed to check if user owns gamepass", result)
		return false
	end
	return result
end

function MonetizationServiceServer:getPassOwnshipChanged(
	player: Player,
	product: MonetizationProduct
): Signal.Signal<boolean?>
	return DataService:getChangedSignal(player, { GAMEPASS_DATA_KEY, tostring(product.id) })
end

function MonetizationServiceServer.ownsGamepass(
	self: MonetizationService,
	player: Player,
	gamepassIdOrProduct: number | MonetizationProduct
): boolean
	local id = if typeof(gamepassIdOrProduct) == "number"
		then gamepassIdOrProduct
		else (gamepassIdOrProduct :: MonetizationProduct).id
	return self:getGamePasses(player)[tostring(id)] == true
end

type MonetizationService = typeof(MonetizationServiceServer) & {
	networker: Networker.Server,
	options: MonetizationOptions,
	playerData: ServicePlayerData.ServicePlayerData<PlayerData>,
	gamePassAwarded: Signal.Signal<Player, MonetizationProduct>,
	productProcessed: Signal.Signal<Player, ReceiptInfo>,
}

return MonetizationServiceServer :: MonetizationService
