if not gadgetHandler:IsSyncedCode() then
	return
end

function gadget:GetInfo()
	return {
		name    = "Eskimo attributes",
		desc    = "Eskimo attribute mechanics.",
		author  = "gajop",
		date    = "LD42",
		license = "GNU GPL, v2 or later",
		layer   = -1,
		enabled = true,
	}
end

local LOG_SECTION = "eskimo-attributes"

local GAME_FRAME_PER_SEC = 33
local MULTI = 1 / GAME_FRAME_PER_SEC

local START_HEALTH          = 50
local HEALTH_REGEN_RATE     = 1.0 * MULTI
local FREEZING_HEALTH_DECAY = 1.0 * MULTI
local STARVING_HEALTH_DECAY = 0.2 * MULTI

local REST_STATES = {
    RESTING = "resting",
    ACTIVE = "active",
}

local MAX_FOOD          = 100
local START_FOOD        = 90
local FOOD_DECAY_RATE   = 1   * MULTI
local FOOD_EATING_RATE  = 10  * MULTI
local FOOD_RES_USAGE    = 0.1 * MULTI

local EATING_STATES = {
    IDLE = "idle",
    EATING = "eating",
    STARVING = "starving"
}

local MAX_HEAT          = 100
local START_HEAT        = 40
local WARMING_INCREASE  = 4   * MULTI
local COLD_DECREASE     = 1   * MULTI
local HEAT_RES_USAGE    = 0.5   * MULTI

local COAL_BURNER_MIN_DISTANCE = 300
local coalBurnerDefID = UnitDefNames["coalburner"].id

local WARM_STATES = {
    WARM = "warm",
    COLD = "cold",
    FREEZING = "freezing",
}

local eskimoDefID = UnitDefNames["eskimo"].id

local eskimos = {}

local function UnitIsEskimo(unitID)
    local unitDefID = Spring.GetUnitDefID(unitID)
    return unitDefID == eskimoDefID
end

function gadget:Initialize()
    Spring.SetGameRulesParam("maxHealth", UnitDefs[eskimoDefID].customParams.health)
    Spring.SetGameRulesParam("maxFood", MAX_FOOD)
    Spring.SetGameRulesParam("maxHeat", MAX_HEAT)

    for _, unitID in pairs(Spring.GetAllUnits()) do
        self:UnitCreated(unitID)
    end
end

local function UpdateAllAttributes(unitID, table)
    for k, v in pairs(table) do
        Spring.SetUnitRulesParam(unitID, k, v)
    end
end

function gadget:UnitCreated(unitID)
    if not UnitIsEskimo(unitID) then
		return
	end

    local function _l(attr)
        return Spring.GetUnitRulesParam(unitID, attr)
    end

    local attrs = {
        health =       _l("health")       or START_HEALTH,
        food =         _l("food")         or START_FOOD,
        heat =         _l("heat")         or START_HEAT,
        rest_state =   _l("rest_state")   or REST_STATES.ACTIVE,
        warm_state =   _l("warm_state")   or WARM_STATES.COLD,
        eating_state = _l("eating_state") or EATING_STATES.IDLE,
		--eating_state = _l("eating_state") or EATING_STATES.EATING,
    }

	eskimos[unitID] = unitID
    UpdateAllAttributes(unitID, attrs)
end

function gadget:UnitDestroyed(unitID)
	if UnitIsEskimo(unitID) then
		eskimos[unitID] = nil
	end
end

-- not really needed anymore but don't want to refactor atm
function SetAttribute(unitID, key, value)
    Spring.SetUnitRulesParam(unitID, key, value)
end

local function DoHeat(unitID)
	local warm_state = Spring.GetUnitRulesParam(unitID, "warm_state")
    local heat = Spring.GetUnitRulesParam(unitID, "heat")

	local threshold = 2
	-- heat when near a coal burner
	if heat + threshold <= MAX_HEAT then
		local x, _, z = Spring.GetUnitPosition(unitID)
		warm_state = WARM_STATES.COLD
		SetAttribute(unitID, "warm_state", warm_state)
		for _, nearbyUnitID in pairs(Spring.GetUnitsInCylinder(x, z, COAL_BURNER_MIN_DISTANCE)) do
			local defID = Spring.GetUnitDefID(nearbyUnitID)
			if defID == coalBurnerDefID then
				warm_state = WARM_STATES.WARM
				SetAttribute(unitID, "warm_state", warm_state)
				break
			end
		end
	end

    if warm_state == WARM_STATES.WARM then
		if not GG.Resources.Consume("heat", HEAT_RES_USAGE) then
			SetAttribute(unitID, "warm_state", WARM_STATES.COLD)
		else
			heat = heat + WARMING_INCREASE
		end
    elseif warm_state == WARM_STATES.COLD then
        heat = heat - COLD_DECREASE
	elseif not warm_state == WARM_STATES.FREEZING then
		Spring.Log(LOG_SECTION, LOG.ERROR, "Invalid warm_state " ..
			tostring(warm_state) .. " for: " .. tostring(unitID))
    end

    if heat <= 0 then
        SetAttribute(unitID, "warm_state", WARM_STATES.FREEZING)
    end
	if heat >= MAX_HEAT then
		SetAttribute(unitID, "warm_state", WARM_STATES.COLD)
	end

    heat = math.min(heat, MAX_HEAT)
    heat = math.max(heat, 0)
    SetAttribute(unitID, "heat", heat)
end

local function DoFood(unitID)
    local food = Spring.GetUnitRulesParam(unitID, "food")
	if food < 20 then -- automatically eat
		Spring.SetUnitRulesParam(unitID, "eating_state", EATING_STATES.EATING)
	elseif food > 80 then
		SetAttribute(unitID, "eating_state", EATING_STATES.IDLE)
	end
	local eating_state = Spring.GetUnitRulesParam(unitID, "eating_state")

    if eating_state == EATING_STATES.IDLE then
        food = food - FOOD_DECAY_RATE
    elseif eating_state == EATING_STATES.EATING then
		if not GG.Resources.Consume("food", FOOD_RES_USAGE) then
			SetAttribute(unitID, "eating_state", EATING_STATES.IDLE)
		else
			food = food + FOOD_EATING_RATE
		end
	elseif not eating_state == EATING_STATES.STARVING then
		Spring.Log(LOG_SECTION, LOG.ERROR, "Invalid eating_state " ..
			tostring(eating_state) .. " for: " .. tostring(unitID))
    end

    if food <= 0 then
        SetAttribute(unitID, "eating_state", EATING_STATES.STARVING)
    end
	if food >= MAX_FOOD then
		SetAttribute(unitID, "eating_state", EATING_STATES.IDLE)
	end

    food = math.min(food, MAX_FOOD)
    food = math.max(food, 0)
    SetAttribute(unitID, "food", food)
end

local function DoHealth(unitID)
	local warm_state = Spring.GetUnitRulesParam(unitID, "warm_state")
	local rest_state = Spring.GetUnitRulesParam(unitID, "rest_state")
	local eating_state = Spring.GetUnitRulesParam(unitID, "eating_state")
    local health = Spring.GetUnitRulesParam(unitID, "health")
    if rest_state == REST_STATES.RESTING then
        health = health + HEALTH_REGEN_RATE
    end
    if warm_state == WARM_STATES.FREEZING then
        health = health - FREEZING_HEALTH_DECAY
    end
    if eating_state == EATING_STATES.STARVING then
        health = health - STARVING_HEALTH_DECAY
    end

    local delayedDestroy = false
    if health <= 0 then
        delayedDestroy = true
    end

    health = math.min(health, UnitDefs[eskimoDefID].customParams.health)
    health = math.max(health, 0)
    SetAttribute(unitID, "health", health)

    if delayedDestroy then
        Spring.DestroyUnit(unitID)
    end
end

function gadget:GameFrame()
	if Spring.GetGameRulesParam("sb_gameMode") == "dev" then
        return
    end
    local frame = Spring.GetGameFrame()

    for _, unitID in pairs(eskimos) do
        DoHeat(unitID)
        DoFood(unitID)
        DoHealth(unitID)
    end
end

GG.Eskimo = {
    SetAttribute = SetAttribute,
}
