---------------------------------------------------------------------
-- TCS MAR (Maritime / Civilian) — Stub
---------------------------------------------------------------------
env.info("TCS(MAR): initializing")

TCS = TCS or {}
TCS.MAR = TCS.MAR or {}

function TCS.MAR.StartPortOps(group, context)
  local rec = TCS.Players.Get(group)
  if not rec then return end

  env.info("TCS(MAR): port operations requested")
end

function TCS.MAR.StartShippingEscort(group, context)
  local rec = TCS.Players.Get(group)
  if not rec then return end

  env.info("TCS(MAR): shipping escort requested")
end

env.info("TCS(MAR): ready")
