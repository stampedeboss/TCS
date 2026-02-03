
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

function TCS.A2G.STRIKE(session)
  if not session then return end

  local echelon = TCS.GetEchelonForSession(session)
  local anchor  = TCS.A2G.Placement.Resolve(session)
  local biased  = TCS.A2G.PlacementBias.Resolve(anchor, "STRIKE")

  local force = TCS.A2G.ForceSpawner.Spawn(session, "STRIKE", echelon, biased)

  TCS.A2G.Feedback.ToGroup(
    session:GetGroup(),
    "STRIKE tasking established",
    10
  )
end

env.info("TCS(A2G.STRIKE): ready")
