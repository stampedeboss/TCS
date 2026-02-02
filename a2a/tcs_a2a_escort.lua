-- TCS_escort.lua (A2A ESCORT)
-- Escort spawns a friendly package template and then spawns threats relative to that package.
-- Includes PACKAGE_STRIKE as requested.

ESCORT = {}

local function _aliveCount(list)
  return A2A.AliveAircraftCount(list)
end

local function _schedule(mode, delaySec, fn)
  if not mode or mode.Terminated then return end
  SCHEDULER:New(nil, function() if mode and not mode.Terminated then fn() end end, {}, delaySec, nil)
end

local function _spawnPackage(rec, templateName, alias, spawnCoord, headingDeg)
  if not templateName or templateName == "" then return nil end
  local sp = SPAWN:NewWithAlias(templateName, alias):InitHeading(headingDeg)
  local spawned = nil
  sp:OnSpawnGroup(function(g) spawned = g end):SpawnFromVec3(spawnCoord)
  return spawned
end

local function _routePackage(pkgGroup, headingDeg)
  if not pkgGroup or not pkgGroup:IsAlive() then return end
  local start = pkgGroup:GetCoordinate()
  local dest = start:Translate((CFG.ESCORT.PACKAGE_ROUTE_NM or 80) * 1852.0, headingDeg, true, false)
  local v2 = dest:GetVec2()
  local kts = CFG.ESCORT.PACKAGE_SPEED_KTS or 350
  pcall(function()
    pkgGroup:TaskRouteToVec2(v2, kts, "Cone")
  end)
end

function ESCORT:Start(rec, packageTemplate, durationSec)
  if not rec or not rec.Unit or not rec.Unit:IsAlive() then return nil end
  local unit = rec.Unit
  local group = rec.Group
  local hdg = unit:GetHeading() or 0
  local playerCoord = unit:GetCoordinate()

  local pkgSpawn = playerCoord:Translate((CFG.ESCORT.PACKAGE_SPAWN_AHEAD_NM or 10) * 1852.0, hdg, true, false)
  local pkgAlias = "PKG_" .. tostring(math.random(1,10000))

  local pkg = _spawnPackage(rec, packageTemplate, pkgAlias, pkgSpawn, hdg)
  if not pkg then
    MsgToGroup(group, "ESCORT: Failed to spawn package template '" .. tostring(packageTemplate) .. "'.", 10)
    return nil
  end

  _routePackage(pkg, hdg)

  local mode = {
    Key = "ESCORT",
    Terminated = false,
    StartTime = timer.getTime(),
    EndTime = timer.getTime() + (durationSec or CFG.ESCORT.DURATION_SEC),
    Package = pkg,
    PackageTemplate = packageTemplate,
    Threats = {},
    Rec = rec,
  }

  function mode:IsOver()
    if self.Terminated then return true end
    if timer.getTime() >= self.EndTime then return true end
    if (not self.Package) or (not self.Package:IsAlive()) then return true end
    return false
  end

  function mode:Terminate(reason)
    if self.Terminated then return end
    self.Terminated = true
    MsgToGroup(group, "ESCORT terminated (" .. tostring(reason or "END") .. ").", 8)
    if self.Package and self.Package:IsAlive() then pcall(function() self.Package:Destroy() end) end
    for _, g in ipairs(self.Threats) do if g and g:IsAlive() then g:Destroy() end end
  end

  function mode:SpawnThreatWave()
    if self:IsOver() then
      if self.Package and self.Package:IsAlive() then
        self:Terminate("TIME")
      else
        MsgToGroup(group, "ESCORT FAILED: Package destroyed.", 10)
        self:Terminate("FAIL")
      end
      return
    end

    if _aliveCount(self.Threats) >= (CFG.ESCORT.MAX_ALIVE_BANDITS or 10) then
      _schedule(self, math.random(CFG.ESCORT.WAVE_MIN_SEC, CFG.ESCORT.WAVE_MAX_SEC), function() self:SpawnThreatWave() end)
      return
    end

    local pkgCoord = self.Package:GetCoordinate()
    local desiredAircraft = math.random(CFG.ESCORT.THREAT_MIN_BANDITS, CFG.ESCORT.THREAT_MAX_BANDITS)
local spawnedWave = {}
local spawnedAircraft = 0
local waveGroups = 0

while spawnedAircraft < desiredAircraft do
  if _aliveCount(self.Threats) >= (CFG.ESCORT.MAX_ALIVE_BANDITS or 10) then break end
  local tname = A2A.GetRandomBanditTemplateName()
  if not tname then break end

  local templateSize = A2A.TemplateUnitCount(tname)
  waveGroups = waveGroups + 1
      local dist = CFG.ESCORT.THREAT_MIN_NM + math.random() * (CFG.ESCORT.THREAT_MAX_NM - CFG.ESCORT.THREAT_MIN_NM)
      local jitter = math.random(-CFG.ESCORT.THREAT_JITTER_DEG, CFG.ESCORT.THREAT_JITTER_DEG)
      local brg = (hdg + 180 + jitter) % 360
      local center = pkgCoord:Translate(dist * 1852.0, brg, true, false)

      -- spread L/R around center
      local side = ((i % 2) == 0) and 90 or -90
      local off = (math.random() * (CFG.ESCORT.THREAT_SPREAD_NM or 6))
      local where = center:Translate(off * 1852.0, brg + side, true, false)

      local alias = string.format("ESC_%d_%d", waveGroups, math.random(1,10000))
      A2A.SpawnBanditFromTemplate(tname, alias, where, (brg + 180) % 360, function(g)
        table.insert(self.Threats, g)
        table.insert(spawnedWave, g)
        self.Rec.ActiveBandits[g:GetName()] = g
        local fg = FLIGHTGROUP:New(g):SetDetection(true)
        fg:AddMission(AUFTRAG:NewINTERCEPT(self.Package))
      end)
  spawnedAircraft = spawnedAircraft + templateSize
end

    if #spawnedWave > 0 then
      MsgToGroup(group, "ESCORT: threats inbound (" .. tostring(#spawnedWave) .. ").", 8)

      if CFG.ESCORT.CONTROLLER_ENABLED then
        _schedule(self, 3, function()
          local ref, _ = A2A.ClosestBanditAndRange(self.Rec, self.Threats)
          if ref then
            AwacsControllerCallBraa(group, unit, ref:GetCoordinate(), "BANDITS GROUP", "", "STANDBY")
            if self.Rec.Session then
              StartAwacsUpdatesSession(self.Rec.Session, function()
                local r, _ = A2A.ClosestBanditAndRange(self.Rec, self.Threats)
                if r and r:IsAlive() then return r:GetCoordinate() end
                return nil
              end, "BANDITS GROUP", "track")
            else
              StartAwacsUpdates(group, unit, function()
                local r, _ = A2A.ClosestBanditAndRange(self.Rec, self.Threats)
                if r and r:IsAlive() then return r:GetCoordinate() end
                return nil
              end, "BANDITS GROUP", "track")
            end
          end

          A2A.AutoManageBandits_Controller(self.Rec, self.Threats, "BANDITS GROUP",
            function() return self:IsOver() end,
            function(_) end,
            self.Rec.Session
          )
        end)
      end
    end

    _schedule(self, math.random(CFG.ESCORT.WAVE_MIN_SEC, CFG.ESCORT.WAVE_MAX_SEC), function() self:SpawnThreatWave() end)
  end

  MsgToGroup(group, "ESCORT started. Protect package: " .. tostring(packageTemplate), 12)
  MsgToGroup(group, NATO_BULLSEYE(pkgSpawn), 12)

  _schedule(mode, 5, function() mode:SpawnThreatWave() end)

  return mode
end
