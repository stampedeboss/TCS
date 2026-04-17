---------------------------------------------------------------------
-- TCS GROUND DOMAIN TEST SUITE
-- Purpose: Validates Catalog, Inventory, Architect, and Spawner.
---------------------------------------------------------------------
env.info("TCS(TEST): Initializing Ground Domain Test...")

--- TEST Direct Demand (Bypass Blueprints + Specific Counts)
function Test_Armor1(zoneName)
    env.info("TCS(SPAWN): Running Direct Demand Spawn (Armor/AirDef)...")
    TriggerSystemSpawn({
        anchor = zoneName or "BAI 1",
        composition = {
            ARMOR = 5, 
            AIRDEF = 1
        },
        coalition = coalition.side.RED,
        skill = "H",
        minNm = 5,
        maxNm = 6,
        ingressHdg = 98,
        ingressArc = 100,
        respawn = false,
        reinforce = false
    })
    TriggerSystemSpawn({
        anchor = zoneName or "BAI 1",
        composition = {
            ARMOR = 2, 
            AIRDEF = 3
        },
        coalition = coalition.side.RED,
        skill = "H",
        minNm = 5,
        maxNm = 6,
        ingressHdg = 98,
        ingressArc = 100,
        respawn = false,
        reinforce = false
    })
end

function Test_Armor2(zoneName)
    env.info("TCS(SPAWN): Running Direct Demand Spawn (Armor/AirDef)...")
    TriggerSystemSpawn({
        anchor = zoneName or "BAI 1",
        composition = {
            ARMOR = 3, 
            AIRDEF = 1
        },
        coalition = coalition.side.RED,
        skill = "H",
        minNm = 5,
        maxNm = 6,
        ingressHdg = 10,
        ingressArc = 30,
        respawn = false,
        reinforce = false
    })
    TriggerSystemSpawn({
        anchor = zoneName or "BAI 1",
        composition = {
            ARMOR = 1, 
            AIRDEF = 1,
			TRANSPORT = 4
        },
        coalition = coalition.side.RED,
        skill = "H",
        minNm = 5,
        maxNm = 6,
        ingressHdg = 10,
        ingressArc = 30,
        respawn = false,
        reinforce = false
    })
end

function Test_Infantry1(zoneName)
    env.info("TCS(SPAWN): Running Direct Demand Spawn (Test_Infantry1)...")
    TriggerSystemSpawn({
        anchor = zoneName or "BAI 1",
        composition = { INFANTRY = 6 },
        coalition = coalition.side.RED,
        skill = "H",
        minNm = 5,
        maxNm = 6,
        ingressHdg = 10,
        ingressArc = 30,
        respawn = false,
        reinforce = false
    })
    TriggerSystemSpawn({
        anchor = zoneName or "BAI 1",
        composition = { INFANTRY = 8 },
        coalition = coalition.side.RED,
        skill = "H",
        minNm = 5,
        maxNm = 6,
        ingressHdg = 10,
        ingressArc = 30,
        respawn = false,
        reinforce = false
    })
end

--- TEST BAI: Standard BAI (Echelon Scaling + Motor Pool Check)
function Test_BAI_R(zoneName)
    env.info("TCS(TEST): Running BAI Scenario... RED COALITION VERSION")
    TriggerMissionBAI({
        anchor = zoneName or "BAI 1",
        echelon = "PLATOON",
        coalition = coalition.side.RED,
        minNm = 2, -- Short distance for visual testing
        maxNm = 4,
        ingressHdg = 180,
        ingressArc = 60,
        respawn = false,
        reinforce = false,
        transitTime = 5 -- Hurry to target in 5 mins
    })
end

function Test_BAI_B(zoneName)
    env.info("TCS(TEST): Running BAI Scenario... BLUE COALITION VERSION")
    TriggerMissionBAI({
        anchor = zoneName or "BAI 2",
        echelon = "PLATOON",
        coalition = coalition.side.BLUE,
        minNm = 2, -- Short distance for visual testing
        maxNm = 4,
        ingressHdg = 0,
        ingressArc = 60,
        respawn = false,
        reinforce = false,
        transitTime = 5 -- Hurry to target in 5 mins
    })
end

--- TEST CAS (Converge interaction + Multiple Requisitions)
function Test_CAS(zoneName)
    env.info("TCS(TEST): Running CAS Scenario...")
    TriggerMissionCAS({
        anchor = zoneName or "TargetZone",
        echelon = "PLATOON",
        coalition = coalition.side.RED, -- Primary enemy side
        separationNm = 2
    })
end

--- TEST DSAM (Pure Doctrinal SAM Site)
function Test_SA2(zoneName, skill)
    env.info("TCS(SPAWN): Running DSAM Scenario (SA-2 Doctrinal Layout)...")
    TriggerSystemDSAM({
        samType = "SA-2",
        anchor = zoneName or "BAI 1",
        skill = skill or "H",
        minNm = 2,
        maxNm = 2,
        ingressHdg = 0,
        ingressArc = 180,
        respawn = false,
        reinforce = false
        -- silent = 15 -- Radar activates when players are within 15 NM
    })
end
 
function Test_SA3(zoneName, skill)
    env.info("TCS(SPAWN): Running DSAM Scenario (SA-3 Doctrinal Layout)...")
    TriggerSystemDSAM({
        samType = "SA-3",
        anchor = zoneName or "BAI 1",
        skill = skill or "H",
        minNm = 3,
        maxNm = 3,
        ingressHdg = 0,
        ingressArc = 180,
        respawn = false,
        reinforce = false
        -- silent = 15 -- Radar activates when players are within 15 NM
    })
end

function Test_SA5(zoneName, skill)
    env.info("TCS(SPAWN): Running DSAM Scenario (SA-5 Doctrinal Layout)...")
    TriggerSystemDSAM({
        samType = "SA-5",
        anchor = zoneName or "BAI 1",
        skill = skill or "H",
        minNm = 4,
        maxNm = 4,
        ingressHdg = 0,
        ingressArc = 180,
        respawn = false,
        reinforce = false
        -- silent = 15 -- Radar activates when players are within 15 NM
    })
end

function Test_SA6(zoneName, skill)
    env.info("TCS(SPAWN): Running DSAM Scenario (SA-6 Doctrinal Layout)...")
    TriggerSystemDSAM({
        anchor = zoneName or "BAI 1",
        samType = "SA-6",
        skill = skill or "H",
		minNm = 5,
		maxNm = 5,
        ingressHdg = 0,
        ingressArc = 180,
		respawn = false,
		reinforce = false
        --silent = 15 -- Radar activates when players are within 15 NM
    })
end

function Test_SA8(zoneName, skill)
    env.info("TCS(SPAWN): Running DSAM Scenario (SA-8 Doctrinal Layout)...")
    TriggerSystemDSAM({
        anchor = zoneName or "BAI 1",
        samType = "SA-8",
        skill = skill or "H",
		minNm = 6,
		maxNm = 6,
        ingressHdg = 0,
        ingressArc = 180,
		respawn = false,
		reinforce = false
        -- silent = 15 -- Radar activates when players are within 15 NM
    })
end

function Test_SA9(zoneName, skill)
    env.info("TCS(SPAWN): Running DSAM Scenario (SA-9 Doctrinal Layout)...")
    TriggerSystemDSAM({
        anchor = zoneName or "BAI 1",
        samType = "SA-9",
        skill = skill or "H",
		minNm = 7,
		maxNm = 7,
        ingressHdg = 0,
        ingressArc = 180,
		respawn = false,
		reinforce = false
        -- silent = 15 -- Radar activates when players are within 15 NM
    })
end

function Test_SA10(zoneName, skill)
    env.info("TCS(SPAWN): Running DSAM Scenario (SA-10 Doctrinal Layout)...")
    TriggerSystemDSAM({
        anchor = zoneName or "BAI 1",
        samType = "SA-10",
        skill = skill or "H",
		minNm = 8,
		maxNm = 8,
        ingressHdg = 0,
        ingressArc = 180,
		respawn = false,
		reinforce = false
        -- silent = 15 -- Radar activates when players are within 15 NM
    })
end

function Test_SA11(zoneName, skill)
    env.info("TCS(SPAWN): Running DSAM Scenario (SA-11 Doctrinal Layout)...")
    TriggerSystemDSAM({
        anchor = zoneName or "BAI 1",
        samType = "SA-11",
        skill = skill or "H",
		minNm = 9,
		maxNm = 9,
        ingressHdg = 0,
        ingressArc = 180,
		respawn = false,
		reinforce = false
        -- silent = 15 -- Radar activates when players are within 15 NM
    })
end

function Test_SA15(zoneName, skill)
    env.info("TCS(SPAWN): Running DSAM Scenario (SA-15 Doctrinal Layout)...")
    TriggerSystemDSAM({
        anchor = zoneName or "BAI 1",
        samType = "SA-15",
        skill = skill or "H",
		minNm = 10,
		maxNm = 10,
        ingressHdg = 0,
        ingressArc = 180,
		respawn = false,
		reinforce = false
        -- silent = 15 -- Radar activates when players are within 15 NM
    })
end

function Test_SA19(zoneName, skill)
    env.info("TCS(SPAWN): Running DSAM Scenario (SA-19 Doctrinal Layout)...")
    TriggerSystemDSAM({
        anchor = zoneName or "BAI 1",
        samType = "SA-19",
        skill = skill or "H",
		minNm = 11,
		maxNm = 11,
        ingressHdg = 0,
        ingressArc = 180,
		respawn = false,
		reinforce = false
        -- silent = 15 -- Radar activates when players are within 15 NM
    })
end

function Test_SA22(zoneName, skill)
    env.info("TCS(SPAWN): Running DSAM Scenario (SA-22 Doctrinal Layout)...")
    TriggerSystemDSAM({
        anchor = zoneName or "BAI 1",
        samType = "SA-22",
        skill = skill or "H",
		minNm = 12,
		maxNm = 12,
        ingressHdg = 0,
        ingressArc = 180,
		respawn = false,
		reinforce = false
        -- silent = 15 -- Radar activates when players are within 15 NM
    })
end

--- TEST DEAD (SAM Battery + Armor/Infantry Protection)
function Test_DEAD(zoneName)
    env.info("TCS(TEST): Running DEAD Scenario (Integrated Defense)...")
    TriggerSystemDEAD({
        anchor = zoneName or "BAI 2",
        samType = "SA-6",
        skill = "H",
        minNm = 1,
        maxNm = 3
    })
end

function Test_SystemCAP()
    env.info("TCS(CAP): Running CAP Scenario")
	return
--[[
  local params = {
    anchor = "BAI 1",
    skill = "G",
    echelon = "SECTION",
    minNm = 35,
    maxNm = 45,
    ingressHdg = 75,
    ingressArc = 50,
    respawn = false,
    reinforce = false
  }

  TriggerSystemCAP(params)  ]]
end

--- TEST RANGES (Bombing, Strafing, Convoys)
function Test_RANGES(zoneName)
    env.info("TCS(TEST): Running Training Range Scenarios...")
    
    -- Create a Bombing Range at BAI 1 (Skill: Good)
    TriggerSystemBombingRange(zoneName or "BAI 1", "G")
    
    -- Create a Strafe Range at BAI 2 (Skill: High)
    TriggerSystemStrafeRange(zoneName or "BAI 2", "H")
    
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
    Test_Armor1()
    Test_Armor2()
    Test_Infantry1()
    Test_BAI_R()
    Test_BAI_B()
    Test_CAS()   
end

function Test_DSAM()
    Test_SA2()
    Test_SA3()
    Test_SA5()
    Test_SA6()
    Test_SA8()
    Test_SA9()
    Test_SA10()
    Test_SA11()
    Test_SA15()
    Test_SA19()
    Test_SA22()
end

function Test_AIRDEF()
    TCS_Cleanup()
    Test_DEAD()
end

function Test_ALL_RANGES()
    TCS_Cleanup()
    Test_RANGES()
end

env.info("TCS(TEST): Ground Test Suite Ready.")

env.info("TCS(TEST): Ground Test Suite Ready. Use 'Test_Ground()' in console.")
env.info("TCS(TEST): DSAM Test Suite Ready. Use 'Test_DSAM()' in console.")
env.info("TCS(TEST): AirDef Test Suite Ready. Use 'Test_AIRDEF()' in console.")
env.info("TCS(TEST): Range Test Suite Ready. Use 'Test_ALL_RANGES()' in console.")

Test_GROUND()
Test_DSAM() -- Focused test for SAM site generation and behavior
Test_ALL_RANGES()