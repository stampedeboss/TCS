---------------------------------------------------------------------
-- TCS CONFIG: NAVAL OPS
-- Legacy configurations extracted for Maritime (MAR) and Surface Warfare (SUW).
---------------------------------------------------------------------
env.info("TCS(CONFIG.SEA.NAVAL_OPS): loading")

TCS = TCS or {}
TCS.Sea = TCS.Sea or {}
TCS.Sea.Config = TCS.Sea.Config or {}

TCS.Sea.Config.NavalOps = {
  -- Cooldowns (seconds)
  Cooldowns = {
    MAR = 60,
    SUW = 60,
  },
  -- Force Composition Ratios
  Forces = {
    MAR_CONVOY = { SHIP_CARGO=4, SHIP_CORVETTE=1, SHIP_FRIGATE=1, SHIP_DESTROYER=0.5, SHIP_CRUISER=0.2 },
    MAR_HARBOR = { SHIP_DOCKED=2, AIRDEF=0.2, STRUCTURE=1.0 },
    SUW_SAG    = { SHIP_CORVETTE=0.7, SHIP_FRIGATE=0.5, SHIP_DESTROYER=0.4, SHIP_CRUISER=0.3, SHIP_CARRIER=0.3 },
  },
  -- Specific SUW / Traffic configurations
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
  -- Specific MAR settings
  MAR = { MOVE_DIST_NM = { MIN = 15, MAX = 30 }, SPEED_KTS = { MIN = 10, MAX = 25 } },
}

env.info("TCS(CONFIG.SEA.NAVAL_OPS): ready")