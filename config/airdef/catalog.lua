---------------------------------------------------------------------
-- TCS CONFIG: AIRDEF CATALOG
-- Defines components for SAM Batteries and Fixed AAA.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Config = TCS.Config or {}
TCS.Config.Catalog = TCS.Config.Catalog or {}

-- TCS AIRDEF CATALOG v1.1.2

TCS.Config.Catalog.AirDef = {
    -- MISSILE COMPONENTS
    LAUNCHER = {
        { id="sa2_ln", sam_type="SA-2", role="LN", unit_type="S_75M_Volhov", coalition="RED", first_service_year=1957, threat_band="HIGH" },
        { id="sa3_ln", sam_type="SA-3", role="LN", unit_type="5p73 s-125 ln", coalition="RED", first_service_year=1961, threat_band="MED" },
        { id="sa6_ln", sam_type="SA-6", role="LN", unit_type="Kub 2P25 ln", coalition="RED", first_service_year=1967, threat_band="MED" },
        { id="sa8_ln", sam_type="SA-8", role="LN", unit_type="Osa 9A33 ln", coalition="RED", first_service_year=1971, threat_band="LOW" },
        { id="sa9_ln", sam_type="SA-9", role="LN", unit_type="Strela-1 9P31", coalition="RED", first_service_year=1968, threat_band="LOW" },
        { id="sa10_ln", sam_type="SA-10", role="LN", unit_type="S-300PS 5P85D ln", coalition="RED", first_service_year=1980, threat_band="HIGH" },
        { id="sa11_ln", sam_type="SA-11", role="LN", unit_type="SA-11 Buk LN 9A310M1", coalition="RED", first_service_year=1979, threat_band="HIGH" },
        { id="sa15_ln", sam_type="SA-15", role="LN", unit_type="Tor 9A331", coalition="RED", first_service_year=1986, threat_band="HIGH" },
        { id="sa19_ln", sam_type="SA-19", role="LN", unit_type="2S6 Tunguska", coalition="RED", first_service_year=1982, threat_band="HIGH" },
        { id="sa22_ln", sam_type="SA-22", role="LN", unit_type="Pantsir-S1", coalition="RED", first_service_year=2003, threat_band="HIGH" },
        { id="sa5_ln", sam_type="SA-5", role="LN", unit_type="S-200_Launcher", coalition="RED", first_service_year=1967, threat_band="HIGH" },
        { id="patriot_ln", sam_type="Patriot", role="LN", unit_type="M901", coalition="BLUE", first_service_year=1981, threat_band="HIGH" },
    },
    -- RADAR COMPONENTS 
    RADAR = {
        { id="sa2_tr", sam_type="SA-2", role="TR", unit_type="SNR_75V", coalition="RED", first_service_year=1957, threat_band="HIGH" },
        { id="sa2_rd", sam_type="SA-2", role="RD", unit_type="RD_75", coalition="RED", first_service_year=1957, threat_band="HIGH" },
        { id="sa3_tr", sam_type="SA-3", role="TR", unit_type="snr s-125 tr", coalition="RED", first_service_year=1961, threat_band="MED" },
        { id="sa5_tr", sam_type="SA-5", role="TR", unit_type="RPC_5N62V", coalition="RED", first_service_year=1967, threat_band="HIGH" },
        { id="sa5_sr", sam_type="SA-5", role="SR", unit_type="p-19 s-125 sr", coalition="RED", first_service_year=1967, threat_band="HIGH" },
        { id="sa10_tr", sam_type="SA-10", role="TR", unit_type="S-300PS 5H63C 30H6_tr", coalition="RED", first_service_year=1980, threat_band="HIGH" },
        { id="sa10_sr", sam_type="SA-10", role="SR", unit_type="S-300PS 64H6E sr", coalition="RED", first_service_year=1980, threat_band="HIGH" },
        { id="sa8_tr", sam_type="SA-8", role="TR", unit_type="Osa 9A33 ln", coalition="RED", first_service_year=1971, threat_band="LOW" },
        { id="sa15_tr", sam_type="SA-15", role="TR", unit_type="Tor 9A331", coalition="RED", first_service_year=1986, threat_band="HIGH" },
        { id="sa22_tr", sam_type="SA-22", role="TR", unit_type="CHAP_PantsirS1", coalition="RED", first_service_year=2003, threat_band="HIGH" },
        { id="p19_sr", sam_type="ALL", role="SR", unit_type="p-19 s-125 sr", coalition="RED", first_service_year=1974, threat_band="HIGH" },
        { id="sa6_tr", sam_type="SA-6", role="TR", unit_type="Kub 1S91 str", coalition="RED", first_service_year=1967, threat_band="MED" },
        { id="sa11_sr", sam_type="SA-11", role="SR", unit_type="SA-11 Buk SR 9S18M1", coalition="RED", first_service_year=1979, threat_band="HIGH" },
        { id="sa11_tr", sam_type="SA-11", role="TR", unit_type="SA-11 Buk LN 9A310M1", coalition="RED", first_service_year=1979, threat_band="HIGH" },
        { id="patriot_tr", sam_type="Patriot", role="TR", unit_type="AN/MPQ-53", coalition="BLUE", first_service_year=1981, threat_band="HIGH" },
    },
    -- FIXED AAA
    FIXED_AAA = {
        { id="ks19", role="AAA", unit_type="KS-19", coalition="RED", first_service_year=1948, threat_band="MED" },
        { id="zu23_static", role="AAA", unit_type="ZU-23 Emplacement", coalition="RED", first_service_year=1960, threat_band="LOW" },
        { id="ural_zu23", role="AAA", unit_type="Ural-375 ZU-23", coalition="RED", first_service_year=1961, threat_band="LOW" },
    },
    -- SUPPORT COMPONENTS
    SUPPORT = {
        { id="skp11", role="CP", unit_type="SKP-11", coalition="RED", first_service_year=1950, threat_band="LOW" },
        { id="pu12", sam_type="ALL", role="CP", unit_type="SKP-11", coalition="RED", first_service_year=1970, threat_band="MED" },
        { id="sa6_cp", sam_type="SA-6", role="CP", unit_type="Ural-375 PBU", coalition="RED", first_service_year=1967, threat_band="MED" },
        { id="sa_pwr", sam_type="ALL", role="PWR", unit_type="ZiL-131 APA-80", coalition="RED", first_service_year=1967, threat_band="MED" },
        { id="sa_fuel", sam_type="ALL", role="FUEL", unit_type="ATZ-10", coalition="RED", first_service_year=1967, threat_band="MED" },
        { id="sa_util", sam_type="ALL", role="UTIL", unit_type="Ural-4320-31", coalition="RED", first_service_year=1967, threat_band="MED" },
        { id="sa10_cp", sam_type="SA-10", role="CP", unit_type="S-300PS 54K6 cp", coalition="RED", first_service_year=1980, threat_band="HIGH" },
        { id="sa11_cp", sam_type="SA-11", role="CP", unit_type="SA-11 Buk CC 9S470M1", coalition="RED", first_service_year=1979, threat_band="HIGH" },
        { id="patriot_cp", sam_type="Patriot", role="CP", unit_type="AN/MSQ-104", coalition="BLUE", first_service_year=1981, threat_band="HIGH" },
    }
}

env.info("TCS(CONFIG.AIRDEF.CATALOG): ready")