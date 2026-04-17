---------------------------------------------------------------------
-- TCS COMMON: MARITIME SPAWNER
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Common = TCS.Common or {}
TCS.Common.Spawner = TCS.Common.Spawner or {}

function TCS.Common.Spawner.SpawnMaritime(session, requisition)
    local spawnedGroups = {}
    local anchor = requisition.geometry.anchor
    if not anchor then return {} end

    local spawnCoord, _ = TCS.Common.Geometry.GetDirectionalPoint(
        anchor, 
        requisition.geometry.minNm, 
        requisition.geometry.maxNm, 
        requisition.geometry.ingressHdg, 
        requisition.geometry.ingressArc
    )

    for i, groupCfg in ipairs(requisition.manifest or {}) do
        local groupName = string.format("TCS_MAR_%s_%d", session.Name or "SYS", math.random(1000, 9999))
        local opts = {
            name = groupName,
            coalition = requisition.coalition or 1,
            skill = "High",
            role = groupCfg.role
        }

        local group = TCS.Common.Spawn.Group(groupCfg.types, spawnCoord:Translate(i * 1000, 90), opts, "SHIP", groupCfg.count)
        if group then
            table.insert(spawnedGroups, group)
        end
    end
    return spawnedGroups
end

env.info("TCS(COMMON.SPAWNER.MARITIME): ready")