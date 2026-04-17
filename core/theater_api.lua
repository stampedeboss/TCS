-- This script provides global functions to trigger theater tasks via the TCS API.
-- It allows specifying a zone name for the anchor and overriding min/max spawn distances.

-- Ensure TCS is loaded
TCS = TCS or {}
TCS.API = TCS.API or {}

--- Normalizes API inputs into structured Objective, Deployment, and Orders blocks.
function TCS.API.Normalize(args, defaultForceSize, domain)
    local p = args or {}
    
    -- Allow fallback to flat tables by treating the root 'p' as the source if a sub-table is missing
    local obj = p.objective or p
    local dep = p.deployment or p
    local ord = p.orders or p

    local anchor = obj.anchor

    -- 1. Dynamic Anchor Resolution (Zone Creation)
    if type(anchor) == "table" and anchor.ClassName == "GROUP" then
        obj.group = anchor
        anchor = nil
    end

    if not anchor and obj.group and TCS.Placement and TCS.Placement.Resolve then
        local conditions = (domain == "LAND") and { terrain = "FLAT", surface = "OPEN" } or nil
        -- Pass requested geometric constraints down to placement solver so it generates the zone intelligently
        local placementOpts = { 
            domain = domain or "LAND", 
            conditions = conditions,
            minNm = obj.minNm,
            maxNm = obj.maxNm,
            heading = obj.ingressHdg
        }
        local resolvedAnchor, reason = TCS.Placement.Resolve(obj.group:GetUnit(1), placementOpts)
        if not resolvedAnchor then
            env.warning("TCS(API): Dynamic anchor resolution failed: " .. tostring(reason))
        end
        anchor = resolvedAnchor
    end

    -- 2. Parameter Normalization & Defaults into Structured Blocks
    return {
        geometry = { -- Passed directly to the Spawner
            type       = "DIRECTIONAL_SPAWN",
            anchor     = anchor,
            minNm      = obj.minNm or 5,
            maxNm      = obj.maxNm or 15,
            ingressHdg = obj.ingressHdg,
            ingressArc = obj.ingressArc or 180,
        },
        coalition      = dep.coalition or coalition.side.RED,
        echelon        = dep.forceSize or dep.echelon or defaultForceSize or "COMPANY",
        skill          = dep.skill or "G",
        count          = dep.count,
        samType        = dep.samType,
        friendlyCoalition = dep.friendlyCoalition,
        
        -- Future expansion for the Task Manager / Zone Manager
        behavior = {
            reinforce    = ord.reinforce,
            respawn      = ord.respawn,
            respawnDelay = ord.respawnDelay or 300,
            duration     = ord.duration,
            silent       = ord.silent
        }
    }
end

--- Deploys a Ground Force to support BAI or CAS missions.
--- The Architect dynamically structures a Troops In Contact (CAS) scenario if `friendlyCoalition` is provided.
function DeployGroundForces(args)
    -- Support legacy positional wrapper for backward compatibility
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end

    local params = TCS.API.Normalize(args, "COMPANY", "LAND")
    
    if not params.geometry.anchor then return nil end
    env.info(string.format("TCS(API): Creating Ground Force task at '%s'", tostring(params.geometry.anchor)))

    if not TCS.Towers or not TCS.Towers.Ground then return nil end
    
    -- Pass the normalized struct directly to the Architect
    local recipe = TCS.Towers.Ground.GetRecipe("MECH_INF", params)
    recipe.missionType = params.friendlyCoalition and "CAS" or "BAI"
    recipe.successCriteria = { { type = "ATTRITION", threshold = 0.65, result = "ENEMY_ROUTED" } }

    return TCS.Architect.ExecuteRequisition(recipe)
end

--- Deploys a Facility (infrastructure and fixed defenders).
function DeployFacility(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end
    local params = TCS.API.Normalize(args, "COMPANY", "LAND")
    
    if not params.geometry.anchor then return nil end
    if not TCS.Towers or not TCS.Towers.Ground then return nil end
    local recipe = TCS.Towers.Ground.GetRecipe("INFANTRY", params)
    recipe.missionType = "STRIKE"
    recipe.successCriteria = { { type = "ATTRITION", threshold = 0.9, result = "COMPLETE" } }
    return TCS.Architect.ExecuteRequisition(recipe)
end

--- Deploys a Short Range Air Defense (SHORAD) network.
function DeployAirDefenses(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end
    local params = TCS.API.Normalize(args, "PLATOON", "LAND")
    
    if not params.geometry.anchor then return nil end
    if not TCS.Towers or not TCS.Towers.Ground then return nil end
    local recipe = TCS.Towers.Ground.GetRecipe("MOBILE_AAA", params)
    recipe.missionType = "SEAD"
    recipe.successCriteria = { { type = "ATTRITION", threshold = 0.8, result = "COMPLETE" } }
    return TCS.Architect.ExecuteRequisition(recipe)
end

--- Deploys a Combat Air Patrol.
function DeployAirPatrol(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end
    local params = TCS.API.Normalize(args, "SQUADRON", "AIR")
    
    if not params.geometry.anchor then return nil end
    if not TCS.Towers or not TCS.Towers.Air then 
        env.info("TCS(API): Air Tower not yet implemented. Skipping Air Patrol task.")
        return nil 
    end
    local recipe = TCS.Towers.Air.GetRecipe("FIGHTER", params)
    recipe.missionType = "CAP"
    return TCS.Architect.ExecuteRequisition(recipe)
end

--- Deploys an Offensive Air Sweep.
function DeployAirSweep(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end
    local params = TCS.API.Normalize(args, "SQUADRON", "AIR")
    
    if not params.geometry.anchor then return nil end
    if not TCS.Towers or not TCS.Towers.Air then 
        env.info("TCS(API): Air Tower not yet implemented. Skipping Air Sweep task.")
        return nil 
    end
    local recipe = TCS.Towers.Air.GetRecipe("FIGHTER", params)
    recipe.missionType = "SWEEP"
    return TCS.Architect.ExecuteRequisition(recipe)
end

--- Deploys a Doctrinal SAM Site.
function DeploySAM(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end

    local params = TCS.API.Normalize(args, "PLATOON", "LAND")

    if not params.samType and TCS.Config and TCS.Config.A2G and TCS.Config.A2G.SAMS then
        local pool = {}
        for key, def in pairs(TCS.Config.A2G.SAMS) do
            if def.tier == params.skill or def.skill == params.skill or not def.tier then
                table.insert(pool, key)
            end
        end
        if #pool > 0 then params.samType = pool[math.random(#pool)] end
    end

    if not params.geometry.anchor then return nil end
    if not TCS.Towers or not TCS.Towers.Ground then return nil end
    local recipe = TCS.Towers.Ground.GetRecipe("MOBILE_AAA", params)
    recipe.missionType = "DSAM"
    recipe.successCriteria = { { type = "ATTRITION", threshold = 0.9, result = "COMPLETE" } }
    return TCS.Architect.ExecuteRequisition(recipe)
end

--- Deploys a Naval Battle Group (Warships).
function DeployBattleGroup(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end
    local params = TCS.API.Normalize(args, "COMPANY", "SEA")
    
    if not params.geometry.anchor then return nil end
    if not TCS.Towers or not TCS.Towers.Sea then return nil end
    local recipe = TCS.Towers.Sea.GetRecipe("NAVY", params)
    recipe.missionType = "NAVY"
    return TCS.Architect.ExecuteRequisition(recipe)
end

--- Deploys Ambient Civilian/Neutral Shipping.
function DeployCivilian(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end
    local params = TCS.API.Normalize(args, "COMPANY", "SEA")
    
    if not params.geometry.anchor then return nil end
    if not TCS.Towers or not TCS.Towers.Sea then return nil end
    local recipe = TCS.Towers.Sea.GetRecipe("CIVILIAN", params)
    recipe.missionType = "CIVILIAN"
    return TCS.Architect.ExecuteRequisition(recipe)
end

--- Deploys a Naval Convoy (Cargo ships led by Naval Warships).
function DeployConvoy(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end
    local params = TCS.API.Normalize(args, "COMPANY", "SEA")
    
    if not params.geometry.anchor then return nil end
    if not TCS.Towers or not TCS.Towers.Sea then return nil end
    local recipe = TCS.Towers.Sea.GetRecipe("CONVOY", params)
    recipe.missionType = "CONVOY"
    return TCS.Architect.ExecuteRequisition(recipe)
end

--- Deploys Ambient Traffic with interspersed Naval combatants acting as escorts.
function DeployTraffic(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end
    local params = TCS.API.Normalize(args, "COMPANY", "SEA")
    
    if not params.geometry.anchor then return nil end
    if not TCS.Towers or not TCS.Towers.Sea then return nil end
    local recipe = TCS.Towers.Sea.GetRecipe("TRAFFIC", params)
    recipe.missionType = "TRAFFIC"
    return TCS.Architect.ExecuteRequisition(recipe)
end

env.info("TCS(API.THEATER): ready")