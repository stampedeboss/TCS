---------------------------------------------------------------------
-- TCS CIC: CONTROLLER
--
-- Purpose:
--   Central brain for cross-domain logic.
--   Orchestrates interactions between A2A, A2G, and Logistics.
---------------------------------------------------------------------
env.info("TCS(CIC.CONTROLLER): loading")

TCS = TCS or {}
TCS.CIC = TCS.CIC or {}
TCS.CIC.Controller = {
  Taskings = {},
  Deployments = {} -- Tracks active envSpecs and their spawned groups
}

function TCS.CIC.Controller:OnEvent(event, params)
  env.info("TCS(CONTROLLER): Event " .. tostring(event))
  
  if event == "CAS_RETREAT" then
    self:HandleCasRetreat(params)
  elseif event == "ESCORT_START" then
    self:HandleEscortStart(params)
  elseif event == "A2G_START" then
    self:HandleA2GStart(params)
  end
end

function TCS.CIC.Controller:AddTasking(type, desc, location, onAcceptFn)
  local id = math.random(1000, 9999)
  self.Taskings[id] = { ID = id, Type = type, Desc = desc, Location = location, OnAccept = onAcceptFn, Timestamp = timer.getTime() }
  local msg = string.format("TASKING BOARD: New Tasking [%d]\nType: %s\nDesc: %s", id, type, desc)
  env.info("TCS(CONTROLLER): " .. msg)
  if MESSAGE then MESSAGE:New(msg, 15):ToAll() else trigger.action.outText(msg, 15) end
  return id
end

function TCS.CIC.Controller:AcceptTasking(id, group, mode)
  local t = self.Taskings[id]
  if not t then return false, "Tasking not found or already taken." end
  if t.OnAccept then t.OnAccept(group, mode) end
  self.Taskings[id] = nil
  return true, "Tasking accepted."
end

function TCS.CIC.Controller:MonitorTaskings()
  local now = timer.getTime()
  local timeout = 3600 -- 1 hour
  for id, t in pairs(self.Taskings) do
    if now - t.Timestamp > timeout then self.Taskings[id] = nil end
  end
  return now + 300
end

function TCS.CIC.Controller:TriggerTripwireResponse(anchorVec3, triggerRadius, intruderCount, coalitionId)
    intruderCount = math.max(1, intruderCount or 1)
    local pairsNeeded = math.ceil(intruderCount / 2)
    
    env.info(string.format("TCS(CIC.CONTROLLER): Tripwire response initiated. Intruders: %d, Intercept Pairs Ordered: %d", intruderCount, pairsNeeded))

    -- 1. Modify overlapping CAPs to SWEEP
    for zoneId, dep in pairs(self.Deployments) do
        if dep.Status == "ACTIVE" and dep.Spec.missionType == "CAP" and dep.PrimaryCoalition == coalitionId then
            local capAnchorVec3 = dep.Spec.anchor:GetVec3()
            local dist = math.sqrt((capAnchorVec3.x - anchorVec3.x)^2 + (capAnchorVec3.z - anchorVec3.z)^2)
            local capRadius = 40 * 1852 -- Standard default CAP radius

            -- If any part of the CAP zone falls within the killbox
            if dist < (capRadius + triggerRadius) then
                dep.Spec.missionType = "SWEEP"
                local newSweepRadius = capRadius * 2

                for _, grp in ipairs(dep.Groups) do
                    if grp and grp:IsAlive() then
                        local ok, flightGroup = pcall(function() return FLIGHTGROUP:New(grp:GetName()) end)
                        if ok and flightGroup then
                            local sweepZone = ZONE_RADIUS:New("SWEEP_ZONE_UPG_" .. grp:GetName(), {x = capAnchorVec3.x, y = capAnchorVec3.z}, newSweepRadius)
                            flightGroup:AddMission(AUFTRAG:NewSweep(sweepZone))
                            env.info(string.format("TCS(CIC.CONTROLLER): Upgraded CAP %s to SWEEP. Radius doubled.", grp:GetName()))
                        end
                    end
                end
            end
        end
    end

    -- 2. Dispatch staggered interceptors from the closest base
    if TriggerSystemIntercept then
        local interceptCoord = COORDINATE:NewFromVec3(anchorVec3)
        for i = 1, pairsNeeded do
            local delaySecs = (i - 1) * math.random(60, 120)
            local interceptParams = { anchor = interceptCoord, initial = 2, max = 2, coalition = coalitionId }
            timer.scheduleFunction(function(args) if TriggerSystemIntercept then TriggerSystemIntercept(args[1]) end end, {interceptParams}, timer.getTime() + delaySecs)
            env.info(string.format("TCS(CIC.CONTROLLER): Ordered Tripwire Intercept pair %d/%d (Delay: %ds)", i, pairsNeeded, delaySecs))
        end
    end
end

---------------------------------------------------------------------
-- Deployment Monitoring & Evaluation
---------------------------------------------------------------------
function TCS.CIC.Controller:RegisterDeployment(zoneId, envSpec, spawnedObjects)
  if not zoneId or not envSpec or not spawnedObjects then return end
  
  local counts = { ENEMY = 0, FRIENDLY = 0 }
  local primaryCoalition = envSpec.coalition or coalition.side.RED

  for _, group in ipairs(spawnedObjects) do
      if group and group.GetInitialSize then
          local isFriendly = (group:GetCoalition() ~= primaryCoalition)
          local size = group:GetInitialSize()
          if isFriendly then counts.FRIENDLY = counts.FRIENDLY + size
          else counts.ENEMY = counts.ENEMY + size end
      end
  end
  
  if counts.ENEMY == 0 and counts.FRIENDLY == 0 then return end
  
  self.Deployments[zoneId] = {
      ZoneID = zoneId, Spec = envSpec, Groups = spawnedObjects,
      InitialCounts = counts, Status = "ACTIVE",
      PrimaryCoalition = primaryCoalition
  }
  env.info(string.format("TCS(CIC.CONTROLLER): Monitoring Zone %s. Enemy: %d, Friendly: %d", tostring(zoneId), counts.ENEMY, counts.FRIENDLY))
end

function TCS.CIC.Controller:EvaluateDeployments()
  for zoneId, dep in pairs(self.Deployments) do
      if dep.Status == "ACTIVE" then
          local currentCounts = { ENEMY = 0, FRIENDLY = 0 }
          
          for _, group in ipairs(dep.Groups) do
              if group and group:IsAlive() then
                  local isFriendly = (group:GetCoalition() ~= dep.PrimaryCoalition)
                  local aliveCount = 0
                  for _, u in ipairs(group:GetUnits() or {}) do
                      if u and u:IsAlive() then aliveCount = aliveCount + 1 end
                  end
                  if isFriendly then currentCounts.FRIENDLY = currentCounts.FRIENDLY + aliveCount
                  else currentCounts.ENEMY = currentCounts.ENEMY + aliveCount end
              end
          end

          local attrition = {
              ENEMY = dep.InitialCounts.ENEMY > 0 and ((dep.InitialCounts.ENEMY - currentCounts.ENEMY) / dep.InitialCounts.ENEMY) or 0,
              FRIENDLY = dep.InitialCounts.FRIENDLY > 0 and ((dep.InitialCounts.FRIENDLY - currentCounts.FRIENDLY) / dep.InitialCounts.FRIENDLY) or 0
          }

          for _, criteria in ipairs(dep.Spec.successCriteria or {}) do
              local targetType = criteria.target -- "ALL_ENEMY" or "ALL_FRIENDLY"
              local rate = (targetType == "ALL_FRIENDLY") and attrition.FRIENDLY or attrition.ENEMY
              
              if criteria.type == "ATTRITION" and rate >= (criteria.threshold or 1.0) then
                  env.info(string.format("TCS(CIC.CONTROLLER): Zone %s achieved criteria: %s (Target: %s, Attrition: %.2f)", zoneId, criteria.result, targetType, rate))
                  dep.Status = "COMPLETED"
                  
                  -- CONSEQUENCES: Trigger subsequent events if players failed!
                  if criteria.result == "FRIENDLY_OVERRUN" then
                      TCS.CIC.Controller:OnEvent("CAS_RETREAT", { location = dep.Spec.anchor, group = nil })
                  elseif criteria.result == "PACKAGE_DESTROYED" then
                      if TCS.Signals and TCS.Signals.AWACS and TCS.Signals.AWACS.Say then TCS.Signals.AWACS.Say("MAGIC. BE ADVISED, FRIENDLY PACKAGE HAS BEEN DESTROYED.") end
                  end
                  
                  if criteria.flag then
                      trigger.action.setUserFlag(criteria.flag, criteria.flagValue or 1)
                      if TCS.Logger then TCS.Logger.trace("TCS(CIC.CONTROLLER): Set DCS flag '%s' to %s", tostring(criteria.flag), tostring(criteria.flagValue or 1)) end
                  end
                  if criteria.message then
                      if MESSAGE then MESSAGE:New(criteria.message, 15):ToAll() else trigger.action.outText(criteria.message, 15) end
                  end
                  
                  break
              end
          end
      end
  end
  return timer.getTime() + 10 -- Check every 10 seconds
end

function TCS.CIC.Controller:EvaluateSensors()
  for zoneId, dep in pairs(self.Deployments) do
      if dep.Status == "ACTIVE" and dep.Spec and dep.Spec.components then
          for _, comp in ipairs(dep.Spec.components) do
              if comp.behavior and comp.behavior.silentDistance and comp.behavior.silentDistance ~= -1 and not comp.SensorTriggered then
                  local isAmbush = (comp.behavior.silentDistance < 0)
                  local triggerDist = math.abs(comp.behavior.silentDistance) * 1852 -- Convert NM to meters
                  local centerVec3 = dep.Spec.anchor:GetVec3()
                  local closestDist = math.huge
                  local intruderCount = 0
                  
                  -- Scan for any enemy aircraft in a 30NM bubble
                  local targetCoalition = (comp.coalition == coalition.side.RED) and coalition.side.BLUE or coalition.side.RED
                  local vol = { id = world.VolumeType.SPHERE, params = { point = centerVec3, radius = 55000 } }
                  
                  world.searchObjects(Object.Category.UNIT, vol, function(obj)
                      if obj and obj:isExist() and obj:getCoalition() == targetCoalition then
                          local desc = obj:getDesc()
                          if desc and (desc.category == Unit.Category.AIRPLANE or desc.category == Unit.Category.HELICOPTER) then
                              local dist = math.sqrt((centerVec3.x - obj:getPoint().x)^2 + (centerVec3.z - obj:getPoint().z)^2)
                              if dist < closestDist then closestDist = dist end
                              if dist <= triggerDist then intruderCount = intruderCount + 1 end
                          end
                      end
                      return true
                  end)

                  local lastDist = comp.LastDist or math.huge
                  local trigger = false

                  if isAmbush then
                      -- TRAP SPRINGS: Target was getting closer, is now moving away, AND is inside the killbox!
                      if closestDist > lastDist and closestDist <= triggerDist then trigger = true end
                  else
                      -- STANDARD POP-UP: Target simply crossed the distance threshold
                      if closestDist <= triggerDist then trigger = true end
                  end

                  if trigger then
                      comp.SensorTriggered = true
                      env.info(string.format("TCS(CIC.CONTROLLER): Sensor trap sprung for zone %s at %.1f NM", zoneId, closestDist / 1852))
                      if comp.spawnedGroups then
                          for _, g in ipairs(comp.spawnedGroups) do
                              if g and g:IsAlive() then
                                  g:GetController():setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.RED)
                                    g:GetController():setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.WEAPON_FREE)
                              end
                          end
                      end
                      self:TriggerTripwireResponse(centerVec3, triggerDist, intruderCount, comp.coalition)
                  end
                  comp.LastDist = closestDist
              end

              -- NEW: Border-Restricted Engagement Logic (Aggressive Radar, Hold Fire until border distance crossed)
              if comp.behavior and comp.behavior.engageRange == "ANCHOR" and comp.behavior.roe == "WEAPON_HOLD" and not comp.RoeReleased then
                  if comp.spawnedGroups and comp.spawnedGroups[1] and comp.spawnedGroups[1]:IsAlive() then
                      local groupVec3 = comp.spawnedGroups[1]:GetVec3()
                      local anchorVec3 = dep.Spec.anchor:GetVec3()
                      
                      -- Set engagement ring to the exact distance between the SAM and the border anchor
                      local triggerDist = math.sqrt((groupVec3.x - anchorVec3.x)^2 + (groupVec3.z - anchorVec3.z)^2)
                      local targetCoalition = (comp.coalition == coalition.side.RED) and coalition.side.BLUE or coalition.side.RED
                      
                      local vol = { id = world.VolumeType.SPHERE, params = { point = groupVec3, radius = triggerDist } }
                      local trigger = false
                      local intruderCount = 0
                      
                      world.searchObjects(Object.Category.UNIT, vol, function(obj)
                          if obj and obj:isExist() and obj:getCoalition() == targetCoalition then
                              local desc = obj:getDesc()
                              if desc and (desc.category == Unit.Category.AIRPLANE or desc.category == Unit.Category.HELICOPTER) then
                                  trigger = true
                                  intruderCount = intruderCount + 1
                              end
                          end
                          return true -- Keep searching to count all intruders
                      end)

                      if trigger then
                          comp.RoeReleased = true
                          env.info(string.format("TCS(CIC.CONTROLLER): Intruder crossed border-restricted range for zone %s. Weapons Free!", zoneId))
                          
                          local audioMsg = "MAGIC. BE ADVISED, INTRUDER CROSSED RESTRICTED LINE. LONG RANGE S-A-M SITES ARE WEAPONS FREE."
                          local textMsg = "CIC: Intruder crossed border constraint. Long-Range SAMs are Weapons Free!"
                          
                          if TCS.CIC.AWACS and TCS.CIC.AWACS.Say then TCS.CIC.AWACS.Say(audioMsg) end
                          if MESSAGE then 
                              MESSAGE:New(textMsg, 15):ToAll() 
                          else 
                              trigger.action.outText(textMsg, 15) 
                          end
                          
                          for _, g in ipairs(comp.spawnedGroups) do
                              if g and g:IsAlive() then
                                  g:GetController():setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.WEAPON_FREE)
                              end
                          end
                          self:TriggerTripwireResponse(groupVec3, triggerDist, intruderCount, comp.coalition)
                      end
                  end
              end
          end
      end
  end
end

function TCS.CIC.Controller:HandleCasRetreat(params)
  local location = params.location
  local group = params.group
  if not group or not location then return end

  local msg = "COMMAND: CAS forces are overrun! Requesting immediate extraction."
  if TCS.MsgToGroup then TCS.MsgToGroup(group, msg, 15) end
  if TCS.CIC.AWACS and TCS.CIC.AWACS.Say then TCS.CIC.AWACS.Say(msg) end

  -- Dispatch a Helicopter QRF to the retreat location
  if DeployCustom then
      DeployCustom({ anchor = location, forceSize = "QRF_HELO" })
  end
end

function TCS.CIC.Controller:HandleEscortStart(params)
  local dest = params.destination
  local pkgType = params.type -- e.g. "STRIKE", "CAS"
  if not dest then return end

  if pkgType == "STRIKE" or pkgType == "BOMBER" then
      local surf = land.getSurfaceType({x=dest.x, y=dest.z})
      if surf == land.SurfaceType.WATER and DeployCivilian then
          -- Escort is flying over water, generate a Naval Harbor/Strike target
          DeployCivilian({ anchor = dest, forceSize = "COMPANY" })
      elseif DeployFacility then
          -- Escort is flying over land, generate a Ground Facility
          DeployFacility({ anchor = dest, forceSize = "COMPANY" })
      end
  elseif pkgType == "CAS" and DeployGroundForces then
      -- Escort is flying a CAS package, generate Troops in Contact
      DeployGroundForces({ anchor = dest, friendlyCoalition = coalition.side.BLUE })
  end
end

function TCS.CIC.Controller:HandleA2GStart(params)
  local anchor = params.anchor
  local group = params.group
  
  -- 40% chance the enemy launches a defensive CAP over the target area
  if math.random() < 0.40 and DeployAirPatrol then
    local msg = "WARNING: Enemy Air Response detected launching!"
    if group and TCS.MsgToGroup then TCS.MsgToGroup(group, msg, 15) end
    if TCS.CIC.AWACS and TCS.CIC.AWACS.Say then TCS.CIC.AWACS.Say(msg) end
    
    -- Use the API to request a CAP, the Architect handles the placement math!
    DeployAirPatrol({ anchor = anchor, forceSize = "SQUADRON" })
  end
end

function TCS.CIC.Controller:EscalateIADS(coalitionId)
    local enemyCoalition = (coalitionId == coalition.side.RED) and coalition.side.BLUE or coalition.side.RED
    local msg = "WARNING: Enemy Air Defenses are switching to advanced tactics. Expect radar ambushes and mobile shoot-and-scoot!"
    
    if MESSAGE then MESSAGE:New(msg, 15):ToCoalition(enemyCoalition) else trigger.action.outText(msg, 15) end
    if TCS.CIC.AWACS and TCS.CIC.AWACS.Say then TCS.CIC.AWACS.Say(msg) end

    for zoneId, dep in pairs(self.Deployments) do
        if dep.Status == "ACTIVE" and dep.PrimaryCoalition == coalitionId then
            if dep.Spec and dep.Spec.components then
                for _, comp in ipairs(dep.Spec.components) do
                    -- Determine if this component has SAMs
                    local hasAirDef = false
                    for _, item in ipairs(comp.manifest or {}) do
                        if item.unit_type and (string.find(item.unit_type, "SA%-") or string.find(item.unit_type, "Patriot") or string.find(item.unit_type, "Hawk")) then
                            hasAirDef = true
                            break
                        end
                    end

                    if hasAirDef then
                        -- 1. Turn on Ambush Mode (Set 15 NM High-Probability Kill Box)
                        comp.behavior = comp.behavior or {}
                        comp.behavior.silentDistance = 15 
                        comp.SensorTriggered = false -- Reset the trap so EvaluateSensors catches it

                        -- 2. Execute immediate tactical posture shift
                        if comp.spawnedGroups then
                            for _, g in ipairs(comp.spawnedGroups) do
                                if g and g:IsAlive() then
                                    local dcsGroup = g:GetDCSObject()
                                    if dcsGroup then
                                        local controller = dcsGroup:getController()
                                        if controller then
                                            -- Radars OFF (Go Dark)
                                            controller:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.GREEN)
                                            -- Hold Fire until the trap is sprung
                                            controller:setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.WEAPON_HOLD)
                                            -- Enable Evasion of Anti-Radiation Missiles (Shoot and Scoot / Reposition)
                                            controller:setOption(AI.Option.Ground.id.EVASION_OF_ARM, true) 
                                        end
                                    end
                                end
                            end
                        end
                        env.info(string.format("TCS(CIC.CONTROLLER): Upgraded AirDef at zone %s to Ambush/Shoot-and-Scoot.", zoneId))
                    end
                end
            end
        end
    end
end

timer.scheduleFunction(function(_, t) return TCS.CIC.Controller:MonitorTaskings() end, nil, timer.getTime() + 300)

-- Start the high-frequency evaluation loop
timer.scheduleFunction(function(_, t) return TCS.CIC.Controller:EvaluateDeployments() end, nil, timer.getTime() + 10)
timer.scheduleFunction(function(_, t) TCS.CIC.Controller:EvaluateSensors(); return timer.getTime() + 2 end, nil, timer.getTime() + 2)

env.info("TCS(CIC.CONTROLLER): ready")