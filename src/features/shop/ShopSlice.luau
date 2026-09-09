local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local MonetizationServiceUtils = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceUtils)
local atom = Charm.atom

type Atom<T> = Charm.Atom<T>
type GiftReceivedData = {
	product: MonetizationServiceUtils.MonetizationProduct,
	giftData: MonetizationServiceUtils.GiftData,
}

local giftingProduct: Atom<any?> = atom(nil)
local giftReceivedData: Atom<GiftReceivedData?> = atom(nil)

local actions = {}

return {
	state = {
		giftingProduct = giftingProduct,
		giftReceivedData = giftReceivedData,
	},
	actions = actions,
}
