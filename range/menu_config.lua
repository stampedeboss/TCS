---------------------------------------------------------------------
-- TCS RANGE TOWER: MENU CONFIGURATION
-- Defines dynamic range targets and practice layouts.
---------------------------------------------------------------------
env.info("TCS(RANGE.MENU_CONFIG): loading")

TCS = TCS or {}
TCS.Range = TCS.Range or {}
TCS.Range.MenuConfig = {
    STRAFE = {
        { label = "Strafe Pit (5-10 NM)",      minNm = 5,  maxNm = 10, rangeConfig = "STRAFE_PIT" },
        { label = "Convoy Run (10-15 NM)",     minNm = 10, maxNm = 15, rangeConfig = "CONVOY" }
    },
    BOMB = {
        { label = "Bomb Circle (10-20 NM)",    minNm = 10, maxNm = 20, rangeConfig = "BOMB_CIRCLE" },
        { label = "Hard Target (15-25 NM)",    minNm = 15, maxNm = 25, rangeConfig = "BUNKER" }
    }
}
env.info("TCS(RANGE.MENU_CONFIG): ready")