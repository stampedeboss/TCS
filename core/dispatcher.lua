---------------------------------------------------------------------
-- TCS CORE DISPATCHER
-- The Executor: Performs the physical spawn and tracking registration.
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
env.info("TCS(CORE.DISPATCHER): loading")

TCS = TCS or {}
TCS.Core = TCS.Core or {}
TCS.Core.Dispatcher = {}

--- Takes an Environment Spec and dispatches all physical units.
function TCS.Core.Dispatcher.Execute(envSpec, params)
    local session = params.session or TCS.SessionManager:Ensure("SYSTEM")
    local spawnedObjects = {}

    env.info("TCS(DISPATCHER): Executing environment for " .. envSpec.taskType)

    for _, recipe in ipairs(envSpec.components) do
        local groups = nil
        
        -- Physical Spawning based on Tower type
        if recipe.tower == "GROUND" then
            groups = TCS.A2G.ForceSpawner.Spawn(session, recipe.forceName, recipe.echelon, envSpec.anchor, params)
        elseif recipe.tower == "AIR" then
            local alias = string.format("%s_%s", envSpec.taskType, recipe.role)
            local spawnCoord = envSpec.anchor -- Simplified: In practice, Air Tower would provide offset
            local heading = 0
            
            TCS.A2A.SpawnBandit(session, recipe.data, alias, spawnCoord, heading, function(mooseGroup)
                if mooseGroup then
                    table.insert(spawnedObjects, mooseGroup)
                    -- Apply behavior logic (Intercept, Orbit, etc)
                end
            end)
            -- Note: Since SpawnBandit is asynchronous due to potential SCHEDULER use in core, 
            -- tracking registration may need a slight delay or callback-based monitor.
        end

        if groups then
            for _, g in ipairs(groups) do table.insert(spawnedObjects, g) end
        end
    end

    -- Register for Tracking & Success Monitoring
    return TCS.Core.Tracker.Monitor(session, envSpec, spawnedObjects)
end

env.info("TCS(CORE.DISPATCHER): ready")