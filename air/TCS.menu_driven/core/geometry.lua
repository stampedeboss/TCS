-- TCS_geometry.lua (A2A)
function MetersToNM(m) return m / 1852.0 end

function Pad3(n)
  n = math.floor(n + 0.5) % 360
  if n < 10 then return "00" .. n end
  if n < 100 then return "0" .. n end
  return tostring(n)
end

-- Bullseye support: prefer actual mission bullseye (coalition setting).
-- Fallback to trigger zone named "BULLSEYE" if mission bullseye not available.
local _BULL = nil

local function GetMissionBullseyeXY(coalitionName)
  if not env or not env.mission or not env.mission.coalition then return nil end
  local c = env.mission.coalition[coalitionName]
  if not c or not c.bullseye then return nil end
  if not c.bullseye.x or not c.bullseye.y then return nil end
  return { x = c.bullseye.x, y = c.bullseye.y } -- meters
end

function ResolveBullseye()
  if _BULL then return _BULL end

  -- 1) Prefer BLUE bullseye (typical for BLUE TCS missions)
  local b = GetMissionBullseyeXY("blue")
  if b then
    _BULL = COORDINATE:New(b.x, 0, b.y) -- mission y maps to world z
    return _BULL
  end

  -- 2) Fallback: ME trigger zone "BULLSEYE" (DCS-native, avoids MOOSE DB timing issues)
  local z = trigger.misc.getZone("BULLSEYE")
  if z and z.point then
    _BULL = COORDINATE:New(z.point.x, 0, z.point.y)
    return _BULL
  end

  return nil
end
function NATO_BULLSEYE(targetCoord)
  if not _BULL or not targetCoord then return "BULLSEYE UNAVAILABLE" end
  local brg = _BULL:HeadingTo(targetCoord)
  local rngm = _BULL:Get2DDistance(targetCoord)
  local rngnm = math.floor(MetersToNM(rngm) + 0.5)
  return "BULLSEYE " .. Pad3(brg) .. "/" .. tostring(rngnm)
end

function NATO_TRACK(lastCoord, currCoord)
  if not lastCoord or not currCoord then return nil end
  local trk = math.floor((lastCoord:HeadingTo(currCoord) % 360) + 0.5)
  local dirs = { "NORTH", "NORTHEAST", "EAST", "SOUTHEAST", "SOUTH", "SOUTHWEST", "WEST", "NORTHWEST" }
  local idx = math.floor(((trk + 22.5) % 360) / 45) + 1
  return "TRACK " .. dirs[idx]
end

function CoordDistanceNM(aCoord, bCoord)
  if not aCoord or not bCoord then return nil end
  local d = aCoord:Get2DDistance(bCoord)
  return MetersToNM(d)
end

function FeetFromMeters(m) return m * 3.28084 end

function AspectHotFlankDrag(banditHeadingDeg, banditToPlayerBearingDeg)
  local diff = math.abs(((banditHeadingDeg - banditToPlayerBearingDeg + 540) % 360) - 180)
  if diff <= 45 then return "HOT" end
  if diff >= 135 then return "DRAG" end
  return "FLANK"
end
