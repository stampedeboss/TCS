---------------------------------------------------------------------
-- TCS COMMON: SCENARIO UTILS
-- Tools for Architects to resolve zones, echelons, and difficulties.
---------------------------------------------------------------------
env.info("TCS(COMMON.SCENARIO): loading")

TCS = TCS or {}
TCS.Architect = TCS.Architect or {}
TCS.Architect.Scenario = {}

function TCS.Architect.Scenario.ResolveDifficulty(zoneId, domain, overrideLevel)
  local level = overrideLevel or "G"
  if level == "SPAWN" then return "SPAWN" end

  local tier = level
  if level ~= "A" and level ~= "G" and level ~= "H" and level ~= "X" then
     tier = TCS.Architect.Scenario.GetTierFromEchelon(level)
  end
  
  if domain == "AIR" or domain == "SEA" or domain == "MAR" or domain == "SUW" then
     return tier
  end

  return TCS.Architect.Scenario.GetEchelonFromTier(tier, domain)
end

function TCS.Architect.Scenario.ResolveTierFilter(input)
  if not input then return {"G"} end
  
  local raw = type(input) == "table" and input or { input }
  local lookup = { [1] = "A", [2] = "G", [3] = "H", [4] = "X" }
  local unique = {}
  local results = {}

  for _, val in ipairs(raw) do
    local t = nil
    if type(val) == "number" then
      t = lookup[val]
    elseif type(val) == "string" then
      t = TCS.Architect.Scenario.GetTierFromEchelon(val)
    end

    if t and not unique[t] then
      unique[t] = true
      table.insert(results, t)
    end
  end

  return #results > 0 and results or {"G"}
end

function TCS.Architect.Scenario.GetTierFromEchelon(echelonName)
  if not echelonName then return "G" end
  
  if echelonName == "A" or echelonName == "G" or echelonName == "H" or echelonName == "X" then return echelonName end
  if echelonName == "PLATOON" or echelonName == "PATROL" then return "A" end
  if echelonName == "COMPANY" or echelonName == "TASK_UNIT" or echelonName == "SQUADRON" then return "G" end
  if echelonName == "BATTALION" or echelonName == "TASK_GROUP" or echelonName == "WING" then return "H" end
  if echelonName == "BRIGADE" or echelonName == "TASK_FORCE" or echelonName == "AIR_DIVISION" then return "X" end

  local cfg = TCS.Common and TCS.Common.Defaults and TCS.Common.Defaults.Echelons
  if cfg and cfg[echelonName] and cfg[echelonName].tier then
    return cfg[echelonName].tier
  end
  
  return "G"
end

function TCS.Architect.Scenario.GetEchelonFromTier(tier, domain)
  local map = TCS.Common and TCS.Common.Defaults and TCS.Common.Defaults.DifficultyMap
  if not map then return "COMPANY" end  

  local level = 2
  if tier == "A" then level = 1
  elseif tier == "G" then level = 2
  elseif tier == "H" then level = 3
  elseif tier == "X" then level = 4
  end

  local d = domain or "LAND"
  if d == "A2G" then d = "LAND" end
  if d == "MAR" or d == "SUW" then d = "SEA" end
  
  local entry = map[level]
  if entry then return entry[d] or entry["LAND"] end
  return "COMPANY"
end

--- Common logic to resolve a zone and its optional ME properties.
function TCS.Architect.Scenario.ResolveZone(anchor)
  local targetZone = nil
  local overrides = {}

  if type(anchor) == "string" then
    -- Strip trailing/leading spaces just in case
    local cleanAnchor = string.match(anchor, "^%s*(.-)%s*$") or anchor

    -- 1. Try MOOSE Zone Databases (Covers both Circles and Polygons)
    targetZone = ZONE:FindByName(cleanAnchor) or (ZONE_POLYGON and ZONE_POLYGON:FindByName(cleanAnchor))
    if not targetZone and anchor ~= cleanAnchor then
      targetZone = ZONE:FindByName(anchor) or (ZONE_POLYGON and ZONE_POLYGON:FindByName(anchor))
    end

    -- 2. Try Airbase Database
    if not targetZone then
      targetZone = AIRBASE:FindByName(cleanAnchor) or AIRBASE:FindByName(anchor)
      if not targetZone then
        -- Partial match for Airbases (e.g., "Senaki" -> "Senaki-Kolkhi")
        local upAnchor = string.upper(cleanAnchor)
        for _, dcsAb in ipairs(world.getAirbases()) do
          if dcsAb and dcsAb.getName then
            local abName = dcsAb:getName()
            if string.find(string.upper(abName), upAnchor, 1, true) then
              targetZone = AIRBASE:FindByName(abName)
              break
            end
          end
        end
      end
    end

    -- 3. Extract Mission Editor Properties from Native DCS
    local dcsZone = trigger.misc.getZone(cleanAnchor) or trigger.misc.getZone(anchor)
    if dcsZone and dcsZone.properties then
      for _, p in ipairs(dcsZone.properties) do
        local k = string.lower(p.key)
        if k == "minnm" then overrides.minNm = tonumber(p.value)
        elseif k == "maxnm" then overrides.maxNm = tonumber(p.value)
        elseif k == "reinforce" then overrides.reinforce = (p.value == "true" or p.value == "1")
        elseif k == "ingresshdg" then overrides.ingressHdg = tonumber(p.value)
        elseif k == "ingressarc" then overrides.ingressArc = tonumber(p.value)
        elseif k == "coalition" then overrides.coalition = tonumber(p.value)
        elseif k == "playerside" then overrides.playerSide = tonumber(p.value)
        elseif k == "respawn" then overrides.respawn = (p.value == "true" or p.value == "1")
        elseif k == "duration" then overrides.duration = tonumber(p.value)
        elseif k == "respawndelay" then overrides.respawnDelay = tonumber(p.value)
        elseif k == "threatlevel" then overrides.threatLevel = p.value
        elseif k == "skill" then overrides.threatLevel = p.value -- Legacy fallback
        end
      end
    end

    -- 4. Extreme Fallback: Native DCS Zone Mock
    -- If MOOSE completely failed to catalog the zone, but DCS native sees it, mock it.
    if not targetZone and dcsZone then
      targetZone = {
        GetName = function() return cleanAnchor end,
        GetCoordinate = function() return COORDINATE:NewFromVec3({x=dcsZone.point.x, y=dcsZone.point.y, z=dcsZone.point.z}) end
      }
    end

  elseif type(anchor) == "table" and anchor.GetCoordinate then
    targetZone = anchor
  end

  return targetZone, overrides
end

env.info("TCS(COMMON.SCENARIO): ready")
