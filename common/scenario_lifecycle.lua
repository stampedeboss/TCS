---------------------------------------------------------------------
-- TCS COMMON SCENARIO: LIFECYCLE
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Common = TCS.Common or {}
TCS.Common.Scenario = TCS.Common.Scenario or {}

function TCS.Common.Scenario.Stop(session, tag)
  if not session then return end
  if TCS.Common.Registry and TCS.Common.Registry.CleanupByTag then
    TCS.Common.Registry:CleanupByTag(session, tag)
  end

  if session[tag .. "_Drawings"] then
    for _, id in ipairs(session[tag .. "_Drawings"]) do trigger.action.removeMark(id) end
  end

  session[tag .. "_Active"] = false
  session[tag .. "_Drawings"] = nil
  if session.ActiveScenarios then session.ActiveScenarios[tag] = nil end
end

function TCS.Common.Scenario.Setup(session, tag, anchor, group, opts)
  if not session then return anchor end
  opts = opts or {}
  TCS.Common.Scenario.Stop(session, tag)

  local finalCoord = anchor
  if type(anchor) == "string" then
    local z = ZONE:FindByName(anchor)
    if z then finalCoord = z:GetCoordinate() end
  elseif type(anchor) == "table" and anchor.GetCoordinate then
    finalCoord = anchor:GetCoordinate()
  end

  if not finalCoord then return nil end

  if opts.Bias and group and group:IsAlive() then
    finalCoord = finalCoord:Translate(math.random(5000, 8000), group:GetHeading() or 0)
  end

  session[tag .. "_Active"] = true
  session.ActiveScenarios = session.ActiveScenarios or {}
  session.ActiveScenarios[tag] = true
  session.Targets = session.Targets or {}
  session.Targets[tag] = finalCoord

  if (opts.domain == "A2G" or opts.domain == "SEA") and group then
    if TCS.Common.JTAC and TCS.Common.JTAC.PushWaypoint then
      TCS.Common.JTAC.PushWaypoint(group, finalCoord, tag)
    end

    if trigger.misc.getUserFlag(285000) <= 9 then
      trigger.action.smoke(finalCoord:GetVec3(), trigger.smokeColor.Red)
    end
  end
  return finalCoord
end