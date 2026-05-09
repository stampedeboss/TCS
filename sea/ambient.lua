---------------------------------------------------------------------
-- TCS SEA AMBIENT
-- Populates a designated Port zone with random shipping traffic.
---------------------------------------------------------------------
env.info("TCS(SEA.AMBIENT): loading")

TCS = TCS or {}
TCS.Sea = TCS.Sea or {}
TCS.Sea.Ambient = {}

--- Outfits a port zone with random inbound and static shipping traffic.
-- @param portZoneName string The name of the trigger zone in the Mission Editor representing the port.
-- @param params table Configuration parameters {count = 3, minNm = 10, maxNm = 40, coalition = coalition.side.RED}
function TCS.Sea.Ambient.OutfitPort(portZoneName, params)
    params = params or {}
    local count = params.count or 10
    local side = params.coalition or coalition.side.RED 
    local minDist = params.minNm or 10
    local maxDist = params.maxNm or 40
    local movingRatio = params.movingRatio or 0.25

    for i = 1, count do
        timer.scheduleFunction(function()
            local isMoving = math.random() <= movingRatio
            local searchRole = (math.random() > 0.7) and "PATROL" or "CARGO"
            local candidates = TCS.Sea.Catalog and TCS.Sea.Catalog.Query({role = searchRole}) or {}
            
            if #candidates > 0 then
                local shipDef = candidates[math.random(#candidates)]
                local recipe = {
                    tower = "SEA",
                    missionType = "AMBIENT",
                    category = Group.Category.SHIP,
                    coalition = side,
                    geometry = { domain = "SEA" }
                }
                
                if isMoving then
                    -- Spawn far out and advance into the port
                    recipe.blueprint = { {x = 0, y = 0, unitType = shipDef.unit_types[1], skill = "Average"} }
                    recipe.geometry.type = "DIRECTIONAL_SPAWN"
                    recipe.geometry.anchor = portZoneName
                    recipe.geometry.minNm = minDist
                    recipe.geometry.maxNm = maxDist
                    recipe.behavior = { mode = "ADVANCE", target = portZoneName, roe = "WEAPON_HOLD" }
                else
                    -- Spawn statically inside the port bounds
                    recipe.blueprint = { {x = 0, y = 0, unitType = shipDef.unit_types[1], isStatic = true, staticCategory = "Ships"} }
                    recipe.geometry.type = "DIRECTIONAL_SPAWN"
                    recipe.geometry.anchor = portZoneName
                    recipe.geometry.minNm = 0
                    recipe.geometry.maxNm = 2
                end
                
                if TCS.Dispatcher and TCS.Dispatcher.ExecuteRequisition then TCS.Dispatcher.ExecuteRequisition(recipe) end
            end
        end, {}, timer.getTime() + i)
    end
end

--- Outfits a linear shipping lane passing through a designated zone.
-- @param laneZoneName string The name of the trigger zone representing the center of the lane.
-- @param params table {count = 10, minNm = 20, maxNm = 80, laneHeading = 135, coalition = RED}
function TCS.Sea.Ambient.OutfitShippingLane(laneZoneName, params)
    params = params or {}
    local count = params.count or 10
    local side = params.coalition or coalition.side.RED 
    local minDist = params.minNm or 20
    local maxDist = params.maxNm or 80
    local movingRatio = params.movingRatio or 0.90
    local laneAxis = params.laneHeading
    
    for i = 1, count do
        timer.scheduleFunction(function()
            local isMoving = math.random() <= movingRatio
            local searchRole = (math.random() > 0.8) and "PATROL" or "CARGO"
            local candidates = TCS.Sea.Catalog and TCS.Sea.Catalog.Query({role = searchRole}) or {}
            if #candidates == 0 then return end
            
            local shipDef = candidates[math.random(#candidates)]
            local axis = laneAxis or math.random(0, 359)
            if math.random() > 0.5 then axis = (axis + 180) % 360 end
            
            local recipe = {
                tower = "SEA", missionType = "AMBIENT", category = Group.Category.SHIP, coalition = side,
                geometry = { domain = "SEA" }
            }
            
            if isMoving then
                recipe.blueprint = { {x = 0, y = 0, unitType = shipDef.unit_types[1], skill = "Average"} }
                recipe.geometry.type = "DIRECTIONAL_SPAWN"
                recipe.geometry.anchor = laneZoneName
                recipe.geometry.minNm = minDist
                recipe.geometry.maxNm = maxDist
                recipe.geometry.ingressHdg = axis
                recipe.behavior = { mode = "ADVANCE", target = laneZoneName, roe = "WEAPON_HOLD" }
            else
                recipe.blueprint = { {x = 0, y = 0, unitType = shipDef.unit_types[1], isStatic = true, staticCategory = "Ships"} }
                recipe.geometry.type = "DIRECTIONAL_SPAWN"
                recipe.geometry.anchor = laneZoneName
                recipe.geometry.minNm = 0
                recipe.geometry.maxNm = 5
                recipe.geometry.ingressHdg = axis
            end
            
            if TCS.Dispatcher and TCS.Dispatcher.ExecuteRequisition then TCS.Dispatcher.ExecuteRequisition(recipe) end
        end, {}, timer.getTime() + i)
    end
end

env.info("TCS(SEA.AMBIENT): ready")