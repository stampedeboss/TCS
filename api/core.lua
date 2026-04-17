-- a2a/core.lua (A2A)
-- air/core.lua (AIR)
-- Reworked:
--   * ACM spawns are CLOSE-IN and SILENT (no controller/AWACS).
--   * INTERCEPT spawns are FARTHER and can spawn a RANDOM number of bandits (controller enabled).
--   * Controller logic applies to Intercept/CAP/Escort/BVR.
--   * Controller pacing prevents 'compressed' calls.

TCS = TCS or {}
TCS.Config = TCS.Config or {}
TCS.Config.Air = TCS.Config.Air or {}
TCS.Config.Air.Countries = dofile(TCS.GetPath("config/air/countries.lua"))
TCS.Config.Air.Scaling = dofile(TCS.GetPath("config/air/scaling.lua"))
TCS.Config.Air.Settings = dofile(TCS.GetPath("config/air/settings.lua"))
local CFG = TCS.Config.Air.Settings

-- Country Resolution (Cached at start)
local RED_COUNTRY = nil
local BLUE_COUNTRY = nil

local function _initCountries()
  local function find(prefs, side)
    for _, cID in ipairs(prefs) do
      if cID and coalition.getCountryCoalition(cID) == side then return cID end
    end
    for _, cID in pairs(country.id) do
      if coalition.getCountryCoalition(cID) == side then return cID end
    end
    return nil
  end

  RED_COUNTRY = find(TCS.Config.Air.Countries.RED, coalition.side.RED) or country.id.USSR
  BLUE_COUNTRY = find(TCS.Config.Air.Countries.BLUE, coalition.side.BLUE) or country.id.USA
  env.info(string.format("TCS.Air: Init Countries -> RED: %s, BLUE: %s", tostring(RED_COUNTRY), tostring(BLUE_COUNTRY)))
end
_initCountries()

---------------------------------------------------------------------
-- Local Helpers (Delegating to Core)
---------------------------------------------------------------------

local function GetPlayer(group)
  return PLAYERS:GetByGroup(group)
end

local function OnCooldown(rec, key)
  return PLAYERS:OnCooldown(rec, key)
end

local function MarkAction(rec, key)
  local dur = (CFG.COOLDOWNS and CFG.COOLDOWNS[key]) or 60
  PLAYERS:MarkAction(rec, key, dur)
end

local function _getBanditDef(filters)
  filters = filters or {}
  -- Query the Unified Catalog
  local candidates = TCS.Catalog.Query(filters)

  if #candidates > 0 then return candidates[math.random(#candidates)] end
  return nil
end

local function _anyAlive(groups)
  for _, g in ipairs(groups) do
    if g and g:IsAlive() then return true end
  end
  return false
end

local function _closestBanditAndRange(rec, banditGroups)
  if not rec or not rec.Unit or not rec.Unit:IsAlive() then return nil, nil end
  local p = rec.Unit:GetCoordinate()
  local bestG, bestNM = nil, nil
  for _, g in ipairs(banditGroups) do
    if g and g:IsAlive() then
      local nm = CoordDistanceNM(p, g:GetCoordinate())
      if nm and ((not bestNM) or nm < bestNM) then bestNM, bestG = nm, g end
    end
  end
  return bestG, bestNM
end

local function AltFeetFromRef(refGroup, coord)
  local altm = nil
  if refGroup and refGroup.GetHeight then
    local ok, h = pcall(function() return refGroup:GetHeight() end)
    if ok and h then altm = h end
  end
  if (not altm) and refGroup and refGroup.GetAltitude then
    local ok, h = pcall(function() return refGroup:GetAltitude() end)
    if ok and h then altm = h end
  end
  if (not altm) and coord and coord.GetVec3 then
    local ok, v3 = pcall(function() return coord:GetVec3() end)
    if ok and v3 and v3.y then altm = v3.y end
  end
  return FeetFromMeters(altm or 0)
end

local function _safeAspect(banditHdg, b2p)
  if _G.AspectHotFlankDrag then return _G.AspectHotFlankDrag(banditHdg, b2p) or "UNK" end
  -- Fallback if global missing
  local diff = math.abs((banditHdg or 0) - (b2p or 0))
  if diff > 180 then diff = 360 - diff end
  if diff < 45 then return "HOT"
  elseif diff > 135 then return "DRAG"
  else return "FLANK" end
end

function A2A_BraaText(rec, refGroup)
  if not rec or not rec.Unit or not rec.Unit:IsAlive() then return "" end
  if not refGroup or not refGroup:IsAlive() then return "" end
  local p = rec.Unit:GetCoordinate()
  local b = refGroup:GetCoordinate()

  local bearing = math.floor((p:HeadingTo(b) % 360) + 0.5)
  local rangeNM = CoordDistanceNM(p, b)
  if not rangeNM then return "" end
  rangeNM = math.floor(rangeNM + 0.5)

  local altFt = AltFeetFromRef(refGroup, b)
  altFt = math.floor((altFt / 1000) + 0.5) * 1000

  local banditHdg = 0
  pcall(function() banditHdg = refGroup:GetHeading() or 0 end)
  local b2p = math.floor((b:HeadingTo(p) % 360) + 0.5)
  local aspect = _safeAspect(banditHdg, b2p)

  return string.format("BRAA %s/%d, %d THOUSAND, %s", Pad3(bearing), rangeNM, math.floor(altFt/1000), aspect) or ""
end

--- Broadcasts a message to all members of a session.
-- @param session (table) The session object.
-- @param text (string) The message text.
-- @param duration (number) Duration in seconds.
function TCS.Air.NotifySession(session, text, duration)
  if not session then return end
  if session.Broadcast then
    session:Broadcast(text, duration)
  end
  if TCS.AWACS and TCS.AWACS.Say then
    TCS.AWACS.Say(text)
  end
end

function TCS.Air.GetSessionDifficulty(session)
  return TCS.GetTierFromEchelon(TCS.ResolveDifficulty(session, "AIR"))
end

-- Global handler to avoid creating SET_GROUP per spawn (memory leak)
local _SplashMap = {} -- BanditGroupName -> PlayerGroup
local _SplashHandler = EVENTHANDLER:New()
_SplashHandler:HandleEvent(EVENTS.UnitLost)
function _SplashHandler:OnEvent(ed)
  if not ed or not ed.IniGroup then return end
  local gName = ed.IniGroup:GetName()
  local pGroup = _SplashMap[gName]
  if pGroup and pGroup:IsAlive() then
    MsgToGroup(pGroup, "SPLASH!! " .. tostring(ed.IniTypeName), 5)
  end
  _SplashMap[gName] = nil
end

local function _trackSplashToGroup(playerGroup, spawnedGroup)
  if not spawnedGroup then return end
  local name = (spawnedGroup.GetName and spawnedGroup:GetName()) or (spawnedGroup.getName and spawnedGroup:getName())
  if name then _SplashMap[name] = playerGroup end
end

local function SpawnBandit(session, banditDef, alias, spawnCoord, spawnHeading, onSpawn, count)
  if not banditDef then return end
  
  -- Resolve fields from Catalog Entry Schema
  local unitType = banditDef.unit_types and banditDef.unit_types[1]
  if not unitType then return end

  local skill = TCS.Config.Air.Scaling.SKILL_MAP[banditDef.skill_profile] or "Average"
  
  local side = banditDef.coalition or coalition.side.RED

  -- Naming Convention: TCS_<Session>_<Feature/Alias>
  local finalName = alias
  if session and session.Name then
    finalName = string.format("TCS_%s_%s", session.Name, alias)
  else
    finalName = string.format("TCS_GLOBAL_%s", alias)
  end

  local opts = {
    coalition = side,
    country = (side == coalition.side.BLUE) and BLUE_COUNTRY or RED_COUNTRY,
    skill = skill,
    payload = banditDef.data and banditDef.data.payload,
    livery = banditDef.data and banditDef.data.livery,
    alt = spawnCoord.y,
    heading = spawnHeading,
    name = finalName
  }

  env.info(string.format("TCS.Air.SpawnBandit: Spawning Group '%s' | Side: %d | Country: %d", tostring(finalName), opts.coalition, opts.country))
  local g = TCS.Spawn.Group(unitType, spawnCoord, opts, "AIRPLANE", count or 1)
  
  -- 1. Validate Spawn Result
  if not g then
    env.error("TCS.Air.SpawnBandit: Spawn failed for " .. tostring(alias))
    return
  end

  -- 2. Ensure MOOSE Object
  local mooseGroup = g
  if not (type(g) == "table" and g.ClassName == "GROUP") then
    local groupName = nil
    if type(g) == "string" then groupName = g
    elseif type(g) == "table" and g.getName then groupName = g:getName() end

    if groupName then
      mooseGroup = GROUP:FindByName(groupName) or GROUP:New(groupName)
    end
  end

  -- 2b. Fallback: If MOOSE wrapper creation failed (e.g. race condition with DCS), use raw object
  if (not mooseGroup) and g and g.getName then
     env.warning("TCS.Air.SpawnBandit: MOOSE wrapper creation failed for " .. g:getName() .. ". Passing raw DCS object.")
     mooseGroup = g
  end

  -- 3. Final Validation before Callback
  -- Allow raw DCS groups to pass through if wrapper failed, so we can at least try to task them manually
  if mooseGroup then
    if onSpawn then onSpawn(mooseGroup) end
  else
    env.error("TCS.Air.SpawnBandit: Failed to resolve MOOSE GROUP for " .. tostring(alias) .. ". Callback skipped.")
  end
end

local function _resolveDifficulty(weights)
  if weights == "RANDOM" or not weights then
    weights = TCS.Config.Air.Scaling.DEFAULT_WEIGHTS
  end

  local total = 0
  for _, item in ipairs(weights) do total = total + item.w end
  local r = math.random() * total
  local running = 0
  for _, item in ipairs(weights) do
    running = running + item.w
    if r <= running then
      return item.tier
    end
  end
  return weights[#weights].tier -- Fallback
end

local function _despawnBandits(session)
  if not session then return 0 end
  if TCS.SessionManager and TCS.SessionManager.CleanupA2ASpawns then
    return TCS.SessionManager:CleanupA2ASpawns(session)
  end
  return 0
end

function TerminateMyBandits(group)
  local session = TCS.SessionManager:GetSessionForGroup(group)
  if not session then
    MsgToGroup(group, "Not in an active session.", 8)
    return
  end
  if TCS.SessionManager.TerminateSessionScenarios then
    TCS.SessionManager:TerminateSessionScenarios(session)
  end
  
  -- Explicit cleanup call to ensure bandits are removed
  local count = _despawnBandits(session)
  MsgToGroup(group, string.format("Terminated all Air scenarios. Cleaned up %d group(s).", count), 8)
end

-- Expose controller manager + spawn helper for CAP/Escort modules

local function _aliveAircraftCount(groups)
  local n = 0
  for _, g in ipairs(groups or {}) do
    if g and g.IsAlive and g:IsAlive() then
      if g.CountAliveUnits then
        n = n + g:CountAliveUnits()
      elseif g.GetUnits then
        local units = g:GetUnits() or {}
        n = n + #units
      else
        n = n + 1
      end
    end
  end
  return n
end

local function _cleanupSession(sessionName)
  if not Sessions or not sessionName then return end
  Sessions:ForEachMemberRec(sessionName, function(rec)
    _despawnBandits(rec.Session)
  end)
end

function TCS.Air.GetPlayerCount(session)
  if not session or not session.Members then return 1 end
  local count = 0
  for _, _ in pairs(session.Members) do count = count + 1 end
  return count
end

function TCS.Air.GetScalingRatio(tier)
  return TCS.Config.Air.Scaling.RATIOS[tier] or 1.0
end

function TCS.Air.GetSortieCount(tier, session)
  local pCount = TCS.Air.GetPlayerCount(session)
  local ratio = TCS.Air.GetScalingRatio(tier)
  local count = math.ceil(pCount * ratio)
  if count < 1 then count = 1 end
  if count > 4 then count = 4 end -- Hard cap for sanity
  return count
end

function TCS.Air.GetCountryForCoalition(side)
  if side == coalition.side.RED then return RED_COUNTRY end
  if side == coalition.side.BLUE then return BLUE_COUNTRY end
  return RED_COUNTRY
end

-- Wipes all TCS-spawned Air groups from the map (Global Level).
function TCS.Air.CleanupAllSpawns()
  local prefix = "TCS_"
  local count = 0

  local sides = { coalition.side.RED, coalition.side.BLUE, coalition.side.NEUTRAL }
  for _, side in ipairs(sides) do
    local groups = coalition.getGroups(side, Group.Category.AIRPLANE) or {}
    for _, g in ipairs(groups) do
      if g and g:isExist() and string.sub(g:getName(), 1, #prefix) == prefix then
        g:destroy()
        count = count + 1
      end
    end
  end
  
  local msg = string.format("TCS Admin: Wiped %d Air spawns (Global).", count)
  env.info(msg)
  MESSAGE:New(msg, 10):ToAll()
  return count
end

TCS.Air = TCS.Air or {}

TCS.Air.SpawnBandit = SpawnBandit
TCS.Air.GetBanditDef = _getBanditDef
TCS.Air.ClosestBanditAndRange = _closestBanditAndRange
TCS.Air.AnyAlive = _anyAlive
TCS.Air.BraaText = A2A_BraaText
TCS.Air.ResolveDifficulty = _resolveDifficulty
TCS.Air.AliveAircraftCount = _aliveAircraftCount
TCS.Air.DespawnBandits = _despawnBandits
TCS.Air.TrackSplash = _trackSplashToGroup
TCS.Air.CleanupSession = _cleanupSession
TCS.Air.GetScalingRatio = TCS.Air.GetScalingRatio
TCS.Air.GetSortieCount = TCS.Air.GetSortieCount
TCS.Air.CleanupAllSpawns = TCS.Air.CleanupAllSpawns