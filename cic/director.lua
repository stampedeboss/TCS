---------------------------------------------------------------------
-- TCS CIC: DIRECTOR
-- The Theater Commander. Manages macroscopic AI behavior, routing, 
-- intercepts, and IADS posture across the entire theater.
---------------------------------------------------------------------
env.info("TCS(CIC.DIRECTOR): loading")

TCS = TCS or {}
TCS.CIC = TCS.CIC or {}
TCS.CIC.Director = {}

--- Commands a group (or list of groups) to advance on a specific zone.
function TCS.CIC.Director.ExecuteAdvance(groups, targetZoneName)
    if not groups or not targetZoneName then return end
    
    -- Resolve the target zone using MOOSE or fallback to DCS
    local targetZone = ZONE:FindByName(targetZoneName)
    if not targetZone then
        local dcsZone = trigger.misc.getZone(targetZoneName)
        if dcsZone then
            targetZone = ZONE_RADIUS:New(targetZoneName, {x = dcsZone.point.x, y = dcsZone.point.z}, dcsZone.radius)
        end
    end
    
    if not targetZone then
        TCS.Logger.error("TCS(DIRECTOR): ExecuteAdvance failed. Target zone '%s' not found.", targetZoneName)
        return
    end

    for _, group in ipairs(groups) do
        if group and group:IsAlive() then
            TCS.Logger.info("TCS(DIRECTOR): Ordering group '%s' to ADVANCE on '%s'", group:GetName(), targetZoneName)
            
            if group:IsGround() then
                -- Route to the target zone using roads where possible, at 40 km/h
                group:RouteGroundTo(targetZone:GetCoordinate(), 40, "On Road")
            elseif group:IsAir() then
                group:RouteToVec2(targetZone:GetVec2(), group:GetSpeedMax() * 0.8)
            elseif group:IsShip() then
                group:RouteToVec2(targetZone:GetVec2(), group:GetSpeedMax())
            end
        end
    end
end

--- FUTURE THEATER COMMANDS ---

--- Creates a polygonal Killbox (Corridor) between a breach point and an airbase.
function TCS.CIC.Director.CreateKillboxCorridor(breachVec2, airbaseVec2, widthMeters, offsetMeters)
    local vec = { x = airbaseVec2.x - breachVec2.x, y = airbaseVec2.y - breachVec2.y }
    local length = math.sqrt(vec.x^2 + vec.y^2)
    if length == 0 then return nil end
    local dir = { x = vec.x / length, y = vec.y / length }
    local perp = { x = -dir.y, y = dir.x }
    local corridorStart = {
        x = breachVec2.x + dir.x * (offsetMeters or 0),
        y = breachVec2.y + dir.y * (offsetMeters or 0)
    }
    local halfWidth = widthMeters / 2
    return {
        Vec2.new(corridorStart.x - perp.x * halfWidth, corridorStart.y - perp.y * halfWidth),
        Vec2.new(corridorStart.x + perp.x * halfWidth, corridorStart.y + perp.y * halfWidth),
        Vec2.new(airbaseVec2.x + perp.x * halfWidth, airbaseVec2.y + perp.y * halfWidth),
        Vec2.new(airbaseVec2.x - perp.x * halfWidth, airbaseVec2.y - perp.y * halfWidth)
    }
end

--- Executes a theater-level Tactical Retreat / Surrender for a given group.
function TCS.CIC.Director.ExecuteTacticalRetreat(group, threatCoord)
    if not group or not group:IsAlive() then return end
    TCS.Logger.info("TCS(DIRECTOR): Tactical Retreat ordered for %s", group:GetName())

    if group:IsAir() then
        group:OptionRadarOff()
        group:OptionROEHoldFire()
        group:OptionROTEvadeFire()
        group:RouteRTB()
    elseif group:IsGround() then
        local gCoord = group:GetCoordinate()
        local fallbackHdg = 0
        if threatCoord and threatCoord.GetVec3 then
            fallbackHdg = math.deg(math.atan2(gCoord:GetVec3().z - threatCoord:GetVec3().z, gCoord:GetVec3().x - threatCoord:GetVec3().x))
        end
        group:RouteGroundTo(gCoord:Translate(5000, fallbackHdg), 40, "On Road")
    end
end

local lastBorderTriggerTime = {}
local BORDER_COOLDOWN_SECONDS = 300

--- Standardized Theater Response for Border Violations (Tripwires)
function TCS.CIC.Director.HandleBorderViolation(params)
    local borderId = params.borderId or "Unknown_Border"
    local currentTime = timer.getTime()

    -- Enforce cooldown so multiple aircraft crossing don't spam the system
    if lastBorderTriggerTime[borderId] and (currentTime - lastBorderTriggerTime[borderId]) < BORDER_COOLDOWN_SECONDS then return end
    lastBorderTriggerTime[borderId] = currentTime

    TCS.Logger.info("TCS(DIRECTOR): TRIPWIRE TRIGGERED: " .. borderId)
    if params.customMessage then trigger.action.outTextForCoalition(coalition.side.BLUE, params.customMessage, 15) end
    
    local isEscalated = (params.responseType == "ESCALATED_AIRDEF" or params.responseType == "COORDINATED_DEFENSE")
    local isIntercept = (params.responseType == "INTERCEPT" or params.responseType == "ESCALATED_AIRDEF" or params.responseType == "COORDINATED_DEFENSE")

    if isEscalated then
        TCS.Logger.info("TCS(DIRECTOR): Escalating regional SAM network to RED status for " .. borderId)
        if TCS.CIC and TCS.CIC.IADS then TCS.CIC.IADS.SetTheaterAlarmState("RED") end
    end

    if isIntercept then
        if DeployIntercept then
            TCS.Logger.info("TCS(DIRECTOR): Dispatching Intercept for " .. borderId)
            local interceptGroups = DeployIntercept({
                coalition = coalition.side.RED,
                anchor = params.anchor,
                echelon = "PATROL",
                airframe = params.airframe or "MiG-29A",
                skill = "High"
            })
            
            -- Handoff Protocol: Keep SAMs hot until fighters arrive, then de-escalate
            if params.responseType == "COORDINATED_DEFENSE" and interceptGroups and #interceptGroups > 0 then
                TCS.Logger.info("TCS(DIRECTOR): Handoff Protocol initiated. SAMs will hold RED until fighters arrive.")
                
                local handoffScheduler
                handoffScheduler = SCHEDULER:New(nil, function()
                    local arrived, allDead = false, true
                    for _, grp in ipairs(interceptGroups) do
                        if grp and grp:IsAlive() then
                            allDead = false
                            local grpVec = grp:GetVec2()
                            local dx, dy = grpVec.x - params.anchor.x, grpVec.y - params.anchor.y
                            if (math.sqrt(dx*dx + dy*dy) / 1852) < 15 then arrived = true; break end
                        end
                    end
                    
                    if arrived then
                        TCS.Logger.info("TCS(DIRECTOR): Fighters on station at " .. borderId .. ". De-escalating SAMs to AUTO.")
                        if TCS.CIC and TCS.CIC.IADS then TCS.CIC.IADS.SetTheaterAlarmState("AUTO") end
                        if handoffScheduler then SCHEDULER:Stop(handoffScheduler) end
                    elseif allDead then
                        TCS.Logger.info("TCS(DIRECTOR): Intercept failed en route to " .. borderId .. ". SAMs remain RED.")
                        if handoffScheduler then SCHEDULER:Stop(handoffScheduler) end
                    end
                end, {}, 10, 10)
            end
        else
            TCS.Logger.error("TCS(DIRECTOR): DeployIntercept API not found! Ensure theater_api.lua is loaded.")
        end
    end
end

-- Expose globally so the backend Tripwire engine can invoke it dynamically via string lookup
_G.TCS_HandleBorderViolation = TCS.CIC.Director.HandleBorderViolation

-- Triggered by Tripwires and early warning networks
function TCS.CIC.Director.ScrambleIntercept(intruderGroup)
  if not intruderGroup or not intruderGroup:IsAlive() then return end

  TCS.Logger.info("TCS(DIRECTOR): Scrambling interceptors against intruder %s!", intruderGroup:GetName())
  trigger.action.outText("CIC: Intruder detected crossing boundary! Scrambling interceptors!", 10)

  -- Determine mission era from the mission date
  local missionYear = env.mission.date.Year
  local interceptorType = "MiG-21Bis" -- A safe fallback for all periods

  -- Query the unified V2 Air Catalog using the Mission Year for era-appropriate bandits
  local candidates = {}
  if TCS.Air and TCS.Air.Catalog and TCS.Air.Catalog.Query then
    local queryResults = TCS.Air.Catalog.Query({ year = missionYear })
    for _, entry in ipairs(queryResults) do
      -- Filter for Red Fighters/Interceptors
      if (entry.role == "FIGHTER" or entry.role == "INTERCEPTOR") and entry.coalitions then
        for _, coa in ipairs(entry.coalitions) do
          if string.upper(coa) == "RED" and entry.unit_types and entry.unit_types[1] then
            table.insert(candidates, entry.unit_types[1])
            break
          end
        end
      end
    end
  end

  if #candidates > 0 then
    interceptorType = candidates[math.random(#candidates)]
  else
    -- Fallback if catalog is empty or no suitable aircraft are found for the era
    TCS.Logger.warn("TCS(DIRECTOR): No suitable interceptors found in catalog for year %d. Falling back to default.", missionYear)
    if missionYear < 1970 then
      interceptorType = "MiG-19P"
    elseif missionYear < 1992 then
      interceptorType = "MiG-23MLD"
    else
      interceptorType = "MiG-29S"
    end
  end

  TCS.Logger.info("TCS(DIRECTOR): Mission year %d, scrambling %s.", missionYear, interceptorType)

  if TCS.DeployCAP then
    TCS.DeployCAP({
      coalition = "RED",
      country = "Syria",
      zone = "TCS_ZONE_CAP_DAMASCUS", -- Fallback anchor zone for the scramble
      minNm = 10, maxNm = 20, ingressHdg = 0, ingressArc = 360,
      airframe = interceptorType, -- Use the dynamically selected airframe
      number = 2, missionType = "INTERCEPT", skill = "High",
      behavior = { target = intruderGroup }
    })
  end
end

env.info("TCS(CIC.DIRECTOR): ready")