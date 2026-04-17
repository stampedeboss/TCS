---------------------------------------------------------------------
-- TCS TOWER: GROUND BEHAVIOR
-- Tactical specialist for ground unit AI and movement.
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.Ground = TCS.Towers.Ground or {} -- Ensure parent table exists
TCS.Towers.Ground.Behavior = {}

--- Applies tactical behavior to a spawned ground group.
function TCS.Towers.Ground.Behavior.ApplyBehavior(group, behavior)
    if not group then return end

    -- 1. Standard Posture
    group:OptionROE(ENUMS.ROE.WeaponFree)
    group:OptionAlarmStateRed()

    -- 2. Movement Logic
    if behavior.mode == "ADVANCE" or behavior.mode == "CONVERGE" then
        local targetCoord = behavior.target
        if targetCoord then
            local speedMs = (behavior.speedKph or 25) / 3.6
            local routeMode = behavior.onRoad and "On Road" or "Off Road"
            
            -- Defensive check: Handle both MOOSE Coordinate objects and raw vec3 tables
            local vec2 = targetCoord.GetVec2 and targetCoord:GetVec2() or { x = targetCoord.x, y = targetCoord.z or targetCoord.y }
            
            env.info(string.format("TCS(GROUND.BEHAVIOR): Tasking %s to %s at %.1f KPH (%s)", group:GetName(), behavior.mode, (behavior.speedKph or 25), routeMode))
            group:TaskRouteToVec2(vec2, speedMs, routeMode)
        end
    end

    -- 3. Special Postures
    if behavior.mode == "DEFEND" then
        group:OptionAlarmStateRed()
        -- Implementation for local picket/patrol logic could go here
    end
end

--- Calculates the retreat point for a routing force.
function TCS.Towers.Ground.Behavior.GetRetreatPoint(anchor, spawnAnchor)
    local dir = anchor:HeadingTo(spawnAnchor) or 0
    return anchor:Translate(15000, dir)
end

env.info("TCS(TOWER.GROUND.BEHAVIOR): ready")