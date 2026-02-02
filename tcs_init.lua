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

-- configurations and catalogs


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

-- A2A
dofile(_G.PATH.TCS_A2A .. [[tcs_a2a_config.lua]])
dofile(_G.PATH.TCS_A2A .. [[tcs_a2a.lua]])
dofile(_G.PATH.TCS_A2A .. [[tcs_a2a_cap.lua]])
dofile(_G.PATH.TCS_A2A .. [[tcs_a2a_escort.lua]])
dofile(_G.PATH.TCS_A2A .. [[tcs_a2a_sweep.lua]])

-- A2G modes
dofile(_G.PATH.TCS_A2G .. [[tcs_a2g_range.lua]])
dofile(_G.PATH.TCS_A2G .. [[tcs_a2g_cas.lua]])
dofile(_G.PATH.TCS_A2G .. [[tcs_a2g_bai.lua]])
dofile(_G.PATH.TCS_A2G .. [[tcs_a2g_sead.lua]])
dofile(_G.PATH.TCS_A2G .. [[tcs_a2g_dead.lua]])
dofile(_G.PATH.TCS_A2G .. [[tcs_a2g_strike.lua]])

-- Admin
dofile(_G.PATH.TCS_ADMIN .. [[admin.lua]])

-- Menu system (definitions only)
dofile(_G.PATH.TCS_MENUS .. [[menu_builder.lua]])
dofile(_G.PATH.TCS_MENUS .. [[root.lua]])
dofile(_G.PATH.TCS_MENUS .. [[training.lua]])
dofile(_G.PATH.TCS_MENUS .. [[a2a.lua]])
dofile(_G.PATH.TCS_MENUS .. [[a2g.lua]])
dofile(_G.PATH.TCS_MENUS .. [[admin.lua]])

env.info("TCS(INIT): complete")
