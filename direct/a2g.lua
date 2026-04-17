---------------------------------------------------------------------
-- TCS DIRECT: A2G
-- Streamlined entry points for ME triggers and quick-scripting.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Direct = TCS.Direct or {}
TCS.Direct.A2G = {}

--- Standardized wrapper to forward Direct calls to the Architect
local function _dispatch(type, params)
    if not TCS.Mission or not TCS.Mission.Architect then 
        env.error("TCS(DIRECT.A2G): Mission Architect not loaded.")
        return nil 
    end
    return TCS.Mission.Architect.Build(type, params)
end

--- Standardized wrapper to forward Range calls to the dedicated Range Architect
local function _dispatchRange(type, params)
    if not TCS.Range or not TCS.Range.Architect then 
        env.error("TCS(DIRECT.A2G): Range Architect not loaded.")
        return nil 
    end
    return TCS.Range.Architect.Build(type, params)
end

-- Re-home trigger aliases to the Architect pipeline
_G.TriggerSystemBAI    = function(p) return _dispatch("BAI", p) end
_G.TriggerSystemStrike = function(p) return _dispatch("STRIKE", p) end
_G.TriggerSystemSEAD   = function(p) return _dispatch("SEAD", p) end
_G.TriggerSystemDEAD   = function(p) return _dispatch("DEAD", p) end
_G.TriggerSystemCAS    = function(p) return _dispatch("CAS", p) end
_G.TriggerSystemDSAM   = function(p) return _dispatch("DSAM", p) end

-- Range specific triggers use the Range Architect
_G.TriggerSystemBomb   = function(p) return _dispatchRange("BOMB", p) end
_G.TriggerSystemStrafe = function(p) return _dispatchRange("STRAFE", p) end
_G.TriggerSystemMixed  = function(p) return _dispatchRange("MIXED", p) end
_G.TriggerSystemConvoy = function(p) return _dispatchRange("CONVOY", p) end
_G.TriggerSystemMovingArmor = function(p) return _dispatchRange("MOVING_ARMOR", p) end
_G.TriggerSystemRadarEmitter = function(p) return _dispatchRange("RADAR_EMITTER", p) end

-- Pop-up SAM is an AirDef responsibility, acting as a specialized DSAM call
_G.TriggerSystemPopupSam = function(p) 
    p.samType = p.samType or "SA-9" -- Default to a short-range mobile IR system
    p.ambushRadiusNm = p.ambushRadiusNm or 5 -- Tell AirDef to hold fire until 5NM
    return _dispatch("DSAM", p) 
end

-- Tactical Override Triggers
_G.TriggerSystemAdvance = function(p) return TCS.Mission.Architect.IssueCommand("ADVANCE", p) end
_G.TriggerSystemRetreat = function(p) return TCS.Mission.Architect.IssueCommand("RETREAT", p) end

-- Global legacy alias
_G.TriggerMissionBAI   = _G.TriggerSystemBAI

env.info("TCS(DIRECT.A2G): ready")