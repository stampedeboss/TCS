---------------------------------------------------------------------
-- TCS TOWER: AIRDEF CATALOG
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.AirDef = TCS.Towers.AirDef or {}

function TCS.Towers.AirDef.Query(params)
    local catalog = TCS.Config.Catalog.AirDef
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
        if missionYear > 0 and entry.first_service_year and entry.first_service_year > missionYear then match = false end
        
        -- 3. Role & Threat Filter
        if params.role and entry.role ~= params.role then match = false end
        if not allowedBands[entry.threat_band or "LOW"] then match = false end

        -- 4. SAM Family Filter (Prevents SA-6 parts in SA-2 sites)
        if params.samType and entry.sam_type and entry.sam_type ~= params.samType and entry.sam_type ~= "ALL" then match = false end

        if match then table.insert(results, entry) end
    end

    return results
end

env.info("TCS(TOWER.AIRDEF.CATALOG): ready")