---------------------------------------------------------------------
-- TCS MARITIME (MAR)
-- Control of sea lines of communication (SLOC) and ports.
---------------------------------------------------------------------
env.info("TCS(MAR): loading")

TCS = TCS or {}
TCS.MAR = {}

function TCS.MAR.Start(session, anchor, forceName, label, move, group, echelon)
  -- Delegate to SUW module which contains the superset of logic (including traffic)
  if TCS.SUW and TCS.SUW.Start then
    TCS.SUW.Start(session, anchor, forceName, label, move, group, echelon)
  end
end

local function MenuRequest(group, forceName, label, move)
  local session = TCS.SessionManager:GetOrCreateSessionForGroup(group)
  if not session then return end
  local unit = group:GetUnit(1)
  local point = TCS.Placement.Resolve(unit, "SEA")
  TCS.MAR.Start(session, point, forceName, label, move, group)
end

function TCS.MAR.StartHarbor(group)
  MenuRequest(group, "MAR_HARBOR", "Harbor", false)
end

function TCS.MAR.StartShipping(group)
  MenuRequest(group, "MAR_CONVOY", "Shipping", true)
end

env.info("TCS(MAR): ready")