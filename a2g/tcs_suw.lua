SUW = {}
SUW.__index = SUW

--========================
-- CONFIGURATION
--========================
SUW.Config = {
  PatrolZones = {
    ZONE_1 = "SUW_ZONE_1",
    ZONE_2 = "SUW_ZONE_2",
    FAR_END = "SUW_ZONE_FAR",
  },

  BarrierDistanceNM = 40,   -- first failure threshold
  EscalationDelay = {
    WARNING = 300,          -- seconds
    BREACH  = 600,
  },

  Band = 0,                -- escalation band (0 = SUW only)
}

--========================
-- RUNTIME STATE
--========================
SUW.State = {
  Phase = "PATROL",        -- PATROL | DEGRADED | BREACH | STRIKE
  PatrolStatus = {},       -- per-zone status
  WinchesterZones = {},   -- zones with no patrol weapons
  LastContactTime = {},
  BarrierBreached = false,
}

--========================
-- INIT
--========================
function SUW:Init()
  self:InitZones()
  self:InitScheduler()
  env.info("[SUW] Mission brain initialized")
end
