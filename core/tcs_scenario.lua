---------------------------------------------------------------------
-- TCS SCENARIO HELPER
-- Consolidates common lifecycle logic for A2A and A2G modules.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Scenario = {}

-- Standard Stop: Cleans up a specific scenario tag
function TCS.Scenario.Stop(session, tag)
  -- Clean from both A2G and A2A registries if they exist
  if TCS.A2G and TCS.A2G.Registry then TCS.A2G.Registry:CleanupByTag(session, tag) end
  if TCS.A2A and TCS.A2A.Registry then TCS.A2A.Registry:CleanupByTag(session, tag) end
  
  local drawKey = tag .. "_Drawings"
  if session[drawKey] then
    for _, id in ipairs(session[drawKey]) do trigger.action.removeMark(id) end
    session[drawKey] = nil
  end

  if session.ActiveScenarios then session.ActiveScenarios[tag] = nil end
  if session.Targets then session.Targets[tag] = nil end
end

-- Standard Setup: Cleanup, Bias, JTAC, Smoke
function TCS.Scenario.Setup(session, tag, anchor, group, opts)
  opts = opts or {}
  
  -- 1. Cleanup Existing (Stop previous instance of this tag)
  TCS.Scenario.Stop(session, tag)

  -- 2. Anchor Validation & Bias
  if not anchor then
    if group and TCS.A2G and TCS.A2G.Feedback then TCS.A2G.Feedback.ToGroup(group, "TCS: No Anchor provided for " .. tag, 10) end
    return nil
  end

  if opts.Bias and TCS.A2G and TCS.A2G.PlacementBias and TCS.A2G.PlacementBias.Resolve then
    local biased = TCS.A2G.PlacementBias.Resolve(anchor, tag)
    if biased then anchor = biased end
  end
  
  -- Track active state
  session.ActiveScenarios = session.ActiveScenarios or {}
  session.ActiveScenarios[tag] = true
  session.Targets = session.Targets or {}
  session.Targets[tag] = anchor

  -- 3. Domain-specific visuals and tasking
  if opts.domain == "A2G" then
    session.A2G_Target = anchor -- Legacy support for JTAC/AWACS
    if group and TCS.A2G and TCS.A2G.JTAC and TCS.A2G.JTAC.PushWaypoint then
      TCS.A2G.JTAC.PushWaypoint(group, anchor, tag)
    end
    trigger.action.smoke(anchor:GetVec3(), trigger.smokeColor.Red)
  elseif opts.domain == "SEA" then
    session.A2G_Target = anchor
    if group and TCS.A2G and TCS.A2G.JTAC and TCS.A2G.JTAC.PushWaypoint then
      TCS.A2G.JTAC.PushWaypoint(group, anchor, tag)
    end
  end

  return anchor
end

-- Standard Drawing: Circle + Text
function TCS.Scenario.Draw(session, tag, anchor, echelon, radius, color, fill)
  local drawKey = tag .. "_Drawings"
  session[drawKey] = {}
  local mid = math.random(10000, 99999)
  local tid = math.random(10000, 99999)
  local p = anchor:GetVec3()
  trigger.action.circleToAll(-1, mid, p, radius or 5000, color or {1,0,0,1}, fill or {1,0,0,0.15}, 1, true)
  trigger.action.textToAll(-1, tid, p, {1,1,1,1}, {0,0,0,0.5}, 11, tag .. ": " .. (echelon or "Active"), true)
  table.insert(session[drawKey], mid)
  table.insert(session[drawKey], tid)
end

-- Unify Difficulty with Echelon concept
-- A2G uses PLATOON/COMPANY/etc. A2A uses A/G/H/X.
-- This helper maps them if needed, or stores them raw.
function TCS.SetSessionDifficulty(session, echelon)
  if not session then return end
  session.Difficulty = echelon
end

function TCS.ResolveDifficulty(session, domain, overrideLevel)
  local level = overrideLevel or (session and session.Difficulty) or "G"

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

function TCS.GetTierFromEchelon(echelonName)
  if not echelonName then return "G" end
  if echelonName == "PLATOON" or echelonName == "PATROL" then return "A" end
  if echelonName == "COMPANY" or echelonName == "TASK_UNIT" or echelonName == "SQUADRON" then return "G" end
  if echelonName == "BATTALION" or echelonName == "TASK_GROUP" or echelonName == "WING" then return "H" end
  if echelonName == "BRIGADE" or echelonName == "TASK_FORCE" or echelonName == "AIR_DIVISION" then return "X" end
  
  -- Also handle direct tier passing
  if echelonName == "A" or echelonName == "G" or echelonName == "H" or echelonName == "X" then return echelonName end
  
  -- Dynamic lookup from config
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