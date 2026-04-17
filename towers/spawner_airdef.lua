---------------------------------------------------------------------
-- TCS COMMON: AIRDEF SPAWNER
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Common = TCS.Common or {}
TCS.Common.Spawner = TCS.Common.Spawner or {}

function TCS.Common.Spawner.SpawnAirDef(session, requisition)
    local spawnedGroups = {}
    local baseCoord = requisition.geometry.anchor
    if not baseCoord then return {} end

    for i, groupCfg in ipairs(requisition.manifest or {}) do
        local off = groupCfg.offset or { x=0, y=0, hdg=0 }
        
        -- Calculate doctrinal position relative to base anchor
        local finalPos = baseCoord:Translate(off.x, 0):Translate(off.y, 90)
        
        local groupName = string.format("TCS_AD_%s_%d", session.Name or "SYS", math.random(1000, 9999))
        local opts = {
            name = groupName,
            coalition = requisition.coalition,
            heading = off.hdg,
            skill = "High"
        }

        local group = TCS.Common.Spawn.Group(groupCfg.types, finalPos, opts, "GROUND", 1)
        if group then
            table.insert(spawnedGroups, group)
        end
    end
    return spawnedGroups
end

env.info("TCS(COMMON.SPAWNER.AIRDEF): ready")