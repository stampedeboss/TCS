---------------------------------------------------------------------
-- TCS MARITIME (MAR)
-- Control of sea lines of communication (SLOC) and ports.
---------------------------------------------------------------------
env.info("TCS(MAR): loading")

TCS = TCS or {}
TCS.MAR = {}

local TAG = "MAR"

local function StartMarScenario(group, forceName, label, move)
  local session = TCS.SessionManager:GetOrCreateSessionForGroup(group)
  if not session then return end

  if TCS.A2G.Registry then TCS.A2G.Registry:CleanupByTag(session, TAG) end

  local unit = group:GetUnit(1)
  local point = TCS.Placement.Resolve(unit, "SEA")
  if not point then
    TCS.A2G.Feedback.ToGroup(group, "No water found ahead for " .. label .. ".")
    return
  end

  local echelon = TCS.GetEchelonForSession(session)
  -- Spawn RED forces
  local force = TCS.A2G.ForceSpawner.Spawn(session, forceName, echelon, point, {coalition=coalition.side.RED})

  if force and #force > 0 then
    if move then
      local cfg = TCS.A2G.Config.MAR
      local dist = cfg.MOVE_DIST_NM.MIN + math.random() * (cfg.MOVE_DIST_NM.MAX - cfg.MOVE_DIST_NM.MIN)
      local speedKts = cfg.SPEED_KTS.MIN + math.random() * (cfg.SPEED_KTS.MAX - cfg.SPEED_KTS.MIN)
      local speedMs = speedKts * 0.514444
      local dest = point:Translate(dist * 1852, unit:GetHeading())
      for _, g in ipairs(force) do
        if g and g.TaskRouteToVec2 then
          g:TaskRouteToVec2(dest:GetVec2(), speedMs, "On Road")
        end
      end
    end

    TCS.A2G.Feedback.ToGroup(group, label .. " scenario generated.")
  else
    TCS.A2G.Feedback.ToGroup(group, "Failed to generate " .. label .. " force (check templates).")
  end
end

function TCS.MAR.StartHarbor(group)
  StartMarScenario(group, "MAR_HARBOR", "Harbor", false)
end

function TCS.MAR.StartShipping(group)
  StartMarScenario(group, "MAR_CONVOY", "Shipping", true)
end

env.info("TCS(MAR): ready")