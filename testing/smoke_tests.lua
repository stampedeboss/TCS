---------------------------------------------------------------------
-- TCS TESTS: SMOKE TESTS
-- Generates massive grids of every unit in the catalogs to verify
-- DCS spawning engine and models don't crash.
---------------------------------------------------------------------
env.info("TCS(TESTS): loading")

TCS = TCS or {}
TCS.Tests = {}

-- Helper to generate a square grid offset from a starting anchor
local function GetGridCoord(anchor, index, spacingX, spacingY)
    local cols = 8
    local row = math.floor((index - 1) / cols)
    local col = (index - 1) % cols
    return anchor:Translate(col * spacingX, 90):Translate(row * spacingY, 0)
end

-- Helper to draw a labeled boundary circle on the F10 Map
local function DrawTestZone(anchor, label, radius)
    local vec3 = anchor:GetVec3()
    local markId1 = math.random(1000000, 9999999)
    local markId2 = math.random(1000000, 9999999)
    trigger.action.circleToAll(-1, markId1, vec3, radius or 500, {1, 1, 1, 1}, {0, 0, 0, 0}, 2, true)
    trigger.action.textToAll(-1, markId2, vec3, {1, 1, 1, 1}, {0, 0, 0, 0.5}, 11, true, label)
end

function TCS.Tests.SpawnAllAir(anchor)
    if not TCS.Air or not TCS.Air.Catalog or not TCS.Air.Catalog.Data then return 0 end
    local count = 0
    local index = 1
    for section, sectionData in pairs(TCS.Air.Catalog.Data) do
        for _, entry in ipairs(sectionData) do
            local spawnPt = GetGridCoord(anchor, index, 3000, 3000)
            DrawTestZone(spawnPt, "AIR: " .. (entry.id or "Unknown"), 1000)
            spawnPt:SetAltitude(6096) -- 20k ft
            local recipe = {
                tower = "TEST", missionType = "TEST_AIR", category = Group.Category.AIRPLANE, coalition = coalition.side.RED,
                blueprint = {{x=0, y=0, unitType = entry.unit_types and entry.unit_types[1] or entry.unit_type, skill="Average"}},
                geometry = {type = "DIRECTIONAL_SPAWN", anchor = spawnPt, minNm=0, maxNm=0, ingressHdg=0, domain="AIR"}
            }
            if TCS.Dispatcher and TCS.Dispatcher.ExecuteRequisition then
                TCS.Dispatcher.ExecuteRequisition(recipe)
                count = count + 1
            end
            index = index + 1
        end
    end
    return count
end

function TCS.Tests.SpawnAllSea(anchor)
    if not TCS.Sea or not TCS.Sea.Catalog or not TCS.Sea.Catalog.Data then return 0 end
    local count = 0
    for i, entry in ipairs(TCS.Sea.Catalog.Data) do
        local spawnPt = GetGridCoord(anchor, i, 3000, 3000)
        DrawTestZone(spawnPt, "SEA: " .. (entry.id or "Unknown"), 1000)
        local recipe = {
            tower = "TEST", missionType = "TEST_SEA", category = Group.Category.SHIP, coalition = coalition.side.RED,
            blueprint = {{x=0, y=0, unitType = entry.unit_types and entry.unit_types[1] or entry.unit_type, skill="Average"}},
            geometry = {type = "DIRECTIONAL_SPAWN", anchor = spawnPt, minNm=0, maxNm=0, ingressHdg=0, domain="SEA"}
        }
        if TCS.Dispatcher and TCS.Dispatcher.ExecuteRequisition then
            TCS.Dispatcher.ExecuteRequisition(recipe)
            count = count + 1
        end
    end
    return count
end

function TCS.Tests.SpawnAllGround(anchor)
    if not TCS.Config or not TCS.Config.LandCatalog then return 0 end
    local count = 0
    local i = 1
    for unitName, entry in pairs(TCS.Config.LandCatalog) do
        local spawnPt = GetGridCoord(anchor, i, 500, 500)
        DrawTestZone(spawnPt, "GND: " .. unitName, 200)
        local isStatic = (entry.role == "FORTIFICATION" or entry.role == "STRUCTURE")
        local recipe = {
            tower = "TEST", missionType = "TEST_GND", category = Group.Category.GROUND, coalition = coalition.side.RED,
            blueprint = {{
                x=0, y=0, unitType = unitName, 
                isStatic = isStatic, staticCategory = isStatic and "Fortifications" or nil, skill="Average"
            }},
            geometry = {type = "DIRECTIONAL_SPAWN", anchor = spawnPt, minNm=0, maxNm=0, ingressHdg=0, domain="LAND"}
        }
        if TCS.Dispatcher and TCS.Dispatcher.ExecuteRequisition then
            TCS.Dispatcher.ExecuteRequisition(recipe)
            count = count + 1
        end
        i = i + 1
    end
    return count
end

function TCS.Tests.SpawnAllRanges(anchor)
    if not TCS.Range or not TCS.Range.Layouts then return 0 end
    local count = 0
    local i = 1
    for key, layout in pairs(TCS.Range.Layouts) do
        local spawnPt = GetGridCoord(anchor, i, 4000, 4000)
        DrawTestZone(spawnPt, "RANGE: " .. key, 1500)
        -- Bypass normal minNm geometry to force exact spawn locations on the grid
        local params = { anchor = spawnPt, anchorHdg = 0, minNm=0, maxNm=0, rangeConfig = key }
        if TCS.Range.Architect and TCS.Range.Architect.Build then
            TCS.Range.Architect.Build("TEST", params)
            count = count + 1
        end
        i = i + 1
    end
    return count
end

-- Inject F10 Menus into the Admin Root
TCS.Menu = TCS.Menu or {}
TCS.Menu.Builders = TCS.Menu.Builders or {}
table.insert(TCS.Menu.Builders, function(client, roots)
    if not roots.Admin then return end
    local testMenu = MENU_CLIENT:New(client, "V2 Smoke Tests", roots.Admin)
    
    local function RunTest(client, testName, testFunc)
        local u = client:GetClientGroupUnit()
        
        local anchor = nil
        if u then
            -- Offset the anchor slightly in front of the player
            anchor = u:GetCoordinate():Translate(3000, u:GetHeading()) 
        else
            -- Game Master Fallback: Anchor to the Blue Bullseye
            local bullseye = coalition.getMainRefPoint(coalition.side.BLUE)
            if bullseye then
                anchor = COORDINATE:NewFromVec3(bullseye)
            else
                anchor = COORDINATE:New(0,0,0)
            end
        end
        
        local count = testFunc(anchor)
        
        if MESSAGE then MESSAGE:New("TCS TESTS: Spawned " .. tostring(count) .. " " .. testName .. " elements. Check F10 Map.", 10):ToClient(client) end
    end

    MENU_CLIENT_COMMAND:New(client, "Test All Air Catalog", testMenu, RunTest, client, "Air", TCS.Tests.SpawnAllAir)
    MENU_CLIENT_COMMAND:New(client, "Test All Sea Catalog", testMenu, RunTest, client, "Sea", TCS.Tests.SpawnAllSea)
    MENU_CLIENT_COMMAND:New(client, "Test All Ground Catalog", testMenu, RunTest, client, "Ground", TCS.Tests.SpawnAllGround)
    MENU_CLIENT_COMMAND:New(client, "Test All Range Layouts", testMenu, RunTest, client, "Range", TCS.Tests.SpawnAllRanges)
end)

env.info("TCS(TESTS): ready")