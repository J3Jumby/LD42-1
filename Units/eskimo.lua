local Humanoid = Unit:New {
	-- FIXME: The docs for buildPic are a lie.
	-- Explicitly specifying an empty string gives different results.
	-- Nvm, this seems to be a side effect of using the OOP class system
	-- That said, it shouldn't have any defaults.
	buildPic 			= "",
	-- Sensors
	sightDistance       = 800,

	-- Commands
	canMove             = true,
	-- All these canX properties shouldn't be on by default:
	-- 	should they even be part of the engine? Lua it!
	canPatrol           = false,
	canGuard            = false,
	canRepeat           = false,
	fireState           = 2,       -- Should auto-attack by default.

	-- Movement & Placement
	-- Wiki: (this section should be split into building and non-building parts)
	-- Maybe even needs to be split differently for ships/air/ground
	footprintX          = 4,		-- 1 seems a bad default (too small!)
	footprintZ          = 4,
	upright             = true,
	minCollisionSpeed   = 1000000,
    pushResistant       = false,
	maxVelocity         = 10,
	-- maxVelocity's default value of "0" is odd, unless the default is a "building"?
	-- then again, acceleration is not 0 by default..
	brakeRate           = 0.4,
	turnRate            = 360 / 0.16,
	-- degrees per seconds = 0.16 * turnRate
	-- what a bizarre calculation, is this turnRate / (2 * pi)?
	-- this is probably just turnRate in radians and should be named such


	-- turnInPlace = true, (default)
	-- So it seems this default value is modeling a person rather than a car
	-- Why is the 'upright' also not reflecting that?
	-- Our default values should model *something*, otherwise they're pointless

	-- blocking & Spring.SetUnitBlocking
	-- we cannot modify all blocking properties here, and we need to rely on Lua

	-- Categories (probably don't need by default?)
	-- OH IT WAS NEEDED.
	category            = "INFANTRY",

	-- Collision Volumes
	-- This should be a good default for games that don't care about performance
	-- Let's hope it works...
	usePieceCollisionVolumes = true,
	usePieceSelectionVolumes = true,
	-- collisionVolumeType      = 'CylY',
	-- collisionVolumeScales    = '37 40 37',
    -- collisionVolumeTest      = 1,
}


local Eskimo = Humanoid:New {
	-- General
	name                = "Eskimo",
	movementClass       = "Eskimo",
	objectName 			= "eskimo.dae",
	script              = "eskimo.lua",
	maxDamage           = 1600,
	-- mass                = 50, -- does this even matter?

	weapons = {
		{
			name = "Spear",
		},
		{
			name = "Gun",
		}
	},

	customParams = {
		health = 100,
		damage = 10,
		death_sound = "DeathEskimo",
	},
	corpse                 = [[DEAD_A]],
	featureDefs                   = {
		DEAD_A  = {
			blocking         = false,
			featureDead      = [[DEAD_B]],
			footprintX       = 2,
			footprintZ       = 2,
			object           = [[eskimo_dead_exhaustion.dae]],
			smokeTime        = 0,
		},
		DEAD_B  = {
			blocking         = false,
			footprintX       = 2,
			footprintZ       = 2,
			object           = [[eskimo_dead_shot.dae]],
			smokeTime        = 0,
		},

	},
}

local Pirate = Humanoid:New {
	-- General
	name                = "Pirate",
	movementClass       = "Eskimo",
	objectName 			= "pirate.dae",
	script              = "eskimo.lua",
	maxDamage           = 1600,
	-- mass                = 50, -- does this even matter?

	weapons = {
		{
			name = "Spear",
		},
		{
			name = "Gun",
		}
	},

	customParams = {
		has_gun = "1",
		health = 100,
		damage = 10,
		death_sound = "DeathPirate",
	},
	corpse                 = [[LESS_DEAD]],
	featureDefs                   = {
		LESS_DEAD  = {
			featureDead      = [[DEAD]],
			blocking         = false,
			footprintX       = 2,
			footprintZ       = 2,
			object           = [[pirate_dead_1.dae]],
			smokeTime        = 0,
		},
		DEAD  = {
			blocking         = false,
			footprintX       = 2,
			footprintZ       = 2,
			object           = [[pirate_dead_2.dae]],
			smokeTime        = 0,
		},
	}
}

return {
    eskimo    = Eskimo,
	pirate    = Pirate,
}
