-- TCS_a2a_training.lua
-- A2A Training Range: BFM, ACM, BVR, Drones
-- Focus: Skill building, specific weapon variants, controlled environments.

local CFG = TCS.A2A.Config
local A2A = TCS.A2A

TCS.A2A.Training = {}
local Training = TCS.A2A.Training

---------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------
local function GetPlayer(group) return PLAYERS:GetByGroup(group) end
local function OnCooldown(rec, key) return PLAYERS:OnCooldown(rec, key) end
local function MarkAction(rec, key)
  local dur = (CFG.Cooldowns and CFG.Cooldowns[key]) or 60
  PLAYERS:MarkAction(rec, key, dur)
end

local function _getBanditDef(filters)
  return A2A.GetBanditDef(filters)
end

---------------------------------------------------------------------
-- Spawners
---------------------------------------------------------------------

-- ACM: silent close-in spawn. No controller/AWACS.
local function SpawnACMSingle(rec, spawnCoord, spawnHeading, label, filters)
  local def = _getBanditDef(filters)
  if not def then
    MsgToGroup(rec.Group, "No training templates available for this scenario.", 10)
    return
  end

  -- Shallow copy to avoid mutating shared template and force enemy coalition
  local banditDef = {}
  for k,v in pairs(def) do banditDef[k] = v end
  local playerSide = rec.Group:GetCoalition()
  banditDef.coalition = (playerSide == coalition.side.RED) and coalition.side.BLUE or coalition.side.RED

  local count = 1
  if rec.Session and filters and filters.tier then
    local pCount = TCS.A2A.GetPlayerCount(rec.Session)
    count = math.ceil(pCount * TCS.A2A.GetScalingRatio(filters.tier))
  end

  -- Pass session to spawn function for registration
  A2A.SpawnBandit(rec.Session, banditDef, "ACM_" .. math.random(1, 10000), spawnCoord, spawnHeading, function(spawnGroup)
    -- Delay AI tasking slightly to ensure group is fully registered (fixes 'waypoints' nil error)
    SCHEDULER:New(nil, function()
      if not spawnGroup or not spawnGroup:IsAlive() then return end
      
      local ok, fg = pcall(function() return FLIGHTGROUP:New(spawnGroup) end)
      if ok and fg then
        fg:SetDetection(true)
        fg:AddMission(AUFTRAG:NewINTERCEPT(rec.Unit))
      end
      
      A2A.TrackSplash(rec.Group, spawnGroup)
      
      local typeName = banditDef.unit_types and banditDef.unit_types[1] or "Bandit"
      local braa = A2A.BraaText(rec, spawnGroup) or ""
      TCS.A2A.NotifySession(rec.Session, string.format("ACM (%s): FIGHTS ON! %s\n%s", label, typeName, braa), 10)
    end, {}, 1.0)
  end, count)
end

-- DRONE: Non-maneuvering, WEAPON HOLD.
local function SpawnDroneSingle(rec, spawnCoord, spawnHeading)
  local banditDef = _getBanditDef({role="DRONE"})
  if not banditDef then
    MsgToGroup(rec.Group, "No DRONE configuration available.", 10)
    return
  end

  A2A.SpawnBandit(rec.Session, banditDef, "DRONE_" .. math.random(1, 10000), spawnCoord, spawnHeading, function(spawnGroup)
    -- Set ROE to Weapon Hold for safety (Training)
    A2A.TrackSplash(rec.Group, spawnGroup)
    spawnGroup:OptionROE(ENUMS.ROE.WeaponHold)
    spawnGroup:OptionROTE(ENUMS.ROTE.NoReaction)
    local typeName = banditDef.unit_types and banditDef.unit_types[1] or "Drone"
    local braa = A2A.BraaText(rec, spawnGroup) or ""
    TCS.A2A.NotifySession(rec.Session, string.format("TRAINING: Target %s Spawned (Weapon Hold).\n%s", typeName, braa), 10)
  end)
end

---------------------------------------------------------------------
-- Public Training Functions
---------------------------------------------------------------------

function Training.StartABEAMDogFight(group, variant)
  local rec = GetPlayer(group); if not rec then return end
  if not rec.Session and TCS.SessionManager then rec.Session = TCS.SessionManager:GetOrCreateSessionForGroup(group) end
  local unit = rec.Unit; if not unit or not unit:IsAlive() then return end
  local playerCoord = unit:GetCoordinate()
  local hdg = unit:GetHeading() or 0
  local spawnCoord = playerCoord:Translate(CFG.ACM.ABEAM_M, (hdg - 90 + 360) % 360, true, false)
  local filters = { role = "WVR", var = variant }
  SpawnACMSingle(rec, spawnCoord, hdg, "ABeam", filters)
end

function Training.StartH2HDogFight(group, variant)
  local rec = GetPlayer(group); if not rec then return end
  if not rec.Session and TCS.SessionManager then rec.Session = TCS.SessionManager:GetOrCreateSessionForGroup(group) end
  local unit = rec.Unit; if not unit or not unit:IsAlive() then return end
  local playerCoord = unit:GetCoordinate()
  local hdg = unit:GetHeading() or 0
  local spawnCoord = playerCoord:Translate(CFG.ACM.H2H_M, hdg, true, false)
  local spawnHeading = spawnCoord:HeadingTo(playerCoord)
  local filters = { role = "WVR", var = variant }
  SpawnACMSingle(rec, spawnCoord, spawnHeading, "H2H", filters)
end

function Training.StartDefensiveDogFight(group, variant)
  local rec = GetPlayer(group); if not rec then return end
  if not rec.Session and TCS.SessionManager then rec.Session = TCS.SessionManager:GetOrCreateSessionForGroup(group) end
  local unit = rec.Unit; if not unit or not unit:IsAlive() then return end
  local playerCoord = unit:GetCoordinate()
  local hdg = unit:GetHeading() or 0
  local spawnCoord = playerCoord:Translate(CFG.ACM.DEFENSIVE_M, (hdg + 180) % 360, true, false)
  local spawnHeading = spawnCoord:HeadingTo(playerCoord)
  local filters = { role = "WVR", var = variant }
  SpawnACMSingle(rec, spawnCoord, spawnHeading, "Defensive", filters)
end

function Training.StartDrone(group)
  local rec = GetPlayer(group); if not rec then return end
  if not rec.Session and TCS.SessionManager then rec.Session = TCS.SessionManager:GetOrCreateSessionForGroup(group) end
  local unit = rec.Unit; if not unit or not unit:IsAlive() then return end
  local playerCoord = unit:GetCoordinate()
  local hdg = unit:GetHeading() or 0
  local spawnCoord = playerCoord:Translate(4000, hdg, true, false) -- 2.2 NM ahead
  SpawnDroneSingle(rec, spawnCoord, hdg)
end

-- BVR Training is handled by the core StartIntercept/StartBVR logic in tcs_a2a.lua, 
-- but exposed via menu. If specific BVR training logic is needed, it goes here.
function Training.StartBVR(group, variant)
  -- Re-use core intercept logic but with specific variant templates
  if TCS.A2A.INTERCEPT and TCS.A2A.INTERCEPT.Start then
    -- Note: StartIntercept in core currently randomizes count. 
    -- For training, we might want a specific setup.
    -- For now, we delegate to the core function which supports the session.
    local session = TCS.SessionManager and TCS.SessionManager:GetOrCreateSessionForGroup(group)
    local difficulty = session and session.Difficulty or "G"
    TCS.A2A.INTERCEPT.Start(session, group, difficulty)
  end
end