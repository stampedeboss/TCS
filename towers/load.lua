---------------------------------------------------------------------
-- TCS MASTER LOADER
-- Responsible for initializing the TCS framework in the correct order.
---------------------------------------------------------------------
env.info("TCS(LOAD): Starting initialization...")

TCS = TCS or {}

-- Determine the base path for loading. 
-- This assumes TCS is located in Missions/Scripts/DCS/TCS/ within the DCS write directory.
local BASE_PATH = lfs.writedir() .. [[Missions\Scripts\DCS\TCS\]]

local function load_tcs(file)
    local path = BASE_PATH .. file
    local f, err = loadfile(path)
    if not f then
        env.error("TCS(LOAD): Could not load " .. path .. ": " .. tostring(err))
    else
        local status, result = pcall(f)
        if not status then
            env.error("TCS(LOAD): Execution error in " .. path .. ": " .. tostring(result))
        end
    end
end

-- 1. Load Configuration & Catalogs
load_tcs([[common\config.lua]])
load_tcs([[common\config_echelons.lua]])
load_tcs([[config\catalog_ground_units.lua]])
load_tcs([[config\ground\defaults.lua]])
load_tcs([[config\catalog_air_qrf.lua]])
load_tcs([[config\catalog_a2a_bandits.lua]])
load_tcs([[config\catalog_a2a_packages.lua]])
load_tcs([[config\catalog_structures.lua]])
load_tcs([[config\catalog_sea_units.lua]])
load_tcs([[config\a2g_config.lua]])
load_tcs([[config\a2a_config.lua]])

-- 2. Load Common Layer (Foundations & Utilities)
load_tcs([[common\spawn_spacing.lua]])
load_tcs([[common\session.lua]])
load_tcs([[common\session_manager.lua]])
load_tcs([[common\spawn_utils.lua]])
load_tcs([[common\warehouse_utils.lua]])
load_tcs([[common\scenario_geometry.lua]])
load_tcs([[common\scenario_difficulty.lua]])
load_tcs([[common\scenario_f10.lua]])
load_tcs([[common\scenario.lua]])
load_tcs([[common\catalog_registry.lua]])
load_tcs([[common\spawner_ground.lua]])
load_tcs([[common\dispatcher.lua]])
load_tcs([[common\tracker.lua]])
load_tcs([[common\task_manager.lua]])
load_tcs([[common\registry.lua]])
load_tcs([[common\awacs.lua]])
load_tcs([[common\catalog.lua]])

-- 2. Load Towers (Domain Specialists)
-- Note: Data is loaded before the Orchestrator so the Catalog is populated.
load_tcs([[towers\ground_catalog.lua]])
load_tcs([[towers\ground_compositions.lua]])
load_tcs([[towers\ground_behavior.lua]])
load_tcs([[towers\ground_inventory.lua]])
load_tcs([[towers\ground_data.lua]])
load_tcs([[towers\ground.lua]])

-- 3. Load Directors (Intent & Logistics)
load_tcs([[mission\architect.lua]])
-- load_tcs([[logistics\architect.lua]]) -- Placeholder for when created

-- 4. Load Direct Interfaces (Simplified Trigger Layer)
load_tcs([[direct\a2g.lua]])
load_tcs([[direct\custom.lua]])

env.info("TCS(LOAD): Initialization complete.")

-- Verification: Check if the Global Trigger exists
if _G.TriggerMissionBAI then env.info("TCS(LOAD): Global TriggerMissionBAI is active.") end
if _G.TriggerSystemSpawn then env.info("TCS(LOAD): Global TriggerSystemSpawn is active.") end