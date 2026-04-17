---------------------------------------------------------------------
-- TCS CONFIG: AIR DEFAULTS
-- Tuning parameters for A2A scenarios and flight envelopes.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Config = TCS.Config or {}
TCS.Config.Air = {
    Defaults = {
        -- Geometry constraints by Mission Intent (README Authoritative)
        INTENT = {
            CAP       = { minNm = 20, maxNm = 40,  arc = 90  },
            SWEEP     = { minNm = 60, maxNm = 100, arc = 135 },
            INTERCEPT = { minNm = 40, maxNm = 80,  arc = 115 },
            ESCORT    = { minNm = 30, maxNm = 60,  arc = 60  },
            BUILD     = { minNm = 5,  maxNm = 15,  arc = 180 }
        },

        -- Altitude Bands (Feet)
        ALTITUDE = { LOW = 15000, MED = 25000, HIGH = 35000 },
        
        REINFORCE_THRESHOLD = 0.50 -- Standard A2A reinforcement trigger
    }
}
env.info("TCS(CONFIG.AIR.DEFAULTS): ready")