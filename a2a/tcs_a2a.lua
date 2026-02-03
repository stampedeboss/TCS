-- TCS_a2a.lua (A2A)
-- Reworked:
--   * ACM spawns are CLOSE-IN and SILENT (no controller/AWACS).
--   * INTERCEPT spawns are FARTHER and can spawn a RANDOM number of bandits (controller enabled).
--   * Controller logic applies to Intercept/CAP/Escort/BVR.
--   * Controller pacing prevents 'compressed' calls.

local CFG = TCS.A2A.Config
local Sessions = TCS.Sessions

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
  local dur = (CFG.Cooldowns and CFG.Cooldowns[key]) or 60
  PLAYERS:MarkAction(rec, key, dur)
end

local function _getBanditDef(filters)
  filters = filters or {}
  local candidates = {}
  local allDefs = CFG.Bandits or {}

  for _, def in ipairs(allDefs) do
    local defFilters = def.filters or {}
    local match = true
    
    if filters.role and defFilters.role ~= filters.role then match = false end
    if filters.tier and defFilters.tier ~= filters.tier then match = false end
    if filters.type and defFilters.type ~= filters.type then match = false end
    if defFilters.var ~= filters.var then match = false end

    if match then
      table.insert(candidates, def)
    end
  end

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
  local aspect = AspectHotFlankDrag(banditHdg, b2p)

  return string.format("BRAA %s/%d, %d THOUSAND, %s", Pad3(bearing), rangeNM, math.floor(altFt/1000), aspect)
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
end

local function _trackSplashToGroup(playerGroup, spawnedGroup)
  if not spawnedGroup then return end
  _SplashMap[spawnedGroup:GetName()] = playerGroup
end

local function SpawnBandit(session, banditDef, alias, spawnCoord, spawnHeading, onSpawn)
  if not banditDef then return end
  
  local opts = {
    coalition = coalition.side.RED,
    skill = banditDef.skill,
    payload = banditDef.payload,
    livery = banditDef.livery,
    alt = spawnCoord.y,
    heading = spawnHeading
  }

  local g = TCS.Spawn.Group(banditDef.unit_type, spawnCoord, opts, "AIRPLANE", 1)
  if g then
    if session then TCS.A2A.Registry:Register(session, g) end
    if onSpawn then onSpawn(g) end
  end
end

local function _despawnBandits(session)
  if not session then return 0 end
  TCS.A2A.Registry:Cleanup(session)
end

function TerminateMyBandits(group)
  local session = TCS.SessionManager:GetSessionForGroup(group)
  if not session then
    MsgToGroup(group, "Not in an active session.", 8)
    return
  end
  _despawnBandits(session)
  MsgToGroup(group, "Terminated all A2A bandits for your session.", 8)
end

-- Expose controller manager + spawn helper for CAP/Escort modules
-- Template sizing + alive-aircraft counting (counts aircraft, not groups)
local function _templateUnitCount(banditDef)
  -- Dynamic definition size, default 1
  return 1 
end

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

TCS.A2A = TCS.A2A or {}

TCS.A2A.SpawnBandit = SpawnBandit
TCS.A2A.GetBanditDef = _getBanditDef
TCS.A2A.ClosestBanditAndRange = _closestBanditAndRange
TCS.A2A.AnyAlive = _anyAlive
TCS.A2A.BraaText = A2A_BraaText
TCS.A2A.TemplateUnitCount = _templateUnitCount
TCS.A2A.AliveAircraftCount = _aliveAircraftCount
TCS.A2A.DespawnBandits = _despawnBandits
TCS.A2A.TrackSplash = _trackSplashToGroup
TCS.A2A.CleanupSession = _cleanupSession
