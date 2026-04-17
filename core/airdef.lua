---------------------------------------------------------------------
-- TCS TOWER: AIRDEF
-- Domain Specialist: Fixed Air Defense and Missile Systems (SAMs).
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
env.info("TCS(TOWER.AIRDEF): loading")

TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.AirDef = {}

--- Translates a request into an AirDef Recipe.
-- @param type (string) "MISSILE_BATTERY", "FIXED_SITE"
-- @param params (table) { echelon, skill, coalition, anchor, silent }
function TCS.Towers.AirDef.GetRecipe(defType, params)
    return {
        tower = "AIRDEF",
        systemType = defType or "MISSILE_BATTERY",
        echelon = params.echelon or "PLATOON",
        skill = params.skill or "G",
        coalition = params.coalition or coalition.side.RED,
        
        -- AirDef usually anchors directly to the objective or uses doctrinal offsets
        geometry = {
            type = "DOCTRINAL_LAYOUT",
            anchor = params.anchor,
            minNm = params.minNm or 0,
            maxNm = params.maxNm or 2,
            ingressHdg = params.ingressHdg
        },

        behavior = {
            mode = "STATIC",
            roe = "WEAPON_FREE",
            silentDistance = params.silent or -1 -- NM for radar activation
        }
    }
end

env.info("TCS(TOWER.AIRDEF): ready")