---------------------------------------------------------------------
-- TCS SUW (Surface Warfare)
-- Anti-Ship and Naval Strike operations
---------------------------------------------------------------------
env.info("TCS(SUW): loading")

TCS = TCS or {}
TCS.SUW = {}

-- Traffic Manager: Owns ambient traffic and cleans it up upon arrival
local TrafficManager = {
  Registry = {}
}

function TrafficManager:Register(groupName, destinationVec2)
  self.Registry[groupName] = destinationVec2
  -- Ensure loop is running
  if not self.LoopID then
    self.LoopID = timer.scheduleFunction(function(_, time) return self:Check(time) end, nil, timer.getTime() + 10)
  end
end

function TrafficManager:Check(t)
  local suwCfg = (TCS.A2G and TCS.A2G.Config and TCS.A2G.Config.SUW) or {}
  local cleanupDist = (suwCfg.TRAFFIC_CLEANUP_DIST_NM or 2) * 1852
  local toRemove = {}
  for name, dest in pairs(self.Registry) do
    local g = Group.getByName(name)
    local keep = false
    if g and g:isExist() then
      local units = g:getUnits()
      if units and #units > 0 then
        local u = units[1]
        local p = u:getPoint()
        local dist = math.sqrt((p.x - dest.x)^2 + (p.z - dest.y)^2)
        if dist < cleanupDist then
          g:destroy()
        else
          keep = true
        end
      end
    end
    if not keep then table.insert(toRemove, name) end
  end
  for _, n in ipairs(toRemove) do self.Registry[n] = nil end
  return t + 60
end

function TCS.SUW.SpawnAmbientTraffic(centerPoint, enemySide)
  enemySide = enemySide or coalition.side.RED
  local suwCfg = TCS.A2G.Config.SUW or {}
  local radiusNm = suwCfg.TRAFFIC_RADIUS_NM or 150
  local count = suwCfg.TRAFFIC_COUNT or 20
  local types = suwCfg.TRAFFIC_TYPES or { "Bulk Cargo Ship", "Dry-cargo ship-1", "Tanker" }

  local minSpacing = (suwCfg.TRAFFIC_MIN_SPACING_NM or 10) * 1852
  local facOffset = suwCfg.FAC_OFFSET_M or 500
  local facTypes = suwCfg.FAST_ATTACK_TYPES or {}
  local facChance = suwCfg.TRAFFIC_HOSTILE_CHANCE or 0
  
  -- Find potential destinations (Airbases as proxies for ports)
  local destinations = {}
  for _, side in pairs({coalition.side.RED, coalition.side.BLUE, coalition.side.NEUTRAL}) do
    local bases = coalition.getAirbases(side) or {}
    for _, base in ipairs(bases) do
      if base and base:getPoint() then
        table.insert(destinations, base:getPoint())
      end
    end
  end

  local spawnedLocs = {}

  for i = 1, count do
    for attempt = 1, 5 do
    -- Random point in radius (sqrt for uniform distribution)
    local r = math.sqrt(math.random()) * (radiusNm * 1852)
    local theta = math.random(0, 359)
    local spawnPt = centerPoint:Translate(r, theta)
    local p2 = spawnPt:GetVec2()

    local tooClose = false
    for _, loc in ipairs(spawnedLocs) do
      local d = math.sqrt((p2.x - loc.x)^2 + (p2.y - loc.y)^2)
      if d < minSpacing then tooClose = true; break end
    end

    -- Check if water and spacing
    if not tooClose and land.getSurfaceType({x = p2.x, y = p2.y}) == land.SurfaceType.WATER then
      -- Found valid spot
      table.insert(spawnedLocs, {x=p2.x, y=p2.y})
      local isMoving = math.random() > 0.4 -- 60% moving
      local shipType = types[math.random(#types)]
      local name = "CIV_TRAFFIC_" .. math.random(100000, 999999)
      
      local units = {
        [1] = {
          name = name .. "_U",
          type = shipType,
          x = p2.x,
          y = p2.y,
          heading = math.rad(math.random(0, 359)),
          skill = "Average"
        }
      }

      local route = { points = {} }
      -- Start point
      table.insert(route.points, {
        x = p2.x,
        y = p2.y,
        action = "Off Road",
        speed = isMoving and 10 or 0,
        type = "Turning Point"
      })

      local targetX, targetY

      if isMoving then
        -- Find nearest destination
        local bestDest = nil
        local minD = math.huge
        local myPos = spawnPt:GetVec3()
        
        for _, dest in ipairs(destinations) do
          local d = math.sqrt((myPos.x - dest.x)^2 + (myPos.z - dest.z)^2)
          if d < minD then
            minD = d
            bestDest = dest
          end
        end

        if bestDest then
          targetX = bestDest.x
          targetY = bestDest.z
        else
          -- Random move if no bases found
          local dPt = spawnPt:Translate(20000, math.random(0, 359))
          local d2 = dPt:GetVec2()
          targetX = d2.x
          targetY = d2.y
        end

        table.insert(route.points, {
          x = targetX,
          y = targetY,
          action = "Off Road",
          speed = 10,
          type = "Turning Point"
        })

        TrafficManager:Register(name, {x=targetX, y=targetY})
      end

      local civGroup = TCS.Spawn.GroupFromData({
        name = name,
        task = "ComboTask",
        route = route,
        units = units
      }, Group.Category.SHIP, coalition.side.NEUTRAL)

      if civGroup then
        env.info("TCS(SUW): Spawned civilian traffic: " .. name)
        SCHEDULER:New(nil, function()
          if civGroup and civGroup:IsAlive() then
            civGroup:getController():setOption(AI.Option.Naval.id.ROE, AI.Option.Naval.val.ROE.RETURN_FIRE)
            civGroup:getController():setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.GREEN)
          end
        end, {}, 1.0)
      end
      
      -- Chance to spawn hostile Fast Attack Craft hiding in traffic
      if #facTypes > 0 and math.random() < facChance then
        local facType = facTypes[math.random(#facTypes)]
        local facName = "FAC_HIDDEN_" .. math.random(100000, 999999)
        
        -- Spawn close to the civilian ship (within ~500m)
        local facX = p2.x + math.random(-facOffset, facOffset)
        local facY = p2.y + math.random(-facOffset, facOffset)

        local facRoute = { points = {} }
        table.insert(facRoute.points, {
          x = facX,
          y = facY,
          action = "Off Road",
          speed = isMoving and 25 or 0, -- FACs move faster/aggressively
          type = "Turning Point"
        })

        if isMoving and targetX and targetY then
          table.insert(facRoute.points, {
            x = targetX,
            y = targetY,
            action = "Off Road",
            speed = 25,
            type = "Turning Point"
          })
          -- Register hostiles for cleanup too so they don't accumulate at the destination
          TrafficManager:Register(facName, {x=targetX, y=targetY})
        end

        local facUnits = { [1] = { name = facName.."_U", type = facType, x = facX, y = facY, heading = math.rad(math.random(0,359)), skill = "Average" } }
        local facGroup = TCS.Spawn.GroupFromData({ name = facName, task = "ComboTask", route = facRoute, units = facUnits }, Group.Category.SHIP, enemySide)

        if facGroup then
          env.info("TCS(SUW): Spawned hostile FAC traffic: " .. facName)
          SCHEDULER:New(nil, function()
            if facGroup and facGroup:IsAlive() then
              facGroup:getController():setOption(AI.Option.Naval.id.ROE, AI.Option.Naval.val.ROE.RETURN_FIRE)
            end
          end, {}, 1.0)
        end
      end
      break -- Success, next ship
    end
    end -- attempt loop
  end
end

function TCS.SUW.Start(session, anchor, forceName, label, move, group, echelon)
  -- 1. Standard Scenario Setup
  anchor = TCS.Scenario.Setup(session, forceName, anchor, group, {Bias=false, domain="SEA"})
  if not anchor then return end

  local enemySide = coalition.side.RED
  if group then
    enemySide = (group:GetCoalition() == coalition.side.RED) and coalition.side.BLUE or coalition.side.RED
  elseif session and session.Coalition then
    enemySide = (session.Coalition == coalition.side.RED) and coalition.side.BLUE or coalition.side.RED
  end

  local difficulty = TCS.ResolveDifficulty(session, "SEA", echelon)
  local echelonName = TCS.GetEchelonFromTier(difficulty, "SEA")
  
  local skillMap = { A="Average", G="Good", H="High", X="Excellent" }
  local skill = skillMap[difficulty] or "Average"

  local force = TCS.A2G.ForceSpawner.Spawn(session, forceName, echelonName, anchor, {
    coalition=enemySide,
    tier=difficulty,
    skill=skill
  })

  if force and #force > 0 then
    for _, g in ipairs(force) do
      if g and g.OptionROE then
        g:OptionROE(ENUMS.ROE.ReturnFire)
      end
    end

    -- Carrier CAP for Tier X
    if difficulty == "X" and TCS.A2A and TCS.A2A.SpawnBandit then
      local carrierGroup = nil
      for _, g in ipairs(force) do
        local u = g:GetUnit(1)
        if u and u:GetTypeName() == "KUZNECOV" then
          carrierGroup = g
          break
        end
      end

      if carrierGroup then
        local capDef = TCS.A2A.GetBanditDef({ role = "BVR", tier = difficulty })
        if capDef then
          local capPos = carrierGroup:GetCoordinate():Translate(4000, math.random(0, 359))
          capPos:SetAltitude(6096) -- 20k ft

          TCS.A2A.SpawnBandit(session, capDef, "SUW_CAP_" .. math.random(1000, 9999), capPos, 0, function(bg)
            SCHEDULER:New(nil, function()
              if not bg or not bg:IsAlive() then return end
              if group then TCS.A2A.TrackSplash(group, bg) end
              
              local ok, fg = pcall(function() return FLIGHTGROUP:New(bg) end)
              if ok and fg then
                fg:SetDetection(true)
                fg:AddMission(AUFTRAG:NewESCORT(carrierGroup))
              end
              TCS.A2A.NotifySession(session, "WARNING: Carrier Air Patrol launching!", 15)
            end, {}, 2)
          end, 2)
        end
      end
    end

    TCS.SUW.SpawnAmbientTraffic(anchor, enemySide)
    if move then
      local cfg = TCS.A2G.Config.MAR or { MOVE_DIST_NM = { MIN = 15, MAX = 30 }, SPEED_KTS = { MIN = 10, MAX = 25 } }
      local dist = cfg.MOVE_DIST_NM.MIN + math.random() * (cfg.MOVE_DIST_NM.MAX - cfg.MOVE_DIST_NM.MIN)
      local speedKts = cfg.SPEED_KTS.MIN + math.random() * (cfg.SPEED_KTS.MAX - cfg.SPEED_KTS.MIN)
      local speedMs = speedKts * 0.514444
      local hdg = 0
      if group then hdg = group:GetUnit(1):GetHeading() else hdg = math.random(0, 359) end
      local dest = anchor:Translate(dist * 1852, hdg)
      for _, g in ipairs(force) do
        if g and g.TaskRouteToVec2 then
          g:TaskRouteToVec2(dest:GetVec2(), speedMs, "On Road")
        end
      end
    end
    
    local echCfg = TCS.A2G.Echelons and TCS.A2G.Echelons[echelonName]
    local drawRad = (echCfg and echCfg.scale or 1) * 12000 -- 12km per scale unit (e.g. 48km for Task Force)
    -- Draw Zone on F10 Map
    TCS.Scenario.Draw(session, forceName, anchor, echelon, drawRad, {0,0,1,1}, {0,0,1,0.15})

    if group then TCS.A2G.Feedback.ToGroup(group, label .. " scenario generated.") end

    if TCS.Controller and TCS.Controller.OnEvent then
      TCS.Controller:OnEvent("A2G_START", { session = session, anchor = anchor, type = "SUW" })
    end
  else
    if group then TCS.A2G.Feedback.ToGroup(group, "Failed to generate " .. label .. " force.") end
  end

  -- Monitor for Naval Retreat
  local function countStrength(groups)
    local c = 0
    for _, g in ipairs(groups or {}) do if g and g:IsAlive() then c = c + g:GetSize() end end
    return c
  end
  local initStr = countStrength(force)

  timer.scheduleFunction(function(_, t)
    if not session[forceName.."_Drawings"] then return nil end
    local currStr = countStrength(force)
    if initStr > 0 and (currStr / initStr) < 0.70 then
      if group then TCS.A2G.Feedback.ToGroup(group, "SUW: Enemy group scattering!", 15) end
      local retreatPt = anchor:Translate(10000, math.random(0, 359))
      trigger.action.smoke(retreatPt:GetVec3(), trigger.smokeColor.Red)
      for _, g in ipairs(force) do if g and g:IsAlive() then g:TaskRouteToVec2(retreatPt:GetVec2(), 25 * 0.514, "On Road") end end
      return nil
    end
    return t + 90
  end, nil, timer.getTime() + 90)
end

local function MenuRequest(group, forceName, label, move)
  local session = TCS.SessionManager:GetOrCreateSessionForGroup(group)
  if not session then return end
  local unit = group:GetUnit(1)
  local point = TCS.Placement.Resolve(unit, "SEA")
  TCS.SUW.Start(session, point, forceName, label, move, group)
end

function TCS.SUW.StartAntiShip(group) MenuRequest(group, "SUW_SAG", "Anti-Ship", true) end
function TCS.SUW.StartStrike(group)   MenuRequest(group, "MAR_HARBOR", "Naval Strike", false) end
function TCS.SUW.StartConvoy(group)   MenuRequest(group, "MAR_CONVOY", "Convoy Hunt", true) end

env.info("TCS(SUW): ready")
