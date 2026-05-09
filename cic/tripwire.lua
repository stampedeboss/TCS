---------------------------------------------------------------------
-- TCS CIC: TRIPWIRE
-- Monitors zones and ME drawn lines to trigger defensive reactions.
---------------------------------------------------------------------
env.info("TCS(CIC.TRIPWIRE): loading")

TCS = TCS or {}
TCS.CIC = TCS.CIC or {}
TCS.CIC.Tripwire = {}

TCS.CIC.Tripwire.Lines = {}
TCS.CIC.Tripwire.Zones = {}
TCS.CIC.Tripwire.TrackedUnits = {}

-- MOOSE Set to efficiently monitor airborne targets
TCS.CIC.Tripwire.AirSet = SET_UNIT:New():FilterCategories("plane", "helicopter"):FilterStart()

-- Math helper: 2D Line Segment Intersection F10 Map
local function ccw(A, B, C)
    return (C.y - A.y) * (B.x - A.x) > (B.y - A.y) * (C.x - A.x)
end
local function intersect(A, B, C, D)
    return ccw(A, C, D) ~= ccw(B, C, D) and ccw(A, B, C) ~= ccw(A, B, D)
end

--- Registers a Line Tripwire
function TCS.CIC.Tripwire.AddLine(name, vec2A, vec2B, targetCoalition, config)
    -- No log output here to prevent spamming the log 500 times.
    TCS.Logger.info("TCS(TRIPWIRE): Registered Line Tripwire '%s'", name)
    TCS.CIC.Tripwire.Lines[name] = { A = vec2A, B = vec2B, coalition = targetCoalition, config = config or {}, triggeredBy = {} }
end

--- Registers a Zone/Polygon Tripwire
function TCS.CIC.Tripwire.AddZone(zoneName, targetCoalition)
    local zone = ZONE:FindByName(zoneName)
    if zone then
        TCS.Logger.info("TCS(TRIPWIRE): Registered Zone Tripwire '%s'", zoneName)
        TCS.CIC.Tripwire.Zones[zoneName] = { zone = zone, coalition = targetCoalition, triggeredBy = {} }
    end
end

--- Parses DCS Mission Editor drawings for lines/polygons named "Tripwire"
function TCS.CIC.Tripwire.InitFromME()
    if not env.mission.drawings then return end
    local count = 0
    for _, layer in pairs(env.mission.drawings.layers or {}) do
        for _, obj in pairs(layer.objects or {}) do
            local name = obj.name and string.upper(obj.name) or ""
            if string.find(name, "TRIPWIRE") then
                -- Default to watching for BLUE intruders
                local targetSide = coalition.side.BLUE 
                if string.find(name, "BLUE") then targetSide = coalition.side.RED end
                
                if obj.primitiveType == "Line" and obj.points and #obj.points >= 2 then
                    for i = 1, #obj.points - 1 do
                        local p1 = {x = obj.mapX + obj.points[i].x, y = obj.mapY + obj.points[i].y}
                        local p2 = {x = obj.mapX + obj.points[i+1].x, y = obj.mapY + obj.points[i+1].y}
                        TCS.CIC.Tripwire.AddLine(obj.name .. "_seg_" .. i, p1, p2, targetSide)
                        count = count + 1
                    end
                elseif obj.primitiveType == "Polygon" then
                    TCS.CIC.Tripwire.AddZone(obj.name, targetSide)
                    count = count + 1
                end
            end
        end
    end
    TCS.Logger.info("TCS(TRIPWIRE): Extracted %d tripwire segments from ME.", count)
end

--- Main Evaluation Loop
function TCS.CIC.Tripwire.Evaluate()
    TCS.CIC.Tripwire.AirSet:ForEachUnit(function(unit)
        if not unit:IsAlive() then return end
        
        local uName = unit:GetName()
        local currentPos = unit:GetVec2()
        local uCoalition = unit:GetCoalition()
        
        if not TCS.CIC.Tripwire.TrackedUnits[uName] then
            TCS.CIC.Tripwire.TrackedUnits[uName] = currentPos
            return
        end
        
        local lastPos = TCS.CIC.Tripwire.TrackedUnits[uName]
        
        for lineName, lineData in pairs(TCS.CIC.Tripwire.Lines) do
            if (not lineData.coalition) or (lineData.coalition == uCoalition) then
                if intersect(lineData.A, lineData.B, lastPos, currentPos) then
                    TCS.CIC.Tripwire.HandleCross(unit, lineName, lineData.coalition, lineData.config, lineData.triggeredBy)
                end
            end
        end
        
        for zoneName, zoneData in pairs(TCS.CIC.Tripwire.Zones) do
            if (not zoneData.coalition) or (zoneData.coalition == uCoalition) then
                if zoneData.zone:IsVec2InZone(currentPos) then
                    TCS.CIC.Tripwire.HandleCross(unit, zoneName, zoneData.coalition, {}, zoneData.triggeredBy)
                end
            end
        end
        
        TCS.CIC.Tripwire.TrackedUnits[uName] = currentPos
    end)
end

--- Centralized handler for when a unit crosses any tripwire zone/line
function TCS.CIC.Tripwire.HandleCross(unit, zoneName, targetCoalition, config, triggeredBy)
    if not unit or not unit:IsAlive() then return end

    local uName = unit:GetName()
    local uCoalition = unit:GetCoalition()
    local currentTime = timer.getTime()

    -- Check if the unit is the target coalition and hasn't triggered this line recently (5 min cooldown)
    if (not targetCoalition or targetCoalition == uCoalition) then
        if not triggeredBy[uName] or (currentTime - triggeredBy[uName]) > 300 then
            triggeredBy[uName] = currentTime -- Debounce
            TCS.Logger.info("TCS(TRIPWIRE): Tripwire '%s' CROSSED by %s", zoneName, uName)

            local cfg = config or {}
            local params = {
                borderId = cfg.borderId or zoneName,
                anchor = unit:GetVec2(),
                intruder = unit:GetGroup(),
                responseType = (type(cfg.onCross) == "string") and cfg.onCross or cfg.responseType,
                customMessage = cfg.customMessage
            }
            
            if type(cfg.onCross) == "function" then
                cfg.onCross(params)
            elseif TCS.CIC.Director and TCS.CIC.Director.HandleBorderViolation then
                TCS.CIC.Director.HandleBorderViolation(params)
            else
                -- Fallback to basic scramble
                if TCS.CIC.Director then TCS.CIC.Director.ScrambleIntercept(unit:GetGroup()) end
            end
        end
    end
end

-- Delay initialization slightly so Zones are fully registered by the engine
timer.scheduleFunction(function() TCS.CIC.Tripwire.InitFromME() end, {}, timer.getTime() + 5)
-- Run checking loop every 2 seconds
timer.scheduleFunction(function(args, time) TCS.CIC.Tripwire.Evaluate(); return time + 2 end, {}, timer.getTime() + 10)

env.info("TCS(CIC.TRIPWIRE): ready")