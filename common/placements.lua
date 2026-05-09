---------------------------------------------------------------------
-- TCS COMMON: PLACEMENTS
-- Tools for Architects to validate terrain and solve coordinates.
---------------------------------------------------------------------
env.info("TCS(COMMON.PLACEMENTS): loading")

TCS = TCS or {}
TCS.Architect = TCS.Architect or {}
TCS.Architect.Placements = {}

--- Checks if the surface at a coordinate is appropriate for the unit's domain.
function TCS.Architect.Placements.IsTerrainAppropriate(coord, domain, footprintRadius, conditions)
    if not coord then return false end
    local pos = { x = coord.x, y = coord.z or coord.y }
    local surfaceType = land.getSurfaceType(pos)

    if domain == "AIR" then return true end

    if domain == "SEA" then
        return (surfaceType == land.SurfaceType.WATER or surfaceType == land.SurfaceType.SHALLOW_WATER)
    end

    -- LAND / AIRDEF / LOGISTICS
    if surfaceType ~= land.SurfaceType.LAND then return false end

    local radius = footprintRadius or 30
    local height = land.getHeight(pos)

    -- Slope Check (Approx 11-degree max tolerance)
    local checkPoints = {
        {x = pos.x + radius, y = pos.y},
        {x = pos.x - radius, y = pos.y},
        {x = pos.x, y = pos.y + radius},
        {x = pos.x, y = pos.y - radius}
    }
    for _, p in ipairs(checkPoints) do
        if math.abs(height - land.getHeight(p)) > (radius * 0.20) then
            return false
        end
    end

    -- Concealment / Scenery Check
    local wantHidden = conditions and conditions.hidden
    local searchRadius = wantHidden and (radius * 1.5) or radius
    local sceneryCount = 0
    
    local vol = {
        id = world.VolumeType.SPHERE,
        params = { point = {x = coord.x, y = height, z = coord.z or coord.y}, radius = searchRadius }
    }
    world.searchObjects(Object.Category.SCENERY, vol, function(obj)
        sceneryCount = sceneryCount + 1
        if not wantHidden then return false end -- Stop searching early if we just want clear terrain
        return true -- Keep counting to ensure dense cover
    end)

    if wantHidden and sceneryCount < 3 then return false end -- Not enough cover, keep looking
    if not wantHidden and sceneryCount > 0 then return false end -- Too much cover, keep looking

    return true
end

--- Solves for a valid map coordinate within the requested geometric constraints.
function TCS.Architect.Placements.SolveCoordinate(anchorCoord, minNm, maxNm, hdg, arc, domain, footprintRadius, conditions)
    local anchorPos = nil
    
    -- Safely extract {x, y, z} regardless of the object type (Coordinate, Zone, Vec3)
    if type(anchorCoord) == "table" then
        if anchorCoord.GetVec3 then
            local v = anchorCoord:GetVec3()
            if v and v.x then anchorPos = v end
        elseif anchorCoord.GetCoordinate then
            local c = anchorCoord:GetCoordinate()
            if c and c.GetVec3 then
                local v = c:GetVec3()
                if v and v.x then anchorPos = v end
            end
        end
        if not anchorPos and anchorCoord.x then
            anchorPos = { x = anchorCoord.x, y = anchorCoord.y or 0, z = anchorCoord.z or anchorCoord.y }
        end
        if not anchorPos and anchorCoord.point and anchorCoord.point.x then
            anchorPos = { x = anchorCoord.point.x, y = anchorCoord.point.y or 0, z = anchorCoord.point.z or anchorCoord.point.y }
        end
    end

    if not anchorPos or not anchorPos.x or not anchorPos.z then
        env.warning("TCS(PLACEMENTS): Invalid coordinate passed to SolveCoordinate. Aborting solver.")
        return nil
    end

    local actualMin = minNm or 0
    local actualMax = maxNm or 0

    local maxAttempts = (actualMin == 0 and actualMax == 0) and 1 or 30

    for i = 1, maxAttempts do
        local dist = math.random(actualMin * 1852, actualMax * 1852)
        local varHdg = ((hdg or 0) + math.random(-(arc or 360)/2, (arc or 360)/2)) % 360
        local rad = math.rad(varHdg)
        
        local candidate = { x = anchorPos.x + dist * math.cos(rad), y = 0, z = anchorPos.z + dist * math.sin(rad) }

        if TCS.Architect.Placements.IsTerrainAppropriate(candidate, domain, footprintRadius, conditions) then
            candidate.y = land.getHeight({x = candidate.x, y = candidate.z})
            return candidate
        end
    end
    return nil
end

env.info("TCS(COMMON.PLACEMENTS): ready")
