
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

TCS = TCS or {}
TCS.A2G = TCS.A2G or {}
TCS.A2G.SEAD = {}

local TAG = "SEAD"
local FORCE = "SEAD"

function TCS.A2G.SEAD.Start(session, anchor, echelon, group)
  -- 1. Standard Scenario Setup
  local biased = TCS.Scenario.Setup(session, TAG, anchor, group, {Bias=true, domain="A2G"})
  if not biased then return end
  
  if group then TCS.A2G.Feedback.ToGroup(group, "Replacing existing SEAD tasking", 8) end

  echelon = TCS.ResolveDifficulty(session, "LAND", echelon)

  local enemySide = coalition.side.RED
  if group then
    enemySide = (group:GetCoalition() == coalition.side.RED) and coalition.side.BLUE or coalition.side.RED
  elseif session and session.Coalition then
    enemySide = (session.Coalition == coalition.side.RED) and coalition.side.BLUE or coalition.side.RED
  end

  local force = TCS.A2G.ForceSpawner.Spawn(session, FORCE, echelon, biased, {coalition=enemySide})

  -- Monitor for Displacement (Move if taking losses)
  local function countStrength(groups)
    local c = 0
    for _, g in ipairs(groups or {}) do if g and g:IsAlive() then c = c + g:GetSize() end end
    return c
  end
  local initStr = countStrength(force)

  timer.scheduleFunction(function(_, t)
    if not session[TAG.."_Drawings"] then return nil end
    local currStr = countStrength(force)
    if initStr > 0 and (currStr / initStr) < 0.75 then -- Sensitive threshold for SAMs
      session:Broadcast("SEAD: Air Defense network displacing!", 15)
      local displacePt = biased:Translate(math.random(2000, 4000), math.random(0, 359))
      trigger.action.smoke(displacePt:GetVec3(), trigger.smokeColor.Red)
      for _, g in ipairs(force) do if g and g:IsAlive() and g.TaskRouteToVec2 then g:TaskRouteToVec2(displacePt:GetVec2(), 30/3.6, "Off Road") end end
      return nil
    end
    return t + 60 -- Check faster (60s)
  end, nil, timer.getTime() + 60)

  -- Draw Zone on F10 Map
  TCS.Scenario.Draw(session, TAG, biased, echelon, 7000, {1,1,0,1}, {1,1,0,0.15})

  if group then TCS.A2G.Feedback.ToGroup(group, "SEAD tasking established", 10) end

  if TCS.Controller and TCS.Controller.OnEvent then
    TCS.Controller:OnEvent("A2G_START", { session = session, anchor = biased, type = "SEAD" })
  end
end

function TCS.A2G.SEAD.MenuRequest(group)
  if not group then return end
  local session = TCS.SessionManager:GetOrCreateSessionForGroup(group)
  if not session then return end

  local echelon = nil -- Use session default
  local anchor, reason = TCS.Placement.Resolve(group:GetUnit(1))
  
  TCS.A2G.SEAD.Start(session, anchor, echelon, group)
end

env.info("TCS(A2G.SEAD): ready")
