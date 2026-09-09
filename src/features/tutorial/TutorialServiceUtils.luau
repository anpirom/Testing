local TutorialSteps = require(script.Parent.TutorialSteps)

local TutorialServiceUtils = {}

function TutorialServiceUtils.getStepNumFromStep(step: string): number
	local num = TutorialSteps[step].num
	return num
end

function TutorialServiceUtils.isValidStep(step: string?): boolean
	return step ~= nil and type(step) == "string" and TutorialSteps[step] ~= nil
end

return TutorialServiceUtils
