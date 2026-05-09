---------------------------------------------------------------------
-- TCS CONFIG: LOGISTICS OPS
-- Configurations for Logistics, Resupply, and Quick Reaction Forces (QRF).
---------------------------------------------------------------------
env.info("TCS(CONFIG.LOGISTICS.OPS): loading")

TCS = TCS or {}
TCS.Logistics = TCS.Logistics or {}
TCS.Logistics.Config = TCS.Logistics.Config or {}

TCS.Logistics.Config.Operations = {
  -- Cooldowns (seconds)
  Cooldowns = {
    LOGISTICS = 60,
  },
  
  -- Force Composition Ratios
  Forces = {
    LOGISTICS = { TRANSPORT=3, AIRDEF=0.5 },
    
    -- Quick Reaction Forces (Dispatched by Logistics Architect)
    HELO_QRF  = { HELO=1.0 },
    CAS_QRF   = { CAS=1.0 },
    CV_CAS_QRF= { CV_CAS=1.0 }
  },
}

env.info("TCS(CONFIG.LOGISTICS.OPS): ready")