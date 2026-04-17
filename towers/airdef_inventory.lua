---------------------------------------------------------------------
-- TCS TOWER: AIRDEF INVENTORY
-- Tracks theater-wide supply against consumption for SAM assets.
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.AirDef = TCS.Towers.AirDef or {}
TCS.Towers.AirDef.Inventory = { RED = {}, BLUE = {} }

function TCS.Towers.AirDef.Inventory.Consume(side, unitId, count, anchor)
    if TCS.Common.Config and TCS.Common.Config.LOGISTICS_ENABLED == false then return end

    local pool = (side == coalition.side.RED) and "RED" or "BLUE"
    local current = TCS.Towers.AirDef.Inventory[pool][unitId] or 999
    TCS.Towers.AirDef.Inventory[pool][unitId] = math.max(0, current - count)
end

function TCS.Towers.AirDef.Inventory.Request(side, unitId, count, anchor)
    if TCS.Common.Config and TCS.Common.Config.LOGISTICS_ENABLED == false then return true end

    local pool = (side == coalition.side.RED) and "RED" or "BLUE"
    local current = TCS.Towers.AirDef.Inventory[pool][unitId] or 999
    return current >= count
end

function TCS.Towers.AirDef.Inventory.SetSupply(side, unitId, count)
    local pool = (side == coalition.side.RED) and "RED" or "BLUE"
    TCS.Towers.AirDef.Inventory[pool][unitId] = count
end

env.info("TCS(TOWER.AIRDEF.INVENTORY): ready")