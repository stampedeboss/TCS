
---------------------------------------------------------------------
-- TCS A2G – BAI (Battlefield Air Interdiction)
--
-- Purpose:
--   Establish and manage a BAI battlespace owned by the pilot session.
--
-- Key Properties:
--   • Requires a session (implicit creation allowed)
--   • Replaces any existing BAI tasking for the session
--   • Uses shared placement, bias, spacing, and force composition
--   • Mandatory A2G AWACS directional tasking
--   • Verbose failure reporting
--
-- Ownership:
--   All spawned objects are registered to the session and cleaned up
--   deterministically on replacement, session end, or reassignment.
---------------------------------------------------------------------

env.info("TCS(A2G.BAI): loading")

TCS = TCS or {}
TCS.A2G = TCS.A2G or {}
TCS.A2G.BAI = {}

local TAG = "BAI"
local FORCE = "MECH_INF"

---------------------------------------------------------------------
-- Core Logic
---------------------------------------------------------------------
function TCS.A2G.BAI.Start(session, anchor, echelon, group)
  -- 1. Standard Scenario Setup
  anchor = TCS.Scenario.Setup(session, TAG, anchor, group, {Bias=true, domain="A2G"})
  if not anchor then return end
  
  if group then TCS.A2G.Feedback.ToGroup(group, "TCS: Replacing existing BAI tasking", 8) end

  echelon = TCS.ResolveDifficulty(session, "LAND", echelon)

  local enemySide = coalition.side.RED
  if group then
    enemySide = (group:GetCoalition() == coalition.side.RED) and coalition.side.BLUE or coalition.side.RED
  elseif session and session.Coalition then
    enemySide = (session.Coalition == coalition.side.RED) and coalition.side.BLUE or coalition.side.RED
  end

  -- Spawn force
  env.info(string.format("TCS(BAI): Invoking ForceSpawner for FORCE='%s', Echelon='%s'", tostring(FORCE), tostring(echelon)))
  local spawned = TCS.A2G.ForceSpawner.Spawn(session, FORCE, echelon, anchor, {coalition=enemySide})
  if not spawned or #spawned == 0 then
    env.error("TCS(BAI): ForceSpawner returned no groups. Check Catalog or Spawner logs.")
    if group then MsgToGroup(group, "TCS: BAI force generation failed", 12) end
    return
  end

  -- 1. Initial Movement (Dispersal/Patrol)
  local moveDir = math.random(0, 359)
  local patrolPt = anchor:Translate(3000, moveDir)
  for _, g in ipairs(spawned) do
    if g and g:IsAlive() and g.TaskRouteToVec2 then
      -- Simple move to disperse
      g:TaskRouteToVec2(patrolPt:GetVec2(), 20/3.6, "On Road")
    end
  end

  -- 2. Monitor for Retreat (35% loss check)
  local function countStrength(groups)
    local c = 0
    for _, g in ipairs(groups or {}) do if g and g:IsAlive() then c = c + g:GetSize() end end
    return c
  end
  local initStr = countStrength(spawned)
  
  timer.scheduleFunction(function(_, t)
    if not session[TAG.."_Drawings"] then return nil end -- Stop if BAI ended/reset
    local currStr = countStrength(spawned)
    if initStr > 0 and (currStr / initStr) < 0.65 then
      session:Broadcast("BAI: Targets breaking contact and retreating!", 15)
      local retreatPt = anchor:Translate(10000, (moveDir + 180) % 360)
      trigger.action.smoke(retreatPt:GetVec3(), trigger.smokeColor.Red)
      for _, g in ipairs(spawned) do if g and g:IsAlive() and g.TaskRouteToVec2 then g:TaskRouteToVec2(retreatPt:GetVec2(), 40/3.6, "On Road") end end
      return nil
    end
    return t + 90
  end, nil, timer.getTime() + 90)

  -- Mandatory A2G AWACS tasking
  if TCS.A2G.AWACS and group then
    TCS.A2G.AWACS:AssignBAI(group, anchor, echelon)
  end

  -- Draw Zone on F10 Map
  TCS.Scenario.Draw(session, TAG, anchor, echelon, 9000, {1,0.5,0,1}, {1,0.5,0,0.15})

  if group then MsgToGroup(group, "TCS: BAI battlespace established", 10) end
  env.info("TCS(BAI): Battlespace established successfully.")
end

---------------------------------------------------------------------
-- Menu Entry Point
---------------------------------------------------------------------
function TCS.A2G.BAI.MenuRequest(group, opts)
  if not group then return end
  opts = opts or {}

  local session = TCS.SessionManager:GetOrCreateSessionForGroup(group)
  if not session then
    MsgToGroup(group, "TCS: Unable to create operational session", 10)
    return
  end

  local echelon = opts.echelon
  local anchor, reason = TCS.Placement.Resolve(group:GetUnit(1), {
    domain = "LAND",
    conditions = { terrain = "FLAT", surface = "OPEN" }
  })
  
  if not anchor then
    MsgToGroup(group, "TCS: Unable to establish BAI battlespace\nReason: " .. (reason or "unknown"), 12)
    return
  end

  TCS.A2G.BAI.Start(session, anchor, echelon, group)
end

env.info("TCS(A2G.BAI): ready")
