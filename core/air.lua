---------------------------------------------------------------------
-- TCS TOWER: AIR
-- Specialist for Air bandit compositions and geometry.
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
env.info("TCS(TOWER.AIR): loading")

TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.Air = {}

-- Translates a mission request into a specific Air Bandit Recipe.
function TCS.Towers.Air.GetRecipe(role, params)
    local skill = params.skill or params.tier or "G"
    local side = params.coalition or coalition.side.RED
    
    -- Support for Friendly Packages (AWACS, Tanker, Strike)
    local isSupport = (role == "AWACS" or role == "TANKER" or role == "STRIKE_PKG" or role == "TRANSPORT")
    local queryFilter = { role = role }
    
    if not isSupport then
        queryFilter.tier = skill
    end

    local candidates = TCS.Catalog.Query(queryFilter)
    local def = candidates[math.random(#candidates)]
    
    return {
        tower = "AIR",
        role = role,
        coalition = side,
        data = def,
        geometry = {
            type = isSupport and "FRIENDLY_STATION" or "A2A_OFFSET",
            distNM = (role == "BVR") and {40, 80} or {5, 15},
            arc = 135
        },
        behavior = isSupport and "ORBIT" or "INTERCEPT"
    }
end

env.info("TCS(TOWER.AIR): ready")