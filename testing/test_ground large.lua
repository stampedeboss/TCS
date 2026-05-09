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
        anchor = "Zone_Alpha",
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
        anchor = "Zone_Bravo",
        forceSize = { {"ARMOR", 4}, {"INFANTRY", 12} },
        minNm = 1,
        maxNm = 3,
        hidden = true
    })
end


--- TEST CAS (Converge interaction + Multiple Requisitions)
function Test_CAS_1(zoneName)
    env.info("TCS(TEST): Running CAS Scenario...1")
    DeployGroundForces({
        anchor = zoneName or "TargetZone",
        echelon = "PLATOON",
        friendlyCoalition = coalition.side.BLUE,
        coalition = coalition.side.RED, -- Primary enemy side
        separationNm = 2
    })
end

--- TEST RANGES (Bombing, Strafing, Convoys)
function Test_RANGE_1(zoneName)
    env.info("TCS(TEST): Running Training Range Scenarios...")
    
    -- Create a Bombing Range at Zone_Charlie (Skill: Good)
    TriggerSystemBombingRange(zoneName or "Zone_Charlie", "G")
    
    -- Create a Strafe Range at Zone_Charlie (Skill: High)
    TriggerSystemStrafeRange(zoneName or "Zone_Charlie", "H")
    
    -- Create a Convoy Range for mobile target practice (Skill: Average)
    TriggerSystemConvoyRange(zoneName or "TargetZone", "A")
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
    Test_CAS_1()   
end

function Test_ALL_RANGES()
    TCS_Cleanup()
    Test_RANGE_1()
end

env.info("TCS(TEST): Ground Test Suite Ready.")

env.info("TCS(TEST): Ground Test Suite Ready. Use 'Test_Ground()' in console.")
env.info("TCS(TEST): Range Test Suite Ready. Use 'Test_ALL_RANGES()' in console.")

Test_GROUND()
Test_ALL_RANGES()