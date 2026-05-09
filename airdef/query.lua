---------------------------------------------------------------------
-- TCS TOWER: AIRDEF CATALOG
---------------------------------------------------------------------
TCS = TCS or {}
TCS.AirDef = TCS.AirDef or {}

function TCS.AirDef.Query(params)
    local catalog = TCS.AirDef.Catalog
    if not catalog then return {} end

    local results = {}
    local defs = TCS.AirDef.Defaults or {}

    -- Use strictly cached global service year limit, defaulting to permissive future
    local missionYearLimit = (TCS.Common and TCS.Common.Defaults and TCS.Common.Defaults.ServiceYearLimit) or defs.FALLBACK_YEAR or 2040

    
    for sysName, entry in pairs(catalog) do
        local match = true
        
        -- 1. Coalition Filter
        local entryCoal = (entry.coalition == "BLUE") and coalition.side.BLUE or coalition.side.RED
        if params.coalition and entryCoal ~= params.coalition then match = false end
        
        -- 2. Era Filter
        if entry.service_date and entry.service_date > missionYearLimit then match = false end
        
        -- 3. Mobility Filter
        if params.mobility and entry.mobility ~= params.mobility then match = false end
        
        -- 4. Threat Filter
        if params.threat and entry.threat ~= params.threat then match = false end

        if match then table.insert(results, sysName) end
    end

    return results
end

env.info("TCS(TOWER.AIRDEF.QUERY): ready")