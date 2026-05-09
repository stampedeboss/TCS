---------------------------------------------------------------------
-- TCS DEPLOY: SPAWNER
-- The General: Spawns units from translated blueprints.
---------------------------------------------------------------------
env.info("TCS(DEPLOY.SPAWNER): loading")

TCS = TCS or {}
TCS.Spawner = {}
TCS.Spawner.CountryCache = {}

-- 2. Helper function to sanitize group data before sending to DCS
local function SanitizeBlueprint(groupData, category)
    if category == Group.Category.AIRPLANE or category == Group.Category.HELICOPTER then
        groupData.task = groupData.task or "CAP"
        groupData.communication = true
        if groupData.route and groupData.route.points and #groupData.route.points > 0 and groupData.units and groupData.units[1] then
            local spawnAlt = groupData.units[1].alt or 2000
            for _, pt in ipairs(groupData.route.points) do
                pt.alt = spawnAlt
                pt.alt_type = groupData.units[1].alt_type or "BARO"
            end
        end
    end
    return groupData
end

--- Spawns a group of units based on a translated blueprint.
-- @param recipe table The full recipe from a Specialist Architect (e.g., Ground Tower).
-- @param zoneId string|number The ID of the zone this spawn belongs to.
-- @return table A table of spawned MOOSE Group objects.
function TCS.Spawner.SpawnFromBlueprint(recipe, zoneId)
    TCS.Logger.trace("SpawnFromBlueprint Initiated for zone: %s", tostring(zoneId))
    TCS.Logger.trace("Recipe Manifest:")
    TCS.Logger.info(recipe)

    if not recipe or not recipe.geometry then
        TCS.Logger.error("TCS(SPAWNER): Invalid recipe provided. Cannot spawn. Missing geometry.")
        return {}
    end

    -- 1. Resolve the geometric constraints to find the final spawn anchor and ingress heading
    local spawnAnchor, ingressHdgRad = TCS.Dispatcher.ResolveAnchorPoint(recipe.geometry)
    if not spawnAnchor then
        TCS.Logger.error("TCS(SPAWNER): Could not resolve spawn anchor point from recipe geometry.")
        return {}
    end
    
    -- Fallback to 0 (North) if no ingress heading is provided (e.g., static SAM sites)
    ingressHdgRad = ingressHdgRad or 0
    TCS.Logger.trace("Geometric constraints resolved. Anchor found.")

    -- 2. Translate the relative blueprint into absolute world coordinates using the resolved anchor
    local absoluteLocations = TCS.Dispatcher.TranslateBlueprint(
        recipe.blueprint or {{x=0, y=0}}, -- Default to a single unit if no blueprint
        spawnAnchor,
        ingressHdgRad
    )

    if #absoluteLocations == 0 then
        TCS.Logger.error("TCS(SPAWNER): Blueprint translation resulted in zero locations.")
        return {}
    end
    TCS.Logger.trace("Blueprint translated into %d absolute locations.", #absoluteLocations)

    local spawnedGroups = {}
    local groupName = string.format("TCS-%s-%s-%d", recipe.tower or "GEN", zoneId or "Z1", math.random(1000, 9999))
    local coalitionId = recipe.coalition or coalition.side.RED
    local skill = recipe.skill or "High"
    local targetPool = recipe.targetPool or {"BTR-80"}
    local groupCategory = recipe.category or Group.Category.GROUND

    -- 1. DCS Native addGroup requires Country ID, not Coalition ID
    local countryId = TCS.Spawner.CountryCache[coalitionId]
    if not countryId then
        countryId = (coalitionId == coalition.side.RED) and country.id.RUSSIA or country.id.USA
        for _, cId in pairs(country.id) do
            if coalition.getCountryCoalition(cId) == coalitionId then
                countryId = cId
                if cId == country.id.CJTF_RED or cId == country.id.CJTF_BLUE or cId == country.id.RUSSIA or cId == country.id.USA then
                    break
                end
            end
        end
        TCS.Spawner.CountryCache[coalitionId] = countryId
    end

    -- 3. Prepare the group data for spawning a single group
    local groupData = { 
        name = groupName, 
        units = {},
        route = { 
            points = { 
                [1] = { x = spawnAnchor.x, y = spawnAnchor.z, alt = 2000, type = "Turning Point", action = "Turning Point" },
                [2] = { x = spawnAnchor.x + (math.cos(ingressHdgRad) * 10000), y = spawnAnchor.z + (math.sin(ingressHdgRad) * 10000), alt = 2000, type = "Turning Point", action = "Turning Point" }
            } 
        }
    }

    for i, loc in ipairs(absoluteLocations) do
        local meta = loc.metadata or {}
        local poolEntry = targetPool[((i-1) % #targetPool) + 1] 
        
        local unitType = meta.unitType or meta.unit_type or meta.type
        local payload = meta.payload
        local unitSkill = meta.skill or skill
        
        if not unitType then
            if type(poolEntry) == "table" then
                unitType = poolEntry.unit_type or poolEntry.type
                payload = payload or poolEntry.payload
                unitSkill = poolEntry.skill or unitSkill
            else
                unitType = poolEntry
            end
        end
        
        -- DCS requires a callsign for MOOSE FLIGHTGROUP to initialize properly.
        local unitCallsign
        if coalitionId == coalition.side.RED then
            unitCallsign = 100 + i -- Russian format (101, 102, etc.)
        else
            unitCallsign = {1, 1, i, name="Enfield1"..i} -- Western format
        end
        
        local unitDef = {
            name = groupName .. "-" .. i,
            type = unitType,
            x = loc.coord.x,
            y = loc.coord.z, -- MOOSE uses .z for map Y
            heading = meta.heading or meta.hdg or ingressHdgRad,
            skill = unitSkill,
            payload = payload
        }
        
        -- Apply altitude and speed for airborne units
        if groupCategory == Group.Category.AIRPLANE or groupCategory == Group.Category.HELICOPTER then
            -- loc.coord.y inherits the pilot's altitude if generated dynamically, or 0 if a flat map Zone
            local alt = loc.coord.y
            
            if recipe.geometry.alt then
                alt = recipe.geometry.alt -- Explicit override from API parameters
            elseif alt < 100 then
                alt = (groupCategory == Group.Category.AIRPLANE) and 6096 or 500 -- Default 20k ft / ~1.5k ft
            end
            
            -- Safety clamp: Enforce minimum altitude for jets so low-level players don't spawn bandits into trees
            if groupCategory == Group.Category.AIRPLANE and alt < 1500 then alt = 6096 end
            
            unitDef.alt = alt
            unitDef.alt_type = "BARO"
            unitDef.speed = (groupCategory == Group.Category.AIRPLANE) and 180 or 50 -- Spawning speed (m/s) to prevent stalls
            unitDef.callsign = unitCallsign
        end
        
        if meta.isStatic then
            local staticData = {
                name = groupName .. "-Pad-" .. i,
                type = unitType,
                x = loc.coord.x,
                y = loc.coord.z,
                heading = meta.heading or meta.hdg or ingressHdgRad,
                category = meta.staticCategory or "Heliports",
                dead = false
            }
            coalition.addStaticObject(countryId, staticData)
        else
            table.insert(groupData.units, unitDef)
        end
    end

    TCS.Logger.trace("Dispatching groupData to DCS Engine for spawn: %s", groupName)
    TCS.Logger.info(groupData)

    -- 4. Behavior Initializer (Crucial for dynamic respawns like CAP pools)
    local function InitGroupBehaviors(grp)
        if not grp or not grp:IsAlive() then return end
        local currentGroupName = grp:GetName()
        
        -- 5. Register with the CIC Tracker for monitoring
        if TCS.CIC and TCS.CIC.Tracker and recipe.successCriteria then
            TCS.CIC.Tracker.Monitor(zoneId, recipe, {grp})
        end

        -- 6. Apply post-spawn behavior
        if recipe.behavior then
            if recipe.behavior.mode == "ADVANCE" and recipe.behavior.target then
                if TCS.CIC.Director then TCS.CIC.Director.ExecuteAdvance({grp}, recipe.behavior.target) end
            end
            
            -- Enforce Rules of Engagement and Alarm State
            local dcsGroup = grp:GetDCSObject()
            if dcsGroup then
                local controller = dcsGroup:getController()
                if controller then
                    if recipe.behavior.roe == "WEAPON_HOLD" then
                        controller:setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.WEAPON_HOLD)
                    end
                    if recipe.behavior.alarmState == "GREEN" then
                        controller:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.GREEN)
                    end
                end
            end
        end

        -- 7. Apply Air-specific flight tasks
        if groupCategory == Group.Category.AIRPLANE then
            local ok, flightGroup = pcall(function() return FLIGHTGROUP:New(currentGroupName) end)
            if ok and flightGroup then
                grp:SetOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_FREE)
                grp:SetOption(AI.Option.Air.id.RTB_ON_OUT_OF_AMMO, false) -- Prevent instant RTB if spawned clean
                grp:SetOption(AI.Option.Air.id.AC_ENGAGE_RANGE, 40000) -- 40km engage range

                -- Hook into the Flight Manager for AWACS and Retreat logic
                if TCS.Air and TCS.Air.FlightManager and TCS.Air.FlightManager.Attach and not recipe.FlightManagerAttached then
                    TCS.Air.FlightManager.Attach(recipe, {grp})
                    recipe.FlightManagerAttached = true
                end

                if recipe.missionType == "CAP" then
                    local capZone = ZONE_RADIUS:New("CAP_ZONE_" .. zoneId, {x = spawnAnchor.x, y = spawnAnchor.z}, 20 * 1852) -- 20NM Radius CAP
                    
                    -- AUFTRAG:NewCAP(Zone, AltMin, AltMax, Speed, SpeedEngage, EngageZone)
                    -- Passing capZone as the EngageZone restricts the AI to only chasing targets that enter this specific zone.
                    local capMission = AUFTRAG:NewCAP(capZone, nil, nil, nil, nil, capZone)
                    flightGroup:AddMission(capMission)
                    env.info(string.format("TCS(SPAWNER): Assigned CAP task to %s.", currentGroupName))
                elseif recipe.missionType == "SWEEP" then
                    local sweepZone = ZONE_RADIUS:New("SWEEP_ZONE_" .. zoneId, {x = spawnAnchor.x, y = spawnAnchor.z}, 30 * 1852) -- 30NM Radius Sweep
                    flightGroup:AddMission(AUFTRAG:NewSweep(sweepZone))
                    env.info(string.format("TCS(SPAWNER): Assigned SWEEP task to %s.", currentGroupName))
                elseif recipe.missionType == "INTERCEPT" then
                    if recipe.behavior and recipe.behavior.target then
                        flightGroup:AddMission(AUFTRAG:NewINTERCEPT(recipe.behavior.target))
                        env.info(string.format("TCS(SPAWNER): Assigned targeted INTERCEPT task to %s.", currentGroupName))
                    else
                        local interceptZone = ZONE_RADIUS:New("INT_ZONE_" .. zoneId, {x = spawnAnchor.x, y = spawnAnchor.z}, 40 * 1852)
                        flightGroup:AddMission(AUFTRAG:NewSweep(interceptZone)) -- Fallback to sweeping the anchor
                        env.info(string.format("TCS(SPAWNER): Assigned INTERCEPT (Sweep Fallback) task to %s.", currentGroupName))
                    end
                elseif recipe.missionType == "ESCORT" then
                    if recipe.behavior and recipe.behavior.target then
                        flightGroup:AddMission(AUFTRAG:NewESCORT(recipe.behavior.target))
                        env.info(string.format("TCS(SPAWNER): Assigned ESCORT task to %s.", currentGroupName))
                    else
                        env.warning(string.format("TCS(SPAWNER): ESCORT missing target. Flying standard route %s.", currentGroupName))
                    end
                end
            else
                TCS.Logger.error("TCS(SPAWNER): Failed to create MOOSE FLIGHTGROUP for %s. Error: %s", currentGroupName, tostring(flightGroup))
            end
        end

        -- 8. Apply Custom Triggers & Events
        if recipe.events then
            for eventName, callback in pairs(recipe.events) do
                if EVENTS and EVENTS[eventName] then
                    grp:HandleEvent(EVENTS[eventName])
                    grp["OnEvent" .. eventName] = function(self, EventData)
                        if callback then callback(self, EventData) end
                    end
                else
                    TCS.Logger.warn("TCS(SPAWNER): Unknown MOOSE event requested: " .. tostring(eventName))
                end
            end
        end
        
        if recipe.onSpawn then
            local ok, err = pcall(recipe.onSpawn, grp, recipe)
            if not ok then TCS.Logger.error("TCS(SPAWNER): onSpawn callback failed: " .. tostring(err)) end
        end
    end

    -- 8. Execution: Standard Spawn vs Managed Pool
    if #groupData.units > 0 then
        groupData = SanitizeBlueprint(groupData, groupCategory)

        local spawnSuccess, result = pcall(function()
            if recipe.maxAirframes and SPAWN then
                TCS.Logger.info("TCS(SPAWNER): Establishing managed overlapping pool for %s (Max: %d)", groupName, recipe.maxAirframes)
                
                local totalLosses = 0
                local maxLosses = recipe.maxAirframes
                local initialGroupSize = #groupData.units
                recipe.activeFlights = {} -- Track flights for early relief & handoffs
                
                local spawnObj = nil
                
                local function SpawnNextFlight()
                    if recipe.Terminated then return end
                    if totalLosses >= maxLosses then
                        TCS.Logger.info("TCS(SPAWNER): %s has exhausted its reserves! Halting reinforcements.", groupName)
                        return
                    end
                    if spawnObj then
                        local newGrp = spawnObj:Spawn()
                        if newGrp then
                            table.insert(recipe.activeFlights, newGrp)
                            TCS.Logger.info("TCS(SPAWNER): Dispatched replacement flight for %s.", groupName)
                        end
                    end
                end

                local function TriggerReplacement(grp, reason)
                    if recipe.Terminated then return end
                    if grp and grp.isReplaced then return end
                    if grp then grp.isReplaced = true end
                    TCS.Logger.info("TCS(SPAWNER): Flight %s needs replacement due to %s.", grp and grp:GetName() or groupName, reason)
                    
                    -- Delay spawn slightly to avoid DCS event queue hitches
                    timer.scheduleFunction(function() SpawnNextFlight() end, nil, timer.getTime() + 1)
                end

                -- Expose ForceRelief to external Controllers (e.g., Air Director)
                recipe.ForceRelief = function()
                    local currentGrp = recipe.activeFlights[#recipe.activeFlights]
                    if currentGrp and not currentGrp.isReplaced then
                        TriggerReplacement(currentGrp, "TACTICAL PRE-SCRAMBLE")
                    end
                end
                
                local function CheckHandoff(departingGrp)
                    if recipe.IntruderActive then
                        local reliefGrp = recipe.activeFlights[#recipe.activeFlights]
                        if reliefGrp and reliefGrp:IsAlive() and reliefGrp ~= departingGrp then
                            local ok, flightGroup = pcall(function() return FLIGHTGROUP:New(reliefGrp:GetName()) end)
                            if ok and flightGroup then
                                local sweepZone = ZONE_RADIUS:New("SWEEP_UPG_" .. reliefGrp:GetName(), {x = spawnAnchor.x, y = spawnAnchor.z}, 40 * 1852)
                                flightGroup:AddMission(AUFTRAG:NewSweep(sweepZone))
                                env.info("TCS(SPAWNER): Primary flight leaving station. Upgrading relief flight to SWEEP.")
                            end
                        end
                    end
                end

                local function RecordLoss(eventGrp, EventData)
                    if EventData.IniUnit then
                        local unitName = EventData.IniUnit:GetName()
                        eventGrp.lossTracked = eventGrp.lossTracked or {}
                        
                        -- Ensure we don't double-count a Crash and a Dead event for the same unit
                        if not eventGrp.lossTracked[unitName] then
                            eventGrp.lossTracked[unitName] = true
                            totalLosses = totalLosses + 1
                            recipe.totalLosses = totalLosses -- Export to Director
                            TCS.Logger.info("TCS(SPAWNER): %s lost an airframe. Total losses: %d / %d", groupName, totalLosses, maxLosses)
                            
                            local currentLosses = 0
                            for k,v in pairs(eventGrp.lossTracked) do currentLosses = currentLosses + 1 end
                            if currentLosses >= initialGroupSize then
                                CheckHandoff(eventGrp)
                                TriggerReplacement(eventGrp, "COMBAT LOSSES")
                            end
                        end
                    end
                end
                
                spawnObj = SPAWN:NewFromTemplate(groupData, groupName)
                    :InitCountry(countryId)
                    :InitCategory(groupCategory)
                    :InitLimit(50, 50) -- Cache up to 50, allow overlaps so replacements can launch before active RTBs
                    :OnSpawnGroup(function(grp)
                        -- Prevent behaviors from running on ghost/corrupt groups
                        if not grp or not grp:IsAlive() then return end
                        
                        table.insert(spawnedGroups, grp)
                        
                        timer.scheduleFunction(function(arg)
                            local g = arg[1]
                            if g and g:IsAlive() then InitGroupBehaviors(g) end
                        end, {grp}, timer.getTime() + 1)
                        
                        -- Track Attrition (Defeated in battle)
                        if EVENTS.Dead then grp:HandleEvent(EVENTS.Dead) end
                        if EVENTS.Crash then grp:HandleEvent(EVENTS.Crash) end
                        if EVENTS.BingoFuel then grp:HandleEvent(EVENTS.BingoFuel) end
                        if EVENTS.Land then grp:HandleEvent(EVENTS.Land) end
                        
                        function grp:OnEventDead(EventData) RecordLoss(self, EventData) end
                        function grp:OnEventCrash(EventData) RecordLoss(self, EventData) end
                        function grp:OnEventBingoFuel(EventData) CheckHandoff(self); TriggerReplacement(self, "BINGO FUEL") end
                        function grp:OnEventLand(EventData) TriggerReplacement(self, "LANDING") end
                    end)
                    
                -- Dispatch the initial flight manually
                SpawnNextFlight()
                
                return recipe.activeFlights[1] or spawnObj
            else
                coalition.addGroup(countryId, groupCategory, groupData)
                local newGroup = GROUP:FindByName(groupName)
                if newGroup and newGroup:IsAlive() then
                    TCS.Logger.info("TCS(SPAWNER): Successfully spawned group '%s' with %d units.", groupName, #groupData.units)
                    table.insert(spawnedGroups, newGroup)
                    
                    timer.scheduleFunction(function(arg)
                        local g = arg[1]
                        if g and g:IsAlive() then InitGroupBehaviors(g) end
                    end, {newGroup}, timer.getTime() + 1)
                    return newGroup
                else
                    return nil
                end
            end
        end)
        
        if not spawnSuccess or result == nil then
            TCS.Logger.error("TCS(SPAWNER): DCS Engine failed to spawn group '%s'. Invalid blueprint or unsupported unit type.", groupName)
            return nil
        end
        return result
    end

    return spawnedGroups
end

env.info("TCS(DEPLOY.SPAWNER): ready")
