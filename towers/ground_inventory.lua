---------------------------------------------------------------------
-- TCS TOWER: GROUND INVENTORY
-- Tracks theater-wide supply against consumption for Ground assets.
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.Ground = TCS.Towers.Ground or {} -- Ensure parent table exists
TCS.Towers.Ground.Inventory = { RED = {}, BLUE = {} } -- Initialize inventory pools

--- Deducts units from the motor pool.
-- @param anchor (Coordinate, optional) Used to locate physical warehouse.
function TCS.Towers.Ground.Inventory.Consume(side, unitId, count, anchor)
    -- Bypass if logistics is disabled
    if TCS.Common.Config and TCS.Common.Config.LOGISTICS_ENABLED == false then
        return
    end

    -- 1. Physical Consumption (DCS Warehouse)
    if anchor and TCS.Common.Warehouse then
        local source = TCS.Common.Warehouse.GetNearestSource(anchor, side)
        if source then
            -- For simplicity, we assume unitId maps to unit type for now
            TCS.Common.Warehouse.RemoveUnits(source:getWarehouse(), unitId, count)
        end
    end

    -- 2. Virtual Consumption (Theater Reserve)
    local pool = (side == coalition.side.RED) and "RED" or "BLUE"
    local current = TCS.Towers.Ground.Inventory[pool][unitId] or 999 -- Default high
    
    TCS.Towers.Ground.Inventory[pool][unitId] = math.max(0, current - count)
    
    if TCS.Towers.Ground.Inventory[pool][unitId] == 0 then
        env.warning(string.format("TCS(GROUND.INVENTORY): Motor Pool exhausted for %s", unitId))
    end
end

--- Checks if units are available in the pool.
-- @param anchor (Coordinate, optional) Used to check physical warehouse.
function TCS.Towers.Ground.Inventory.Request(side, unitId, count, anchor)
    -- Always grant request if logistics is disabled
    if TCS.Common.Config and TCS.Common.Config.LOGISTICS_ENABLED == false then
        return true
    end

    -- 1. Check Physical Stock if anchor is present
    if anchor and TCS.Common.Warehouse then
        local source = TCS.Common.Warehouse.GetNearestSource(anchor, side)
        if source and TCS.Common.Warehouse.GetUnitCount(source:getWarehouse(), unitId) >= count then
            return true
        end
    end

    -- 2. Fallback to Virtual Theater Reserve
    local pool = (side == coalition.side.RED) and "RED" or "BLUE"
    local current = TCS.Towers.Ground.Inventory[pool][unitId] or 999
    
    if current >= count then
        return true
    end
    return false, current
end

--- Initializes the theater pool counts.
function TCS.Towers.Ground.Inventory.SetSupply(side, unitId, count)
    local pool = (side == coalition.side.RED) and "RED" or "BLUE"
    TCS.Towers.Ground.Inventory[pool][unitId] = count
end

env.info("TCS(TOWER.GROUND.INVENTORY): ready")