---------------------------------------------------------------------
-- TCS MASTER INITIALIZATION (Merged)
-- Handles framework sequence and conditional player-logic loading.
---------------------------------------------------------------------
env.info("TCS(INIT): Starting Theater Control System...")

TCS = TCS or {}

-- 1. Resolve Base Path
local BASE_PATH = lfs.writedir() .. [[Missions\Scripts\DCS\TCS\]]
env.info("TCS(INIT): Base path resolved to " .. BASE_PATH)

local function load_tcs(file)
    local path = BASE_PATH .. file
    local f, err = loadfile(path)
    if not f then
        env.error("TCS(INIT): Could not load " .. path .. ": " .. tostring(err))
    else
        local status, result = pcall(f)
        if not status then
            env.error("TCS(INIT): Execution error in " .. path .. ": " .. tostring(result))
        end
    end
end

-- 2. Load Foundations & Common Utilities
load_tcs([[common\world.lua]])
load_tcs([[common\players.lua]])
load_tcs([[common\tracked_area.lua]])
load_tcs([[common\area_manager.lua]])
load_tcs([[common\session_utils.lua]])
load_tcs([[common\session_scale.lua]])
load_tcs([[common\placements.lua]])
load_tcs([[common\spawn_spacing.lua]])
load_tcs([[common\spawn.lua]])
load_tcs([[common\scenario.lua]])
load_tcs([[common\dispatcher.lua]])
load_tcs([[common\tracker.lua]])
load_tcs([[common\task_manager.lua]])
load_tcs([[common\registry.lua]])
load_tcs([[common\awacs.lua]])
load_tcs([[common\catalog.lua]])
load_tcs([[common\catalog_registry.lua]])
load_tcs([[common\spawner_ground.lua]])
load_tcs([[common\spawner_airdef.lua]])
load_tcs([[common\spawner_maritime.lua]])
load_tcs([[common\spawner_air.lua]])
load_tcs([[common\range.lua]])

-- 3. Load Configuration & Data Ingestion
load_tcs([[config\config.lua]])
load_tcs([[config\a2a_config.lua]])
load_tcs([[config\a2g_config.lua]])
load_tcs([[config\catalog_ground_units.lua]])
load_tcs([[config\catalog_air_qrf.lua]])
load_tcs([[config\catalog_sea_units.lua]])
load_tcs([[config\catalog_structures.lua]])
load_tcs([[config\catalog_a2a_bandits.lua]])
load_tcs([[config\catalog_a2a_packages.lua]])

if TCS.Catalog and TCS.Catalog.Ingest then
    TCS.Catalog.Ingest(TCS.Config.Catalog)
end

-- 4. Load Domain Specialists (Towers)
load_tcs([[towers\training.lua]])
load_tcs([[towers\maritime.lua]])
load_tcs([[towers\ground.lua]])
load_tcs([[towers\airdef.lua]])
load_tcs([[towers\air.lua]])
load_tcs([[mission\architect.lua]])

-- 5. Load Legacy Domain Logic (Core)
load_tcs([[a2a\core.lua]])
load_tcs([[a2g\core.lua]])
load_tcs([[common\feedback.lua]])
load_tcs([[a2g\jtac.lua]])

-- 6. Load Simplified Trigger Layer (Always loaded for Mission Builders)
load_tcs([[direct\a2g.lua]])
load_tcs([[direct\custom.lua]])

---------------------------------------------------------------------
-- 7. Conditional Player Control Loading
---------------------------------------------------------------------
local flagVal = trigger.misc.getUserFlag(285000)
local isHeadless = (flagVal > 9)
local menusEnabled = TCS.Config.System and TCS.Config.System.EnableF10Menus

if isHeadless then
    env.info("TCS(INIT): Headless Mode active (Flag 285000 > 9). Skipping Player Menus/API.")
else
    -- Load API Layer
    load_tcs([[api\a2g.lua]])
    load_tcs([[api\a2a.lua]])
    load_tcs([[api\training_a2a.lua]])
    load_tcs([[api\training_a2g.lua]])
    load_tcs([[api\jtac.lua]])

    -- Load Radio Menus
    if menusEnabled then
        env.info("TCS(INIT): Initializing Player Radio Menus...")
        load_tcs([[menus\menu_builder.lua]])
        load_tcs([[menus\root.lua]])
        load_tcs([[menus\training.lua]])
        load_tcs([[menus\a2a.lua]])
        load_tcs([[menus\a2g.lua]])
        load_tcs([[menus\mar.lua]])
        load_tcs([[menus\suw.lua]])
        load_tcs([[menus\tasking.lua]])
        load_tcs([[menus\admin.lua]])
    end

    -- Load Admin/Social
    load_tcs([[admin\admin.lua]])
    load_tcs([[admin\chat_commands.lua]])
end

-- 8. Final System Setup
if SetupAwacs then pcall(SetupAwacs) end

env.info("TCS(INIT): Initialization Complete.")
