---------------------------------------------------------------------
-- TCS CONFIG: GROUND CATALOG
-- Defines units available to the Ground Tower Motor Pool.
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Config = TCS.Config or {}
TCS.Config.Catalog = TCS.Config.Catalog or {}
TCS.Config.Catalog.A2G = {
  ARMOR = {
    { id="t90", role="MBT", unit_type="T-90", threat_band="HIGH", coalition="RED", first_service_year=1992 },
    { id="t72b", role="MBT", unit_type="T-72B", threat_band="MED", coalition="RED", first_service_year=1985 },
    { id="bmp3", role="IFV", unit_type="BMP-3", threat_band="MED", coalition="RED", first_service_year=1987 },
    { id="bmp2", role="IFV", unit_type="BMP-2", threat_band="LOW", coalition="RED", first_service_year=1980 },
    { id="abrams", role="MBT", unit_type="M-1 Abrams", threat_band="HIGH", coalition="BLUE", first_service_year=1980 },
    { id="bradley", role="IFV", unit_type="M-2 Bradley", threat_band="HIGH", coalition="BLUE", first_service_year=1981 },
  },
  INFANTRY = {
    { id="inf_ak", role="RIFLEMAN", unit_type="Infantry AK", threat_band="LOW", coalition="RED", first_service_year=1947 },
    { id="inf_rpg", role="RIFLEMAN_AT", unit_type="Soldier RPG", threat_band="LOW", coalition="RED", first_service_year=1961 },
    { id="inf_m4", role="RIFLEMAN", unit_type="Soldier M4", threat_band="LOW", coalition="BLUE", first_service_year=1994 },
  },
  AIRDEF = {
    { id="shilka", role="AAA", unit_type="ZSU-23-4 Shilka", threat_band="LOW", coalition="RED", first_service_year=1962 },
    { id="osa", role="SHORAD", unit_type="Osa 9A33 bm", threat_band="MED", coalition="RED", first_service_year=1971 },
    { id="gepard", role="AAA", unit_type="Gepard", threat_band="HIGH", coalition="BLUE", first_service_year=1976 },
  },
  TRANSPORT = {
    { id="ural375", role="TRANSPORT", unit_type="Ural-375", threat_band="NONE", coalition="RED", first_service_year=1961 },
    { id="m939", role="TRANSPORT", unit_type="M939", threat_band="NONE", coalition="BLUE", first_service_year=1982 },
  },
  JTAC = {
    { id="brdm2", role="SCOUT", unit_type="BRDM-2", threat_band="NONE", coalition="RED", first_service_year=1962 },
  }
}

env.info("TCS(CONFIG.GROUND.CATALOG): ready")