env.info('TCS(A2G.COMPONENTS): populated from DCS Unit Types')

---------------------------------------------------------------------
-- TCS A2G Component Pools
-- Lists of Mission Editor template group names for ForceSpawner.
---------------------------------------------------------------------
env.info("TCS(A2G.COMPONENTS): loading")

TCS = TCS or {}
TCS.A2G = TCS.A2G or {}

TCS.A2G.Components = {
  MIXED = {
    { id="bmp2", domain="LAND", role="IFV", unit_type="BMP-2", size=1, mobility="TRACKED", threat_band="LOW", coalition="RED" },
    { id="btr80", domain="LAND", role="APC", unit_type="BTR-80", size=1, mobility="WHEELED", threat_band="LOW", coalition="RED" },
    { id="ural375", domain="LAND", role="TRANSPORT", unit_type="Ural-375", size=1, mobility="WHEELED", threat_band="LOW", coalition="RED" },
    { id="shilka", domain="LAND", role="AAA", unit_type="ZSU-23-4 Shilka", size=1, mobility="TRACKED", threat_band="LOW", coalition="RED" },
    { id="t55", domain="LAND", role="MBT", unit_type="T-55", size=1, mobility="TRACKED", threat_band="MED", coalition="RED" },
    { id="mtlb", domain="LAND", role="APC", unit_type="MT-LB", size=1, mobility="TRACKED", threat_band="LOW", coalition="RED" },
    { id="btr82a", domain="LAND", role="APC", unit_type="BTR-82A", size=1, mobility="WHEELED", threat_band="MED", coalition="RED" },
    { id="bmp3", domain="LAND", role="IFV", unit_type="BMP-3", size=1, mobility="TRACKED", threat_band="MED", coalition="RED" },
  },
  AIRDEF = {
    { id="osa", domain="LAND", role="SHORAD", unit_type="Osa 9A33 bm", size=1, mobility="WHEELED", threat_band="MED", coalition="RED" },
    { id="tor", domain="LAND", role="SHORAD", unit_type="Tor 9A331", size=1, mobility="TRACKED", threat_band="HIGH", coalition="RED" },
    { id="strela10", domain="LAND", role="SHORAD", unit_type="Strela-10M3", size=1, mobility="TRACKED", threat_band="LOW", coalition="RED" },
    { id="strela1", domain="LAND", role="SHORAD", unit_type="Strela-1 9P31", size=1, mobility="WHEELED", threat_band="LOW", coalition="RED" },
    { id="shilka", domain="LAND", role="AAA", unit_type="ZSU-23-4 Shilka", size=1, mobility="TRACKED", threat_band="LOW", coalition="RED" },
    { id="zu23_static", domain="LAND", role="AAA", unit_type="ZU-23 Emplacement Closed", size=1, mobility="STATIC", threat_band="LOW", coalition="RED" },
    { id="ural_zu23", domain="LAND", role="AAA", unit_type="Ural-375 ZU-23", size=1, mobility="WHEELED", threat_band="LOW", coalition="RED" },
    { id="igla", domain="LAND", role="MANPADS", unit_type="SA-18 Igla-S manpad", size=1, mobility="STATIC", threat_band="LOW", coalition="RED" },
    { id="tunguska", domain="LAND", role="SHORAD", unit_type="2S6 Tunguska", size=1, mobility="TRACKED", threat_band="HIGH", coalition="RED" },
    { id="zsu57", domain="LAND", role="AAA", unit_type="ZSU-57-2", size=1, mobility="TRACKED", threat_band="LOW", coalition="RED" },
  },
  ARMOR = {
    { id="t90", domain="LAND", role="MBT", unit_type="T-90", size=1, mobility="TRACKED", threat_band="HIGH", coalition="RED" },
    { id="t80u", domain="LAND", role="MBT", unit_type="T-80U", size=1, mobility="TRACKED", threat_band="HIGH", coalition="RED" },
    { id="t72b", domain="LAND", role="MBT", unit_type="T-72B", size=1, mobility="TRACKED", threat_band="MED", coalition="RED" },
    { id="t55", domain="LAND", role="MBT", unit_type="T-55", size=1, mobility="TRACKED", threat_band="LOW", coalition="RED" },
    { id="bmp3", domain="LAND", role="IFV", unit_type="BMP-3", size=1, mobility="TRACKED", threat_band="MED", coalition="RED" },
    { id="bmp2", domain="LAND", role="IFV", unit_type="BMP-2", size=1, mobility="TRACKED", threat_band="LOW", coalition="RED" },
    { id="bmp1", domain="LAND", role="IFV", unit_type="BMP-1", size=1, mobility="TRACKED", threat_band="LOW", coalition="RED" },
    { id="btr82a", domain="LAND", role="APC", unit_type="BTR-82A", size=1, mobility="WHEELED", threat_band="MED", coalition="RED" },
    { id="btr80", domain="LAND", role="APC", unit_type="BTR-80", size=1, mobility="WHEELED", threat_band="LOW", coalition="RED" },
    { id="mtlb", domain="LAND", role="APC", unit_type="MT-LB", size=1, mobility="TRACKED", threat_band="LOW", coalition="RED" },
  },
  TRANSPORT = {
    { id="ural375", domain="LAND", role="TRANSPORT", unit_type="Ural-375", size=1, mobility="WHEELED", threat_band="LOW", coalition="RED" },
    { id="ural4320", domain="LAND", role="TRANSPORT", unit_type="Ural-4320", size=1, mobility="WHEELED", threat_band="LOW", coalition="RED" },
    { id="kamaz", domain="LAND", role="TRANSPORT", unit_type="KAMAZ-43101", size=1, mobility="WHEELED", threat_band="LOW", coalition="RED" },
    { id="uaz", domain="LAND", role="TRANSPORT", unit_type="UAZ-469", size=1, mobility="WHEELED", threat_band="LOW", coalition="RED" },
    { id="gaz66", domain="LAND", role="TRANSPORT", unit_type="GAZ-66", size=1, mobility="WHEELED", threat_band="LOW", coalition="RED" },
    { id="zil131", domain="LAND", role="TRANSPORT", unit_type="ZIL-131", size=1, mobility="WHEELED", threat_band="LOW", coalition="RED" },
  },
  JTAC = {
    { id="brdm2", domain="LAND", role="SCOUT", unit_type="BRDM-2", size=1, mobility="WHEELED", threat_band="LOW", coalition="RED" },
    { id="uaz_scout", domain="LAND", role="SCOUT", unit_type="UAZ-469", size=1, mobility="WHEELED", threat_band="LOW", coalition="RED" },
  },
  STRUCTURE = {
    { id="bunker", domain="LAND", role="FORTIFICATION", unit_type="Bunker", size=1, mobility="STATIC", threat_band="LOW", coalition="RED" },
    { id="outpost", domain="LAND", role="FORTIFICATION", unit_type="Outpost", size=1, mobility="STATIC", threat_band="LOW", coalition="RED" },
    { id="house_armed", domain="LAND", role="FORTIFICATION", unit_type="Armed House", size=1, mobility="STATIC", threat_band="LOW", coalition="RED" },
  },
  -- Maritime Components
  SHIP_CARGO  = {
    { id="drycargo1", domain="SEA", role="CARGO", unit_type="Dry-cargo ship-1", size=1, mobility="SHIP", threat_band="LOW", coalition="RED" },
    { id="drycargo2", domain="SEA", role="CARGO", unit_type="Dry-cargo ship-2", size=1, mobility="SHIP", threat_band="LOW", coalition="RED" },
    { id="handywind", domain="SEA", role="CARGO", unit_type="HandyWind", size=1, mobility="SHIP", threat_band="LOW", coalition="RED" },
    { id="bulkcarrier", domain="SEA", role="CARGO", unit_type="Bulk Carrier", size=1, mobility="SHIP", threat_band="LOW", coalition="RED" },
  },
  SHIP_ESCORT = {
    { id="albatros", domain="SEA", role="CORVETTE", unit_type="ALBATROS", size=1, mobility="SHIP", threat_band="MED", coalition="RED" },
    { id="molniya", domain="SEA", role="CORVETTE", unit_type="MOLNIYA", size=1, mobility="SHIP", threat_band="MED", coalition="RED" },
    { id="rezky", domain="SEA", role="FRIGATE", unit_type="REZKY", size=1, mobility="SHIP", threat_band="HIGH", coalition="RED" },
  },
  SHIP_DOCKED = {
    { id="drycargo1_dock", domain="SEA", role="CARGO", unit_type="Dry-cargo ship-1", size=1, mobility="STATIC", threat_band="LOW", coalition="RED" },
    { id="tanker_dock", domain="SEA", role="CARGO", unit_type="Tanker", size=1, mobility="STATIC", threat_band="LOW", coalition="RED" },
  },

}

env.info("TCS(A2G.COMPONENTS): ready")