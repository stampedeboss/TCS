---------------------------------------------------------------------
-- TCS CORE: PLACEMENTS
-- Responsible for terrain validation and tactical coordinate solving.
-- Prevents units (like SA-11s) from spawning in inappropriate terrain.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Placements = TCS.Placements or {}

local function NM_TO_METERS(nm) return nm * 1852 end

--- Checks if the surface at a coordinate is appropriate for the unit's domain.
-- @param coord Vec3/Vec2
-- @param domain "LAND", "SEA", "AIR"
-- @return boolean
function TCS.Placements.IsTerrainAppropriate(coord, domain)
    if not coord then return false end
    local pos = { x = coord.x, y = coord.z or coord.y } -- Normalize to Vec2 for DCS land calls
    local surfaceType = land.getSurfaceType(pos)

    if domain == "LAND" then
        -- 1. Basic Surface Type: Must be LAND. 
        -- Reject Water (2), Shallow Water (1), Road (3), and Runway (4).
        if surfaceType ~= land.SurfaceType.LAND then 
            env.info("TCS(PLACEMENTS): Rejecting coordinate - Invalid surface type: " .. tostring(surfaceType))
            return false
        end

        -- 2. Slope Check: Ensure the ground is relatively flat (essential for SAM batteries)
        local height = land.getHeight(pos)
        local offset = 15 -- Check 15m out
        local checkPoints = {
            {x = pos.x + offset, y = pos.y},
            {x = pos.x - offset, y = pos.y},
            {x = pos.x, y = pos.y + offset},
            {x = pos.x, y = pos.y - offset}
        }
        for _, p in ipairs(checkPoints) do
            local h = land.getHeight(p)
            if math.abs(height - h) > 2.0 then -- Tighten slope tolerance
                return false
            end
        end

        -- 3. Urban/Forest Check: Check for scenery objects (buildings/trees) in a tight radius
        local isObstructed = false
        local vol = {
            id = world.VolumeType.SPHERE,
            params = { point = {x = coord.x, y = height, z = coord.z or coord.y}, radius = 40 }
        }
        world.searchObjects(Object.Category.SCENERY, vol, function(obj)
            isObstructed = true
            return false 
        end)
        if isObstructed then return false end

    elseif domain == "SEA" then
        if surfaceType ~= land.SurfaceType.WATER and surfaceType ~= land.SurfaceType.SHALLOW_WATER then
            return false
        end
    end

    return true
end

--- Solves for a coordinate based on distance and bearing arcs, with terrain validation.
-- @param params Spawning parameters (anchor, minNm, maxNm, ingressHdg, ingressArc, domain)
-- @return Vec3 or nil
function TCS.Placements.SolveCoordinate(params)
    local anchor = params.anchor
    local minNm = params.minNm or 1
    local maxNm = params.maxNm or 2
    local hdg = params.ingressHdg or math.random(0, 359)
    local arc = params.ingressArc or 180
    local domain = params.domain or "LAND"

    -- 1. Resolve Anchor to Point
    local anchorPos = nil
    if type(anchor) == "string" then
        local zone = trigger.misc.getZone(anchor)
        if zone then anchorPos = zone.point end
    elseif type(anchor) == "table" then
        -- Support for MOOSE COORDINATE or raw Vec3
        anchorPos = anchor.GetVec3 and anchor:GetVec3() or anchor
    end

    if not anchorPos then
        env.error("TCS(PLACEMENTS): Could not resolve anchor position.")
        return nil
    end

    -- 2. Iterative Search for Valid Terrain
    -- We use a limited number of attempts to find suitable terrain within the arc.
    local maxAttempts = 20
    for i = 1, maxAttempts do
        local dist = math.random(NM_TO_METERS(minNm), NM_TO_METERS(maxNm))
        -- Heading is calculated relative to the provided ingress path
        local varHdg = (hdg + math.random(-arc/2, arc/2)) % 360
        local rad = math.rad(varHdg)
        
        -- DCS uses X (North) and Z (East)
        local candidate = {
            x = anchorPos.x + dist * math.cos(rad),
            y = 0, -- Altitude to be resolved
            z = anchorPos.z + dist * math.sin(rad)
        }

        if TCS.Placements.IsTerrainAppropriate(candidate, domain) then
            -- Resolve final height
            candidate.y = land.getHeight({x = candidate.x, y = candidate.z})
            return candidate
        end
    end

    -- 3. Fallback
    -- If all attempts fail, we log a warning. For Land units like SA-11,
    -- spawning in water is worse than not spawning at all.
    env.error(string.format("TCS(PLACEMENTS): Failed to find valid %s terrain at %s", domain, tostring(anchor)))
    return nil
end

env.info("TCS(CORE.PLACEMENTS): Terrain-aware placement engine initialized.")