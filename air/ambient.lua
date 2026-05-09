---------------------------------------------------------------------
-- TCS AIR AMBIENT
-- Populates airbases or custom zones with static aircraft and cargo.
---------------------------------------------------------------------
env.info("TCS(AIR.AMBIENT): loading")

TCS = TCS or {}
TCS.Air = TCS.Air or {}
TCS.Air.Ambient = {}
TCS.Air.Ambient.OutfittedBases = {}

-- Safety check: DCS natively ignores static objects when evaluating "empty" spots
local function isLocationOccupied(vec3)
    local occupied = false
    local searchRadius = TCS.Air.Settings and TCS.Air.Settings.AMBIENT.COLLISION_RADIUS_M or 15
    local vol = { id = world.VolumeType.SPHERE, params = { point = vec3, radius = searchRadius } }
    local handler = function(obj) occupied = true; return false end
    world.searchObjects(Object.Category.UNIT, vol, handler)
    if not occupied then world.searchObjects(Object.Category.STATIC, vol, handler) end
    return occupied
end

function TCS.Air.Ambient.OutfitBase(params, legacyDensity, legacyMaxItems)
    -- Support for legacy positional arguments: OutfitBase("BaseName", density, maxItems)
    if type(params) == "string" then
        params = {
            base = params,
            density = legacyDensity,
            maxItems = legacyMaxItems
        }
    end

    local baseName = params.base or params.anchor
    if not baseName then return end

    -- Prevent accidental double-outfitting (e.g., from multiple ME triggers)
    if TCS.Air.Ambient.OutfittedBases[baseName] then
        env.info(string.format("TCS(AIR.AMBIENT): Base '%s' already outfitted. Skipping to prevent overlaps.", baseName))
        return
    end
    TCS.Air.Ambient.OutfittedBases[baseName] = true

    local ambSet = TCS.Air.Settings and TCS.Air.Settings.AMBIENT or {}
    local mode = params.mode
    local density = params.density or ambSet.DEFAULT_DENSITY or 0.5
    local maxItems = params.maxItems or params.max or params.maxAirframes or ambSet.DEFAULT_MAX_ITEMS or 50
    local coalitionId = params.coalition or coalition.side.RED
    local staticType = params.staticType or "FARP"
    if type(coalitionId) == "string" then
        coalitionId = string.upper(coalitionId) == "BLUE" and coalition.side.BLUE or coalition.side.RED
    end

    -- 1. Determine Anchor and Mode (RAMP vs DISPERSED)
    local anchorCoord = nil
    local dcsAirbase = Airbase.getByName(baseName)
    
    if dcsAirbase then
        anchorCoord = COORDINATE:NewFromVec3(dcsAirbase:getPoint())
        mode = mode or "RAMP"
    else
        local z = ZONE:FindByName(baseName)
        if z then anchorCoord = z:GetCoordinate() end
        mode = mode or "DISPERSED"
    end

    if not anchorCoord then
        if TCS.Logger then TCS.Logger.error("TCS(AIR.AMBIENT): Could not resolve base or zone '%s'", tostring(baseName)) end
        return
    end

    local blueprint = {}
    local count = 0
    local trafficBlueprint = {}

    -- 2. Target Pool Selection
    local targetPool = {}
    local sourceManifest = params.manifest

    local function hasFaction(tbl, val)
        if not tbl then return true end
        for _, v in ipairs(tbl) do if string.upper(v) == string.upper(val) then return true end end
        return false
    end
    local coaStr = (coalitionId == coalition.side.BLUE) and "BLUE" or "RED"

    if not sourceManifest then
        if mode == "RAMP" then
            local candidates = TCS.Air.Catalog and TCS.Air.Catalog.Data or {}
            
            -- Determine the era to filter out anachronistic airframes (e.g., no Sabres in 2010)
            local missionYear = params.year or (env.mission and env.mission.date and env.mission.date.Year) or 2000

            for section, sectionData in pairs(candidates) do
                for _, ac in ipairs(sectionData) do
                    if hasFaction(ac.coalitions, coaStr) then
                        -- Validate Era
                        local intro = 0
                        local retired = 9999
                        
                        if ac.years and type(ac.years) == "table" then
                            intro = tonumber(ac.years[1]) or 0
                            retired = tonumber(ac.years[2]) or 9999
                        else
                            intro = tonumber(ac.yearIntro or ac.year_intro or ac.year_introduced or ac.service_date) or 0
                            retired = tonumber(ac.yearRetired or ac.year_retired or ac.last_service_year or ac.last_day_of_service) or 9999
                            
                            -- Fallback for catalogs that just use a single 'year' parameter
                            if not (ac.yearIntro or ac.year_intro or ac.year_introduced or ac.service_date) and ac.year then
                                intro = tonumber(ac.year) or 0
                                retired = intro + 35 -- Assume roughly a 35 year lifespan if retired isn't specified
                            end
                        end
                        
                        if missionYear >= intro and missionYear <= retired then
                            local uType = ac.unit_types and ac.unit_types[1] or ac.type
                            if uType then
                                -- Dynamically weight based on role from the catalog
                                local weight = 1
                                if ac.role == "FIGHTER" or ac.role == "STRIKE" or ac.role == "CAS" then weight = params.fighterWeight or 2
                                elseif ac.role == "BOMBER" or ac.role == "TRANSPORT" or ac.role == "AWACS" or ac.role == "TANKER" then weight = params.heavyWeight or 4
                                elseif ac.role == "ATTACK_HELO" or ac.role == "RESCUE" then weight = params.heloWeight or 2
                                end
                                
                                for _ = 1, weight do table.insert(targetPool, uType) end
                            end
                        end
                    end
                end
            end
            if #targetPool == 0 then targetPool = {"F-16C_50"} end -- Ultimate fallback
        else
            local staticCat = TCS.Air.Catalog.Statics and TCS.Air.Catalog.Statics[coaStr]
            if staticCat then
                local mix = staticCat[staticType] or staticCat.FARP or {}
                for uType, weight in pairs(mix) do
                    for _ = 1, weight do table.insert(targetPool, uType) end
                end
            end
            if #targetPool == 0 then targetPool = {"FARP Tent", "Ural-375"} end
        end
    end

    if type(sourceManifest) == "string" then 
        table.insert(targetPool, sourceManifest)
    elseif type(sourceManifest) == "table" then
        if sourceManifest[1] then 
            targetPool = sourceManifest
        else 
            for unitType, weight in pairs(sourceManifest) do
                for _ = 1, weight do table.insert(targetPool, unitType) end
            end
        end
    end

    -- 3. Populate Blueprint
    local anchorVec = anchorCoord:GetVec3()

    if mode == "RAMP" and dcsAirbase then
        local spots = dcsAirbase:getParking(true) -- 'true' forces DCS to only return EMPTY parking spots!
        if spots then
            for i = #spots, 2, -1 do local j = math.random(i); spots[i], spots[j] = spots[j], spots[i] end -- Shuffle
            
            -- Generate roaming traffic (take spots from the end of the shuffled array so statics don't use them)
            if params.traffic ~= false then
                local trafficCount = params.trafficCount or math.random(ambSet.TRAFFIC_MIN or 1, ambSet.TRAFFIC_MAX or 2)
                local trafficPool = (coalitionId == coalition.side.BLUE) and {"Hummer", "M 818"} or {"UAZ-469", "Ural-375"}
                for i = 1, trafficCount do
                    if #spots > 0 then
                        local spot = table.remove(spots)
                        if spot and spot.vTerminalPos and not isLocationOccupied(spot.vTerminalPos) then
                            table.insert(trafficBlueprint, { x = spot.vTerminalPos.x - anchorVec.x, y = spot.vTerminalPos.z - anchorVec.z, unitType = trafficPool[math.random(#trafficPool)], isStatic = false, heading = spot.fHdg or 0 })
                        end
                    end
                end
            end

            for _, spot in ipairs(spots) do
                if count >= maxItems then break end
                if math.random() <= density and spot.vTerminalPos and not isLocationOccupied(spot.vTerminalPos) then
                    local unitType = targetPool[math.random(#targetPool)]
                    
                    -- DCS natively provides the parking spot heading (fHdg) in radians. 
                    -- NOTE: If statics spawn facing backward, use `spot.fHdg + math.pi`
                    local spotHdg = spot.fHdg or math.rad(math.random(0, 359))
                    table.insert(blueprint, { x = spot.vTerminalPos.x - anchorVec.x, y = spot.vTerminalPos.z - anchorVec.z, unitType = unitType, isStatic = true, staticCategory = params.staticCategory or "Planes", heading = spotHdg })
                    count = count + 1
                end
            end
        end
    elseif mode == "DISPERSED" then
        local radius = params.radiusNm or ambSet.DEFAULT_DISPERSION_NM or 1
        for attempts = 1, maxItems * 2 do
            if count >= maxItems then break end
            if math.random() <= density then
                local spawnCoord = anchorCoord:Translate(math.random(10, radius * 1852), math.random(0, 359))
                if spawnCoord:GetSurfaceType() == land.SurfaceType.LAND then
                    local vec3 = spawnCoord:GetVec3()
                    if vec3 and not isLocationOccupied(vec3) then
                        local unitType = targetPool[math.random(#targetPool)]
                        table.insert(blueprint, { x = spawnCoord.x - anchorCoord.x, y = spawnCoord.z - anchorCoord.z, unitType = unitType, isStatic = true, staticCategory = params.staticCategory or "Fortifications", heading = math.rad(math.random(0, 359)) })
                        count = count + 1
                    end
                end
            end
        end
    end

    -- 4. Hand off to Dispatcher
    if #blueprint > 0 then
        local recipe = { tower = "AIR", missionType = "AMBIENT", category = Group.Category.GROUND, coalition = coalitionId, blueprint = blueprint, geometry = { type = "ANCHORED", anchor = anchorCoord, ingressHdg = 0, domain = "LAND" } }
        if TCS.Dispatcher and TCS.Dispatcher.ExecuteRequisition then TCS.Dispatcher.ExecuteRequisition(recipe) end
    end

    -- 5. Dispatch Roaming Traffic
    if #trafficBlueprint > 0 then
        local trafficRecipe = {
            tower = "AIR",
            missionType = "AMBIENT_TRAFFIC",
            category = Group.Category.GROUND,
            coalition = coalitionId,
            blueprint = trafficBlueprint,
            geometry = { type = "ANCHORED", anchor = anchorCoord, ingressHdg = 0, domain = "LAND" },
            onSpawn = function(grp, rec)
                if grp and grp:IsAlive() then
                    -- Delay MOOSE wrapper to ensure DCS spawned the unit completely
                    timer.scheduleFunction(function(args)
                        local pGroup = GROUP:FindByName(args[1])
                        if pGroup and pGroup:IsAlive() then pGroup:PatrolZones({ZONE_AIRBASE:New(args[2], 1500)}, 25, "Cone") end
                    end, {grp:GetName(), baseName}, timer.getTime() + 2)
                end
            end
        }
        if TCS.Dispatcher and TCS.Dispatcher.ExecuteRequisition then TCS.Dispatcher.ExecuteRequisition(trafficRecipe) end
    end
end

-- Global Aliases for easy access in Mission Editor
TCS.OutfitBase = TCS.Air.Ambient.OutfitBase
_G.OutfitBase = TCS.Air.Ambient.OutfitBase

env.info("TCS(AIR.AMBIENT): ready")