---------------------------------------------------------------------
-- TCS COMMON: GROUND SPAWNER
-- Handles the physicalization of Ground Recipes.
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Common = TCS.Common or {}
TCS.Common.Spawner = TCS.Common.Spawner or {}

function TCS.Common.Spawner.SpawnGround(session, requisition)
    local spawnedGroups = {}
    
    -- 1. Resolve Entry Point Geometry (Architect has already resolved this to a Coordinate)
    local spawnCoord = requisition.geometry.anchor
    if not spawnCoord or type(spawnCoord) ~= "table" then return {} end

    -- Apply Directional Offset if required (Zone property or API override)
    if requisition.geometry.type == "DIRECTIONAL" then
        local g = requisition.geometry
        spawnCoord, _ = TCS.Common.Geometry.GetDirectionalPoint(spawnCoord, g.minNm, g.maxNm, g.ingressHdg, g.ingressArc)
    end

    -- 2. Fulfill the Requisition Manifest
    for i, groupCfg in ipairs(requisition.manifest or {}) do
        local groupName = string.format("TCS_%s_%s_%d_%d", session.Name or "SYS", requisition.forceType or "GRD", i, math.random(1000, 9999))
        local spawnOpts = {
            name = groupName,
            coalition = requisition.coalition or 1,
            skill = "Good",
            formation = groupCfg.formation or "WEDGE",
            spacing = requisition.spacing or 50,
            role = groupCfg.role
        }

        -- Offset this group relative to the spawnCoord to prevent unit stacking
        local r, a = TCS.Common.Geometry.GetStackingOffset(i, spawnOpts.spacing * 4)
        local finalPos = spawnCoord:Translate(r, a)

        env.info(string.format("TCS(SPAWNER.GROUND): Requesting spawn for %s (Count: %d) at %s", groupName, groupCfg.count, finalPos:ToStringMGRS()))
        local group = TCS.Common.Spawn.Group(groupCfg.types, finalPos, spawnOpts, "GROUND", groupCfg.count)
        if group then
            table.insert(spawnedGroups, group)
            
            -- Resolve Behavior Overrides (e.g. Infantry speed/offroad)
            local taskBehavior = {}
            for k,v in pairs(requisition.behavior) do taskBehavior[k] = v end
            if groupCfg.speed then taskBehavior.speedKph = groupCfg.speed end
            if groupCfg.onRoad ~= nil then taskBehavior.onRoad = groupCfg.onRoad end

            -- Delay behavior application to ensure DCS has fully registered the group
            timer.scheduleFunction(function()
                TCS.Towers.Ground.Behavior.ApplyBehavior(group, taskBehavior)
            end, nil, timer.getTime() + 1)
        end
    end

    return spawnedGroups
end

env.info("TCS(COMMON.SPAWNER.GROUND): ready")