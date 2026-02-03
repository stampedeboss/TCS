---------------------------------------------------------------------
-- TCS INIT (authoritative)
---------------------------------------------------------------------
env.info("TCS(INIT): starting")
_G.PATH.TCS       = lfs.writedir() .. [[Missions/Scripts/TCS/]]
_G.PATH.TCS_CORE  = _G.PATH.TCS .. [[core/]]
_G.PATH.TCS_A2A   = _G.PATH.TCS .. [[a2a/]]
_G.PATH.TCS_A2G   = _G.PATH.TCS .. [[a2g/]]
_G.PATH.TCS_ADMIN = _G.PATH.TCS .. [[admin/]]
_G.PATH.TCS_MENUS = _G.PATH.TCS .. [[menus/]]
_G.PATH.TCS_CONFIG = _G.PATH.TCS .. [[config/]]

-- configurations and catalogs
dofile(_G.PATH.TCS_CONFIG .. [[components.lua]])
dofile(_G.PATH.TCS_CONFIG .. [[forces.lua]])
dofile(_G.PATH.TCS_CONFIG .. [[echelons.lua]])
dofile(_G.PATH.TCS_A2G .. [[tcs_a2g_config.lua]])

-- World / utilities
dofile(_G.PATH.TCS_CORE .. [[world.lua]])
dofile(_G.PATH.TCS_CORE .. [[players.lua]])
dofile(_G.PATH.TCS_CORE .. [[session_manager.lua]])
dofile(_G.PATH.TCS_CORE .. [[session_scale.lua]])

dofile(_G.PATH.TCS_CORE .. [[placements.lua]])
dofile(_G.PATH.TCS_CORE .. [[placement_bias.lua]])
dofile(_G.PATH.TCS_CORE .. [[spawn.lua]])
dofile(_G.PATH.TCS_CORE .. [[spawn_spacing.lua]])
dofile(_G.PATH.TCS_CORE .. [[force_spawner.lua]])
dofile(_G.PATH.TCS_CORE .. [[registry.lua]])
dofile(_G.PATH.TCS_CORE .. [[feedback.lua]])
dofile(_G.PATH.TCS_CORE .. [[awacs.lua]])

-- A2A
dofile(_G.PATH.TCS_A2A .. [[tcs_a2a_config.lua]])
dofile(_G.PATH.TCS_A2A .. [[tcs_a2a.lua]])
dofile(_G.PATH.TCS_A2A .. [[tcs_a2a_cap.lua]])
dofile(_G.PATH.TCS_A2A .. [[tcs_a2a_controller.lua]])
dofile(_G.PATH.TCS_A2A .. [[tcs_a2a_intercept.lua]])
dofile(_G.PATH.TCS_A2A .. [[tcs_a2a_escort.lua]])
dofile(_G.PATH.TCS_A2A .. [[tcs_a2a_sweep.lua]])
dofile(_G.PATH.TCS_A2A .. [[tcs_a2a_training.lua]])

-- A2G modes
dofile(_G.PATH.TCS_A2G .. [[tcs_a2g_range.lua]])
dofile(_G.PATH.TCS_A2G .. [[tcs_a2g_jtac.lua]])
dofile(_G.PATH.TCS_A2G .. [[tcs_a2g_cas.lua]])
dofile(_G.PATH.TCS_A2G .. [[tcs_a2g_bai.lua]])
dofile(_G.PATH.TCS_A2G .. [[tcs_a2g_sead.lua]])
dofile(_G.PATH.TCS_A2G .. [[tcs_a2g_dead.lua]])
dofile(_G.PATH.TCS_A2G .. [[tcs_a2g_strike.lua]])
dofile(_G.PATH.TCS_A2G .. [[tcs_mar.lua]])
dofile(_G.PATH.TCS_A2G .. [[tcs_suw.lua]])

-- Admin
dofile(_G.PATH.TCS_ADMIN .. [[admin.lua]])

-- Menu system (definitions only)
dofile(_G.PATH.TCS_MENUS .. [[menu_builder.lua]])
dofile(_G.PATH.TCS_MENUS .. [[root.lua]])
dofile(_G.PATH.TCS_MENUS .. [[training.lua]])
dofile(_G.PATH.TCS_MENUS .. [[a2a.lua]])
dofile(_G.PATH.TCS_MENUS .. [[a2g.lua]])
dofile(_G.PATH.TCS_MENUS .. [[admin.lua]])

-- Final Setup
if SetupAwacs then SetupAwacs() end

env.info("TCS(INIT): complete")
