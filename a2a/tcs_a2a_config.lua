-- TCS_config.lua (A2A)
-- Reworked:
--   * ACM = close-in only (no controller).
--   * Intercept = farther + random bandit count (controller enabled).
--   * Added CAP (relative to player) and ESCORT (template-based packages).

TCS = TCS or {}
TCS.A2A = TCS.A2A or {}

TCS.A2A.Config = {
  Coalition = coalition.side.BLUE,

  -- Close-in ACM setups (meters)
  ACM = {
    ABEAM_M        = 1600,   -- ~0.9 NM
    DEFENSIVE_M    = 1600,
    H2H_M          = 4000,   -- ~2.2 NM
  },

  -- Intercept spawns (nautical miles)
  INTERCEPT = {
    MIN_NM         = 40,   -- README: 40-80 NM
    MAX_NM         = 80,
    JITTER_DEG     = 110,  -- README: +/- 90 to 135 deg
    MIN_BANDITS    = 1,
    MAX_BANDITS    = 4,
    SPREAD_NM      = 4,
  },

  -- CAP (relative to player)
  CAP = {
    -- CAP center point relative to player's nose at start
    CENTER_MIN_NM      = 20,   -- README: 20-40 NM
    CENTER_MAX_NM      = 40,
    CENTER_JITTER_DEG  = 90,   -- README: +/- 90 deg

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
    CENTER_MIN_NM      = 60,   -- README: 60-100 NM
    CENTER_MAX_NM      = 100,
    CENTER_JITTER_DEG  = 135,  -- README: +/- 135 deg

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

  -- Dynamic Package Configuration (Friendly VIPs)
  Packages = {
    TANKER = {
      unit_type = "KC-135",
      skill = "High",
      count = 1,
    },
    AWACS = {
      unit_type = "A-50",
      skill = "High",
      count = 1,
    },
    AWACS_E3 = {
      unit_type = "E-3A",
      skill = "High",
      count = 1,
    },
    AWACS_E2 = {
      unit_type = "E-2C",
      skill = "High",
      count = 1,
    },
    IL78_TANKER = {
      unit_type = "IL-78M",
      skill = "High",
      count = 1,
    },
    TRANSPORT = {
      unit_type = "C-130",
      skill = "High",
      count = 1,
    },
    TANKER_S3 = {
      unit_type = "S-3B Tanker",
      skill = "High",
      count = 1,
    },
    TRANSPORT_C17 = {
      unit_type = "C-17A",
      skill = "High",
      count = 1,
    },
    STRIKE = {
      unit_type = "F-15E",
      skill = "High",
      count = 4,
    },
    SU24_STRIKE = {
      unit_type = "Su-24M",
      skill = "High",
      count = 4,
    },
    SU25_STRIKE = {
      unit_type = "Su-25T",
      skill = "High",
      count = 4,
    },
    STRIKE_F18 = {
      unit_type = "F/A-18C",
      skill = "High",
      count = 4,
    },
    STRIKE_A10 = {
      unit_type = "A-10C",
      skill = "High",
      count = 2,
    },
    BOMBER = {
      unit_type = "B-52H",
      skill = "High",
      count = 2,
    },
    BOMBER_B1 = {
      unit_type = "B-1B",
      skill = "High",
      count = 2,
    },
    TU22_BOMBER = {
      unit_type = "Tu-22M3",
      skill = "High",
      count = 2,
    },
  },

  -- ESCORT (template packages)
  ESCORT = {
    -- Keys into Packages table (or legacy template names)
    PACKAGE_TANKER     = "TANKER",
    PACKAGE_TRANSPORT  = "TRANSPORT",
    PACKAGE_STRIKE     = "STRIKE",

    -- Route: move package straight ahead from spawn (relative)
    PACKAGE_SPAWN_AHEAD_NM = 10,
    PACKAGE_ROUTE_NM       = { MIN = 60, MAX = 100 },
    PACKAGE_SPEED_KTS      = { MIN = 300, MAX = 380 },

    -- Threat spawns (relative to package)
    THREAT_MIN_NM      = 30,   -- README: 30-60 NM
    THREAT_MAX_NM      = 60,
    THREAT_JITTER_DEG  = 60,   -- README: +/- 60 deg (forward biased)
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

  -- Dynamic Bandit Configuration (No Templates)
  Bandits = {
    ------------------------------------------------------------------
    -- TIER A (Beginner)
    ------------------------------------------------------------------
    -- MiG-21Bis
    {
      id = "MIG21_WVR_A",
      filters = { role="WVR", tier="A", type="MIG21" },
      unit_type = "MiG-21Bis",
      skill = "Average",
      payload = {
        pylons = {
          [1] = { clsid = "{R-60M}" }, [2] = { clsid = "{R-60M}" },
          [3] = { clsid = "{R-60M}" }, [4] = { clsid = "{R-60M}" },
        },
        fuel = 2000,
        flare = 60, chaff = 60, gun = 100,
      }
    },
    {
      id = "MIG21_BVR_A",
      filters = { role="BVR", tier="A", type="MIG21" },
      unit_type = "MiG-21Bis",
      skill = "Average",
      payload = {
        pylons = {
          [1] = { clsid = "{R-60M}" }, [2] = { clsid = "{R-3R}" },
          [3] = { clsid = "{R-3R}" }, [4] = { clsid = "{R-60M}" },
        },
        fuel = 2000,
        flare = 60, chaff = 60, gun = 100,
      }
    },
    {
      id = "MIG21_WVR_A_GUNS",
      filters = { role="WVR", tier="A", type="MIG21", var="GUNS" },
      unit_type = "MiG-21Bis",
      skill = "Average",
      payload = {
        pylons = {}, -- Guns only
        fuel = 2000,
        flare = 60, chaff = 60, gun = 100,
      }
    },
    -- MiG-23MLA
    {
      id = "MIG23_WVR_A",
      filters = { role="WVR", tier="A", type="MIG23" },
      unit_type = "MiG-23MLA",
      skill = "Average",
      payload = {
        pylons = {
          [3] = { clsid = "{R-60M}" }, [4] = { clsid = "{R-60M}" },
        },
        fuel = 2500,
        flare = 60, chaff = 60, gun = 100,
      }
    },
    {
      id = "MIG23_WVR_A_GUNS",
      filters = { role="WVR", tier="A", type="MIG23", var="GUNS" },
      unit_type = "MiG-23MLA",
      skill = "Average",
      payload = {
        pylons = {}, -- Guns only
        fuel = 2500,
        flare = 60, chaff = 60, gun = 100,
      }
    },
    -- Su-25T (Humility Target)
    {
      id = "SU25_WVR_A",
      filters = { role="WVR", tier="A", type="SU25" },
      unit_type = "Su-25T",
      skill = "Average",
      payload = {
        pylons = {
          [1] = { clsid = "{R-60M}" }, [11] = { clsid = "{R-60M}" },
        },
        fuel = 2500,
        flare = 128, chaff = 128, gun = 100,
      }
    },

    ------------------------------------------------------------------
    -- TIER G (Intermediate)
    ------------------------------------------------------------------
    -- MiG-29A
    {
      id = "MIG29A_WVR_G",
      filters = { role="WVR", tier="G", type="MIG29A" },
      unit_type = "MiG-29A",
      skill = "Good",
      payload = {
        pylons = {
          [1] = { clsid = "{R-60M}" }, [2] = { clsid = "{R-60M}" },
          [5] = { clsid = "{R-60M}" }, [6] = { clsid = "{R-60M}" },
        },
        fuel = 3000,
        flare = 60, chaff = 60, gun = 100,
      }
    },
    -- MiG-29S
    {
      id = "MIG29S_WVR_G",
      filters = { role="WVR", tier="G", type="MIG29" },
      unit_type = "MiG-29S",
      skill = "Good",
      payload = {
        pylons = {
          [1] = { clsid = "{R-73}" }, [2] = { clsid = "{R-73}" },
          [5] = { clsid = "{R-73}" }, [6] = { clsid = "{R-73}" },
        },
        fuel = 3000,
        flare = 60, chaff = 60, gun = 100,
      }
    },
    {
      id = "MIG29S_BVR_G",
      filters = { role="BVR", tier="G", type="MIG29" },
      unit_type = "MiG-29S",
      skill = "Good",
      payload = {
        pylons = {
          [1] = { clsid = "{R-73}" }, [3] = { clsid = "{R-27R}" },
          [4] = { clsid = "{R-27R}" }, [6] = { clsid = "{R-73}" },
        },
        fuel = 3000,
        flare = 60, chaff = 60, gun = 100,
      }
    },
    -- Su-27
    {
      id = "SU27_BVR_G",
      filters = { role="BVR", tier="G", type="SU27" },
      unit_type = "Su-27",
      skill = "Good",
      payload = {
        pylons = {
          [1] = { clsid = "{R-73}" }, [3] = { clsid = "{R-27R}" },
          [8] = { clsid = "{R-27R}" }, [10] = { clsid = "{R-73}" },
        },
        fuel = 5000,
        flare = 96, chaff = 96, gun = 100,
      }
    },

    ------------------------------------------------------------------
    -- TIER H (Advanced)
    ------------------------------------------------------------------
    -- MiG-29S
    {
      id = "MIG29S_BVR_H",
      filters = { role="BVR", tier="H", type="MIG29" },
      unit_type = "MiG-29S",
      skill = "High",
      payload = {
        pylons = {
          [1] = { clsid = "{R-73}" }, [3] = { clsid = "{R-27ER}" },
          [4] = { clsid = "{R-27ER}" }, [6] = { clsid = "{R-73}" },
        },
        fuel = 3000,
        flare = 60, chaff = 60, gun = 100,
      }
    },
    -- Su-27
    {
      id = "SU27_WVR_H",
      filters = { role="WVR", tier="H", type="SU27" },
      unit_type = "Su-27",
      skill = "High",
      payload = {
        pylons = {
          [1] = { clsid = "{R-73}" }, [2] = { clsid = "{R-73}" },
          [9] = { clsid = "{R-73}" }, [10] = { clsid = "{R-73}" },
        },
        fuel = 5000,
        flare = 96, chaff = 96, gun = 100,
      }
    },
    {
      id = "SU27_BVR_H",
      filters = { role="BVR", tier="H", type="SU27" },
      unit_type = "Su-27",
      skill = "High",
      payload = {
        pylons = {
          [1] = { clsid = "{R-73}" }, [3] = { clsid = "{R-27ER}" },
          [5] = { clsid = "{R-27ET}" }, [6] = { clsid = "{R-27ET}" },
          [8] = { clsid = "{R-27ER}" }, [10] = { clsid = "{R-73}" },
        },
        fuel = 5000,
        flare = 96, chaff = 96, gun = 100,
      }
    },
    -- J-11A (Fox-3 capable)
    {
      id = "J11_BVR_H",
      filters = { role="BVR", tier="H", type="J11" },
      unit_type = "J-11A",
      skill = "High",
      payload = {
        pylons = {
          [1] = { clsid = "{R-73}" }, [2] = { clsid = "{R-73}" },
          [3] = { clsid = "{R-27ER}" }, [4] = { clsid = "{R-77}" },
          [7] = { clsid = "{R-77}" }, [8] = { clsid = "{R-27ER}" },
          [9] = { clsid = "{R-73}" }, [10] = { clsid = "{R-73}" },
        },
        fuel = 5000,
        flare = 96, chaff = 96, gun = 100,
      }
    },

    ------------------------------------------------------------------
    -- TIER X (Boss)
    ------------------------------------------------------------------
    {
      id = "SU27_BVR_X",
      filters = { role="BVR", tier="X", type="SU27" },
      unit_type = "Su-27",
      skill = "Excellent",
      payload = {
        pylons = {
          [1] = { clsid = "{R-73}" }, [2] = { clsid = "{R-73}" },
          [3] = { clsid = "{R-27ER}" }, [4] = { clsid = "{R-27ET}" },
          [5] = { clsid = "{R-27ER}" }, [6] = { clsid = "{R-27ER}" },
          [7] = { clsid = "{R-27ET}" }, [8] = { clsid = "{R-27ER}" },
          [9] = { clsid = "{R-73}" }, [10] = { clsid = "{R-73}" },
        },
        fuel = 5000,
        flare = 96, chaff = 96, gun = 100,
      }
    },
    {
      id = "J11_BVR_X",
      filters = { role="BVR", tier="X", type="J11" },
      unit_type = "J-11A",
      skill = "Excellent",
      payload = {
        pylons = {
          [1] = { clsid = "{R-73}" }, [2] = { clsid = "{R-73}" },
          [3] = { clsid = "{R-77}" }, [4] = { clsid = "{R-77}" },
          [5] = { clsid = "{R-27ER}" }, [6] = { clsid = "{R-27ER}" },
          [7] = { clsid = "{R-77}" }, [8] = { clsid = "{R-77}" },
          [9] = { clsid = "{R-73}" }, [10] = { clsid = "{R-73}" },
        },
        fuel = 5000,
        flare = 96, chaff = 96, gun = 100,
      }
    },

    ------------------------------------------------------------------
    -- BOMBER (Target Role)
    ------------------------------------------------------------------
    {
      id = "TU22_BOMBER",
      filters = { role="BOMBER", type="TU22" },
      unit_type = "Tu-22M3",
      skill = "Average",
      payload = {} -- No offensive A2A weapons
    },
    {
      id = "TU95_BOMBER",
      filters = { role="BOMBER", type="TU95" },
      unit_type = "Tu-95MS",
      skill = "Average",
      payload = {} -- No offensive A2A weapons
    },
  },

  Templates = {
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
