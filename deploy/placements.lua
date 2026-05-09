---------------------------------------------------------------------
-- TCS DEPLOY: PLACEMENTS
-- Responsible for terrain validation and tactical coordinate solving.
-- Prevents units from spawning in inappropriate terrain.
---------------------------------------------------------------------
env.info("TCS(DEPLOY.PLACEMENTS): loading")

TCS = TCS or {}
TCS.Placements = TCS.Placements or {}

local function NM_TO_METERS(nm) return nm * 1852 end

function TCS.Placements.IsTerrainAppropriate(coord, domain)
    if not coord then return false end
    local pos = { x = coord.x, y = coord.z or coord.y }
    local surfaceType = land.getSurfaceType(pos)

    if domain == "LAND" then
        if surfaceType ~= land.SurfaceType.LAND then return false end

        local height = land.getHeight(pos)
        local offset = 15
        local checkPoints = {
            {x = pos.x + offset, y = pos.y},
            {x = pos.x - offset, y = pos.y},
            {x = pos.x, y = pos.y + offset},
            {x = pos.x, y = pos.y - offset}
        }
        for _, p in ipairs(checkPoints) do
            local h = land.getHeight(p)
            if math.abs(height - h) > 2.0 then return false end
        end

        local isObstructed = false
        local vol = { id = world.VolumeType.SPHERE, params = { point = {x = coord.x, y = height, z = coord.z or coord.y}, radius = 40 } }
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

    if not anchorPos then
        env.error("TCS(PLACEMENTS): Could not resolve anchor position.")
        return nil
    end

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

    env.error(string.format("TCS(PLACEMENTS): Failed to find valid %s terrain at %s", domain, tostring(anchor)))
    return nil
end

env.info("TCS(DEPLOY.PLACEMENTS): ready")