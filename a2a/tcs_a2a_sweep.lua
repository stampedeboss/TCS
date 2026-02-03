-- TCS_sweep.lua (A2A SWEEP - Two Phase Push)
-- Sweep = clear a corridor ahead of the player (relative).
-- TWO PHASE:
--   PHASE 1: PUSH to the Push Line (near edge of corridor). No bandits yet.
--   PHASE 2: SANITIZE the corridor (bandits distributed through corridor, optional trickle).
-- Completion: corridor sanitized (no bandits alive) OR duration expires. Optional EGRESS call.

local CFG = TCS.A2A.Config
local A2A = TCS.A2A

TCS.A2A.SWEEP = {}
local SWEEP = TCS.A2A.SWEEP

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
      AwacsControllerCallBraa(mode.Rec.Group, mode.Rec.Unit, ref:GetCoordinate(), "BANDITS GROUP", "", descriptor or "SWEEP")
      if mode.Rec.Session then
        StartAwacsUpdatesSession(mode.Rec.Session, function()
          local r, _ = A2A.ClosestBanditAndRange(mode.Rec, mode.Spawned)
          if r and r:IsAlive() then return r:GetCoordinate() end
          return nil
        end, "BANDITS GROUP", "track")
      else
        StartAwacsUpdates(mode.Rec.Group, mode.Rec.Unit, function()
          local r, _ = A2A.ClosestBanditAndRange(mode.Rec, mode.Spawned)
          if r and r:IsAlive() then return r:GetCoordinate() end
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

function SWEEP:Start(rec, durationSec)
  if not rec or not rec.Unit or not rec.Unit:IsAlive() then return nil end
  local unit = rec.Unit
  local group = rec.Group
  local hdg = unit:GetHeading() or 0
  local playerCoord = unit:GetCoordinate()

  local centerDist = CFG.SWEEP.CENTER_MIN_NM + math.random() * (CFG.SWEEP.CENTER_MAX_NM - CFG.SWEEP.CENTER_MIN_NM)
  local jitter = math.random(-CFG.SWEEP.CENTER_JITTER_DEG, CFG.SWEEP.CENTER_JITTER_DEG)
  local sweepHeading = (hdg + jitter) % 360
  local sweepCenter = playerCoord:Translate(centerDist * 1852.0, sweepHeading, true, false)

  -- Push line is the near edge of the corridor (half-length back toward player)
  local pushLine = sweepCenter:Translate((CFG.SWEEP.LENGTH_NM * 1852.0) / 2.0, (sweepHeading + 180) % 360, true, false)

  local mode = {
    Key = "SWEEP",
    Terminated = false,
    StartTime = timer.getTime(),
    EndTime = timer.getTime() + (durationSec or CFG.SWEEP.DURATION_SEC),
    Center = sweepCenter,
    PushLine = pushLine,
    Heading = sweepHeading,
    Spawned = {},
    Rec = rec,
    ControllerStarted = false,
    Phase = 1, -- 1=Push, 2=Sanitize
    SanitizedOnce = false,
  }

  function mode:IsOver()
    if self.Terminated then return true end
    if timer.getTime() >= self.EndTime then return true end
    if self.Phase == 2 and self.SanitizedOnce and _aliveCount(self.Spawned) == 0 then return true end
    return false
  end

  function mode:Terminate(reason)
    if self.Terminated then return end
    self.Terminated = true

    local rsn = tostring(reason or "END")
    if (rsn == "COMPLETE") and CFG.SWEEP.EGRESS_CALL_ENABLED then
      MsgToGroup(group, "SWEEP COMPLETE. EGRESS. " .. NATO_BULLSEYE(self.PushLine), 12)
      if CFG.SWEEP.CONTROLLER_ENABLED then
        AwacsDispatchNATO(group, unit, self.PushLine, "EGRESS", "SURFACE")
      end
    else
      MsgToGroup(group, "SWEEP terminated (" .. rsn .. ").", 8)
    end

    -- Clean up leftovers
    SCHEDULER:New(nil, function()
      for _, g in ipairs(self.Spawned) do
        if g and g:IsAlive() then g:Destroy() end
      end
    end, {}, 30, nil)
  end

  function mode:SpawnSanitizeInitial()
    if self.Terminated then return end
    self.Phase = 2
    self.SanitizedOnce = true

    local count = math.random(CFG.SWEEP.INITIAL_MIN_BANDITS, CFG.SWEEP.INITIAL_MAX_BANDITS)
    for i = 1, count do
      local banditDef = A2A.GetBanditDef()
      if not banditDef then break end
      local where = _randomInCorridor(self.Center, self.Heading, CFG.SWEEP.LENGTH_NM, CFG.SWEEP.WIDTH_NM)
      local alias = string.format("SWP_%d_%d", i, math.random(1,10000))
      local spawnHdg = (self.Heading + 180) % 360
      A2A.SpawnBandit(self.Rec.Session, banditDef, alias, where, spawnHdg, function(g)
        table.insert(self.Spawned, g)
        A2A.TrackSplash(self.Rec.Group, g)
        local fg = FLIGHTGROUP:New(g):SetDetection(true)
        fg:AddMission(AUFTRAG:NewINTERCEPT(unit))
      end)
    end

    MsgToGroup(group, "SWEEP PHASE 2: SANITIZE. " .. NATO_BULLSEYE(self.Center), 12)
    if CFG.SWEEP.CONTROLLER_ENABLED then
      AwacsDispatchNATO(group, unit, self.Center, "SANITIZE", "SURFACE")
    end
    _startController(self, "SWEEP")

    if CFG.SWEEP.TRICKLE_ENABLED then
      _schedule(self, math.random(CFG.SWEEP.WAVE_MIN_SEC, CFG.SWEEP.WAVE_MAX_SEC), function() self:SpawnTrickle() end)
    end

    -- Completion checker
    _schedule(self, 10, function() self:CheckCompletion() end)
  end

  function mode:SpawnTrickle()
    if self:IsOver() then
      if _aliveCount(self.Spawned) == 0 and self.Phase == 2 then
        self:Terminate("COMPLETE")
      else
        self:Terminate("TIME")
      end
      return
    end

    if _aliveCount(self.Spawned) >= (CFG.SWEEP.MAX_ALIVE_BANDITS or 8) then
      _schedule(self, math.random(CFG.SWEEP.WAVE_MIN_SEC, CFG.SWEEP.WAVE_MAX_SEC), function() self:SpawnTrickle() end)
      return
    end

    local desiredAircraft = math.random(CFG.SWEEP.WAVE_MIN_BANDITS, CFG.SWEEP.WAVE_MAX_BANDITS)
    local spawnedAircraft = 0
    local waveGroups = 0

    while spawnedAircraft < desiredAircraft do
      if _aliveCount(self.Spawned) >= (CFG.SWEEP.MAX_ALIVE_BANDITS or 8) then break end
      local banditDef = A2A.GetBanditDef()
      if not banditDef then break end

      local templateSize = A2A.TemplateUnitCount(banditDef)
      waveGroups = waveGroups + 1
      local where = _randomInCorridor(self.Center, self.Heading, CFG.SWEEP.LENGTH_NM, CFG.SWEEP.WIDTH_NM)
      local alias = string.format("SWP_T_%d_%d", waveGroups, math.random(1,10000))
      local spawnHdg = (self.Heading + 180) % 360
      A2A.SpawnBandit(self.Rec.Session, banditDef, alias, where, spawnHdg, function(g)
        table.insert(self.Spawned, g)
        A2A.TrackSplash(self.Rec.Group, g)
        local fg = FLIGHTGROUP:New(g):SetDetection(true)
        fg:AddMission(AUFTRAG:NewINTERCEPT(unit))
      end)
      spawnedAircraft = spawnedAircraft + templateSize
    end

    MsgToGroup(group, "SWEEP: additional contacts injected.", 8)
    _schedule(self, math.random(CFG.SWEEP.WAVE_MIN_SEC, CFG.SWEEP.WAVE_MAX_SEC), function() self:SpawnTrickle() end)
  end

  function mode:CheckCompletion()
    if self.Terminated then return end
    if self:IsOver() then
      if self.Phase == 2 and _aliveCount(self.Spawned) == 0 then
        self:Terminate("COMPLETE")
      else
        self:Terminate("TIME")
      end
      return
    end
    _schedule(self, 10, function() self:CheckCompletion() end)
  end

  function mode:Phase1PushLoop()
    if self.Terminated then return end
    if not unit or not unit:IsAlive() then self:Terminate("PLAYER DOWN"); return end

    -- If timeout, force sanitize
    if (timer.getTime() - self.StartTime) >= (CFG.SWEEP.PUSH_TIMEOUT_SEC or 360) then
      MsgToGroup(group, "SWEEP: push timeout. Proceeding to SANITIZE.", 10)
      self:SpawnSanitizeInitial()
      return
    end

    local dnm = CoordDistanceNM(unit:GetCoordinate(), self.PushLine)
    if dnm and dnm <= (CFG.SWEEP.PUSH_LINE_TOL_NM or 5) then
      MsgToGroup(group, "SWEEP: push line crossed. SANITIZE corridor.", 10)
      self:SpawnSanitizeInitial()
      return
    end

    -- periodic reminder (text + optional dispatch)
    MsgToGroup(group, "SWEEP PHASE 1: PUSH to line. " .. NATO_BULLSEYE(self.PushLine), 10)
    if CFG.SWEEP.CONTROLLER_ENABLED then
      AwacsDispatchNATO(group, unit, self.PushLine, "PUSH", "SURFACE")
    end

    _schedule(self, 45, function() self:Phase1PushLoop() end)
  end

  -- Start PHASE 1
  MsgToGroup(group, "SWEEP started (2-phase). PHASE 1: PUSH to line.", 12)
  MsgToGroup(group, NATO_BULLSEYE(pushLine), 12)
  if CFG.SWEEP.CONTROLLER_ENABLED then
    AwacsDispatchNATO(group, unit, pushLine, "PUSH", "SURFACE")
  end

  _schedule(mode, 20, function() mode:Phase1PushLoop() end)

  return mode
end
