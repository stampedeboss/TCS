---------------------------------------------------------------------
-- TCS COMMON: ARCHITECT UTILITIES
-- Universal Geometry, Terrain Validation, and Dispatch Engine (Phases 3 & 4)
---------------------------------------------------------------------
env.info("TCS(COMMON.ARCHITECT): loading")

TCS = TCS or {}
TCS.Architect = TCS.Architect or {}

function TCS.Architect.FinalizePayload(envSpec, params)
    if not envSpec or not envSpec.components or #envSpec.components == 0 then
        return nil
    end

    local anchor = envSpec.anchor
    local minNm = params.minNm or 0
    local maxNm = params.maxNm or 0
    local hdgRad = params.ingressHdg and math.rad(params.ingressHdg) or (math.random(0, 359) * math.pi / 180)
    local arc = params.ingressArc or 360
    
    -- 1. Determine primary domain to enforce terrain rules (e.g. SAMs go on LAND)
    local primaryDomain = envSpec.components[1].tower or "LAND"
    if primaryDomain == "AIRDEF" or primaryDomain == "LOGISTICS" then primaryDomain = "LAND" end
    if primaryDomain == "MARITIME" then primaryDomain = "SEA" end

    local deployCenter = anchor

    if maxNm > 0 then
        if TCS.Architect.Placements and TCS.Architect.Placements.SolveCoordinate then
            -- Ask the placement engine to find a terrain-valid coordinate inside the Kill Box
            local solved = TCS.Architect.Placements.SolveCoordinate({
                anchor = anchor, 
                minNm = minNm, 
                maxNm = maxNm, 
                ingressHdg = params.ingressHdg, 
                ingressArc = arc, 
                domain = primaryDomain
            })
            if solved then deployCenter = COORDINATE:NewFromVec3(solved)
            else env.warning("TCS(ARCHITECT): Valid terrain not found. Falling back to raw geometry.") end
        end
        -- Fallback if placements failed or wasn't loaded
        if deployCenter == anchor then 
            local fallbackHdgDeg = params.ingressHdg or math.random(0, 359)
            local dMin = math.floor(minNm * 1852)
            local dMax = math.floor(maxNm * 1852)
            if dMin > dMax then dMin, dMax = dMax, dMin end
            deployCenter = anchor:Translate(math.random(dMin, dMax), fallbackHdgDeg) 
        end
    end

    local centerVec = deployCenter:GetVec3()

    -- 2. Translate Relative Placements to Absolute Coordinates
    for _, comp in ipairs(envSpec.components) do
        if comp.manifest then
            for _, item in ipairs(comp.manifest) do
                local rel = item.relativePos or {x=0, y=0}
                -- Rotate relative Cartesian offsets by the deployment heading
                local rx = rel.x * math.cos(hdgRad) - rel.y * math.sin(hdgRad)
                local ry = rel.x * math.sin(hdgRad) + rel.y * math.cos(hdgRad)
                
                -- Apply Cartesian offsets directly to the Vec3 to avoid MOOSE polar translation bugs
                item.pos = { x = centerVec.x + rx, y = centerVec.z + ry }
                item.heading = hdgRad + (item.relativeHdg or 0)
            end
        end
    end

    -- 3. Pass fully resolved Manifest to CIC for Physical Spawning
    local spawnedObjects = {}
    if TCS.CIC and TCS.CIC.Spawner and TCS.CIC.Spawner.Execute then spawnedObjects = TCS.CIC.Spawner.Execute(envSpec) end

    -- 3.5 Apply Post-Spawn Behaviors (Waypoints and MOOSE Tasks)
    for _, comp in ipairs(envSpec.components) do
        if comp.behavior and comp.spawnedGroups then
            for _, group in ipairs(comp.spawnedGroups) do
                if group and group:IsAlive() then
                    
                    -- Apply Silent / Ambush Rules (Start completely dark)
                    if comp.behavior.silentDistance and comp.behavior.silentDistance ~= -1 then
                        local ctrl = group:GetController()
                        if ctrl then
                            -- Radar Off, Hold Fire
                            ctrl:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.GREEN)
                            ctrl:setOption(AI.Option.Naval.id.ROE, AI.Option.Naval.val.ROE.WEAPON_HOLD)
                        end
                    end
                    
                    -- Standard Waypoint Routing
                    if comp.behavior.target then
                        local speedKph = comp.behavior.speedKph or (comp.tower == "AIR" and 700 or 30)
                        if comp.tower == "AIR" then
                            local alt = comp.manifest and comp.manifest[1] and comp.manifest[1].alt or 6000
                            local vec3 = comp.behavior.target.GetVec3 and comp.behavior.target:GetVec3() or { x = comp.behavior.target.x, y = alt, z = comp.behavior.target.z or comp.behavior.target.y }
                            vec3.y = alt -- Force aircraft to fly at assigned altitude
                            group:TaskRouteToVec3(vec3, speedKph / 3.6)
                        else
                            local routeMode = (comp.tower == "LAND") and "On Road" or nil
                            local vec2 = comp.behavior.target.GetVec2 and comp.behavior.target:GetVec2() or { x = comp.behavior.target.x, y = comp.behavior.target.z or comp.behavior.target.y }
                            group:TaskRouteToVec2(vec2, speedKph / 3.6, routeMode)
                        end
                    end
                    
                    -- MOOSE Escort Tasking
                    if comp.behavior.mode == "ESCORT" and comp.behavior.escortTargetIndex then
                        local targetComp = envSpec.components[comp.behavior.escortTargetIndex]
                        if targetComp and targetComp.spawnedGroups and targetComp.spawnedGroups[1] then
                            local vipGroup = targetComp.spawnedGroups[1]
                            -- offset: {x=back/fwd, y=high/low, z=right/left}
                            group:TaskEscort(vipGroup, {x=500, y=500, z=500})
                        end
                    end
                end
            end
        end
    end

    -- 4. Centralized Registration & F10 Drawing
    local zoneName = type(params.anchor) == "string" and params.anchor or nil
    local zoneId = zoneName or string.format("Z_%s_%d", envSpec.missionType, math.random(1000, 9999))
    
    if TCS.CIC and TCS.CIC.ZoneManager then TCS.CIC.ZoneManager.RegisterZone(zoneId, anchor) end
    if TCS.CIC and TCS.CIC.Controller and TCS.CIC.Controller.RegisterDeployment then TCS.CIC.Controller:RegisterDeployment(zoneId, envSpec, spawnedObjects) end
    if TCS.Signals and TCS.Signals.F10 then TCS.Signals.F10.Draw(zoneId, envSpec.missionType, anchor, params.echelon, 5000, zoneName, params.ingressHdg, params.ingressArc) end

    return spawnedObjects
end
env.info("TCS(COMMON.ARCHITECT): ready")