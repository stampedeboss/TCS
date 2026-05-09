---------------------------------------------------------------------
-- TCS INIT (authoritative)
---------------------------------------------------------------------
env.info("TCS(INIT): starting")

TCS = TCS or {}

-- 1. Resolve Script Path
local TCS_PATH = lfs.writedir() .. [[Missions\Scripts\DCS\TCS\]]
env.info("TCS(INIT): Path set to " .. TCS_PATH)

local function load_tcs(file)
  local p = TCS_PATH .. file
  env.info("TCS(INIT): Loading " .. p)
  local f, err = loadfile(p)
  if not f then
    env.error("TCS(INIT): Failed to load " .. p .. ": " .. tostring(err))
  else
    local status, result = pcall(f)
    if not status then
      env.error("TCS(INIT): Error executing " .. p .. ": " .. tostring(result))
    end
  end
end

-- 2. Load Core Utilities
load_tcs("core\\world.lua")
load_tcs("core\\players.lua")
load_tcs("core\\session_class.lua")
load_tcs("core\\session_utils.lua")
load_tcs("core\\session_manager.lua")
load_tcs("core\\session_cleanup.lua")
load_tcs("core\\session_scale.lua")
load_tcs("core\\placements.lua")
load_tcs("core\\placement_bias.lua")
load_tcs("core\\spawn_spacing.lua")
load_tcs("core\\spawn.lua")
load_tcs("core\\force_spawner.lua")
load_tcs("core\\tcs_scenario.lua")
load_tcs("core\\registry.lua")
load_tcs("core\\feedback.lua")
load_tcs("core\\tcs_range.lua")
load_tcs("core\\awacs.lua")
load_tcs("core\\tcs_a2g.lua")
load_tcs("core\\tcs_catalog.lua")

-- 3. Load Configuration
load_tcs("config\\tcs_config.lua")
load_tcs("config\\tcs_a2a_config.lua")
load_tcs("config\\tcs_a2g_config.lua")
load_tcs("config\\tcs_catalog_data.lua")
if TCS.Catalog and TCS.Catalog.Ingest and TCS.Config.Catalog then
  TCS.Catalog.Ingest(TCS.Config.Catalog)
end

-- 4. Load A2A Modules
load_tcs("a2a\\tcs_a2a.lua")
load_tcs("a2a\\tcs_a2a_cap.lua")
load_tcs("a2a\\tcs_a2a_controller.lua")
load_tcs("a2a\\tcs_a2a_intercept.lua")
load_tcs("a2a\\tcs_a2a_escort.lua")
load_tcs("a2a\\tcs_a2a_sweep.lua")
load_tcs("a2a\\tcs_a2a_training.lua")

-- 5. Load A2G Modules
load_tcs("a2g\\tcs_map_core.lua")
load_tcs("a2g\\tcs_zones.lua")
load_tcs("a2g\\tcs_a2g_jtac.lua")
load_tcs("a2g\\tcs_a2g_cas.lua")
load_tcs("a2g\\tcs_a2g_bai.lua")
load_tcs("a2g\\tcs_a2g_sead.lua")
load_tcs("a2g\\tcs_a2g_dead.lua")
load_tcs("a2g\\tcs_a2g_strike.lua")
load_tcs("a2g\\tcs_a2g_logistics.lua")
load_tcs("a2g\\tcs_suw.lua")
load_tcs("a2g\\tcs_mar.lua")

-- 6. Load Menus & Admin
load_tcs("menus\\menu_builder.lua")
load_tcs("menus\\root.lua")
load_tcs("menus\\training.lua")
load_tcs("menus\\a2a.lua")
load_tcs("menus\\a2g.lua")
load_tcs("menus\\mar.lua")
load_tcs("menus\\suw.lua")
load_tcs("menus\\admin.lua")
load_tcs("menus\\tasking.lua")
load_tcs("admin\\admin.lua")
load_tcs("admin\\chat_commands.lua")

-- Final Setup
if SetupAwacs then SetupAwacs() end

env.info("TCS(INIT): Complete.")
