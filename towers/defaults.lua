---------------------------------------------------------------------
-- TCS CONFIG: AIRDEF DEFAULTS
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Config = TCS.Config or {}
TCS.Config.AirDef = TCS.Config.AirDef or {}

TCS.Config.AirDef.Defaults = {
    -- Engagement distance for 'Silent' sites (NM)
    RADAR_ACTIVATE_NM = 15,
    
    -- Default placement offsets
    GEOMETRY = {
        MIN_SPAWN_NM = 0,
        MAX_SPAWN_NM = 2,
        DEFAULT_HDG = 0
    }
}

env.info("TCS(CONFIG.AIRDEF.DEFAULTS): ready")