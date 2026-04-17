---------------------------------------------------------------------
-- TCS COMMON: ECHELON CONFIGURATION
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Common = TCS.Common or {}
TCS.Common.Config = TCS.Common.Config or {}

TCS.Common.Config.Echelons = {
    PLATOON = { scale = 1, spacing = 50 },
    COMPANY = { scale = 3, spacing = 75 },
    BATTALION = { scale = 9, spacing = 100 },
    BRIGADE = { scale = 27, spacing = 150 },

    -- Special Echelon for custom spawns
    SPAWN = { scale = 1, spacing = 150, label = "Spawn Force" },
    
    -- Maritime Echelons (examples)
    PATROL = { scale = 1, spacing = 200 },
    TASK_UNIT = { scale = 2, spacing = 300 },
}

env.info("TCS(COMMON.CONFIG.ECHELONS): ready")