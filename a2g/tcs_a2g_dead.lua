
---------------------------------------------------------------------
-- TCS A2G DEAD
--
-- Purpose:
--   Destruction of Enemy Air Defenses
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

env.info("TCS(A2G.DEAD): loading")

function TCS.A2G.DEAD(group)
  if not group then return end
  local session = TCS.SessionManager:GetOrCreateSessionForGroup(group)
  if not session then return end

  local echelon = TCS.GetEchelonForSession(session)
  local anchor, reason  = TCS.Placement.Resolve(group:GetUnit(1))
  if not anchor then
    TCS.A2G.Feedback.ToGroup(group, "DEAD tasking failed: No suitable location found.", 10)
    return
  end
  local biased  = TCS.A2G.PlacementBias.Resolve(anchor, "DEAD")

  local force = TCS.A2G.ForceSpawner.Spawn(session, "DEAD", echelon, biased)

  TCS.A2G.Feedback.ToGroup(
    group,
    "DEAD tasking established",
    10
  )
end

env.info("TCS(A2G.DEAD): ready")
