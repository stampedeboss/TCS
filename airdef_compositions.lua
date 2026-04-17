---------------------------------------------------------------------
-- TCS TOWER: AIRDEF COMPOSITIONS
-- Defines tiered doctrinal layouts for DSAM structures.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.AirDef = TCS.Towers.AirDef or {}
TCS.Towers.AirDef.Compositions = TCS.Towers.AirDef.Compositions or {}

--- Returns the tiered layout for a specific SAM type.
function TCS.Towers.AirDef.GetBattery(samType, tier)
    local comps = TCS.Towers.AirDef.Compositions
    
    -- 1. Search Strategic and Mobile pools for the SAM type definition
    local site = (comps.Pools and comps.Pools[samType]) or (comps.Mobile and comps.Mobile[samType])
    if not site then return nil, false end

    -- 2. Identify if the asset belongs to the Mobile tactical pool
    local isMobile = (comps.Mobile and comps.Mobile[samType]) and true or false

    -- 3. Resolve Layout Tier: Requested -> Good (G) -> First Available
    local battery = site[tier or "G"] or site["G"]
    if not battery then
        -- Safety fallback to avoid nil index if standard tiers are missing
        local firstKey = next(site)
        battery = firstKey and site[firstKey]
    end

    return battery, isMobile
end

env.info("TCS(TOWER.AIRDEF.COMPOSITIONS): ready")