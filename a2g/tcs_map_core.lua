---------------------------------------------------------------------
-- TCS MAP CORE
-- Common utilities for theater initialization and management.
---------------------------------------------------------------------
env.info("TCS(MAP_CORE): loading")

_G.DCS = _G.DCS or {}
_G.DCS.TCS = _G.DCS.TCS or {}
DCS.TCS.Map = DCS.TCS.Map or {}

-- Helper: Sanitize warehouses at neutral bases
function DCS.TCS.Map.SanitizeNeutrals(baseNames)
  -- Use MSI Core if available
  if DCS.SanitizeNeutrals then 
    return DCS.SanitizeNeutrals(baseNames) 
  end

  if not baseNames then return end
  for _, name in ipairs(baseNames) do
    local ab = Airbase.getByName(name)
    if ab then
      local wh = ab:getWarehouse()
      if wh then
        wh:clear()
        env.info("TCS(MAP): Sanitized warehouse (Weapons/Fuel removed) at Neutral base: " .. name)
      end
    else
      env.warning("TCS(MAP): Could not find airbase for sanitization: " .. name)
    end
  end
end

-- Helper: Calculate a point relative to an airbase (bearing in degrees, dist in NM)
function DCS.TCS.Map.GetRelativePoint(baseName, bearing, distNM)
  -- Use MSI Core if available
  if DCS.GetRelativePoint then 
    return DCS.GetRelativePoint(baseName, bearing, distNM) 
  end

  local ab = Airbase.getByName(baseName)
  if not ab then return nil end
  
  local p = ab:getPoint() -- Vec3
  local distM = distNM * 1852
  local rad = math.rad(bearing)
  
  return {
    x = p.x + math.cos(rad) * distM,
    y = p.z + math.sin(rad) * distM -- Note: DCS Vec3.z is Map Y
  }
end

-- Helper: Register the active map
function DCS.TCS.Map.Register(mapConfig)
  if env.mission.theatre == mapConfig.Name then
    env.info("TCS(MAP): Active Theater Registered: " .. mapConfig.Name)
    if mapConfig.Init then
      mapConfig.Init()
    end
  end
end

env.info("TCS(MAP_CORE): ready")