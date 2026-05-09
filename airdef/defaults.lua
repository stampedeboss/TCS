---------------------------------------------------------------------
-- TCS AIRDEF: DEFAULTS & CONFIGURATION
---------------------------------------------------------------------
TCS = TCS or {}
TCS.AirDef = TCS.AirDef or {}

TCS.AirDef.Defaults = {
    -- Geometry & Organic Jitter
    MAX_SPAWN_NM = 2,
    JITTER_POS_MIN = -5,       -- Meters
    JITTER_POS_MAX = 5,        -- Meters
    JITTER_HDG_MIN = -10,      -- Degrees
    JITTER_HDG_MAX = 10,       -- Degrees
    
    -- Radar / Ambush Ranges
    RADAR_ACTIVATE_NM = 15,
    SILENT_MULTIPLIER_HIGH = 0.8,
    SILENT_MULTIPLIER_EXTREME = 0.5,
    
    -- Fallbacks
    FALLBACK_YEAR = 2040,      -- Permissive future year if global limit isn't set
    FALLBACK_INVENTORY = 999,  -- Infinite supply if logistics tracking is off
    FALLBACK_SAM_TYPE = "SA-6",
    
    -- Mission Architect Thresholds
    DEAD_GUARD_MIN_NM = 0.5,
    DEAD_GUARD_MAX_NM = 2.0,
    DEAD_ATTRITION_THRESHOLD = 0.50,
    SEAD_ATTRITION_THRESHOLD = 0.70
}

env.info("TCS(AIRDEF.DEFAULTS): loaded")