---------------------------------------------------------------------
-- TCS TEST SCRIPT: RANGE MODULE
-- Usage: Run this via "Do Script File" or "Do Script" in ME.
-- Prerequisite: A player group named "Test_Player_Group" with a unit named "Test_Player_Unit" must be in the mission.
---------------------------------------------------------------------
env.info("TCS(TEST): Running Range Module Tests")

-- The names of your test aircraft in the Mission Editor
local testGroupName = "Test_Player_Group"
local testUnitName = "Test_Player_Unit"

if GROUP:FindByName(testGroupName) then
    -- Test 1: Bombing Range
    -- Expectation: Spawns a target range (like concentric tires/containers) a few miles directly ahead of the player.
    -- Note: "BOMB_CIRCLE" should match a valid key in your TCS.Config.A2G.Range table.
    if TCS.RANGE and TCS.RANGE.Create then
        TCS.RANGE.Create(testGroupName, testUnitName, "BOMB_CIRCLE")
        env.info("TCS(TEST): Range 'BOMB_CIRCLE' Generation Triggered")
    end
else
    env.warning("TCS(TEST): Cannot test Range module - Group '" .. testGroupName .. "' not found. Make sure you spawn in first!")
end

env.info("TCS(TEST): Range Module Tests Completed")