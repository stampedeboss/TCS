---------------------------------------------------------------------
-- TCS SEA ARCHITECT
-- Director Layer: Assembles Naval Strike and Maritime Patrols.
---------------------------------------------------------------------
env.info("TCS(SEA.ARCHITECT): loading")

TCS = TCS or {}
TCS.Sea = TCS.Sea or {}
TCS.Sea.Architect = {}

function TCS.Sea.Architect.Build(missionType, params)
    local anchor = params.anchor
    if not anchor then return nil end
    
    params.coalition = params.coalition or coalition.side.RED
    local searchTier = params.threat or "H"
    local missionYear = params.year or (env.mission and env.mission.date and env.mission.date.Year) or 2000
    
    -- Determine ship role based on the mission type requested
    local searchRole = "PATROL"
    if missionType == "SUW" then
        if searchTier == "G" then searchRole = "PATROL"
        elseif searchTier == "H" then searchRole = "CORVETTE"
        elseif searchTier == "X" then searchRole = "FRIGATE"
        end
    elseif missionType == "MAR" then
        searchRole = "CARGO"
    end

    -- Query Catalog for Maritime assets
    local candidates = TCS.Sea.Catalog and TCS.Sea.Catalog.Query({role=searchRole, tier=searchTier, year=missionYear}) or {}
    if #candidates == 0 then candidates = TCS.Sea.Catalog and TCS.Sea.Catalog.Query({role=searchRole}) or {} end
    
    local shipDef = #candidates > 0 and candidates[math.random(#candidates)] or nil
    if not shipDef then
        env.warning("TCS(SEA.ARCHITECT): No naval vessels found in catalog for query.")
        return nil
    end
    
    -- Resolve Scale based on Maritime Echelons
    local unitType = shipDef.unit_types[1]
    local count = 1
    if params.echelon == "SEA_PATROL" then count = 1
    elseif params.echelon == "TASK_UNIT" then count = 2
    elseif params.echelon == "TASK_GROUP" then count = 4
    elseif params.echelon == "TASK_FORCE" then count = 6
    end

    local blueprint = {}
    for i = 1, count do
        table.insert(blueprint, { x = -(i-1)*1000, y = (i-1)*1000, unitType = unitType, skill = shipDef.skill or "High" })
    end

    local recipe = {
        tower = "SEA", missionType = missionType, category = Group.Category.SHIP, coalition = params.coalition,
        blueprint = blueprint,
        geometry = { type = "DIRECTIONAL_SPAWN", anchor = anchor, minNm = params.minNm or 15, maxNm = params.maxNm or 30, ingressHdg = params.anchorHdg, ingressArc = 90, domain = "SEA" },
        behavior = { mode = "ADVANCE", target = anchor }
    }
    
    if TCS.Dispatcher and TCS.Dispatcher.ExecuteRequisition then return TCS.Dispatcher.ExecuteRequisition(recipe) end
end
env.info("TCS(SEA.ARCHITECT): ready")