---------------------------------------------------------------------
-- TCS RANGE TOWER: LAYOUTS & FALLBACKS
---------------------------------------------------------------------
env.info("TCS(RANGE.LAYOUTS): loading")

TCS = TCS or {}
TCS.Range = TCS.Range or {}

TCS.Range.Layouts = {
    STRAFE_PIT = {
        pattern = "ROW", count = 10, spacing_m = 15, activity = "STATIC",
        target_pool = { "476_Target_Strafe_Pit_West", "Ural-375", "KAMAZ-43101" }
    },
    CONVOY = {
        pattern = "ROW", count = 6, spacing_m = 50, activity = "CONVOY",
        target_pool = { "Ural-375", "BTR-80" }
    },
    BOMB_CIRCLE = {
        pattern = "STAR", count = 5, spacing_m = 50, activity = "STATIC",
        target_pool = { "476_Target_Circle_75", "Container Red 1" }
    },
    BUNKER = {
        pattern = "GRID", rows = 2, cols = 2, spacing_m = 120, activity = "STATIC",
        target_pool = { "476_Target_Hard_1", "Bunker", "Outpost" }
    }
}

TCS.Range.Fallbacks = {
    ["476_Target_Circle_75"]       = "Container Red 1",
    ["476_Target_Circle_150"]      = "Container Red 1",
    ["476_Target_Square_75"]       = "Container Red 2",
    ["476_Target_Square_150"]      = "Container Red 2",
    ["476_Target_Hard_1"]          = "Bunker",
    ["476_Conex_Box_White"]        = "Container Red 3",
    ["476_Target_Truck"]           = "Container Red 1",
    ["476_Target_APC"]             = "Container Red 1",
    ["476_Target_Tank"]            = "Container Red 1",
    ["476_Target_Strafe_Pit_West"] = "Container Red 1",
    ["476_Target_Strafe_Pit_East"] = "Container Red 1",
    ["476_Target_Panel_Vertical"]  = "Container Red 1",
}
env.info("TCS(RANGE.LAYOUTS): ready")