
---------------------------------------------------------------------
-- TCS A2G SEAD
--
-- Purpose:
--   Suppression of Enemy Air Defenses
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

env.info("TCS(A2G.SEAD): loading")

function TCS.A2G.SEAD(session)
  if not session then return end

  local echelon = TCS.GetEchelonForSession(session)
  local anchor  = TCS.A2G.Placement.Resolve(session)
  local biased  = TCS.A2G.PlacementBias.Resolve(anchor, "SEAD")

  local force = TCS.A2G.ForceSpawner.Spawn(session, "SEAD", echelon, biased)

  for _, obj in ipairs(force or {}) do
    TCS.A2G.Registry:Register(session, obj)
  end

  TCS.A2G.Feedback.ToGroup(
    session:GetGroup(),
    "SEAD tasking established",
    10
  )
end

env.info("TCS(A2G.SEAD): ready")
