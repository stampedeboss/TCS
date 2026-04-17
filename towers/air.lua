---------------------------------------------------------------------
-- TCS TOWER: AIR
-- Domain Specialist: Fighter sweeps, CAP, and Intercepts.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.Air = TCS.Towers.Air or {}

function TCS.Towers.Air.PrepareRequisition(role, params)
    local manifest = {}
    local side = params.coalition or 1
    local missionType = params.missionType or "CAP"
    
    -- Resolve Sortie Count based on Echelon
    local totalSorties = 2 -- Default Section
    if params.echelon == "SQUADRON" then totalSorties = 4 end
    if params.echelon == "WING" then totalSorties = 8 end

    local pool = TCS.Towers.Air.Query({ category = "FIGHTER", coalition = side, role = "BVR" })

    if #pool > 0 then
        local remaining = totalSorties
        while remaining > 0 do
            local groupCount = math.min(remaining, 2) -- Section based variety
            local selected = pool[math.random(#pool)]

            -- Motor Pool Handshake
            if TCS.Towers.Air.Inventory and TCS.Towers.Air.Inventory.Request(side, selected.id, groupCount, params.anchor) then
                TCS.Towers.Air.Inventory.Consume(side, selected.id, groupCount, params.anchor)
                
                table.insert(manifest, {
                    types = { selected.unit_type },
                    count = groupCount,
                    id = selected.id,
                    skill = params.skill or "Good"
                })
                remaining = remaining - groupCount
            else
                break
            end
        end
    end

    -- Resolve Geometry based on Mission Intent
    local intent = TCS.Config.Air.Defaults.INTENT[missionType] or TCS.Config.Air.Defaults.INTENT.CAP

    return {
        tower = "AIR",
        manifest = manifest,
        coalition = side,
        geometry = {
            type = "A2A_OFFSET",
            anchor = params.anchor,
            minNm = params.minNm or intent.minNm,
            maxNm = params.maxNm or intent.maxNm,
            arc = intent.arc
        },
        behavior = { 
            mode = params.interaction or missionType, 
            target = params.anchor,
            groupTarget = params.group 
        }
    }
end

env.info("TCS(TOWER.AIR): ready")