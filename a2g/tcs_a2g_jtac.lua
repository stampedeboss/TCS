
---------------------------------------------------------------------
-- TCS A2G JTAC Controller
--
-- Supports CAS 9-Line tasking with pilot-selectable marking:
--   Default: SMOKE
--   Options: SMOKE / IR / LASER
--   LASER uses default code unless pilot specifies otherwise
---------------------------------------------------------------------

env.info("TCS(A2G.JTAC): loading")

TCS = TCS or {}
TCS.A2G = TCS.A2G or {}
TCS.A2G.JTAC = {}

-- Configuration
local CFG = TCS.A2G.Config and TCS.A2G.Config.JTAC or {}
local DefaultMark = CFG.DEFAULT_MARK or "SMOKE"
local DefaultLaserCode = CFG.DEFAULT_LASER_CODE or 1688

---------------------------------------------------------------------
-- Internal helpers
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Friendly marking
---------------------------------------------------------------------

function TCS.A2G.JTAC.MarkFriendlies(session, groups, mark, laserCode)
  mark = mark or DefaultMark
  laserCode = laserCode or DefaultLaserCode

  for _, g in ipairs(groups or {}) do
    if g and g.GetCoordinate then
      local coord = g:GetCoordinate():GetVec2()
      if mark == "SMOKE" then
        trigger.action.smoke(coord, trigger.smokeColor.Green)
      elseif mark == "IR" then
        trigger.action.illuminationBomb(coord, 2000)
      elseif mark == "LASER" then
        -- Placeholder: DCS laser is conceptual here; message conveys code
      end
    end
  end

  local msg = "JTAC: Friendlies marked by " .. mark
  if mark == "LASER" then
    msg = msg .. " code " .. tostring(laserCode)
  end
  TCS.A2G.NotifySession(session, msg, 10)
end

---------------------------------------------------------------------
-- Target Designation (Laser)
---------------------------------------------------------------------

function TCS.A2G.JTAC.LaserOn(session, targetCoord, code, duration)
  code = code or DefaultLaserCode
  duration = duration or (CFG.LASER_DURATION or 300)

  if not targetCoord then return end

  -- Resolve target point
  local point = nil
  if targetCoord.GetVec3 then
    point = targetCoord:GetVec3()
  elseif type(targetCoord) == "table" and targetCoord.x then
    point = targetCoord
  end
  if not point then return end

  -- Find source unit (Lasing entity)
  local sourceUnit = nil
  local fallbackUnit = nil
  
  -- 1. Try session registry (friendlies spawned for this session)
  if TCS.A2G.Registry and session then
    local sessionName = session:GetName()
    local objects = TCS.A2G.Registry.bySession[sessionName] or {}
    for _, obj in ipairs(objects) do
      if obj and obj.GetUnits then -- MOOSE Group
        local isPriority = (obj.TCS_Role == "SCOUT")
        local units = obj:GetUnits()
        for _, u in ipairs(units) do
          if u and u:IsAlive() and u:GetCoalition() == coalition.side.BLUE then
            if isPriority then
              sourceUnit = u
              break
            elseif not fallbackUnit then
              fallbackUnit = u
            end
          end
        end
      end
      if sourceUnit then break end
    end
  end

  sourceUnit = sourceUnit or fallbackUnit

  if not sourceUnit then
    TCS.A2G.NotifySession(session, "JTAC: No visual (cannot lase).", 5)
    return
  end

  local dcsUnit = sourceUnit:GetDCSObject()
  if not dcsUnit then return end

  -- Check Line of Sight
  local srcPos = dcsUnit:getPoint()
  srcPos.y = srcPos.y + 2.0 -- approximate sensor height
  if not land.isVisible(srcPos, point) then
    TCS.A2G.NotifySession(session, "JTAC: Negative laser. No line of sight.", 5)
    return
  end

  local spot = Spot.createLaser(dcsUnit, {x=0, y=2, z=0}, point, code)
  trigger.action.smoke(point, trigger.smokeColor.Red)
  TCS.A2G.NotifySession(session, "JTAC: LASER ON. Code " .. tostring(code), 10)

  SCHEDULER:New(nil, function()
    if spot then spot:destroy() end
    TCS.A2G.NotifySession(session, "JTAC: LASER OFF.", 5)
  end, {}, duration)
end

---------------------------------------------------------------------
-- TheWay Interface
---------------------------------------------------------------------

function TCS.A2G.JTAC.PushWaypoint(group, targetCoord, label)
  if not group then return end

  -- Store last tasking if session exists
  if TCS.SessionManager then
    local session = TCS.SessionManager:GetSessionForGroup(group)
    if session then
      session.LastTasking = {
        Coord = targetCoord,
        Label = label,
        Time = timer.getTime()
      }
    end
  end
  
  local p = targetCoord
  if type(p) == "table" and p.GetVec3 then p = p:GetVec3() end
  if not p then return end
  
  local lat, lon = _G.coord.LOtoLL(p)
  local alt = p.y

  -- 1. Always provide text feedback (MGRS/LL)
  if targetCoord.ToStringMGRS and targetCoord.ToStringLLDDM then
    local msg = string.format("TASKING: %s\nMGRS: %s\nLL: %s", label or "TGT", targetCoord:ToStringMGRS(), targetCoord:ToStringLLDDM())
    MESSAGE:New(msg, 30):ToGroup(group)
  end

  -- 2. TheWay Integration
  if not theway then return end
  local units = group.GetUnits and group:GetUnits() or (group.getUnits and group:getUnits())
  if units then
    for _, unit in ipairs(units) do
      local name = nil
      if unit.GetPlayerName then
        name = unit:GetPlayerName()
      elseif unit.getPlayerName then
        name = unit:getPlayerName()
      end

      if name and theway.SendPoint then
        theway.SendPoint(name, lat, lon, alt, label or "TGT")
      end
    end
    if MESSAGE then
      MESSAGE:New("Data Link: Waypoint sent.\nREMINDER: Must be in HSI mode and PRECISION boxed.", 15):ToGroup(group)
    end
  end
end

function TCS.A2G.JTAC.RepeatTasking(group)
  if not group then return end
  local session = TCS.SessionManager and TCS.SessionManager:GetSessionForGroup(group)
  if not session or not session.LastTasking then
    if MESSAGE then MESSAGE:New("No previous tasking found for this session.", 5):ToGroup(group) end
    return
  end
  
  local t = session.LastTasking
  TCS.A2G.JTAC.PushWaypoint(group, t.Coord, t.Label)
end

-- Helper to resolve IP geometry
local function ResolveIP(targetCoord, ingressGroup)
  local ipName = "IP SOUTH"
  local ipCoord = targetCoord:Translate(12 * 1852, 180) -- Default 12NM South

  -- Dynamic IP based on player position (since no ME zones exist)
  if ingressGroup then
    local u = ingressGroup:GetUnit(1)
    if u then
      local pCoord = u:GetCoordinate()
      local hdgToPlayer = targetCoord:HeadingTo(pCoord)
      ipName = string.format("IP %03d", math.floor(hdgToPlayer))
      ipCoord = targetCoord:Translate(12 * 1852, hdgToPlayer)
    end
  end

  -- Try to find a real IP zone defined in ME
  if SET_ZONE then
    local bestD = 1000000
    SET_ZONE:New():ForEach(function(z)
      if z and z:IsExist() and string.sub(z:GetName(), 1, 2) == "IP" then
        local d = z:GetCoordinate():Get2DDistance(targetCoord)
        -- Pick closest IP that is at least 5NM away (don't pick one on top of target)
        if d < bestD and d > (5 * 1852) then
           bestD = d
           ipCoord = z:GetCoordinate()
           ipName = z:GetName()
        end
      end
    end)
  end

  local hdg = ipCoord:HeadingTo(targetCoord)
  local dist = ipCoord:Get2DDistance(targetCoord) * 0.000539957 -- Meters to NM
  
  return ipName, string.format("%03d", hdg), string.format("%.1f NM", dist)
end

local function GetCardinal(heading)
  local dirs = { "North", "Northeast", "East", "Southeast", "South", "Southwest", "West", "Northwest" }
  local idx = math.floor(((heading + 22.5) % 360) / 45) + 1
  return dirs[idx]
end

---------------------------------------------------------------------
-- CAS 9-Line briefing
---------------------------------------------------------------------

function TCS.A2G.JTAC.BriefCAS(session, targetOrData, extraRemarks, group)
  local data = {}

  -- 1. Resolve Data (Handle Coordinate object or raw table)
  if targetOrData and targetOrData.GetVec3 then
    -- Input is a MOOSE Coordinate
    local c = targetOrData
    local elevM = c:GetLandHeight() or 0
    local elevFt = math.floor(elevM * 3.28084)
    
    local ip, ipHdg, ipDist = ResolveIP(c, group)
    
    local dirStr = "South"
    if group then
       local u = group:GetUnit(1)
       if u and u:IsAlive() then
          local b = c:HeadingTo(u:GetCoordinate())
          dirStr = GetCardinal(b)
       end
    end

    data = {
      gameplan   = "Type 2 Control. Bomb on Coordinate.",
      ip         = ip,
      heading    = ipHdg,
      distance   = ipDist,
      elevation  = tostring(elevFt) .. " FT MSL",
      targetDesc = "Enemy Armor",
      grid       = c:ToStringMGRS(),
      mark       = TCS.A2G.JTAC.GetDefaultMark(session),
      friendlies = dirStr .. " 1500m",
      egress     = dirStr,
      remarks    = extraRemarks or "Fighter to FENCE IN. Report IP INBOUND."
    }
    
    -- Attempt to push waypoint via TheWay
    if group then
      TCS.A2G.JTAC.PushWaypoint(group, c, "CAS")
    end
  elseif type(targetOrData) == "table" then
    data = targetOrData
  else
    return -- Invalid input
  end

  -- 2. Send Game Plan
  local msg = "JTAC: " .. (data.gameplan or "Type 2 Control.")
  TCS.A2G.NotifySession(session, msg, 10)

  -- 3. The 9-Line (Scheduled for flow)
  local function q(text, delay, dur)
    SCHEDULER:New(nil, function() TCS.A2G.NotifySession(session, text, dur) end, {}, delay)
  end

  local t = 4 -- start after gameplan
  q("JTAC: Advise when ready for 9-Line.", t, 5)
  t = t + 6

  local lines = {
    string.format("IP: %s", data.ip or "N/A"),
    string.format("Heading: %s", data.heading or "N/A"),
    string.format("Distance: %s", data.distance or "N/A"),
    string.format("Elevation: %s", data.elevation or "0"),
    string.format("Description: %s", data.targetDesc or "Target"),
    string.format("Grid: %s", data.grid or "Unknown"),
    string.format("Mark: %s", data.mark or "None"),
    string.format("Friendlies: %s", data.friendlies or "None"),
    string.format("Egress: %s", data.egress or "South")
  }

  for _, line in ipairs(lines) do
    q(line, t, 5)
    t = t + 5 + math.random(1, 2) -- Read time (~3s) + Pause (1-5s)
  end

  if data.remarks then
    q("Remarks: " .. data.remarks, t, 10)
  end
end

---------------------------------------------------------------------
-- Pilot selection helpers (menus wired elsewhere)
---------------------------------------------------------------------

function TCS.A2G.JTAC.SetDefaultMark(session, mark)
  session.A2G = session.A2G or {}
  session.A2G.Mark = mark
end

function TCS.A2G.JTAC.GetDefaultMark(session)
  return (session.A2G and session.A2G.Mark) or DefaultMark
end

env.info("TCS(A2G.JTAC): ready")
