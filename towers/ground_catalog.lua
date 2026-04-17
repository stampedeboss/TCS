---------------------------------------------------------------------
-- TCS TOWER: GROUND CATALOG
-- Specialist for Ground unit registration and schema-based queries.
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.Ground = TCS.Towers.Ground or {} -- Ensure parent table exists

--- Queries the local catalog based on mission requirements.
function TCS.Towers.Ground.Query(params)
    local catalog = TCS.Config and TCS.Config.Catalog and TCS.Config.Catalog.A2G
    if not catalog or not params.category then return {} end

    local sourceTable = catalog[params.category] or {}
    local results = {}

    local missionYear = TCS.Common.Config.GetMissionYear()
    
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

env.info("TCS(TOWER.GROUND.CATALOG): ready")