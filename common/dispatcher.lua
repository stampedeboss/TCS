---------------------------------------------------------------------
-- TCS COMMON DISPATCHER
-- The Executor: Performs the physical spawn and tracking registration.
---------------------------------------------------------------------
env.info("TCS(COMMON.DISPATCHER): loading")

TCS = TCS or {}
TCS.Common = TCS.Common or {}
TCS.Common.Dispatcher = {}

--- Takes an Environment Spec and dispatches all physical units.
function TCS.Common.Dispatcher.Execute(envSpec, params)
    local session = params.session or TCS.Common.SessionManager:Ensure("SYSTEM")
    local spawnedObjects = {}

    if trigger.misc.getUserFlag(285000) <= 9 then
        session:Broadcast(string.format("TCS: Fulfilling %s requisition...", envSpec.missionType or "Task"), 5)
    end
    env.info("TCS(DISPATCHER): Executing environment for " .. (envSpec.missionType or "UNKNOWN"))

    -- REQUISITION AUDIT: Log manifest contents for tracking
    for i, req in ipairs(envSpec.components) do
        for j, item in ipairs(req.manifest or {}) do
            local typeLabel = (item.types and #item.types > 0) and table.concat(item.types, "/") or "N/A"
            local roleLabel = item.role or "GENERIC"
            local count = item.count or 0
            local id = item.id or "N/A"
            env.info(string.format("TCS(AUDIT): Requisition [%d] Item [%d] -> Role: %s, Type: %s, Count: %d, ID: %s", i, j, roleLabel, typeLabel, count, id))
        end
    end

    for _, requisition in ipairs(envSpec.components) do
        local groups = {}
        
        -- Fulfill Requisitions based on Tower type
        if requisition.tower == "GROUND" and TCS.Common.Spawner.SpawnGround then
            groups = TCS.Common.Spawner.SpawnGround(session, requisition)
        elseif requisition.tower == "AIRDEF" and TCS.Common.Spawner.SpawnAirDef then
            groups = TCS.Common.Spawner.SpawnAirDef(session, requisition)
        elseif requisition.tower == "AIR" and TCS.Common.Spawner.SpawnAir then
            groups = TCS.Common.Spawner.SpawnAir(session, requisition)
        elseif requisition.tower == "MARITIME" and TCS.Common.Spawner.SpawnMaritime then
            groups = TCS.Common.Spawner.SpawnMaritime(session, requisition)
        end

        if groups then
            for _, g in ipairs(groups) do table.insert(spawnedObjects, g) end
        end
    end

    -- Register for Tracking & Success Monitoring
    return TCS.Common.Tracker and TCS.Common.Tracker.Monitor(session, envSpec, spawnedObjects)
end

env.info("TCS(COMMON.DISPATCHER): ready")