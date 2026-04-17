---------------------------------------------------------------------
-- TCS CONFIG: AIRDEF DEFAULTS
-- Tuning parameters for SAM sites and point defense.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Config = TCS.Config or {}
TCS.Config.AirDef = {
    Defaults = {
        -- Engagement distance for 'Silent' sites (NM)
        RADAR_ACTIVATE_NM = 15,
        
        -- Default placement offsets
        GEOMETRY = {
            MIN_SPAWN_NM = 0,
            MAX_SPAWN_NM = 2,
            DEFAULT_HDG = 0,
            DEFAULT_RADIUS_NM = 1.0
        },
        
        REINFORCE_THRESHOLD = 0.75 -- AirDef is more fragile than Ground
    }
}
env.info("TCS(CONFIG.AIRDEF.DEFAULTS): ready")