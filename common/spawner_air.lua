---------------------------------------------------------------------
-- TCS COMMON: AIR SPAWNER
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Common = TCS.Common or {}
TCS.Common.Spawner = TCS.Common.Spawner or {}

function TCS.Common.Spawner.SpawnAir(session, requisition)
    local spawnedGroups = {}
    local anchor = requisition.geometry.anchor
    if not anchor or type(anchor) ~= "table" then return {} end

    -- Resolve Spawn Coordinate (Forward of anchor/player course)
    local g = requisition.geometry
    local anchorHdg = 0
    if requisition.behavior.groupTarget and requisition.behavior.groupTarget:IsAlive() then
        anchorHdg = requisition.behavior.groupTarget:GetHeading() or 0
    end

    local dist = math.random(g.minNm, g.maxNm) * 1852
    -- Standardize arc math: arc is total width, centered on the heading.
    local jitter = (math.random() * (g.arc or 90)) - ((g.arc or 90) / 2)
    local bearing = (anchorHdg + jitter) % 360
    
    local spawnCoord = anchor:Translate(dist, bearing)
    spawnCoord:SetAltitude(TCS.Config.Air.Defaults.ALTITUDE.MED * 0.3048)

    for i, groupCfg in ipairs(requisition.manifest or {}) do
        local groupName = string.format("TCS_AIR_%s_%d", session.Name or "SYS", math.random(1000, 9999))
        local opts = {
            name = groupName,
            coalition = requisition.coalition or 1,
            heading = (bearing + 180) % 360,
            skill = groupCfg.skill or "High",
            alt = spawnCoord:GetAltitude()
        }

        local group = TCS.Common.Spawn.Group(groupCfg.types, spawnCoord, opts, "AIR", groupCfg.count)
        if group then
            table.insert(spawnedGroups, group)
            -- Apply basic A2A tasking
            timer.scheduleFunction(function()
                if group and group:IsAlive() then
                    group:OptionROE(ENUMS.ROE.WeaponFree)
                    
                    -- Use MOOSE FlightGroup for superior A2A AI
                    local fg = FLIGHTGROUP:New(group)
                    if requisition.behavior.mode == "CAP" then
                        fg:AddMission(AUFTRAG:NewCAP(requisition.geometry.anchor, 25000, 350))
                    else
                        fg:AddMission(AUFTRAG:NewSWEEP(requisition.geometry.anchor, 25000, 400))
                    end
                end
            end, nil, timer.getTime() + 1)
        end
    end
    return spawnedGroups
end

env.info("TCS(COMMON.SPAWNER.AIR): ready")