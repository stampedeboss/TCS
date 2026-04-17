---------------------------------------------------------------------
-- core/dsam.lua
-- Handles doctrinal, complex SAM sites with directional spawning.
---------------------------------------------------------------------
env.info("TCS(DSAM): loading")

TCS = TCS or {}
TCS.DSAM = {}
TCS.DSAM.Sites = {}

--- Resolves AI behavior parameters based on Tier.
local function _resolveAIParams(difficulty)
  local ai = { skill = "High", maxDist = 80000, roe = 0, reaction = 2 }

  if difficulty == "A" then
    ai.skill = "Average"; ai.maxDist = 45000; ai.roe = 1; ai.reaction = 1
  elseif difficulty == "G" then
    ai.skill = "Good"; ai.maxDist = 65000; ai.roe = 0; ai.reaction = 2
  elseif difficulty == "H" then
    ai.skill = "High"; ai.maxDist = 90000; ai.roe = 0; ai.reaction = 2
  elseif difficulty == "X" then
    ai.skill = "Excellent"; ai.maxDist = 150000; ai.roe = 0; ai.reaction = 3
  end
  return ai
end

function TCS.DSAM:Start(rec, samKey, params)
  local group = rec.Group
  local unit = rec.Unit
  local session = rec.Session
  local difficulty = (params and params.skill) or (session and session.Difficulty) or "G"

  local samDef = TCS.Config.A2G.SAMS[samKey]
  if not samDef then
    MESSAGE:New("Error: SAM definition '" .. samKey .. "' not found.", 10):ToGroup(group:GetName())
    return nil
  end

  -- 1. Resolve Position and Orientation
  local playerPos = unit:GetCoordinate()
  local siteHdg = nil
  local centerPos = nil
  local spawnMsg = ""
  local anchor = params and params.anchor

  if anchor then
    if TCS.Scenario and TCS.Scenario.CalculateSpawnPoint then
      local coal = params.coalition or coalition.side.RED
      local minNm = params.minSpawnDistNm or (samDef.max_range_nm or 15)
      local maxNm = params.maxSpawnDistNm or (minNm + 5)
      local spawnCoord, spawnHdg = TCS.Scenario.CalculateSpawnPoint(anchor, coal, minNm, maxNm, params.ingressHdg, params.ingressArc)
      centerPos = { x = spawnCoord.x, y = spawnCoord.z }
      siteHdg = math.rad(spawnHdg)
    else
      centerPos = { x = anchor.x, y = anchor.z }
      siteHdg = anchor:HeadingTo(playerPos) + math.pi
    end
    spawnMsg = string.format("%s site established near %s.", samDef.label, tostring(params.anchor))
  else
    -- Legacy/Relative Spawn
    local playerHdg = unit:GetHeading()
    local spawn_dist_m = ((TCS.Config.A2G.TrainingRange and TCS.Config.A2G.TrainingRange.SPAWN_DISTANCE_NM) or 15) * 1852
    local bearing_rad = playerHdg + math.rad(math.random() * 90 - 45)
    siteHdg = bearing_rad + math.pi
    centerPos = {
      x = playerPos.x + math.sin(bearing_rad) * spawn_dist_m,
      y = playerPos.z + math.cos(bearing_rad) * spawn_dist_m
    }
    spawnMsg = samDef.label .. " site created ahead of position."
  end

  -- 2. Build AI Tasking
  local ai = _resolveAIParams(difficulty)
  local groupData = {
    name = string.format("DSAM-%s-%s-%d", samKey, group:GetName(), math.random(1000)),
    units = {},
    route = {
      points = {
        [1] = {
          x = centerPos.x, y = centerPos.y, type = "Turning Point", action = "Off Road", speed = 0,
          task = { id = "ComboTask", params = { tasks = {
            { id = "EngageTargets", params = { targetTypes = {"Air"}, maxDist = ai.maxDist } },
            { id = "SetOption", params = { value = ai.roe, name = 0 } },
            { id = "SetOption", params = { value = ai.reaction, name = 1 } }
          } } }
        }
      }
    }
  }

  -- 3. Resolve Composition
  local composition = samDef.compositions and (samDef.compositions[difficulty] or samDef.compositions["G"]) or samDef.composition
  if not composition then return nil end

  local targetNames = {}
  for i, compUnit in ipairs(composition) do
    local catalogEntry = TCS.Catalog.FindById(compUnit.id)
    if catalogEntry then
      local offsetX = compUnit.x * math.cos(siteHdg) - compUnit.y * math.sin(siteHdg)
      local offsetY = compUnit.x * math.sin(siteHdg) + compUnit.y * math.cos(siteHdg)
      local uName = string.format("%s_U%d", groupData.name, i)
      
      table.insert(groupData.units, {
        name = uName,
        type = catalogEntry.unit_types[1],
        x = centerPos.x + offsetX,
        y = centerPos.y + offsetY,
        heading = siteHdg + math.rad(compUnit.hdg or 0),
        skill = ai.skill
      })
      table.insert(targetNames, uName)
    end
  end

  -- 4. Spawn
  local newGroup = coalition.addGroup(coalition.side.RED, Group.Category.GROUND, groupData)
  local mooseGroup = GROUP:FindByName(newGroup.name)
  
  if mooseGroup then
    -- If the group has an active Range scoring session, add these as targets
    if TCS.RANGE and TCS.RANGE.Ranges[group:GetName()] then
      local r = TCS.RANGE.Ranges[group:GetName()].mooseRange
      if r then r:AddBombingTargets(targetNames) end
    end

    -- If silent is a positive number, turn off radar and start proximity monitor. 
    -- If -1, nil, or false, radar starts active.
    local silentDist = tonumber(params.silent)
    if silentDist and silentDist > 0 then
      mooseGroup:GetController():setCommand({id = 'SetRadarOn', params = { value = false }})
      
      -- Monitor proximity (Check every 5 seconds)
      SCHEDULER:New(nil, function(s)
        if not mooseGroup:IsAlive() then s:Stop(); return end
        
        local samCoord = mooseGroup:GetCoordinate()
        local playerNearby = false
        
        -- Check if any session member is within 10 NM
        session:ForEachMemberRec(function(pRec)
          if pRec.Unit and pRec.Unit:IsAlive() then
            local dist = samCoord:Get2DDistance(pRec.Unit:GetCoordinate())
            if dist < (silentDist * 1852) then playerNearby = true end
          end
        end)
        
        if playerNearby then
          mooseGroup:GetController():setCommand({id = 'SetRadarOn', params = { value = true }})
          s:Stop()
        end
      end, {}, 5, 5)
    end

    MESSAGE:New(spawnMsg, 15):ToGroup(group:GetName())

    -- Return Handle
    local handle = {
      SpawnedObjects = { mooseGroup },
      StartTime = timer.getTime(),
      Duration = params.duration or 7200
    }
    function handle:IsOver()
      if timer.getTime() > (self.StartTime + self.Duration) then return true, "TIMEOUT" end
      if not self.SpawnedObjects[1]:IsAlive() then return true, "COMPLETE" end
      return false
    end
    return handle
  end

  return nil
end

env.info("TCS(DSAM): ready")