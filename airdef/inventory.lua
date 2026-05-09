---------------------------------------------------------------------
-- TCS TOWER: AIRDEF INVENTORY
-- Tracks theater-wide supply against consumption for SAM assets.
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.AirDef = TCS.AirDef or {}
TCS.AirDef.Inventory = { RED = {}, BLUE = {} }

function TCS.AirDef.Inventory.Consume(side, unitId, count, anchor)
    if TCS.Common and TCS.Common.Defaults and TCS.Common.Defaults.LOGISTICS_ENABLED == false then return end

    local defs = TCS.AirDef and TCS.AirDef.Defaults or {}

    local pool = (side == coalition.side.RED) and "RED" or "BLUE"
    local current = TCS.AirDef.Inventory[pool][unitId] or defs.FALLBACK_INVENTORY or 999
    TCS.AirDef.Inventory[pool][unitId] = math.max(0, current - count)
end

function TCS.AirDef.Inventory.Request(side, unitId, count, anchor)
    if TCS.Common and TCS.Common.Defaults and TCS.Common.Defaults.LOGISTICS_ENABLED == false then return true end
    local defs = TCS.AirDef and TCS.AirDef.Defaults or {}

    local pool = (side == coalition.side.RED) and "RED" or "BLUE"
    local current = TCS.AirDef.Inventory[pool][unitId] or defs.FALLBACK_INVENTORY or 999
    return current >= count
end

function TCS.AirDef.Inventory.SetSupply(side, unitId, count)
    local pool = (side == coalition.side.RED) and "RED" or "BLUE"
    TCS.AirDef.Inventory[pool][unitId] = count
end

env.info("TCS(TOWER.AIRDEF.INVENTORY): ready")