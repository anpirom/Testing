local AnalyticsService = game:GetService("AnalyticsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).server
local Networker = require(ReplicatedStorage.Packages.Networker)
local ServicePlayerData = require(ReplicatedStorage.Packages.ServicePlayerData)
local TutorialServiceUtils = require(ReplicatedStorage.Source.Features.Tutorial.TutorialServiceUtils)

local TutorialServiceServer = {}

function TutorialServiceServer.init(self: TutorialServiceServer)
	self.networker = Networker.server.new("TutorialService", self, { self.changeStep })
	self.playerData = ServicePlayerData.new({}, self)
end

function TutorialServiceServer:playerRemoving(player: Player)
	if not self:hasCompletedTutorial(player) then
		DataService:set(player, { "tutorial", "completed" }, true)
	end
end

function TutorialServiceServer:playerAdded(player: Player)
	DataService:waitForData(player)
	DataService:getChangedSignal(player, "rebirths"):Connect(function(rebirths: number)
		AnalyticsService:LogFunnelStepEvent(player, "rebirths", nil, math.clamp(rebirths, 1, 99))
	end)
end

function TutorialServiceServer:hasCompletedTutorial(player: Player): boolean
	return DataService:get(player, { "tutorial", "completed" })
end

function TutorialServiceServer.changeStep(
	self: TutorialServiceServer,
	player: Player,
	completedStep: string,
	currentStep: string
): ()
	if self:hasCompletedTutorial(player) or not TutorialServiceUtils.isValidStep(completedStep) then
		return
	end

	DataService:set(player, { "tutorial", "step" }, currentStep, true)

	local stepNum = TutorialServiceUtils.getStepNumFromStep(completedStep)
	AnalyticsService:LogOnboardingFunnelStepEvent(player, stepNum, completedStep)

	if currentStep == "complete" then
		DataService:set(player, { "tutorial", "completed" }, true, true)
	end
end

function TutorialServiceServer:getStep(player: Player): string
	return DataService:get(player, { "tutorial", "step" })
end

type TutorialServiceServer = typeof(TutorialServiceServer) & {
	networker: Networker.Server,
	playerData: ServicePlayerData.ServicePlayerData<{}>,
}

return TutorialServiceServer :: TutorialServiceServer
