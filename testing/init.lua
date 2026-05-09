-- Testing Modules
---------------------------------------------------------------------
-- TCS: TEST SUITE INITIALIZATION
---------------------------------------------------------------------
env.info("TCS(TESTS): Bootstrapping test modules...")
TCS_LOAD("testing/smoke_tests.lua")
TCS_LOAD("testing/test_ground.lua")
TCS_LOAD("testing/test_air.lua")
TCS_LOAD("testing/test_sea.lua")
TCS_LOAD("testing/test_airdef.lua")
TCS_LOAD("testing/test_range.lua")
TCS_LOAD("testing/test_bandit_catalog.lua")
