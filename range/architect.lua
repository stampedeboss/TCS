---------------------------------------------------------------------
-- TCS RANGE TOWER: ARCHITECT
-- Generates target practice arrays and initializes MOOSE Range scripts.
---------------------------------------------------------------------
env.info("TCS(RANGE.ARCHITECT): loading")

TCS = TCS or {}
TCS.Range = TCS.Range or {}
TCS.Range.Architect = {}

local function BuildOffsets(cfg)
    local pts = {}
    local spacing = cfg.spacing_m or 50
    if cfg.pattern == "ROW" then
        for i = 1, (cfg.count or 5) do table.insert(pts, {x = (i-1)*spacing, y = 0}) end
    elseif cfg.pattern == "STAR" then
        local count = cfg.count or 5
        local step = (2 * math.pi) / count
        for i = 1, count do table.insert(pts, {x = math.cos(step*i)*spacing, y = math.sin(step*i)*spacing}) end
    elseif cfg.pattern == "GRID" then
        local rows, cols = cfg.rows or 2, cfg.cols or 2
        local offX = (cols - 1) * spacing / 2
        local offY = (rows - 1) * spacing / 2
        for r = 1, rows do
            for c = 1, cols do table.insert(pts, {x = (c-1)*spacing - offX, y = (r-1)*spacing - offY}) end
        end
    end
    return pts
end

local function start_funkman(R)
    if not debug then return end
    local info = debug.getinfo(1, 'S')
    local current_file_path = info and info.source and info.source:sub(2) or ""

    if string.find(current_file_path, 'FlyingWrecks') then
        R:SetFunkManOn(10043)
        env.info("TCS(RANGE): FunkMan Started on port 10043")
        return
    end
    if string.find(current_file_path, 'Stampede') then
        R:SetFunkManOn(10042)
        env.info("TCS(RANGE): FunkMan Started on port 10042")
        return
    end
    env.info("TCS(RANGE): Running Single Player, No Funkman")
end

function TCS.Range.Architect.Build(category, params)
    local rangeConfigKey = params.rangeConfig or "STRAFE_PIT"
    local cfg = TCS.Range.Layouts and TCS.Range.Layouts[rangeConfigKey]
    if not cfg then return nil end

    -- Resolve the exact center point upfront so we can build the MOOSE Zone around it
    local distMeters = math.random(params.minNm or 5, params.maxNm or 15) * 1852
    local targetCoord = params.anchor:Translate(distMeters, params.anchorHdg)

    local blueprint = {}
    for i, pt in ipairs(BuildOffsets(cfg)) do
        local uType = cfg.target_pool[math.random(#cfg.target_pool)]
        if TCS.Range.Fallbacks and TCS.Range.Fallbacks[uType] then uType = TCS.Range.Fallbacks[uType] end

        table.insert(blueprint, {
            x = pt.x,
            y = pt.y,
            unitType = uType,
            isStatic = (cfg.activity ~= "CONVOY"),
            staticCategory = (cfg.activity ~= "CONVOY") and "Fortifications" or nil,
            skill = "Average"
        })
    end

    local recipe = {
        tower = "RANGE",
        missionType = rangeConfigKey,
        category = (cfg.activity == "CONVOY") and Group.Category.GROUND or nil,
        coalition = coalition.side.RED,
        blueprint = blueprint,
        geometry = { type = "DIRECTIONAL_SPAWN", anchor = targetCoord, minNm = 0, maxNm = 0, ingressHdg = params.anchorHdg, domain = "LAND" },
        behavior = (cfg.activity == "CONVOY") and { mode = "ADVANCE", target = params.anchor } or nil
    }

    if TCS.Architect and TCS.Architect.ExecuteRequisition then 
        local zoneId = TCS.Architect.ExecuteRequisition(recipe)
        
        -- Seamlessly wrap the MOOSE Range around the deployed targets
        if zoneId and RANGE then
            ZONE_RADIUS:New("A2G_RANGE_" .. zoneId, targetCoord:GetVec2(), 9000) -- 9km safety net
            local r = RANGE:New("A2G_RANGE_" .. zoneId)
            if r then
                r:SetRangeControl(252.000)
                r:TrackBombsON()
                r:TrackRocketsON()
                r:SetDefaultPlayerSmokeBomb(true)
                start_funkman(r)
                r:Start()
            end
        end
    end
end
env.info("TCS(RANGE.ARCHITECT): ready")