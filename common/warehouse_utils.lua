---------------------------------------------------------------------
-- TCS COMMON: WAREHOUSE UTILITIES
-- Bridge between TCS Inventory and physical DCS Warehouse objects.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Common = TCS.Common or {}
TCS.Common.Warehouse = {}

--- Finds the nearest friendly airbase/warehouse to a coordinate.
function TCS.Common.Warehouse.GetNearestSource(coord, coalitionSide)
    local point = coord:GetVec2()
    local bestBase = nil
    local bestDist = 1000000 -- Meters

    local airbases = coalition.getAirbases(coalitionSide)
    for _, ab in ipairs(airbases) do
        local abPos = ab:getPoint()
        local dist = ((abPos.x - point.x)^2 + (abPos.z - point.y)^2)^0.5
        if dist < bestDist then
            bestDist = dist
            bestBase = ab
        end
    end
    return bestBase
end

--- Checks if a specific unit type is available in a warehouse.
function TCS.Common.Warehouse.GetUnitCount(warehouseObj, unitType)
    if not warehouseObj or not warehouseObj.getInventory then return 0 end
    local inv = warehouseObj:getInventory()
    -- DCS tracks units in warehouses by their unit type string
    return inv and inv[unitType] or 0
end

--- Physically removes units from a DCS warehouse.
function TCS.Common.Warehouse.RemoveUnits(warehouseObj, unitType, count)
    if not warehouseObj or not warehouseObj.getInventory then return end
    -- Use DCS API to deduct units from the physical object
    warehouseObj:setInventory(unitType, math.max(0, TCS.Common.Warehouse.GetUnitCount(warehouseObj, unitType) - count))
end

env.info("TCS(COMMON.WAREHOUSE): ready")