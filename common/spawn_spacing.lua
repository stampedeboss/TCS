---------------------------------------------------------------------
-- TCS COMMON: SPAWN SPACING
-- Calculates formation offsets for group unit placement.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Common = TCS.Common or {}
TCS.Common.SpawnSpacing = {}

function TCS.Common.SpawnSpacing.GetPoints(formation, count, spacing)
    local points = {}
    local s = spacing or 50
    
    if formation == "WEDGE" or formation == "VEE" then
        -- Tactical spread for better arcs of fire
        for i = 0, (count - 1) do
            local row = math.floor(math.sqrt(i + 0.5))
            local col = i - row * row
            local x = -row * s
            local y = (col - row / 2) * s
            
            -- Reverse Y for VEE if needed, though WEDGE is usually best for AI
            table.insert(points, { x = x, y = y })
        end
    else
        -- Default: COLUMN (simple linear offset behind the leader)
        -- Note: This is poor for engagement but good for roads
        for i = 0, (count - 1) do
            table.insert(points, {
                x = -(i * s),
                y = 0
            })
        end
    end

    return points
end

env.info("TCS(COMMON.SPAWN_SPACING): ready")