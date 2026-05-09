env.info("TCS(CONFIG.A2G): loading")

TCS = TCS or {}
TCS.Config = TCS.Config or {}

-- 3. A2G Tuning
TCS.Config.A2G = {
  LEAD_ONLY_STARTS = true,
  DEFAULT_SPAWN_MIN_NM = 25,
  DEFAULT_SPAWN_MAX_NM = 45,

  -- Skill range behavior
  SKILL_RANGE_DISTANCE_NM = 15,
  SKILL_RANGE_WARNINGS_ONLY = true,
  
  -- Cooldowns (seconds)
  Cooldowns = {
    RANGE     = 10,
    CAS       = 60,
    BAI       = 60,
    SEAD      = 60,
    DEAD      = 60,
    STRIKE    = 60,
    MAR       = 60,
    SUW       = 60,
    LOGISTICS = 60,
  },

  -- Force Composition (References Catalog Categories)
  Forces = {
    MECH_INF       = { MIXED=3.0, AIRDEF=0.5, ARMOR=0.3, TRANSPORT=0.5, JTAC=0.5 },
    MECH_INF_NJTAC = { MIXED=3.0, AIRDEF=0.5, ARMOR=0.3, TRANSPORT=1.0 },
    SEAD           = { AIRDEF=2.0, MIXED=1.0 },
    DEAD           = { AIRDEF=1.0, ARMOR=1.0, MIXED=1.0 },
    STRIKE         = { ARMOR=2.0, TRANSPORT=1.0, AIRDEF=0.5, STRUCTURE=1.0 },
    MAR_CONVOY     = { SHIP_CARGO=4, SHIP_CORVETTE=1, SHIP_FRIGATE=1, SHIP_DESTROYER=0.5, SHIP_CRUISER=0.2 },
    MAR_HARBOR     = { SHIP_DOCKED=2, AIRDEF=0.2, STRUCTURE=1.0 },
    SUW_SAG        = { SHIP_CORVETTE=0.7, SHIP_FRIGATE=0.5, SHIP_DESTROYER=0.4, SHIP_CRUISER=0.3, SHIP_CARRIER=0.3 },
    LOGISTICS      = { TRANSPORT=3, AIRDEF=0.5 }
  },

  -- Module Settings
  JTAC = {
    DEFAULT_MARK = "SMOKE",
    DEFAULT_LASER_CODE = 1688,
    LASER_DURATION = 300,
  },

  RangeCommon = {
    FREQUENCY = 252.000,
    SMOKE_ON_OFF = true,
  },

  -- Settings for dynamically spawned training ranges
  TrainingRange = {
    SPAWN_DISTANCE_NM = 15, -- Default spawn distance in Nautical Miles
    SPAWN_BUFFER_NM = 50, -- Safety buffer outside of SAM max range
    SAM_SPAWN_ZONE_NAME = "Dynamic SAM Sites", -- If this zone exists, SAMs will spawn inside it instead of relative to the player.
    GENERIC_SPAWN_ZONE_NAME = "Dynamic Training Ranges", -- If this zone exists, generic ranges will spawn inside it.
  },

  SUW = { 
    FAST_ATTACK_TYPES = { "Molniya", "Albatros", "Speedboat" }, 
    TRAFFIC_HOSTILE_CHANCE = 0.15,
    TRAFFIC_RADIUS_NM = 40,
    TRAFFIC_COUNT = 12,
    TRAFFIC_MIN_SPACING_NM = 5,
    TRAFFIC_CLEANUP_DIST_NM = 2,
    FAC_OFFSET_M = 500,
    TRAFFIC_TYPES = { "Bulk Cargo Ship", "Dry-cargo ship-1", "Tanker" }
  },
  
  MAR = { MOVE_DIST_NM = { MIN = 15, MAX = 30 }, SPEED_KTS = { MIN = 10, MAX = 25 } },
  CAS = { SEPARATION_NM = { MIN = 2, MAX = 4 }, SPEED_KPH = { MIN = 20, MAX = 35 } },

  -- Dynamic Range Configurations
  Range = {
    -- BOMBS
    bomb_row_containers = {
      purpose = "BOMB",
      pattern = "ROW",
      count = 6,
      spacing_m = 40,
      target_pool = { "container_red1", "container_red2", "container_red3" }
    },
    bomb_grid_random = {
      purpose = "BOMB",
      pattern = "GRID",
      rows = 4,
      columns = 4,
      spacing_m = 50,
      target_pool = { "ural375", "kamaz", "container_red1" }
    },
    bomb_row_476_circles = {
      purpose = "BOMB",
      pattern = "ROW",
      count = 5,
      spacing_m = 100,
      target_pool = { "476_circ_75", "476_circ_150" } -- Uses ID for fallback support
    },
    bomb_star_containers = {
      purpose = "BOMB",
      pattern = "STAR",
      count = 5,
      spacing_m = 50,
      target_pool = { "container_red1" }
    },
    precision_strike_factory = {
      purpose = "BOMB",
      pattern = "GRID",
      rows = 2,
      columns = 2,
      spacing_m = 120,
      target_pool = { "factory", "warehouse", "workshop" }
    },
    
    -- STRAFE
    strafe_row_generic = {
      purpose = "STRAFE",
      pattern = "ROW",
      count = 10,
      spacing_m = 15,
      target_pool = { "ural375", "kamaz" }
    },
    strafe_row_armor = {
      purpose = "STRAFE",
      pattern = "ROW",
      count = 6,
      spacing_m = 30,
      target_pool = { "btr80", "bmp2" }
    },
    range_476_strafe = {
      purpose = "STRAFE",
      pattern = "ROW",
      count = 15,
      spacing_m = 10,
      target_pool = { "476_pit_w" }
    },

    -- ROCKETS
    rocket_grid_soft = {
      purpose = "BOMB", -- Rockets treated as area
      pattern = "GRID",
      rows = 5,
      columns = 5,
      spacing_m = 30,
      target_pool = { "ural375", "uaz" }
    },
    mixed_grid = {
      purpose = "MIXED",
      pattern = "GRID",
      rows = 3,
      columns = 3,
      spacing_m = 40,
      target_pool = { "btr80", "ural375", "container_red1" }
    },

    -- MOBILE
    convoy_hunt = {
      purpose = "STRAFE",
      activity = "CONVOY",
      pattern = "ROW",
      count = 6,
      spacing_m = 50,
      target_pool = { "ural375", "btr80" }
    },
    MOVING_HOSTILE = {
      purpose = "STRAFE",
      activity = "CONVOY",
      pattern = "ROW",
      count = 4,
      spacing_m = 50,
      target_pool = { "t72b", "bmp2" }
    },

    -- SAM / THREATS
    POPUP = {
      purpose = "SEAD",
      activity = "POPUP",
      pattern = "RANDOM",
      count = 2,
      radius = 2000,
      target_pool = { "osa", "strela10" }
    },
    SAM_CIRCLE = {
      purpose = "SEAD",
      pattern = "STAR",
      count = 3,
      spacing_m = 500,
      target_pool = { "shilka" }
    },

    -- WATER
    bomb_row_shipping = { purpose = "BOMB", pattern = "ROW", count = 3, spacing_m = 200, target_pool = { "drycargo1" } },
    strafe_row_shipping = { purpose = "STRAFE", pattern = "ROW", count = 4, spacing_m = 100, target_pool = { "speedboat" } },
    SAM_SHIP = { purpose = "SEAD", activity = "POPUP", pattern = "RANDOM", count = 1, radius = 1000, target_pool = { "albatros" } },

    -- MIXED
    range_476_tactical = { purpose = "MIXED", pattern = "RANDOM", count = 8, radius = 800, target_pool = { "476_circ_75", "476_sq_75", "476_hard_1", "476_conex", "476_truck", "476_apc", "476_tank" } },
    random_scatter = { purpose = "MIXED", pattern = "RANDOM", count = 12, radius = 1500, target_pool = { "t72b", "btr80", "ural375" } }
  },

  -- Template naming conventions (Mission Editor groups, Late Activation)
  TEMPLATES = {
    -- JTAC / FAC
    JTAC = "JTAC",

    -- Skill Range templates (Late Activated ground groups)
    RANGE_CIRCLE = "A2G_RANGE_CIRCLE",
    RANGE_ROW    = "A2G_RANGE_ROW",
    RANGE_STRAFE = "A2G_RANGE_STRAFE",
    RANGE_MISC   = "A2G_RANGE_MISC",

    -- CAS templates (Late Activated ground groups)
    -- Enemy (RED):  "CAS RED-1", "CAS RED-2", ...
    -- Friendlies (BLUE): "CAS BLUE-1", "CAS BLUE-2", ...
    CAS_RED_PREFIX   = "CAS RED-",
    CAS_BLUE_PREFIX  = "CAS BLUE-",

    -- Other categories (placeholders; name similarly later if desired)
    BAI_TARGET_PREFIX    = "BAI TARGET-",
    SAM_SITE_PREFIX      = "SAM SITE-",
    STRIKE_TARGET_PREFIX = "STRIKE TARGET-",
    MAR_SHIP_PREFIX      = "MAR-",
    SUW_GROUP_PREFIX     = "SUW-",
  },
}

-- Dynamic SAM Site Compositions (No ME Templates required)
-- Defines relative positions (x, y in meters) and headings for components.
TCS.Config.A2G.SAMS = {
  ["SA-2"] = {
    label = "SA-2 (Fan Song)",
    max_range_nm = 24,
    compositions = {
      A = { { id="sa2_tr", x=0, y=0, hdg=0 }, { id="p19_sr", x=-80, y=20, hdg=0 }, { id="sa2_ln", x=60, y=0, hdg=180 }, { id="sa2_ln", x=-60, y=0, hdg=0 } },
      G = { { id="sa2_tr", x=0, y=0, hdg=0 }, { id="p19_sr", x=-80, y=20, hdg=0 }, { id="sa2_ln", x=60, y=0, hdg=180 }, { id="sa2_ln", x=30, y=52, hdg=240 }, { id="sa2_ln", x=-30, y=52, hdg=300 }, { id="sa2_ln", x=-60, y=0, hdg=0 }, { id="sa2_ln", x=-30, y=-52, hdg=60 }, { id="sa2_ln", x=30, y=-52, hdg=120 } },
      H = { { id="sa2_tr", x=0, y=0, hdg=0 }, { id="p19_sr", x=-80, y=20, hdg=0 }, { id="sa2_ln", x=60, y=0, hdg=180 }, { id="sa2_ln", x=30, y=52, hdg=240 }, { id="sa2_ln", x=-30, y=52, hdg=300 }, { id="sa2_ln", x=-60, y=0, hdg=0 }, { id="sa2_ln", x=-30, y=-52, hdg=60 }, { id="sa2_ln", x=30, y=-52, hdg=120 }, { id="ural375", x=-100, y=20, hdg=90 }, { id="zu23_static", x=100, y=100, hdg=225 }, { id="zu23_static", x=-100, y=-100, hdg=45 } },
    }
  },
  ["SA-3"] = {
    label = "SA-3 (Low Blow)",
    max_range_nm = 13,
    compositions = {
      A = { { id="sa3_tr", x=0, y=0, hdg=0 }, { id="p19_sr", x=-50, y=10, hdg=45 }, { id="sa3_ln", x=50, y=50, hdg=225 }, { id="sa3_ln", x=-50, y=-50, hdg=45 } },
      G = { { id="sa3_tr", x=0, y=0, hdg=0 }, { id="p19_sr", x=-50, y=10, hdg=45 }, { id="sa3_ln", x=60, y=60, hdg=225 }, { id="sa3_ln", x=60, y=-60, hdg=315 }, { id="sa3_ln", x=-60, y=-60, hdg=45 }, { id="sa3_ln", x=-60, y=60, hdg=135 } },
      H = { { id="sa3_tr", x=0, y=0, hdg=0 }, { id="p19_sr", x=-50, y=10, hdg=45 }, { id="sa3_ln", x=60, y=60, hdg=225 }, { id="sa3_ln", x=60, y=-60, hdg=315 }, { id="sa3_ln", x=-60, y=-60, hdg=45 }, { id="sa3_ln", x=-60, y=60, hdg=135 }, { id="ural_zu23", x=100, y=0, hdg=90 } },
    }
  },
  ["SA-6"] = {
    label = "SA-6 (Kub)",
    max_range_nm = 13,
    compositions = {
      A = { { id="sa6_tr", x=0, y=0, hdg=0 }, { id="sa6_ln", x=50, y=50, hdg=225 }, { id="sa6_ln", x=-50, y=-50, hdg=45 } },
      G = { { id="sa6_tr", x=0, y=0, hdg=0 }, { id="sa6_ln", x=50, y=50, hdg=225 }, { id="sa6_ln", x=50, y=-50, hdg=315 }, { id="sa6_ln", x=-50, y=-50, hdg=45 }, { id="sa6_ln", x=-50, y=50, hdg=135 } },
      H = { { id="sa6_tr", x=0, y=0, hdg=0 }, { id="sa6_ln", x=50, y=50, hdg=225 }, { id="sa6_ln", x=50, y=-50, hdg=315 }, { id="sa6_ln", x=-50, y=-50, hdg=45 }, { id="sa6_ln", x=-50, y=50, hdg=135 }, { id="shilka", x=100, y=0, hdg=0 } },
    }
  },
  ["SA-8"] = {
    label = "SA-8 (Osa)",
    max_range_nm = 8,
    compositions = {
      A = { { id="sa8_sys", x=0, y=0, hdg=0 } },
      G = { { id="sa8_sys", x=0, y=0, hdg=0 }, { id="sa8_sys", x=100, y=50, hdg=45 } },
      H = { { id="sa8_sys", x=0, y=0, hdg=0 }, { id="sa8_sys", x=100, y=50, hdg=45 }, { id="sa8_sys", x=-100, y=50, hdg=315 } },
    }
  },
  ["SA-10"] = {
    label = "SA-10 (S-300)",
    max_range_nm = 81,
    compositions = {
      G = { { id="sa10_tr", x=0, y=0, hdg=0 }, { id="sa10_sr", x=-100, y=0, hdg=0 }, { id="sa10_ln", x=200, y=200, hdg=225 }, { id="sa10_ln", x=-200, y=-200, hdg=45 } },
      H = { { id="sa10_tr", x=0, y=0, hdg=0 }, { id="sa10_sr", x=-100, y=0, hdg=0 }, { id="sa10_low_tr", x=0, y=-100, hdg=0 }, { id="sa10_ln", x=250, y=250, hdg=225 }, { id="sa10_ln", x=250, y=-250, hdg=315 }, { id="sa10_ln", x=-250, y=-250, hdg=45 }, { id="sa10_ln", x=-250, y=250, hdg=135 }, { id="sa10_ln", x=0, y=350, hdg=270 }, { id="sa10_ln", x=0, y=-350, hdg=90 } },
      X = { { id="sa10_tr", x=0, y=0, hdg=0 }, { id="sa10_sr", x=-150, y=0, hdg=0 }, { id="sa10_low_tr", x=0, y=-150, hdg=0 }, { id="sa10_ln", x=300, y=300, hdg=225 }, { id="sa10_ln", x=300, y=-300, hdg=315 }, { id="sa10_ln", x=-300, y=-300, hdg=45 }, { id="sa10_ln", x=-300, y=300, hdg=135 }, { id="sa10_ln", x=425, y=0, hdg=270 }, { id="sa10_ln", x=-425, y=0, hdg=90 }, { id="sa10_ln", x=0, y=425, hdg=180 }, { id="sa10_ln", x=0, y=-425, hdg=0 }, { id="sa15_sys", x=800, y=0, hdg=0 }, { id="sa19_sys", x=-800, y=0, hdg=0 } },
    }
  },
  ["SA-11"] = {
    label = "SA-11 (Buk)",
    max_range_nm = 17,
    compositions = {
      G = { { id="sa11_sr", x=0, y=0, hdg=0 }, { id="sa11_cp", x=20, y=-20, hdg=0 }, { id="sa11_ln", x=100, y=100, hdg=225 }, { id="sa11_ln", x=-100, y=-100, hdg=45 } },
      H = { { id="sa11_sr", x=0, y=0, hdg=0 }, { id="sa11_cp", x=20, y=-20, hdg=0 }, { id="sa11_ln", x=150, y=150, hdg=225 }, { id="sa11_ln", x=150, y=-150, hdg=315 }, { id="sa11_ln", x=-150, y=-150, hdg=45 }, { id="sa11_ln", x=-150, y=150, hdg=135 } },
      X = { { id="sa11_sr", x=0, y=0, hdg=0 }, { id="sa11_cp", x=20, y=-20, hdg=0 }, { id="sa11_ln", x=200, y=200, hdg=225 }, { id="sa11_ln", x=200, y=-200, hdg=315 }, { id="sa11_ln", x=-200, y=-200, hdg=45 }, { id="sa11_ln", x=-200, y=200, hdg=135 }, { id="sa19_sys", x=400, y=0, hdg=0 } },
    }
  },
  ["SA-15"] = {
    label = "SA-15 (Tor)",
    max_range_nm = 7,
    compositions = {
      A = { { id="sa15_sys", x=0, y=0, hdg=0 } },
      G = { { id="sa15_sys", x=0, y=0, hdg=0 }, { id="sa15_sys", x=50, y=50, hdg=180 } },
      H = { { id="sa15_sys", x=0, y=0, hdg=0 }, { id="sa15_sys", x=50, y=50, hdg=180 }, { id="sa15_sys", x=-50, y=50, hdg=270 } },
    }
  },
  ["SA-19"] = {
    label = "SA-19 (Tunguska)",
    max_range_nm = 5,
    compositions = {
      A = { { id="sa19_sys", x=0, y=0, hdg=0 } },
      G = { { id="sa19_sys", x=0, y=0, hdg=0 }, { id="sa19_sys", x=50, y=-50, hdg=270 } },
      H = { { id="sa19_sys", x=0, y=0, hdg=0 }, { id="sa19_sys", x=50, y=-50, hdg=270 }, { id="sa19_sys", x=-50, y=-50, hdg=90 } },
    }
  },
  ["SA-5"] = {
    label = "SA-5 (Gammon)",
    max_range_nm = 130,
    compositions = {
      -- G is a simplified site with only 2 launchers
      G = { { id="sa5_tr", x=0, y=0, hdg=0 }, { id="sa5_sr", x=-200, y=50, hdg=0 }, { id="sa5_ln", x=500, y=0, hdg=0 }, { id="sa5_ln", x=-500, y=0, hdg=60 } },
      -- H is a full doctrinal site with 6 launchers and point defense
      H = { { id="sa5_tr", x=0, y=0, hdg=0 }, { id="sa5_sr", x=-200, y=50, hdg=0 }, { id="sa5_ln", x=500, y=0, hdg=0 }, { id="sa5_ln", x=250, y=433, hdg=300 }, { id="sa5_ln", x=-250, y=433, hdg=240 }, { id="sa5_ln", x=-500, y=0, hdg=180 }, { id="sa5_ln", x=-250, y=-433, hdg=120 }, { id="sa5_ln", x=250, y=-433, hdg=60 }, { id="zu23_static", x=600, y=600, hdg=225 }, { id="zu23_static", x=-600, y=-600, hdg=45 } },
      -- X is the full site plus a layered screen of shorter-range SAMs
      X = { { id="sa5_tr", x=0, y=0, hdg=0 }, { id="sa5_sr", x=-200, y=50, hdg=0 }, { id="sa5_ln", x=500, y=0, hdg=0 }, { id="sa5_ln", x=250, y=433, hdg=300 }, { id="sa5_ln", x=-250, y=433, hdg=240 }, { id="sa5_ln", x=-500, y=0, hdg=180 }, { id="sa5_ln", x=-250, y=-433, hdg=120 }, { id="sa5_ln", x=250, y=-433, hdg=60 }, { id="zu23_static", x=600, y=600, hdg=225 }, { id="zu23_static", x=-600, y=-600, hdg=45 }, { id="sa15_sys", x=1000, y=200, hdg=225 }, { id="sa19_sys", x=-1000, y=-200, hdg=45 } },
    }
  },
  ["SA-22"] = {
    label = "SA-22 (Pantsir)",
    max_range_nm = 11,
    compositions = {
      H = { { id="sa22_sys", x=0, y=0, hdg=0 } },
      X = { { id="sa22_sys", x=0, y=0, hdg=0 }, { id="sa22_sys", x=100, y=0, hdg=180 } },
    }
  },
}

-- Backwards Compatibility Aliases
TCS.A2G = TCS.A2G or {}
TCS.A2G.Config = TCS.Config.A2G
TCS.A2G.Forces = TCS.Config.A2G.Forces
TCS.A2G.Echelons = TCS.Config.Echelons
TCS.RANGE_CONFIG = TCS.Config.A2G.Range

env.info("TCS(CONFIG.A2G): ready")