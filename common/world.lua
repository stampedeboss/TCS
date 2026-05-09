---------------------------------------------------------------------
-- TCS COMMON WORLD UTILITIES
---------------------------------------------------------------------
env.info("TCS(WORLD): loading")

function TCS.MetersToNM(m) return m / 1852.0 end

function TCS.CoordDistanceNM(c1, c2)
  if not c1 or not c2 then return nil end
  local distM = c1:Get2DDistance(c2)
  return TCS.MetersToNM(distM)
end

function TCS.FeetFromMeters(m) return m * 3.28084 end

function TCS.Pad3(num) return string.format("%03d", num) end

function TCS.GetNearestAirbaseVec2(fromCoord)
  if not fromCoord then return nil end
  local ab = fromCoord:GetClosestAirbase()
  if not ab then return nil end
  return ab:GetVec2()
end

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

function TCS.GetRelativePoint(baseName, bearing, distNM)
  local ab = Airbase.getByName(baseName)
  if not ab then return nil end
  local p = ab:getPoint()
  local distM = distNM * 1852
  local rad = math.rad(bearing)
  return { x = p.x + math.cos(rad) * distM, y = p.z + math.sin(rad) * distM }
end

function TCS.SanitizeNeutrals(baseNames)
  if not baseNames then return end
  for _, name in pairs(baseNames) do
    local ab = Airbase.getByName(name)
    if ab then
      local wh = ab:getWarehouse()
      if wh then wh:clear() end
    end
  end
end

function TCS.MsgToGroup(group, text, duration)
  env.info("TCS(MSG): " .. tostring(text))
  if not group then return end
  local groupName = (type(group) == "string" and group) or (group.GetName and group:GetName())
  if not groupName then return end
  local mooseGroup = GROUP:FindByName(groupName)
  if mooseGroup then MESSAGE:New(text, duration or 10):ToGroup(mooseGroup) end
end

env.info("TCS(WORLD): ready")