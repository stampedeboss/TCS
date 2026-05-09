---------------------------------------------------------------------
-- TCS: MENU DISPATCHER
-- Listens for player spawns and dynamically builds F10 menus
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Menu = TCS.Menu or {}
TCS.Menu.Builders = TCS.Menu.Builders or {}

if TCS.Logger then TCS.Logger.trace("Loading TCS Menu Dispatcher...") end

local MenuHandler = EVENTHANDLER:New()
MenuHandler:HandleEvent(EVENTS.PlayerEnterAircraft)
MenuHandler:HandleEvent(EVENTS.PlayerEnterUnit) -- Covers Combined Arms / Ground slots if needed

function MenuHandler:OnEventPlayerEnterAircraft(EventData)
    self:BuildPlayerMenu(EventData)
end

function MenuHandler:OnEventPlayerEnterUnit(EventData)
    self:BuildPlayerMenu(EventData)
end

function MenuHandler:BuildPlayerMenu(EventData)
    if not EventData.IniPlayerName then return end
    
    local client = CLIENT:FindByName(EventData.IniUnitName)
    if not client then return end
    
    -- 1. Create Base Root Menus
    local roots = {
        Admin = MENU_CLIENT:New(client, "TCS Admin")
    }
    
    -- 2. Execute all registered builders (from tower/test scripts)
    for _, builder in ipairs(TCS.Menu.Builders) do
        if type(builder) == "function" then builder(client, roots) end
    end
end

env.info("TCS: Menu Dispatcher loaded.")