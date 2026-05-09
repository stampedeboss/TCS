---------------------------------------------------------------------
-- TCS SEA TOWER: MENU CONFIGURATION
-- Defines maritime F10 options and passes constraints to the Spawner.
---------------------------------------------------------------------
env.info("TCS(SEA.MENU_CONFIG): loading")

TCS = TCS or {}
TCS.Sea = TCS.Sea or {}
TCS.Sea.MenuConfig = {
    SUW = {
        { label = "Patrol Boat (15-25 NM)",        minNm = 15, maxNm = 25,  echelon = "SEA_PATROL", threat = "G" },
        { label = "Corvette Task Unit (25-40 NM)", minNm = 25, maxNm = 40,  echelon = "TASK_UNIT",  threat = "H" },
        { label = "Frigate Task Group (40-60 NM)", minNm = 40, maxNm = 60,  echelon = "TASK_GROUP", threat = "H" },
        { label = "Heavy Task Force (60-100 NM)",  minNm = 60, maxNm = 100, echelon = "TASK_FORCE", threat = "X" }
    },
    MAR = {
        { label = "Coastal Shipping (15-30 NM)",   minNm = 15, maxNm = 30, echelon = "SEA_PATROL", threat = "A" },
        { label = "Armed Convoy (30-60 NM)",       minNm = 30, maxNm = 60, echelon = "TASK_UNIT",  threat = "G" },
        { label = "Naval Harbor (20-40 NM)",       minNm = 20, maxNm = 40, echelon = "TASK_GROUP", threat = "H" }
    }
}

env.info("TCS(SEA.MENU_CONFIG): ready")