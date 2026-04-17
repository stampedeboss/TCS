---------------------------------------------------------------------
-- TCS WORLD UTILITIES
---------------------------------------------------------------------
env.info("TCS(WORLD): loading")

-- Meters to Nautical Miles
function TCS.MetersToNM(m) return m / 1852.0 end

-- Coordinate Distance in Nautical Miles
function TCS.CoordDistanceNM(c1, c2)
  if not c1 or not c2 then return nil end
  local distM = c1:Get2DDistance(c2)
  return TCS.MetersToNM(distM)
end

-- Feet from Meters
function TCS.FeetFromMeters(m)
  return m * 3.28084
end

-- Pad number to 3 digits (e.g. 5 -> "005")
function TCS.Pad3(num)
  return string.format("%03d", num)
end

-- Aspect calculation
function TCS.AspectHotFlankDrag(targetHdg, bearingToTarget)
  local aspect = math.abs((targetHdg - bearingToTarget + 180) % 360 - 180)
  if aspect < 30 then return "HOT" end
  if aspect > 120 then return "DRAG" end
  return "FLANK"
end

-- Bullseye Resolution
local _Bullseye = nil
function TCS.ResolveBullseye()
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

function TCS.GetNearestAirbaseVec2(fromCoord)
  if not fromCoord then return nil end
  local ab = fromCoord:GetClosestAirbase()
  if not ab then return nil end
  return ab:GetVec2()
end

--- Finds the closest airbase for a specific coalition.
function TCS.GetClosestCoalitionAirbase(fromCoord, coal)
  local abList = coalition.getAirbases(coal)
  local minDist = math.huge
  local closestAB = nil
  local fromVec3 = fromCoord:GetVec3()
  
  for _, ab in ipairs(abList) do
    local abPos = ab:getPoint()
    local d = math.sqrt((abPos.x - fromVec3.x)^2 + (abPos.z - fromVec3.z)^2)
    if d < minDist then
      minDist = d
      closestAB = ab
    end
  end
  return closestAB
end

--- Calculates a 2D point relative to a named airbase.
-- @param baseName (string) The name of the reference airbase.
-- @param bearing (number) The bearing in degrees from the airbase.
-- @param distNM (number) The distance in nautical miles.
-- @return (table|nil) A table with {x, y} coordinates or nil if base not found.
function TCS.GetRelativePoint(baseName, bearing, distNM)
  local ab = Airbase.getByName(baseName)
  if not ab then 
    env.warning("TCS.GetRelativePoint: Could not find reference airbase: " .. baseName)
    return nil 
  end
  
  local p = ab:getPoint() -- Vec3
  local distM = distNM * 1852
  local rad = math.rad(bearing)
  
  return {
    x = p.x + math.cos(rad) * distM,
    y = p.z + math.sin(rad) * distM -- Note: DCS Vec3.z is Map Y
  }
end

--- Clears weapons and fuel from the warehouses of specified neutral airbases.
-- @param baseNames (table) A list of airbase names to sanitize.
function TCS.SanitizeNeutrals(baseNames)
  if not baseNames then return end

  for _, name in pairs(baseNames) do
    local ab = Airbase.getByName(name)
    if ab then
      local wh = ab:getWarehouse()
      if wh then
        wh:clear()
        env.info("TCS(WORLD): Sanitized neutral airbase warehouse: " .. name)
      end
    end
  end
end

--- Sends a message to a group (MOOSE or DCS).
-- @param group (Group|string) The group object or name.
-- @param text (string) The message text.
-- @param duration (number) Duration in seconds (default 10).
function TCS.MsgToGroup(group, text, duration)
  env.info("TCS(MSG): " .. tostring(text))
  if not group then return end
  
  -- Resolve group name from string or object
  local groupName = (type(group) == "string" and group) or (group.GetName and group:GetName())
  if not groupName then return end

  local mooseGroup = GROUP:FindByName(groupName)
  if mooseGroup then
    MESSAGE:New(text, duration or 10):ToGroup(mooseGroup)
  end
end

env.info("TCS(WORLD): ready")