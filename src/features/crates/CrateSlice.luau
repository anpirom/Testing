local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local atom = Charm.atom

type Atom<T> = Charm.Atom<T>

local crates: Atom<{ [Instance]: string }> = atom({})

local actions = {
	addCrate = function(instance: Instance, crateId: string)
		crates(function(prev)
			return Sift.Dictionary.set(prev, instance, crateId)
		end)
	end,

	removeCrate = function(instance: Instance)
		crates(function(prev)
			return Sift.Dictionary.removeKey(prev, instance)
		end)
	end,
}

return {
	state = {
		crates = crates,
	},
	actions = actions,
}
