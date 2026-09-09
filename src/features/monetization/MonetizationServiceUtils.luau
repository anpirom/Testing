export type GiftData = {
	fromUserId: number,
	productKey: string,
	date: number,
}

export type MonetizationProduct = {
	id: number,
	key: string?,
	giftId: number?,
	isPass: boolean?,
	oneTimePurchase: boolean?,
	purchaseCooldown: number?,
	random: boolean?,
	disabled: boolean?,
	callback: ((Player) -> ())?,
}

export type Gamepasses = {
	[number]: boolean?,
}

return nil
