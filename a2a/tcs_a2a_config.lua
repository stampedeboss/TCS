-- TCS_config.lua (A2A)
-- Reworked:
--   * ACM = close-in only (no controller).
--   * Intercept = farther + random bandit count (controller enabled).
--   * Added CAP (relative to player) and ESCORT (template-based packages).

CFG = {
  Coalition = coalition.side.BLUE,

  -- Close-in ACM setups (meters)
  ACM = {
    ABEAM_M        = 1600,   -- ~0.9 NM
    DEFENSIVE_M    = 1600,
    H2H_M          = 4000,   -- ~2.2 NM
  },

  -- Intercept spawns (nautical miles)
  INTERCEPT = {
    MIN_NM         = 12,
    MAX_NM         = 25,
    JITTER_DEG     = 35,
    MIN_BANDITS    = 1,
    MAX_BANDITS    = 4,
    SPREAD_NM      = 4,
  },

  -- CAP (relative to player)
  CAP = {
    -- CAP center point relative to player's nose at start
    CENTER_MIN_NM      = 20,
    CENTER_MAX_NM      = 35,
    CENTER_JITTER_DEG  = 50,

    -- Where bandits spawn relative to CAP center
    RADIUS_MIN_NM      = 10,
    RADIUS_MAX_NM      = 25,

    -- Wave generation
    DURATION_SEC       = 15 * 60,
    WAVE_MIN_SEC       = 120,
    WAVE_MAX_SEC       = 240,
    WAVE_MIN_BANDITS   = 1,
    WAVE_MAX_BANDITS   = 4,
    MAX_ALIVE_BANDITS  = 8,

    -- Optional controller
    CONTROLLER_ENABLED = true,
  },


  -- SWEEP (relative to player): clear a corridor ahead. One-time or paced waves.
  SWEEP = {
    -- Corridor anchor (ahead of player at start)
    CENTER_MIN_NM      = 25,
    CENTER_MAX_NM      = 45,
    CENTER_JITTER_DEG  = 35,

    -- Corridor geometry
    LENGTH_NM          = 60,
    WIDTH_NM           = 20,

    -- Two-phase push
    PUSH_LINE_TOL_NM    = 5,      -- consider "at push line" when within this distance
    PUSH_TIMEOUT_SEC    = 6 * 60,  -- auto-start sanitize if players don't reach push line
    EGRESS_CALL_ENABLED = true,

    -- Population
    INITIAL_MIN_BANDITS = 2,
    INITIAL_MAX_BANDITS = 6,

    -- Optional follow-on trickle waves while sweep is active
    TRICKLE_ENABLED    = false,
    WAVE_MIN_SEC       = 240,
    WAVE_MAX_SEC       = 420,
    WAVE_MIN_BANDITS   = 1,
    WAVE_MAX_BANDITS   = 3,
    MAX_ALIVE_BANDITS  = 8,

    DURATION_SEC       = 20 * 60,

    CONTROLLER_ENABLED = true,
  },

  -- ESCORT (template packages)
  ESCORT = {
    -- Templates (group names in mission to clone via SPAWN)
    PACKAGE_TANKER     = "PACKAGE_TANKER",
    PACKAGE_TRANSPORT  = "PACKAGE_TRANSPORT",
    PACKAGE_STRIKE     = "PACKAGE_STRIKE",

    -- Route: move package straight ahead from spawn (relative)
    PACKAGE_SPAWN_AHEAD_NM = 10,
    PACKAGE_ROUTE_NM       = 80,
    PACKAGE_SPEED_KTS      = 350,

    -- Threat spawns (relative to package)
    THREAT_MIN_NM      = 25,
    THREAT_MAX_NM      = 45,
    THREAT_JITTER_DEG  = 60,
    THREAT_MIN_BANDITS = 2,
    THREAT_MAX_BANDITS = 4,
    THREAT_SPREAD_NM   = 6,

    -- Waves during escort
    DURATION_SEC       = 20 * 60,
    WAVE_MIN_SEC       = 180,
    WAVE_MAX_SEC       = 300,
    MAX_ALIVE_BANDITS  = 10,

    CONTROLLER_ENABLED = true,
  },

  -- BVR
  BVR = {
    RANGE_M        = 150000, -- ~81 NM
    JITTER_DEG     = 35,
  },


  -- SESSIONS (Human flight sessions across separate client groups)
  -- Airboss-friendly: separate client groups can join the same session so threats/calls are shared.
  SESSION = {
    -- Predefined session names (no text entry needed in F10)
    NAMES = { "ALPHA", "BRAVO", "CHARLIE" },

    -- Behavior
    LEAD_ONLY_STARTS = true,      -- only the session lead can start scenarios
    AUTO_JOIN_IF_ONE_ACTIVE = true, -- if only one session exists, "Join Active" will join it

    -- Controller updates are broadcast to all member groups
    BROADCAST_BRAA_TO_ALL = true,  -- keep comms cleaner; use bullseye/common calls by default
  },

  Cooldowns = {
    ABEAM       = 60,
    DEFENSIVE   = 60,
    H2H         = 60,
    INTERCEPT   = 90,
    CAP         = 120,
    ESCORT      = 180,
    SWEEP       = 150,
    BVR         = 90,
    BVR_BRACKET = 120,
  },

  -- DARKSTAR (SRS / MSRS)
  AWACS = {
    Label   = "DARKSTAR",
    Freq    = 251.000,
    Mod     = radio.modulation.AM,
    SRSPath = "C:\\Program Files\\DCS-SimpleRadio-Standalone",
    UpdateTotal = 180,
    UpdateEvery = 30,
  },

  Templates = {
    BanditPrefix = "BANDIT",
  },

  -- Controller-like management (used for Intercept/CAP/Escort/BVR)
  A2A_CTRL = {
    COMMIT_GATE_NM     = 60,
    HOSTILE_GATE_NM    = 45,
    PUSH_GATE_NM       = 40,
    PRESS_GATE_NM      = 25,
    MERGE_GATE_NM      = 15,
    KIO_GATE_NM        = 10,
    TERMINATE_GATE_NM  = 120,

    MIN_CTRL_SPACING_SEC = 10,
    DECLARE_DELAY_SEC    = 6,

    MAX_ENGAGE_SEC     = 900,
    RTB_GRACE_SEC      = 180,
    USE_RTB_ROUTE      = true,
  },
}
