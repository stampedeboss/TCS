---------------------------------------------------------------------
-- TCS CIC: JTAC Controller
--
-- Supports CAS 9-Line tasking with pilot-selectable marking:
--   Default: SMOKE
--   Options: SMOKE / IR / LASER
---------------------------------------------------------------------
env.info("TCS(CIC.JTAC): loading")

TCS = TCS or {}
TCS.CIC = TCS.CIC or {}
TCS.CIC.JTAC = {
    Taskings = {},
    Settings = {}
}

local function GetConfig()
    return (TCS.Land and TCS.Land.Config and TCS.Land.Config.JTAC) or {
        DEFAULT_MARK = "SMOKE",
        DEFAULT_LASER_CODE = 1688,
        LASER_DURATION = 300
    }
end

---------------------------------------------------------------------
-- Friendly marking
---------------------------------------------------------------------
function TCS.CIC.JTAC.MarkFriendlies(group, targetGroups, mark, laserCode)
  local cfg = GetConfig()
  mark = mark or TCS.CIC.JTAC.Settings[group:GetName()] or cfg.DEFAULT_MARK
  laserCode = laserCode or cfg.DEFAULT_LASER_CODE

  for _, g in ipairs(targetGroups or {}) do
    if g and g.GetCoordinate then
      local coord = g:GetCoordinate():GetVec2()
      if mark == "SMOKE" then
        trigger.action.smoke(coord, trigger.smokeColor.Green)
      elseif mark == "IR" then
        trigger.action.illuminationBomb(coord, 2000)
      end
    end
  end

  local msg = "JTAC: Friendlies marked by " .. mark
  if mark == "LASER" then
    msg = msg .. " code " .. tostring(laserCode)
  end
  if TCS.MsgToGroup then TCS.MsgToGroup(group, msg, 10) end
end

---------------------------------------------------------------------
-- Target Designation (Laser)
---------------------------------------------------------------------
function TCS.CIC.JTAC.LaserOn(group, targetCoord, code, duration)
  local cfg = GetConfig()
  code = code or cfg.DEFAULT_LASER_CODE
  duration = duration or cfg.LASER_DURATION

  if not targetCoord then
     local tsk = TCS.CIC.JTAC.Taskings[group:GetName()]
     if tsk then targetCoord = tsk.Coord end
  end

  if not targetCoord then
    if TCS.MsgToGroup then TCS.MsgToGroup(group, "JTAC: No target coordinates available to lase.", 5) end
    return
  end

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
  
  -- Look through registered zones for friendly units to lase from
  if TCS.CIC.Registry and TCS.CIC.Registry.byZone then
    for zId, objects in pairs(TCS.CIC.Registry.byZone) do
      for _, obj in ipairs(objects) do
        if obj and obj.GetUnits then
          local isScout = (obj.TCS_Role == "SCOUT")
          for _, u in ipairs(obj:GetUnits()) do
            if u and u:IsAlive() and u:GetCoalition() == group:GetCoalition() then
              local uCoord = u:GetCoordinate()
              if uCoord and targetCoord.Get2DDistance and uCoord:Get2DDistance(targetCoord) < 15000 then
                if isScout then
                  sourceUnit = u
                  break
                elseif not fallbackUnit then
                  fallbackUnit = u
                end
              end
            end
          end
        end
        if sourceUnit then break end
      end
      if sourceUnit then break end
    end
  end

  sourceUnit = sourceUnit or fallbackUnit

  if not sourceUnit then
    if TCS.MsgToGroup then TCS.MsgToGroup(group, "JTAC: Negative visual. No friendlies in position to lase.", 5) end
    return
  end

  local dcsUnit = sourceUnit:GetDCSObject()
  if not dcsUnit then return end

  -- Check Line of Sight
  local srcPos = dcsUnit:getPoint()
  srcPos.y = srcPos.y + 2.0 -- approximate sensor height
  if not land.isVisible(srcPos, point) then
    if TCS.MsgToGroup then TCS.MsgToGroup(group, "JTAC: Negative laser. No line of sight.", 5) end
    return
  end

  local spot = Spot.createLaser(dcsUnit, {x=0, y=2, z=0}, point, code)
  trigger.action.smoke(point, trigger.smokeColor.Red)
  if TCS.MsgToGroup then TCS.MsgToGroup(group, "JTAC: LASER ON. Code " .. tostring(code), 10) end

  SCHEDULER:New(nil, function()
    if spot then spot:destroy() end
    if TCS.MsgToGroup then TCS.MsgToGroup(group, "JTAC: LASER OFF.", 5) end
  end, {}, duration)
end

---------------------------------------------------------------------
-- TheWay Interface
---------------------------------------------------------------------
function TCS.CIC.JTAC.PushWaypoint(group, targetCoord, label)
  if not group then return end

  TCS.CIC.JTAC.Taskings[group:GetName()] = {
    Coord = targetCoord,
    Label = label,
    Time = timer.getTime()
  }
  
  local p = targetCoord
  if type(p) == "table" and p.GetVec3 then p = p:GetVec3() end
  if not p then return end
  
  local lat, lon = _G.coord.LOtoLL(p)
  local alt = p.y

  -- 1. Always provide text feedback (MGRS/LL)
  if targetCoord.ToStringMGRS and targetCoord.ToStringLLDDM then
    local msg = string.format("TASKING: %s\nMGRS: %s\nLL: %s", label or "TGT", targetCoord:ToStringMGRS(), targetCoord:ToStringLLDDM())
    if TCS.MsgToGroup then TCS.MsgToGroup(group, msg, 30) end
  end

  -- 2. TheWay Integration
  if not theway then return end
  local units = group.GetUnits and group:GetUnits() or (group.getUnits and group:getUnits())
  if units then
    for _, unit in ipairs(units) do
      local name = unit.GetPlayerName and unit:GetPlayerName() or (unit.getPlayerName and unit:getPlayerName())
      if name and theway.SendPoint then
        theway.SendPoint(name, lat, lon, alt, label or "TGT")
      end
    end
    if MESSAGE then
      MESSAGE:New("Data Link: Waypoint sent.\nREMINDER: Must be in HSI mode and PRECISION boxed.", 15):ToGroup(group)
    end
  end
end

function TCS.CIC.JTAC.RepeatTasking(group)
  if not group then return end
  local t = TCS.CIC.JTAC.Taskings[group:GetName()]
  if not t then
    if MESSAGE then MESSAGE:New("No previous tasking found.", 5):ToGroup(group) end
    return
  end
  TCS.CIC.JTAC.PushWaypoint(group, t.Coord, t.Label)
end

-- Helper to resolve IP geometry
local function ResolveIP(targetCoord, ingressGroup)
  local ipName = "IP SOUTH"
  local ipCoord = targetCoord:Translate(12 * 1852, 180) -- Default 12NM South

  -- Dynamic IP based on player position
  if ingressGroup then
    local u = ingressGroup:GetUnit(1)
    if u then
      local pCoord = u:GetCoordinate()
      local hdgToPlayer = targetCoord:HeadingTo(pCoord)
      ipName = string.format("IP %03d", math.floor(hdgToPlayer))
      ipCoord = targetCoord:Translate(12 * 1852, hdgToPlayer)
    end
  end

  local hdg = ipCoord:HeadingTo(targetCoord)
  local dist = ipCoord:Get2DDistance(targetCoord) * 0.000539957
  return ipName, string.format("%03d", hdg), string.format("%.1f NM", dist)
end

function TCS.CIC.JTAC.SetDefaultMark(group, mark)
  TCS.CIC.JTAC.Settings[group:GetName()] = mark
end

env.info("TCS(CIC.JTAC): ready")