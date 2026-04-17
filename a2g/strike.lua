
---------------------------------------------------------------------
-- TCS A2G STRIKE
--
-- Purpose:
--   Planned strike against fixed objectives
--
-- Execution Model:
--   • Session-owned
--   • Scales via echelon
--   • Uses shared placement authority
--
-- Lifecycle:
--   • All spawned objects registered
--   • Auto-cleanup on session end / owner loss
--
-- Notes:
--   • This module contains NO direct spawn logic
--   • Force composition delegated to ForceSpawner
---------------------------------------------------------------------

env.info("TCS(A2G.STRIKE): loading")

TCS.A2G.STRIKE = {}

local TAG = "STRIKE"
local FORCE = "STRIKE"

function TCS.A2G.STRIKE:Start(rec, anchor, echelon)
  if not rec then return end
  local group = rec.Group
  local session = rec.Session or TCS.SessionManager:GetOrCreateSessionForGroup(group)

  -- Resolve anchor: If a zone is provided, objective is zone center, spawn is random in zone.
  local targetZone, zoneOverrides = TCS.Scenario.ResolveZone(anchor)

  -- Initial determination of spawnAnchor and objective (anchor)
  local spawnAnchor = anchor
  if targetZone then
    spawnAnchor = targetZone:GetRandomCoordinate()
    anchor = targetZone:GetCoordinate() -- Objective is the center of the zone
  end

  -- 1. Standard Scenario Setup (This `anchor` is the final objective, potentially biased)
  local biased = TCS.Scenario.Setup(session, TAG, anchor, group, {Bias=true, domain="A2G"})
  if not biased then return end

  echelon = TCS.ResolveDifficulty(session, "LAND", echelon)

  local enemySide = coalition.side.RED
  if session and session.Coalition then
    enemySide = (session.Coalition == coalition.side.RED) and coalition.side.BLUE or coalition.side.RED
  elseif rec and rec.Params and rec.Params.coalition then
    -- For system tasks, the coalition of the *spawned units* must be specified in the API call
    enemySide = rec.Params.coalition
  end

  local spawnAnchor = biased
  local cfg = TCS.A2G.Config.STRIKE or {}
  local minNm = rec.Params.minNm or zoneOverrides.minNm or cfg.MIN_SPAWN_DISTANCE_NM or 0
  local maxNm = rec.Params.maxNm or zoneOverrides.maxNm or cfg.MAX_SPAWN_DISTANCE_NM or minNm

  if maxNm > 0 and targetZone then
    local coal = rec.Params.coalition or enemySide
    local overrideHdg = rec.Params.ingressHdg or zoneOverrides.ingressHdg
    local overrideArc = rec.Params.ingressArc or zoneOverrides.ingressArc
    spawnAnchor, _ = TCS.Scenario.CalculateSpawnPoint(biased, coal, minNm, maxNm, overrideHdg, overrideArc)
    env.info(string.format("TCS(STRIKE): Generated directional spawn at %.1f NM from objective center", (spawnAnchor:Get2DDistance(biased)/1852)))
  end

  local force = TCS.A2G.ForceSpawner.Spawn(session, FORCE, echelon, spawnAnchor, {coalition=enemySide})

  -- Draw Zone on F10 Map
  TCS.Scenario.Draw(session, TAG, biased, echelon, 3000, {1,0,0,1}, {1,0,0,0.15})

  if group then TCS.A2G.Feedback.ToGroup(group, "STRIKE tasking established", 10) else env.info("TCS(STRIKE): System task established.") end

  if TCS.Controller and TCS.Controller.OnEvent then
    TCS.Controller:OnEvent("A2G_START", { session = session, anchor = biased, type = "STRIKE" })
  end

  -- Create and return a task handle for the Task Manager
  local taskHandle = {
    SpawnedGroups = force,
    StartTime = timer.getTime(),
    Duration = 3600, -- Default 1-hour lifetime
  }

  -- Method for the Task Manager to check if the task is complete
  function taskHandle:IsOver()
    if timer.getTime() > (self.StartTime + self.Duration) then return true, "TIMEOUT" end
    
    local aliveCount = 0
    for _, g in ipairs(self.SpawnedGroups or {}) do
      if g and g:IsAlive() then
        aliveCount = aliveCount + 1
      end
    end
    if aliveCount == 0 then return true, "COMPLETE" end
    
    return false
  end

  -- The Terminate method is implicitly handled by TCS.Scenario.Stop()

  return taskHandle
end

env.info("TCS(A2G.STRIKE): ready")
