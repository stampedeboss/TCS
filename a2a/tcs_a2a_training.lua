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
  local banditDef = _getBanditDef(filters)
  if not banditDef then
    MsgToGroup(rec.Group, "No training templates available for this scenario.", 10)
    return
  end

  -- Pass session to spawn function for registration
  A2A.SpawnBandit(rec.Session, banditDef, "ACM_" .. math.random(1, 10000), spawnCoord, spawnHeading, function(spawnGroup)
    local fg = FLIGHTGROUP:New(spawnGroup):SetDetection(true)
    A2A.TrackSplash(rec.Group, spawnGroup)
    fg:AddMission(AUFTRAG:NewINTERCEPT(rec.Unit))
    MsgToGroup(rec.Group, "ACM (" .. label .. "): FIGHTS ON!", 10)
  end)
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
    local groupMoose = GROUP:FindByName(spawnGroup:GetName())
    if groupMoose then
      groupMoose:OptionROE(ENUMS.ROE.WeaponHold)
      groupMoose:OptionROTE(ENUMS.ROTE.NoReaction)
    end
    MsgToGroup(rec.Group, "TRAINING: Target Drone Spawned (Weapon Hold).", 10)
  end)
end

---------------------------------------------------------------------
-- Public Training Functions
---------------------------------------------------------------------

function Training.StartABEAMDogFight(group, variant)
  local rec = GetPlayer(group); if not rec then return end
  local unit = rec.Unit; if not unit or not unit:IsAlive() then return end
  local playerCoord = unit:GetCoordinate()
  local hdg = unit:GetHeading()
  local spawnCoord = playerCoord:Translate(CFG.ACM.ABEAM_M, (hdg - 90), true, false)
  local filters = { role = "WVR", var = variant }
  SpawnACMSingle(rec, spawnCoord, hdg, "ABeam", filters)
end

function Training.StartH2HDogFight(group, variant)
  local rec = GetPlayer(group); if not rec then return end
  local unit = rec.Unit; if not unit or not unit:IsAlive() then return end
  local playerCoord = unit:GetCoordinate()
  local hdg = unit:GetHeading()
  local spawnCoord = playerCoord:Translate(CFG.ACM.H2H_M, hdg, true, false)
  local spawnHeading = spawnCoord:HeadingTo(playerCoord)
  local filters = { role = "WVR", var = variant }
  SpawnACMSingle(rec, spawnCoord, spawnHeading, "H2H", filters)
end

function Training.StartDefensiveDogFight(group, variant)
  local rec = GetPlayer(group); if not rec then return end
  local unit = rec.Unit; if not unit or not unit:IsAlive() then return end
  local playerCoord = unit:GetCoordinate()
  local hdg = unit:GetHeading()
  local spawnCoord = playerCoord:Translate(CFG.ACM.DEFENSIVE_M, (hdg - 180), true, false)
  local spawnHeading = spawnCoord:HeadingTo(playerCoord)
  local filters = { role = "WVR", var = variant }
  SpawnACMSingle(rec, spawnCoord, spawnHeading, "Defensive", filters)
end

function Training.StartDrone(group)
  local rec = GetPlayer(group); if not rec then return end
  local unit = rec.Unit; if not unit or not unit:IsAlive() then return end
  local playerCoord = unit:GetCoordinate()
  local hdg = unit:GetHeading()
  local spawnCoord = playerCoord:Translate(4000, hdg, true, false) -- 2.2 NM ahead
  SpawnDroneSingle(rec, spawnCoord, hdg)
end

-- BVR Training is handled by the core StartIntercept/StartBVR logic in tcs_a2a.lua, 
-- but exposed via menu. If specific BVR training logic is needed, it goes here.
function Training.StartBVR(group, variant)
  -- Re-use core intercept logic but with specific variant templates
  if TCS.A2A.StartIntercept then
    -- Note: StartIntercept in core currently randomizes count. 
    -- For training, we might want a specific setup.
    -- For now, we delegate to the core function which supports the session.
    A2A.StartIntercept(group) 
  end
end