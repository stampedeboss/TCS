env.info("TCS(A2G_CORE): loading")

TCS = TCS or {}
TCS.A2G = TCS.A2G or {}

-- Ensure core namespaces exist to prevent nil indexing errors in sub-modules
TCS.A2G.Echelons = TCS.A2G.Echelons or {}
TCS.A2G.Config   = TCS.A2G.Config or {}
TCS.A2G.Feedback = TCS.A2G.Feedback or {}

-- Global messaging helper used across A2A and A2G modules
function _G.MsgToGroup(group, text, duration)
  if group then
    MESSAGE:New(text, duration or 10):ToGroup(group)
  end
end

-- Standardized feedback method for A2G modules
function TCS.A2G.Feedback.ToGroup(group, text, duration)
  MsgToGroup(group, text, duration)
end

--- Broadcasts a message to all members of a session.
-- @param session (table) The session object.
-- @param text (string) The message text.
-- @param duration (number) Duration in seconds.
function TCS.A2G.NotifySession(session, text, duration)
  if not session then return end
  if session.Broadcast then
    session:Broadcast(text, duration)
  end
  if TCS.AWACS and TCS.AWACS.Say then
    TCS.AWACS.Say(text)
  end
end

--- Dispatches AI reinforcements to a specific location from the nearest base.
-- @param session (table) The session object.
-- @param anchor (Coordinate) Objective coordinate.
-- @param echelon (string) Force size.
-- @param coal (number) Coalition ID.
-- @param forceName (string) Force composition key.
-- @param tag (string) Mission tag for messaging.
function TCS.A2G.ReinforceTask(session, anchor, echelon, coal, forceName, tag)
  local closestAB = TCS.GetClosestCoalitionAirbase(anchor, coal)
  if not closestAB then return end
  
  local abCoord = COORDINATE:NewFromVec3(closestAB:getPoint())
  local spawnCoord = abCoord:Translate(200, math.random(0,359))

  -- Scale reinforcement size (Quick Reaction Force is usually smaller than the original echelon)
  local qrfEch = echelon
  if echelon == "BRIGADE" then qrfEch = "BATTALION"
  elseif echelon == "BATTALION" then qrfEch = "COMPANY"
  elseif echelon == "TASK_FORCE" then qrfEch = "TASK_GROUP"
  elseif echelon == "TASK_GROUP" then qrfEch = "TASK_UNIT"
  elseif echelon == "TASK_UNIT" then qrfEch = "SEA_PATROL"
  end

  -- Calculate Staging Area: 10km from objective towards the base
  local stagingCoord = anchor:Translate(10000, anchor:HeadingTo(abCoord))

  TCS.A2G.NotifySession(session, string.format("COMMAND: %s QRF units dispatched from %s. Staging at 10km.", tag, closestAB:getName()), 15)
  
  -- 1. Ground Reinforcements
  local spawnedGround = TCS.A2G.ForceSpawner.Spawn(session, forceName, qrfEch, spawnCoord, {coalition=coal})
  
  if spawnedGround then
    for _, g in ipairs(spawnedGround) do
      if g and g:IsAlive() and g.TaskRouteToVec2 then
        -- Route to staging first
        g:TaskRouteToVec2(stagingCoord:GetVec2(), 60/3.6, "On Road")
        -- Then to objective
        g:TaskRouteToVec2(anchor:GetVec2(), 45/3.6, "On Road")
      end
    end
  end

  -- 2. Air-based reinforcements if it's an airbase or helipad
  local abDesc = closestAB:getDesc()
  if abDesc.category == 0 or abDesc.category == 1 then -- AIRDROME or HELIPAD
    local spawnedAir = TCS.A2G.ForceSpawner.Spawn(session, "HELO_QRF", "SECTION", abCoord:Translate(500, math.random(0,359)), {coalition=coal})
    if spawnedAir then
      for _, g in ipairs(spawnedAir) do
        if g and g:IsAlive() and g.TaskRouteToVec2 then
          -- Helos fly directly
          g:TaskRouteToVec2(stagingCoord:GetVec2(), 180/3.6)
          g:TaskRouteToVec2(anchor:GetVec2(), 120/3.6)
        end
      end
    end

    -- 3. Fixed-wing reinforcements if it's a full airdrome (30% chance)
    if abDesc.category == 0 and math.random() < 0.3 then
      local spawnedFixed = TCS.A2G.ForceSpawner.Spawn(session, "CAS_QRF", "SECTION", abCoord:Translate(1000, math.random(0,359)), {coalition=coal})
      if spawnedFixed then
        TCS.A2G.NotifySession(session, string.format("INTEL: Fixed-wing CAS elements scrambling from %s!", closestAB:getName()), 15)
        for _, g in ipairs(spawnedFixed) do
          if g and g:IsAlive() and g.TaskRouteToVec2 then
            -- Fixed wing flies much faster
            g:TaskRouteToVec2(stagingCoord:GetVec2(), 450/3.6)
            g:TaskRouteToVec2(anchor:GetVec2(), 350/3.6)
          end
        end
      end
    end
  end

  -- 4. Carrier-based reinforcements if it's a ship (category 2) (50% chance)
  if abDesc.category == 2 and math.random() < 0.5 then
    local spawnedCV = TCS.A2G.ForceSpawner.Spawn(session, "CV_CAS_QRF", "SECTION", abCoord:Translate(1000, math.random(0,359)), {coalition=coal})
    if spawnedCV then
      TCS.A2G.NotifySession(session, string.format("INTEL: Carrier-based air elements launching from %s!", closestAB:getName()), 15)
      for _, g in ipairs(spawnedCV) do
        if g and g:IsAlive() and g.TaskRouteToVec2 then
          -- Fixed wing flies much faster
          g:TaskRouteToVec2(stagingCoord:GetVec2(), 450/3.6)
          g:TaskRouteToVec2(anchor:GetVec2(), 350/3.6)
        end
      end
    end
  end
end

--- Wipes all TCS-spawned A2G objects (Groups & Statics) from the map.
function TCS.A2G.CleanupAllSpawns()
  local prefix = "TCS_"
  local count = 0

  local sides = { coalition.side.RED, coalition.side.BLUE, coalition.side.NEUTRAL }
  local cats = { Group.Category.GROUND, Group.Category.SHIP, Group.Category.TRAIN }

  for _, side in ipairs(sides) do
    -- Groups
    for _, cat in ipairs(cats) do
      local groups = coalition.getGroups(side, cat) or {}
      for _, g in ipairs(groups) do
        if g and g:isExist() and string.sub(g:getName(), 1, #prefix) == prefix then
          g:destroy()
          count = count + 1
        end
      end
    end
    -- Statics
    local statics = coalition.getStaticObjects(side) or {}
    for _, s in ipairs(statics) do
      if s and s:isExist() and string.sub(s:getName(), 1, #prefix) == prefix then
        s:destroy()
        count = count + 1
      end
    end
  end
  
  local msg = string.format("TCS Admin: Wiped %d A2G spawns (Global).", count)
  env.info(msg)
  MESSAGE:New(msg, 10):ToAll()
  return count
end

env.info("TCS(A2G_CORE): ready")