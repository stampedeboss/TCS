---------------------------------------------------------------------
-- TCS MARITIME (MAR)
-- Control of sea lines of communication (SLOC) and ports.
---------------------------------------------------------------------
env.info("TCS(MAR): loading")

TCS = TCS or {}
TCS.MAR = {}

function TCS.MAR.Start(rec, forceName, label, move, echelon)
  -- Delegate to SUW module which contains the superset of logic (including traffic)
  if TCS.SUW and TCS.SUW.Start then
    return TCS.SUW.Start(rec, forceName, label, move, echelon)
  end
end

function TCS.MAR.StartHarbor(rec)
  return TCS.MAR.Start(rec, "MAR_HARBOR", "Harbor", false)
end

function TCS.MAR.StartShipping(rec)
  return TCS.MAR.Start(rec, "MAR_CONVOY", "Shipping", true)
end

env.info("TCS(MAR): ready")