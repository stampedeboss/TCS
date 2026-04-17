---------------------------------------------------------------------
-- TCS COMMON: SCENARIO GEOMETRY
-- Math utilities for directional spawning and offsets.
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Common = TCS.Common or {}
TCS.Common.Geometry = {}

--- Calculates a spawn coordinate based on an anchor and directional constraints.
function TCS.Common.Geometry.GetDirectionalPoint(anchor, minNm, maxNm, heading, arc)
    local min = minNm or TCS.Config.Ground.Defaults.GEOMETRY.DEFAULT_SPAWN_RADIUS_NM
    local max = maxNm or (min + 10)
    
    -- World-Class Precision: Use float randomization for continuous distance
    local dist = (min + (math.random() * (max - min))) * 1852
    
    local baseHdg = heading or math.random(0, 359)
    local arcWidth = arc or 0

    -- Apply jitter within the arc
    local finalHdg = baseHdg
    if arcWidth and arcWidth > 0 then
        local offset = (math.random() * arcWidth) - (arcWidth / 2)
        finalHdg = (baseHdg + offset) % 360
    end

    -- Target translated by the calculated distance and bearing
    return anchor:Translate(dist, finalHdg), (finalHdg + 180) % 360
end

--- Provides a simple spiral/jitter offset to prevent unit stacking.
function TCS.Common.Geometry.GetStackingOffset(index, spacing)
    local angle = index * 137.5 -- Golden angle
    local radius = math.sqrt(index) * (spacing or 150)
    return radius, angle
end

env.info("TCS(COMMON.GEOMETRY): ready")