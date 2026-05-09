---------------------------------------------------------------------
-- TCS TOWER: LAND
-- Domain Specialist: Translates compositions into Requisition Manifests.
---------------------------------------------------------------------
env.info("TCS(TOWER.LAND): loading")

TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.Land = TCS.Towers.Land or {}

--- Returns the blueprint for a specific force type.
function TCS.Towers.Land.GetBlueprint(forceType)
    local bp = TCS.Towers.Land.Compositions and TCS.Towers.Land.Compositions.Blueprints and TCS.Towers.Land.Compositions.Blueprints[forceType]
    if not bp then
        env.warning("TCS(LAND): No blueprint found for " .. tostring(forceType))
        return TCS.Towers.Land.Compositions and TCS.Towers.Land.Compositions.Blueprints and TCS.Towers.Land.Compositions.Blueprints.MECH_INF
    end
    return bp
end

function TCS.Towers.Land.PrepareRequisition(forceType, params)
    env.info(string.format("TCS(LAND): Preparing requisition for type '%s'", tostring(forceType)))
    
    local manifest = {}
    local blueprint = nil
    local countMultiplier = 1

    if forceType == "CUSTOM" then
        -- Create a dynamic blueprint using absolute counts
        local comp = params.composition or {}
        if params.category and params.count then comp[params.category] = params.count end
        blueprint = { baseSize = 1, ratios = comp }
        countMultiplier = 1
    else
        blueprint = TCS.Towers.Land.GetBlueprint(forceType)
        if not blueprint then
            env.warning("TCS(LAND): Missing blueprint for " .. tostring(forceType))
            return { tower = "LAND", manifest = {}, geometry = {}, behavior = {} }
        end
        
        -- Determine base size multiplier based on echelon
        local bSize = blueprint.baseSize or 4
        if params.echelon == "PATROL" or params.echelon == "PLATOON" then countMultiplier = bSize * 0.5
        elseif params.echelon == "COMPANY" then countMultiplier = bSize
        elseif params.echelon == "BATTALION" then countMultiplier = bSize * 2
        elseif params.echelon == "BRIGADE" then countMultiplier = bSize * 4 
        else countMultiplier = bSize end
    end

    countMultiplier = math.max(1, math.floor(countMultiplier))

    -- 2. Convert ratios into discrete unit counts
    local subGroupOffset = 0
    for category, ratioDef in pairs(blueprint.ratios) do
        local weight = type(ratioDef) == "table" and ratioDef.weight or ratioDef
        local catCount = math.max(1, math.floor(countMultiplier * weight))
        
        local pool = TCS.Towers.Land.Query({ category = category, skill = params.skill, coalition = params.coalition })
        if #pool > 0 then
            for i = 1, catCount do
                local selected = pool[math.random(#pool)]
                
                -- Organize into rough grid formations per category to avoid collisions
                local spacing = (category == "INFANTRY") and 15 or 40
                local col = (i - 1) % 4
                local row = math.floor((i - 1) / 4)
                
                table.insert(manifest, {
                    unit_type = selected.unit_type,
                    role = selected.role,
                    category = category, -- Used by CIC to split DCS groups
                    isStatic = (category == "STRUCTURE"),
                    -- Provide recommended relative tactical placement 
                    relativePos = { x = (col * spacing) + subGroupOffset, y = -(row * spacing) },
                    skill = params.skill or "Good"
                })
            end
            subGroupOffset = subGroupOffset + 150 -- Space out different categories
        else
            env.warning("TCS(LAND): Catalog missing entries for category: " .. tostring(category))
        end
    end

    return {
        tower = "LAND",
        forceType = forceType,
        manifest = manifest,
        coalition = params.coalition or coalition.side.RED,
        geometry = params.geometry, -- Handled directly by Mission Architect / Dispatcher
        behavior = {
            mode = (forceType == "STRIKE_TARGET") and "STATIC" or "ADVANCE",
            target = params.anchor,
            speedKph = 25
        }
    }
end

-- Alias to support legacy calls in the Mission Architect
TCS.Towers.Ground = TCS.Towers.Land

env.info("TCS(TOWER.LAND): ready")