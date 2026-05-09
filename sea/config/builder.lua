---------------------------------------------------------------------
-- TCS SEA TOWER: MENU BUILDER
-- Injects Sea options into the Common Menu Root.
---------------------------------------------------------------------
env.info("TCS(SEA.MENU_BUILDER): loading")

TCS = TCS or {}
TCS.Sea = TCS.Sea or {}

local function HandleSeaRequest(client, missionType, configParams)
    local params = TCS.Menu.Geometry.GetRequestParams(client, configParams)
    if not params then return end
    
    -- Force the domain flag so the Placements engine actively seeks Water!
    params.domain = "SEA"

    if TCS.Sea.Architect and TCS.Sea.Architect.Build then
        TCS.Sea.Architect.Build(missionType, params)
        local msg = string.format("TCS NAVAL: %s target generated %d to %d NM along your flight path.", missionType, params.minNm, params.maxNm)
        if MESSAGE then MESSAGE:New(msg, 10):ToClient(client) end
    elseif TCS.Mission and TCS.Mission.Architect and TCS.Mission.Architect.Build then
        -- Fallback to Mission Architect if a dedicated Sea Architect isn't loaded yet
        TCS.Mission.Architect.Build(missionType, params)
        local msg = string.format("TCS NAVAL: %s target generated %d to %d NM along your flight path.", missionType, params.minNm, params.maxNm)
        if MESSAGE then MESSAGE:New(msg, 10):ToClient(client) end
    end
end

TCS.Menu = TCS.Menu or {}
TCS.Menu.Builders = TCS.Menu.Builders or {}
table.insert(TCS.Menu.Builders, function(client, roots)
    if not roots.Sea or not TCS.Sea.MenuConfig then return end
    
    for missionType, options in pairs(TCS.Sea.MenuConfig) do
        local subMenu = MENU_CLIENT:New(client, "Request " .. missionType, roots.Sea)
        for _, opt in ipairs(options) do MENU_CLIENT_COMMAND:New(client, opt.label, subMenu, HandleSeaRequest, client, missionType, opt) end
    end
end)

env.info("TCS(SEA.MENU_BUILDER): ready")