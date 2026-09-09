local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local TutorialSteps = require(script.Parent.TutorialSteps)
local Networker = require(ReplicatedStorage.Packages.Networker)
local TutorialInstructions = require(ReplicatedStorage.Source.Features.Tutorial.Modules.TutorialInstructions)

local TutorialServiceClient = {}

function TutorialServiceClient.init(self: TutorialServiceClient)
	self.networker = Networker.client.new("TutorialService", self)
	self.instructionJanitor = Janitor.new()

	local tutorialInfo = DataService:get("tutorial")
	if tutorialInfo.completed then
		return
	end

	DataService:getChangedSignal({ "tutorial", "step" }):Connect(function(step: string)
		self:instruct(step)
	end)

	self:nextStep("joinInit")
end

local function getRootAttachment(): Attachment
	local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart"):WaitForChild("RootAttachment")
end

function TutorialServiceClient.instruct(self: TutorialServiceClient, step: string): ()
	self.instructionJanitor:Cleanup()
	local instructions = TutorialInstructions[step]
	if not instructions then
		return
	end

	if instructions.waitTime then
		self.instructionJanitor:Add(task.delay(instructions.waitTime, function()
			self:nextStep(step)
		end))
	end

	if step == "stopBrainrots" then
		self.instructionJanitor:Add(DataService:getChangedSignal("currency"):Connect(function(newCurrency: number)
			if newCurrency >= 100 then
				self:nextStep(step)
			end
		end))
	end

	if not instructions.poi then
		return
	end

	local partJanitor = Janitor.new()
	self.instructionJanitor:Add(partJanitor)

	local function partAdded(part: BasePart)
		partJanitor:Cleanup()

		local attach = Instance.new("Attachment")
		attach.Parent = part
		partJanitor:Add(attach)

		local beam = ReplicatedStorage.Assets.VFX.ArrowGuideBeam:Clone() :: Beam
		beam.Attachment1 = attach
		beam.Parent = workspace
		partJanitor:Add(beam)

		local rootAttachment = getRootAttachment()
		beam.Attachment0 = rootAttachment
		partJanitor:Add(Players.LocalPlayer.CharacterAdded:Connect(function()
			beam.Attachment0 = getRootAttachment()
		end))

		local pointer = ReplicatedStorage.Assets.VFX.Pointer:Clone() :: BasePart
		pointer.Parent = workspace
		partJanitor:Add(pointer)

		--make pointer bob
		local d = 0
		partJanitor:Add(RunService.Heartbeat:Connect(function(dt: number)
			d += dt * 3
			local cf = part:GetPivot() * instructions.poi.arrowOffset
			pointer.CFrame = cf * CFrame.new(0.6 * math.sin(d), 0, 0)
		end))
	end

	for _, instance in CollectionService:GetTagged(instructions.poi.tag) do
		partAdded(instance)
	end

	self.instructionJanitor:Add(CollectionService:GetInstanceAddedSignal(instructions.poi.tag):Connect(partAdded))
end

function TutorialServiceClient.nextStep(self: TutorialServiceClient, currentStep: string): ()
	if self:hasCompletedTutorial() then
		return
	end

	local nextStep = TutorialSteps[currentStep].nextStep
	local actualCurrentStep = DataService:get({ "tutorial", "step" })
	if nextStep and actualCurrentStep == currentStep then
		self:setStep(nextStep)
	end
end

function TutorialServiceClient.setStep(self: TutorialServiceClient, step: string): ()
	local old = DataService:get({ "tutorial", "step" })
	DataService:set({ "tutorial", "step" }, step)
	if step == "complete" then
		DataService:set({ "tutorial", "completed" }, true)
	end
	self.networker:fire("changeStep", step, old)
end

function TutorialServiceClient.getStep(self: TutorialServiceClient): string?
	if self:hasCompletedTutorial() then
		return nil
	end

	return DataService:get({ "tutorial", "step" })
end

function TutorialServiceClient.hasCompletedTutorial(_self: TutorialServiceClient): boolean
	return DataService:get("tutorial").completed
end

type TutorialServiceClient = typeof(TutorialServiceClient) & {
	networker: Networker.Client,
	instructionJanitor: Janitor.Janitor,
}

return TutorialServiceClient :: TutorialServiceClient
