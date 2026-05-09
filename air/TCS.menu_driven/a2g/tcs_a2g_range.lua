---------------------------------------------------------------------
-- A2G TCS Range Module (MP-safe, owner-aware)
-- Group-based (1 aircraft per group)
-- Shared scoring, exclusive control
---------------------------------------------------------------------

TCS = TCS or {}
TCS.RANGE = TCS.RANGE or {}

TCS.RANGE.Ranges = TCS.RANGE.Ranges or {}   -- keyed by group name

---------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Utilities
---------------------------------------------------------------------

local function ResolveUCID(unit)
  if not unit then return nil end
  -- Try PILOT_ID if available (FunkMan/Core integration)
  if PILOT_ID and PILOT_ID.FromUnit then
    local id = PILOT_ID.FromUnit(unit)
    if id and id.ucid then return id end
  end
  -- Fallback
  return {
    ucid = nil,
    name = unit:GetPlayerName() or "AI"
  }
end

local function SendBotEvent(msg)
  if dcsbot and dcsbot.sendBotTable then
    dcsbot.sendBotTable(msg)
  end
end

local function DestroyStatics(range)
  for _, obj in ipairs(range.statics) do
    if obj and obj:isExist() then
      obj:destroy()
    end
  end
  range.statics = {}
end

local function DestroyMobiles(range)
  for _, grp in ipairs(range.mobiles or {}) do
    if grp and grp:isExist() then
      grp:destroy()
    end
  end
  range.mobiles = {}
end


local function ResolveCatalogEntry(filter)
  if TCS.Catalog and TCS.Catalog.Query then
    local candidates = TCS.Catalog.Query(filter)
    if #candidates > 0 then
      return candidates[math.random(#candidates)]
    end
  end
  return nil
end

local function start_funkman (R)
  if not debug then return end
  local info = debug.getinfo(1, 'S')
  local current_file_path = info.source:sub(2) -- Remove the leading '@'
  local subString = "FlyingWrecks"

  if string.find(current_file_path, 'FlyingWrecks') then
	  R:SetFunkManOn(10043)
    env.info("FunkMan Started: 10043")
		return
  end
  if string.find(current_file_path, 'Stampede') then
    R:SetFunkManOn(10042)
    env.info("FunkMan Started: 10042")
		return
	end
	env.info("Running Single Player, No Funkman")
	return
end
---------------------------------------------------------------------
-- Range Lifecycle
---------------------------------------------------------------------

local function DestroyRange(groupName)
  local range = TCS.RANGE.Ranges[groupName]
  if not range then return end

  if range.moose then
    range.moose:Stop()
  end

  if range.detectors then
    for _, detector in ipairs(range.detectors) do
      detector:Destroy()
    end
    range.detectors = nil
  end

  if range.drawings then
    for _, markId in ipairs(range.drawings) do
      trigger.action.removeMark(markId)
    end
  end

  DestroyStatics(range)
  DestroyMobiles(range)
  TCS.RANGE.Ranges[groupName] = nil

  env.info("[TCS.RANGE] Destroyed range owned by " .. groupName)
end

---------------------------------------------------------------------
-- MOOSE RANGE Setup (per range)
---------------------------------------------------------------------

function TCS.RANGE.CreateMooseRange(range, groupName)
  local r = RANGE:New("A2G_RANGE_" .. groupName)
  if not r then return end

  function r:OnAfterBombingResult(EventData)
    local unit = EventData.IniUnit
    local id = ResolveUCID(unit)
    
    -- Send to DCSServerBot
    local msg = {
      command   = "onMissionEvent",
      eventName = "S_EVENT_RANGE_BOMB",
      initiator = {
        ucid = id.ucid,
        name = id.name,
        unit = unit and unit:GetName() or "UNKNOWN"
      },
      range = {
        name     = "A2G_RANGE_" .. groupName,
        weapon   = EventData.WeaponName or "UNKNOWN",
        distance = EventData.Distance or -1, -- meters
        score    = EventData.Score or 0,
        target   = EventData.TgtName or (EventData.TgtUnit and EventData.TgtUnit:GetName()) or "Unknown Target",
        quality  = EventData.Quality or "MISS"
      },
      time = timer.getTime()
    }
    SendBotEvent(msg)
  end

  function r:OnAfterStrafeResult(EventData)
    local unit = EventData.IniUnit
    local id = ResolveUCID(unit)

    -- Send to DCSServerBot
    local msg = {
      command   = "onMissionEvent",
      eventName = "S_EVENT_RANGE_STRAFE",
      initiator = {
        ucid = id.ucid,
        name = id.name,
        unit = unit and unit:GetName() or "UNKNOWN"
      },
      range = {
        name     = "A2G_RANGE_" .. groupName,
        rounds   = EventData.RoundsFired or 0,
        hits     = EventData.RoundsHit or 0,
        score    = EventData.Score or 0,
        target   = EventData.TgtName or "Strafe Target"
      },
      time = timer.getTime()
    }
    SendBotEvent(msg)
  end

  -- if lfs then
  --   _G.PATH.TRACKING = lfs.writedir() .. [[Tracking]]
  --   -- r:Load(_G.PATH.TRACKING)
  --   r:SetAutoSave(_G.PATH.TRACKING, "range_" .. groupName .. ".csv")
  -- end

  local commonCfg = TCS.A2G.Config and TCS.A2G.Config.RangeCommon or {}
  local freq = commonCfg.FREQUENCY or 252.000

  r:SetRangeControl(freq)
  r:TrackBombsON()
  r:TrackRocketsON()
  r:TrackMissilesON()
  r:SetDefaultPlayerSmokeBomb(commonCfg.SMOKE_ON_OFF ~= false)
  start_funkman(r)
  range.moose = r
  r:Start()
end

---------------------------------------------------------------------
-- Configuration Applicator
---------------------------------------------------------------------

local function ApplySingleConfig(range, center, heading, cfg, suffix)
  suffix = suffix or ""
  local hdgRad = math.rad(heading)
  local patternHdg = hdgRad + math.rad(cfg.pattern_rotation or 0)
  
  local coords = TCS.RANGE.BuildPattern(cfg.pattern, center, patternHdg, cfg)
  local spawnedNames = {}

  -- Activity: CONVOY (Moving)
  if cfg.activity == "CONVOY" then
    local rawType = cfg.target_pool[math.random(#cfg.target_pool)]
    local entry = ResolveCatalogEntry({id=rawType})
    
    local uType = rawType
    local cat = Group.Category.GROUND -- Default to ground
    
    if entry then
      if entry.unit_types then uType = entry.unit_types[1] end
      if entry.domain == "SEA" then 
        cat = Group.Category.SHIP 
      end
    end

    -- Create route perpendicular to heading (crossing the range)
    -- We use the center point to define a crossing path
    local startPt = center:Translate(1500, heading - 90)
    local endPt   = center:Translate(1500, heading + 90)
    
    local units = {}
    for i, pos in ipairs(coords) do
      -- For convoy, we use the pattern to define relative formation positions
      -- But here we simplify to a column based on the start point for movement
      -- Re-calculating column positions based on startPt for the route
      local dist = (i-1) * (cfg.spacing_m or 50)
      local uPos = startPt:Translate(dist, heading - 90) -- Trailing behind start
      
      table.insert(units, {
        name = range.id .. "_" .. suffix .. "_MOV_" .. i,
        type = uType,
        x = uPos.x,
        y = uPos.z,
        heading = math.rad(heading + 90),
        skill = "High"
      })
    end

    local route = {
      points = {
        [1] = { x = startPt.x, y = startPt.z, action = "Off Road", speed = 11, type = "Turning Point" },
        [2] = { x = endPt.x, y = endPt.z, action = "Off Road", speed = 11, type = "Turning Point" }
      }
    }
    
    local gData = {
      name = range.id .. "_" .. suffix .. "_GRP",
      task = "Ground Nothing",
      route = route,
      units = units
    }
    
    local group = TCS.Spawn.GroupFromData(gData, cat, range.enemyCoalition)
    if group then
      table.insert(range.mobiles, group)
    end

  -- Activity: Default (non-moving) or POPUP
  else
    for i, pos in ipairs(coords) do
      local rawType = cfg.target_pool[math.random(#cfg.target_pool)]
      local entry = ResolveCatalogEntry({id=rawType})
      local finalType = rawType
      local cat = Group.Category.GROUND
      
      if entry then
        if entry.unit_types then finalType = entry.unit_types[1] end
        if entry.domain == "SEA" then cat = Group.Category.SHIP end
      end

      local sName = range.id .. "_" .. suffix .. "_" .. i
      
      if cfg.activity == "POPUP" then
         -- Spawn as mobile group for popup logic (simplified here as static group for now)
         local groupName = sName .. "_GRP"
         local gData = {
           name = groupName,
           task = "Ground Defence",
           units = {{ name = sName, type = finalType, x = pos.x, y = pos.z, heading = hdgRad, skill = "High" }},
           route = {
             points = {
               [1] = {
                 x = pos.x,
                 y = pos.z,
                 action = "Off Road",
                 type = "Turning Point",
                 speed = 0
               }
             }
           }
         }
         
         local group = TCS.Spawn.GroupFromData(gData, cat, range.enemyCoalition)
         if group then
           table.insert(range.mobiles, group)
         end

         -- Post-spawn logic to set ROE and detection
         SCHEDULER:New(nil, function()
             local group = GROUP:FindByName(groupName)
             if group and group:IsAlive() then
                 group:OptionROE(ENUMS.ROE.WeaponHold)

                 local detection = DETECTION_AREAS:New(group, 3000) -- 3km bubble
                 detection:SetHandler(function(detected_group)
                     if detected_group:IsPlayer() then
                         group:OptionROE(ENUMS.ROE.WeaponFree)
                         MESSAGE:New("HOSTILE! Threat is engaging!", 10):ToAll()
                         detection:Destroy()
                     end
                 end):Start()
                 range.detectors = range.detectors or {}
                 table.insert(range.detectors, detection)
             end
         end, {}, 1)
      else
         local sData = {
           category = TCS.Spawn.GetStaticCategory(finalType),
           type = finalType,
           name = sName,
           x = pos.x,
           y = pos.z,
           heading = hdgRad
         }
         local obj = TCS.Spawn.StaticFromData(sData, range.enemyCoalition)
         if obj then table.insert(range.statics, obj) end
         
         table.insert(spawnedNames, sName)
      end
    end

    -- Register targets with MOOSE Range for scoring
    if range.moose and #spawnedNames > 0 then
      if cfg.purpose == "BOMB" or cfg.purpose == "MIXED" then
        range.moose:AddBombingTargets(spawnedNames)
      end
      if cfg.purpose == "STRAFE" or cfg.purpose == "MIXED" then
        for _, n in ipairs(spawnedNames) do
          range.moose:AddStrafePit(n, cfg.strafe_length or 300, 300)
        end
      end
    end
  end
end

function TCS.RANGE.ApplyConfiguration(range, center, heading, configKey)
  local cfg = TCS.RANGE_CONFIG and TCS.RANGE_CONFIG[configKey]
  
  if not cfg then
    env.warning("TCS.RANGE: Unknown configuration '" .. tostring(configKey) .. "'")
    return
  end

  local batchId = math.random(10000, 99999)

  if cfg.complex and cfg.components then
    for i, sub in ipairs(cfg.components) do
      local subCenter = center
      if sub.offset then
        -- Apply offset relative to heading
        local ox = sub.offset.x or 0 -- Forward
        local oz = sub.offset.z or 0 -- Right
        local rad = math.rad(heading)
        local dx = ox * math.cos(rad) - oz * math.sin(rad)
        local dz = ox * math.sin(rad) + oz * math.cos(rad)
        subCenter = { x = center.x + dx, z = center.z + dz }
        -- Add helper methods if center is not a MOOSE coord
        function subCenter:Translate(d, h) 
           local r = math.rad(h)
           return { x = self.x + d * math.cos(r), z = self.z + d * math.sin(r) } 
        end
      end
      ApplySingleConfig(range, subCenter, heading, sub, configKey .. "_" .. batchId .. "_" .. i)
    end
  else
    ApplySingleConfig(range, center, heading, cfg, configKey .. "_" .. batchId)
  end
end

--- Generic Range Spawner (TCS Native)
-- @param name (string) Unique ID for the range
-- @param owner (string) Owner name (Group name or "SYSTEM")
-- @param vec3 (table) {x, y, z} center point
-- @param heading (number) Heading in degrees
-- @param configKey (string) Configuration key
function TCS.RANGE.Spawn(name, owner, vec3, heading, configKey)
  if TCS.RANGE.Ranges[name] then
    env.warning("TCS.RANGE: Range " .. name .. " already exists.")
    return
  end

  local range = {
    id      = name,
    owner   = owner,
    statics = {},
    mobiles = {},
    moose   = nil,
    detectors = {},
    drawings = {},
    enemyCoalition = coalition.side.RED, -- Default, could be param
    centerVec3 = vec3,
    heading = heading
  }

  TCS.RANGE.Ranges[name] = range
  TCS.RANGE.CreateMooseRange(range, name)

  -- Draw on F10 Map
  local markIdCircle = math.random(100000, 999999)
  local markIdText = math.random(100000, 999999)
  
  -- Draw a 1.5 NM (approx 2800m) circle
  trigger.action.circleToAll(-1, markIdCircle, vec3, 2800, {1, 0, 0, 1}, {1, 0, 0, 0.15}, 1, true)
  table.insert(range.drawings, markIdCircle)

  -- Draw Label
  trigger.action.textToAll(-1, markIdText, vec3, {1, 1, 1, 1}, {0, 0, 0, 0.5}, 11, "RANGE: " .. configKey, true)
  table.insert(range.drawings, markIdText)

  local center = COORDINATE:NewFromVec3(vec3)
  TCS.RANGE.ApplyConfiguration(range, center, heading, configKey)
end

---------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------

function TCS.RANGE.Create(groupName, unitName, configKey)
  local group = GROUP:FindByName(groupName)
  local unit  = UNIT:FindByName(unitName)
  if not group or not unit then return end

  -- Ownership check
  local existingRange = TCS.RANGE.Ranges[groupName]
  if existingRange then
    local center = COORDINATE:NewFromVec3(existingRange.centerVec3)
    TCS.RANGE.ApplyConfiguration(existingRange, center, existingRange.heading, configKey)
    trigger.action.smoke(existingRange.centerVec3, trigger.smokeColor.Green)
    if group and TCS.A2G.JTAC and TCS.A2G.JTAC.PushWaypoint then
      TCS.A2G.JTAC.PushWaypoint(group, center, "RANGE")
    end
    MESSAGE:New("Range extended with " .. configKey, 10):ToGroup(group)
    return
  end

  -- Determine domain based on player location
  local domain = "LAND"
  local p = unit:GetVec3()
  if p and land.getSurfaceType({x=p.x, y=p.z}) == land.SurfaceType.WATER then
    domain = "SEA"
  end

  local anchor, dist = TCS.Placement.Resolve(unit, domain)
  if not anchor then
    MESSAGE:New("No suitable range location found.", 8):ToGroup(group)
    return
  end

  -- Delegate to generic spawner
  TCS.RANGE.Spawn(groupName, groupName, anchor:GetVec3(), unit:GetHeading(), configKey)

  if group and TCS.A2G.JTAC and TCS.A2G.JTAC.PushWaypoint then
    TCS.A2G.JTAC.PushWaypoint(group, anchor, "RANGE")
  end

  local msg = string.format("RANGE BUILT %d NM AHEAD (%s)", dist, configKey)
  
  -- Notify Session or Group
  local session = TCS.SessionManager:GetSessionForGroup(group)
  if session then
    session:Broadcast(msg, 10)
  else
    MESSAGE:New(msg, 10):ToGroup(group)
  end
end

function TCS.RANGE.Reset(groupName)
  DestroyRange(groupName)
end

---------------------------------------------------------------------
-- Owner death / despawn cleanup
---------------------------------------------------------------------

TCS.RANGE.Handler = EVENTHANDLER:New()

TCS.RANGE.Handler:HandleEvent(EVENTS.Dead)
TCS.RANGE.Handler:HandleEvent(EVENTS.Crash)
TCS.RANGE.Handler:HandleEvent(EVENTS.Ejection)
TCS.RANGE.Handler:HandleEvent(EVENTS.PlayerLeaveUnit)

function TCS.RANGE.Handler:OnEvent(event)
  if not event.IniGroup then return end
  local groupName = event.IniGroup:GetName()

  if TCS.RANGE.Ranges[groupName] then
    DestroyRange(groupName)
  end
end

-- Namespace Alias
TCS.A2G = TCS.A2G or {}
TCS.A2G.Range = TCS.RANGE
