---------------------------------------------------------------------
-- TCS PLACEMENT
-- Authoritative world placement routine
-- Used by ALL domains
---------------------------------------------------------------------

env.info("TCS(PLACEMENT): loading")

TCS            = TCS or {}
TCS.Placement  = TCS.Placement or {}

---------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------

local NM_TO_M   = 1852
local START_NM  = 30
local STEP_NM   = 5
local MAX_NM    = 60

---------------------------------------------------------------------
-- Terrain suitability
---------------------------------------------------------------------

function TCS.Placement.Validate(coord, domain, conditions)
  if not coord then return false end
  conditions = conditions or {}
  local s = land.getSurfaceType({ x = coord.x, y = coord.z })

  if domain == "SEA" then
    if s ~= land.SurfaceType.WATER then return false end
    
    if conditions.water_type then
      local r = conditions.dimension or 2000
      local landFound = false
      for i = 0, 315, 45 do
        local check = coord:Translate(r, i)
        if land.getSurfaceType({x=check.x, y=check.z}) ~= land.SurfaceType.WATER then
          landFound = true
          break
        end
      end
      if conditions.water_type == "OPEN" and landFound then return false end
      if (conditions.water_type == "COASTAL" or conditions.water_type == "HARBOR" or conditions.water_type == "ISLAND") and not landFound then return false end
    end

    if conditions.min_depth then
      local h = land.getHeight({x=coord.x, y=coord.z})
      if h > -conditions.min_depth then return false end
    end

    return true
  end

  if domain == "AIR" then
    -- AIR is valid everywhere inside map bounds (implicit in DCS)
    return true
  end

  if domain == "AIR" then return true end

  -- LAND (Default)
  if s == land.SurfaceType.WATER then return false end

  -- Surface Conditions
  if conditions.surface then
    if conditions.surface == "ROAD" and s ~= land.SurfaceType.ROAD then return false end
    if conditions.surface == "RUNWAY" and s ~= land.SurfaceType.RUNWAY then return false end
    if conditions.surface == "OPEN" and (s == land.SurfaceType.ROAD or s == land.SurfaceType.RUNWAY) then return false end
  end

  -- Dimension (Radius for checks)
  local radius = conditions.dimension or 10

  -- Terrain: FLAT (Slope check)
  if conditions.terrain == "FLAT" or (not conditions.terrain) then
    local h1 = coord:GetLandHeight()
    local h2 = coord:Translate(radius, 0):GetLandHeight()
    local diff = math.abs(h1 - h2)
    local maxDiff = radius * 0.2 -- Default tolerance
    if conditions.terrain == "FLAT" then maxDiff = radius * 0.05 end -- Stricter for explicit FLAT
    if diff > maxDiff then return false end
  end

  -- Terrain: HILLTOP
  if conditions.terrain == "HILLTOP" then
    local h = coord:GetLandHeight()
    local lowerCount = 0
    local checkDist = 200
    for i=0, 3 do
       local check = coord:Translate(checkDist, i*90)
       if check:GetLandHeight() < (h - 10) then lowerCount = lowerCount + 1 end
    end
    if lowerCount < 3 then return false end
  end

  -- Terrain: CANYON
  if conditions.terrain == "CANYON" then
    local h = coord:GetLandHeight()
    local higherCount = 0
    local checkDist = 500
    for i=0, 3 do
       local check = coord:Translate(checkDist, i*90)
       if check:GetLandHeight() > (h + 50) then higherCount = higherCount + 1 end
    end
    if higherCount < 2 then return false end
  end

  -- Populated (Scenery Density)
  local popCheck = conditions.populated
  if not popCheck and not conditions.surface then popCheck = "LOW" end -- Default to avoiding dense areas if not specified

  if popCheck then
    local count = 0
    local searchRad = (conditions.dimension or 100)
    if searchRad < 100 then searchRad = 100 end
    local p = {x=coord.x, y=coord:GetLandHeight(), z=coord.z}
    
    world.searchObjects(Object.Category.SCENERY, { id = world.VolumeType.SPHERE, params = { point = p, radius = searchRad } }, function() count = count + 1; return true end)

    if popCheck == "NONE" and count > 5 then return false end
    if popCheck == "LOW" and count > 50 then return false end
    if popCheck == "HIGH" and count < 50 then return false end
  end

  return true
end

---------------------------------------------------------------------
-- Resolve placement
---------------------------------------------------------------------
-- Returns:
--   coord (Coordinate)
--   distanceNM (number)
--   headingUsed (degrees)
---------------------------------------------------------------------

function TCS.Placement.Resolve(unit, criteria)
  if not unit or not unit:IsAlive() then return nil end

  -- Normalize criteria
  local params = {}
  if type(criteria) == "string" then
    params.domain = criteria
  elseif type(criteria) == "table" then
    params = criteria
  else
    params.domain = "LAND"
  end

  local domain = params.domain or "LAND"
  local min_dist = params.min_dist or START_NM
  local max_dist = params.max_dist or MAX_NM
  local step_dist = params.step_dist or STEP_NM
  local offset = params.offset or 0
  local tolerance = params.tolerance or 45
  local mode = params.mode or "CLOSEST" -- "CLOSEST" or "RANDOM"
  
  local conditions = params.conditions or {}
  -- Map top level params to conditions if present
  if params.surface then conditions.surface = params.surface end
  if params.terrain then conditions.terrain = params.terrain end
  if params.populated then conditions.populated = params.populated end
  if params.dimension then conditions.dimension = params.dimension end

  local origin = unit:GetCoordinate()
  local track  = unit:GetHeading()

  if mode == "RANDOM" then
    -- Try N times to find a random valid spot
    for i = 1, 20 do
      local d = min_dist + math.random() * (max_dist - min_dist)
      local a = offset + (math.random() * (tolerance * 2) - tolerance)
      local h = track + a
      local test = origin:Translate(d * NM_TO_M, h)
      
      if TCS.Placement.Validate(test, domain, conditions) then
        return test, d, h
      end
    end
    return nil -- Failed to find random spot
  else
    -- CLOSEST (Iterative search)
    -- Generate search angles
    local angles = {}
    if tolerance == 0 then
      table.insert(angles, 0)
    else
      table.insert(angles, 0)
      local step = 15
      for a = step, tolerance, step do
        table.insert(angles, a)
        table.insert(angles, -a)
      end
    end

    for dist = min_dist, max_dist, step_dist do
      for _, ang in ipairs(angles) do
        local h = track + offset + ang
        local test = origin:Translate(dist * NM_TO_M, h)

        if TCS.Placement.Validate(test, domain, conditions) then
          return test, dist, h
        end
      end
    end
  end

  return nil
end

env.info("TCS(PLACEMENT): loaded")
