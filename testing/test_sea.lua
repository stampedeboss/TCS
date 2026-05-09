---------------------------------------------------------------------
-- TCS TEST SCRIPT: SEA MODULE
-- Usage: Run this via "Do Script File" or "Do Script" in ME.
-- Prerequisite: Ensure a Trigger Zone named "ZONE_TEST_SEA" exists over water.
---------------------------------------------------------------------
env.info("TCS(TEST): Running Sea Module Tests")

-- Test 1: Naval Battle Group
-- Expectation: Spawns a Diamond formation of warships pushing aggressively toward the anchor.
DeployBattleGroup({
    objective = { anchor = "ZONE_TEST_SEA", minNm = 5, maxNm = 10 },
    deployment = { forceSize = "SQUADRON", coalition = coalition.side.RED, skill = "G" }
})

-- Test 2: Naval Convoy
-- Expectation: Spawns a Line Ahead formation of cargo ships led by a naval escort.
DeployConvoy({
    objective = { anchor = "ZONE_TEST_SEA", minNm = 15, maxNm = 20 },
    deployment = { count = 5, coalition = coalition.side.RED, skill = "A" }
})

-- Test 3: Ambient Civilian Traffic
-- Expectation: Scatters 8 neutral cargo ships around the zone with Weapon Hold ROE.
DeployCivilian({
    objective = { anchor = "ZONE_TEST_SEA", minNm = 5, maxNm = 25 },
    deployment = { count = 8 }
})

-- Test 4: Ambient Traffic (Mixed with Escorts)
-- Expectation: Scatters civilian shipping but intersperses hidden naval combatants acting as escorts.
DeployTraffic({
    objective = { anchor = "ZONE_TEST_SEA", minNm = 10, maxNm = 30 },
    deployment = { count = 10, coalition = coalition.side.RED, skill = "G" }
})

env.info("TCS(TEST): Sea Module Tests Dispatched")