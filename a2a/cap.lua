-- a2a/cap.lua (A2A CAP)
-- CAP is relative to player. Spawns waves near a CAP center point.
-- Controller is optional via CFG.CAP.CONTROLLER_ENABLED.

TCS = TCS or {}
TCS.A2A = TCS.A2A or {}

local CFG = TCS.A2A.Config
local A2A = TCS.A2A

TCS.A2A.CAP = {}
local CAP = TCS.A2A.CAP
local TAG = "CAP"

--- Starts a CAP centered at a specific coordinate.
-- @param session (table) The TCS session.
-- @param capCenter (Coordinate) The center of the CAP zone.
-- @param durationSec (number) How long the CAP lasts.
-- @param group (Group|nil) Optional: Player group for messages/controller.
function CAP:StartAt(session, capCenter, durationSec, group, echelon)
  -- 1. Standard Scenario Setup
  local anchor = TCS.Scenario.Setup(session, TAG, capCenter, group, {Bias=false, domain="A2A"})
  if not anchor then return nil end

  local echelonName = TCS.ResolveDifficulty(session, "AIR", echelon)
  local difficulty = TCS.GetTierFromEchelon(echelonName)

  local rec = { Session = session, Group = group } -- Minimal record for internal use

  local fsm = FSM:New("CAP_FSM")

  function fsm:Terminate(reason)
    TCS.A2A.NotifySession(self.Rec.Session, "CAP terminated (" .. tostring(reason or "END") .. ").", 8)
    
    -- Schedule cleanup via Scenario helper
    SCHEDULER:New(nil, function()
      TCS.Scenario.Stop(self.Rec.Session, TAG)
      for _, g in ipairs(self.Spawned) do
        if g and g:IsAlive() then g:Destroy() end
      end
    end, {}, 30, nil)
  end

  function fsm:SpawnWave()
    if self:IsInState("Done") then return end
    if timer.getTime() >= self.EndTime then self:OnEvent("Timeout"); return end

    if A2A.AliveAircraftCount(self.Spawned) >= (CFG.CAP.MAX_ALIVE_BANDITS or 8) then
      -- Try again later without spawning more
      self:ScheduleNextWave(math.random(CFG.CAP.WAVE_MIN_SEC, CFG.CAP.WAVE_MAX_SEC))
      return
    end

    local diffKey = self.Difficulty
    if self.Difficulty == "RANDOM" and CFG.CAP.DIFFICULTY["RANDOM"] then
       diffKey = CFG.CAP.DIFFICULTY["RANDOM"]:resolve()
       -- Optional: Notify session of the roll for this wave? Or keep it secret.
    end

    local diffCfg = CFG.CAP.DIFFICULTY[diffKey] or CFG.CAP.DIFFICULTY["G"]
    
    local pCount = TCS.A2A.GetPlayerCount(self.Rec.Session)
    local desiredAircraft = math.ceil(pCount * TCS.A2A.GetScalingRatio(diffKey))
    
    local spawnedThisWave = {}
    local spawnedAircraft = 0
    local waveGroups = 0

    while spawnedAircraft < desiredAircraft do
      if A2A.AliveAircraftCount(self.Spawned) >= (CFG.CAP.MAX_ALIVE_BANDITS or 8) then break end
      
      -- Chance for Bomber Package (25%)
      local attemptBomber = (math.random() <= 0.25)
      local bomberDef = attemptBomber and A2A.GetBanditDef({ role = "BOMBER" }) or nil

      if bomberDef then
         -- Spawn Bomber + Escort
         local escortDef = A2A.GetBanditDef({ role = "BVR", tier = diffCfg.tier })
         if not escortDef then break end

         waveGroups = waveGroups + 1
         local dist = CFG.CAP.RADIUS_MIN_NM + math.random() * (CFG.CAP.RADIUS_MAX_NM - CFG.CAP.RADIUS_MIN_NM)
         local brg = math.random(0, 359)
         local center = self.CapCenter:Translate(dist * 1852.0, brg, true, false)
         local alt = math.random(CFG.CAP.ALT_MIN or 18000, CFG.CAP.ALT_MAX or 32000)
         center:SetAltitude(alt * 0.3048)
         
         local aliasBase = string.format("CAP_%d_%d", waveGroups, math.random(1,10000))
         local spawnHdg = (brg + 180) % 360

         -- Bomber (1-2)
         local bCount = math.random(1,2)
         A2A.SpawnBandit(self.Rec.Session, bomberDef, aliasBase.."_B", center, spawnHdg, function(bg)
            SCHEDULER:New(nil, function()
              if not bg or not bg:IsAlive() then return end
              table.insert(self.Spawned, bg)
              table.insert(spawnedThisWave, bg)
              A2A.TrackSplash(self.Rec.Group, bg)
              
              local ok, fg = pcall(function() return FLIGHTGROUP:New(bg) end)
              if ok and fg then
                fg:SetDetection(true)
                if self.Group then fg:AddMission(AUFTRAG:NewINTERCEPT(self.Group)) else fg:AddMission(AUFTRAG:NewCAP(self.CapCenter, 20000, 15000, self.CapCenter, 20, 350)) end
              end
              
              -- Escort (2)
              local eCount = 2
              local ePos = center:Translate(3 * 1852.0, (brg + 90) % 360, true, false)
              ePos:SetAltitude(alt * 0.3048)
              A2A.SpawnBandit(self.Rec.Session, escortDef, aliasBase.."_E", ePos, spawnHdg, function(eg)
                SCHEDULER:New(nil, function()
                  if not eg or not eg:IsAlive() then return end
                  table.insert(self.Spawned, eg)
                  table.insert(spawnedThisWave, eg)
                  A2A.TrackSplash(self.Rec.Group, eg)
                  
                  local eok, efg = pcall(function() return FLIGHTGROUP:New(eg) end)
                  if eok and efg then
                    efg:SetDetection(true)
                    efg:AddMission(AUFTRAG:NewESCORT(bg))
                  end
                end, {}, 0.5)
              end, eCount)
            end, {}, 0.5)
         end, bCount)

         spawnedAircraft = spawnedAircraft + bCount + eCount
      else
         -- Standard Fighter Logic
         local banditDef = A2A.GetBanditDef({ role = "BVR", tier = diffCfg.tier })
         if not banditDef then break end
         local groupSize = CFG.CAP.WAVE_SIZE or 2
         waveGroups = waveGroups + 1

         local dist = CFG.CAP.RADIUS_MIN_NM + math.random() * (CFG.CAP.RADIUS_MAX_NM - CFG.CAP.RADIUS_MIN_NM)
         local brg = math.random(0, 359)
         local where = self.CapCenter:Translate(dist * 1852.0, brg, true, false)
         local alt = math.random(CFG.CAP.ALT_MIN or 18000, CFG.CAP.ALT_MAX or 32000)
         where:SetAltitude(alt * 0.3048)
         local alias = string.format("CAP_%d_%d", waveGroups, math.random(1,10000))

         local spawnHdg = (brg + 180) % 360
         
         A2A.SpawnBandit(self.Rec.Session, banditDef, alias, where, spawnHdg, function(g)
            -- Delay tasking to ensure group is fully registered
            SCHEDULER:New(nil, function()
              if not g or not g:IsAlive() then return end
              table.insert(self.Spawned, g)
              table.insert(spawnedThisWave, g)
              A2A.TrackSplash(self.Rec.Group, g)
              
              local ok, fg = pcall(function() return FLIGHTGROUP:New(g) end)
              if ok and fg then
                fg:SetDetection(true)
                if self.Group then
                   fg:AddMission(AUFTRAG:NewINTERCEPT(self.Group))
                else
                   fg:AddMission(AUFTRAG:NewCAP(self.CapCenter, 20000, 15000, self.CapCenter, 20, 350))
                end
              end
            end, {}, 0.5)
         end, groupSize)

         spawnedAircraft = spawnedAircraft + groupSize
      end
    end

    if #spawnedThisWave > 0 then
      TCS.A2A.NotifySession(self.Rec.Session, "CAP: wave spawned (" .. tostring(#spawnedThisWave) .. " bandit(s)).", 8)

      if CFG.CAP.CONTROLLER_ENABLED and self.Group then
        SCHEDULER:New(nil, function()
          local ref, _ = A2A.ClosestBanditAndRange(self.Rec, self.Spawned)
          if ref then
            TCS.A2A.AwacsControllerCallBraa(self.Group, nil, ref, "BANDITS GROUP", "", "STANDBY")
            if self.Rec.Session then
              TCS.A2A.StartAwacsUpdatesSession(self.Rec.Session, function()
                local r, _ = A2A.ClosestBanditAndRange(self.Rec, self.Spawned)
                if r and r:IsAlive() then return r end
                return nil
              end, "BANDITS GROUP", "track")
            else
              TCS.A2A.StartAwacsUpdates(self.Group, nil, function()
                local r, _ = A2A.ClosestBanditAndRange(self.Rec, self.Spawned)
                if r and r:IsAlive() then return r end
                return nil
              end, "BANDITS GROUP", "track")
            end
          end

          A2A.AutoManageBandits_Controller(self.Rec, self.Spawned, "BANDITS GROUP",
            function() return self:IsOver() end,
            function(_) end,
            self.Rec.Session
          )
        end, {}, 3, nil)
      end
    end

    self:ScheduleNextWave(math.random(CFG.CAP.WAVE_MIN_SEC, CFG.CAP.WAVE_MAX_SEC))
  end

  function fsm:ScheduleNextWave(delaySec)
    if not self or self.Terminated then return end
    SCHEDULER:New(nil, function() 
      if self and not self:IsInState("Done") then 
        self:SpawnWave() 
      end 
    end, {}, delaySec, nil)
  end

  -- Populate FSM properties
  fsm.Rec = rec
  fsm.StartTime = timer.getTime()
  fsm.EndTime = timer.getTime() + (durationSec or CFG.CAP.DURATION_SEC)
  fsm.CapCenter = anchor
  fsm.Spawned = {}
  fsm.Difficulty = difficulty
  fsm.Group = group

  -- Define FSM States and Transitions
  fsm:SetState({ "Active", "Done" })

  fsm:OnEnterActive(function(fsm)
    TCS.A2A.NotifySession(fsm.Rec.Session, "CAP started. Defend the CAP area. " .. NATO_BULLSEYE(fsm.CapCenter), 12)
    fsm:ScheduleNextWave(5) -- Start first wave
  end)

  fsm:OnEnterDone(function(fsm, event)
    local reason = "COMPLETE"
    if event == "Timeout" then reason = "TIME"
    elseif event == "Terminate" then reason = "USER_TERMINATE"
    end
    fsm:Terminate(reason)
  end)

  fsm:AddTransition("Active", "Done", "Timeout")
  fsm:AddTransition("Active", "Done", "Terminate")

  -- Draw Zone on F10 Map
  TCS.Scenario.Draw(session, TAG, anchor, nil, 30000, {1,0,0,1}, {1,0,0,0.15})

  local taskHandle = fsm
  function taskHandle:IsOver() return self:IsInState("Done") end

  fsm:Start("Active")
  return taskHandle
end

function CAP:Start(rec, durationSec, echelon)
  if not rec or not rec.Unit or not rec.Unit:IsAlive() then return nil end
  local unit = rec.Unit
  local group = rec.Group

  local hdg = unit:GetHeading() or 0
  local playerCoord = unit:GetCoordinate()

  local centerDist = CFG.CAP.CENTER_MIN_NM + math.random() * (CFG.CAP.CENTER_MAX_NM - CFG.CAP.CENTER_MIN_NM)
  local jitter = math.random(-CFG.CAP.CENTER_JITTER_DEG, CFG.CAP.CENTER_JITTER_DEG)
  local capCenter = playerCoord:Translate(centerDist * 1852.0, hdg + jitter, true, false)

  return self:StartAt(rec.Session, capCenter, durationSec, group, echelon)
end