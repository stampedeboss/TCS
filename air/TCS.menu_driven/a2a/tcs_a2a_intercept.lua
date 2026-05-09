---------------------------------------------------------------------
-- TCS A2A INTERCEPT
--
-- Purpose:
--   Dynamic generation of Air-to-Air intercept scenarios.
--
-- Logic:
--   • Anchor: Session owner or requesting group.
--   • Geometry: 40-80 NM, +/- 90-135 degrees off nose (Flank/Beam).
--   • Templates: Uses BANDIT_BVR_* naming convention.
---------------------------------------------------------------------

env.info("TCS(A2A.INTERCEPT): loading")

TCS = TCS or {}
TCS.A2A = TCS.A2A or {}
TCS.A2A.INTERCEPT = {}
local TAG = "INTERCEPT"

local function GetSpawnGeometry(anchorUnit, banditDef)
  local cfg = TCS.A2A.Config.INTERCEPT
  local coord = anchorUnit:GetCoordinate()
  local hdg = anchorUnit:GetHeading() -- Degrees
  
  local minNM = cfg.MIN_NM
  local maxNM = cfg.MAX_NM
  
  if banditDef and banditDef.speed_class == "SLOW" then
     minNM = math.max(10, minNM * 0.5)
     maxNM = math.max(20, maxNM * 0.5)
  elseif banditDef and banditDef.speed_class == "FAST" then
     minNM = minNM * 1.5
     maxNM = maxNM * 1.5
  end
  
  -- Calculate random distance
  local dist = math.random(minNM, maxNM) * 1852 -- NM to Meters
  
  -- Calculate random aspect (Left or Right flank)
  local offset = math.random(cfg.ASPECT_MIN, cfg.ASPECT_MAX)
  if math.random() > 0.5 then offset = -offset end
  
  local spawnHdg = (hdg + offset) % 360
  local spawnCoord = coord:Translate(dist, spawnHdg)
  
  -- Random Altitude
  local alt = math.random(cfg.ALT_MIN, cfg.ALT_MAX)
  spawnCoord:SetAltitude(alt * 0.3048) -- Ft to Meters
  
  return spawnCoord, spawnHdg
end

local function SpawnInterceptGroup(session, def, alias, coord, hdg, anchor, count, label)
  TCS.A2A.SpawnBandit(session, def, alias, coord, hdg, function(g)
    -- Delay tasking to ensure group is fully registered
    SCHEDULER:New(nil, function()
      if not g or not g:IsAlive() then return end
      if g.TaskIntercept then g:SetTask(g:TaskIntercept(anchor:GetGroup()), 1) end
      local typeName = def.unit_types and def.unit_types[1] or "Bandit"
      local rec = { Unit = anchor }
      local braa = TCS.A2A.BraaText(rec, g) or ""
      local msg = string.format("%s Generated: %d x %s\n%s", label, count, typeName, tostring(braa))
      TCS.A2A.NotifySession(session, msg, 15)
    end, {}, 0.5)
  end, count)
end

function TCS.A2A.INTERCEPT.Start(session, group, echelon)
  -- 1. Standard Scenario Setup
  TCS.Scenario.Stop(session, TAG)
  local anchorUnit = group:GetUnit(1)
  if not anchorUnit then return end

  -- Resolve Difficulty & Config FIRST
  local difficulty = TCS.GetTierFromEchelon(TCS.ResolveDifficulty(session, "AIR", echelon))
  if not TCS.A2A.Config.INTERCEPT.DIFFICULTY then return end

  local diffKey = difficulty
  if difficulty == "RANDOM" and TCS.A2A.Config.INTERCEPT.DIFFICULTY["RANDOM"] then
     diffKey = TCS.A2A.Config.INTERCEPT.DIFFICULTY["RANDOM"]:resolve()
     TCS.A2A.NotifySession(session, "INTERCEPT: Random difficulty selected -> " .. diffKey, 5)
  end
  local diffCfg = TCS.A2A.Config.INTERCEPT.DIFFICULTY[diffKey] or TCS.A2A.Config.INTERCEPT.DIFFICULTY["G"]

  -- Select Primary Bandit Definition
  local attemptBomber = (math.random() <= 0.25)
  local bomberDef = attemptBomber and TCS.A2A.GetBanditDef({ role = "BOMBER" }) or nil
  
  local primaryDef = bomberDef
  if not primaryDef then
     primaryDef = TCS.A2A.GetBanditDef({role="BVR", tier=diffCfg.tier})
  end
  
  if not primaryDef then
      MESSAGE:New("TCS A2A: No bandit definition found.", 10):ToGroup(group)
      return
  end

  local spawnCoord, bearingFromAnchor = GetSpawnGeometry(anchorUnit, primaryDef)
  local anchor = TCS.Scenario.Setup(session, TAG, spawnCoord, group, {domain="A2A"})
  if not anchor then return end

  local totalCount = TCS.A2A.GetSortieCount(difficulty, session)
  
  local waveSize = TCS.A2A.Config.INTERCEPT.WAVE_SIZE or 2

  -- Spawn
  local spawnName = string.format("A2A_INT_%s_%d", session and session.Name or "GRP", math.random(1000,9999))
  local spawnHdg = (bearingFromAnchor + 180) % 360

  -- Push Waypoint to Player
  if group and TCS.A2G and TCS.A2G.JTAC and TCS.A2G.JTAC.PushWaypoint then
    TCS.A2G.JTAC.PushWaypoint(group, spawnCoord, "INT")
  end

  -- Draw Zone on F10 Map
  TCS.Scenario.Draw(session, TAG, spawnCoord, nil, 20000, {1,0,0,1}, {1,0,0,0.15})

  local spawnedCount = 0

  if bomberDef then
    -- Spawn Bomber + Escort
    local escortDef = TCS.A2A.GetBanditDef({ role = "BVR", tier=diffCfg.tier })
    if not escortDef then
      MESSAGE:New("TCS A2A: No BVR escort definition found for tier " .. diffCfg.tier, 10):ToGroup(group)
      return
    end

    local aliasBase = spawnName
    local bCount = math.random(1,2)
    local eCount = math.max(2, totalCount - bCount) -- Scale escort to meet desired count

    -- Spawn Bombers
    TCS.A2A.SpawnBandit(session, bomberDef, aliasBase.."_B", spawnCoord, spawnHdg, function(bg)
      SCHEDULER:New(nil, function()
        if not bg or not bg:IsAlive() then return end
        if bg.TaskIntercept then bg:SetTask(bg:TaskIntercept(anchorUnit:GetGroup()), 1) end
        
        local typeName = bomberDef.unit_types and bomberDef.unit_types[1] or "Bomber"
        local rec = { Unit = anchorUnit }
        local braa = TCS.A2A.BraaText(rec, bg) or ""
        local msg = string.format("Intercept Generated: %d x %s\n%s", bCount, typeName, braa)
        TCS.A2A.NotifySession(session, msg, 15)

        -- Spawn Escorts (Nested to protect bombers)
        local ePos = spawnCoord:Translate(3 * 1852.0, (bearingFromAnchor + 90) % 360, true, false)
        ePos:SetAltitude(spawnCoord.y)
        
        -- Spawn initial escort wave immediately
        local initialEscort = math.min(waveSize, eCount)
        TCS.A2A.SpawnBandit(session, escortDef, aliasBase.."_E1", ePos, spawnHdg, function(eg)
          SCHEDULER:New(nil, function()
            if not eg or not eg:IsAlive() then return end
            if eg.TaskEscort then eg:SetTask(eg:TaskEscort(bg), 1) end
            
            local eTypeName = escortDef.unit_types and escortDef.unit_types[1] or "Escort"
            local eBraa = TCS.A2A.BraaText(rec, eg) or ""
            local eMsg = string.format("Escort Generated: %d x %s\n%s", eCount, eTypeName, eBraa)
            TCS.A2A.NotifySession(session, eMsg, 15)
          end, {}, 0.5)
        end, initialEscort)

        -- Schedule remaining escorts as waves
        local remainingEscorts = eCount - initialEscort
        if remainingEscorts > 0 then
           local waveIdx = 1
           local function spawnNextEscortWave()
              if not session.ActiveScenarios[TAG] then return end
              if remainingEscorts <= 0 then return end
              
              waveIdx = waveIdx + 1
              local thisWave = math.min(waveSize, remainingEscorts)
              local wavePos = spawnCoord:Translate(3 * 1852.0 + (waveIdx * 1000), (bearingFromAnchor + 90) % 360, true, false)
              wavePos:SetAltitude(spawnCoord.y)

              TCS.A2A.SpawnBandit(session, escortDef, aliasBase.."_E"..waveIdx, wavePos, spawnHdg, function(eg)
                 SCHEDULER:New(nil, function()
                    if not eg or not eg:IsAlive() then return end
                    if bg and bg:IsAlive() and eg.TaskEscort then eg:SetTask(eg:TaskEscort(bg), 1) end
                 end, {}, 0.5)
              end, thisWave)
              
              remainingEscorts = remainingEscorts - thisWave
              if remainingEscorts > 0 then
                 local delay = math.random(diffCfg.interval_min or 30, diffCfg.interval_max or 60)
                 SCHEDULER:New(nil, spawnNextEscortWave, {}, delay)
              end
           end
           SCHEDULER:New(nil, spawnNextEscortWave, {}, math.random(diffCfg.interval_min or 30, diffCfg.interval_max or 60))
        end
      end, {}, 0.5)
    end, bCount)

  else
    -- Standard Fighter Logic
    local banditDef = primaryDef

    local waveIndex = 0
    local function spawnFighterWave()
       if not session.ActiveScenarios[TAG] then return end
       if spawnedCount >= totalCount then return end
       
       local remaining = totalCount - spawnedCount
       local thisWave = math.random(1, math.min(remaining, waveSize))
       
       waveIndex = waveIndex + 1
       local waveName = string.format("%s_W%d", spawnName, waveIndex)
       
       -- Dynamic positioning: Ensure minimum safety distance from anchor
       local waveCoord = spawnCoord
       if anchorUnit and anchorUnit:IsAlive() then
          local currPos = anchorUnit:GetCoordinate()
          local dist = currPos:Get2DDistance(spawnCoord)
          local minSafe = 20 * 1852 -- 20 NM minimum buffer
          
          if dist < minSafe then
             -- Push back along the spawn axis (away from anchor) to maintain buffer
             local push = minSafe - dist
             waveCoord = spawnCoord:Translate(push, (spawnHdg + 180) % 360)
          end
       end
       
       -- Small jitter to prevent exact overlap
       local jitter = math.random(500, 1500)
       waveCoord = waveCoord:Translate(jitter, math.random(0,359))
       waveCoord:SetAltitude(spawnCoord.y)

       SpawnInterceptGroup(session, banditDef, waveName, waveCoord, spawnHdg, anchorUnit, thisWave, "Intercept")
       
       spawnedCount = spawnedCount + thisWave
       if spawnedCount < totalCount then
          local delay = math.random(diffCfg.interval_min or 30, diffCfg.interval_max or 60)
          SCHEDULER:New(nil, spawnFighterWave, {}, delay)
       end
    end

    spawnFighterWave()
  end

  -- Start Controller Updates
  -- We need to track the spawned groups to provide updates. 
  -- Since SpawnInterceptGroup is async, we'll use a simple finder for the session's bandits.
  SCHEDULER:New(nil, function()
    if session and session.ActiveScenarios[TAG] then
       TCS.A2A.StartAwacsUpdatesSession(session, function()
          -- Find closest bandit in session registry
          -- Note: This assumes Registry is populated. 
          -- For simplicity, we can rely on the fact that SpawnBandit registers them.
          -- A helper to find closest bandit to session lead would be ideal here, but we'll skip complex logic for now.
          return nil -- Placeholder: Intercept usually relies on initial BRAA, but this enables the hook.
       end, "INTERCEPT", "track")
    end
  end, {}, 5)
end

function TCS.A2A.INTERCEPT.MenuRequest(group)
  if not group then return end
  local session = TCS.SessionManager and TCS.SessionManager:GetOrCreateSessionForGroup(group)
  
  -- Default to 'G' (Good) difficulty for menu quick-start
  TCS.A2A.INTERCEPT.Start(session, group, nil)
end

env.info("TCS(A2A.INTERCEPT): ready")