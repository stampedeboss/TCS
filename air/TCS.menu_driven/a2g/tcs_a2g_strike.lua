
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

function TCS.A2G.STRIKE.Start(session, anchor, echelon, group)
  -- 1. Standard Scenario Setup
  local biased = TCS.Scenario.Setup(session, TAG, anchor, group, {Bias=true, domain="A2G"})
  if not biased then return end

  echelon = TCS.ResolveDifficulty(session, "LAND", echelon)

  local enemySide = coalition.side.RED
  if group then
    enemySide = (group:GetCoalition() == coalition.side.RED) and coalition.side.BLUE or coalition.side.RED
  elseif session and session.Coalition then
    enemySide = (session.Coalition == coalition.side.RED) and coalition.side.BLUE or coalition.side.RED
  end

  local force = TCS.A2G.ForceSpawner.Spawn(session, FORCE, echelon, biased, {coalition=enemySide})

  -- Draw Zone on F10 Map
  TCS.Scenario.Draw(session, TAG, biased, echelon, 3000, {1,0,0,1}, {1,0,0,0.15})

  if group then TCS.A2G.Feedback.ToGroup(group, "STRIKE tasking established", 10) end

  if TCS.Controller and TCS.Controller.OnEvent then
    TCS.Controller:OnEvent("A2G_START", { session = session, anchor = biased, type = "STRIKE" })
  end
end

function TCS.A2G.STRIKE.MenuRequest(group)
  if not group then return end
  local session = TCS.SessionManager:GetOrCreateSessionForGroup(group)
  if not session then return end

  local echelon = nil
  local anchor = TCS.Placement.Resolve(session.OwnerUnit)
  
  TCS.A2G.STRIKE.Start(session, anchor, echelon, group)
end

env.info("TCS(A2G.STRIKE): ready")
