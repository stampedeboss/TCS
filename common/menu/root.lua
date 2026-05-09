---------------------------------------------------------------------
-- TCS COMMON: MENU ROOT
-- Establishes the base F10 hierarchy and coordinates Tower Builders.
---------------------------------------------------------------------
env.info("TCS(COMMON.MENU.ROOT): loading")

TCS = TCS or {}
TCS.Menu = TCS.Menu or {}
TCS.Menu.Builders = TCS.Menu.Builders or {}
TCS.Menu.Roots = TCS.Menu.Roots or {}

function TCS.Menu.BuildRoot(client)
    if not client or not client:IsAlive() then return end
    local clientName = client:GetClientGroupID() or client:GetName()
    
    if TCS.Menu.Roots[clientName] and TCS.Menu.Roots[clientName].Main then
        TCS.Menu.Roots[clientName].Main:Remove()
    end

    local main = MENU_CLIENT:New(client, "TCS Command")
    TCS.Menu.Roots[clientName] = {
        Main = main,
        Air = MENU_CLIENT:New(client, "Air Tower", main),
        AirDef = MENU_CLIENT:New(client, "AirDef Tower", main),
        Land = MENU_CLIENT:New(client, "Land Tower", main),
        Sea = MENU_CLIENT:New(client, "Sea Tower", main),
        Range = MENU_CLIENT:New(client, "Range Tower", main),
        Logistics = MENU_CLIENT:New(client, "Logistics Tower", main),
        Admin = MENU_CLIENT:New(client, "Admin", main)
    }

    -- Distribute the population task to any loaded Tower Menu Builders
    for _, builder in ipairs(TCS.Menu.Builders) do
        builder(client, TCS.Menu.Roots[clientName])
    end
end

TCS.Menu.ClientSet = SET_CLIENT:New():FilterActive():FilterStart()
TCS.Menu.ClientSet:HandleEvent(EVENTS.Birth)
function TCS.Menu.ClientSet:OnEventBirth(EventData) if EventData.IniPlayerName then TCS.Menu.BuildRoot(CLIENT:FindByName(EventData.IniUnitName)) end end

env.info("TCS(COMMON.MENU.ROOT): ready")