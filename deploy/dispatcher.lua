---------------------------------------------------------------------
-- TCS DEPLOY: DISPATCHER
-- Pipeline Manager: Translates requisitions into executable spawn orders.
---------------------------------------------------------------------
env.info("TCS(DEPLOY.DISPATCHER): loading")

TCS = TCS or {}
TCS.Dispatcher = {}

--- Central execution pipeline. Takes a fully formed blueprint recipe and executes it.
-- @param recipe table The composite manifest containing geometry, behavior, and blueprints.
-- @return string|number The ZoneID where the recipe was executed.
function TCS.Dispatcher.ExecuteRequisition(recipe)
    if not recipe or not recipe.geometry or not recipe.geometry.anchor then
        if TCS.Logger then TCS.Logger.error("TCS(DISPATCHER): Invalid requisition recipe.") end
        return nil
    end
    
    local anchor = recipe.geometry.anchor
    local finalCoord = anchor
    local zoneId = type(anchor) == "string" and anchor or tostring(math.random(10000, 99999))
    
    if type(anchor) == "string" then
        local z = ZONE:FindByName(anchor)
        if z then finalCoord = z:GetCoordinate() end
    elseif type(anchor) == "table" and anchor.GetCoordinate then
        finalCoord = anchor:GetCoordinate()
    end
    
    if not finalCoord or not finalCoord.GetVec3 then
        if TCS.Logger then TCS.Logger.error("TCS(DISPATCHER): Failed to resolve anchor for requisition.") end
        return nil
    end
    
    -- Update the recipe's anchor to the absolute coordinate for the Spawner
    recipe.geometry.anchor = finalCoord
    
    -- Register with CIC ZoneManager
    if TCS.CIC and TCS.CIC.ZoneManager then
        TCS.CIC.ZoneManager.RegisterZone(zoneId, finalCoord)
    end
    
    -- Hand off to the General (Spawner) for execution
    if TCS.Spawner and TCS.Spawner.SpawnFromBlueprint then
        TCS.Spawner.SpawnFromBlueprint(recipe, zoneId)
    else
        if TCS.Logger then TCS.Logger.error("TCS(DISPATCHER): Spawner module missing.") end
    end
    
    return zoneId
end

--- Resolves a geometric definition into a single, absolute spawn anchor point.
-- This is the core of the map-agnostic geometry engine.
-- @param geometry table The geometry object from a recipe.
-- @return Coordinate, number The resolved coordinate and the final ingress heading in radians.
function TCS.Dispatcher.ResolveAnchorPoint(geometry)
    if not geometry or not geometry.anchor then
        if TCS.Logger then TCS.Logger.error("TCS(DISPATCHER): Invalid geometry provided for anchor resolution.") end
        return nil, nil
    end

    local centerCoord = geometry.anchor
    if type(centerCoord) == "string" then
        local z = ZONE:FindByName(centerCoord)
        if z then centerCoord = z:GetCoordinate() end
    end

    if not centerCoord or not centerCoord.GetVec3 then
        if TCS.Logger then TCS.Logger.error("TCS(DISPATCHER): Could not resolve anchor to a valid coordinate: " .. tostring(geometry.anchor)) end
        return nil, nil
    end

    if geometry.type == "DIRECTIONAL_SPAWN" then
        local spawnPoint = nil
        local finalHdg = nil

        -- Attempt to use the Surveyor (Placements) to find a valid spot
        if TCS.Placements and TCS.Placements.SolveCoordinate then
            local solved = TCS.Placements.SolveCoordinate({
                anchor = centerCoord,
                minNm = geometry.minNm,
                maxNm = geometry.maxNm,
                ingressHdg = geometry.ingressHdg,
                ingressArc = geometry.ingressArc,
                domain = geometry.domain,
                conditions = { hidden = geometry.hidden }
            })
            if solved then spawnPoint = COORDINATE:NewFromVec3(solved) end
        end

        -- Fallback to raw math if surveyor fails or is not present
        if not spawnPoint then
            if TCS.Logger then TCS.Logger.warn("TCS(DISPATCHER): Surveyor failed or unavailable. Falling back to raw geometry.") end
            local min_m = (geometry.minNm or 5) * 1852
            local max_m = (geometry.maxNm or 10) * 1852
            local spawnDist = math.random(min_m, max_m)
            local baseHdg = geometry.ingressHdg or math.random(0, 359)
            local arc = geometry.ingressArc or 90
            finalHdg = baseHdg + math.random(-arc/2, arc/2)
            spawnPoint = centerCoord:Translate(spawnDist, finalHdg)
        end
        
        local ingressHdg = finalHdg and (finalHdg + 180) % 360 or spawnPoint:HeadingTo(centerCoord)
        return spawnPoint, math.rad(ingressHdg)
    end

    -- Default for "ANCHORED" type or others
    return centerCoord, math.rad(geometry.ingressHdg or 0)
end

--- Translates a relative blueprint into an absolute array of map coordinates.
-- @param blueprint table Array of {x, y, ...} relative offsets.
-- @param anchorCoord Coordinate The central geographic anchor for the Zone.
-- @param headingRad number The rotational ingress heading in radians.
-- @return table Array of absolute coordinates with inherited metadata.
function TCS.Dispatcher.TranslateBlueprint(blueprint, anchorCoord, headingRad)
    local absoluteLocations = {}
    headingRad = headingRad or 0

    if not anchorCoord or not anchorCoord.GetVec3 then
        if TCS.Logger then TCS.Logger.error("TCS(DISPATCHER): Translation failed. Invalid anchor coordinate.") end
        return absoluteLocations
    end

    local anchorVec = anchorCoord:GetVec3()

    for _, offset in ipairs(blueprint) do
        -- Rotate the relative x, y offsets by the given heading
        local rx = offset.x * math.cos(headingRad) - offset.y * math.sin(headingRad)
        local rz = offset.x * math.sin(headingRad) + offset.y * math.cos(headingRad)

        -- Translate the anchor point
        -- In DCS, X is North/South and Z is East/West (Y is altitude)
        local absCoord = COORDINATE:NewFromVec3({ x = anchorVec.x + rx, y = anchorVec.y, z = anchorVec.z + rz })

        table.insert(absoluteLocations, {
            coord = absCoord,
            metadata = offset -- Preserve any metadata like target type, escort assignment, etc.
        })
    end

    return absoluteLocations
end

env.info("TCS(DEPLOY.DISPATCHER): ready")