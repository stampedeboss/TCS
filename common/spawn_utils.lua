---------------------------------------------------------------------
-- TCS COMMON: SPAWN UTILITIES
-- Low-level functions for creating DCS groups and statics.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Common = TCS.Common or {}
TCS.Common.Spawn = {}

local function GetCountryForCoalition(side)
  if side == coalition.side.RED then
    return country.id.CJTF_RED
  elseif side == coalition.side.BLUE then
    return country.id.CJTF_BLUE
  end
  return country.id.NEUTRAL
end

local function GetRoleMatchedFallback(category, role)
  local fallbacks = {
    -- World-Class Fallbacks: Units guaranteed to exist in base DCS
    MBT = "T-55", IFV = "BMP-2", APC = "BTR-80", AAA = "ZSU-23-4 Shilka",
    LN = "Osa 9A33 bm", TR = "Osa 9A33 bm", SR = "p-19 s-125 sr", CP = "SKP-11",
    TRANSPORT = "Ural-375", RIFLEMAN = "Infantry AK",
    -- Air Roles (Universal)
    BVR = "MiG-21Bis", WVR = "MiG-21Bis", AWACS = "A-50",
    -- Ship
    CORVETTE = "Molniya"
  }
  if role and fallbacks[role] then return fallbacks[role] end
  if category == "AIR" then return "MiG-21Bis" end
  if category == "SHIP" then return "Molniya" end
  return "Container Red 1"
end

function TCS.Common.Spawn.GetStaticCategory(typeName)
  if string.find(typeName, "Warehouse") or string.find(typeName, "Depot") or string.find(typeName, "Tank") then
    return "Warehouses"
  end
  return "Fortifications" -- Default for Bunkers, Outposts, Armed House
end

--- Spawns a DCS group based on unit types and options.
-- @param unitTypes (string|table) Single unit type string or table of types for random selection.
-- @param coord (Coordinate) MOOSE Coordinate object for spawn location.
-- @param opts (table) Options: { coalition, skill, formation, spacing, name, heading, alt, payload, livery, speed, role }
-- @param categoryName (string) "GROUND", "AIR", "SHIP", "STRUCTURE"
-- @param count (number) Number of units in the group.
function TCS.Common.Spawn.Group(unitTypes, coord, opts, categoryName, count)
  opts = opts or {}
  
  local coal = opts.coalition or coalition.side.RED
  local countryID = opts.country or GetCountryForCoalition(coal)
  env.info(string.format("TCS(SPAWN): Creating %s group for coalition %d using Country ID %d", categoryName or "UNIT", coal, countryID))
  local point = coord and coord:GetVec2() or {x=0, y=0}

  local typeTag = "MIX"
  if type(unitTypes) == "string" then 
    typeTag = unitTypes
  elseif type(unitTypes) == "table" and unitTypes.id then
    typeTag = unitTypes.id
  end
  local name = opts.name or ("TCS_DYN_" .. (categoryName or typeTag) .. "_" .. math.random(100000))
  local heading = opts.heading and (opts.heading * (math.pi/180)) or (math.random(0, 359) * (math.pi/180))

  -- Handle Static Objects (Structures)
  if categoryName == "STRUCTURE" then
    local staticData = {
      type = unitTypes,
      name = name,
      x = point.x,
      y = point.y,
      heading = heading,
      category = TCS.Common.Spawn.GetStaticCategory(unitTypes),
    }
    local s = coalition.addStaticObject(countryID, staticData)
    if s then return STATIC:FindByName(name, false) end
    return nil
  end

  -- Dynamic Group Spawn
  local domain = categoryName or (opts and opts.domain)
  local catID = Group.Category.GROUND
  if domain and (string.find(domain, "SHIP") or string.find(domain, "MAR") or domain == "SEA") then
    catID = Group.Category.SHIP
  elseif domain and (string.find(domain, "AIR") or string.find(domain, "PLANE")) then
    catID = Group.Category.AIRPLANE
  end
  
  local groupData = {
    visible = false,
    task = (catID == Group.Category.AIRPLANE) and "CAP" or "Ground Nothing",
    uncontrollable = false,
    hidden = false,
    units = {},
    name = name,
  }

  local unitCount = count or 1
  local alt = opts.alt or 2000 -- Default 2000m for air if not specified
  if catID ~= Group.Category.AIRPLANE then alt = nil end
  
  local formationPoints = TCS.Common.SpawnSpacing.GetPoints(opts.formation, unitCount, opts.spacing)

  local function resolveLivery(l)
    if type(l) == "table" and #l > 0 then return l[math.random(#l)] end
    return l
  end

  for i, offset in ipairs(formationPoints) do
    local uType = unitTypes
    if type(unitTypes) == "table" then
      local pool = unitTypes.unit_types or unitTypes
      if #pool > 0 then uType = pool[math.random(#pool)] end
    end

    -- World-Class Validation: Prevent DCS from defaulting to Leopard-2 tanks
    if world and world.getDescByName and not world.getDescByName(uType) then
        local fallback = GetRoleMatchedFallback(categoryName, opts.role)
        env.error(string.format("TCS(SPAWN): CRITICAL - Unit type '%s' is unknown to DCS. Falling back to role-matched unit '%s'. Catalog ID: %s", tostring(uType), fallback, tostring(typeTag)))
        uType = fallback
    end

    local rotatedX = offset.x * math.cos(heading) - offset.y * math.sin(heading)
    local rotatedY = offset.x * math.sin(heading) + offset.y * math.cos(heading)
    
    table.insert(groupData.units, {
      x = point.x + rotatedX,
      y = point.y + rotatedY,
      alt = alt,
      type = uType,
      name = name .. "_Unit_" .. i,
      heading = heading,
      skill = opts.skill or "Average",
      payload = opts.payload,
      livery_id = resolveLivery(opts.livery),
      speed = opts.speed or 150,
    })
  end
  
  -- Ensure a basic route exists (stationary for ground/ship by default)
  if not groupData.route then
    groupData.route = {
      points = {
        [1] = {
          x = point.x,
          y = point.y,
          action = "Off Road",
          type = "Turning Point",
          speed = 0
        }
      }
    }
  end

  coalition.addGroup(countryID, catID, groupData)
  
  if Group.getByName(name) then
    return GROUP:FindByName(name) or GROUP:New(name)
  end
  return nil
end

--- Low-level wrapper to spawn a static from raw DCS data table.
function TCS.Common.Spawn.StaticFromData(staticData, side)
  local cty = GetCountryForCoalition(side or coalition.side.RED)
  local res = coalition.addStaticObject(cty, staticData)
  if STATIC then return STATIC:FindByName(staticData.name, false) end
  return res
end

env.info("TCS(COMMON.SPAWN): ready")