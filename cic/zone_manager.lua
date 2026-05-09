---------------------------------------------------------------------
-- TCS CIC: ZONE MANAGER
-- Handles the lifecycle, persistence, and garbage collection of Zones.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.CIC = TCS.CIC or {}
TCS.CIC.ZoneManager = {
    Zones = {},
    Config = {
        TIMEOUT_SECONDS = 600, -- 10 minutes of inactivity before collapse
        CHECK_INTERVAL = 30,   -- Check every 30 seconds
        ZONE_RADIUS_M = 92600  -- ~50NM radius for activity tracking
    }
}

--- Registers a Zone to begin lifecycle monitoring
function TCS.CIC.ZoneManager.RegisterZone(zoneId, anchorCoord)
    if not TCS.CIC.ZoneManager.Zones[zoneId] then
        TCS.CIC.ZoneManager.Zones[zoneId] = {
            Id = zoneId,
            Anchor = anchorCoord,
            LastActive = timer.getTime()
        }
        env.info("TCS(CIC): Zone " .. tostring(zoneId) .. " activated.")
    else
        TCS.CIC.ZoneManager.Zones[zoneId].LastActive = timer.getTime()
    end
end

--- Pings a zone to reset its inactivity timeout
function TCS.CIC.ZoneManager.PingZone(zoneId)
    if TCS.CIC.ZoneManager.Zones[zoneId] then
        TCS.CIC.ZoneManager.Zones[zoneId].LastActive = timer.getTime()
    end
end

--- Evaluates zones for garbage collection based on presence and time
function TCS.CIC.ZoneManager.Update()
    local currentTime = timer.getTime()
    
    for zoneId, zone in pairs(TCS.CIC.ZoneManager.Zones) do
        local playerPresent = false
        local players = coalition.getPlayers(coalition.side.BLUE)
        for _, p in ipairs(coalition.getPlayers(coalition.side.RED)) do table.insert(players, p) end

        -- Check if any player is within the Zone's radius
        for _, player in ipairs(players) do
            if player and player.isExist and player:isExist() then
                local pCoord = player:getPoint()
                if zone.Anchor and zone.Anchor.GetVec3 then
                    local anchorVec3 = zone.Anchor:GetVec3()
                    local dist = math.sqrt((pCoord.x - anchorVec3.x)^2 + (pCoord.z - anchorVec3.z)^2)
                    if dist < TCS.CIC.ZoneManager.Config.ZONE_RADIUS_M then
                        playerPresent = true
                        break
                    end
                end
            end
        end

        if playerPresent then
            zone.LastActive = currentTime
        elseif (currentTime - zone.LastActive) > TCS.CIC.ZoneManager.Config.TIMEOUT_SECONDS then
            TCS.CIC.ZoneManager.CollapseZone(zoneId)
        end
    end
    
    return timer.getTime() + TCS.CIC.ZoneManager.Config.CHECK_INTERVAL
end

--- Collapses a zone, cleaning up tasks, units, and drawings
function TCS.CIC.ZoneManager.CollapseZone(zoneId)
    env.info("TCS(CIC): Zone " .. tostring(zoneId) .. " timed out. Collapsing and garbage collecting.")
    
    -- 1. Clean up map drawings using the refactored F10 module
    if TCS.Signals and TCS.Signals.F10 then
        TCS.Signals.F10.ClearZone(zoneId)
    end
    
    -- 2. Terminate active Deployments and despawn their groups
    if TCS.CIC.Controller and TCS.CIC.Controller.Deployments then
        for id, dep in pairs(TCS.CIC.Controller.Deployments) do
            if dep.ZoneID == zoneId then
                dep.Status = "ABORTED"
                for _, g in ipairs(dep.Groups) do
                    if g and g:IsAlive() then
                        g:Destroy()
                    end
                end
            end
        end
    end

    -- Remove from monitoring
    TCS.CIC.ZoneManager.Zones[zoneId] = nil
end

-- Start the monitoring loop
timer.scheduleFunction(TCS.CIC.ZoneManager.Update, nil, timer.getTime() + TCS.CIC.ZoneManager.Config.CHECK_INTERVAL)

---------------------------------------------------------------------
-- EVENT LISTENER: Ping Zones on Combat Events
---------------------------------------------------------------------
local ZoneEventHandler = {}
function ZoneEventHandler:onEvent(event)
    -- Guard against events with no position or initiator data
    if not event.pos and not event.initiator then return end
    
    if event.id == world.event.S_EVENT_SHOOT or 
       event.id == world.event.S_EVENT_HIT or 
       event.id == world.event.S_EVENT_DEAD then
       
        local pos = event.pos -- Prioritize event.pos, which is present for HIT and DEAD events
        if not pos and event.initiator and event.initiator.isExist and event.initiator:isExist() then
            -- Fallback for events like SHOOT where initiator is alive but event.pos is nil
            pos = event.initiator:getPoint()
        end

        if pos then
            for zoneId, zone in pairs(TCS.CIC.ZoneManager.Zones) do
                if zone.Anchor and zone.Anchor.GetVec3 then
                    local anchorVec3 = zone.Anchor:GetVec3()
                    local dist = math.sqrt((pos.x - anchorVec3.x)^2 + (pos.z - anchorVec3.z)^2)
                    if dist < TCS.CIC.ZoneManager.Config.ZONE_RADIUS_M then
                        TCS.CIC.ZoneManager.PingZone(zoneId)
                    end
                end
            end
        end
    end
end
world.addEventHandler(ZoneEventHandler)