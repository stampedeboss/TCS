---------------------------------------------------------------------
-- TCS CONFIG: AIR CATALOG
-- Defines available airframes and roles for the Air Tower.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Config = TCS.Config or {}
TCS.Config.Catalog = TCS.Config.Catalog or {}
TCS.Config.Catalog.A2A = {
    -- INTERCEPTORS / CAP
    FIGHTER = {
        { id="mig29s", role="BVR", unit_type="MiG-29S", coalition="RED", first_service_year=1994, threat_band="MED" },
        { id="su27", role="BVR", unit_type="Su-27", coalition="RED", first_service_year=1985, threat_band="MED" },
        { id="mig31", role="BVR", unit_type="MiG-31", coalition="RED", first_service_year=1981, threat_band="HIGH" },
        { id="f16c", role="BVR", unit_type="F-16C_50", coalition="BLUE", first_service_year=1991, threat_band="HIGH" },
        { id="fa18c", role="BVR", unit_type="FA-18C_hornet", coalition="BLUE", first_service_year=1987, threat_band="HIGH" },
    },
    -- SUPPORT (AWACS, TANKERS)
    SUPPORT = {
        { id="a50", role="AWACS", unit_type="A-50", coalition="RED", first_service_year=1984, threat_band="NONE" },
        { id="e3a", role="AWACS", unit_type="E-3A", coalition="BLUE", first_service_year=1977, threat_band="NONE" },
    }
}

env.info("TCS(CONFIG.AIR.CATALOG): ready")