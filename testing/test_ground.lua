---------------------------------------------------------------------
-- TCS GROUND DOMAIN TEST SUITE
-- Purpose: Validates Catalog, Inventory, Architect, and Spawner.
---------------------------------------------------------------------
env.info("TCS(TEST): Initializing Ground Domain Test...")

-- TEST 1: The Standard Doctrinal Deployment
-- Tests normal scaling, era filtering, and tactical sub-grouping.
-- Spawns a full Company of mechanized infantry 10-15 NM North (ingressHdg = 0).
function Test_GF_1(zoneName)
    env.info("TCS(TEST): Running GF Scenario...1")
    DeployGroundForces({
        anchor = "Zone_Charlie",
        forceSize = "COMPANY",
        minNm = 10,
        maxNm = 15,
        ingressHdg = 0 
    })
end

-- TEST 2: The Smart Custom Deployment with Concealment
-- Tests exact custom unit arrays and the new Placements Scenery/Tree scanner.
-- Spawns exactly 4 Armor and 12 Infantry very close to the zone, forced into cover.
function Test_Custom_1(zoneName)
    env.info("TCS(TEST): Running Custom Scenario...1")
    DeployCustom({
        anchor = "Zone_Charlie",
        forceSize = { {"ARMOR", 4}, {"INFANTRY", 12} },
        minNm = 1,
        maxNm = 3,
        hidden = true
    })
end

-- TEST 3: The Lethal Post-Merge Ambush
-- Tests the Architect's ROE toggles and the Controller's high-speed distance math.
-- Spawns an SA-15 site that remains totally dark until an aircraft passes over it 
-- and is moving AWAY at less than 3 NM.
function Test_SAM_1(zoneName)
    env.info("TCS(TEST): Running SAM Scenario...1")
    DeploySAM({
        anchor = "Zone_Charlie",
        forceSize = "SA-15",
        silent = -3
    })
end

-- 4. Helper to wipe the slate
function TCS_Cleanup()
    env.info("TCS(TEST): Cleaning up all TCS groups and statics...")
    for _, side in pairs({1, 2}) do
        local groups = coalition.getGroups(side)
        for _, g in ipairs(groups) do
            if string.find(g:getName(), "TCS_") then g:destroy() end
        end
        local statics = coalition.getStaticObjects(side)
        for _, s in ipairs(statics) do
            if string.find(s:getName(), "TCS_") then s:destroy() end
        end
    end
end

function Test_GROUND()
    TCS_Cleanup()
    Test_GF_1()
    Test_Custom_1()
    Test_SAM_1()
end

env.info("TCS(TEST): Ground Test Suite Ready.")

-- Auto-execution removed. 
-- Type "/test" or "/run Test_GROUND" in DCS multiplayer chat to trigger this script!
Test_Custom_1() -- Uncomment to run this test directly on mission start.