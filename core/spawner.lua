---------------------------------------------------------------------
-- TCS CORE: SPAWNER
-- The General: Spawns units from translated blueprints.
---------------------------------------------------------------------
env.info("TCS(CORE.SPAWNER): loading")

TCS = TCS or {}
TCS.Spawner = {}

--- Spawns a group of units based on a translated blueprint.
-- @param recipe table The full recipe from a Specialist Architect (e.g., Ground Tower).
-- @param zoneId string|number The ID of the zone this spawn belongs to.
-- @return table A table of spawned MOOSE Group objects.
function TCS.Spawner.SpawnFromBlueprint(recipe, zoneId)
    if not recipe or not recipe.geometry then
        env.error("TCS(SPAWNER): Invalid recipe provided. Cannot spawn.")
        return {}
    end

    -- 1. Resolve the geometric constraints to find the final spawn anchor and ingress heading
    local spawnAnchor, ingressHdgRad = TCS.Architect.ResolveAnchorPoint(recipe.geometry)
    if not spawnAnchor then
        env.error("TCS(SPAWNER): Could not resolve spawn anchor point from recipe geometry.")
        return {}
    end

    -- 2. Translate the relative blueprint into absolute world coordinates using the resolved anchor
    local absoluteLocations = TCS.Architect.TranslateBlueprint(
        recipe.blueprint or {{x=0, y=0}}, -- Default to a single unit if no blueprint
        spawnAnchor,
        ingressHdgRad
    )

    if #absoluteLocations == 0 then
        env.error("TCS(SPAWNER): Blueprint translation resulted in zero locations.")
        return {}
    end

    local spawnedGroups = {}
    local groupName = string.format("TCS-%s-%s-%d", recipe.tower or "GEN", zoneId or "Z1", math.random(1000, 9999))
    local coalitionId = recipe.coalition or coalition.side.RED
    local skill = recipe.skill or "High"
    local targetPool = recipe.targetPool or {"BTR-80"}
    local groupCategory = recipe.category or Group.Category.GROUND_UNIT

    -- 3. Prepare the group data for spawning a single group
    local groupData = { name = groupName, units = {} }

    for i, loc in ipairs(absoluteLocations) do
        local unitType = targetPool[((i-1) % #targetPool) + 1] -- Cycle through the target pool
        table.insert(groupData.units, {
            name = groupName .. "-" .. i,
            type = unitType,
            x = loc.coord.x,
            y = loc.coord.z, -- MOOSE uses .z for map Y
            heading = ingressHdgRad,
            skill = skill
        })
    end

    -- 4. Spawn the group
    local newGroup = coalition.addGroup(coalitionId, groupCategory, groupData)
    if newGroup and newGroup:IsAlive() then
        env.info(string.format("TCS(SPAWNER): Spawned group '%s' with %d units.", groupName, #groupData.units))
        table.insert(spawnedGroups, newGroup)

        -- 5. Register with the CIC Tracker for monitoring
        if TCS.CIC and TCS.CIC.Tracker and recipe.successCriteria then
            TCS.CIC.Tracker.Monitor(zoneId, recipe, {newGroup})
        end

        -- 6. Apply post-spawn behavior
        if recipe.behavior then
            if recipe.behavior.mode == "ADVANCE" and recipe.behavior.target then
                TCS.CIC.Director.ExecuteAdvance({newGroup}, recipe.behavior.target)
            end
            
            -- Enforce Rules of Engagement and Alarm State
            local dcsGroup = Group.getByName(groupName)
            if dcsGroup then
                local controller = dcsGroup:getController()
                if controller then
                    if recipe.behavior.roe == "WEAPON_HOLD" then
                        controller:setOption(AI.Option.Naval.id.ROE, AI.Option.Naval.val.ROE.WEAPON_HOLD)
                    end
                    if recipe.behavior.alarmState == "GREEN" then
                        controller:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.GREEN)
                    end
                end
            end
        end
    else
        env.error("TCS(SPAWNER): Failed to spawn group '" .. groupName .. "'.")
    end

    return spawnedGroups
end

env.info("TCS(CORE.SPAWNER): ready")