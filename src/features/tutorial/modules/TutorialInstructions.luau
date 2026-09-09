local instructions = {
	clickConveyorSpawn = {
		text = "Spawn your first crate",
		poi = {
			tag = "ConveyorSpawner",
			beamOffset = CFrame.identity,
			arrowOffset = CFrame.Angles(math.rad(45), math.rad(90), math.rad(90))
				* CFrame.new(5, -1, 2)
				* CFrame.Angles(0, math.rad(-15), 0),
		},
	},

	buyCrate = {
		text = "Buy the crate",
		poi = {
			tag = "TutorialCrate",
			beamOffset = CFrame.identity,
			arrowOffset = CFrame.new(0, 8, 0) * CFrame.Angles(math.rad(90), math.rad(90), 0),
		},
	},

	placeCrate = {
		text = "Place the crate",
		poi = {
			tag = "TutorialNode",
			beamOffset = CFrame.identity,
			arrowOffset = CFrame.new(0, 8, 0) * CFrame.Angles(math.rad(90), math.rad(90), 0),
		},
	},

	waitForCrateTimer = {
		text = "Wait and open the crate",
		waitTime = 4,
	},

	openCrate = {
		text = "Open the crate",
		poi = {
			tag = "TutorialNode",
			beamOffset = CFrame.identity,
			arrowOffset = CFrame.new(0, 8, 0) * CFrame.Angles(math.rad(90), math.rad(90), 0),
		},
	},

	stopBrainrots = {
		text = "Earn $100 by stopping brainrots",
	},

	upgradeTower = {
		text = "Upgrade your tower",
		poi = {
			tag = "TutorialUpgrader",
			beamOffset = CFrame.identity,
			arrowOffset = CFrame.new(-3, 4.5, 0)
				* CFrame.Angles(math.rad(90), math.rad(90), 0)
				* CFrame.Angles(0, math.rad(35), 0),
		},
	},

	repeatHaveFun = {
		text = "Repeat and have fun",
		waitTime = 4,
	},
}

return instructions
