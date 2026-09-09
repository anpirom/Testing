type IncompleteStep = {
	nextStep: string,
	num: any,
}

type Step = IncompleteStep & {
	num: number,
}

local steps = {
	joinInit = {
		nextStep = "clickConveyorSpawn",
	},

	clickConveyorSpawn = {
		nextStep = "buyCrate",
	},

	buyCrate = {
		nextStep = "placeCrate",
	},

	placeCrate = {
		nextStep = "waitForCrateTimer",
	},

	waitForCrateTimer = {
		nextStep = "openCrate",
	},

	openCrate = {
		nextStep = "stopBrainrots",
	},

	stopBrainrots = {
		nextStep = "upgradeTower",
	},

	upgradeTower = {
		nextStep = "repeatHaveFun",
	},

	repeatHaveFun = {
		nextStep = "complete",
	},

	complete = {},
}

-- calc stepNums
local step = "joinInit"
local num = 1

while step do
	steps[step].num = num
	step = steps[step].nextStep
	num += 1
end

return steps :: { [string]: Step }
