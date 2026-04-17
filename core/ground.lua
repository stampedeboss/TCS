---------------------------------------------------------------------
-- TCS TOWER: GROUND
-- Domain Specialist: Mech, Transport, and Infantry components.
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
env.info("TCS(TOWER.GROUND): loading")

TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.Ground = {}

--- Translates a request into a Ground Recipe.
-- @param forceType (string) "MECH_INF", "TRANSPORT", "INFANTRY", "MOBILE_AAA"
-- @param params (table) { echelon, skill, coalition, anchor, minNm, maxNm, ingressHdg, ingressArc }
function TCS.Towers.Ground.GetRecipe(forceType, params)
    local recipe = {
        tower = "GROUND",
        forceType = forceType or "MECH_INF",
        echelon = params.echelon or "COMPANY",
        skill = params.skill or "G",
        coalition = params.coalition or coalition.side.RED,
        
        -- 1. Geometry: Where does this component enter the world?
        geometry = {
            type = "DIRECTIONAL_SPAWN",
            anchor = params.anchor,
            minNm = params.minNm or 5,
            maxNm = params.maxNm or 10,
            ingressHdg = params.ingressHdg,
            ingressArc = params.ingressArc
        },

        -- 2. Posture: How do they behave upon arrival?
        behavior = {
            mode = params.interaction or "ADVANCE", -- ADVANCE, CONVERGE, STATIC
            target = params.anchor,
            speedKph = 25,
            formation = "COLUMN",
            roe = "WEAPON_FREE"
        }
    }

    -- Special logic: Infantry vs. Mech movement characteristics
    if forceType == "INFANTRY" then
        recipe.behavior.speedKph = 10
        recipe.behavior.formation = "VEE"
        recipe.behavior.onRoad = false
    else
        recipe.behavior.onRoad = true
    end
    
    -- Tactical Logic: Logistics/Transport behavior
    if forceType == "TRANSPORT" then
        recipe.behavior.roe = "RETURN_FIRE"
        recipe.behavior.speedKph = 40
    end
    
    -- Mobile Air Defense logic
    if forceType == "MOBILE_AAA" then
        recipe.behavior.roe = "WEAPON_FREE"
        recipe.behavior.speedKph = 25
    end

    return recipe
end

--- Internal helper to map Tower behavior to Group Commands (Used by Dispatcher)
function TCS.Towers.Ground.ApplyBehavior(group, behavior)
    -- Implementation logic for TaskRouteToVec2 goes here in the Dispatcher phase
end

env.info("TCS(TOWER.GROUND): ready")