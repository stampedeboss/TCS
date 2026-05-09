---------------------------------------------------------------------
-- TCS TOWER: SEA
-- Domain Specialist: Pattern generation for Maritime & Civilian tasks.
---------------------------------------------------------------------
env.info("TCS(TOWER.SEA): loading")

TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.Sea = {}

--- Builds a relative coordinate blueprint (offsets only) for sea assets.
function TCS.Towers.Sea.BuildRelativeBlueprint(pattern, cfg)
    local pts = {}
    local spacing = cfg.spacing_m or (TCS.Sea and TCS.Sea.Config and TCS.Sea.Config.Spawns.Spacing_m) or 2500

    if pattern == "LINE_AHEAD" then
        -- Ships follow in a straight line backward from the core
        for i = 1, cfg.count do
            table.insert(pts, { x = 0, y = -(i - 1) * spacing, role = (i == 1) and "CORE" or "SCREEN" })
        end
    elseif pattern == "DIAMOND" then
        -- Core ship at center, screens guarding flanks and rear
        table.insert(pts, { x = 0, y = 0, role = "CORE" })
        if cfg.count >= 2 then table.insert(pts, { x = spacing, y = -spacing, role = "SCREEN" }) end
        if cfg.count >= 3 then table.insert(pts, { x = -spacing, y = -spacing, role = "SCREEN" }) end
        if cfg.count >= 4 then table.insert(pts, { x = 0, y = -spacing * 2, role = "SCREEN" }) end
        -- Add additional ships trailing if count exceeds 4
        for i = 5, cfg.count do
            table.insert(pts, { x = 0, y = -(i - 2) * spacing, role = "SCREEN" })
        end
    elseif pattern == "SCATTER" then
        -- Random points within a wide radius (e.g., ambient traffic)
        local radius = cfg.radius_m or (TCS.Sea and TCS.Sea.Config and TCS.Sea.Config.Spawns.TrafficRadius_m) or 30000
        for i = 1, cfg.count do
            local r = math.sqrt(math.random()) * radius
            local a = math.random() * 2 * math.pi
            table.insert(pts, { x = math.cos(a) * r, y = math.sin(a) * r, role = "TRAFFIC" })
        end
    else
        table.insert(pts, { x = 0, y = 0, role = "CORE" })
    end

    return pts
end

--- Translates a request into a relative Architect Blueprint.
function TCS.Towers.Sea.GetRecipe(taskCategory, params)
    local recipe = {
        tower = "SEA",
        category = Group.Category.SHIP,
        geometry = {
            type = "DIRECTIONAL_SPAWN",
            anchor = params.anchor,
            ingressHdg = params.ingressHdg,
            ingressArc = params.ingressArc,
            minNm = params.minNm or 10,
            maxNm = params.maxNm or 30
        }
    }

    local pattern = "LINE_AHEAD"
    local count = 3
    local pool = TCS.Catalog and TCS.Catalog.Query({ domain="SEA" }) or {}

    if taskCategory == "NAVY" then
        recipe.coalition = params.coalition or coalition.side.RED
        recipe.skill = params.skill or "High"
        pool = TCS.Catalog and TCS.Catalog.Query({ domain="SEA", threat_band="HIGH", coalition=(recipe.coalition == 1 and "RED" or "BLUE") }) or pool
        
        if params.echelon == "SQUADRON" then
            pattern = "DIAMOND"; count = 4
        elseif params.echelon == "PLATOON" then
            pattern = "LINE_AHEAD"; count = 2
        else
            pattern = "DIAMOND"; count = 3
        end
        
        recipe.successCriteria = { { type = "ATTRITION", threshold = 0.7, result = "ENEMY_ROUTED" } }
        recipe.behavior = { mode = "ADVANCE", target = params.anchor } -- Warships push toward objective
        
    elseif taskCategory == "CIVILIAN" then
        recipe.coalition = coalition.side.NEUTRAL
        recipe.skill = "Average"
        pool = TCS.Catalog and TCS.Catalog.Query({ domain="SEA", role="CARGO" }) or pool
        pattern = "SCATTER"; count = params.count or 5
        
        recipe.behavior = { 
            mode = "LOITER", 
            roe = "WEAPON_HOLD", 
            alarmState = "GREEN" 
        }
        
    elseif taskCategory == "CONVOY" then
        recipe.coalition = params.coalition or coalition.side.RED
        recipe.skill = params.skill or "Average"
        pool = TCS.Catalog and TCS.Catalog.Query({ domain="SEA", role="CARGO" }) or pool
        pattern = "LINE_AHEAD"; count = params.count or 4
        
        recipe.successCriteria = { { type = "ATTRITION", threshold = 0.6, result = "ENEMY_ROUTED" } }
        recipe.behavior = { mode = "ADVANCE", target = params.anchor, roe = "RETURN_FIRE", alarmState = "RED" }
        
    elseif taskCategory == "TRAFFIC" then
        recipe.coalition = params.coalition or coalition.side.RED
        recipe.skill = params.skill or "Average"
        pool = TCS.Catalog and TCS.Catalog.Query({ domain="SEA", role="CARGO" }) or pool
        pattern = "SCATTER"; count = params.count or 8
        
        recipe.behavior = { mode = "LOITER", roe = "RETURN_FIRE", alarmState = "GREEN" }
    end
    
    local cfgSpawns = (TCS.Sea and TCS.Sea.Config and TCS.Sea.Config.Spawns) or { Spacing_m = 2500, TrafficRadius_m = 30000 }
    local pts = TCS.Towers.Sea.BuildRelativeBlueprint(pattern, { count = count, spacing_m = cfgSpawns.Spacing_m, radius_m = cfgSpawns.TrafficRadius_m })

    local manifest = {}
    local ptIdx = 1
    if #pool > 0 then
        local remaining = count
        while remaining > 0 do
            local selected = pool[math.random(#pool)]
            local shipCount = (taskCategory == "CONVOY") and math.min(remaining, 3) or 1
            
            for i = 1, shipCount do
                local pt = pts[ptIdx] or {x=0, y=0, role="CORE"}
                table.insert(manifest, {
                    unit_type = selected.unit_types and selected.unit_types[1] or selected.unit_type,
                    role = selected.role or "SURFACE",
                    category = pt.role, -- Sub-groups by CORE, SCREEN, or TRAFFIC
                    isStatic = false,
                    relativePos = { x = pt.x, y = pt.y },
                    skill = params.skill or "Average"
                })
                ptIdx = ptIdx + 1
            end
            remaining = remaining - shipCount
        end
    end

    if taskCategory == "HARBOR" then
        -- Add static docked ships
        for i=1, 2 do
            table.insert(manifest, { unit_type = "Dry-cargo ship-1", role = "OBJECTIVE", category = "DOCKED", isStatic = true, relativePos = { x = i * 150, y = 150 }, skill = "Average" })
        end
    end

    recipe.manifest = manifest
    return recipe
end

env.info("TCS(TOWER.SEA): ready")