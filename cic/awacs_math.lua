---------------------------------------------------------------------
-- TCS CIC: AWACS MATH
-- NATO formatting, Aspect calculation, and Bullseye tracking.
---------------------------------------------------------------------
env.info("TCS(CIC.AWACS_MATH): loading")

TCS = TCS or {}

function TCS.AspectHotFlankDrag(targetHdg, bearingToTarget)
  local aspect = math.abs((targetHdg - bearingToTarget + 180) % 360 - 180)
  if aspect < 30 then return "HOT" end
  if aspect > 120 then return "DRAG" end
  return "FLANK"
end

local _Bullseye = nil
function TCS.ResolveBullseye()
  if _Bullseye then return _Bullseye end
  local coal = coalition.side.BLUE
  local bull = coalition.getMainRefPoint(coal)
  if bull then
    _Bullseye = COORDINATE:NewFromVec3(bull)
    return _Bullseye
  end
  local zone = ZONE:FindByName("BULLSEYE")
  if zone then
    _Bullseye = zone:GetCoordinate()
    env.warning("TCS(CIC): Using fallback BULLSEYE trigger zone.")
    return _Bullseye
  end
  return nil
end

function TCS.NATO_BULLSEYE(coord)
  local bull = TCS.ResolveBullseye()
  if not bull or not coord then return "BULLSEYE N/A" end
  local bearing = bull:HeadingTo(coord)
  local dist = TCS.CoordDistanceNM(bull, coord)
  return string.format("BULLSEYE %s/%d", TCS.Pad3(bearing), math.floor(dist))
end

function TCS.NATO_TRACK(lastCoord, currCoord)
  if not lastCoord or not currCoord then return nil end
  local trk = math.floor((lastCoord:HeadingTo(currCoord) % 360) + 0.5)
  local dirs = { "NORTH", "NORTHEAST", "EAST", "SOUTHEAST", "SOUTH", "SOUTHWEST", "WEST", "NORTHWEST" }
  local idx = math.floor(((trk + 22.5) % 360) / 45) + 1
  return "TRACK " .. dirs[idx]
end

env.info("TCS(CIC.AWACS_MATH): ready")