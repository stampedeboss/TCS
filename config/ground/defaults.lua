---------------------------------------------------------------------
-- TCS CONFIG: GROUND DEFAULTS
-- Consolidates all ground-specific tuning parameters and defaults.
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Config = TCS.Config or {}
TCS.Config.Ground = {
    Defaults = {
        -- Mission-Specific Setup Defaults
        MISSION_DEFAULTS = {
            BAI = { minNm = 15, maxNm = 25, transitTime = 20 },
            CAS = { separationNm = 3 },
            SPAWN = { minNm = 5, maxNm = 10 },
            REINFORCE_THRESHOLD = 0.65
        },

        -- Tower Domain Performance Constants
        PERFORMANCE_CONSTANTS = {
            MOVE_SPEED_KPH = 25,      -- Standard mechanized march speed
            INFANTRY_SPEED_KPH = 10,  -- Standard infantry movement speed
            MAX_TACTICAL_SPEED = 60   -- Maximum allowed speed for any ground unit
        },

        -- Geometry Defaults
        GEOMETRY = {
            DEFAULT_SPAWN_RADIUS_NM = 5000 / 1852 -- Convert 5000m to NM
        }
    }
}
env.info("TCS(CONFIG.GROUND.DEFAULTS): ready")