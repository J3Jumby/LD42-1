-- unitDef = {
-- 	unitname = [[transportship]],
--
-- 	name = [[Troop carrier]],
-- 	description = [[Pirates invading troops ]],
--   acceleration        = 0.102,
--   activateWhenBuilt   = true,
--   brakeRate           = 0.115,
--   buildCostMetal      = 220,
--   builder             = false,
--   buildPic            = [[]],
--   canMove             = true,
--   cantBeTransported   = true,
--   category            = [[SHIP UNARMED]],
--   collisionVolumeOffsets = [[0 0 -3]],
--   collisionVolumeScales  = [[35 20 55]],
--   collisionVolumeType    = [[ellipsoid]],
--   corpse              = [[]],
--
--   customParams        = {
-- 	turnatfullspeed = [[1]],
--     modelradius    = [[15]],
--   },
--
--   explodeAs           = [[]],
--   floater             = true,
--   footprintX          = 4,
--   footprintZ          = 4,
--   holdSteady          = true,
--   iconType            = [[]],
--   idleAutoHeal        = 5,
--   idleTime            = 1800,
--   isFirePlatform      = true,
--   maxDamage           = 1200,
--   maxVelocity         = 3.3,
--   minCloakDistance    = 75,
--   movementClass       = [[SHIP4]],
--   noChaseCategory     = [[]],
--   objectName          = [[drillship.s3o]],
--   releaseHeld         = true,
--   script              = [[shipscript.lua]],
--   selfDestructAs      = [[]],
--   sightDistance       = 325,
--   sonarDistance       = 325,
--   transportCapacity   = 1,
--   transportSize       = 3,
--   turnRate            = 590,
--
--
--
-- }
--
-- return lowerkeys({ transportship = unitDef })




-- This script below loads them but still crashes Spring when I try to create them






--
-- local TransportShip = Unit:New {
-- 	acceleration        = 0.5,
-- 	brakeRate           = 0.4,
--     --buildCostMetal        = 65, -- used only for power XP calcs
--     canMove             = true,
-- --     canGuard            = false,
-- --     canPatrol           = false,
-- --     canRepeat           = false,
--     category            = "INFANTRY",
--
--     --pushResistant       = true,
--     collisionVolumeScales   = '37 40 37',
--     collisionVolumeTest     = 1,
--     collisionVolumeType     = 'CylY',
--     footprintX          = 6,
--     footprintZ          = 6,
--     mass                = 50,
--     minCollisionSpeed   = 1,
--     movementClass       = "Eskimo",
--     repairable          = false,
--     sightDistance       = 800,
--
--
--     stealth             = true,
--     turnRate            = 3000,
--     upright             = true,
--
--
--     name                = "TransportShip",
--     activateWhenBuilt   = true,
--     customParams = {
--     },
--
--     idletime = 120, --in simframes
--     idleautoheal = 50,
--     autoheal = 1,
--
--     maxDamage           = 1600,
--     maxVelocity         = 10,
--     onoffable           = true,
--     fireState           = 0,
--     moveState           = 0,
--     script              = "transportship.lua",
-- 	objectName 			= "drillship.s3o",
-- }
--
-- return {
--     transportship    = TransportShip,
-- }
