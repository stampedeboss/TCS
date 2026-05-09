---------------------------------------------------------------------
-- TCS LOGISTICS TOWER: MENU BUILDER
-- Injects Logistics options into the Common Menu Root.
---------------------------------------------------------------------
env.info("TCS(LOGISTICS.MENU_BUILDER): loading")

TCS = TCS or {}
TCS.Logistics = TCS.Logistics or {}

local function HandleLogisticsRequest(client, missionType, configParams)
    local params = TCS.Menu.Geometry.GetRequestParams(client, configParams)
    if not params then return end

    if TCS.Logistics.Architect and TCS.Logistics.Architect.Build then
        TCS.Logistics.Architect.Build(missionType, params)
        local msg = string.format("TCS LOGISTICS: %s mission generated %d to %d NM along your flight path.", missionType, params.minNm, params.maxNm)
        if MESSAGE then MESSAGE:New(msg, 10):ToClient(client) end
    end
end

local function BuildFarpAtCurrentLocation(client)
    local unit = client:GetClientGroupUnit()
    if not unit then return end
    
    local coord = unit:GetCoordinate()
    local heading = unit:GetHeading()
    local side = client:GetCoalition()
    
    if TCS.Logistics and TCS.Logistics.SpawnFARP then
        TCS.Logistics.SpawnFARP(coord, math.rad(heading), side, client:GetPlayerName())
        if MESSAGE then MESSAGE:New("TCS LOGISTICS: FARP deployed at your location.", 10):ToClient(client) end
    end
end

TCS.Menu = TCS.Menu or {}
TCS.Menu.Builders = TCS.Menu.Builders or {}
table.insert(TCS.Menu.Builders, function(client, roots)
    if not roots.Logistics or not TCS.Logistics.MenuConfig then return end
    
    local unit = client:GetClientGroupUnit()
    if unit and unit:IsHelicopter() then
        MENU_CLIENT_COMMAND:New(client, "Deploy FARP (Current Location)", roots.Logistics, BuildFarpAtCurrentLocation, client)
    end

    for missionType, options in pairs(TCS.Logistics.MenuConfig) do
        local subMenu = MENU_CLIENT:New(client, "Request " .. missionType, roots.Logistics)
        for _, opt in ipairs(options) do MENU_CLIENT_COMMAND:New(client, opt.label, subMenu, HandleLogisticsRequest, client, missionType, opt) end
    end
end)

env.info("TCS(LOGISTICS.MENU_BUILDER): ready")