---------------------------------------------------------------------
-- TCS COMMON: TRACKER
-- The Monitor: Tracks group health and success criteria.
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Common = TCS.Common or {}
TCS.Common.Tracker = { Tasks = {} }

--- Registers a mission environment for status monitoring.
function TCS.Common.Tracker.Monitor(session, envSpec, spawnedObjects)
    local taskId = #TCS.Common.Tracker.Tasks + 1
    local task = {
        Id = taskId,
        Session = session,
        Spec = envSpec,
        Groups = spawnedObjects,
        InitialStrength = 0,
        Status = "ACTIVE",
        StartTime = timer.getTime()
    }

    -- Record initial unit counts for attrition math
    for _, g in ipairs(spawnedObjects) do
        if g and g:IsAlive() then
            task.InitialStrength = task.InitialStrength + g:GetSize()
        end
    end

    TCS.Common.Tracker.Tasks[taskId] = task
    env.info(string.format("TCS(TRACKER): Registered Task %d for %s", taskId, envSpec.missionType))
    return taskId
end

--- Evaluates task status against success criteria.
function TCS.Common.Tracker.Update()
    for id, task in pairs(TCS.Common.Tracker.Tasks) do
        local current = 0
        for _, g in ipairs(task.Groups) do
            if g and g:IsAlive() then current = current + g:GetSize() end
        end

        -- Evaluate Criteria
        for _, criteria in ipairs(task.Spec.successCriteria or {}) do
            if criteria.type == "ATTRITION" then
                local loss = 1.0 - (current / (task.InitialStrength > 0 and task.InitialStrength or 1))
                if loss >= criteria.threshold then
                    task.Status = criteria.result or "COMPLETE"
                    TCS.Common.Tracker.ResolveResult(task)
                end
            end
        end
        
        -- Remove finished tasks
        if task.Status ~= "ACTIVE" then TCS.Common.Tracker.Tasks[id] = nil end
    end
    return timer.getTime() + 15
end

--- Triggers consequences based on task result (e.g., Routing/Retreat).
function TCS.Common.Tracker.ResolveResult(task)
    local msg = string.format("%s: %s", task.Spec.missionType, task.Status)
    if task.Session then task.Session:Broadcast(msg, 10) end
    
    -- Tactical Leapfrog: Move Mobile Air Defense forward on victory
    if (task.Status == "COMPLETE" or task.Status == "ENEMY_ROUTED") and task.Session.MobileSAMs then
        local targetVec2 = task.Spec.anchor:GetVec2()
        for _, g in ipairs(task.Session.MobileSAMs) do
            if g and g:IsAlive() then
                env.info(string.format("TCS(TRACKER): Victory achieved. Advancing Mobile SAM %s to new objective.", g:GetName()))
                -- Move at a standard tactical speed (30 KPH)
                g:TaskRouteToVec2(targetVec2, 30/3.6, "On Road")
            end
        end
    end

    if task.Status == "ENEMY_ROUTED" and #task.Groups > 0 then
        local firstGrp = task.Groups[1]
        local retreatPt = TCS.Towers.Ground.Behavior and TCS.Towers.Ground.Behavior.GetRetreatPoint(task.Spec.anchor, firstGrp:GetCoordinate())
        local vec2 = retreatPt.GetVec2 and retreatPt:GetVec2() or { x = retreatPt.x, y = retreatPt.z or retreatPt.y }
        for _, g in ipairs(task.Groups) do
            if g and g:IsAlive() then
                g:TaskRouteToVec2(vec2, 40/3.6, "On Road")
            end
        end
    end
end

timer.scheduleFunction(TCS.Common.Tracker.Update, nil, timer.getTime() + 15)