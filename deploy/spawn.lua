---------------------------------------------------------------------
-- TCS DEPLOY: LEGACY SPAWNER
-- Preserved exclusively for FARP and Range structural spawning.
---------------------------------------------------------------------
env.info("TCS(DEPLOY.SPAWN): loading")
TCS=TCS or {}; TCS.Spawn={}

TCS.SpawnSpacing = TCS.SpawnSpacing or {}
function TCS.SpawnSpacing.GetPoints(formation, count, spacing)
  local points = {}
  spacing = spacing or 50
  for i = 1, count do
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
  
  local tpl = type(typeOrName) == "string" and GROUP:FindByName(typeOrName)
  if tpl then
    local g = tpl:CopyToCoalition(opts.coalition or coalition.side.RED)
    if coord then g:SetCoordinate(coord) end
    return g
  end

  local coal = opts.coalition or coalition.side.RED
  local countryID = opts.country or GetCountryForCoalition(coal)
  local point = coord and coord:GetVec2() or {x=0, y=0}

  local typeTag = "MIX"
  if type(typeOrName) == "string" then typeTag = typeOrName
  elseif type(typeOrName) == "table" and typeOrName.id then typeTag = typeOrName.id end
  local name = opts.name or ("TCS_DYN_" .. (categoryName or typeTag) .. "_" .. math.random(100000))
  local heading = opts.heading and (opts.heading * (math.pi/180)) or (math.random(0, 359) * (math.pi/180))

  if categoryName == "STRUCTURE" then
    local staticData = { type = typeOrName, name = name, x = point.x, y = point.y, heading = heading, category = TCS.Spawn.GetStaticCategory(typeOrName) }
    local s = coalition.addStaticObject(countryID, staticData)
    if s then return STATIC:FindByName(name, false) end
    return nil
  end

  local domain = categoryName or (opts and opts.domain)
  local catID = Group.Category.GROUND
  if domain and (string.find(domain, "SHIP") or string.find(domain, "MAR") or domain == "SEA") then
    catID = Group.Category.SHIP
  elseif domain and (string.find(domain, "AIR") or string.find(domain, "PLANE")) then
    if string.find(string.upper(typeOrName), "KA%-50") or string.find(string.upper(typeOrName), "AH%-64") or string.find(string.upper(typeOrName), "MI%-24") or string.find(string.upper(typeOrName), "UH%-60") then
      catID = Group.Category.HELICOPTER
    else
      catID = Group.Category.AIRPLANE
    end
  end
  
  local groupData = { visible = false, task = (catID == Group.Category.AIRPLANE) and "CAP" or "Ground Nothing", uncontrollable = false, hidden = false, units = {}, name = name }
  local unitCount = count or 1
  local alt = opts.alt or 2000
  if catID ~= Group.Category.AIRPLANE then alt = nil end
  
  local formationPoints = TCS.SpawnSpacing.GetPoints(opts.formation, unitCount, opts.spacing)
  local function resolveLivery(l) if type(l) == "table" and #l > 0 then return l[math.random(#l)] end return l end

  for i, offset in ipairs(formationPoints) do
    local uType = typeOrName
    if type(typeOrName) == "table" then
      local pool = typeOrName.unit_types or typeOrName
      if #pool > 0 then uType = pool[math.random(#pool)] end
    end

    local rotatedX = offset.x * math.cos(heading) - offset.y * math.sin(heading)
    local rotatedY = offset.x * math.sin(heading) + offset.y * math.cos(heading)
    local ux = point.x + rotatedX
    local uy = point.y + rotatedY

    if catID == Group.Category.GROUND and TCS.Placements then
        if not TCS.Placements.IsTerrainAppropriate({x = ux, y = uy}, "LAND") then
            local found = false
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
        end
    end

    table.insert(groupData.units, { x = ux, y = uy, alt = alt, type = uType, name = name .. "_Unit_" .. i, heading = heading, skill = opts.skill or "Average", payload = opts.payload, livery_id = resolveLivery(opts.livery), speed = opts.speed or 150 })
  end
  
  if not groupData.route then
    if catID == Group.Category.AIRPLANE then
      local rAlt = alt or 2000
      local rSpeed = opts.speed or 150
      groupData.route = { points = { [1] = { x = point.x, y = point.y, alt = rAlt, type = "Turning Point", action = "Turning Point", speed = rSpeed, task = { id = "ComboTask", params = { tasks = { [1] = { enabled = true, auto = false, id = "EngageTargets", number = 1, params = { maxDist = 40000, targetTypes = { "Air" }, priority = 0 } }, [2] = { enabled = true, auto = false, id = "Orbit", number = 2, params = { pattern = "Circle", altitude = rAlt, speed = rSpeed } } } } } }, [2] = { x = point.x + 1000, y = point.y, alt = rAlt, type = "Turning Point", action = "Turning Point", speed = rSpeed, task = { id = "ComboTask", params = { tasks = {} } } } } }
    else
      groupData.route = { points = { [1] = { x = point.x, y = point.y, action = "Off Road", type = "Turning Point", speed = 0 } } }
    end
  end

  coalition.addGroup(countryID, catID, groupData)
  if Group.getByName(name) then return GROUP:FindByName(name) or GROUP:New(name) end
  return nil
end

function TCS.Spawn.GroupFromTable(name, template, pos, heading, side)
  local data = { name = name, task = template.category == Group.Category.AIRPLANE and "CAP" or "Ground Nothing", units = {} }
  for i, unitType in ipairs(template.units) do
    local offset = (i - 1) * 20
    table.insert(data.units, { name = name .. "_U" .. i, type = unitType, x = pos.x + offset, y = pos.y + offset, heading = math.rad(heading), skill = "High" })
  end
  if template.route then data.route = template.route end
  local cty = GetCountryForCoalition(side or coalition.side.RED)
  coalition.addGroup(cty, template.category, data)
  return GROUP:FindByName(name)
end

function TCS.Spawn.GroupFromData(groupData, category, side)
  local cty = GetCountryForCoalition(side or coalition.side.RED)
  coalition.addGroup(cty, category, groupData)
  if Group.getByName(groupData.name) then return GROUP:FindByName(groupData.name) or GROUP:New(groupData.name) end
  return nil
end

function TCS.Spawn.StaticFromData(staticData, side)
  local cty = GetCountryForCoalition(side or coalition.side.RED)
  local res = coalition.addStaticObject(cty, staticData)
  if STATIC then return STATIC:FindByName(staticData.name, false) end
  return res
end

env.info("TCS(DEPLOY.SPAWN): ready")