env.info("TCS(CONFIG.A2A): loading")

TCS = TCS or {}
TCS.Config = TCS.Config or {}

-- 2. A2A Tuning
TCS.Config.A2A = {
  Coalition = coalition.side.BLUE,
  
  -- Reference to Session config for A2A modules expecting it here
  SESSION = TCS.Config.Session,
  
  -- Cooldowns (seconds)
  Cooldowns = {
    ABEAM = 60, DEFENSIVE = 60, H2H = 60,
    INTERCEPT = 90, CAP = 120, ESCORT = 180,
    SWEEP = 150, BVR = 90, BVR_BRACKET = 120,
  },

  -- Controller Logic
  A2A_CTRL = {
    COMMIT_GATE_NM = 60, HOSTILE_GATE_NM = 45,
    PUSH_GATE_NM = 40, PRESS_GATE_NM = 25,
    MERGE_GATE_NM = 15, KIO_GATE_NM = 10,
    TERMINATE_GATE_NM = 120,
    MIN_CTRL_SPACING_SEC = 10,
    DECLARE_DELAY_SEC = 6,
    MAX_ENGAGE_SEC = 900,
    RTB_GRACE_SEC = 180,
    USE_RTB_ROUTE = true,
  },

  -- Modes
  ACM = { ABEAM_M = 1600, DEFENSIVE_M = 1600, H2H_M = 8000 },
  
  INTERCEPT = {
    MIN_NM = 40, MAX_NM = 80, JITTER_DEG = 110,
    ASPECT_MIN = 0, ASPECT_MAX = 120,
    ALT_MIN = 18000, ALT_MAX = 32000,
    MIN_BANDITS = 1, MAX_BANDITS = 4, SPREAD_NM = 4,
    DIFFICULTY = {
      A = { tier="A", interval_min=60, interval_max=120 },
      G = { tier="G", interval_min=45, interval_max=90 },
      H = { tier="H", interval_min=30, interval_max=60 },
      X = { tier="X", interval_min=15, interval_max=30 },
      ["RANDOM"] = {
        weights = { {tier="A", w=10}, {tier="G", w=40}, {tier="H", w=40}, {tier="X", w=10} },
        resolve = function(self)
          return TCS.A2A.ResolveDifficulty(self.weights)
        end
      },
    }
  },

  CAP = {
    CENTER_MIN_NM = 30, CENTER_MAX_NM = 50, CENTER_JITTER_DEG = 90,
    RADIUS_MIN_NM = 10, RADIUS_MAX_NM = 25,
    ALT_MIN = 18000, ALT_MAX = 32000,
    DURATION_SEC = 900, WAVE_MIN_SEC = 120, WAVE_MAX_SEC = 240,
    WAVE_MIN_BANDITS = 1, WAVE_MAX_BANDITS = 4, MAX_ALIVE_BANDITS = 8,
    CONTROLLER_ENABLED = true,
    DIFFICULTY = {
      ["A"] = { tier="A", min=1, max=2 },
      ["G"] = { tier="G", min=2, max=2 },
      ["H"] = { tier="H", min=2, max=4 },
      ["X"] = { tier="X", min=4, max=4 },
      ["RANDOM"] = {
        weights = { {tier="A", w=10}, {tier="G", w=40}, {tier="H", w=40}, {tier="X", w=10} },
        resolve = function(self)
          return TCS.A2A.ResolveDifficulty(self.weights)
        end
      },
    },
  },

  SWEEP = {
    CENTER_MIN_NM = 60, CENTER_MAX_NM = 100, CENTER_JITTER_DEG = 135,
    LENGTH_NM = 60, WIDTH_NM = 20,
    ALT_MIN = 18000, ALT_MAX = 32000,
    PUSH_LINE_TOL_NM = 5, PUSH_TIMEOUT_SEC = 360, EGRESS_CALL_ENABLED = true,
    INITIAL_MIN_BANDITS = 2, INITIAL_MAX_BANDITS = 6,
    TRICKLE_ENABLED = false, WAVE_MIN_SEC = 240, WAVE_MAX_SEC = 420,
    WAVE_MIN_BANDITS = 1, WAVE_MAX_BANDITS = 3, MAX_ALIVE_BANDITS = 8,
    DURATION_SEC = 1200, CONTROLLER_ENABLED = true,
    DIFFICULTY = {
      ["A"] = { tier="A", min=2, max=2 },
      ["G"] = { tier="G", min=2, max=4 },
      ["H"] = { tier="H", min=4, max=6 },
      ["X"] = { tier="X", min=4, max=8 },
      ["RANDOM"] = {
        weights = { {tier="A", w=10}, {tier="G", w=40}, {tier="H", w=40}, {tier="X", w=10} },
        resolve = function(self)
          return TCS.A2A.ResolveDifficulty(self.weights)
        end
      },
    },
  },

  ESCORT = {
    PACKAGE_SPAWN_AHEAD_NM = 10,
    PACKAGE_ROUTE_NM = { MIN = 60, MAX = 100 },
    PACKAGE_SPEED_KTS = { MIN = 300, MAX = 380 },
    THREAT_MIN_NM = 30, THREAT_MAX_NM = 60, THREAT_JITTER_DEG = 60,
    THREAT_MIN_BANDITS = 2, THREAT_MAX_BANDITS = 4, THREAT_SPREAD_NM = 6,
    ALT_MIN = 18000, ALT_MAX = 32000,
    DURATION_SEC = 1200, WAVE_MIN_SEC = 180, WAVE_MAX_SEC = 300,
    MAX_ALIVE_BANDITS = 10, CONTROLLER_ENABLED = true,
    DIFFICULTY = {
      ["A"] = { tier="A", min=1, max=2 },
      ["G"] = { tier="G", min=2, max=2 },
      ["H"] = { tier="H", min=2, max=4 },
      ["X"] = { tier="X", min=4, max=4 },
      ["RANDOM"] = {
        weights = { {tier="A", w=10}, {tier="G", w=40}, {tier="H", w=40}, {tier="X", w=10} },
        resolve = function(self)
          return TCS.A2A.ResolveDifficulty(self.weights)
        end
      },
    },
  },

  BVR = { RANGE_M = 150000, JITTER_DEG = 35 },
}

-- Backwards Compatibility Aliases
TCS.A2A = TCS.A2A or {}
TCS.A2A.Config = TCS.Config.A2A

env.info("TCS(CONFIG.A2A): ready")