---------------------------------------------------------------------
-- TCS TEST SCRIPT: AIR MODULE
-- Usage: Run this via "Do Script File" or "Do Script" in ME.
-- Prerequisite: Ensure a Trigger Zone named "ZONE_TEST_AIR" exists.
---------------------------------------------------------------------
env.info("TCS(TEST): Running Air Module Tests")

-- Test 1: Combat Air Patrol (CAP)
-- Expectation: Spawns a 4-ship Wedge of High-skill Red fighters 10-20 NM from the zone, circling in a CAP.
DeployCap({
    objective = { 
        anchor = "ZONE_TEST_AIR", 
        minNm = 10, 
        maxNm = 20 
    },
    deployment = { 
        forceSize = "SQUADRON", 
        coalition = coalition.side.RED, 
        skill = "H" 
    }
})

-- Test 2: Offensive Air Sweep
-- Expectation: Spawns a 2-ship Trail of Boss-tier fighters 30-50 NM out, ingressing from the South (180).
DeploySweep({
    objective = { anchor = "ZONE_TEST_AIR", minNm = 30, maxNm = 50, ingressHdg = 180 },
    deployment = { forceSize = "FLIGHT", coalition = coalition.side.RED, skill = "X" }
})

env.info("TCS(TEST): Air Module Tests Dispatched")