---------------------------------------------------------------------
-- TCS COMMON: PLACEMENTS
-- Responsible for terrain validation and tactical coordinate solving.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Placements = TCS.Placements or {}

local function NM_TO_METERS(nm) return nm * 1852 end

--- Resolves a biased position for a specific capability tag.
-- @param anchor (Coordinate) The reference coordinate.
-- @param tag (string) The capability tag (e.g. "BAI", "SAM").
function TCS.Placements.ResolveBias(anchor, tag)
  if not anchor then return nil end
  return anchor
end

--- Checks if the surface at a coordinate is appropriate for the unit's domain.
-- Includes Surface Type, Slope, and Urban Obstruction validation.
function TCS.Placements.IsTerrainAppropriate(coord, domain)
    if not coord then return false end
    local pos = { x = coord.x, y = coord.z or coord.y }
    local surfaceType = land.getSurfaceType(pos)

    if domain == "LAND" then
        -- 1. Surface Type (Reject Water, Shallow Water, Road, Runway)
        if surfaceType ~= land.SurfaceType.LAND then 
            return false
        end

        -- 2. Slope Check (Reject cliffs/steep hills for ground units)
        local height = land.getHeight(pos)
        local offset = 15
        local checkPoints = {
            {x = pos.x + offset, y = pos.y},
            {x = pos.x - offset, y = pos.y},
            {x = pos.x, y = pos.y + offset},
            {x = pos.x, y = pos.y - offset}
        }
        for _, p in ipairs(checkPoints) do
            if math.abs(height - land.getHeight(p)) > 2.0 then return false end
        end

        -- 3. Obstruction Check (Reject Urban/Forest/Scenery)
        local isObstructed = false
        local vol = {
            id = world.VolumeType.SPHERE,
            params = { point = {x = coord.x, y = height, z = coord.z or coord.y}, radius = 40 }
        }
        world.searchObjects(Object.Category.SCENERY, vol, function()
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

--- Iteratively searches for valid terrain within an arc.
function TCS.Placements.SolveCoordinate(params)
    local anchor = params.anchor
    local minNm = params.minNm or 1
    local maxNm = params.maxNm or 2
    local hdg = params.ingressHdg or math.random(0, 359)
    local arc = params.ingressArc or 180
    local domain = params.domain or "LAND"

    local anchorPos = nil
    if type(anchor) == "string" then
        local zone = trigger.misc.getZone(anchor)
        if zone then anchorPos = zone.point end
    elseif type(anchor) == "table" then
        anchorPos = anchor.GetVec3 and anchor:GetVec3() or anchor
    end

    if not anchorPos then return nil end

    local maxAttempts = 20
    for i = 1, maxAttempts do
        local dist = math.random(NM_TO_METERS(minNm), NM_TO_METERS(maxNm))
        local varHdg = (hdg + math.random(-arc/2, arc/2)) % 360
        local rad = math.rad(varHdg)
        
        local candidate = {
            x = anchorPos.x + dist * math.cos(rad),
            y = 0,
            z = anchorPos.z + dist * math.sin(rad)
        }

        if TCS.Placements.IsTerrainAppropriate(candidate, domain) then
            candidate.y = land.getHeight({x = candidate.x, y = candidate.z})
            return candidate
        end
    end
    return nil
end