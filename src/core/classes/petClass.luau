local pet = {}
pet.__index = pet

local renderClient = require("@game/ReplicatedStorage/Source/Features/Pet/renderClient") :: typeof(require("@game/ReplicatedStorage/Source/Features/Pet/renderClient"))

type VisibilityState = "All" | "Player" | "None"
type Player = typeof(game:GetService("Players"))

export type petProps = {
    owner: Player,
    ModelName: string,
    damage: number,
    displayName: string,
    VisibilityState: VisibilityState,
}

export type Pet = petProps & {
    name: string,
    Damage: number,
    model: Model?,
    level: number?,
}

function pet.new(prop: petProps): Pet
    local self = setmetatable({} :: Pet,pet)
    self.owner = prop.owner
    self.name = prop.displayName
    self.Damage = prop.damage
    self.VisibilityState = prop.VisibilityState
    self.model = game.ServerStorage.pets:FindFirstChild(prop.ModelName):Clone()
    self:renderClient(prop.owner,false)
    return self
end

function pet:renderClient(player: Player,isRerendering: boolean)
    local Render = renderClient.StartLogic(player,self.model,self.VisibilityState,isRerendering)
    Render:Spawn()
end

function pet:ChangeDamage(newDamage: number): Pet
    self.Damage = newDamage
    return self
end

function pet:ChangeName(newName: string,reRender: boolean,changeModel: boolean): Pet
    self.name = newName
    if changeModel then self:ChangeModel(newName,false,false) end
    if reRender then self:renderClient(self.owner,true) end
    return self
end

function pet:ChangeModel(newModel: string,reRender: boolean,changeName: boolean): Pet
    if changeName then self.name = newModel end
    if reRender then self:renderClient(self.owner,true) end
    return self
end

function pet:ChangeVisibilityState(newVisibilityState: VisibilityState): Pet
    if newVisibilityState == self.VisibilityState then return self end
    self.VisibilityState = newVisibilityState
    self:renderClient(self.owner,true)
    return self
end

function pet:ChangeLevel(newLevel: number): Pet
    self.level = newLevel
    return self
end

function pet:getDamage(): number
    return self.Damage
end

function pet:getName(): string
    return self.name
end

function pet:getModel(): string?
    return tostring(self.model)
end

function pet:getVisibilityState(): VisibilityState
    return self.VisibilityState
end

function pet:Destroy()
    warn("destroing")
    table.clear(self)
    table.freeze(self)
end

return pet