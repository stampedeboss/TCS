---------------------------------------------------------------------
-- TCS WORLD UTILITIES
---------------------------------------------------------------------
env.info("TCS(WORLD): loading")

-- Meters to Nautical Miles
function MetersToNM(m) return m / 1852.0 end

-- Coordinate Distance in Nautical Miles
function CoordDistanceNM(c1, c2)
  if not c1 or not c2 then return nil end
  local distM = c1:Get2DDistance(c2)
  return MetersToNM(distM)
end

-- Feet from Meters
function FeetFromMeters(m)
  return m * 3.28084
end

-- Pad number to 3 digits (e.g. 5 -> "005")
function Pad3(num)
  return string.format("%03d", num)
end

-- Aspect calculation
function AspectHotFlankDrag(targetHdg, bearingToTarget)
  local aspect = math.abs((targetHdg - bearingToTarget + 180) % 360 - 180)
  if aspect < 30 then return "HOT" end
  if aspect > 120 then return "DRAG" end
  return "FLANK"
end

-- Bullseye Resolution
local _Bullseye = nil
function ResolveBullseye()
  if _Bullseye then return _Bullseye end

  -- 1. Prefer Coalition Bullseye (Blue)
  local coal = coalition.side.BLUE
  local bull = coalition.getMainRefPoint(coal)
  if bull then
    _Bullseye = COORDINATE:NewFromVec3(bull)
    return _Bullseye
  end

  -- 2. Fallback: Try to find a zone named "BULLSEYE"
  local zone = ZONE:FindByName("BULLSEYE")
  if zone then
    _Bullseye = zone:GetCoordinate()
    env.warning("TCS(WORLD): Using fallback BULLSEYE trigger zone. Please set a Bullseye in the Mission Editor for the BLUE coalition.")
    return _Bullseye
  end

  return nil
end

-- NATO Bullseye String
function NATO_BULLSEYE(coord)
  local bull = ResolveBullseye()
  if not bull or not coord then return "BULLSEYE N/A" end
  
  local bearing = bull:HeadingTo(coord)
  local dist = CoordDistanceNM(bull, coord)
  
  return string.format("BULLSEYE %s/%d", Pad3(bearing), math.floor(dist))
end

function NATO_TRACK(lastCoord, currCoord)
  if not lastCoord or not currCoord then return nil end
  local trk = math.floor((lastCoord:HeadingTo(currCoord) % 360) + 0.5)
  local dirs = { "NORTH", "NORTHEAST", "EAST", "SOUTHEAST", "SOUTH", "SOUTHWEST", "WEST", "NORTHWEST" }
  local idx = math.floor(((trk + 22.5) % 360) / 45) + 1
  return "TRACK " .. dirs[idx]
end

function GetNearestAirbaseVec2(fromCoord)
  if not fromCoord then return nil end
  local ab = fromCoord:GetClosestAirbase()
  if not ab then return nil end
  return ab:GetVec2()
end

-- Global Message Helper
function MsgToGroup(group, text, duration)
  env.info("TCS(MSG): " .. tostring(text))
  if not group then return end
  local mGroup = group
  if type(group) == "string" then
    mGroup = GROUP:FindByName(group)
  elseif type(group) == "table" and (not group.ClassName or group.ClassName ~= "GROUP") then
    if group.getName then mGroup = GROUP:FindByName(group:getName()) end
  end
  if mGroup and mGroup.ClassName == "GROUP" then
    MESSAGE:New(text, duration or 10):ToGroup(mGroup)
  end
end

env.info("TCS(WORLD): ready")