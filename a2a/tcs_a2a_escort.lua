-- TCS_escort.lua (A2A ESCORT)
-- Escort spawns a friendly package template and then spawns threats relative to that package.
-- Includes PACKAGE_STRIKE as requested.

local A2A = TCS.A2A

TCS.A2A.ESCORT = {}
local ESCORT = TCS.A2A.ESCORT
local TAG = "ESCORT"

local function _aliveCount(list)
  return A2A.AliveAircraftCount(list)
end

local function _schedule(mode, delaySec, fn)
  if not mode or mode.Terminated then return end
  SCHEDULER:New(nil, function() if mode and not mode.Terminated then fn() end end, {}, delaySec, nil)
end

local function _spawnPackage(rec, pkgRef, alias, spawnCoord, headingDeg)
  -- Apply session-based naming convention for cleanup
  local finalAlias = alias
  if rec.Session and rec.Session.Name then
    finalAlias = string.format("TCS_%s_%s", rec.Session.Name, alias)
  end

  -- Check if pkgRef is a key in CFG.Packages
  local def = nil
  if TCS.Catalog and TCS.Catalog.Query then
    local res = TCS.Catalog.Query({id=pkgRef})
    if res and #res > 0 then def = res[1] end
  end
  local cfg = TCS.A2A.Config
  
  if def then
    -- Dynamic Spawn
    local side = cfg.Coalition or coalition.side.BLUE
    local opts = {
      coalition = side,
      country = TCS.A2A.GetCountryForCoalition(side),
      skill = (def.data and def.data.skill) or "High",
      alt = spawnCoord.y,
      heading = headingDeg,
      name = finalAlias
    }
    local uType = def.unit_types and def.unit_types[1]
    local count = (def.data and def.data.count) or 1
    local g = TCS.Spawn.Group(uType, spawnCoord, opts, "AIRPLANE", count)
    
    -- Ensure MOOSE Group
    if g and not (type(g) == "table" and g.ClassName == "GROUP") then
       local name = (type(g) == "string" and g) or (g.getName and g:getName())
       if name then 
         local wrapped = GROUP:FindByName(name) or GROUP:New(name)
         if wrapped then g = wrapped end
       end
    end
    return g
  else
    -- Legacy Template Spawn
    if not pkgRef or pkgRef == "" then return nil end
    local sp = SPAWN:NewWithAlias(pkgRef, finalName):InitHeading(headingDeg)
    local spawned = nil
    sp:OnSpawnGroup(function(g) spawned = g end):SpawnFromVec3(spawnCoord)
    return spawned
  end
end

local function _routePackage(pkgGroup, destinationCoord, waypoints, speedKts, landingAirbase)
  if not pkgGroup or not pkgGroup:IsAlive() then return end

  pcall(function()
    if landingAirbase then
       local abName = landingAirbase:getName()
       local MooseAirbase = AIRBASE:FindByName(abName)
       if MooseAirbase then
          pkgGroup:TaskLandAtAirbase(MooseAirbase, speedKts, 20000)
          return
       end
    end

    local pts = { pkgGroup:GetCoordinate() }
    if waypoints then
      if type(waypoints) == "table" and waypoints.GetVec2 then
         table.insert(pts, waypoints)
      elseif type(waypoints) == "table" then
         for _, wp in ipairs(waypoints) do table.insert(pts, wp) end
      end
    end
    table.insert(pts, destinationCoord)
    pkgGroup:TaskRoute(pts, speedKts, "Cone")
  end)
end

function ESCORT:Start(rec, packageTemplate, durationSec, echelon, destinationCoord)
  if not rec or not rec.Unit or not rec.Unit:IsAlive() then return nil end
  local unit = rec.Unit
  local group = rec.Group
  local cfg = TCS.A2A.Config.ESCORT
  local hdg = unit:GetHeading() or 0
  local playerCoord = unit:GetCoordinate()

  local pkgSpawn = playerCoord:Translate((cfg.PACKAGE_SPAWN_AHEAD_NM or 10) * 1852.0, hdg, true, false)
  local pkgAlias = "PKG_" .. tostring(math.random(1,10000))

  local difficulty = TCS.ResolveDifficulty(rec.Session, "AIR", echelon)

  -- 1. Standard Scenario Setup
  local anchor = TCS.Scenario.Setup(rec.Session, TAG, pkgSpawn, group, {Bias=false, domain="A2A"})
  if not anchor then return nil end

  local pkg = _spawnPackage(rec, packageTemplate, pkgAlias, pkgSpawn, hdg)
  if not pkg then
    MsgToGroup(group, "ESCORT: Failed to spawn package template '" .. tostring(packageTemplate) .. "'.", 10)
    return nil
  end

  -- Calculate Speed
  local ktsCfg = cfg.PACKAGE_SPEED_KTS
  local kts = 350
  if type(ktsCfg) == "table" then
    kts = ktsCfg.MIN + math.random() * (ktsCfg.MAX - ktsCfg.MIN)
  elseif type(ktsCfg) == "number" then
    kts = ktsCfg
  end

  -- Calculate destination here so we can pass it to Controller
  local dest = destinationCoord
  local landingAirbase = nil

  if not dest then
    local totalTime = (durationSec or cfg.DURATION_SEC) + 300 -- Duration + 5 mins
    local distNM = (kts * totalTime) / 3600
    
    -- Search for suitable airbase
    local side = pkg:GetCoalition()
    local airbases = coalition.getAirbases(side) or {}
    local candidates = {}
    
    for _, ab in ipairs(airbases) do
       local pAb = COORDINATE:NewFromVec3(ab:getPoint())
       local d = pkgSpawn:Get2DDistance(pAb) * 0.000539957 -- meters to NM
       if d >= (distNM * 0.7) and d <= (distNM * 1.3) then
          table.insert(candidates, ab)
       end
    end
    
    if #candidates > 0 then
       landingAirbase = candidates[math.random(#candidates)]
       dest = COORDINATE:NewFromVec3(landingAirbase:getPoint())
    else
       dest = pkgSpawn:Translate(distNM * 1852.0, hdg, true, false)
    end
  end

  local wp1 = pkgSpawn:Translate(10 * 1852.0, hdg, true, false)
  
  -- Generate Dogleg if distance is sufficient
  local routePoints = { wp1 }
  local distTotal = pkgSpawn:Get2DDistance(dest)
  if distTotal > 50 * 1852 then
    local mid = pkgSpawn:Translate(distTotal / 2, pkgSpawn:HeadingTo(dest), true, false)
    local offset = (math.random() > 0.5 and 1 or -1) * math.random(15, 30) * 1852
    local wp2 = mid:Translate(math.abs(offset), (pkgSpawn:HeadingTo(dest) + (offset > 0 and 90 or -90)) % 360, true, false)
    table.insert(routePoints, wp2)
  end

  _routePackage(pkg, dest, routePoints, kts, landingAirbase)

  local mode = {
    Key = "ESCORT",
    Terminated = false,
    StartTime = timer.getTime(),
    EndTime = timer.getTime() + (durationSec or cfg.DURATION_SEC),
    Package = pkg,
    PackageTemplate = packageTemplate,
    Threats = {},
    Rec = rec,
    Difficulty = difficulty,
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
    TCS.A2A.NotifySession(self.Rec.Session, "ESCORT terminated (" .. tostring(reason or "END") .. ").", 8)
    if self.Package and self.Package:IsAlive() then pcall(function() self.Package:Destroy() end) end
    for _, g in ipairs(self.Threats) do if g and g:IsAlive() then g:Destroy() end end
    TCS.Scenario.Stop(self.Rec.Session, TAG)
  end

  function mode:SpawnThreatWave()
    local cfg = TCS.A2A.Config.ESCORT
    if self:IsOver() then
      if self.Package and self.Package:IsAlive() then
        self:Terminate("TIME")
      else
        TCS.A2A.NotifySession(self.Rec.Session, "ESCORT FAILED: Package destroyed.", 10)
        self:Terminate("FAIL")
      end
      return
    end

    if _aliveCount(self.Threats) >= (cfg.MAX_ALIVE_BANDITS or 10) then
      _schedule(self, math.random(cfg.WAVE_MIN_SEC, cfg.WAVE_MAX_SEC), function() self:SpawnThreatWave() end)
      return
    end

    local pkgCoord = self.Package:GetCoordinate()
    local diffKey = self.Difficulty
    if self.Difficulty == "RANDOM" and cfg.DIFFICULTY["RANDOM"] then
       diffKey = cfg.DIFFICULTY["RANDOM"]:resolve()
       -- Optional: Notify session of the roll for this wave
    end

    local diffCfg = cfg.DIFFICULTY[diffKey] or cfg.DIFFICULTY["G"]
    local pCount = TCS.A2A.GetPlayerCount(self.Rec.Session)
    local desiredAircraft = math.ceil(pCount * TCS.A2A.GetScalingRatio(diffKey))

    local spawnedWave = {}
    local spawnedAircraft = 0
    local waveGroups = 0

    while spawnedAircraft < desiredAircraft do
      if _aliveCount(self.Threats) >= (cfg.MAX_ALIVE_BANDITS or 10) then break end
      local banditDef = A2A.GetBanditDef({ role = "BVR", tier = diffCfg.tier })
      if not banditDef then break end

      local groupSize = cfg.WAVE_SIZE or 2
      waveGroups = waveGroups + 1
      
      -- Dynamic Heading: Use Package heading if available, else fallback to initial
      local pkgUnit = self.Package and self.Package:GetUnit(1)
      local currentHdg = (pkgUnit and pkgUnit:GetHeading()) or hdg

      local dist = cfg.THREAT_MIN_NM + math.random() * (cfg.THREAT_MAX_NM - cfg.THREAT_MIN_NM)
      local jitter = math.random(-cfg.THREAT_JITTER_DEG, cfg.THREAT_JITTER_DEG)
      local brg = (currentHdg + jitter) % 360
      local center = pkgCoord:Translate(dist * 1852.0, brg, true, false)

      -- spread L/R around center
      local side = ((waveGroups % 2) == 0) and 90 or -90
      local off = (math.random() * (cfg.THREAT_SPREAD_NM or 6))
      local where = center:Translate(off * 1852.0, brg + side, true, false)

      local alt = math.random(cfg.ALT_MIN or 18000, cfg.ALT_MAX or 32000)
      where:SetAltitude(alt * 0.3048)

      local alias = string.format("ESC_%d_%d", waveGroups, math.random(1,10000))
      A2A.SpawnBandit(self.Rec.Session, banditDef, alias, where, (brg + 180) % 360, function(g)
        SCHEDULER:New(nil, function()
          if not g or not g:IsAlive() then return end
          table.insert(self.Threats, g)
          table.insert(spawnedWave, g)
          A2A.TrackSplash(self.Rec.Group, g)
          
          local ok, fg = pcall(function() return FLIGHTGROUP:New(g) end)
          if ok and fg then
            fg:SetDetection(true)
            fg:AddMission(AUFTRAG:NewINTERCEPT(self.Package))
          end
        end, {}, 0.5)
      end, groupSize)
      spawnedAircraft = spawnedAircraft + groupSize
    end

    if #spawnedWave > 0 then
      TCS.A2A.NotifySession(self.Rec.Session, "ESCORT: threats inbound (" .. tostring(#spawnedWave) .. ").", 8)

      if cfg.CONTROLLER_ENABLED then
        _schedule(self, 3, function()
          local ref, _ = A2A.ClosestBanditAndRange(self.Rec, self.Threats)
          if ref then
            TCS.A2A.AwacsControllerCallBraa(group, unit, ref, "BANDITS GROUP", "", "STANDBY")
            if self.Rec.Session then
              TCS.A2A.StartAwacsUpdatesSession(self.Rec.Session, function()
                local r, _ = A2A.ClosestBanditAndRange(self.Rec, self.Threats)
                if r and r:IsAlive() then return r end
                return nil
              end, "BANDITS GROUP", "track")
            else
              TCS.A2A.StartAwacsUpdates(group, unit, function()
                local r, _ = A2A.ClosestBanditAndRange(self.Rec, self.Threats)
                if r and r:IsAlive() then return r end
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

    _schedule(self, math.random(cfg.WAVE_MIN_SEC, cfg.WAVE_MAX_SEC), function() self:SpawnThreatWave() end)
  end

  -- Draw Zone on F10 Map
  TCS.Scenario.Draw(rec.Session, TAG, pkgSpawn, nil, 10000, {0,0,1,1}, {0,0,1,0.15})

  TCS.A2A.NotifySession(rec.Session, "ESCORT started. Protect package: " .. tostring(packageTemplate), 12)
  TCS.A2A.NotifySession(rec.Session, NATO_BULLSEYE(pkgSpawn), 12)

  if TCS.Controller and TCS.Controller.OnEvent then
    TCS.Controller:OnEvent("ESCORT_START", { session = rec.Session, destination = dest, type = packageTemplate })
  end

  _schedule(mode, 5, function() mode:SpawnThreatWave() end)

  return mode
end
