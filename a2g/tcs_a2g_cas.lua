
---------------------------------------------------------------------
-- TCS A2G – CAS (Close Air Support)
---------------------------------------------------------------------

env.info("TCS(A2G.CAS): loading")

TCS = TCS or {}
TCS.A2G = TCS.A2G or {}
TCS.A2G.CAS = {}

local TAG = "CAS"
local FORCE_FRIENDLY = "MECH_INF"
local FORCE_ENEMY = "MECH_INF_NJTAC"

--- Starts a CAS scenario at a specific location for a specific session.
function TCS.A2G.CAS.Start(session, anchor, echelon, group)
  -- 1. Standard Scenario Setup
  anchor = TCS.Scenario.Setup(session, TAG, anchor, group, {Bias=false, domain="A2G"})
  if not anchor then return end
  if group then TCS.A2G.Feedback.ToGroup(group, "Replacing existing CAS tasking", 10) end

  local friendlyEch = TCS.ResolveDifficulty(session, "LAND", echelon)
  local enemyEch    = TCS.ResolveDifficulty(session, "LAND", echelon)

  if not enemyEch then
    if group then TCS.A2G.Feedback.ToGroup(group, "Unable to establish CAS battlespace: force balance failed", 10) end
    return
  end

  -- Calculate start positions for interaction
  local casCfg = TCS.A2G.Config.CAS or {}
  local sepMin = casCfg.SEPARATION_NM and casCfg.SEPARATION_NM.MIN or 2
  local sepMax = casCfg.SEPARATION_NM and casCfg.SEPARATION_NM.MAX or 4
  local dist = (sepMin + math.random() * (sepMax - sepMin)) * 1852 / 2
  
  local axis = math.random(0, 359)
  
  -- Align axis to player ingress if available
  if group then
    local u = group:GetUnit(1)
    if u and u:IsAlive() then
       local pPos = u:GetCoordinate()
       local bearingToPlayer = anchor:HeadingTo(pPos)
       -- Align so friendlies (axis + 180) are towards player
       axis = (bearingToPlayer + 180) % 360
    end
  end

  -- Determine sides
  local playerSide = coalition.side.BLUE
  if group then 
    playerSide = group:GetCoalition()
  elseif session and session.Coalition then
    playerSide = session.Coalition
  end
  local enemySide = (playerSide == coalition.side.RED) and coalition.side.BLUE or coalition.side.RED

  local friendlyStart = anchor:Translate(dist, (axis + 180) % 360)
  local enemyStart    = anchor:Translate(dist, axis)

  local friendly = TCS.A2G.ForceSpawner.Spawn(session, FORCE_FRIENDLY, friendlyEch, friendlyStart, {coalition=playerSide})
  local enemy    = TCS.A2G.ForceSpawner.Spawn(session, FORCE_ENEMY, enemyEch, enemyStart, {coalition=enemySide})

  if not friendly or not enemy then
    if group then TCS.A2G.Feedback.ToGroup(group, "Unable to establish CAS battlespace: spawn failure", 10) end
    return
  end

  -- Task units to move towards the center (Interaction)
  local speedKph = casCfg.SPEED_KPH and math.random(casCfg.SPEED_KPH.MIN, casCfg.SPEED_KPH.MAX) or 25
  local speedMs = speedKph / 3.6
  local function converge(groups)
    for _, g in ipairs(groups or {}) do
      if g and g:IsAlive() and g.TaskRouteToVec2 then g:TaskRouteToVec2(anchor:GetVec2(), speedMs, "On Road") end
    end
  end
  converge(friendly)
  converge(enemy)

  -- Monitor for retreat (35% loss check every 90s)
  local function countStrength(groups)
    local c = 0
    for _, g in ipairs(groups or {}) do if g and g:IsAlive() then c = c + g:GetSize() end end
    return c
  end
  local initFriendly, initEnemy = countStrength(friendly), countStrength(enemy)
  
  timer.scheduleFunction(function(_, t)
    if not session[TAG.."_Drawings"] then return nil end -- Stop if CAS ended
    local currFriendly, currEnemy = countStrength(friendly), countStrength(enemy)
    local threshold = 0.65 -- Retreat if < 65% strength

    local fName = (playerSide == coalition.side.RED) and "Red" or "Blue"
    local eName = (enemySide == coalition.side.RED) and "Red" or "Blue"
    local fColor = (playerSide == coalition.side.RED) and trigger.smokeColor.Red or trigger.smokeColor.Blue
    local eColor = (enemySide == coalition.side.RED) and trigger.smokeColor.Red or trigger.smokeColor.Blue

    if initFriendly > 0 and (currFriendly / initFriendly) < threshold then
      local msg = "CAS: " .. fName .. " forces taking heavy losses! Retreating!"
      TCS.A2G.NotifySession(session, msg, 15)
      trigger.action.smoke(friendlyStart:GetVec3(), fColor)
      
      -- Notify Unified Controller
      if TCS.Controller and TCS.Controller.OnEvent then
        TCS.Controller:OnEvent("CAS_RETREAT", { session = session, location = friendlyStart, group = group })
      end

      for _, g in ipairs(friendly or {}) do if g and g:IsAlive() and g.TaskRouteToVec2 then g:TaskRouteToVec2(friendlyStart:GetVec2(), speedMs * 1.5, "On Road") end end
      return nil
    elseif initEnemy > 0 and (currEnemy / initEnemy) < threshold then
      local msg = "CAS: " .. eName .. " forces taking heavy losses! Retreating!"
      TCS.A2G.NotifySession(session, msg, 15)
      trigger.action.smoke(enemyStart:GetVec3(), eColor)
      for _, g in ipairs(enemy or {}) do if g and g:IsAlive() and g.TaskRouteToVec2 then g:TaskRouteToVec2(enemyStart:GetVec2(), speedMs * 1.5, "On Road") end end
      return nil
    end
    return t + 90
  end, nil, timer.getTime() + 90)

  if TCS.A2G.JTAC and TCS.A2G.JTAC.MarkFriendlies then
    TCS.A2G.JTAC.MarkFriendlies(session, friendly)
  end

  if TCS.A2G.JTAC and TCS.A2G.JTAC.BriefCAS then
    TCS.A2G.JTAC.BriefCAS(session, anchor, nil, group)
  end

  -- Draw Zone on F10 Map
  TCS.Scenario.Draw(session, TAG, anchor, echelon, 5500, {1,0,0,1}, {1,0,0,0.15})

  if group then 
    local msg = "CAS support established"
    TCS.A2G.NotifySession(session, msg, 10)
  end
end

--- F10 Menu Entry Point
function TCS.A2G.CAS.MenuRequest(group, opts)
  if not group then return end
  opts = opts or {}

  local session = TCS.SessionManager:GetOrCreateSessionForGroup(group)
  if not session then
    TCS.A2G.Feedback.ToGroup(group, "Unable to create operational session", 10)
    return
  end

  local anchor, reason = TCS.Placement.Resolve(group:GetUnit(1), {
    domain = "LAND",
    conditions = { terrain = "FLAT", surface = "OPEN" }
  })
  if not anchor then
    TCS.A2G.Feedback.ToGroup(group, "Unable to establish CAS battlespace: " .. tostring(reason), 10)
    return
  end

  TCS.A2G.CAS.Start(session, anchor, opts.echelon, group)
end

env.info("TCS(A2G.CAS): ready")
