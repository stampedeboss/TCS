-- =========================================================
-- TCS A2A Dynamic Spawn Configuration
-- =========================================================

TCS = TCS or {}
TCS.A2A_CONFIG = {

  tiers = {
    A = { skill = "Average", fox3 = false },
    G = { skill = "Good",    fox3 = false },
    H = { skill = "High",    fox3 = true  },
    X = { skill = "Excellent", fox3 = true }
  },

  roles = {
    WVR = {
      aircraft = { "MIG21", "F5", "M2000" },
      distance_nm = { min = 10, max = 20 },
      offset_deg = 30,
      alt_m = 6000
    },

    BVR = {
      aircraft = { "MIG29", "SU27", "J11" },
      distance_nm = { min = 30, max = 50 },
      offset_deg = 60,
      alt_m = 9000
    },

    MIX = {
      aircraft = { "MIG29", "SU27", "M2000" },
      distance_nm = { min = 25, max = 40 },
      offset_deg = 90,
      alt_m = 8000
    }
  },

  aircraft = {
    MIG21 = { type = "MiG-21Bis", fuel = 0.7 },
    MIG29 = { type = "MiG-29",    fuel = 0.8 },
    SU27  = { type = "Su-27",     fuel = 0.85 },
    J11   = { type = "J-11A",     fuel = 0.85 },
    F5    = { type = "F-5E-3",    fuel = 0.7 },
    M2000 = { type = "Mirage 2000C", fuel = 0.8 }
  }
}
