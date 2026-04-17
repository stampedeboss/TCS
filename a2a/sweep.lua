-- TCS_sweep.lua (A2A SWEEP - Two Phase Push)
-- Sweep = clear a corridor ahead of the player (relative).
-- TWO PHASE:
-- TCS A2A SWEEP
--
-- Purpose:
--   Spawns an adversary group in a sweep geometry (wide, forward)
--   relative to the requesting group.
---------------------------------------------------------------------
env.info("TCS(A2A.SWEEP): loading")

TCS = TCS or {}
TCS.A2A = TCS.A2A or {}

local CFG = TCS.A2A.Config
local A2A = TCS.A2A

TCS.A2A.SWEEP = {}
local SWEEP = TCS.A2A.SWEEP
local TAG = "SWEEP"

local function _aliveCount(list)
  return A2A.AliveAircraftCount(list)
end

local function _schedule(mode, delaySec, fn)
  if not mode or mode.Terminated then return end
  SCHEDULER:New(nil, function() if mode and not mode.Terminated then fn() end end, {}, delaySec, nil)
end

-- Random coordinate inside corridor centered on 'center', aligned with heading 'hdg'.
local function _randomInCorridor(centerCoord, hdgDeg, lengthNM, widthNM)
  local halfLenM = (lengthNM * 1852.0) / 2.0
  local halfWidM = (widthNM * 1852.0) / 2.0
  local along = (math.random() * 2.0 - 1.0) * halfLenM
  local cross = (math.random() * 2.0 - 1.0) * halfWidM
  local c1 = centerCoord:Translate(along, hdgDeg, true, false)
  local c2 = c1:Translate(cross, (hdgDeg + 90) % 360, true, false)
  return c2
end

local function _startController(mode, descriptor)
  if mode.ControllerStarted then return end
  mode.ControllerStarted = true
  if not CFG.SWEEP.CONTROLLER_ENABLED then return end

  _schedule(mode, 3, function()
    local ref, _ = A2A.ClosestBanditAndRange(mode.Rec, mode.Spawned)
    if ref then
      TCS.A2A.AwacsControllerCallBraa(mode.Rec.Group, mode.Rec.Unit, ref, "BANDITS GROUP", "", descriptor or "SWEEP")
      if mode.Rec.Session then
        TCS.A2A.StartAwacsUpdatesSession(mode.Rec.Session, function()
          local r, _ = A2A.ClosestBanditAndRange(mode.Rec, mode.Spawned)
          if r and r:IsAlive() then return r end
          return nil
        end, "BANDITS GROUP", "track")
      else
        TCS.A2A.StartAwacsUpdates(mode.Rec.Group, mode.Rec.Unit, function()
          local r, _ = A2A.ClosestBanditAndRange(mode.Rec, mode.Spawned)
          if r and r:IsAlive() then return r end
          return nil
        end, "BANDITS GROUP", "track")
      end
    end

    A2A.AutoManageBandits_Controller(mode.Rec, mode.Spawned, "BANDITS GROUP",
      function() return mode:IsOver() end,
      function(_) end,
      mode.Rec.Session
    )
  end)
end

function SWEEP:Start(rec, durationSec, echelon)
  if not rec or not rec.Unit or not rec.Unit:IsAlive() then return nil end
  local unit = rec.Unit
  local group = rec.Group
  local hdg = unit:GetHeading() or 0
  local playerCoord = unit:GetCoordinate()

  local centerDist = CFG.SWEEP.CENTER_MIN_NM + math.random() * (CFG.SWEEP.CENTER_MAX_NM - CFG.SWEEP.CENTER_MIN_NM)
  local jitter = math.random(-CFG.SWEEP.CENTER_JITTER_DEG, CFG.SWEEP.CENTER_JITTER_DEG)
  local sweepHeading = (hdg + jitter) % 360
  local sweepCenter = playerCoord:Translate(centerDist * 1852.0, sweepHeading, true, false)

  local anchor = TCS.Scenario.Setup(rec.Session, TAG, sweepCenter, group, {Bias=false, domain="A2A"})
  if not anchor then return nil end

  local difficulty = TCS.GetTierFromEchelon(TCS.ResolveDifficulty(rec.Session, "AIR", echelon))
  local desiredCount = TCS.A2A.GetSortieCount(difficulty, rec.Session)

  local pushLine = sweepCenter:Translate((CFG.SWEEP.LENGTH_NM * 1852.0) / 2.0, (sweepHeading + 180) % 360, true, false)
  
  -- Create the FSM to manage the sweep state
  local fsm = FSM:New("SWEEP_FSM")

  function fsm:Terminate(reason)
    if self.Terminated then return end
    self.Terminated = true

    local rsn = tostring(reason or "END")
    if rsn ~= "COMPLETE" then
      TCS.A2A.NotifySession(self.Rec.Session, "SWEEP terminated (" .. rsn .. ").", 8)
    end

    SCHEDULER:New(nil, function()
      for _, g in ipairs(self.Spawned) do
        if g and g:IsAlive() then g:Destroy() end
      end
      TCS.Scenario.Stop(self.Rec.Session, TAG)
    end, {}, 30, nil)
  end

  function fsm:SpawnSanitizeInitial()
    if self.Terminated then return end
    self.SanitizedOnce = true
    
    local diffKey = self.Difficulty
    if self.Difficulty == "RANDOM" and CFG.SWEEP.DIFFICULTY["RANDOM"] then
       diffKey = CFG.SWEEP.DIFFICULTY["RANDOM"]:resolve()
       TCS.A2A.NotifySession(self.Rec.Session, "SWEEP: Random difficulty selected -> " .. diffKey, 5)
    end

    local diffCfg = CFG.SWEEP.DIFFICULTY[diffKey] or CFG.SWEEP.DIFFICULTY["G"]
    local desiredAircraft = self.DesiredCount
    local spawnedAircraft = 0
    local i = 0

    while spawnedAircraft < desiredAircraft do
      i = i + 1
      local attemptBomber = (math.random() <= 0.25)
      local bomberDef = attemptBomber and A2A.GetBanditDef({ role = "BOMBER" }) or nil

      if bomberDef then
         local escortDef = A2A.GetBanditDef({ role = "BVR", tier = diffCfg.tier })
         if escortDef then
            local where = _randomInCorridor(self.Center, self.Heading, CFG.SWEEP.LENGTH_NM, CFG.SWEEP.WIDTH_NM)
            local alias = string.format("SWP_%d_%d", i, math.random(1,10000))
            local spawnHdg = (self.Heading + 180) % 360
            local bCount = math.random(1,2)
            
            A2A.SpawnBandit(self.Rec.Session, bomberDef, alias.."_B", where, spawnHdg, function(g)
               SCHEDULER:New(nil, function()
                 if not g or not g:IsAlive() then return end
                 table.insert(self.Spawned, g)
                 A2A.TrackSplash(self.Rec.Group, g)
                 
                 local ok, fg = pcall(function() return FLIGHTGROUP:New(g) end)
                 if ok and fg then fg:SetDetection(true); fg:AddMission(AUFTRAG:NewINTERCEPT(unit)) end
                 
                 local ePos = where:Translate(3 * 1852.0, (spawnHdg + 90) % 360, true, false)
                 A2A.SpawnBandit(self.Rec.Session, escortDef, alias.."_E", ePos, spawnHdg, function(eg)
                   SCHEDULER:New(nil, function()
                     if not eg or not eg:IsAlive() then return end
                     table.insert(self.Spawned, eg)
                     A2A.TrackSplash(self.Rec.Group, eg)
                     
                     local eok, efg = pcall(function() return FLIGHTGROUP:New(eg) end)
                     if eok and efg then efg:SetDetection(true); efg:AddMission(AUFTRAG:NewESCORT(g)) end
                   end, {}, 0.5)
                 end, 2)
               end, {}, 0.5)
            end, bCount)
            spawnedAircraft = spawnedAircraft + bCount + 2
         end
      else
         local banditDef = A2A.GetBanditDef({ role = "BVR", tier = diffCfg.tier })
         if not banditDef then break end
         local where = _randomInCorridor(self.Center, self.Heading, CFG.SWEEP.LENGTH_NM, CFG.SWEEP.WIDTH_NM)
         local alias = string.format("SWP_%d_%d", i, math.random(1,10000))
         local spawnHdg = (self.Heading + 180) % 360
         A2A.SpawnBandit(self.Rec.Session, banditDef, alias, where, spawnHdg, function(g)
           SCHEDULER:New(nil, function()
             if not g or not g:IsAlive() then return end
             table.insert(self.Spawned, g)
             A2A.TrackSplash(self.Rec.Group, g)
             
             local ok, fg = pcall(function() return FLIGHTGROUP:New(g) end)
             if ok and fg then fg:SetDetection(true); fg:AddMission(AUFTRAG:NewINTERCEPT(unit)) end
           end, {}, 0.5)
         end, 2)
         spawnedAircraft = spawnedAircraft + 2
      end
    end

    TCS.A2A.NotifySession(self.Rec.Session, "SWEEP PHASE 2: SANITIZE. " .. NATO_BULLSEYE(self.Center), 12)
    if CFG.SWEEP.CONTROLLER_ENABLED then AwacsDispatchNATO(group, unit, self.Center, "SANITIZE", "SURFACE") end
    _startController(self, "SWEEP")

    if CFG.SWEEP.TRICKLE_ENABLED then
      _schedule(self, math.random(CFG.SWEEP.WAVE_MIN_SEC, CFG.SWEEP.WAVE_MAX_SEC), function() self:SpawnTrickle() end)
    end

    _schedule(self, 10, function() self:CheckCompletion() end)
  end

  function fsm:SpawnTrickle()
    if self:IsInState("Done") then return end
    if timer.getTime() >= self.EndTime then self:OnEvent("Timeout"); return end
    
    if _aliveCount(self.Spawned) >= (CFG.SWEEP.MAX_ALIVE_BANDITS or 8) then
      _schedule(self, math.random(CFG.SWEEP.WAVE_MIN_SEC, CFG.SWEEP.WAVE_MAX_SEC), function() self:SpawnTrickle() end)
      return
    end

    local diffKey = self.Difficulty
    if self.Difficulty == "RANDOM" and CFG.SWEEP.DIFFICULTY["RANDOM"] then diffKey = CFG.SWEEP.DIFFICULTY["RANDOM"]:resolve() end

    local diffCfg = CFG.SWEEP.DIFFICULTY[diffKey] or CFG.SWEEP.DIFFICULTY["G"]
    local desiredAircraft = math.max(1, math.ceil(self.DesiredCount * 0.33))
    local spawnedAircraft = 0
    local waveGroups = 0

    while spawnedAircraft < desiredAircraft do
      if _aliveCount(self.Spawned) >= (CFG.SWEEP.MAX_ALIVE_BANDITS or 8) then break end
      
      local attemptBomber = (math.random() <= 0.25)
      local bomberDef = attemptBomber and A2A.GetBanditDef({ role = "BOMBER" }) or nil

      if bomberDef then
         local escortDef = A2A.GetBanditDef({ role = "BVR", tier = diffCfg.tier })
         if not escortDef then break end
         waveGroups = waveGroups + 1
         local where = _randomInCorridor(self.Center, self.Heading, CFG.SWEEP.LENGTH_NM, CFG.SWEEP.WIDTH_NM)
         local alt = math.random(CFG.SWEEP.ALT_MIN or 18000, CFG.SWEEP.ALT_MAX or 32000)
         where:SetAltitude(alt * 0.3048)
         local alias = string.format("SWP_T_%d_%d", waveGroups, math.random(1,10000))
         local spawnHdg = (self.Heading + 180) % 360
         
         local bCount = math.random(1,2)
         A2A.SpawnBandit(self.Rec.Session, bomberDef, alias.."_B", where, spawnHdg, function(g)
            SCHEDULER:New(nil, function()
              if not g or not g:IsAlive() then return end
              table.insert(self.Spawned, g)
              A2A.TrackSplash(self.Rec.Group, g)
              
              local ok, fg = pcall(function() return FLIGHTGROUP:New(g) end)
              if ok and fg then fg:SetDetection(true); fg:AddMission(AUFTRAG:NewINTERCEPT(unit)) end
              
              local ePos = where:Translate(3 * 1852.0, (spawnHdg + 90) % 360, true, false)
              ePos:SetAltitude(alt * 0.3048)
              A2A.SpawnBandit(self.Rec.Session, escortDef, alias.."_E", ePos, spawnHdg, function(eg)
                SCHEDULER:New(nil, function()
                  if not eg or not eg:IsAlive() then return end
                  table.insert(self.Spawned, eg)
                  A2A.TrackSplash(self.Rec.Group, eg)
                  
                  local eok, efg = pcall(function() return FLIGHTGROUP:New(eg) end)
                  if eok and efg then efg:SetDetection(true); efg:AddMission(AUFTRAG:NewESCORT(g)) end
                end, {}, 0.5)
              end, 2)
            end, {}, 0.5)
         end, bCount)
         spawnedAircraft = spawnedAircraft + bCount + 2
      else
         local banditDef = A2A.GetBanditDef({ role = "BVR", tier = diffCfg.tier })
         if not banditDef then break end
         local groupSize = CFG.SWEEP.WAVE_SIZE or 2
         waveGroups = waveGroups + 1
         local where = _randomInCorridor(self.Center, self.Heading, CFG.SWEEP.LENGTH_NM, CFG.SWEEP.WIDTH_NM)
         local alt = math.random(CFG.SWEEP.ALT_MIN or 18000, CFG.SWEEP.ALT_MAX or 32000)
         where:SetAltitude(alt * 0.3048)
         local alias = string.format("SWP_T_%d_%d", waveGroups, math.random(1,10000))
         local spawnHdg = (self.Heading + 180) % 360
         A2A.SpawnBandit(self.Rec.Session, banditDef, alias, where, spawnHdg, function(g)
           SCHEDULER:New(nil, function()
             if not g or not g:IsAlive() then return end
             table.insert(self.Spawned, g)
             A2A.TrackSplash(self.Rec.Group, g)
             
             local ok, fg = pcall(function() return FLIGHTGROUP:New(g) end)
             if ok and fg then fg:SetDetection(true); fg:AddMission(AUFTRAG:NewINTERCEPT(unit)) end
           end, {}, 0.5)
         end, groupSize)
         spawnedAircraft = spawnedAircraft + groupSize
      end
    end

    TCS.A2A.NotifySession(self.Rec.Session, "SWEEP: additional contacts injected.", 8)
    _schedule(self, math.random(CFG.SWEEP.WAVE_MIN_SEC, CFG.SWEEP.WAVE_MAX_SEC), function() self:SpawnTrickle() end)
  end

  function fsm:CheckCompletion()
    if self:IsInState("Done") then return end
    if timer.getTime() >= self.EndTime then self:OnEvent("Timeout"); return end

    if self.SanitizedOnce and _aliveCount(self.Spawned) == 0 then
      self:OnEvent("AllDead")
      return
    end

    _schedule(self, 10, function() self:CheckCompletion() end)
  end

  function fsm:Phase1PushLoop()
    if self:IsInState("Done") then return end
    if not unit or not unit:IsAlive() then self:OnEvent("PlayerDown"); return end

    if (timer.getTime() - self.StartTime) >= (CFG.SWEEP.PUSH_TIMEOUT_SEC or 360) then
      self:OnEvent("PushTimeout")
      return
    end

    local dnm = CoordDistanceNM(unit:GetCoordinate(), self.PushLine)
    if dnm and dnm <= (CFG.SWEEP.PUSH_LINE_TOL_NM or 5) then
      self:OnEvent("CrossedLine")
      return
    end

    TCS.A2A.NotifySession(self.Rec.Session, "SWEEP PHASE 1: PUSH to line. " .. NATO_BULLSEYE(self.PushLine), 10)
    if CFG.SWEEP.CONTROLLER_ENABLED then TCS.A2A.AwacsDispatchNATO(group, unit, self.PushLine, "PUSH", "SURFACE") end

    _schedule(self, 45, function() self:Phase1PushLoop() end)
  end

  -- Populate FSM properties
  fsm.Rec = rec
  fsm.StartTime = timer.getTime()
  fsm.EndTime = timer.getTime() + (durationSec or CFG.SWEEP.DURATION_SEC)
  fsm.Center = sweepCenter
  fsm.PushLine = pushLine
  fsm.Heading = sweepHeading
  fsm.Spawned = {}
  fsm.ControllerStarted = false
  fsm.SanitizedOnce = false
  fsm.Difficulty = difficulty
  fsm.DesiredCount = desiredCount
  fsm.Terminated = false

  -- Define FSM States and Transitions
  fsm:SetState({ "Push", "Sanitize", "Done" })

  fsm:OnEnterPush(function(fsm)
    TCS.A2A.NotifySession(fsm.Rec.Session, "SWEEP started (2-phase). PHASE 1: PUSH to line.", 12)
    TCS.A2A.NotifySession(fsm.Rec.Session, NATO_BULLSEYE(fsm.PushLine), 12)
    if CFG.SWEEP.CONTROLLER_ENABLED then TCS.A2A.AwacsDispatchNATO(group, unit, fsm.PushLine, "PUSH", "SURFACE") end
    _schedule(fsm, 20, function() fsm:Phase1PushLoop() end)
  end)

  fsm:OnEnterSanitize(function(fsm, event)
    if event == "CrossedLine" then TCS.A2A.NotifySession(fsm.Rec.Session, "SWEEP: push line crossed. SANITIZE corridor.", 10)
    elseif event == "PushTimeout" then TCS.A2A.NotifySession(fsm.Rec.Session, "SWEEP: push timeout. Proceeding to SANITIZE.", 10) end
    fsm:SpawnSanitizeInitial()
  end)

  fsm:OnEnterDone(function(fsm, event)
    local reason = "COMPLETE"
    if event == "Timeout" then reason = "TIME"
    elseif event == "PlayerDown" then reason = "PLAYER DOWN"
    elseif event == "Terminate" then reason = "USER_TERMINATE"
    end
    fsm:Terminate(reason)
  end)

  fsm:AddTransition("Push", "Sanitize", "CrossedLine")
  fsm:AddTransition("Push", "Sanitize", "PushTimeout")
  fsm:AddTransition("Sanitize", "Done", "AllDead")
  fsm:AddTransition("*", "Done", "Timeout")
  fsm:AddTransition("*", "Done", "PlayerDown")
  fsm:AddTransition("*", "Done", "Terminate")

  -- Draw Zone on F10 Map
  TCS.Scenario.Draw(rec.Session, TAG, sweepCenter, nil, 40000, {1,0,0,1}, {1,0,0,0.15})

  -- The FSM itself is the task handle
  local taskHandle = fsm
  function taskHandle:IsOver()
    return self:IsInState("Done")
  end

  fsm:Start("Push")
  return taskHandle
end

env.info("TCS(A2A.SWEEP): ready")
