
env.info("TCS(SPAWN): loading")
TCS=TCS or {}; TCS.Spawn={}

-- Backwards compatibility for A2G
TCS.A2G = TCS.A2G or {}; TCS.A2G.Spawn = TCS.Spawn

local function GetStaticCategory(typeName)
  if string.find(typeName, "Warehouse") or string.find(typeName, "Depot") or string.find(typeName, "Tank") then
    return "Warehouses"
  end
  -- Default for Bunkers, Outposts, Armed House
  return "Fortifications"
end

function TCS.Spawn.Group(typeOrName, coord, opts, categoryName, count)
  opts = opts or {}
  
  -- 1. Try Template (Legacy/Override)
  local tpl = GROUP:FindByName(typeOrName)
  if tpl then
    local g = tpl:CopyToCoalition(opts.coalition or coalition.side.RED)
    if coord then g:SetCoordinate(coord) end
    return g
  end

  -- 2. Setup Common Data
  local coal = opts.coalition or coalition.side.RED
  local countryID = (coal == coalition.side.RED) and country.id.RUSSIA or country.id.USA
  local point = coord and coord:GetVec2() or {x=0, y=0}
  local name = "TCS_DYN_" .. typeOrName .. "_" .. math.random(100000)
  local heading = opts.heading and (opts.heading * (math.pi/180)) or (math.random(0, 359) * (math.pi/180))

  -- 3. Static Objects (Structures)
  if categoryName == "STRUCTURE" then
    local staticData = {
      type = typeOrName,
      name = name,
      x = point.x,
      y = point.y,
      heading = heading,
      category = GetStaticCategory(typeOrName),
    }
    local s = coalition.addStaticObject(countryID, staticData)
    if s then
      return STATIC:FindByName(name, false)
    end
    return nil
  end

  -- 4. Dynamic Group Spawn
  local catID = Group.Category.GROUND
  if categoryName and (string.find(categoryName, "SHIP") or string.find(categoryName, "MAR")) then
    catID = Group.Category.SHIP
  elseif categoryName and (string.find(categoryName, "AIR") or string.find(categoryName, "PLANE")) then
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
  
  local formationPoints = TCS.SpawnSpacing.GetPoints(opts.formation, unitCount, opts.spacing)

  local function resolveLivery(l)
    if type(l) == "table" and #l > 0 then
      return l[math.random(#l)]
    end
    return l
  end

  for i, offset in ipairs(formationPoints) do
    -- Rotate the formation point by the group's heading
    local rotatedX = offset.x * math.cos(heading) - offset.y * math.sin(heading)
    local rotatedY = offset.x * math.sin(heading) + offset.y * math.cos(heading)
    
    table.insert(groupData.units, {
      x = point.x + rotatedX,
      y = point.y + rotatedY,
      alt = alt,
      type = typeOrName,
      name = name .. "_Unit_" .. i,
      heading = heading,
      skill = opts.skill or "Average",
      payload = opts.payload,
      livery_id = resolveLivery(opts.livery),
      speed = opts.speed or 150,
    })
  end
  
  local gDCS = coalition.addGroup(countryID, catID, groupData)
  if gDCS then
    return GROUP:FindByName(name)
  end
  return nil
end
