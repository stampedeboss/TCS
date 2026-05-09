---------------------------------------------------------------------
-- TCS TOWER: AIRDEF
-- Main entry point for Fixed Sites and Missile Batteries.
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.AirDef = TCS.AirDef or {}

--- Returns the tiered layout for a specific SAM type.
function TCS.AirDef.GetBattery(samType, tier)
    local catalog = TCS.AirDef and TCS.AirDef.Catalog
    local defs = TCS.AirDef and TCS.AirDef.Defaults or {}
    if not catalog then return nil, false, samType end

    local missionYear = (TCS.Common and TCS.Common.Defaults and TCS.Common.Defaults.ServiceYearLimit) or defs.FALLBACK_YEAR or 2040
    local subs = TCS.AirDef.Substitutions or {}

    -- Cascade down the substitution matrix if out of era
    while catalog[samType] and catalog[samType].service_date and catalog[samType].service_date > missionYear do
        local fallbacks = subs[samType]
        local downgraded = false
        if fallbacks then
            for _, fallback in ipairs(fallbacks) do
                if catalog[fallback] and (not catalog[fallback].service_date or catalog[fallback].service_date <= missionYear) then
                    env.info(string.format("TCS(AIRDEF): Era Downgrade - %s replaced by %s (Year: %d)", samType, fallback, missionYear))
                    samType = fallback
                    downgraded = true
                    break
                end
            end
        end
        if not downgraded then break end -- No valid fallback found
    end

    local entry = catalog[samType]
    if not entry or not entry.layouts then return nil, false, samType end

    local isMobile = (entry.mobility == "MOBILE")
    local battery = entry.layouts[tier or "G"] or entry.layouts["G"] or entry.layouts[next(entry.layouts)]
    
    return battery, isMobile, samType
end

function TCS.AirDef.PrepareRequisition(samType, params)
    local battery, isMobile, finalSamType = TCS.AirDef.GetBattery(samType, params.threat or "H")
    samType = finalSamType or samType

    env.info(string.format("TCS(AIRDEF): Preparing requisition for type '%s' (Threat: %s)", tostring(samType), tostring(params.threat or "H")))
    local manifest = {}

    if not battery or not battery.layout then
        env.warning(string.format("TCS(AIRDEF): Failed to find layout for SAM type '%s' (Threat: %s). Requisition aborted.", tostring(samType), tostring(params.threat or "H")))
        -- Return empty spec to prevent Dispatcher crash
        return { tower = "AIRDEF", manifest = {}, coalition = params.coalition, geometry = {}, behavior = {} }
    end

    local catalog = TCS.AirDef and TCS.AirDef.Catalog
    local defs = TCS.AirDef and TCS.AirDef.Defaults or {}
    local missionYear = (TCS.Common and TCS.Common.Defaults and TCS.Common.Defaults.ServiceYearLimit) or defs.FALLBACK_YEAR or 2040
    local subs = TCS.AirDef.Substitutions or {}

    -- Fulfill Doctrinal Layout
    for _, component in ipairs(battery.layout) do
        -- Bypass catalog queries and directly use the prepackaged layout
        local dcsUnitType = component.unit_type
        local compSamType = component.sam_type

        -- Process embedded era downgrades (e.g., SA-15 point defense in an SA-10 site during a 1980 mission)
        if compSamType and catalog and catalog[compSamType] and catalog[compSamType].service_date and catalog[compSamType].service_date > missionYear then
            local fallbacks = subs[compSamType]
            if fallbacks then
                for _, fallback in ipairs(fallbacks) do
                    if catalog[fallback] and (not catalog[fallback].service_date or catalog[fallback].service_date <= missionYear) then
                        -- Extract the LAUNCHER unit type from the fallback's basic 'A' layout
                        local fbEntry = catalog[fallback]
                        if fbEntry and fbEntry.layouts and fbEntry.layouts["A"] then
                            for _, fbComp in ipairs(fbEntry.layouts["A"].layout) do
                                if fbComp.category == "LAUNCHER" and fbComp.unit_type then
                                    env.info(string.format("TCS(AIRDEF): Embedded Era Downgrade - %s replaced by %s", compSamType, fallback))
                                    dcsUnitType = fbComp.unit_type
                                    break
                                end
                            end
                        end
                        break
                    end
                end
            end
        end

        if not dcsUnitType then
            env.warning(string.format("TCS(AIRDEF): Layout component missing 'unit_type' for %s", tostring(samType)))
        else
            -- Motor Pool / Inventory Handshake
            if TCS.AirDef.Inventory and TCS.AirDef.Inventory.Request(params.coalition, dcsUnitType, 1, params.anchor) then
                TCS.AirDef.Inventory.Consume(params.coalition, dcsUnitType, 1, params.anchor)
            end
            
            -- Add slight organic jitter
            local jX = math.random(defs.JITTER_POS_MIN or -5, defs.JITTER_POS_MAX or 5)
            local jY = math.random(defs.JITTER_POS_MIN or -5, defs.JITTER_POS_MAX or 5)
            local jHdg = math.rad(math.random(defs.JITTER_HDG_MIN or -10, defs.JITTER_HDG_MAX or 10))

            table.insert(manifest, {
                unit_type = dcsUnitType,
                role = component.role,
                category = component.category, -- RADAR, LAUNCHER, etc.
                isStatic = false,
                relativePos = { x = component.x + jX, y = component.y + jY },
                relativeHdg = math.rad(component.hdg or 0) + jHdg,
                -- Map Threat Tier back to DCS Internal AI Skill Level
                skill = (params.threat == "X") and "Excellent" or "High"
            })
        end
    end

    -- Resolve Silent Radar Behavior based on Skill/Threat Tier
    local silentDist = -1
    local threat = params.threat or "H"
    local baseSilent = defs.RADAR_ACTIVATE_NM or 15

    -- Check if an explicit silent/ambush radius was requested
    if params.silent then
        silentDist = params.silent
    else
        if threat == "H" then
            silentDist = baseSilent * (defs.SILENT_MULTIPLIER_HIGH or 0.8)
        elseif threat == "X" then
            silentDist = baseSilent * (defs.SILENT_MULTIPLIER_EXTREME or 0.5)
        end
    end

    env.info(string.format("TCS(AIRDEF): Requisition complete. Manifest contains %d components.", #manifest))

    -- Compile final behavior, merging in any mission-specific overrides (like ROE or Alarm States)
    local finalBehavior = { 
        mode = "STATIC", 
        roe = params.silent and "WEAPON_HOLD" or "WEAPON_FREE", 
        silentDistance = silentDist
    }
    if params.behavior and type(params.behavior) == "table" then
        for k, v in pairs(params.behavior) do finalBehavior[k] = v end
    end

    return {
        tower = "AIRDEF",
        manifest = manifest,
        isMobile = isMobile,
        coalition = params.coalition,
        geometry = {
            type = "DOCTRINAL",
            anchor = params.anchor,
            minNm = params.minNm or 0,
            maxNm = params.maxNm or defs.MAX_SPAWN_NM or 2,
            ingressHdg = params.ingressHdg,
            ingressArc = params.ingressArc
        },
        behavior = finalBehavior
    }
end

env.info("TCS(TOWER.AIRDEF): ready")