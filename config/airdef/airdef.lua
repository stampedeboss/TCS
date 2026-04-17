---------------------------------------------------------------------
-- TCS TOWER: AIRDEF
-- Main entry point for Fixed Sites and Missile Batteries.
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.AirDef = TCS.Towers.AirDef or {}

function TCS.Towers.AirDef.PrepareRequisition(samType, params)
    env.info(string.format("TCS(AIRDEF): Preparing requisition for type '%s' (Tier: %s)", tostring(samType), tostring(params.skill or "G")))
    local battery, isMobile = TCS.Towers.AirDef.GetBattery(samType, params.skill)
    local manifest = {}

    if not battery or not battery.layout then
        env.warning(string.format("TCS(AIRDEF): Failed to find layout for SAM type '%s' (Tier: %s). Requisition aborted.", tostring(samType), tostring(params.skill)))
        -- Return empty spec to prevent Dispatcher crash
        return { tower = "AIRDEF", manifest = {}, coalition = params.coalition, geometry = {}, behavior = {} }
    end

    -- Fulfill Doctrinal Layout
    for _, component in ipairs(battery.layout) do
        local pool = TCS.Towers.AirDef.Query({
            category = component.category,
            coalition = params.coalition,
            role = component.role,
            skill = params.skill or "G",
            samType = component.sam_type or samType -- Respect family override for X-Tier Layered sites
        })

        if #pool > 0 then
            local selected = pool[math.random(#pool)]
            env.info(string.format("TCS(AIRDEF): Selected component '%s' for role '%s'", selected.id, component.role))

            -- Motor Pool / Inventory Handshake
            if TCS.Towers.AirDef.Inventory and TCS.Towers.AirDef.Inventory.Request(params.coalition, selected.id, 1, params.anchor) then
                TCS.Towers.AirDef.Inventory.Consume(params.coalition, selected.id, 1, params.anchor)
                
                table.insert(manifest, {
                    types = { selected.unit_type },
                    count = 1,
                    id = selected.id,
                    offset = { x = component.x, y = component.y, hdg = component.hdg },
                    role = component.role
                })
            end
        else
            env.warning(string.format("TCS(AIRDEF): No units found in catalog for category '%s' role '%s' (Side: %s)", component.category, component.role, tostring(params.coalition)))
        end
    end

    -- Resolve Silent Radar Behavior based on Skill/Threat Tier
    local silentDist = -1
    local skill = params.skill or "G"
    local adDefaults = (TCS.Config and TCS.Config.AirDef and TCS.Config.AirDef.Defaults)
    local baseSilent = adDefaults and adDefaults.RADAR_ACTIVATE_NM or 15

    -- Check if an explicit ambush radius was requested (e.g. via TriggerSystemPopupSam)
    if params.ambushRadiusNm then
        silentDist = params.ambushRadiusNm
    else
        if skill == "G" then
            silentDist = baseSilent
        elseif skill == "H" then
            silentDist = baseSilent * 0.8 -- Approx 12 NM
        elseif skill == "X" then
            silentDist = baseSilent * 0.5 -- Approx 7.5 NM (Ambush)
        end
    end

    env.info(string.format("TCS(AIRDEF): Requisition complete. Manifest contains %d components.", #manifest))

    return {
        tower = "AIRDEF",
        manifest = manifest,
        isMobile = isMobile,
        coalition = params.coalition,
        geometry = {
            type = "DOCTRINAL",
            anchor = params.anchor,
            minNm = params.minNm or 0,
            maxNm = params.maxNm or (adDefaults and adDefaults.GEOMETRY.MAX_SPAWN_NM) or 2,
            ingressHdg = params.ingressHdg,
            ingressArc = params.ingressArc
        },
        behavior = { 
            mode = "STATIC", 
            roe = params.ambushRadiusNm and "WEAPON_HOLD" or "WEAPON_FREE", -- Hold fire if it's an ambush
            silentDistance = silentDist
        }
    }
end

env.info("TCS(TOWER.AIRDEF): ready")