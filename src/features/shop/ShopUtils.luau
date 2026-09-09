local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Towers = require(ReplicatedStorage.Source.Features.Defense.Modules.Towers)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local MonetizationServiceUtils = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceUtils)
local RebirthUtils = require(ReplicatedStorage.Source.Features.Plots.Modules.RebirthUtils)
local ShopUtils = {}

local MINUTE = 60
local HOUR = 60 * MINUTE
local instaOpenProducts = {
	MINUTE,
	5 * MINUTE,
	15 * MINUTE,
	30 * MINUTE,
	45 * MINUTE,
	60 * MINUTE,
	90 * MINUTE,
	2 * HOUR,
	3 * HOUR,
	5 * HOUR,
}

local CURENCY_TIER_MULTIPLIERS = { 0.3, 1.27, 5.1 }

function ShopUtils.getInstaOpenTimeFromN(n: number): number
	return instaOpenProducts[n]
end

function ShopUtils.getProductFromTimeRemaining(
	timeRemaining: number
): (MonetizationServiceUtils.MonetizationProduct?, number?)
	if timeRemaining <= 5 then
		return
	end

	for i, t in instaOpenProducts do
		if timeRemaining <= t then
			return Products["insta" .. i], i
		end
	end

	return Products.insta10, 10
end

function ShopUtils.getProductFromConveyorCrate(
	rebirths: number,
	crateId: string
): (MonetizationServiceUtils.MonetizationProduct, number)
	local rebirthCost = RebirthUtils.getRebirthCost(rebirths)
	local crateCost = Towers.getTowerInfo(crateId).crateCost
	local n = math.log(1 + crateCost / rebirthCost, 2) + 0.5
	n = math.clamp(math.ceil(n), 1, 9)
	return Products["crate" .. n], n
end

function ShopUtils.getCurrencyAmtFromRebirth(tier: number, rebirths: number): number
	local rebirthCost = RebirthUtils.getRebirthCost(rebirths)
	local tierMultiplier = CURENCY_TIER_MULTIPLIERS[tier]
	return math.floor(rebirthCost * tierMultiplier)
end

return ShopUtils
