---------------------------------------------------------------------
-- TCS COMMON SCENARIO: DIFFICULTY
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Common = TCS.Common or {}
TCS.Common.Scenario = TCS.Common.Scenario or {} -- Ensure parent table exists

function TCS.Common.Scenario.ResolveDifficulty(session, domain, overrideLevel)
  local level = overrideLevel or (session and session.Difficulty) or "G"
  if level == "SPAWN" then return "SPAWN" end
  local tier = level
  if level ~= "A" and level ~= "G" and level ~= "H" and level ~= "X" then tier = TCS.Common.Scenario.GetTierFromEchelon(level) end
  if domain == "AIR" or domain == "SEA" then return tier end -- A2A/SUW use Tier directly
  return TCS.Common.Scenario.GetEchelonFromTier(tier, domain) -- A2G maps Tier to Echelon
end

function TCS.Common.Scenario.GetTierFromEchelon(ech)
  local map = { PLATOON="A", COMPANY="G", BATTALION="H", BRIGADE="X" }
  return map[ech] or "G"
end

function TCS.Common.Scenario.GetEchelonFromTier(tier, domain)
  local map = TCS.Common.Config and TCS.Common.Config.DifficultyMap
  if not map then return "COMPANY" end  
  local level = (tier == "A" and 1) or (tier == "G" and 2) or (tier == "H" and 3) or 4
  local entry = map[level]
  return entry and (entry[domain] or entry["LAND"]) or "COMPANY"
end

function TCS.Common.Scenario.ResolveTierFilter(input)
  local raw = type(input) == "table" and input or { input }
  local lookup = { [1] = "A", [2] = "G", [3] = "H", [4] = "X" }
  local results = {}
  local seen = {}

  for _, val in ipairs(raw) do
    local t = type(val) == "number" and lookup[val] or TCS.Common.GetTierFromEchelon(val)
    if t and not seen[t] then
      seen[t] = true
      table.insert(results, t)
    end
  end
  return #results > 0 and results or {"G"}
end