---------------------------------------------------------------------
-- TCS TOWER: GROUND COMPOSITIONS
-- Defines unit ratios for different tactical force types.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.Ground = TCS.Towers.Ground or {} -- Ensure parent table exists
TCS.Towers.Ground.Compositions = {}

TCS.Towers.Ground.Compositions.Blueprints = {
    -- 1. MECH_INF: Balanced combined arms (The 8-unit block)
    MECH_INF = {
        baseSize = 8,
        ratios = {
            ARMOR     = { weight = 1.0, sub = { MBT = 0.3, IFV = 0.7 } },
            INFANTRY  = { weight = 1.0, sub = { RIFLEMAN = 0.8, RIFLEMAN_AT = 0.2 } },
            TRANSPORT = 0.5, -- Logistics/Support
            AIRDEF    = 0.1, -- Point Defense
            JTAC      = 0.1  -- Recon
        }
    },

    -- 2. ARMOR_STRIKE: Heavy breakthrough force
    ARMOR_STRIKE = {
        baseSize = 8,
        ratios = {
            ARMOR     = { weight = 1.0, sub = { MBT = 0.8, IFV = 0.2 } }, 
            AIRDEF    = 0.2, -- Extra AAA for the spearhead
            JTAC      = 0.1
        }
    },

    -- 3. MOTOR_RIFLE: High-volume mechanized infantry
    MOTOR_RIFLE = {
        baseSize = 12,
        ratios = {
            INFANTRY  = { weight = 1.0, sub = { RIFLEMAN = 0.7, RIFLEMAN_AT = 0.2, MACHINE_GUNNER = 0.1 } },
            ARMOR     = { weight = 0.3, sub = { APC = 1.0 } },
            TRANSPORT = 0.6,
            AIRDEF    = 0.1
        }
    },

    -- 4. LIGHT_INF: The "Infra Only" request
    LIGHT_INF = {
        baseSize = 8,
        ratios = {
            INFANTRY  = { weight = 1.0, sub = { RIFLEMAN = 0.6, RIFLEMAN_AT = 0.2, SNIPER = 0.1, RIFLEMAN_AA = 0.1 } },
            TRANSPORT = 0.2, -- Minimal logistics
            JTAC      = 0.1  -- Spotters
        }
    },

    -- 5. AIRDEF_SECTION: Dedicated mobile AD
    AIRDEF_SECTION = {
        baseSize = 4,
        ratios = {
            AIRDEF = 1.0
        }
    },

    -- Standard Support Blueprints (Updated to new format)
    TRANSPORT = {
        baseSize = 6,
        ratios = { TRANSPORT = 1.0 }
    },
    MOBILE_AAA = {
        baseSize = 2,
        ratios = { AIRDEF = 1.0 }
    },
    INFANTRY = {
        baseSize = 8,
        ratios = { 
            INFANTRY = { 
                weight = 1.0, 
                sub = { RIFLEMAN = 0.7, RIFLEMAN_AT = 0.2, SNIPER = 0.1 } 
            } 
        }
    }
}

--- Returns the blueprint for a specific force type.
function TCS.Towers.Ground.GetBlueprint(forceType)
    local bp = TCS.Towers.Ground.Compositions.Blueprints[forceType]
    if not bp then
        env.warning("TCS(GROUND): No blueprint found for " .. tostring(forceType))
        return TCS.Towers.Ground.Compositions.Blueprints.MECH_INF
    end
    return bp
end

env.info("TCS(TOWER.GROUND.COMPOSITIONS): ready")