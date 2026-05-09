---------------------------------------------------------------------
-- TCS DEPLOY: GEOMETRY
-- Math utilities for directional spawning and offsets.
---------------------------------------------------------------------
env.info("TCS(DEPLOY.GEOMETRY): loading")

TCS = TCS or {}
TCS.Deploy = TCS.Deploy or {}
TCS.Deploy.Geometry = {}

--- Calculates a spawn coordinate based on an anchor and directional constraints.
function TCS.Deploy.Geometry.GetDirectionalPoint(anchor, minNm, maxNm, heading, arc)
    local dist = math.random(minNm or 5, maxNm or 15) * 1852
    local baseHdg = heading or math.random(0, 359)
    local arcWidth = arc or 0

    local finalHdg = baseHdg
    if arcWidth > 0 then
        local offset = (math.random() * arcWidth) - (arcWidth / 2)
        finalHdg = (baseHdg + offset) % 360
    end

    return anchor:Translate(dist, finalHdg), (finalHdg + 180) % 360
end

--- Provides a simple spiral/jitter offset to prevent unit stacking.
function TCS.Deploy.Geometry.GetStackingOffset(index, spacing)
    local angle = index * 137.5 -- Golden angle
    local radius = math.sqrt(index) * (spacing or 150)
    return radius, angle
end

env.info("TCS(DEPLOY.GEOMETRY): ready")