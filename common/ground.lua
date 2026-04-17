---------------------------------------------------------------------
-- TCS TOWER: GROUND
-- Main entry point for the Ground specialist.
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.Ground = TCS.Towers.Ground or {}

-- Tower Domain Performance Constants
TCS.Towers.Ground.Config = {
    MOVE_SPEED_KPH = 25,      -- Standard mechanized march speed
    INFANTRY_SPEED_KPH = 10,  -- Standard infantry movement speed
    MAX_TACTICAL_SPEED = 60   -- Maximum allowed speed for any ground unit
}

--- Prepares a requisition of resources based on Director requirements.
-- @param forceType (string) e.g., "MECH_INF", "MOBILE_AAA"
-- @param params (table) High-level intent from the Architect.
function TCS.Towers.Ground.PrepareRequisition(forceType, params)
    local ech = (TCS.Common.Config and TCS.Common.Config.Echelons) and TCS.Common.Config.Echelons[params.echelon or "COMPANY"] or { scale = 3, spacing = 50 }
    local manifest = {}

    -- 1. Assemble Manifest (Motor Pool Fulfillment)
    if forceType == "SPAWN" and params.composition then
        -- DIRECT DEMAND: Architect requests specific counts, Tower selects types
        for category, count in pairs(params.composition) do
            local pool = TCS.Towers.Ground.Query({
                category = category,
                coalition = params.coalition,
                skill = params.skill or "G"
            })
            if #pool > 0 then
                local selected = pool[math.random(#pool)]
                
                -- Bridge to Motor Pool / DCS Warehouse
                if TCS.Towers.Ground.Inventory and TCS.Towers.Ground.Inventory.Request(params.coalition, selected.id, count, params.anchor) then
                    TCS.Towers.Ground.Inventory.Consume(params.coalition, selected.id, count, params.anchor)
                    
                    -- Standardize on 'types' as a table for the Spawner
                    local types = type(selected.unit_type) == "table" and selected.unit_type or { selected.unit_type }
                    table.insert(manifest, { types = types, count = count, id = selected.id })
                else
                    env.warning("TCS(GROUND): Tower cannot fulfill demand for " .. category .. " (Insufficient Supply)")
                end
            end
        end
    else
        -- STANDARD PROCESS: Proportional Ratio Scaling
        local blueprint = TCS.Towers.Ground.GetBlueprint(forceType) or {}
        local ratios = blueprint.ratios or {}
        
        local totalRatio = 0
        for _, r in pairs(ratios) do 
            totalRatio = totalRatio + (type(r) == "table" and r.weight or r)
        end

        for category, ratioData in pairs(ratios) do
            local ratio = type(ratioData) == "table" and ratioData.weight or ratioData
            local pool = TCS.Towers.Ground.Query({
                category = category,
                coalition = params.coalition,
                skill = params.skill or "G"
            })

            if #pool > 0 then
                local categoryTotalCount = math.max(1, math.floor((blueprint.baseSize * (ratio / totalRatio) * ech.scale) + 0.5))
                
                if type(ratioData) == "table" and ratioData.sub then
                    -- Sub-role distribution logic
                    for role, subRatio in pairs(ratioData.sub) do
                        local subPool = {}
                        for _, entry in ipairs(pool) do
                            if entry.role == role then table.insert(subPool, entry) end
                        end

                        if #subPool > 0 then
                            local roleCount = math.floor((categoryTotalCount * subRatio) + 0.5)
                            if subRatio > 0 then roleCount = math.max(1, roleCount) end

                            -- Variety Chunking: Split into tactical groups of 4
                            local remaining = roleCount
                            while remaining > 0 do
                                local groupCount = math.min(remaining, 4)
                                local selected = subPool[math.random(#subPool)]
                                
                                if TCS.Towers.Ground.Inventory and TCS.Towers.Ground.Inventory.Consume then
                                    TCS.Towers.Ground.Inventory.Consume(params.coalition, selected.id, groupCount, params.anchor)
                                end

                                local types = type(selected.unit_type) == "table" and selected.unit_type or { selected.unit_type }
                                local item = { types = types, count = groupCount, id = selected.id, role = role, formation = "WEDGE" }

                                if category == "INFANTRY" then
                                    item.speed = TCS.Config.Ground.Defaults.PERFORMANCE_CONSTANTS.INFANTRY_SPEED_KPH
                                    item.onRoad = false
                                end

                                table.insert(manifest, item)
                                remaining = remaining - groupCount
                            end
                        end
                    end
                else
                    -- Default: Pick one random type for the whole category count
                    local selected = pool[math.random(#pool)]
                    if TCS.Towers.Ground.Inventory and TCS.Towers.Ground.Inventory.Consume then
                        TCS.Towers.Ground.Inventory.Consume(params.coalition, selected.id, categoryTotalCount, params.anchor)
                    end

                    -- Tactical Variety: Split standard categories into groups of 4 and re-roll
                    local remaining = categoryTotalCount
                    while remaining > 0 do
                        local groupCount = math.min(remaining, 4)
                        local chunkSelected = pool[math.random(#pool)]
                        
                        local types = type(chunkSelected.unit_type) == "table" and chunkSelected.unit_type or { chunkSelected.unit_type }
                        local item = { types = types, count = groupCount, id = chunkSelected.id, formation = "WEDGE" }

                        if category == "INFANTRY" then
                            item.speed = TCS.Config.Ground.Defaults.PERFORMANCE_CONSTANTS.INFANTRY_SPEED_KPH
                            item.onRoad = false
                        end
                        
                        table.insert(manifest, item)
                        
                        remaining = remaining - groupCount
                    end
                end
            end
        end
    end

    -- 2. Calculate Required Speed based on Transit Time (Time-on-Target)
    local speedKph = (forceType == "INFANTRY") and TCS.Config.Ground.Defaults.PERFORMANCE_CONSTANTS.INFANTRY_SPEED_KPH or TCS.Config.Ground.Defaults.PERFORMANCE_CONSTANTS.MOVE_SPEED_KPH
    
    if params.transitTime and params.minNm and params.maxNm then
        local avgDistM = ((params.minNm + params.maxNm) / 2) * 1852
        local timeSec = params.transitTime * 60
        local calcSpeedKph = (avgDistM / timeSec) * 3.6
        
        -- Clamp speed between a slow crawl (5kph) and the tactical max
        speedKph = math.min(math.max(calcSpeedKph, 5), TCS.Config.Ground.Defaults.PERFORMANCE_CONSTANTS.MAX_TACTICAL_SPEED)
    end

    return {
        tower = "GROUND",
        forceType = forceType,
        manifest = manifest,
        spacing = ech.spacing,
        coalition = params.coalition,
        geometry = {
            type = "DIRECTIONAL",
            anchor = params.anchor,
            minNm = params.minNm,
            maxNm = params.maxNm,
            ingressHdg = params.ingressHdg,
            ingressArc = params.ingressArc
        },
        behavior = {
            mode = params.interaction or "ADVANCE",
            target = params.anchor,
            onRoad = false, -- Default to Off Road for better reliability in dynamic spawns
            speedKph = speedKph
        }
    }
end

env.info("TCS(TOWER.GROUND): ready")