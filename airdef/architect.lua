---------------------------------------------------------------------
-- TCS AIRDEF ARCHITECT
-- Director Layer: Assembles Air Defense & SEAD/DEAD requisitions.
---------------------------------------------------------------------
env.info("TCS(AIRDEF.ARCHITECT): loading")

TCS = TCS or {}
TCS.AirDef = TCS.AirDef or {}
TCS.AirDef.Architect = {}

function TCS.AirDef.Architect.Build(missionType, params)
    local defs = TCS.AirDef.Defaults or {}

    local anchor = params.anchor
    if type(anchor) == "string" then
        local z = ZONE:FindByName(anchor)
        anchor = z and z:GetCoordinate() or nil
    elseif type(anchor) == "table" and anchor.GetCoordinate then
        anchor = anchor:GetCoordinate()
    end

    if not anchor then return nil end

    params.coalition = params.coalition or coalition.side.RED
    params.anchor = anchor

    local envSpec = { missionType = missionType, anchor = anchor, components = {}, successCriteria = {} }

    if missionType == "DSAM" or missionType == "DEAD" then
        local samType = params.manifest or params.samType
        if type(samType) == "table" and #samType > 0 then
            samType = samType[math.random(#samType)]
        end
        
        -- If no specific SAM was requested, query the Catalog using TYPE, RANGE, and THREAT LEVEL
        if not samType then
            local pool = TCS.AirDef.Query and TCS.AirDef.Query(params) or {}
            samType = (#pool > 0) and pool[math.random(#pool)] or (defs.FALLBACK_SAM_TYPE or "SA-6")
        end

        table.insert(envSpec.components, TCS.AirDef.PrepareRequisition(samType, params))
        
        if missionType == "DEAD" then
            -- DEAD missions inject a Ground Architect requisition for HVT protection
            local guardParams = { anchor = anchor, minNm = defs.DEAD_GUARD_MIN_NM or 0.5, maxNm = defs.DEAD_GUARD_MAX_NM or 2.0, coalition = params.coalition, threat = params.threat, echelon = params.echelon }
            table.insert(envSpec.components, TCS.Land.PrepareRequisition("ARMOR_STRIKE", guardParams))
            table.insert(envSpec.components, TCS.Land.PrepareRequisition("INFANTRY", guardParams))
        end

        local resultMsg = (missionType == "DEAD") and "AREA_CLEARED" or "RADARS_SUPPRESSED"
        envSpec.successCriteria = { { type = "ATTRITION", target = "ALL_ENEMY", threshold = defs.DEAD_ATTRITION_THRESHOLD or 0.50, result = resultMsg } }
    elseif missionType == "SEAD" then
        -- SEAD missions target tactical mobile SHORAD networks
        table.insert(envSpec.components, TCS.Land.PrepareRequisition("AIRDEF_SECTION", params))
        envSpec.successCriteria = { { type = "ATTRITION", target = "ALL_ENEMY", threshold = defs.SEAD_ATTRITION_THRESHOLD or 0.70, result = "RADARS_SUPPRESSED" } }
    else
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

---------------------------------------------------------------------
-- PUBLIC API ENDPOINTS
---------------------------------------------------------------------
function TCS.DeploySAM(params)
    params = params or {}
    
    -- Map common API aliases to internal Architect parameters
    params.samType = params.samType or params.type or params.forceSize
    params.anchor = params.anchor or params.zone
    
    if not TCS.AirDef.Architect then
        env.warning("TCS(API): AirDef Architect not loaded.")
        return nil
    end
    
    return TCS.AirDef.Architect.Build("DSAM", params)
end

-- Backwards compatibility alias for F10 training menus
_G.DeploySAM = TCS.DeploySAM

env.info("TCS(AIRDEF.ARCHITECT): ready")