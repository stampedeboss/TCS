---------------------------------------------------------------------
-- TCS RANGE TOWER: MENU BUILDER
-- Injects Range options into the Common Menu Root.
---------------------------------------------------------------------
env.info("TCS(RANGE.MENU_BUILDER): loading")

TCS = TCS or {}
TCS.Range = TCS.Range or {}

local function HandleRangeRequest(client, category, configParams)
    local params = TCS.Menu.Geometry.GetRequestParams(client, configParams)
    if not params then return end

    params.rangeConfig = configParams.rangeConfig

    if TCS.Range.Architect and TCS.Range.Architect.Build then
        TCS.Range.Architect.Build(category, params)
        local msg = string.format("TCS RANGE: %s practice range deployed %d to %d NM along your flight path.", configParams.label, params.minNm, params.maxNm)
        if MESSAGE then MESSAGE:New(msg, 10):ToClient(client) end
    end
end

TCS.Menu = TCS.Menu or {}
TCS.Menu.Builders = TCS.Menu.Builders or {}
table.insert(TCS.Menu.Builders, function(client, roots)
    if not roots.Range or not TCS.Range.MenuConfig then return end
    for category, options in pairs(TCS.Range.MenuConfig) do
        local subMenu = MENU_CLIENT:New(client, category, roots.Range)
        for _, opt in ipairs(options) do MENU_CLIENT_COMMAND:New(client, opt.label, subMenu, HandleRangeRequest, client, category, opt) end
    end
end)
env.info("TCS(RANGE.MENU_BUILDER): ready")