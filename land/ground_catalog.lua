---------------------------------------------------------------------
-- TCS TOWER: GROUND CATALOG
-- Specialist for Ground unit registration and schema-based queries.
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.Land = TCS.Towers.Land or {} -- Ensure parent table exists

--- Queries the local catalog based on mission requirements.
function TCS.Towers.Land.Query(params)
    local catalog = TCS.Land and TCS.Land.Config and TCS.Land.Config.Catalog
    if not catalog or not params.category then return {} end

    local sourceTable = catalog[params.category] or {}
    local results = {}

    -- Safely resolve mission year
    local missionYear = 0
    if TCS.Common and TCS.Common.Config and TCS.Common.Config.GetMissionYear then
        missionYear = TCS.Common.Config.GetMissionYear()
    elseif TCS.Land and TCS.Land.Config and TCS.Land.Config.Defaults and TCS.Land.Config.Defaults.MISSION_YEAR_FLAG then
        missionYear = trigger.misc.getUserFlag(TCS.Land.Config.Defaults.MISSION_YEAR_FLAG)
    end
    
    -- Resolve allowed bands from Tier
    local allowedBands = { LOW = true, NONE = true }
    if params.skill == "G" then allowedBands.MED = true
    elseif params.skill == "H" or params.skill == "X" then 
        allowedBands.MED = true; allowedBands.HIGH = true 
    end

    for _, entry in ipairs(sourceTable) do
        local match = true
        
        -- 1. Coalition Filter
        local entryCoal = (entry.coalition == "BLUE") and coalition.side.BLUE or coalition.side.RED
        if params.coalition and entryCoal ~= params.coalition then match = false end

        -- 2. Era Filter
        if missionYear > 0 and entry.first_service_year and entry.first_service_year > missionYear then
            match = false
        end

        -- 3. Threat Band Filter
        if not allowedBands[entry.threat_band or "LOW"] then match = false end

        if match then table.insert(results, entry) end
    end

    return results
end

env.info("TCS(TOWER.LAND.CATALOG): ready")