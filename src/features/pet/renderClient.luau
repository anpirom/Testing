const Promise = require("../../../Packages/Promise")
const Ripple = require("../../../Packages/Ripple")

local ReC = {}
ReC.__index = ReC

type VisibilityState = "All" | "Player" | "None"
type Player = typeof(game:GetService("Players"))
export type Render = {
    Player: Player,
    Model: Model,
    VisibilityState: VisibilityState,
    DestroyPromise: any,
}

function ReC.StartLogic(ply: Player, model: Model, config: VisibilityState, reRender: boolean): Render
    return setmetatable({
        Player = ply,
        Model = model,
        VisibilityState = config,
        DestroyPromise = nil,
    }, ReC)
end

function ReC:Animate(position: CFrame, scale: number)
    local pivot = self.Model:GetPivot()
    local positionSpring = Ripple.createSpring(pivot, {tension = 190, friction = 18, start = true})
    local scaleSpring = Ripple.createSpring(self.Model:GetScale(), {tension = 200, friction = 18, start = true})

    positionSpring:onChange(function(value) self.Model:PivotTo(value) end)
    scaleSpring:onChange(function(value) self.Model:ScaleTo(math.max(value, 0.001)) end)

    positionSpring:setGoal(position)
    scaleSpring:setGoal(scale)
end

function ReC:Spawn()
    self.Model.Parent = workspace
    self.Model:ScaleTo(0.001)
    self:Animate(self.Model:GetPivot() * CFrame.new(0, 5, -9), 1)

    Promise.delay(1):andThen(function()
        self:Hide()
    end)
end

function ReC:Hide()
    local pivot = self.Model:GetPivot()
    local scaleSpring = Ripple.createSpring(self.Model:GetScale(), {tension = 200, friction = 18, start = true})

    scaleSpring:onChange(function(value)
        self.Model:PivotTo(pivot)
        self.Model:ScaleTo(math.max(value, 0.001))
    end)

    scaleSpring:setGoal(0.001)

    if self.DestroyPromise then
        self.DestroyPromise:cancel()
    end

    self.DestroyPromise = Promise.delay(1):andThen(function()
        if self.Model then
            self:Destroy()
        end
    end)
end

function ReC:Destroy(instant: boolean)
    if self.DestroyPromise then
        self.DestroyPromise:cancel()
        self.DestroyPromise = nil
    end
    if instant then
        self.Model:Destroy()
        return
    end
    warn("destroing")
    table.clear(self)
    table.freeze(self)
end

return ReC