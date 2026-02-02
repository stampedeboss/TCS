---------------------------------------------------------------------
-- TCS A2G BASE PLACEMENT
-- Authoritative world placement routine
-- Used by ALL A2G domains
---------------------------------------------------------------------

env.info("TCS(A2G.PLACEMENT): loading")

TCS            = TCS or {}
TCS.A2G        = TCS.A2G or {}
TCS.A2G.Place  = TCS.A2G.Place or {}

---------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------

local NM_TO_M   = 1852
local START_NM  = 30
local STEP_NM   = 5
local MAX_NM    = 60

-- Forward cone (deterministic order)
local ANGLE_OFFSETS = { 0, 15, -15, 30, -30, 45, -45 }

---------------------------------------------------------------------
-- Terrain suitability
---------------------------------------------------------------------

local function IsUsableTerrain(coord)
  -- Reject water
  if land.getSurfaceType({ x = coord.x, y = coord.z }) == land.SurfaceType.WATER then
    return false
  end

  -- Reject steep slopes
  local h1 = coord:GetLandHeight()
  local h2 = coord:Translate(10, 0):GetLandHeight()
  if math.abs(h1 - h2) > 2.0 then
    return false
  end

  -- Reject dense city cores (soft check)
  local count = 0
  world.searchObjects(
    Object.Category.SCENERY,
    {
      id = world.VolumeType.SPHERE,
      params = {
        point  = { x = coord.x, y = h1, z = coord.z },
        radius = 300
      }
    },
    function()
      count = count + 1
      return count < 30
    end
  )

  return count < 25
end

---------------------------------------------------------------------
-- Resolve placement
---------------------------------------------------------------------
-- Returns:
--   coord (Coordinate)
--   distanceNM (number)
--   headingUsed (degrees)
---------------------------------------------------------------------

function TCS.A2G.Place.Resolve(unit)
  if not unit or not unit:IsAlive() then return nil end

  local origin = unit:GetCoordinate()
  local track  = unit:GetHeading()

  for dist = START_NM, MAX_NM, STEP_NM do
    for _, offset in ipairs(ANGLE_OFFSETS) do
      local heading = track + offset
      local test    = origin:Translate(dist * NM_TO_M, heading)

      if IsUsableTerrain(test) then
        return test, dist, heading
      end
    end
  end

  return nil
end

env.info("TCS(A2G.PLACEMENT): loaded")
