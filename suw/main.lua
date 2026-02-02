---------------------------------------------------------------------
-- TCS SUW (Surface Warfare) — Stub
---------------------------------------------------------------------
env.info("TCS(SUW): initializing")

TCS = TCS or {}
TCS.SUW = TCS.SUW or {}

function TCS.SUW.Start(group, context)
  local rec = TCS.Players.Get(group)
  if not rec then return end

  env.info("TCS(SUW): start requested")
  -- future: spawn combatants, assign ISR, task escorts
end

env.info("TCS(SUW): ready")
