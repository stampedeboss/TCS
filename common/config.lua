---------------------------------------------------------------------
-- TCS COMMON: CONFIGURATION
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Common = TCS.Common or {}
TCS.Common.Config = {
    VERSION = "1.1.2", -- Use this to verify server deployment
    LOGISTICS_ENABLED = false, -- Set to false for unlimited supply until logistics are built
    DRAW_ZONE_OUTLINES = true, -- Set to true to draw the actual trigger zone boundaries on F10
    REINFORCEMENTS_ALLOWED = true, -- Global toggle for theater reinforcement logic
    MISSION_YEAR_FLAG = 285999, -- User flag to set mission year for era filtering
    DifficultyMap = { -- Maps Tier (1-4) to Echelon names for different domains
        [1] = { LAND = "PLATOON", SEA = "PATROL", AIR = "SECTION" },
        [2] = { LAND = "COMPANY", SEA = "TASK_UNIT", AIR = "SQUADRON" },
        [3] = { LAND = "BATTALION", SEA = "TASK_GROUP", AIR = "WING" },
        [4] = { LAND = "BRIGADE", SEA = "TASK_FORCE", AIR = "AIR_DIVISION" },
    },
}

--- Resolves the current Mission Year based on the DCS Flag offset from 1940.
function TCS.Common.Config.GetMissionYear()
    local flagVal = trigger.misc.getUserFlag(TCS.Common.Config.MISSION_YEAR_FLAG or 285999)
    -- If flag is 0, we assume 'Modern/Unlimited' (0), otherwise calculate from 1940
    return (flagVal > 0) and (1940 + flagVal) or 0
end

-- Seed the random generator for unique unit selection and geometry
-- Use timer.getAbsTime() as a fallback for sanitized environments
if math.randomseed then
    -- Create a more entropy-rich seed using absolute time and fractional seconds
    local seed = (timer and timer.getAbsTime()) and (math.floor(timer.getAbsTime() * 1000) % 2147483647) or 12345
    math.randomseed(seed)
    -- Advance the PRNG sequence to clear initial bias
    math.random(); math.random(); math.random()
end

env.info("TCS(COMMON.CONFIG): ready")