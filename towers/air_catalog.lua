---------------------------------------------------------------------
-- TCS TOWER: AIR CATALOG
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.Air = TCS.Towers.Air or {}

function TCS.Towers.Air.Query(params)
    local catalog = TCS.Config.Catalog.A2A
    if not catalog or not params.category then return {} end

    local sourceTable = catalog[params.category] or {}
    local results = {}
    
    local flagVal = trigger.misc.getUserFlag(TCS.Common.Config.MISSION_YEAR_FLAG or 285999)
    local missionYear = flagVal > 0 and (1940 + flagVal) or 0
    
    for _, entry in ipairs(sourceTable) do
        local match = true
        local entryCoal = (entry.coalition == "BLUE") and 2 or 1
        if params.coalition and entryCoal ~= params.coalition then match = false end
        
        if missionYear > 0 and entry.first_service_year and entry.first_service_year > missionYear then match = false end
        if params.role and entry.role ~= params.role then match = false end

        if match then table.insert(results, entry) end
    end

    return results
end

env.info("TCS(TOWER.AIR.CATALOG): ready")