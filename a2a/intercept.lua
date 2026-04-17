---------------------------------------------------------------------
-- TCS A2A INTERCEPT
--
-- Purpose:
--   Spawns an adversary group in an intercept geometry relative to
--   the requesting group.
---------------------------------------------------------------------
env.info("TCS(A2A.INTERCEPT): loading")

TCS = TCS or {}
TCS.A2A = TCS.A2A or {}
TCS.A2A.INTERCEPT = {}

--- Starts an Intercept scenario.
-- @param rec (table) The context record { Group, Unit, Session }.
-- @param difficulty (string) Optional override (A/G/H/X).
function TCS.A2A.INTERCEPT:Start(rec, difficulty)
  if not rec or not rec.Group then return end
  
  local session = rec.Session

  -- 1. Determine Difficulty
  local diff = difficulty or (session and session.Difficulty) or "G"

  -- 2. Resolve Bandit Definition
  -- Uses the A2A Core logic to pick a template based on difficulty/era
  local def = TCS.A2A.GetBanditDef({
    role = "INTERCEPT",
    tier = diff
  })
  
  if not def then
    TCS.MsgToGroup(rec.Group, "TCS: No valid INTERCEPT template found for tier " .. diff)
    return
  end

  -- 3. Spawn Logic (Delegated to A2A Core SpawnBandit)
  -- Intercept usually spawns Hot/Flank 40-80nm out.
  -- Passing '0' as bearing/distance lets the core A2A solver handle randomization based on intent.
  -- Or we can calculate specific geometry here if desired.
  local anchor = rec.Unit:GetCoordinate()
  local spawnName = "TCS_INT_" .. rec.Group:GetName() .. "_" .. math.random(1000)
  
  -- Note: We assume the A2A core handles the "INTERCEPT" intent and returns the spawned groups.
  local spawnedGroups
  if TCS.A2A.SpawnPackage then
    spawnedGroups = TCS.A2A.SpawnPackage(session, rec.Group, def, "INTERCEPT", spawnName)
  else
    TCS.MsgToGroup(rec.Group, "TCS: A2A Core SpawnPackage not available.")
    return
  end

  local taskHandle = {
    SpawnedGroups = spawnedGroups,
    StartTime = timer.getTime(),
    Duration = 3600, -- 1 hour default lifetime
  }

  function taskHandle:IsOver()
    if timer.getTime() > (self.StartTime + self.Duration) then return true, "TIMEOUT" end
    
    local aliveCount = 0
    for _, g in ipairs(self.SpawnedGroups or {}) do
      if g and g:IsAlive() then aliveCount = aliveCount + 1 end
    end
    if aliveCount == 0 then return true, "COMPLETE" end
    
    return false
  end

  return taskHandle
end

env.info("TCS(A2A.INTERCEPT): ready")