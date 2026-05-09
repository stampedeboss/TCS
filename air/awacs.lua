---------------------------------------------------------------------
-- TCS AIR AWACS & GCI
-- Provides Ground Control Intercept (GCI) and BRAA logic.
---------------------------------------------------------------------
env.info("TCS(AIR.AWACS): loading")

TCS = TCS or {}
TCS.Air = TCS.Air or {}

-- Helpers for BRAA calculations
local function AltFeetFromRef(refGroup, coord)
  local altm = nil
  if refGroup and refGroup.GetHeight then pcall(function() altm = refGroup:GetHeight() end) end
  if (not altm) and refGroup and refGroup.GetAltitude then pcall(function() altm = refGroup:GetAltitude() end) end
  if (not altm) and coord and coord.GetVec3 then pcall(function() altm = coord:GetVec3().y end) end
  return TCS.FeetFromMeters(altm or 0)
end

local function _safeAspect(banditHdg, b2p)
  local diff = math.abs((banditHdg or 0) - (b2p or 0))
  if diff > 180 then diff = 360 - diff end
  if diff < 45 then return "HOT"
  elseif diff > 135 then return "DRAG"
  else return "FLANK" end
end

function TCS.Air.ClosestBanditAndRange(rec, banditGroups)
  if not rec or not rec.Unit or not rec.Unit:IsAlive() then return nil, nil end
  local p = rec.Unit:GetCoordinate()
  local bestG, bestNM = nil, nil
  for _, g in ipairs(banditGroups) do
    if g and g:IsAlive() then
      local nm = TCS.CoordDistanceNM(p, g:GetCoordinate())
      if nm and ((not bestNM) or nm < bestNM) then bestNM, bestG = nm, g end
    end
  end
  return bestG, bestNM
end

function TCS.Air.BraaText(rec, refGroup)
  if not rec or not rec.Unit or not rec.Unit:IsAlive() then return "" end
  if not refGroup or not refGroup:IsAlive() then return "" end
  local p = rec.Unit:GetCoordinate()
  local b = refGroup:GetCoordinate()

  local bearing = math.floor((p:HeadingTo(b) % 360) + 0.5)
  local rangeNM = math.floor((TCS.CoordDistanceNM(p, b) or 0) + 0.5)
  local altFt = math.floor((AltFeetFromRef(refGroup, b) / 1000) + 0.5) * 1000

  local banditHdg = 0
  pcall(function() banditHdg = refGroup:GetHeading() or 0 end)
  local b2p = math.floor((b:HeadingTo(p) % 360) + 0.5)
  local aspect = _safeAspect(banditHdg, b2p)

  return string.format("BRAA %s/%d, %d THOUSAND, %s", TCS.Pad3(bearing), rangeNM, math.floor(altFt/1000), aspect)
end

local function GetCallsign(unit, group)
  local playerName = (unit and unit.GetPlayerName and unit:GetPlayerName()) or (group and group.GetPlayerName and group:GetPlayerName())
  if playerName and TCS.Utils and TCS.Utils.ParseCallsign then return TCS.Utils.ParseCallsign(playerName)
  elseif playerName then return playerName end

  if unit and unit.GetCallsign then
    local cs = unit:GetCallsign()
    if cs and cs ~= "" then return cs end
  end
  return group and group:GetName() or "Unknown"
end

function TCS.Air.AwacsControllerCallBraa(group, unit, target, label, subLabel, state)
  if not group then return end
  local u = unit or group:GetUnit(1)
  if not u then return end
  
  local braa = (target and target.IsAlive and target:IsAlive()) and TCS.Air.BraaText({Unit=u}, target) or nil
  if braa and braa ~= "" then
    local awacsLabel = (TCS.Air.Settings and TCS.Air.Settings.FALLBACKS and TCS.Air.Settings.FALLBACKS.AWACS_CALLSIGN) or "MAGIC"
    local callsign = GetCallsign(u, group)
    local text = string.format("%s: %s, %s. %s", awacsLabel, callsign, label, braa)
    if subLabel and subLabel ~= "" then text = text .. ", " .. subLabel end
    if state and state ~= "" then text = text .. ". " .. state end
    
    MESSAGE:New(text, 10):ToGroup(group)
    if TCS.AWACS and TCS.AWACS.Say then TCS.AWACS.Say(text) end
  end
end

function TCS.Air.StartAwacsUpdates(group, unit, targetResolver, label, state)
  local update_interval = (TCS.Air.Settings and TCS.Air.Settings.FLIGHT_MANAGER and TCS.Air.Settings.FLIGHT_MANAGER.AWACS_UPDATE_INTERVAL_SEC) or 30
  local function update()
    if not group or not group:IsAlive() then return end
    local target = targetResolver()
    if target then TCS.Air.AwacsControllerCallBraa(group, unit, target, label, "", state) end
    timer.scheduleFunction(update, nil, timer.getTime() + update_interval)
  end
  timer.scheduleFunction(update, nil, timer.getTime() + update_interval)
end

env.info("TCS(AIR.AWACS): ready")