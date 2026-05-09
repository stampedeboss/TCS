---------------------------------------------------------------------
-- TCS COMMON: DEFAULTS & CONFIGURATION
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Common = TCS.Common or {}

TCS.Common.Defaults = {
    LOGISTICS_ENABLED = false,
    EnableF10Menus = true,          -- Toggle to enable/disable the F10 Radio Menus
    Coalition = coalition.side.BLUE,
    
    -- Admin UCIDs (Server Admins)
    -- If empty, ALL players can use admin commands (Dev Mode).
    Admins = {
        "9206bc8a296341b4d1610f4bd5ecad6b",
    },
    
    ServiceYearLimit = 2040, -- Default permissive future year

    -- FORCE SCALING & DIFFICULTY
    Echelons = {
        -- Land
        PLATOON   = { scale=1,  spacing=30, tier="A" },
        COMPANY   = { scale=3,  spacing=50, tier="G" },
        BATTALION = { scale=5,  spacing=75, tier="H" },
        BRIGADE   = { scale=7, spacing=100, tier="X" },
        -- Sea
        SEA_PATROL = { scale=1, spacing=4000, tier="A" },
        TASK_UNIT  = { scale=2, spacing=1000, tier="G" },
        TASK_GROUP = { scale=3, spacing=2000, tier="H" },
        TASK_FORCE = { scale=4, spacing=4000, tier="X" },
        -- Air
        PATROL       = { scale=2, spacing=4000, tier="A" },
        SQUADRON     = { scale=4, spacing=1000, tier="G" },
        WING         = { scale=5, spacing=2000, tier="H" },
        AIR_DIVISION = { scale=6, spacing=4000, tier="X" }
    },
    
    DifficultyMap = {
        [1] = { LAND="PLATOON",   SEA="SEA_PATROL", AIR="PATROL" },
        [2] = { LAND="COMPANY",   SEA="TASK_UNIT",  AIR="SQUADRON" },
        [3] = { LAND="BATTALION", SEA="TASK_GROUP", AIR="WING" },
        [4] = { LAND="BRIGADE",   SEA="TASK_FORCE", AIR="AIR_DIVISION" },
    }
}

env.info("TCS(COMMON.DEFAULTS): loaded")
