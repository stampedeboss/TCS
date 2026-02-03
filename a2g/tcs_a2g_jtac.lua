
---------------------------------------------------------------------
-- TCS A2G JTAC Controller
--
-- Supports CAS 9-Line tasking with pilot-selectable marking:
--   Default: SMOKE
--   Options: SMOKE / IR / LASER
--   LASER uses default code unless pilot specifies otherwise
---------------------------------------------------------------------

TCS = TCS or {}
TCS.A2G = TCS.A2G or {}
TCS.A2G.JTAC = {}

-- Defaults
local DefaultMark = "SMOKE"
local DefaultLaserCode = 1688

---------------------------------------------------------------------
-- Internal helpers
---------------------------------------------------------------------

local function say(session, msg, t)
  if TCS_COMMS and TCS_COMMS.SayToSession then
    TCS_COMMS.SayToSession(session, msg, t or 10)
  elseif session and session.Broadcast then
    session:Broadcast(msg, t or 10)
  end
end

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
  say(session, msg, 10)
end

---------------------------------------------------------------------
-- Target Designation (Laser)
---------------------------------------------------------------------

function TCS.A2G.JTAC.LaserOn(session, targetCoord, code, duration)
  code = code or DefaultLaserCode
  duration = duration or 300 -- 5 min default

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
    say(session, "JTAC: No visual (cannot lase).", 5)
    return
  end

  local dcsUnit = sourceUnit:GetDCSObject()
  if not dcsUnit then return end

  -- Check Line of Sight
  local srcPos = dcsUnit:getPoint()
  srcPos.y = srcPos.y + 2.0 -- approximate sensor height
  if not land.isVisible(srcPos, point) then
    say(session, "JTAC: Negative laser. No line of sight.", 5)
    return
  end

  local spot = Spot.createLaser(dcsUnit, {x=0, y=2, z=0}, point, code)
  trigger.action.smoke(point, trigger.smokeColor.Red)
  say(session, "JTAC: LASER ON. Code " .. tostring(code), 10)

  SCHEDULER:New(nil, function()
    if spot then spot:destroy() end
    say(session, "JTAC: LASER OFF.", 5)
  end, {}, duration)
end

---------------------------------------------------------------------
-- CAS 9-Line briefing
---------------------------------------------------------------------

function TCS.A2G.JTAC.BriefCAS(session, targetOrData, extraRemarks)
  local data = {}

  -- 1. Resolve Data (Handle Coordinate object or raw table)
  if targetOrData and targetOrData.GetVec3 then
    -- Input is a MOOSE Coordinate
    local c = targetOrData
    local elevM = c:GetLandHeight() or 0
    local elevFt = math.floor(elevM * 3.28084)

    data = {
      gameplan   = "Type 2 Control. Bomb on Coordinate.",
      ip         = "N/A",
      heading    = "N/A",
      distance   = "N/A",
      elevation  = tostring(elevFt) .. " FT MSL",
      targetDesc = "Enemy Armor",
      grid       = c:ToStringMGRS(),
      mark       = TCS.A2G.JTAC.GetDefaultMark(session),
      friendlies = "South 1500m",
      egress     = "South",
      remarks    = extraRemarks or "Fighter to FENCE IN. Report IP INBOUND."
    }
  elseif type(targetOrData) == "table" then
    data = targetOrData
  else
    return -- Invalid input
  end

  -- 2. Send Game Plan
  local msg = "JTAC: " .. (data.gameplan or "Type 2 Control.")
  say(session, msg, 10)

  -- 3. The 9-Line (Scheduled for flow)
  local function q(text, delay, dur)
    SCHEDULER:New(nil, function() say(session, text, dur) end, {}, delay)
  end

  local t = 4 -- start after gameplan
  q("JTAC: Advise when ready for 9-Line.", t, 5)
  t = t + 6

  local l1 = string.format("1. IP: %s\n2. Hdg: %s\n3. Dist: %s", data.ip or "N/A", data.heading or "N/A", data.distance or "N/A")
  q(l1, t, 10); t = t + 11

  local l2 = string.format("4. Elev: %s\n5. Desc: %s\n6. Grid: %s", data.elevation or "0", data.targetDesc or "Target", data.grid or "Unknown")
  q(l2, t, 10); t = t + 11

  local l3 = string.format("7. Mark: %s\n8. Friendlies: %s\n9. Egress: %s", data.mark or "None", data.friendlies or "None", data.egress or "South")
  q(l3, t, 10); t = t + 11

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
