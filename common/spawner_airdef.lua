---------------------------------------------------------------------
-- TCS COMMON: AIRDEF SPAWNER
-- Handles doctrinal placement of SAM components.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Common = TCS.Common or {}
TCS.Common.Spawner = TCS.Common.Spawner or {}

function TCS.Common.Spawner.SpawnAirDef(session, requisition)
    local spawnedGroups = {}
    local spawnCoord = requisition.geometry.anchor
    if not spawnCoord or type(spawnCoord) ~= "table" then return {} end

    -- World-Class Placement: Always apply jitter within the radius to prevent battery stacking
    local g = requisition.geometry
    if g.maxNm and g.maxNm > 0 then
        spawnCoord, _ = TCS.Common.Geometry.GetDirectionalPoint(spawnCoord, g.minNm, g.maxNm, g.ingressHdg, g.ingressArc)
    end

    for i, groupCfg in ipairs(requisition.manifest or {}) do
        local off = groupCfg.offset or { x=0, y=0, hdg=0 }
        
        -- Calculate doctrinal position relative to the resolved anchor
        local finalPos = spawnCoord:Translate(off.x, 0):Translate(off.y, 90)
        
        local groupName = string.format("TCS_AD_%s_%d", session.Name or "SYS", math.random(1000, 9999))
        local opts = {
            name = groupName,
            coalition = requisition.coalition or 1,
            heading = off.hdg,
            skill = "High",
            role = groupCfg.role
        }

        -- Spawning as GROUND (instead of STRUCTURE) provides the AI controller 
        -- required for ROE and Radar Silence (Alarm State) logic.
        local group = TCS.Common.Spawn.Group(groupCfg.types, finalPos, opts, "GROUND", groupCfg.count)
        if group then
            table.insert(spawnedGroups, group)
            
            -- If mobile, register with the session for dynamic movement on victory
            if requisition.isMobile then
                session.MobileSAMs = session.MobileSAMs or {}
                table.insert(session.MobileSAMs, group)
            end

            -- Ensure Combat Readiness (Missing in previous version)
            timer.scheduleFunction(function()
                group:OptionROE(ENUMS.ROE.WeaponFree)
                group:OptionAlarmStateRed()
            end, nil, timer.getTime() + 1)

            -- Resolve Ambush Behavior: Toggle Radar based on Player Proximity
            local silentNM = requisition.behavior.silentDistance
            if silentNM and silentNM > 0 then
                timer.scheduleFunction(function()
                    if not group or not group:IsAlive() then return end
                    group:OptionAlarmStateGreen() -- Start Dark

                    local ambushScheduler
                    ambushScheduler = SCHEDULER:New(nil, function()
                        if not group or not group:IsAlive() then 
                            if ambushScheduler then ambushScheduler:Stop() end
                            return 
                        end
                        
                        local radarPos = group:GetCoordinate()
                        for name, _ in pairs(session.Members or {}) do
                            local pGroup = GROUP:FindByName(name)
                            if pGroup and pGroup:IsAlive() and pGroup:GetCoordinate() then
                                local dist = radarPos:Get2DDistance(pGroup:GetCoordinate()) / 1852
                                if dist < silentNM then
                                    group:OptionAlarmStateRed() -- Ambush!
                                    ambushScheduler:Stop()
                                    break
                                end
                            end
                        end
                    end, {}, 5, 10)
                end, nil, timer.getTime() + 2)
            end
        end
    end
    return spawnedGroups
end

env.info("TCS(COMMON.SPAWNER.AIRDEF): ready")