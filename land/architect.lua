---------------------------------------------------------------------
-- TCS LAND ARCHITECT
-- Director Layer: Assembles Land/A2G component requisitions.
---------------------------------------------------------------------
env.info("TCS(LAND.ARCHITECT): loading")

TCS = TCS or {}
TCS.Land = TCS.Land or {}
TCS.Land.Architect = {}

-- Mission-Specific Setup Defaults (Extracted from legacy A2G config)
TCS.Land.Architect.Defaults = {
    BAI = { minNm = 15, maxNm = 25, transitTime = 20 },
    CAS = { separationNm = 3 },
    CUSTOM = { minNm = 5, maxNm = 10 },
    REINFORCE_THRESHOLD = 0.65
}

--- Builds a Target Environment Specification for Land Missions
function TCS.Land.Architect.Build(missionType, params)
    local zoneName = type(params.anchor) == "string" and params.anchor or nil
    
    -- 0. Resolve Anchor and extract Mission Editor properties
    local targetZone, overrides = TCS.Architect.Scenario.ResolveZone(params.anchor)
    if targetZone then
        params.anchor = targetZone:GetCoordinate()
        -- Apply ME properties, allowing explicit API params to take precedence
        for k, v in pairs(overrides) do
            if params[k] == nil then params[k] = v end
        end
    elseif type(params.anchor) == "table" and params.anchor.GetCoordinate then
        params.anchor = params.anchor:GetCoordinate()
    end

    local anchor = params.anchor
    if not anchor or type(anchor) == "string" then
        env.warning(string.format("TCS(LAND.ARCHITECT): Failed to resolve anchor '%s' for %s.", tostring(zoneName or "Unknown"), missionType))
        return nil
    end

    params.coalition = params.coalition or coalition.side.RED
    params.anchor = anchor

    local envSpec = {
        missionType = missionType,
        anchor = anchor,
        components = {},
        successCriteria = {}
    }

    if missionType == "BAI" then
        params.minNm = params.minNm or TCS.Land.Architect.Defaults.BAI.minNm
        params.maxNm = params.maxNm or TCS.Land.Architect.Defaults.BAI.maxNm

        table.insert(envSpec.components, TCS.Towers.Land.PrepareRequisition("MECH_INF", params))
        table.insert(envSpec.components, TCS.Towers.Land.PrepareRequisition("MOBILE_AAA", params))

        envSpec.successCriteria = {
            { type = "ATTRITION", target = "ALL_ENEMY", threshold = TCS.Land.Architect.Defaults.REINFORCE_THRESHOLD, result = "ENEMY_ROUTED" }
        }

    elseif missionType == "CAS" then
        local sep = params.separationNm or TCS.Land.Architect.Defaults.CAS.separationNm
        params.minNm = params.minNm or sep
        params.maxNm = params.maxNm or sep

        local enemyParams = { anchor = anchor, minNm = params.minNm, maxNm = params.maxNm, coalition = params.coalition, skill = params.skill, echelon = params.echelon }
        local friendlyParams = { anchor = anchor, minNm = params.minNm, maxNm = params.maxNm, coalition = (params.coalition == coalition.side.RED) and coalition.side.BLUE or coalition.side.RED, skill = params.skill, echelon = params.echelon }
        
        table.insert(envSpec.components, TCS.Towers.Land.PrepareRequisition("MECH_INF", enemyParams))
        table.insert(envSpec.components, TCS.Towers.Land.PrepareRequisition("MECH_INF", friendlyParams))

        envSpec.successCriteria = {
            { type = "ATTRITION", target = "ALL_ENEMY", threshold = 0.65, result = "ENEMY_ROUTED" },
            { type = "ATTRITION", target = "ALL_FRIENDLY", threshold = 0.50, result = "FRIENDLY_OVERRUN" }
        }

    elseif missionType == "STRIKE" then
        table.insert(envSpec.components, TCS.Towers.Land.PrepareRequisition("STRIKE_TARGET", params))
        envSpec.successCriteria = {
            { type = "ATTRITION", target = "ALL_ENEMY", threshold = 0.70, result = "COMPLETE" }
        }

    elseif missionType == "RANGE" then
        local rangeKey = params.rangeKey or "bomb_grid_random"
        local recipe = TCS.Towers.Land.Training.GetRecipe(rangeKey, anchor, params.ingressHdg)
        if recipe then
            table.insert(envSpec.components, recipe)
        end
        envSpec.successCriteria = { { type = "ATTRITION", target = "ALL_ENEMY", threshold = 1.0, result = "RANGE_CLEARED" } }

    elseif missionType == "CUSTOM" then
        params.minNm = params.minNm or TCS.Land.Architect.Defaults.CUSTOM.minNm
        params.maxNm = params.maxNm or TCS.Land.Architect.Defaults.CUSTOM.maxNm

        table.insert(envSpec.components, TCS.Towers.Land.PrepareRequisition("CUSTOM", params))
        envSpec.successCriteria = { { type = "ATTRITION", target = "ALL_ENEMY", threshold = 0.90, result = "COMPLETE" } }
    else
        env.warning("TCS(LAND.ARCHITECT): Unknown mission type: " .. tostring(missionType))
        return nil
    end

    -- Package into V2 Recipes and Execute via the Deploy Dispatcher
    local zoneIds = {}
    if TCS.Dispatcher and TCS.Dispatcher.ExecuteRequisition then
        for _, comp in ipairs(envSpec.components) do
            local blueprint = {}
            for _, item in ipairs(comp.manifest or {}) do
                local rel = item.relativePos or {x=0, y=0}
                table.insert(blueprint, { x = rel.x, y = rel.y, unitType = item.unit_type, isStatic = item.isStatic, skill = item.skill })
            end
            comp.blueprint = blueprint
            comp.successCriteria = envSpec.successCriteria
            if not comp.geometry.domain then comp.geometry.domain = "LAND" end
            
            local zId = TCS.Dispatcher.ExecuteRequisition(comp)
            table.insert(zoneIds, zId)
        end
    end

    return zoneIds
end

--- Issues a tactical override command to all units in a session.
function TCS.Land.Architect.IssueCommand(command, params)
    params = params or {}
    local targetZoneId = params.zoneId
    local anchor = params.anchor
    
    if type(anchor) == "string" then
        local z = ZONE:FindByName(anchor)
        anchor = z and z:GetCoordinate() or nil
    end

    if not anchor then return false end

    for zoneId, dep in pairs(TCS.CIC.Controller and TCS.CIC.Controller.Deployments or {}) do
        if not targetZoneId or zoneId == targetZoneId then
            for _, g in ipairs(dep.Groups) do
                if g and g:IsAlive() then
                    if command == "ADVANCE" then
                        TCS.Towers.Land.Behavior.ApplyBehavior(g, { mode = "ADVANCE", target = anchor, speedKph = params.speed or 30 })
                    elseif command == "RETREAT" then
                        local retreatPt = TCS.Towers.Land.Behavior.GetRetreatPoint(anchor, g:GetCoordinate())
                        TCS.Towers.Land.Behavior.ApplyBehavior(g, { mode = "ADVANCE", target = retreatPt, speedKph = 45, onRoad = true })
                    end
                end
            end
        end
    end
    return true
end

env.info("TCS(LAND.ARCHITECT): ready")