-- =========================================================
-- TCS Dynamic Range Configuration
-- =========================================================

TCS = TCS or {}
TCS.RANGE_CONFIG = {

  bomb_star = {
    purpose = "BOMB",
    pattern = "STAR",
    count = 5,
    spacing_m = 25,
    target_pool = {
      "Container red 1",
      "Container red 2",
      "Cargo1",
      "Cargo2"
    }
  },

  strafe_row = {
    purpose = "STRAFE",
    pattern = "ROW",
    count = 10,
    spacing_m = 30,
    strafe_length = 300,
    target_pool = {
      "Ural-375",
      "ZIL-131",
      "HESCO"
    }
  },

  mixed_grid = {
    purpose = "MIXED",
    pattern = "GRID",
    rows = 3,
    columns = 4,
    spacing_m = 40,
    target_pool = {
      "Container red 1",
      "Ural-375",
      "ZIL-131"
    }
  }
}
