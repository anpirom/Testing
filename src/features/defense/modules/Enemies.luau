local ReplicatedStorage = game:GetService("ReplicatedStorage")
export type EnemyStats = {
	health: number,
	speed: number,
	size: number,
	x: number,
	type: string,
}

export type EnemyInfo = {
	name: string,
	animationId: number,
	color: Color3,
	animation: Animation,
	chachedModel: Model?,
}

local HP_SCALAR = 0.08
local BASE_REWARD = 20

local enemyTypes = {
	normal = {
		health = 100,
		speed = 6,
		size = 1,
		odds = 0.7,
	},

	fast = {
		health = 35,
		speed = 14,
		size = 0.75,
		odds = 0.2,
	},

	tank = {
		health = 300,
		speed = 3,
		size = 1.5,
		odds = 0.1,
	},
}

local enemies = {
	[1] = {
		name = "TungTungSahur",
		animationId = 103703750011723,
		color = Color3.fromRGB(255, 187, 0),
	},
	[2] = {
		name = "BrrPatapim",
		animationId = 72693997832193,
		color = Color3.fromRGB(51, 255, 0),
	},
	[3] = {
		name = "OdinDinDinDun",
		animationId = 80432333248969,
		color = Color3.fromRGB(255, 202, 57),
	},
	[4] = {
		name = "CapuccinoAssassino",
		animationId = 77880126445782,
		color = Color3.fromRGB(255, 255, 255),
	},
	[5] = {
		name = "SalaminoPinguino",
		animationId = 120123383140042,
		color = Color3.fromRGB(255, 14, 46),
	},
	[6] = {
		name = "VacaSaturnoSaturnita",
		animationId = 128214391995141,
		color = Color3.fromRGB(14, 247, 255),
	},
	[7] = {
		name = "BananitaDolfinita",
		animationId = 88123928750857,
		color = Color3.fromRGB(255, 212, 71),
	},
	[8] = {
		name = "StrawberryFlamingelli",
		animationId = 87078499386846,
		color = Color3.fromRGB(255, 71, 215),
	},
	[9] = {
		name = "BombardiniGusini",
		animationId = 81407221314243,
		color = Color3.fromRGB(54, 32, 32),
	},
	[10] = {
		name = "BallerinaCapuccina",
		animationId = 95181051711588,
		color = Color3.fromRGB(251, 146, 255),
	},
	[11] = {
		name = "IlCactoHipopotamo",
		animationId = 70892960329725,
		color = Color3.fromRGB(172, 255, 64),
	},
	[12] = {
		name = "LosTralaleritos",
		animationId = 96082161510461,
		color = Color3.fromRGB(64, 169, 255),
	},
	[13] = {
		name = "FrigoCamelo",
		animationId = 136071309049047,
		color = Color3.fromRGB(146, 71, 0),
	},
	[14] = {
		name = "GlorboFruttodrillo",
		animationId = 114962970557632,
		color = Color3.fromRGB(145, 255, 0),
	},
	[15] = {
		name = "TralaleroTralala",
		animationId = 93862466163278,
		color = Color3.fromRGB(0, 204, 255),
	},
	[16] = {
		name = "GaramaAndMadundung",
		animationId = 134152742513729,
		color = Color3.fromRGB(255, 212, 133),
	},
	[17] = {
		name = "TrippiTroppi",
		animationId = 96655063955227,
		color = Color3.fromRGB(255, 115, 0),
	},
	[18] = {
		name = "EspressonaSignora",
		animationId = 87106164681980,
		color = Color3.fromRGB(192, 143, 104),
	},
	[19] = {
		name = "BombardinoCrocodilo",
		animationId = 74368371830033,
		color = Color3.fromRGB(129, 184, 0),
	},
	[20] = {
		name = "RhinoToasterino",
		animationId = 87874378107412,
		color = Color3.fromRGB(199, 222, 228),
	},
	[21] = {
		name = "PipiAvocado",
		animationId = 77241092729421,
		color = Color3.fromRGB(1, 255, 86),
	},
	[22] = {
		name = "TrulimeroTrulichina",
		animationId = 134929164842130,
		color = Color3.fromRGB(255, 238, 1),
	},
	[23] = {
		name = "BonecaAmbalabu",
		animationId = 74419931062388,
		color = Color3.fromRGB(1, 255, 56),
	},
	[24] = {
		name = "GangsterFootera",
		animationId = 86184010029416,
		color = Color3.fromRGB(255, 248, 183),
	},
	[25] = {
		name = "FrulliFrulla",
		animationId = 73325104590147,
		color = Color3.fromRGB(255, 187, 0),
	},
	[26] = {
		name = "ChimpanziniBananini",
		animationId = 88773317020913,
		color = Color3.fromRGB(255, 217, 111),
	},
	[27] = {
		name = "SvininoBombondino",
		animationId = 117712281351170,
		color = Color3.fromRGB(255, 192, 216),
	},
	[28] = {
		name = "LiriliLarila",
		animationId = 86252438711820,
		color = Color3.fromRGB(0, 255, 0),
	},
	[29] = {
		name = "OrcaleroOrcala",
		animationId = 137665444254698,
		color = Color3.fromRGB(255, 255, 255),
	},
	[30] = {
		name = "TaTaTaSahur",
		animationId = 120107844136432,
		color = Color3.fromRGB(255, 81, 0),
	},
}

local Enemies = {}

local function rollStrengthMultiplier(): number
	local x = math.random()
	local n = math.clamp(1 + 0.33 * x + (x + 0.05) ^ 30, 1, 5)
	return if math.random() < 0.5 then n else 1 / n
end

local function rollEnemyType(): string
	local roll = math.random()
	local cumulative = 0
	for enemyType, data in enemyTypes do
		cumulative += data.odds
		if roll <= cumulative then
			return enemyType
		end
	end
	return "normal"
end

local function getEnemyStats(x: number, enemyType: string): EnemyStats
	local base = enemyTypes[enemyType]
	return {
		health = math.round(base.health * HP_SCALAR * 2 ^ x),
		speed = base.speed,
		size = base.size,
		x = x,
		type = enemyType,
	}
end

function Enemies.getEnemyForStrength(strength: number): EnemyStats
	local damper = math.clamp(0.5 + (strength / 1000), 0.5, 1)
	local mult = rollStrengthMultiplier()
	strength *= mult * damper
	local x = math.max(1, math.round(math.log(strength / 4, 2)))
	local enemyType = rollEnemyType()
	return getEnemyStats(x, enemyType)
end

function Enemies.getEnemyReward(maxHp: number, rebirths: number, ownsStarterPack: boolean, numFriends: number): number
	local multiplier = 1 + rebirths * 0.1 + numFriends * 0.1
	if ownsStarterPack then
		multiplier += 0.1
	end
	return (maxHp + BASE_REWARD) * multiplier
end

function Enemies.getIndexFromX(x: number): number
	return x % #enemies + 1
end

function Enemies.getEnemyInfo(index: number)
	return enemies[Enemies.getIndexFromX(index - 1)]
end

function Enemies.getEnemyModel(index: number, enemyType: string): Model
	local info = enemies[Enemies.getIndexFromX(index - 1)]
	if info.chachedModel then
		local scale = enemyTypes[enemyType].size
		local model = info.chachedModel:Clone() :: Model
		model:ScaleTo(model:GetScale() * scale * 0.66)
		return model
	end

	local model = ReplicatedStorage.Assets.Enemies:FindFirstChild(info.name):Clone() :: Model
	if model:FindFirstChild("InitialPoses") then
		model.InitialPoses:Destroy()
	end

	if model:FindFirstChild("AnimSaves") then
		model.AnimSaves:Destroy()
	end

	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.CanCollide = false
			part.CastShadow = false
		end
	end

	local mesh = model.PrimaryPart :: MeshPart
	local cf: CFrame = model:GetPivot()
	local rootCf: CFrame = CFrame.new(cf.X, 0.5, cf.Z)
	local root = Instance.new("Part")
	root.Name = "Root"
	root.Size = Vector3.new(1, 1, 1)
	root.CanCollide = false
	root.Transparency = 1
	root.CFrame = rootCf
	root.Anchored = true
	root.Parent = model
	model.PrimaryPart = root

	local attachment = Instance.new("Attachment")
	attachment.Name = "RootAttachment"
	attachment.Parent = mesh

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://" .. info.animationId
	animation.Name = info.name
	animation.Parent = ReplicatedStorage.Assets.Animations.Enemies

	local healthBillboard = ReplicatedStorage.Assets.Misc.EnemyHealthBillboard:Clone()
	healthBillboard.Parent = model
	healthBillboard.Adornee = mesh

	info.animation = animation
	info.chachedModel = model

	return Enemies.getEnemyModel(index, enemyType)
end

return Enemies
