---------------------------------------------------------------------
-- TCS AIR F10 MENU
-- Provides player-driven scenario generation via the F10 radio menu.
---------------------------------------------------------------------
env.info("TCS(AIR.MENU): loading")

env.info("TCS(AIR.MENU): [DEPRECATED] F10 Menus have been moved to the Signals domain. Skipping.")
return

if not (TCS.Common and TCS.Common.Defaults and TCS.Common.Defaults.EnableF10Menus) then
    env.info("TCS(AIR.MENU): F10 Menus are disabled in common/defaults.lua. Skipping.")
    return
end

TCS = TCS or {}
TCS.Air = TCS.Air or {}
TCS.Air.Menu = {}

---------------------------------------------------------------------
-- Menu Callback Functions
---------------------------------------------------------------------

-- Packages an Intent-Based Request for the Air Planner.
local function requestScenario(group, intent, params)
    if not group then return end
    local unit = group:GetUnit(1)
    if not unit then return end

    local request = {
        intent = intent,
        anchor = unit:GetCoordinate(),
        heading = unit:GetHeading(),
        coalition = (group:GetCoalition() == coalition.side.BLUE) and coalition.side.RED or coalition.side.BLUE
    }
    
    -- Merge in any optional UI constraints (tier, variant, etc.)
    if params then for k, v in pairs(params) do request[k] = v end end

    if TCS.Air.Planner and TCS.Air.Planner.Execute then
        local success, msg = TCS.Air.Planner.Execute(request)
        MESSAGE:New("CIC: " .. msg, 15):ToGroup(group)
    end
end

-- Outfits the nearest airbase with ambient statics.
local function outfitNearestAirbase(group)
    if not group then return end
    local coord = group:GetCoordinate()
    if not coord then return end

    local airbase = coord:GetClosestAirbase()
    if not airbase then
        MESSAGE:New("Could not find a nearby airbase.", 10):ToGroup(group)
        return
    end

    local baseName = airbase:GetName()
    local coa = group:GetCoalition()
    
    if _G.OutfitBase then
        _G.OutfitBase({
            base = baseName,
            coalition = coa,
            density = 0.6, -- A reasonable default for a manual spawn
            traffic = true
        })
        MESSAGE:New("Outfitting " .. baseName .. " with ambient statics.", 15):ToGroup(group)
    else
        MESSAGE:New("OutfitBase function not found.", 10):ToGroup(group)
    end
end

-- Admin function to clean up all spawned air assets.
local function cleanupAirSpawns()
    if TCS.Air and TCS.Air.CleanupAllSpawns then
        TCS.Air.CleanupAllSpawns()
    end
end

---------------------------------------------------------------------
-- Menu Build Function
---------------------------------------------------------------------

function TCS.Air.Menu.BuildForCoalition(side)
    local rootMenu = MENU_COALITION:New(side, "TCS Air Operations")

    -- Training Scenarios
    local trainingMenu = rootMenu:AddSubMenu("Training Scenarios")
    trainingMenu:AddCommand("BFM (Guns Only)", function(group) requestScenario(group, "ACM", { loadoutThreat = "A" }) end)
    trainingMenu:AddCommand("BFM (Fox 1 & Fox 2)", function(group) requestScenario(group, "ACM", { loadoutThreat = "H" }) end)
    trainingMenu:AddCommand("BVR (Extreme / Fox 3)", function(group) requestScenario(group, "BVR", { loadoutThreat = "X" }) end)

    -- Combat Missions
    local combatMenu = rootMenu:AddSubMenu("Combat Missions")
    
    local interceptMenu = combatMenu:AddSubMenu("Generate Intercept")
    interceptMenu:AddCommand("Low Threat (Guns Only)", function(group) requestScenario(group, "INTERCEPT", { aircraftThreat = "A", loadoutThreat = "A" }) end)
    interceptMenu:AddCommand("Standard Threat (Fox 1)", function(group) requestScenario(group, "INTERCEPT", { aircraftThreat = "G", loadoutThreat = "G" }) end)
    interceptMenu:AddCommand("High Threat (Fox 2)", function(group) requestScenario(group, "INTERCEPT", { aircraftThreat = "H", loadoutThreat = "H" }) end)
    interceptMenu:AddCommand("Extreme Threat (Fox 3)", function(group) requestScenario(group, "INTERCEPT", { aircraftThreat = "X", loadoutThreat = "X" }) end)

    local capMenu = combatMenu:AddSubMenu("Generate CAP")
    capMenu:AddCommand("Low Threat (Guns Only)", function(group) requestScenario(group, "CAP", { aircraftThreat = "A", loadoutThreat = "A" }) end)
    capMenu:AddCommand("Standard Threat (Fox 1)", function(group) requestScenario(group, "CAP", { aircraftThreat = "G", loadoutThreat = "G" }) end)
    capMenu:AddCommand("High Threat (Fox 2)", function(group) requestScenario(group, "CAP", { aircraftThreat = "H", loadoutThreat = "H" }) end)
    capMenu:AddCommand("Extreme Threat (Fox 3)", function(group) requestScenario(group, "CAP", { aircraftThreat = "X", loadoutThreat = "X" }) end)

    local sweepMenu = combatMenu:AddSubMenu("Generate Sweep")
    sweepMenu:AddCommand("Low Threat (Guns Only)", function(group) requestScenario(group, "SWEEP", { aircraftThreat = "A", loadoutThreat = "A" }) end)
    sweepMenu:AddCommand("Standard Threat (Fox 1)", function(group) requestScenario(group, "SWEEP", { aircraftThreat = "G", loadoutThreat = "G" }) end)
    sweepMenu:AddCommand("High Threat (Fox 2)", function(group) requestScenario(group, "SWEEP", { aircraftThreat = "H", loadoutThreat = "H" }) end)
    sweepMenu:AddCommand("Extreme Threat (Fox 3)", function(group) requestScenario(group, "SWEEP", { aircraftThreat = "X", loadoutThreat = "X" }) end)

    -- Ambient Scenery
    local ambientMenu = rootMenu:AddSubMenu("Ambient Scenery")
    ambientMenu:AddCommand("Outfit Nearest Airbase", outfitNearestAirbase)

    -- Admin Menu (Only shows for admins defined in common/defaults.lua)
    local adminMenu = rootMenu:AddSubMenu("Admin")
    adminMenu:AddCommand("Cleanup All Air Spawns", cleanupAirSpawns)
    
    -- Set admin-only access
    local admins = TCS.Common and TCS.Common.Defaults and TCS.Common.Defaults.Admins or {}
    if #admins > 0 then
        adminMenu:SetMenuCoalition(side)
        for _, ucid in ipairs(admins) do
            adminMenu:AllowPlayer(ucid)
        end
    end
end

-- Build the menus for both sides
TCS.Air.Menu.BuildForCoalition(coalition.side.BLUE)
TCS.Air.Menu.BuildForCoalition(coalition.side.RED)

env.info("TCS(AIR.MENU): F10 menus are now active.")