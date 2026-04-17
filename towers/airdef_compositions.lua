---------------------------------------------------------------------
-- TCS TOWER: AIRDEF COMPOSITIONS
-- Defines tiered doctrinal layouts for DSAM structures.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.AirDef = TCS.Towers.AirDef or {}
TCS.Towers.AirDef.Compositions = TCS.Towers.AirDef.Compositions or {}

--- Returns the tiered layout for a specific SAM type.
function TCS.Towers.AirDef.GetBattery(type, tier)

    -- Use logical OR to find the system in either the Strategic (Pools) or Mobile pool.
    -- This requires that the Pools and Mobile data files are loaded BEFORE this logic file.
    local site = (TCS.Towers.AirDef.Compositions.Pools and TCS.Towers.AirDef.Compositions.Pools[type]) 
              or (TCS.Towers.AirDef.Compositions.Mobile and TCS.Towers.AirDef.Compositions.Mobile[type])

     local isMobile = false
    if site and TCS.Towers.AirDef.Compositions.Mobile and TCS.Towers.AirDef.Compositions.Mobile[type] then
        isMobile = true
    end

    if not site then return nil end

    -- Fallback logic: exact tier -> standard tier (G) -> first available
    return site[tier or "G"] or site["G"] or site[next(site)], isMobile
end

env.info("TCS(TOWER.AIRDEF.COMPOSITIONS): ready")