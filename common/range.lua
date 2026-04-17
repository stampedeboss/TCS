---------------------------------------------------------------------
-- common/range.lua
-- Handles dynamic creation of A2G training ranges.
---------------------------------------------------------------------
env.info("TCS(RANGE): loading")

TCS.RANGE = {}
TCS.RANGE.Ranges = {} -- Keyed by group name

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
function TCS.RANGE:Reset(rec)
  if not rec or not rec.Group then return end
  local groupName = rec.Group:GetName()

  local range = self.Ranges[groupName]
  if not range then return end

  -- 1. Stop MOOSE range tracking
  if range.mooseRange and range.mooseRange.Stop then
    pcall(function() range.mooseRange:Stop() end)
  end

  -- 2. Destroy all spawned objects
  for _, obj in ipairs(range.objects or {}) do
    if obj and obj.isExist and obj:isExist() then
      obj:destroy()
    end
  end

  self.Ranges[groupName] = nil
end

local function _createPatternRange(group, unit, rangeKey, spawnedRange, params)
  local playerPos = unit and unit:GetCoordinate()
  local centerPos = nil
  local playerHdg = 0
  local spawnMsg = ""

  local anchor = params and params.anchor
  if anchor then
    if type(anchor) == "string" then
      local z = ZONE:FindByName(anchor)
      centerPos = z and z:GetVec2()
    elseif anchor.GetVec2 then
      centerPos = anchor:GetVec2()
    else
      centerPos = { x = anchor.x, y = anchor.z or anchor.y }
    end
    if playerPos then
      playerHdg = COORDINATE:New(centerPos.x, 0, centerPos.y):HeadingTo(playerPos) + math.pi
    end
    spawnMsg = "Training range established at " .. tostring(anchor) .. "."
  else
    local cfg = TCS.Config.A2G.TrainingRange or {}
    local zoneName = (cfg and cfg.GENERIC_SPAWN_ZONE_NAME) or nil
    local spawnZone = zoneName and ZONE:FindByName(zoneName)
    if spawnZone then
      local centerVec2 = spawnZone:GetRandomVec2()
      centerPos = { x = centerVec2.x, y = centerVec2.y }
      playerHdg = COORDINATE:New(centerPos.x, 0, centerPos.y):HeadingTo(playerPos) + math.pi
      spawnMsg = "Range created in " .. zoneName .. "."
    else
      local default_spawn_dist_nm = (TCS.Config.A2G.TrainingRange and TCS.Config.A2G.TrainingRange.SPAWN_DISTANCE_NM) or 15
      local SPAWN_DISTANCE_M = default_spawn_dist_nm * 1852
      playerHdg = unit:GetHeading()

      -- FIX: Use the solver instead of raw math to avoid water/urban areas
      local solved = TCS.Placements.SolveCoordinate({
          anchor = playerPos, 
          minNm = default_spawn_dist_nm, 
          maxNm = default_spawn_dist_nm + 1, 
          ingressHdg = math.deg(playerHdg), 
          ingressArc = 20
      })
      if solved then
          centerPos = { x = solved.x, y = solved.z }
          spawnMsg = "Range created " .. default_spawn_dist_nm .. " NM ahead."
      else
          MESSAGE:New("Could not find suitable terrain for range spawn.", 10):ToGroup(group:GetName())
          return
      end
    end
  end

  -- Use the Training Tower to get the recipe
  local recipe = centerPos and TCS.Towers.Training.GetRecipe(rangeKey, COORDINATE:New(centerPos.x, 0, centerPos.y), playerHdg)
  if not recipe then
    env.error("TCS(RANGE): Could not generate recipe for " .. tostring(rangeKey))
    return
  end

  local coords = recipe.coords
  local spawnedNames = {}

  -- Resolve AI behavior based on Tier
  local difficulty = (params and params.skill) or "G"
  local aiSkill = "High"
  local aiMaxDist = 80000
  local aiROE = 0
  local aiReaction = 2

  if difficulty == "A" then
    aiSkill = "Average"; aiMaxDist = 45000; aiROE = 1; aiReaction = 1
  elseif difficulty == "G" then
    aiSkill = "Good"; aiMaxDist = 65000; aiROE = 0; aiReaction = 2
  elseif difficulty == "H" then
    aiSkill = "High"; aiMaxDist = 90000; aiROE = 0; aiReaction = 2
  elseif difficulty == "X" then
    aiSkill = "Excellent"; aiMaxDist = 150000; aiROE = 0; aiReaction = 3
  end

  if recipe.activity == "CONVOY" or recipe.activity == "POPUP" then
    -- For mobile or active threats, spawn as groups
    for i, pos in ipairs(coords) do
      -- Skip if specific point is invalid (Water/Town/Slope)
      if not TCS.Placements.IsTerrainAppropriate({x = pos.x, y = pos.z}, "LAND") then
          env.info("TCS(RANGE): Skipping target point " .. i .. " due to terrain.")
          goto next_coord_group
      end
      local targetId = recipe.targetPool[math.random(#recipe.targetPool)]
      local catalogEntry = TCS.Catalog.FindById(targetId)
      if catalogEntry then
        local nameBase = group and group:GetName() or "SYS"
        local groupName = string.format("RNG-%s-%s_U%d", rangeKey, nameBase, i)
        local uName = groupName .. "_U1"
        local groupData = {
          name = groupName,
          units = {{ name = uName, type = catalogEntry.unit_types[1], x = pos.x, y = pos.z, heading = playerHdg + math.pi, skill = aiSkill }}
        }
        
        local newGroup = coalition.addGroup(coalition.side.RED, Group.Category.GROUND, groupData)
        local mooseGroup = GROUP:FindByName(groupName)
        if mooseGroup then
          table.insert(spawnedRange.objects, mooseGroup)
          if spawnedRange.mooseRange then
            spawnedRange.mooseRange:AddBombingTargets({uName})
          end
          -- Special handling for POPUP activity
          if recipe.activity == "POPUP" and group then
            mooseGroup:InitROE(AI.ROE.WEAPON_HOLD)
            local zone = ZONE_RADIUS:New(group:GetName() .. "_POPUP_ZONE_" .. i, group:GetVec3(), 10000)
            local fsm = FSM:New(mooseGroup)
            fsm:OnEnterGroupInZone(zone, function() mooseGroup:InitROE(AI.ROE.WEAPON_FREE); MESSAGE:New("Threats are active!", 10):ToGroup(group:GetName()) end, function() mooseGroup:InitROE(AI.ROE.WEAPON_HOLD) end)
          end
        end
      end
      ::next_coord_group::
    end
  else
    -- For static targets (BOMB, STRAFE, MIXED), spawn as individual static objects for scoring
    for i, pos in ipairs(coords) do
      -- Skip if specific point is invalid
      if not TCS.Placements.IsTerrainAppropriate({x = pos.x, y = pos.z}, "LAND") then
          env.info("TCS(RANGE): Skipping static target point " .. i .. " due to terrain.")
          goto next_coord_static
      end
      local targetId = recipe.targetPool[math.random(#recipe.targetPool)]
      local catalogEntry = TCS.Catalog.FindById(targetId)
      if catalogEntry then
        local nameBase = group and group:GetName() or "SYS"
        local sName = string.format("RNG-%s-%s_U%d", rangeKey, nameBase, i)
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
      ::next_coord_static::
    end

    -- Register static targets with MOOSE for scoring
    if spawnedRange.mooseRange and #spawnedNames > 0 then
      if recipe.purpose == "BOMB" or recipe.purpose == "MIXED" then
        spawnedRange.mooseRange:AddBombingTargets(spawnedNames)
      end
      if recipe.purpose == "STRAFE" or recipe.purpose == "MIXED" then
        for _, n in ipairs(spawnedNames) do
          spawnedRange.mooseRange:AddStrafePit(n, 300, 300)
        end
      end
    end
  end

  if group then MESSAGE:New(spawnMsg, 15):ToGroup(group:GetName()) end
end

function TCS.RANGE:Start(rec, configKey, params)
  local group = rec.Group
  local unit = rec.Unit

  if not params.anchor and not (group and unit and group:IsAlive() and unit:IsAlive()) then
    env.error("TCS(RANGE): No anchor or player group provided for range spawn.")
    return
  end

  -- Clean up any previous range created by this group
  if group then self:Reset(rec) end

  -- Create a new range object to hold state
  local spawnedRange = {
    objects = {},
    mooseRange = _createMooseRange(group and group:GetName() or "SYSTEM")
  }
  if group then self.Ranges[group:GetName()] = spawnedRange end

  local session = rec.Session
  local difficulty = (params and params.skill) or (session and session.Difficulty) or "G"

  _createPatternRange(group, unit, configKey, spawnedRange, params)

  local taskHandle = {
    SpawnedObjects = spawnedRange.objects,
    StartTime = timer.getTime(),
    Duration = 7200, -- 2 hour default lifetime
  }

  function taskHandle:IsOver()
    if timer.getTime() > (self.StartTime + self.Duration) then return true, "TIMEOUT" end
    
    -- The range is "complete" when all its objects are destroyed.
    for _, obj in ipairs(self.SpawnedObjects or {}) do
      if obj and obj.isExist and obj:isExist() then return false end -- At least one object is still alive
    end
    return true, "COMPLETE" -- All objects are gone
  end

  return taskHandle
end

env.info("TCS(RANGE): ready")