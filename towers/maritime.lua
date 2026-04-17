---------------------------------------------------------------------
-- TCS TOWER: MARITIME
-- Domain Specialist: Surface Action Groups, Convoys, and Harbors.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.Maritime = {}

function TCS.Towers.Maritime.PrepareRequisition(forceType, params)
    local manifest = {}
    local side = params.coalition or 1
    
    -- Resolve Scale based on Maritime Echelons
    local shipCount = 1
    if params.echelon == "TASK_UNIT" then shipCount = 2
    elseif params.echelon == "TASK_GROUP" then shipCount = 4
    elseif params.echelon == "TASK_FORCE" then shipCount = 8
    end

    -- Query Catalog for Maritime assets
    local category = (forceType == "CONVOY") and "CARGO_SHIP" or "WARSHIP"
    local pool = TCS.Catalog.Query({ category = category, coalition = (side == 2 and "BLUE" or "RED") })

    if #pool > 0 then
        local remaining = shipCount
        while remaining > 0 do
            local selected = pool[math.random(#pool)]
            local count = (forceType == "CONVOY") and math.min(remaining, 3) or 1
            
            table.insert(manifest, {
                types = selected.unit_types,
                count = count,
                id = selected.id,
                role = selected.threat or "SURFACE"
            })
            remaining = remaining - count
        end
    end

    -- If it's a strike/harbor, add static defenses or docked targets
    if forceType == "HARBOR" then
        table.insert(manifest, { types = {"Static Cargo Ship"}, count = 2, role = "OBJECTIVE" })
    end

    return {
        tower = "MARITIME",
        forceType = forceType,
        manifest = manifest,
        coalition = side,
        geometry = {
            type = "DIRECTIONAL",
            anchor = params.anchor,
            minNm = params.minNm or 10,
            maxNm = params.maxNm or 20,
            ingressHdg = params.ingressHdg,
            ingressArc = params.ingressArc,
            domain = "SEA"
        },
        behavior = {
            mode = (forceType == "HARBOR") and "STATIC" or "ADVANCE",
            target = params.anchor,
            speedKph = (forceType == "CONVOY") and 15 or 25
        }
    }
end

env.info("TCS(TOWER.MARITIME): ready")