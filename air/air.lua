---------------------------------------------------------------------
-- TCS TOWER: AIR
-- Domain Specialist: Fighter sweeps, CAPs, and Support Aircraft.
---------------------------------------------------------------------
env.info("TCS(TOWER.AIR): loading")

TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.Air = {}
TCS.Air = TCS.Air or {}

--- Counts the total number of alive units across a list of MOOSE Groups
function TCS.Air.AliveAircraftCount(groups)
    local count = 0
    if not groups then return count end
    for _, group in ipairs(groups) do
        if group and group:IsAlive() then
            local aliveUnits = group:GetAliveUnits()
            if aliveUnits then count = count + #aliveUnits end
        end
    end
    return count
end

--- Wipes all TCS-spawned air groups from the map.
function TCS.Air.CleanupAllSpawns()
    local prefixes = { "TCS_CAP_", "TCS_SWEEP_", "TCS_INTERCEPT_", "TCS_ESCORT_", "TCS_BUILD_", "TCS_AMBIENT_", "TCS_AIR_" }
    local count = 0
    for _, prefix in ipairs(prefixes) do
        local groupsToClean = SET_GROUP:New():FilterPrefix(prefix):FilterOnce()
        groupsToClean:ForEach(function(g)
            if g and g:IsAlive() then
                g:Destroy()
                count = count + 1
            end
        end)
    end
    local msg = string.format("TCS Air Admin: Wiped %d air groups.", count)
    env.info(msg)
    MESSAGE:New(msg, 15):ToAll()
end

function TCS.Towers.Air.PrepareRequisition(role, params)
    local manifest = {}
    local side = params.coalition or coalition.side.RED
    local skill = params.skill or params.echelon or "G"

    -- Use explicitly passed count, or derive from echelon
    local count = params.count or params.initial or 2
    if not params.count and not params.initial then
        if params.echelon == "PATROL" then count = 2
        elseif params.echelon == "SQUADRON" then count = 4
        elseif params.echelon == "WING" then count = 8
        end
    end

    local isSupport = (role == "AWACS" or role == "TANKER" or role == "TRANSPORT")
    if isSupport then count = 1 end

    -- Pure Data-Driven: Rely on Architect's Catalog Query
    local unitType = params.unit_type or TCS.Air.Settings.FALLBACKS.FIGHTER
    if isSupport and not params.unit_type then
        unitType = (role == "AWACS") and TCS.Air.Settings.FALLBACKS.AWACS or (role == "TANKER") and TCS.Air.Settings.FALLBACKS.TANKER or TCS.Air.Settings.FALLBACKS.TRANSPORT
    end

    local alt = params.alt or (isSupport and TCS.Air.Settings.ALTITUDE.MED or TCS.Air.Settings.ALTITUDE.HIGH)
    
    -- Determine Payload: Prefer passed params (from the Catalog), fallback to default empty loadout
    local payload = params.payload or TCS.Air.Settings.FALLBACKS.PAYLOAD
    local spacing = TCS.Air.Settings.FORMATION.ECHELON_RIGHT_SPACING_M or 50

    for i = 1, count do
        table.insert(manifest, {
            unit_type = unitType,
            role = role,
            category = isSupport and "SUPPORT" or "FIGHTER",
            isStatic = false,
            relativePos = { x = -(i-1)*spacing, y = (i-1)*spacing }, -- Echelon Right formation
            alt = alt,
            skill = skill,
            payload = payload
        })
    end

    return {
        tower = "AIR",
        manifest = manifest,
        coalition = side,
        geometry = params.geometry,
        behavior = { mode = isSupport and "ORBIT" or "INTERCEPT", target = params.anchor }
    }
end

env.info("TCS(TOWER.AIR): ready")