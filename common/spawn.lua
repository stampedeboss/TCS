---------------------------------------------------------------------
-- TCS COMMON: SPAWN
-- Low-level group spawning with integrated terrain nudging.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Spawn = {}

TCS.SpawnSpacing = TCS.SpawnSpacing or {}
function TCS.SpawnSpacing.GetPoints(formation, count, spacing)
  local points = {}
  spacing = spacing or 50
  for i = 1, count do
    local x = (i - 1) * -spacing
    local y = (i - 1) * spacing
    table.insert(points, {x = x, y = y})
  end
  return points
end

local function GetCountryForCoalition(side)
  local prefs = (side == coalition.side.RED) 
    and {country.id.CJTF_RED, country.id.RUSSIA, country.id.USSR, country.id.CHINA}
    or  {country.id.CJTF_BLUE, country.id.USA, country.id.UK}
  for _, cID in ipairs(prefs) do
    if cID and coalition.getCountryCoalition(cID) == side then return cID end
  end
  return (side == coalition.side.RED) and country.id.RUSSIA or country.id.USA
end

function TCS.Spawn.Group(typeOrName, coord, opts, categoryName, count)
  opts = opts or {}
  local coal = opts.coalition or coalition.side.RED
  local countryID = opts.country or GetCountryForCoalition(coal)
  local point = coord and coord:GetVec2() or {x=0, y=0}
  local name = opts.name or ("TCS_DYN_" .. (categoryName or "UNIT") .. "_" .. math.random(100000))
  local heading = opts.heading and math.rad(opts.heading) or (math.random(0, 359) * (math.pi/180))

  -- Determine Category
  local domain = categoryName or (opts and opts.domain)
  local catID = Group.Category.GROUND
  if domain and (string.find(domain, "SHIP") or domain == "SEA") then
    catID = Group.Category.SHIP
  elseif domain and (string.find(domain, "AIR") or string.find(domain, "PLANE")) then
    catID = Group.Category.AIRPLANE
  end
  
  local groupData = { units = {}, name = name, task = "Ground Nothing" }
  local unitCount = count or 1
  local alt = opts.alt or 2000
  local formationPoints = TCS.SpawnSpacing.GetPoints(opts.formation, unitCount, opts.spacing)

  for i, offset in ipairs(formationPoints) do
    local uType = type(typeOrName) == "table" and (typeOrName.unit_types and typeOrName.unit_types[1] or typeOrName[1]) or typeOrName

    local rotatedX = offset.x * math.cos(heading) - offset.y * math.sin(heading)
    local rotatedY = offset.x * math.sin(heading) + offset.y * math.cos(heading)
    local ux = point.x + rotatedX
    local uy = point.y + rotatedY

    -- UPGRADED: Individual unit terrain nudge
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

    table.insert(groupData.units, {
      x = ux, y = uy, alt = (catID == Group.Category.AIRPLANE and alt or nil),
      type = uType, name = name .. "_U" .. i, heading = heading, skill = opts.skill or "Average"
    })
  end

  coalition.addGroup(countryID, catID, groupData)
  return Group.getByName(name) and (GROUP:FindByName(name) or GROUP:New(name)) or nil
end