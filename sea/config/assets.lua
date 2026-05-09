---------------------------------------------------------------------
-- TCS SEA CONFIGURATION
-- Centralized data and definitions for the Sea domain.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Sea = TCS.Sea or {}
TCS.Sea.Config = {
    Pools = {
        NAVY     = { "ALBATROS", "MOLNIYA", "REZKY", "MOSCOVA" },
        CIVILIAN = { "Dry-cargo ship-1", "Dry-cargo ship-2", "ZWEZDNY" },
        CONVOY   = { "MOLNIYA", "Dry-cargo ship-1", "Dry-cargo ship-2", "ZWEZDNY" },
        TRAFFIC  = { "Dry-cargo ship-1", "Dry-cargo ship-2", "ALBATROS", "ZWEZDNY", "Dry-cargo ship-1", "MOLNIYA" }
    },
    Spawns = {
        Spacing_m = 2500,
        TrafficRadius_m = 30000
    }
}