---------------------------------------------------------------------
-- TCS AIR ESCORT
--
-- Purpose:
--   Spawns a friendly package (e.g., Strike, AWACS, Tanker) for the
--   player to escort.
---------------------------------------------------------------------
env.info("TCS(AIR.ESCORT): loading")

TCS = TCS or {}
TCS.Air = TCS.Air or {}
TCS.Air.ESCORT = {}

--- Starts an Escort scenario.
-- @param rec (table) The context record { Group, Unit, Session }.
-- @param packageType (string) The type of package to spawn (e.g., "STRIKE", "AWACS_E3").
function TCS.Air.ESCORT:Start(rec, packageType)
  if not rec or not rec.Group then return end
  
  local session = rec.Session
  if not session then
    session = TCS.SessionManager:GetOrCreateSessionForGroup(rec.Group)
  end

  -- Default package if none provided
  local pkg = packageType or "STRIKE"

  -- Resolve Definition
  -- This relies on Air Core or Catalog to resolve "STRIKE" to a specific template/group data
  -- For now, we assume TCS.Air.GetFriendlyPackageDef exists or we use a generic placeholder logic
  -- similar to the other modules.
  local def = TCS.Air.GetFriendlyPackageDef and TCS.Air.GetFriendlyPackageDef(pkg)
  
  if not def and TCS.Air.GetBanditDef then
     -- Fallback: try to find a definition using the bandit system but for friendly coalition
     -- This is often how simple escorts are hacked in if a dedicated friendly catalog isn't built yet
     def = TCS.Air.GetBanditDef({ role = pkg, tier = "G" }) 
  end

  if not def then
    TCS.MsgToGroup(rec.Group, "TCS: No valid ESCORT package found for type: " .. pkg)
    return
  end

  local spawnName = "TCS_ESC_" .. pkg .. "_" .. math.random(1000)
  
  -- Delegate to Core Spawner
  -- The core SpawnPackage logic usually handles the geometry (e.g. spawn near player, or at a specific point)
  local escortedPackage
  if TCS.Air.SpawnPackage then
    -- "ESCORT" intent usually implies spawning the friendly *near* the player to be escorted
    escortedPackage = TCS.Air.SpawnPackage(session, rec.Group, def, "ESCORT", spawnName, coalition.side.BLUE)
  else
    TCS.MsgToGroup(rec.Group, "TCS: A2A Core SpawnPackage not available.")
    return
  end

  local taskHandle = {
    EscortedGroups = escortedPackage,
    StartTime = timer.getTime(),
    Duration = 7200, -- 2 hour default lifetime
  }

  function taskHandle:IsOver()
    if timer.getTime() > (self.StartTime + self.Duration) then return true, "COMPLETE" end -- Assume success if time runs out
    
    local aliveCount = 0
    for _, g in ipairs(self.EscortedGroups or {}) do
      if g and g:IsAlive() then aliveCount = aliveCount + 1 end
    end
    -- If all escorted assets are destroyed, the task has failed.
    if aliveCount == 0 then return true, "FAILED" end
    
    return false
  end

  return taskHandle
end

env.info("TCS(AIR.ESCORT): ready")