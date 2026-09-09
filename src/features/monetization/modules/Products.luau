local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MonetizationServiceUtils = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceUtils)
type MonetizationProduct = MonetizationServiceUtils.MonetizationProduct

local products = {
	doubleUnlockSpeed = {
		id = 1704367518,
		giftId = 3532524902,
		isPass = true,
	} :: MonetizationProduct,

	starterPack = {
		id = 1704401477,
		giftId = 3532526931,
		isPass = true,
	} :: MonetizationProduct,

	doubleMoney = {
		id = 1704403366,
		giftId = 3532526815,
		isPass = true,
	} :: MonetizationProduct,

	doubleDamage = {
		id = 1704025700,
		giftId = 3532526673,
		isPass = true,
	} :: MonetizationProduct,

	diamondHunter = {
		id = 1703826017,
		giftId = 3532526534,
		isPass = true,
	} :: MonetizationProduct,

	goldHunter = {
		id = 1704067647,
		giftId = 3532526375,
		isPass = true,
	} :: MonetizationProduct,

	fastConveyor = {
		id = 1704474361,
		giftId = 3532526228,
		isPass = true,
	} :: MonetizationProduct,

	doubleCrates = {
		id = 1704291427,
		giftId = 3532525858,
		isPass = true,
	} :: MonetizationProduct,

	tripleCrates = {
		id = 1704095646,
		giftId = 3532526057,
		isPass = true,
	} :: MonetizationProduct,

	ultraLuck = {
		id = 1704275544,
		giftId = 3532524696,
		isPass = true,
	} :: MonetizationProduct,

	superLuck = {
		id = 1704321547,
		giftId = 3532524696,
		isPass = true,
	} :: MonetizationProduct,

	currency1 = {
		id = 3534567556,
	} :: MonetizationProduct,

	currency2 = {
		id = 3534567655,
	} :: MonetizationProduct,

	currency3 = {
		id = 3534567812,
	} :: MonetizationProduct,

	insta1 = {
		id = 3534504112,
	} :: MonetizationProduct,

	insta2 = {
		id = 3534504181,
	} :: MonetizationProduct,

	insta3 = {
		id = 3534504265,
	} :: MonetizationProduct,

	insta4 = {
		id = 3534504356,
	} :: MonetizationProduct,

	insta5 = {
		id = 3534504433,
	} :: MonetizationProduct,

	insta6 = {
		id = 3534504501,
	} :: MonetizationProduct,

	insta7 = {
		id = 3534504617,
	} :: MonetizationProduct,

	insta8 = {
		id = 3534504724,
	} :: MonetizationProduct,

	insta9 = {
		id = 3534504808,
	} :: MonetizationProduct,

	insta10 = {
		id = 3534504893,
	} :: MonetizationProduct,

	crate1 = {
		id = 3534576125,
	} :: MonetizationProduct,

	crate2 = {
		id = 3534576195,
	} :: MonetizationProduct,

	crate3 = {
		id = 3534576263,
	} :: MonetizationProduct,

	crate4 = {
		id = 3534576417,
	} :: MonetizationProduct,

	crate5 = {
		id = 3534576506,
	} :: MonetizationProduct,

	crate6 = {
		id = 3534576601,
	} :: MonetizationProduct,

	crate7 = {
		id = 3534576698,
	} :: MonetizationProduct,

	crate8 = {
		id = 3534576761,
	} :: MonetizationProduct,

	crate9 = {
		id = 3534576814,
	} :: MonetizationProduct,

	luckyBlock1 = {
		id = 3534681159,
		giftId = 3534681227,
		random = true,
	} :: MonetizationProduct,

	luckyBlock2 = {
		id = 3534681555,
		giftId = 3534681611,
		random = true,
	} :: MonetizationProduct,

	luckyBlock3 = {
		id = 3534681871,
		giftId = 3534681812,
		random = true,
	} :: MonetizationProduct,

	threeLuckyBlock1 = {
		id = 3534681390,
		random = true,
	} :: MonetizationProduct,

	threeLuckyBlock2 = {
		id = 3534681726,
		random = true,
	} :: MonetizationProduct,

	threeLuckyBlock3 = {
		id = 3534681979,
		random = true,
	} :: MonetizationProduct,

	recoverCrate = {
		id = 3535143477,
	} :: MonetizationProduct,

	pyramidiumTower = {
		id = 3535178179,
		giftId = 3535178260,
	} :: MonetizationProduct,

	eradicatorTower = {
		id = 3535225657,
		giftId = 3535225729,
	} :: MonetizationProduct,

	overdriveTower = {
		id = 3535757314,
		giftId = 3535757380,
	} :: MonetizationProduct,
}

return products -- :: { [keyof<typeof(products)>]: MonetizationProduct }
