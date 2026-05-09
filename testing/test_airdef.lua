---------------------------------------------------------------------
-- TCS AIR DEFENSE DOMAIN TEST SUITE
-- Purpose: Validates Catalog, Inventory, Architect, and Spawner.
---------------------------------------------------------------------
env.info("TCS(TEST): Initializing Air Defense Domain Test...")

-- TEST 3: The Lethal Post-Merge Ambush
-- Tests the Architect's ROE toggles and the Controller's high-speed distance math.
-- Spawns an SA-15 site that remains totally dark until an aircraft passes over it 
-- and is moving AWAY at less than 3 NM.
function Test_SAM_1(zoneName)
    env.info("TCS(TEST): Running SAM Scenario...1")
    DeploySAM({
        anchor = zoneName or "Zone_Charlie",
        forceSize = "SA-15",
        silent = -3
    })
end

function Test_DSAM_REDFOR(zoneName)
    local redfor_sams = {"SA-2", "SA-3", "SA-5", "SA-6", "SA-8", "SA-9", "SA-10", "SA-11", "SA-13", "SA-15", "SA-19", "SA-22"}
    for i, sam in ipairs(redfor_sams) do
        env.info("TCS(TEST): Spawning REDFOR SAM: " .. sam)
        DeploySAM({ anchor = zoneName or "Zone_Alpha", samType = sam, threat = "H" })
    end
end

function Test_DSAM_BLUEFOR(zoneName)
    local bluefor_sams = {"Hawk", "Patriot", "NASAMS", "Vulcan", "M6 Linebacker", "M1097 Avenger", "M48 Chaparral", "Rapier", "Roland"}
    for i, sam in ipairs(bluefor_sams) do
        env.info("TCS(TEST): Spawning BLUEFOR SAM: " .. sam)
        DeploySAM({ anchor = zoneName or "Zone_Bravo", samType = sam, threat = "H", coalition = coalition.side.BLUE })
    end
end

function Test_SEAD(zoneName)
    env.info("TCS(TEST): Running SEAD Scenario (Mobile SHORAD)...")
    if TCS.AirDef and TCS.AirDef.Architect then
        TCS.AirDef.Architect.Build("SEAD", {
            anchor = zoneName or "TargetZone",
            threat = "X",
            coalition = coalition.side.RED
        })
    end
end

function Test_DEAD(zoneName)
    env.info("TCS(TEST): Running DEAD Scenario (Integrated Defense + Armor)...")
    if TCS.AirDef and TCS.AirDef.Architect then
        TCS.AirDef.Architect.Build("DEAD", {
            anchor = zoneName or "Zone_Charlie",
            samType = "SA-10",
            threat = "H",
            coalition = coalition.side.RED
        })
    end
end

-- TEST 6: Massive SAM Grid Validation
-- Spawns every single SAM system and tier layout from the catalog in a massive grid.
-- Draws a circle and label for each site on the F10 map for visual inspection.
function Test_SAM_Grid(zoneName)
    env.info("TCS(TEST): Running Full SAM Grid Deployment...")
    local targetZoneName = zoneName or "Damascus"
    
    local anchorCoord
    local anchorZone = ZONE:FindByName(targetZoneName)
    if anchorZone then
        anchorCoord = anchorZone:GetCoordinate()
    else
        env.warning("TCS(TEST): Zone '" .. targetZoneName .. "' not found! Falling back to Blue Bullseye.")
        local bullseye = coalition.getMainRefPoint(coalition.side.BLUE)
        anchorCoord = COORDINATE:NewFromVec3(bullseye)
    end

    local index = 1
    local cols = 8
    local spacing = 4000 -- 4 km spacing between sites

    for sysName, sysData in pairs(TCS.AirDef.Catalog) do
        if sysData.layouts then
            for tier, _ in pairs(sysData.layouts) do
                
                local row = math.floor((index - 1) / cols)
                local col = (index - 1) % cols
                
                -- Translate from the anchor: East for columns, North for rows
                local spawnCoord = anchorCoord:Translate(col * spacing, 90):Translate(row * spacing, 0)
                local label = string.format("%s (Tier: %s)", sysName, tier)
                
                env.info("TCS(TEST): Grid Spawning " .. label)
                
                -- Draw the dynamic zone and label
                mist.marker.add({
                    mType = "circle",
                    pos = spawnCoord:GetVec3(),
                    radius = 1500,
                    text = label,
                    color = {1, 1, 1, 1},
                    fillColor = {0, 0, 0, 0.1},
                    lineType = 1,
                    readOnly = true
                })
                
                -- Deploy the SAM
                DeploySAM({
                    anchor = spawnCoord,
                    samType = sysName,
                    threat = tier,
                    coalition = (sysData.coalition == "BLUE") and coalition.side.BLUE or coalition.side.RED
                })
                
                index = index + 1
            end
        end
    end
    env.info("TCS(TEST): Deployed " .. (index - 1) .. " SAM configurations to the grid.")
end

function Test_DSAM()
    if TCS_Cleanup then TCS_Cleanup() end
    Test_DSAM_REDFOR()
    Test_DSAM_BLUEFOR()
end

function Test_AIRDEF()
    if TCS_Cleanup then TCS_Cleanup() end
    Test_SEAD()
    Test_DEAD()
end

env.info("TCS(TEST): AirDef Test Suite Ready. Use 'Test_DSAM()', 'Test_AIRDEF()', or 'Test_SAM_Grid()' in console.")