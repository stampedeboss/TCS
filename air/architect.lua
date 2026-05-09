---------------------------------------------------------------------
-- TCS AIR ARCHITECT
-- Director Layer: Assembles Air and Support requisitions.
---------------------------------------------------------------------
env.info("TCS(AIR.ARCHITECT): loading")

TCS = TCS or {}
TCS.Air = TCS.Air or {}
TCS.Air.Architect = {}

function TCS.Air.Architect.Build(missionType, params)
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
    
    -- 1. Query Unified Catalog for Bandit Definition
    local searchRole = params.role or "BVR"
    local searchTier = params.tier or "G"
    local missionYear = params.year or (env.mission and env.mission.date and env.mission.date.Year) or 2000
    
    local banditDef = nil
    if type(params.manifest) == "string" then
        banditDef = { unit_types = { params.manifest } }
    else
        local query = {role=searchRole, tier=searchTier, year=missionYear}
        if params.var then query.var = params.var end
        local candidates = TCS.Air.Catalog and TCS.Air.Catalog.Query(query) or {}
        banditDef = #candidates > 0 and candidates[math.random(#candidates)] or nil
    end
    
    if banditDef then
        params.unit_type = banditDef.unit_types[1]
        params.payload = banditDef.data and banditDef.data.payload
        params.speed_class = banditDef.speed_class
        -- Translate tier to skill string
        local skillMap = { ["A"]="Average", ["G"]="Good", ["H"]="High", ["X"]="Excellent" }
        params.skill = skillMap[searchTier] or "Good"
    end

    if missionType == "CAP" or missionType == "SWEEP" or missionType == "INTERCEPT" or missionType == "BUILD" then
        table.insert(envSpec.components, TCS.Towers.Air.PrepareRequisition("FIGHTER", params))
        envSpec.successCriteria = { { type = "ATTRITION", target = "ALL_ENEMY", threshold = 0.65, result = "AIRSPACE_CLEARED" } }
    elseif missionType == "ESCORT" then
        -- Component 1: The Package (STRIKE, TRANSPORT, etc.)
        local pkgParams = { anchor = anchor, coalition = params.coalition, echelon = "PATROL" }
        local pkgComponent = TCS.Towers.Air.PrepareRequisition(params.package or "STRIKE", pkgParams)
        if params.destination then pkgComponent.behavior = { mode = "STRIKE", target = params.destination } end
        table.insert(envSpec.components, pkgComponent)

        -- Component 2: The Escort (FIGHTERS)
        local escortComponent = TCS.Towers.Air.PrepareRequisition("FIGHTER", params)
        escortComponent.behavior = { mode = "ESCORT", escortTargetIndex = 1 }
        table.insert(envSpec.components, escortComponent)

        envSpec.successCriteria = { { type = "ATTRITION", target = "ALL_FRIENDLY", threshold = 0.5, result = "PACKAGE_DESTROYED" } }
    else return nil end

    -- 2. Resolve Global Anchor Geometry (V1 Intercept Intelligence Port)
    local minNM = params.minNm or TCS.Air.Settings.DEFAULT_MIN_NM or 40
    local maxNM = params.maxNm or TCS.Air.Settings.DEFAULT_MAX_NM or 80
    
    -- Scale distance based on catalog speed_class
    if params.speed_class == "SLOW" then
        minNM = math.max(10, minNM * 0.5)
        maxNM = math.max(20, maxNM * 0.5)
    elseif params.speed_class == "FAST" then
        minNM = minNM * 1.5
        maxNM = maxNM * 1.5
    end
    
    -- Calculate Flank/Beam aspect offset based on settings.lua ingress arc
    local anchorHeadingDeg = params.anchorHdg or 0
    local arcLimit = params.ingressArc or 120
    local aspectOffset = math.random(0, arcLimit)
    if math.random() > 0.5 then aspectOffset = -aspectOffset end
    local spawnHdgDeg = (anchorHeadingDeg + aspectOffset) % 360

    -- Convert requested altitude (feet) to meters for the DCS Spawner
    local altMeters = (params.alt or TCS.Air.Settings.ALTITUDE.MED or 25000) * 0.3048

    -- 3. Package into V2 Recipes and Execute via the Deploy Architect
    local zoneIds = {}
    for _, comp in ipairs(envSpec.components) do
        local blueprint = {}
        for _, item in ipairs(comp.manifest or {}) do
            local rel = item.relativePos or {x=0, y=0}
            -- Flatten manifest items into V2 blueprint offsets with metadata
            table.insert(blueprint, {
                x = rel.x,
                y = rel.y,
                unitType = item.unit_type,
                payload = item.payload,
                skill = item.skill
            })
        end

        local recipe = {
            missionType = missionType,
            category = Group.Category.AIRPLANE,
            coalition = comp.coalition or params.coalition,
            behavior = comp.behavior,
            successCriteria = envSpec.successCriteria,
            blueprint = blueprint,
            geometry = {
                type = "DIRECTIONAL_SPAWN",
                anchor = anchor,
                minNm = minNM,
                maxNm = maxNM,
                ingressHdg = spawnHdgDeg,
                ingressArc = 0, -- Keeps the echelon formation together
                domain = "AIR",
                alt = altMeters
            },
            maxAirframes = params.maxAirframes or params.max
        }
        
        if TCS.Dispatcher and TCS.Dispatcher.ExecuteRequisition then 
            local zId = TCS.Dispatcher.ExecuteRequisition(recipe)
            table.insert(zoneIds, zId)
        end
    end
    
    return zoneIds
end
env.info("TCS(AIR.ARCHITECT): ready")