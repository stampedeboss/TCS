
env.info("TCS(SPAWN): loading")
TCS=TCS or {}; TCS.Spawn={}

-- Backwards compatibility for A2G
TCS.A2G = TCS.A2G or {}; TCS.A2G.Spawn = TCS.Spawn

-- Formation Spacing Utility
TCS.SpawnSpacing = TCS.SpawnSpacing or {}
function TCS.SpawnSpacing.GetPoints(formation, count, spacing)
  local points = {}
  spacing = spacing or 50
  for i = 1, count do
    -- Default to Echelon Right
    local x = (i - 1) * -spacing -- Back
    local y = (i - 1) * spacing  -- Right
    table.insert(points, {x = x, y = y})
  end
  return points
end

function TCS.Spawn.GetStaticCategory(typeName)
  if string.find(typeName, "Warehouse") or string.find(typeName, "Depot") or string.find(typeName, "Tank") then
    return "Warehouses"
  end
  -- Default for Bunkers, Outposts, Armed House
  return "Fortifications"
end

local function GetCountryForCoalition(side)
  local prefs = (side == coalition.side.RED) 
    and {country.id.CJTF_RED, country.id.RUSSIA, country.id.USSR, country.id.CHINA}
    or  {country.id.CJTF_BLUE, country.id.USA, country.id.UK}
    
  for _, cID in ipairs(prefs) do
    if cID and coalition.getCountryCoalition(cID) == side then return cID end
  end
  for _, cID in pairs(country.id) do
    if coalition.getCountryCoalition(cID) == side then return cID end
  end
  return (side == coalition.side.RED) and country.id.RUSSIA or country.id.USA
end

function TCS.Spawn.Group(typeOrName, coord, opts, categoryName, count)
  opts = opts or {}
  
  -- 1. Try Template (Legacy/Override)
  local tpl = type(typeOrName) == "string" and GROUP:FindByName(typeOrName)
  if tpl then
    local g = tpl:CopyToCoalition(opts.coalition or coalition.side.RED)
    if coord then g:SetCoordinate(coord) end
    return g
  end

  -- 2. Setup Common Data
  local coal = opts.coalition or coalition.side.RED
  local countryID = opts.country or GetCountryForCoalition(coal)
  local point = coord and coord:GetVec2() or {x=0, y=0}

  local typeTag = "MIX"
  if type(typeOrName) == "string" then 
    typeTag = typeOrName
  elseif type(typeOrName) == "table" and typeOrName.id then
    typeTag = typeOrName.id
  end
  local name = opts.name or ("TCS_DYN_" .. (categoryName or typeTag) .. "_" .. math.random(100000))
  local heading = opts.heading and (opts.heading * (math.pi/180)) or (math.random(0, 359) * (math.pi/180))

  -- 3. Static Objects (Structures)
  if categoryName == "STRUCTURE" then
    local staticData = {
      type = typeOrName,
      name = name,
      x = point.x,
      y = point.y,
      heading = heading,
      category = TCS.Spawn.GetStaticCategory(typeOrName),
    }
    local s = coalition.addStaticObject(countryID, staticData)
    if s then
      return STATIC:FindByName(name, false)
    end
    return nil
  end

  -- 4. Dynamic Group Spawn
  local domain = categoryName or (opts and opts.domain)
  local catID = Group.Category.GROUND
  if domain and (string.find(domain, "SHIP") or string.find(domain, "MAR") or domain == "SEA") then
    catID = Group.Category.SHIP
  elseif domain and (string.find(domain, "AIR") or string.find(domain, "PLANE")) then
    -- Detect if unit type is a helicopter
    if string.find(string.upper(typeOrName), "KA%-50") or string.find(string.upper(typeOrName), "AH%-64") or string.find(string.upper(typeOrName), "MI%-24") or string.find(string.upper(typeOrName), "UH%-60") then
      catID = Group.Category.HELICOPTER
    else
      catID = Group.Category.AIRPLANE
    end
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
  
  local formationPoints = TCS.SpawnSpacing.GetPoints(opts.formation, unitCount, opts.spacing)

  local function resolveLivery(l)
    if type(l) == "table" and #l > 0 then
      return l[math.random(#l)]
    end
    return l
  end

  for i, offset in ipairs(formationPoints) do
    -- Support mixing unit types within a single group spawn.
    -- If typeOrName is a table (or a catalog entry with unit_types), select a random variation for each unit.
    local uType = typeOrName
    if type(typeOrName) == "table" then
      local pool = typeOrName.unit_types or typeOrName
      if #pool > 0 then uType = pool[math.random(#pool)] end
    end

    -- Rotate the formation point by the group's heading
    local rotatedX = offset.x * math.cos(heading) - offset.y * math.sin(heading)
    local rotatedY = offset.x * math.sin(heading) + offset.y * math.cos(heading)
    
    local ux = point.x + rotatedX
    local uy = point.y + rotatedY

    -- ACTIVE TERRAIN GUARD:
    -- Validates individual unit placement (Surface, Slope, Urban).
    if catID == Group.Category.GROUND and TCS.Placements then
        if not TCS.Placements.IsTerrainAppropriate({x = ux, y = uy}, "LAND") then
            env.info(string.format("TCS(SPAWN): Unit %d at invalid terrain. Attempting local nudge...", i))
            local found = false
            -- Spiral search: check 8 points in increasing radii
            for radius = 10, 100, 20 do
                for angle = 0, 315, 45 do
                    local nx = ux + radius * math.cos(math.rad(angle))
                    local ny = uy + radius * math.sin(math.rad(angle))
                    if TCS.Placements.IsTerrainAppropriate({x = nx, y = ny}, "LAND") then
                        ux, uy = nx, ny
                        found = true; break
                    end
                end
                if found then break end
            end
            if not found then env.warning("TCS(SPAWN): Could not find valid terrain for unit " .. i) end
        end
    end

    table.insert(groupData.units, {
      x = ux,
      y = uy,
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
  
  -- Ensure a basic route exists
  if not groupData.route then
    if catID == Group.Category.AIRPLANE then
    local rAlt = alt or 2000
    local rSpeed = opts.speed or 150
    groupData.route = { 
      points = { 
        [1] = {
          x = point.x,
          y = point.y,
          alt = rAlt,
          type = "Turning Point",
          action = "Turning Point",
          speed = rSpeed,
          task = { 
            id = "ComboTask", 
            params = { 
              tasks = {
                [1] = {
                  enabled = true,
                  auto = false,
                  id = "EngageTargets",
                  number = 1,
                  params = {
                    maxDist = 40000,
                    targetTypes = { "Air" },
                    priority = 0
                  }
                },
                [2] = {
                  enabled = true,
                  auto = false,
                  id = "Orbit",
                  number = 2,
                  params = {
                    pattern = "Circle",
                    altitude = rAlt,
                    speed = rSpeed
                  }
                }
              } 
            } 
          }
        },
        [2] = {
           x = point.x + 1000,
           y = point.y,
           alt = rAlt,
           type = "Turning Point",
           action = "Turning Point",
           speed = rSpeed,
           task = { id = "ComboTask", params = { tasks = {} } }
        }
      } 
    }
    else
      -- Ground/Ship default route (Stationary)
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
  end

  coalition.addGroup(countryID, catID, groupData)
  
  -- Return a MOOSE GROUP object. Using :New() ensures the object is created 
  -- even if the MOOSE Database hasn't processed the Birth event yet.
  if Group.getByName(name) then
    return GROUP:FindByName(name) or GROUP:New(name)
  end
  return nil
end


--- Spawns a group from a raw data template (TCS native).
-- @param name (string) The name for the new group.
-- @param template (table) A table containing `category`, `units`, and optional `route`.
-- @param pos (table) A table with {x, y} map coordinates for the spawn point.
-- @param heading (number) The initial heading in degrees.
-- @param side (number|nil) Coalition side (default: RED).
function TCS.Spawn.GroupFromTable(name, template, pos, heading, side)
  local data = {
    name = name,
    task = template.category == Group.Category.AIRPLANE and "CAP" or "Ground Nothing",
    units = {}
  }

  for i, unitType in ipairs(template.units) do
    local offset = (i - 1) * 20
    table.insert(data.units, {
      name = name .. "_U" .. i,
      type = unitType,
      x = pos.x + offset,
      y = pos.y + offset,
      heading = math.rad(heading),
      skill = "High"
    })
  end

  if template.route then data.route = template.route end
  
  local cty = GetCountryForCoalition(side or coalition.side.RED)
  coalition.addGroup(cty, template.category, data)
  return GROUP:FindByName(name)
end

--- Low-level wrapper to spawn a group from raw DCS data table.
-- Ensures correct Country ID mapping.
function TCS.Spawn.GroupFromData(groupData, category, side)
  local cty = GetCountryForCoalition(side or coalition.side.RED)
  coalition.addGroup(cty, category, groupData)
  
  if Group.getByName(groupData.name) then
    return GROUP:FindByName(groupData.name) or GROUP:New(groupData.name)
  end
  return nil
end

--- Low-level wrapper to spawn a static from raw DCS data table.
-- Ensures correct Country ID mapping.
function TCS.Spawn.StaticFromData(staticData, side)
  local cty = GetCountryForCoalition(side or coalition.side.RED)
  local res = coalition.addStaticObject(cty, staticData)
  if STATIC then return STATIC:FindByName(staticData.name, false) end
  return res
end

env.info("TCS(SPAWN): ready")
