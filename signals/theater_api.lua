-- This script provides global functions to trigger theater tasks via the TCS API.
-- It allows specifying a zone name for the anchor and overriding min/max spawn distances.

-- Ensure TCS is loaded
TCS = TCS or {}
TCS.API = TCS.API or {}

--- Normalizes API inputs into structured Objective, Deployment, and Orders blocks.
function TCS.API.Normalize(args, defaultForceSize, domain)
    local p = args or {}
    
    -- Allow fallback to flat tables by treating the root 'p' as the source if a sub-table is missing
    local obj = p.objective or p
    local dep = p.deployment or p
    local ord = p.orders or p

    -- Low-Level Control Interface (The General)
    -- Maps specific, granular requests into the standard architect manifest
    if p.airframe and not dep.manifest then dep.manifest = p.airframe end
    if p.type and not dep.manifest then dep.manifest = p.type end
    if p.threat and not dep.tier then dep.tier = p.threat end
    if p.number and not dep.count then dep.count = p.number end

    local anchor = obj.anchor or obj.zone
    local zoneNameStr = type(anchor) == "string" and anchor or nil

    -- UNIVERSAL ANCHOR RESOLVER: Convert strings and tables to MOOSE COORDINATEs immediately
    if type(anchor) == "string" then
        local resolved = false
        
        if ZONE and ZONE:FindByName(anchor) then
            anchor = ZONE:FindByName(anchor):GetCoordinate()
            resolved = true
        end
        
        if not resolved then
            local dcsZone = trigger.misc.getZone(anchor)
            if dcsZone then
                local yAlt = land and land.getHeight({x = dcsZone.point.x, y = dcsZone.point.z}) or 0
                anchor = COORDINATE:New(dcsZone.point.x, yAlt, dcsZone.point.z)
                resolved = true
            end
        end
        
        if not resolved and mist and mist.DBs and mist.DBs.zonesByName and mist.DBs.zonesByName[anchor] then
            local z = mist.DBs.zonesByName[anchor]
            if z.point then
                anchor = COORDINATE:New(z.point.x, z.point.y, z.point.z)
                resolved = true
            elseif z.x and z.y then
                local yAlt = land and land.getHeight({x = z.x, y = z.y}) or 0
                anchor = COORDINATE:New(z.x, yAlt, z.y)
                resolved = true
            end
        end

        if not resolved and env.mission and env.mission.triggers and env.mission.triggers.zones then
            for _, z in ipairs(env.mission.triggers.zones) do
                if z.name == anchor then
                    local yAlt = land and land.getHeight({x = z.x, y = z.y}) or 0
                    anchor = COORDINATE:New(z.x, yAlt, z.y)
                    resolved = true
                    break
                end
            end
        end

        if not resolved and Airbase and Airbase.getByName(anchor) then
            anchor = COORDINATE:NewFromVec3(Airbase.getByName(anchor):getPoint())
            resolved = true
        end
        
        if not resolved then
            env.warning("TCS(API): Could not resolve anchor string to a valid location: " .. tostring(anchor))
            anchor = nil
        end
    elseif type(anchor) == "table" and not anchor.GetCoordinate and not anchor.GetVec3 then
        -- Convert raw {x, y} or {x, z} coordinate tables into MOOSE Coordinates
        local x = anchor.x
        local z = anchor.z or anchor.y
        if x and z then
            local yAlt = land and land.getHeight({x = x, y = z}) or 0
            anchor = COORDINATE:New(x, yAlt, z)
        end
    end

    -- 1. Dynamic Anchor Resolution (Zone Creation)
    if type(anchor) == "table" and anchor.ClassName == "GROUP" then
        obj.group = anchor
        anchor = nil
    end

    if not anchor and obj.group then
        -- Always fetch a fresh reference to the group by name in case the player respawned!
        local groupName = obj.group:GetName()
        local freshGroup = GROUP:FindByName(groupName)
        
        if freshGroup and freshGroup:IsAlive() then
            local coord = freshGroup:GetCoordinate()
            if coord then
                local distNm = obj.maxNm or obj.minNm or 15
                local hdgRad = freshGroup:GetHeading() or 0
                
                anchor = coord:Translate(distNm * 1852, hdgRad)
                env.info(string.format("TCS(API): Dynamically generated zone center at %.1f NM ahead.", distNm))
            else
                env.warning("TCS(API): Dynamic zone generation failed: Could not resolve coordinate for group " .. tostring(groupName))
            end
        else
            env.warning("TCS(API): Dynamic zone generation failed: Group '" .. tostring(groupName) .. "' is not alive or not found.")
        end
    end

    -- The combination of settings applied when the "-T" macro is detected
    local TRIPWIRE_SETTINGS = { silent = -3, hidden = true }
    local useTripwireTable = false

    local function parseTripwireSuffix(str)
        if type(str) ~= "string" then return str, false end
        local u = string.upper(str)
        if string.match(u, "[%-_]T$") then
            return string.sub(str, 1, -3), true -- Strip the "-T"
        end
        return str, false
    end

    local resolvedEchelon = defaultForceSize or "COMPANY"
    local resolvedSkill = dep.skill or dep.tier or "G"
    local resolvedManifest = dep.manifest
    local resolvedComposition = dep.composition

    -- Smart Tuple/Array Parser for forceSize
    local fs = dep.forceSize or dep.echelon
    if type(fs) == "table" then
        if type(fs[1]) == "table" then
            -- Nested composition array: { {"ARMOR", 4}, {"INFANTRY", 12} }
            resolvedComposition = {}
            for _, item in ipairs(fs) do
                if type(item) == "table" and #item >= 2 then
                    local cat = type(item[1]) == "string" and string.upper(item[1]) or item[1]
                    resolvedComposition[cat] = item[2]
                end
            end
        else
            -- Tuple: {"SA15", "H"} or {"COMPANY", "X"} or {"ARMOR", 4}
            local v1 = fs[1]
            local v2 = fs[2]
            if type(v1) == "string" then
                local isTripwire = false
                v1, isTripwire = parseTripwireSuffix(v1)
                if isTripwire then useTripwireTable = true end
                
                local vUp = string.upper(v1)
                if vUp == "SA" or vUp == "SAM" then v1 = nil; vUp = "" end
                
                local echelons = {PATROL=1, PLATOON=1, COMPANY=1, BATTALION=1, BRIGADE=1, SQUADRON=1, WING=1, TASK_UNIT=1, TASK_GROUP=1, TASK_FORCE=1}
                if echelons[vUp] then resolvedEchelon = vUp elseif v1 then resolvedManifest = v1 end
            end
            if v2 then
                if type(v2) == "string" then resolvedSkill = v2
                elseif type(v2) == "number" then resolvedComposition = { [type(v1)=="string" and string.upper(v1) or v1] = v2 }
                end
            end
        end
    elseif type(fs) == "string" then
        -- Standard string fallback
        local isTripwire = false
        fs, isTripwire = parseTripwireSuffix(fs)
        if isTripwire then useTripwireTable = true end
        
        local vUp = string.upper(fs)
        if vUp == "SA" or vUp == "SAM" then fs = nil; vUp = "" end
        
        local echelons = {PATROL=1, PLATOON=1, COMPANY=1, BATTALION=1, BRIGADE=1, SQUADRON=1, WING=1, TASK_UNIT=1, TASK_GROUP=1, TASK_FORCE=1}
        if echelons[vUp] then resolvedEchelon = vUp elseif fs then resolvedManifest = fs end
    end

    -- Apply the tripwire table settings if the macro was triggered
    if useTripwireTable then
        ord.silent = ord.silent or TRIPWIRE_SETTINGS.silent
        if dep.hidden == nil then dep.hidden = TRIPWIRE_SETTINGS.hidden end
    end

    local resolvedCoalition = dep.coalition or obj.coalition or p.coalition or coalition.side.RED
    if type(resolvedCoalition) == "string" then
        resolvedCoalition = string.upper(resolvedCoalition) == "BLUE" and coalition.side.BLUE or coalition.side.RED
    end

    -- 2. Parameter Normalization & Defaults into Structured Blocks
    return {
        -- Flatten properties so Architects can read them easily
        anchor         = anchor,
        zoneName       = zoneNameStr,
        destination    = obj.destination or dep.destination,
        hidden         = obj.hidden or dep.hidden,
        minNm          = obj.minNm or 5,
        maxNm          = obj.maxNm or 15,
        ingressHdg     = obj.ingressHdg or obj.heading,
        ingressArc     = obj.ingressArc or 180,
        alt            = obj.alt or obj.altitude,
        coalition      = resolvedCoalition,
        count          = dep.count,
        echelon        = resolvedEchelon,
        skill          = resolvedSkill,
        manifest       = resolvedManifest,
        tier           = dep.tier or ord.tier or p.tier or resolvedSkill,
        role           = dep.role or ord.role or p.role,
        maxAirframes   = dep.maxAirframes or ord.maxAirframes or p.maxAirframes,
        composition    = resolvedComposition,
        friendlyCoalition = dep.friendlyCoalition,
        reinforce      = ord.reinforce,
        respawn        = ord.respawn,
        respawnDelay   = ord.respawnDelay or 300,
        duration       = ord.duration,
        silent         = ord.silent
    }
end

--- Deploys a Ground Force to support BAI or CAS missions.
--- The Architect dynamically structures a Troops In Contact (CAS) scenario if `friendlyCoalition` is provided.
function DeployGroundForces(args)
    -- Support legacy positional wrapper for backward compatibility
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end

    local params = TCS.API.Normalize(args, "COMPANY", "LAND")
    if not params.anchor then return nil end
    env.info(string.format("TCS(API): Creating Ground Force task at '%s'", tostring(params.zoneName or "Coordinates")))

    if not TCS.Land or not TCS.Land.Architect then return nil end
    local mType = params.friendlyCoalition and "CAS" or "BAI"
    return TCS.Land.Architect.Build(mType, params)
end

--- Deploys a Custom exact-count unit layout.
function DeployCustom(args)
    if type(args) ~= "table" then return nil end
    
    local params = TCS.API.Normalize(args, "CUSTOM", "LAND")
    if not params.anchor then return nil end
    
    if not TCS.Land or not TCS.Land.Architect then return nil end
    return TCS.Land.Architect.Build("CUSTOM", params)
end

--- Deploys a Strike Target (infrastructure and fixed defenders).
function DeployStrike(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end
    local params = TCS.API.Normalize(args, "COMPANY", "LAND")
    
    if not params.anchor then return nil end
    if not TCS.Land or not TCS.Land.Architect then return nil end
    return TCS.Land.Architect.Build("STRIKE", params)
end

--- Deploys a Short Range Air Defense (SHORAD) network.
function DeployAirDefenses(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end
    local params = TCS.API.Normalize(args, "PLATOON", "LAND")
    
    if not params.anchor then return nil end
    if not TCS.AirDef or not TCS.AirDef.Architect then return nil end
    return TCS.AirDef.Architect.Build("SEAD", params)
end

--- Deploys a Combat Air Patrol.
function DeployCap(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end
    local params = TCS.API.Normalize(args, "SQUADRON", "AIR")
    
    if not params.anchor then return nil end
    if not TCS.Air or not TCS.Air.Architect then return nil end
    return TCS.Air.Architect.Build("CAP", params)
end

--- Deploys an Offensive Air Sweep.
function DeploySweep(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end
    local params = TCS.API.Normalize(args, "SQUADRON", "AIR")
    
    if not params.anchor then return nil end
    if not TCS.Air or not TCS.Air.Architect then return nil end
    return TCS.Air.Architect.Build("SWEEP", params)
end

--- Deploys an Air Intercept mission.
function DeployIntercept(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end
    local params = TCS.API.Normalize(args, "SQUADRON", "AIR")
    
    if not params.anchor then return nil end
    if not TCS.Air or not TCS.Air.Architect then return nil end
    return TCS.Air.Architect.Build("INTERCEPT", params)
end

--- Deploys a Strike Package escorted by Fighters.
function DeployEscort(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end
    local params = TCS.API.Normalize(args, "SQUADRON", "AIR")
    params.package = args.package or "STRIKE"
    if not params.anchor then return nil end
    if not TCS.Air or not TCS.Air.Architect then return nil end
    return TCS.Air.Architect.Build("ESCORT", params)
end

--- Deploys a Doctrinal SAM Site.
function DeploySAM(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end

    local params = TCS.API.Normalize(args, "PLATOON", "LAND")

    if not params.anchor then return nil end
    if not TCS.AirDef or not TCS.AirDef.Architect then return nil end
    return TCS.AirDef.Architect.Build("DSAM", params)
end

--- Deploys a SAM Site specifically configured for a post-merge Ambush.
function DeployAmbushSAM(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end

    local params = TCS.API.Normalize(args, "PLATOON", "LAND")
    params.silent = args.silent or -3 -- Default to a brutal 3NM post-merge trap
    params.hidden = (args.hidden ~= false) -- Default to seeking tree-line concealment

    if not params.anchor then return nil end
    if not TCS.AirDef or not TCS.AirDef.Architect then return nil end
    return TCS.AirDef.Architect.Build("DSAM", params)
end

--- Deploys a Naval Battle Group (Warships).
function DeployBattleGroup(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end
    local params = TCS.API.Normalize(args, "COMPANY", "SEA")
    
    if not params.anchor then return nil end
    if not TCS.Sea or not TCS.Sea.Architect then return nil end
    return TCS.Sea.Architect.Build("SUW_ANTISHIP", params)
end

--- Deploys Ambient Civilian/Neutral Shipping.
function DeployCivilian(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end
    local params = TCS.API.Normalize(args, "COMPANY", "SEA")
    
    if not params.anchor then return nil end
    if not TCS.Sea or not TCS.Sea.Architect then return nil end
    return TCS.Sea.Architect.Build("MAR_HARBOR", params) -- Or whatever mapping fits best
end

--- Deploys a Naval Convoy (Cargo ships led by Naval Warships).
function DeployConvoy(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end
    local params = TCS.API.Normalize(args, "COMPANY", "SEA")
    
    if not params.anchor then return nil end
    if not TCS.Sea or not TCS.Sea.Architect then return nil end
    return TCS.Sea.Architect.Build("CONVOY", params)
end

--- Deploys Ambient Traffic with interspersed Naval combatants acting as escorts.
function DeployTraffic(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end
    local params = TCS.API.Normalize(args, "COMPANY", "SEA")
    
    if not params.anchor then return nil end
    if not TCS.Sea or not TCS.Sea.Architect then return nil end
    return TCS.Sea.Architect.Build("SUW_STRIKE", params) -- Mixed traffic/combat
end

--- Outfits an airbase or trigger zone with ambient static traffic.
function OutfitBase(args, argDensity, argMax)
    local params = type(args) == "table" and args or { base = args, density = argDensity, maxItems = argMax }
    if TCS.Air and TCS.Air.Ambient and TCS.Air.Ambient.OutfitBase then
        TCS.Air.Ambient.OutfitBase(params)
    else
        if TCS.Logger then TCS.Logger.warn("TCS(API): Air.Ambient module missing. Cannot outfit base.") end
    end
end
TCS.OutfitBase = OutfitBase -- Namespace mapping for specific use cases

--- Smart Legacy Wrapper for V1 DeployCAP (Routes by missionType)
local function TCS_Legacy_DeployCAP(args)
    local p = type(args) == "table" and args or {}
    local mType = string.upper(p.missionType or "CAP")
    if mType == "SWEEP" then return DeploySweep(args)
    elseif mType == "INTERCEPT" then return DeployIntercept(args)
    elseif mType == "ESCORT" then return DeployEscort(args)
    else return DeployCap(args) end
end

-- Low-Level Control Interfaces (The General)
TCS.DeployGroundForces = DeployGroundForces
TCS.DeploySAM          = DeploySAM
TCS.DeployCAP          = TCS_Legacy_DeployCAP
TCS.DeployCap          = DeployCap
TCS.DeploySweep        = DeploySweep
TCS.DeployStrike       = DeployStrike
TCS.DeployIntercept    = DeployIntercept
_G.DeployCAP           = TCS_Legacy_DeployCAP
_G.DeployAirPatrol     = DeployCap

--- Deploys a Training Range setup.
function DeployRange(args)
    if type(args) ~= "table" then
        env.warning("TCS(API): Positional arguments are deprecated. Please use the structured args table.")
        return nil
    end
    local params = TCS.API.Normalize(args, "PLATOON", "LAND")
    
    if not params.anchor then return nil end
    if not TCS.Land or not TCS.Land.Architect then return nil end
    return TCS.Land.Architect.Build("RANGE", params)
end

--- Extracts a polyline from the DCS F10 Map Drawings
function ExtractF10Line(drawingName)
    if not env.mission or not env.mission.drawings or not env.mission.drawings.layers then
        return nil
    end
    
    for _, layer in pairs(env.mission.drawings.layers) do
        for _, obj in pairs(layer.objects) do
            if obj.name == drawingName and obj.points then
                local extractedPoints = {}
                local maxKey = 0
                for k, _ in pairs(obj.points) do
                    if type(k) == "number" and k > maxKey then maxKey = k end
                end
                for i = 1, maxKey do
                    if obj.points[i] then
                        table.insert(extractedPoints, { x = obj.mapX + obj.points[i].x, y = obj.mapY + obj.points[i].y })
                    end
                end
                return extractedPoints
            end
        end
    end
    return nil
end

--- Deploys Tripwire notification lines on the F10 map.
function DeployTripwire(args)
    local req = args or {}
    if not TCS.CIC or not TCS.CIC.Tripwire then return end

    local function registerPoints(baseName, points, config)
        for i = 1, #points - 1 do
            local p1 = {x = points[i].x, y = points[i].y or points[i].z}
            local p2 = {x = points[i+1].x, y = points[i+1].y or points[i+1].z}
            TCS.CIC.Tripwire.AddLine(baseName .. "_seg_" .. i, p1, p2, req.coalition or coalition.side.RED, config)
        end
    end

    if req.lines then
        for _, lineName in ipairs(req.lines) do
            if ExtractF10Line then
                local points = ExtractF10Line(lineName)
                if points and #points > 0 then registerPoints(lineName, points, req) end
            end
        end
    elseif req.points then registerPoints(req.name or "Custom_Tripwire", req.points, req) end
end

--- Requests JTAC to lase the current objective.
function TCS.API.JTAC_LaserOn(args)
    if TCS.CIC and TCS.CIC.JTAC then TCS.CIC.JTAC.LaserOn(args.group, args.targetCoord, args.code, args.duration) end
end

--- Repeats the last 9-line or waypoint tasking.
function TCS.API.JTAC_RepeatTasking(args)
    if TCS.CIC and TCS.CIC.JTAC then TCS.CIC.JTAC.RepeatTasking(args.group) end
end

env.info("TCS(API.THEATER): ready")