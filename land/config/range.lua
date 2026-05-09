---------------------------------------------------------------------
-- TCS CONFIG: TRAINING RANGES
-- Definitions for dynamic target ranges (Bombing, Strafing, etc.)
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Land = TCS.Land or {}
TCS.Land.Config = TCS.Land.Config or {}

-- General Training Range Settings
TCS.Land.Config.RangeSettings = {
    SPAWN_DISTANCE_NM = 15, -- Default spawn distance in Nautical Miles
    SPAWN_BUFFER_NM = 50, -- Safety buffer outside of SAM max range
    SAM_SPAWN_ZONE_NAME = "Dynamic SAM Sites", -- If this zone exists, SAMs will spawn inside it instead of relative to the player.
    GENERIC_SPAWN_ZONE_NAME = "Dynamic Training Ranges", -- If this zone exists, generic ranges will spawn inside it.
    FREQUENCY = 252.000,
    SMOKE_ON_OFF = true,
}

-- Dynamic Range Layout Blueprints
TCS.Land.Config.Range = {
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
}

env.info("TCS(CONFIG.LAND.RANGE): ready")