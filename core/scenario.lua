---------------------------------------------------------------------
-- TCS SCENARIO HELPER
-- Consolidates common lifecycle logic for A2A and A2G modules.
-- core/scenario.lua
-- Purpose: Unified orchestration for task lifecycle and F10 drawing.
---------------------------------------------------------------------
env.info("TCS(SCENARIO): loading")

TCS = TCS or {}
TCS.Scenario = {}

TCS.Scenario._NextMarkID = 2850000 -- Start at a high block to avoid ME collisions

--- Central ID generator for F10 marks/drawings.
function TCS.Scenario.GetNextMarkID()
  TCS.Scenario._NextMarkID = TCS.Scenario._NextMarkID + 1
  return TCS.Scenario._NextMarkID
end

--- Stops a scenario and cleans up its F10 drawings.
function TCS.Scenario.Stop(session, tag)
  if not session then return end
  
  -- 1. Clean from registries (despawn units)
  if TCS.Registry and TCS.Registry.CleanupByTag then
    TCS.Registry:CleanupByTag(session, tag)
  end

  -- 2. Remove F10 Drawings
  local draws = session[tag .. "_Drawings"]
  if draws then
    for _, id in ipairs(draws) do
      trigger.action.removeMark(id)
    end
  end

  session[tag .. "_Active"] = false
  session[tag .. "_Drawings"] = nil
  if session.ActiveScenarios then session.ActiveScenarios[tag] = nil end
end

--- Prepares a scenario for a session, cleaning up previous tasks of the same type.
-- @param session (table) The session object.
-- @param tag (string) Task identifier (e.g., "BAI", "CAP").
-- @param anchor (Coordinate|string) The requested center point or zone name.
-- @param group (Group) The pilot group.
-- @param opts (table) { Bias = bool, domain = string }
-- @return (Coordinate) The resolved/biased coordinate.
function TCS.Scenario.Setup(session, tag, anchor, group, opts)
  if not session then return anchor end
  opts = opts or {}

  -- 1. Automatic Cleanup of existing task with same tag
  TCS.Scenario.Stop(session, tag)

  -- 2. Normalize anchor (handle Strings as Zone names)
  local finalCoord = anchor
  if type(anchor) == "string" then
    local z = ZONE:FindByName(anchor)
    if z then finalCoord = z:GetCoordinate() end
  elseif type(anchor) == "table" and anchor.GetCoordinate then
    finalCoord = anchor:GetCoordinate()
  end

  if not finalCoord then
    env.error("TCS.Scenario.Setup: Could not resolve coordinate for " .. tostring(anchor))
    return nil
  end

  -- 3. Bias Logic (Push target away based on player course)
  if opts.Bias and group and group:IsAlive() then
    local hdg = group:GetHeading() or 0
    finalCoord = finalCoord:Translate(math.random(5000, 8000), hdg)
  end

  -- 4. Global Bias resolution (Hills, roads, etc)
  if TCS.A2G and TCS.A2G.PlacementBias and TCS.A2G.PlacementBias.Resolve then
    local biased = TCS.A2G.PlacementBias.Resolve(finalCoord, tag)
    if biased then finalCoord = biased end
  end

  -- 5. Register with ZoneManager 
  if TCS.CIC and TCS.CIC.ZoneManager then
      TCS.CIC.ZoneManager.RegisterZone(zoneId, finalCoord)
  end

  -- 6. Trigger visuals/tasking
  if opts.domain == "A2G" or opts.domain == "SEA" then
    if group then
      if TCS.A2G and TCS.A2G.JTAC and TCS.A2G.JTAC.PushWaypoint then
        TCS.A2G.JTAC.PushWaypoint(group, finalCoord, tag)
      end
      trigger.action.smoke(finalCoord:GetVec3(), trigger.smokeColor.Red)
    end
  end

  return finalCoord
end

--- Draws tactical boundaries and labels on the F10 map.
function TCS.Scenario.Draw(zoneId, tag, coord, echelon, radius, color, fill)
  if not zoneId or not coord then return end
  
  -- Delegate to the central F10 module
  if TCS.Common and TCS.Common.Scenario and TCS.Common.Scenario.F10 then
      TCS.Common.Scenario.F10.Draw(zoneId, tag, coord, echelon, radius, nil, nil, nil)
  end
end

function TCS.ResolveDifficulty(zoneId, domain, overrideLevel)
  local level = overrideLevel or "G" -- Defaults to Good/Intermediate if not provided in blueprint
  -- Allow special metadata echelons like "SPAWN" to pass through without re-mapping to standard sizes
  if level == "SPAWN" then return "SPAWN" end

  -- 1. Normalize input to Tier (A/G/H/X)
  local tier = level
  if level ~= "A" and level ~= "G" and level ~= "H" and level ~= "X" then
     tier = TCS.GetTierFromEchelon(level)
  end
  
  -- 2. If domain is AIR (A2A) or SEA (Naval), return Tier (Skill/Type based)
  if domain == "AIR" or domain == "A2A" or domain == "SEA" or domain == "MAR" or domain == "SUW" then
     return tier
  end

  -- 3. If domain is LAND (A2G), map Tier -> Echelon (Force Size based)
  return TCS.GetEchelonFromTier(tier, domain)
end

--- Resolves an input (number, string, or table) into a flat list of Tier strings (A, G, H, X).
-- Used primarily as a content filter for designers.
-- @param input The value to resolve.
-- @return table A table of Tier strings.
function TCS.ResolveTierFilter(input)
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
      -- TCS.GetTierFromEchelon handles "A" or "COMPANY"
      t = TCS.GetTierFromEchelon(val)
    end

    if t and not unique[t] then
      unique[t] = true
      table.insert(results, t)
    end
  end

  return #results > 0 and results or {"G"}
end

function TCS.GetTierFromEchelon(echelonName)
  if not echelonName then return "G" end
  
  if echelonName == "A" or echelonName == "G" or echelonName == "H" or echelonName == "X" then return echelonName end
  if echelonName == "PLATOON" or echelonName == "PATROL" then return "A" end
  if echelonName == "COMPANY" or echelonName == "TASK_UNIT" or echelonName == "SQUADRON" then return "G" end
  if echelonName == "BATTALION" or echelonName == "TASK_GROUP" or echelonName == "WING" then return "H" end
  if echelonName == "BRIGADE" or echelonName == "TASK_FORCE" or echelonName == "AIR_DIVISION" then return "X" end

  local cfg = TCS.Config and TCS.Config.Echelons
  if cfg and cfg[echelonName] and cfg[echelonName].tier then
    return cfg[echelonName].tier
  end
  
  return "G" -- Default
end

function TCS.GetEchelonFromTier(tier, domain)
  local map = TCS.Config and TCS.Config.DifficultyMap
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
function TCS.Scenario.ResolveZone(anchor)
  local targetZone = nil
  if type(anchor) == "string" then
    targetZone = ZONE:FindByName(anchor)
  elseif type(anchor) == "table" and anchor.GetRandomCoordinate then
    targetZone = anchor
  end

  local overrides = {}
  if targetZone then
    local dcsZone = trigger.misc.getZone(targetZone:GetName())
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
        elseif k == "skill" then overrides.skill = p.value
        end
      end
    end
  end
  return targetZone, overrides
end

env.info("TCS(SCENARIO): ready")