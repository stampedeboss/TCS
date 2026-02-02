-- TCS_cap.lua (A2A CAP)
-- CAP is relative to player. Spawns waves near a CAP center point.
-- Controller is optional via CFG.CAP.CONTROLLER_ENABLED.

CAP = {}

local function _aliveCount(list)
  return A2A.AliveAircraftCount(list)
end

local function _scheduleNextWave(mode, delaySec)
  if not mode or mode.Terminated then return end
  SCHEDULER:New(nil, function() if mode and not mode.Terminated then mode:SpawnWave() end end, {}, delaySec, nil)
end

function CAP:Start(rec, durationSec)
  if not rec or not rec.Unit or not rec.Unit:IsAlive() then return nil end
  local unit = rec.Unit
  local group = rec.Group

  local hdg = unit:GetHeading() or 0
  local playerCoord = unit:GetCoordinate()

  local centerDist = CFG.CAP.CENTER_MIN_NM + math.random() * (CFG.CAP.CENTER_MAX_NM - CFG.CAP.CENTER_MIN_NM)
  local jitter = math.random(-CFG.CAP.CENTER_JITTER_DEG, CFG.CAP.CENTER_JITTER_DEG)
  local capCenter = playerCoord:Translate(centerDist * 1852.0, hdg + jitter, true, false)

  local mode = {
    Key = "CAP",
    Terminated = false,
    StartTime = timer.getTime(),
    EndTime = timer.getTime() + (durationSec or CFG.CAP.DURATION_SEC),
    CapCenter = capCenter,
    Spawned = {},
    Rec = rec,
  }

  function mode:IsOver()
    return self.Terminated or (timer.getTime() >= self.EndTime)
  end

  function mode:Terminate(reason)
    if self.Terminated then return end
    self.Terminated = true
    MsgToGroup(group, "CAP terminated (" .. tostring(reason or "END") .. ").", 8)
    -- RTB/despawn already handled by controller manager when it sees mode end, but also sweep leftover
    SCHEDULER:New(nil, function()
      for _, g in ipairs(self.Spawned) do
        if g and g:IsAlive() then g:Destroy() end
      end
    end, {}, 30, nil)
  end

  function mode:SpawnWave()
    if self:IsOver() then self:Terminate("TIME"); return end

    if _aliveCount(self.Spawned) >= (CFG.CAP.MAX_ALIVE_BANDITS or 8) then
      -- Try again later without spawning more
      _scheduleNextWave(self, math.random(CFG.CAP.WAVE_MIN_SEC, CFG.CAP.WAVE_MAX_SEC))
      return
    end

    local desiredAircraft = math.random(CFG.CAP.WAVE_MIN_BANDITS, CFG.CAP.WAVE_MAX_BANDITS)
local spawnedThisWave = {}
local spawnedAircraft = 0
local waveGroups = 0

while spawnedAircraft < desiredAircraft do
  if _aliveCount(self.Spawned) >= (CFG.CAP.MAX_ALIVE_BANDITS or 8) then break end
  local templateName = A2A.GetRandomBanditTemplateName()
  if not templateName then break end

  local templateSize = A2A.TemplateUnitCount(templateName)
  waveGroups = waveGroups + 1
      local templateName = A2A.GetRandomBanditTemplateName()
      if not templateName then break end

      local dist = CFG.CAP.RADIUS_MIN_NM + math.random() * (CFG.CAP.RADIUS_MAX_NM - CFG.CAP.RADIUS_MIN_NM)
      local brg = math.random(0, 359)
      local where = self.CapCenter:Translate(dist * 1852.0, brg, true, false)
      local alias = string.format("CAP_%d_%d", waveGroups, math.random(1,10000))

      A2A.SpawnBanditFromTemplate(templateName, alias, where, (brg + 180) % 360, function(g)
        table.insert(self.Spawned, g)
        table.insert(spawnedThisWave, g)
        self.Rec.ActiveBandits[g:GetName()] = g

        local fg = FLIGHTGROUP:New(g):SetDetection(true)
        fg:AddMission(AUFTRAG:NewINTERCEPT(unit))
  spawnedAircraft = spawnedAircraft + templateSize
end
)
    end

    if #spawnedThisWave > 0 then
      MsgToGroup(group, "CAP: wave spawned (" .. tostring(#spawnedThisWave) .. " bandit(s)).", 8)

      if CFG.CAP.CONTROLLER_ENABLED then
        SCHEDULER:New(nil, function()
          local ref, _ = A2A.ClosestBanditAndRange(self.Rec, self.Spawned)
          if ref then
            AwacsControllerCallBraa(group, unit, ref:GetCoordinate(), "BANDITS GROUP", "", "STANDBY")
            if self.Rec.Session then
              StartAwacsUpdatesSession(self.Rec.Session, function()
                local r, _ = A2A.ClosestBanditAndRange(self.Rec, self.Spawned)
                if r and r:IsAlive() then return r:GetCoordinate() end
                return nil
              end, "BANDITS GROUP", "track")
            else
              StartAwacsUpdates(group, unit, function()
                local r, _ = A2A.ClosestBanditAndRange(self.Rec, self.Spawned)
                if r and r:IsAlive() then return r:GetCoordinate() end
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

    _scheduleNextWave(self, math.random(CFG.CAP.WAVE_MIN_SEC, CFG.CAP.WAVE_MAX_SEC))
  end

  MsgToGroup(group, "CAP started. Defend the CAP area. " .. NATO_BULLSEYE(capCenter), 12)

  -- Start first wave quickly
  _scheduleNextWave(mode, 5)

  return mode
end
