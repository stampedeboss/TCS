---------------------------------------------------------------------
-- core/tcs_range.lua
-- Handles dynamic creation of A2G training ranges.
---------------------------------------------------------------------
env.info("TCS(RANGE): loading")

TCS.RANGE = {}
TCS.RANGE.Ranges = {} -- Keyed by group name

-- Merged from tcs_a2g_range_patterns.lua for self-containment
function TCS.RANGE.BuildPattern(pattern, center, hdgRad, cfg)
  local pts = {}
  local spacing = cfg.spacing_m or 25
  local cx = center.x
  local cz = center.z -- MOOSE coord .z is Map Y

  if pattern == "ROW" then
    local half = (cfg.count - 1) / 2
    for i = 1, cfg.count do
      local dist = (i - 1 - half) * spacing
      table.insert(pts, {
        x = cx + dist * math.cos(hdgRad),
        z = cz + dist * math.sin(hdgRad)
      })
    end
  elseif pattern == "STAR" then
    local count = cfg.count or 5
    local angleStep = (2 * math.pi) / count
    for i = 1, count do
      local a = angleStep * i + hdgRad
      table.insert(pts, { x = cx + math.cos(a) * spacing, z = cz + math.sin(a) * spacing })
    end
  elseif pattern == "GRID" then
    local rows = cfg.rows or 3; local cols = cfg.columns or 3
    local offX = (cols - 1) * spacing / 2; local offZ = (rows - 1) * spacing / 2
    for r = 1, rows do
      for c = 1, cols do
        local dx = (c - 1) * spacing - offX; local dz = (r - 1) * spacing - offZ
        local rx = dx * math.cos(hdgRad) - dz * math.sin(hdgRad)
        local rz = dx * math.sin(hdgRad) + dz * math.cos(hdgRad)
        table.insert(pts, { x = cx + rx, z = cz + rz })
      end
    end
  elseif pattern == "RANDOM" then
    local count = cfg.count or 10; local radius = cfg.radius or (spacing * 5)
    for i = 1, count do
      local r = math.sqrt(math.random()) * radius; local a = math.random() * 2 * math.pi
      table.insert(pts, { x = cx + math.cos(a) * r, z = cz + math.sin(a) * r })
    end
  end
  return pts
end

local function _createMooseRange(groupName)
  local r = RANGE:New("A2G_RANGE_" .. groupName)
  if not r then return nil end

  -- Handlers for scoring would go here if you use dcs-bot or other logging
  -- function r:OnAfterBombingResult(EventData) ... end
  -- function r:OnAfterStrafeResult(EventData) ... end

  local commonCfg = TCS.Config.A2G.RangeCommon or {}
  r:SetRangeControl(commonCfg.FREQUENCY or 252.000)
  r:TrackBombsON()
  r:TrackRocketsON()
  r:TrackMissilesON()
  r:SetDefaultPlayerSmokeBomb(commonCfg.SMOKE_ON_OFF ~= false)
  r:Start()
  return r
end

--- Cleans up a previously spawned range for a group.
-- @param groupName The name of the group that spawned the range.
function TCS.RANGE.Reset(groupName)
  local range = TCS.RANGE.Ranges[groupName]
  if not range then return end

  if range.mooseRange and range.mooseRange.Stop then
    -- The MOOSE RANGE object might be in a bad state if creation failed.
    -- Wrap the Stop() call in pcall to prevent script errors during cleanup.
    local ok, err = pcall(function() range.mooseRange:Stop() end)
    if not ok then env.error("TCS(RANGE): Error stopping mooseRange during reset: " .. tostring(err)) end
  end

  for _, obj in ipairs(range.objects or {}) do
    if obj and obj.isExist and obj:isExist() then obj:destroy() end
  end
  MESSAGE:New("Range reset.", 10):ToGroup(groupName)
  TCS.RANGE.Ranges[groupName] = nil
end

--- Spawns a complex, composition-based SAM site.
-- @param group The MOOSE group object of the spawner.
-- @param unit The MOOSE unit object of the spawner.
-- @param samKey The key of the SAM from TCS.Config.A2G.SAMS.
-- @param difficulty The session difficulty tier ('A', 'G', 'H', 'X').
local function _createDynamicSAM(group, unit, samKey, difficulty, spawnedRange)
  local samDef = TCS.Config.A2G.SAMS[samKey]
  if not samDef then
    MESSAGE:New("Error: SAM definition '" .. samKey .. "' not found.", 10):ToGroup(group:GetName())
    return
  end

  -- Calculate spawn distance based on SAM range + buffer
  local cfg = TCS.Config.A2G.TrainingRange or {}
  local buffer_nm = cfg.SPAWN_BUFFER_NM or 50
  local fallback_nm = cfg.SPAWN_DISTANCE_NM or 15
  
  local spawn_dist_nm = fallback_nm
  if samDef.max_range_nm then
    spawn_dist_nm = samDef.max_range_nm + buffer_nm
  end
  local spawn_dist_m = spawn_dist_nm * 1852

  local composition = nil
  if samDef.compositions then
    composition = samDef.compositions[difficulty]
    -- Fallback chain if specific difficulty is not defined
    if not composition then composition = samDef.compositions["G"] end
    if not composition then composition = samDef.compositions["A"] end
    if not composition then composition = samDef.compositions["H"] end
    if not composition then composition = samDef.compositions["X"] end
  end
  if not composition then composition = samDef.composition end -- Legacy fallback

  if not composition then
    MESSAGE:New("Error: No valid composition found for SAM '" .. samKey .. "' at difficulty '" .. difficulty .. "'.", 10):ToGroup(group:GetName())
    return
  end

  local playerPos = unit:GetCoordinate()
  local siteHdg = nil
  local centerPos = nil
  local spawnMsg = ""

  -- Check for a designated spawn zone
  local zoneName = (cfg and cfg.SAM_SPAWN_ZONE_NAME) or nil
  local spawnZone = zoneName and ZONE:FindByName(zoneName)

  if spawnZone then
    -- Spawn inside the designated zone
    local centerVec2 = spawnZone:GetRandomVec2()
    centerPos = { x = centerVec2.x, y = centerVec2.y }
    -- Site faces towards the player
    siteHdg = COORDINATE:New(centerPos.x, 0, centerPos.y):HeadingTo(playerPos) + math.pi
    spawnMsg = samDef.label .. " site created in " .. zoneName .. "."
  else
    -- Fallback to relative spawning
    local playerHdg = unit:GetHeading() -- Radians
    -- Spawn at a random bearing +/- 45 degrees from player's course
    local bearing_offset_rad = math.rad(math.random() * 90 - 45)
    local spawn_bearing_rad = playerHdg + bearing_offset_rad

    -- Site faces towards the player's spawn-time location
    siteHdg = spawn_bearing_rad + math.pi
    centerPos = {
      x = playerPos.x + math.sin(spawn_bearing_rad) * spawn_dist_m,
      y = playerPos.z + math.cos(spawn_bearing_rad) * spawn_dist_m
    }
    spawnMsg = samDef.label .. " site created " .. math.floor(spawn_dist_nm) .. " NM ahead."
  end
  
  local groupData = {
    name = string.format("SAM-%s-%s", samKey, group:GetName()),
    units = {},
    route = {
        points = {
            [1] = {
                x = centerPos.x,
                y = centerPos.y,
                type = "Turning Point",
                action = "Off Road",
                speed = 0,
                task = {
                    id = "ComboTask",
                    params = {
                        tasks = {
                            {
                                id = "EngageTargets",
                                params = {
                                    targetTypes = {"Air"},
                                    maxDist = 80000, -- 80km engagement radius
                                }
                            }
                        }
                    }
                }
            }
        }
    }
  }

  local targetNames = {}
  -- Build the unit list from the composition
  if not TCS.Catalog or not TCS.Catalog.FindById then
    MESSAGE:New("Error: TCS Catalog module not loaded. Cannot create SAM site.", 10):ToGroup(group:GetName())
    return
  end

  for i, compUnit in ipairs(composition) do
    local catalogEntry = TCS.Catalog:FindById(compUnit.id)
    if catalogEntry then
      -- Calculate rotated offset from site center
      local offsetX = compUnit.x * math.cos(siteHdg) - compUnit.y * math.sin(siteHdg)
      local offsetY = compUnit.x * math.sin(siteHdg) + compUnit.y * math.cos(siteHdg)

      local uName = string.format("%s_U%d", groupData.name, i)
      table.insert(groupData.units, {
        name = uName,
        type = catalogEntry.unit_types[1],
        x = centerPos.x + offsetX,
        y = centerPos.y + offsetY,
        heading = siteHdg + math.rad(compUnit.hdg or 0),
        skill = "High"
      })
      table.insert(targetNames, uName)
    else
      env.warn("TCS(RANGE): Could not find unit with id '" .. compUnit.id .. "' in catalog for SAM site '" .. samKey .. "'")
    end
  end

  if #groupData.units == 0 then
    MESSAGE:New("Error: Could not create SAM site, no valid units found.", 10):ToGroup(group:GetName())
    return
  end

  -- Spawn and register the group
  local newGroup = coalition.addGroup(coalition.side.RED, Group.Category.GROUND, groupData)
  local mooseGroup = GROUP:FindByName(newGroup.name)
  if mooseGroup then 
    table.insert(spawnedRange.objects, mooseGroup)
    if spawnedRange.mooseRange then
      spawnedRange.mooseRange:AddBombingTargets(targetNames)
    end
  end
  MESSAGE:New(spawnMsg, 15):ToGroup(group:GetName())
end

--- Spawns a simple, pattern-based range (handles POPUP, SAM_CIRCLE, etc.)
-- @param group The MOOSE group object of the spawner.
-- @param unit The MOOSE unit object of the spawner.
-- @param rangeKey The key from TCS.Config.A2G.Range.
local function _createPatternRange(group, unit, rangeKey, spawnedRange)
  local rangeDef = TCS.Config.A2G.Range[rangeKey]
  if not rangeDef then
    MESSAGE:New("Error: Range definition '" .. rangeKey .. "' not found.", 10):ToGroup(group:GetName())
    return
  end

  local playerPos = unit:GetCoordinate()
  local playerHdg = nil
  local centerPos = nil
  local spawnMsg = ""

  -- Check for a designated spawn zone
  local cfg = TCS.Config.A2G.TrainingRange or {}
  local zoneName = (cfg and cfg.GENERIC_SPAWN_ZONE_NAME) or nil
  local spawnZone = zoneName and ZONE:FindByName(zoneName)

  if spawnZone then
    -- Spawn inside the designated zone
    local centerVec2 = spawnZone:GetRandomVec2()
    centerPos = { x = centerVec2.x, y = centerVec2.y }
    -- Range faces towards the player
    playerHdg = COORDINATE:New(centerPos.x, 0, centerPos.y):HeadingTo(playerPos) + math.pi
    spawnMsg = "Range created in " .. zoneName .. "."
  else
    -- Fallback to relative spawning
    local default_spawn_dist_nm = (TCS.Config.A2G.TrainingRange and TCS.Config.A2G.TrainingRange.SPAWN_DISTANCE_NM) or 15
    local SPAWN_DISTANCE_M = default_spawn_dist_nm * 1852
    playerHdg = unit:GetHeading()
    centerPos = {
      x = playerPos.x + math.sin(playerHdg) * SPAWN_DISTANCE_M,
      y = playerPos.z + math.cos(playerHdg) * SPAWN_DISTANCE_M
    }
    spawnMsg = "Range created " .. default_spawn_dist_nm .. " NM ahead."
  end

  local pattern = rangeDef.pattern or "RANDOM"
  local coords = TCS.RANGE.BuildPattern(pattern, COORDINATE:New(centerPos.x, 0, centerPos.y), playerHdg, rangeDef)
  local spawnedNames = {}

  if rangeDef.activity == "CONVOY" or rangeDef.activity == "POPUP" or rangeDef.purpose == "SEAD" then
    -- For mobile or active threats, spawn as groups
    for i, pos in ipairs(coords) do
      local targetId = rangeDef.target_pool[math.random(#rangeDef.target_pool)]
      local catalogEntry = TCS.Catalog:FindById(targetId)
      if catalogEntry then
        local groupName = string.format("RNG-%s-%s_U%d", rangeKey, group:GetName(), i)
        local uName = groupName .. "_U1"
        local groupData = {
          name = groupName,
          units = {{ name = uName, type = catalogEntry.unit_type, x = pos.x, y = pos.z, heading = playerHdg + math.pi, skill = "High" }}
        }
        
        -- Add engage task for SEAD targets
        if rangeDef.purpose == "SEAD" then
          groupData.route = { points = { [1] = { x = pos.x, y = pos.z, type = "Turning Point", action = "Off Road", speed = 0, task = { id = "ComboTask", params = { tasks = { { id = "EngageTargets", params = { targetTypes = {"Air"}, maxDist = 80000 } } } } } } } }
        end

        local newGroup = coalition.addGroup(coalition.side.RED, Group.Category.GROUND, groupData)
        local mooseGroup = GROUP:FindByName(groupName)
        if mooseGroup then
          table.insert(spawnedRange.objects, mooseGroup)
          if spawnedRange.mooseRange then
            spawnedRange.mooseRange:AddBombingTargets({uName})
          end
          -- Special handling for POPUP activity
          if rangeDef.activity == "POPUP" then
            mooseGroup:InitROE(AI.ROE.WEAPON_HOLD)
            local zone = ZONE_RADIUS:New(group:GetName() .. "_POPUP_ZONE_" .. i, group:GetVec3(), 10000)
            local fsm = FSM:New(mooseGroup)
            fsm:OnEnterGroupInZone(zone, function() mooseGroup:InitROE(AI.ROE.WEAPON_FREE); MESSAGE:New("Threats are active!", 10):ToGroup(group:GetName()) end, function() mooseGroup:InitROE(AI.ROE.WEAPON_HOLD) end)
          end
        end
      end
    end
  else
    -- For static targets (BOMB, STRAFE, MIXED), spawn as individual static objects for scoring
    for i, pos in ipairs(coords) do
      local targetId = rangeDef.target_pool[math.random(#rangeDef.target_pool)]
      local catalogEntry = TCS.Catalog:FindById(targetId)
      if catalogEntry then
        local sName = string.format("RNG-%s-%s_U%d", rangeKey, group:GetName(), i)
        local sData = {
          category = TCS.Spawn.GetStaticCategory(catalogEntry.unit_type),
          type = catalogEntry.unit_type,
          name = sName,
          x = pos.x,
          y = pos.z,
          heading = playerHdg + math.pi
        }
        local obj = TCS.Spawn.StaticFromData(sData, coalition.side.RED)
        if obj then
          table.insert(spawnedRange.objects, obj)
          table.insert(spawnedNames, sName)
        end
      end
    end

    -- Register static targets with MOOSE for scoring
    if spawnedRange.mooseRange and #spawnedNames > 0 then
      if rangeDef.purpose == "BOMB" or rangeDef.purpose == "MIXED" then
        spawnedRange.mooseRange:AddBombingTargets(spawnedNames)
      end
      if rangeDef.purpose == "STRAFE" or rangeDef.purpose == "MIXED" then
        for _, n in ipairs(spawnedNames) do
          spawnedRange.mooseRange:AddStrafePit(n, 300, 300)
        end
      end
    end
  end

  MESSAGE:New(spawnMsg, 15):ToGroup(group:GetName())
end

--- Main entry point called by the training menu.
-- @param groupName The name of the group that spawned the range.
-- @param unitName The name of the unit that spawned the range.
-- @param configKey The key identifying the range to create.
function TCS.RANGE.Create(groupName, unitName, configKey)
  local group = GROUP:FindByName(groupName)
  local unit = UNIT:FindByName(unitName)

  if not (group and unit and group:IsAlive() and unit:IsAlive()) then
    env.error("TCS(RANGE): Could not find spawner group/unit: " .. tostring(groupName))
    return
  end

  -- Clean up any previous range created by this group
  TCS.RANGE.Reset(groupName)

  -- Create a new range object to hold state
  local spawnedRange = {
    objects = {},
    mooseRange = _createMooseRange(groupName)
  }
  TCS.RANGE.Ranges[groupName] = spawnedRange

  local session = TCS.SessionManager:GetOrCreateSessionForGroup(group)
  local difficulty = (session and session.Difficulty) or "G" -- Default to Standard

  -- Check if it's a complex dynamic SAM site
  local samKey = string.match(configKey, "^SAM_SITE:(.+)")
  if samKey then
    _createDynamicSAM(group, unit, samKey, difficulty, spawnedRange)
  else
    -- Otherwise, assume it's a simple pattern-based range
    _createPatternRange(group, unit, configKey, spawnedRange)
  end
end

env.info("TCS(RANGE): ready")