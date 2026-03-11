---------------------------------------------------------------------
-- TCS CATALOG DATA
-- Content definitions for the Unified Catalog.
-- Loaded after core/tcs_catalog.lua.
---------------------------------------------------------------------
env.info("TCS(CATALOG_DATA): loading")

TCS.Config.Catalog = {}

-- 1. A2G Components (Ground/Sea)
TCS.Config.Catalog.A2G = {
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
    { id="ural375", domain="LAND", role="TRANSPORT", unit_type="Ural-375", size=1, mobility="WHEELED", threat_band="NONE", coalition="RED" },
    { id="ural4320", domain="LAND", role="TRANSPORT", unit_type="Ural-4320", size=1, mobility="WHEELED", threat_band="NONE", coalition="RED" },
    { id="kamaz", domain="LAND", role="TRANSPORT", unit_type="KAMAZ-43101", size=1, mobility="WHEELED", threat_band="NONE", coalition="RED" },
    { id="uaz", domain="LAND", role="TRANSPORT", unit_type="UAZ-469", size=1, mobility="WHEELED", threat_band="NONE", coalition="RED" },
    { id="gaz66", domain="LAND", role="TRANSPORT", unit_type="GAZ-66", size=1, mobility="WHEELED", threat_band="NONE", coalition="RED" },
    { id="zil131", domain="LAND", role="TRANSPORT", unit_type="ZIL-131", size=1, mobility="WHEELED", threat_band="NONE", coalition="RED" },
  },
  JTAC = {
    { id="brdm2", domain="LAND", role="SCOUT", unit_type="BRDM-2", size=1, mobility="WHEELED", threat_band="NONE", coalition="RED" },
    { id="uaz_scout", domain="LAND", role="SCOUT", unit_type="UAZ-469", size=1, mobility="WHEELED", threat_band="NONE", coalition="RED" },
  },
  STRUCTURE = {
    { id="bunker", domain="LAND", role="FORTIFICATION", unit_type="Bunker", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
    { id="outpost", domain="LAND", role="FORTIFICATION", unit_type="Outpost", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
    { id="house_armed", domain="LAND", role="FORTIFICATION", unit_type="Armed House", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
    { id="container_red1", domain="LAND", role="FORTIFICATION", unit_type="Container Red 1", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
    { id="container_red2", domain="LAND", role="FORTIFICATION", unit_type="Container Red 2", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
    { id="container_red3", domain="LAND", role="FORTIFICATION", unit_type="Container Red 3", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
  },
  SHIP_CARGO  = {
    { id="drycargo1", domain="SEA", role="CARGO", unit_type="Dry-cargo ship-1", size=1, mobility="SHIP", threat_band="NONE", coalition="RED" },
    { id="drycargo2", domain="SEA", role="CARGO", unit_type="Dry-cargo ship-2", size=1, mobility="SHIP", threat_band="NONE", coalition="RED" },
    { id="handywind", domain="SEA", role="CARGO", unit_type="HandyWind", size=1, mobility="SHIP", threat_band="NONE", coalition="RED" },
    { id="bulkcarrier", domain="SEA", role="CARGO", unit_type="Bulk Carrier", size=1, mobility="SHIP", threat_band="NONE", coalition="RED" },
  },
  SHIP_CORVETTE = {
    { id="molniya", domain="SEA", role="CORVETTE", unit_type="MOLNIYA", size=1, mobility="SHIP", threat_band="MED", coalition="RED" },
    { id="albatros", domain="SEA", role="CORVETTE", unit_type="ALBATROS", size=1, mobility="SHIP", threat_band="MED", coalition="RED" },
    { id="speedboat", domain="SEA", role="CORVETTE", unit_type="Speedboat", size=1, mobility="SHIP", threat_band="LOW", coalition="RED" },
  },
  SHIP_FRIGATE = {
    { id="rezky", domain="SEA", role="FRIGATE", unit_type="REZKY", size=1, mobility="SHIP", threat_band="HIGH", coalition="RED" },
    { id="neustrashimy", domain="SEA", role="FRIGATE", unit_type="NEUSTRASHIMY", size=1, mobility="SHIP", threat_band="HIGH", coalition="RED" },
  },
  SHIP_DESTROYER = {
    { id="type052b", domain="SEA", role="DESTROYER", unit_type="Type_052B", size=1, mobility="SHIP", threat_band="HIGH", coalition="RED" },
    { id="type052c", domain="SEA", role="DESTROYER", unit_type="Type_052C", size=1, mobility="SHIP", threat_band="HIGH", coalition="RED" },
  },
  SHIP_CRUISER = {
    { id="moskva", domain="SEA", role="CRUISER", unit_type="MOSKVA", size=1, mobility="SHIP", threat_band="HIGH", coalition="RED" },
    { id="pyotr", domain="SEA", role="CRUISER", unit_type="PYOTR VELIKIY", size=1, mobility="SHIP", threat_band="HIGH", coalition="RED" },
  },
  SHIP_CARRIER = {
    { id="kuznetsov", domain="SEA", role="CARRIER", unit_type="KUZNECOV", size=1, mobility="SHIP", threat_band="HIGH", coalition="RED" },
  },
  SHIP_SUBMARINE = {
    { id="kilo", domain="SEA", role="SUBMARINE", unit_type="KILO", size=1, mobility="SHIP", threat_band="HIGH", coalition="RED" },
    { id="som", domain="SEA", role="SUBMARINE", unit_type="SOM", size=1, mobility="SHIP", threat_band="HIGH", coalition="RED" },
  },
  SHIP_AMPHIB = {
    { id="bdk775", domain="SEA", role="AMPHIB", unit_type="BDK-775", size=1, mobility="SHIP", threat_band="MED", coalition="RED" },
  },
  SHIP_DOCKED = {
    { id="drycargo1_dock", domain="SEA", role="CARGO", unit_type="Dry-cargo ship-1", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
    { id="tanker_dock", domain="SEA", role="CARGO", unit_type="Tanker", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
  },
  RANGE_476 = {
    { id="476_circ_75", domain="LAND", role="RANGE_TARGET", unit_type="476_Target_Circle_75", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
    { id="476_circ_150", domain="LAND", role="RANGE_TARGET", unit_type="476_Target_Circle_150", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
    { id="476_sq_75", domain="LAND", role="RANGE_TARGET", unit_type="476_Target_Square_75", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
    { id="476_sq_150", domain="LAND", role="RANGE_TARGET", unit_type="476_Target_Square_150", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
    { id="476_hard_1", domain="LAND", role="RANGE_TARGET", unit_type="476_Target_Hard_1", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
    { id="476_conex", domain="LAND", role="RANGE_TARGET", unit_type="476_Conex_Box_White", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
    { id="476_truck", domain="LAND", role="RANGE_TARGET", unit_type="476_Target_Truck", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
    { id="476_apc", domain="LAND", role="RANGE_TARGET", unit_type="476_Target_APC", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
    { id="476_tank", domain="LAND", role="RANGE_TARGET", unit_type="476_Target_Tank", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
    { id="476_pit_w", domain="LAND", role="RANGE_TARGET", unit_type="476_Target_Strafe_Pit_West", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
    { id="476_pit_e", domain="LAND", role="RANGE_TARGET", unit_type="476_Target_Strafe_Pit_East", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
    { id="476_panel", domain="LAND", role="RANGE_TARGET", unit_type="476_Target_Panel_Vertical", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
  },
}

-- 2. A2A Bandits (Air)
local function generate_bandits()
  local bandits = {}
  local function add(id, type, tier, role, var, skill, loadout, speed_class)
    table.insert(bandits, {
      id = id,
      filters = { role=role, tier=tier, type=type, var=var },
      unit_type = type,
      skill = skill,
      payload = loadout,
      speed_class = speed_class
    })
  end

  local Skills = { A="Average", G="Good", H="High", X="Excellent" }
  local P = {
    Empty = {},
    A10_AIM9 = {pylons={[1]={clsid="{AIM-9M}"},[11]={clsid="{AIM-9M}"}}, fuel=4000, flare=120, chaff=240, gun=100},
    F14_AIM54 = {pylons={[1]={clsid="{AIM-9M}"},[3]={clsid="{AIM-54C_Mk47}"},[4]={clsid="{AIM-54C_Mk47}"},[5]={clsid="{AIM-54C_Mk47}"},[6]={clsid="{AIM-54C_Mk47}"},[8]={clsid="{AIM-9M}"}}, fuel=6000, flare=60, chaff=60, gun=100},
    F14_AIM7 = {pylons={[1]={clsid="{AIM-9M}"},[3]={clsid="{AIM-7M}"},[4]={clsid="{AIM-7M}"},[5]={clsid="{AIM-7M}"},[6]={clsid="{AIM-7M}"},[8]={clsid="{AIM-9M}"}}, fuel=6000, flare=60, chaff=60, gun=100},
    F14_AIM9 = {pylons={[2]={clsid="{AIM-9M}"},[7]={clsid="{AIM-9M}"}}, fuel=6000, flare=60, chaff=60, gun=100},
    F16_AIM120 = {pylons={[1]={clsid="{AIM-120C}"},[2]={clsid="{AIM-9M}"},[3]={clsid="{AIM-120C}"},[7]={clsid="{AIM-120C}"},[8]={clsid="{AIM-9M}"},[9]={clsid="{AIM-120C}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    F16_AIM9 = {pylons={[1]={clsid="{AIM-9M}"},[2]={clsid="{AIM-9M}"},[8]={clsid="{AIM-9M}"},[9]={clsid="{AIM-9M}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    F18_AIM120 = {pylons={[1]={clsid="{AIM-9M}"},[2]={clsid="{AIM-120C}"},[3]={clsid="{AIM-120C}"},[7]={clsid="{AIM-120C}"},[8]={clsid="{AIM-120C}"},[9]={clsid="{AIM-9M}"}}, fuel=4000, flare=60, chaff=60, gun=100},
    F18_AIM9 = {pylons={[1]={clsid="{AIM-9M}"},[9]={clsid="{AIM-9M}"}}, fuel=4000, flare=60, chaff=60, gun=100},
    F5_AIM9 = {pylons={[1]={clsid="{AIM-9P5}"},[7]={clsid="{AIM-9P5}"}}, fuel=2000, flare=30, chaff=30, gun=100},
    J11_R27 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[3]={clsid="{R-27R}"},[4]={clsid="{R-27R}"},[9]={clsid="{R-73}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    J11_R27ER = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[3]={clsid="{R-27ER}"},[4]={clsid="{R-27ER}"},[7]={clsid="{R-27ER}"},[8]={clsid="{R-27ER}"},[9]={clsid="{R-73}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    J11_R77 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[3]={clsid="{R-77}"},[4]={clsid="{R-77}"},[5]={clsid="{R-27ER}"},[6]={clsid="{R-27ER}"},[7]={clsid="{R-77}"},[8]={clsid="{R-77}"},[9]={clsid="{R-73}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    JF17_PL5 = {pylons={[1]={clsid="{PL-5EII}"},[7]={clsid="{PL-5EII}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    JF17_SD10 = {pylons={[1]={clsid="{PL-5EII}"},[2]={clsid="{SD-10}"},[6]={clsid="{SD-10}"},[7]={clsid="{PL-5EII}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    L39_R60 = {pylons={[1]={clsid="{R-60M}"},[4]={clsid="{R-60M}"}}, fuel=1000, flare=0, chaff=0, gun=100},
    M2000_MAGIC = {pylons={[1]={clsid="{MAGIC_II}"},[9]={clsid="{MAGIC_II}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    MIG19_R3S = {pylons={[1]={clsid="{R-3S}"},[2]={clsid="{R-3S}"}}, fuel=2000, flare=0, chaff=0, gun=100},
    MIG21_R3R = {pylons={[1]={clsid="{R-60M}"},[2]={clsid="{R-3R}"},[3]={clsid="{R-3R}"},[4]={clsid="{R-60M}"}}, fuel=2000, flare=60, chaff=60, gun=100},
    MIG21_R60 = {pylons={[1]={clsid="{R-60M}"},[2]={clsid="{R-60M}"},[3]={clsid="{R-60M}"},[4]={clsid="{R-60M}"}}, fuel=2000, flare=60, chaff=60, gun=100},
    MIG23_R23 = {pylons={[1]={clsid="{R-23R}"},[2]={clsid="{R-23R}"},[3]={clsid="{R-60M}"},[4]={clsid="{R-60M}"}}, fuel=2500, flare=60, chaff=60, gun=100},
    MIG23_R60 = {pylons={[3]={clsid="{R-60M}"},[4]={clsid="{R-60M}"}}, fuel=2500, flare=60, chaff=60, gun=100},
    MIG29A_R27 = {pylons={[1]={clsid="{R-73}"},[3]={clsid="{R-27R}"},[4]={clsid="{R-27R}"},[6]={clsid="{R-73}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    MIG29A_R60 = {pylons={[1]={clsid="{R-60M}"},[2]={clsid="{R-60M}"},[5]={clsid="{R-60M}"},[6]={clsid="{R-60M}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    MIG29S_R27 = {pylons={[1]={clsid="{R-73}"},[3]={clsid="{R-27R}"},[4]={clsid="{R-27R}"},[6]={clsid="{R-73}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    MIG29S_R27ER = {pylons={[1]={clsid="{R-73}"},[3]={clsid="{R-27ER}"},[4]={clsid="{R-27ER}"},[6]={clsid="{R-73}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    MIG29S_R73 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[5]={clsid="{R-73}"},[6]={clsid="{R-73}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    MIG29S_R77 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-77}"},[3]={clsid="{R-77}"},[4]={clsid="{R-77}"},[5]={clsid="{R-77}"},[6]={clsid="{R-73}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    MIG31_R33 = {pylons={[1]={clsid="{R-33}"},[2]={clsid="{R-33}"},[3]={clsid="{R-33}"},[4]={clsid="{R-33}"}}, fuel=6000, flare=60, chaff=60, gun=100},
    MIG31_R60 = {pylons={[5]={clsid="{R-60M}"},[6]={clsid="{R-60M}"}}, fuel=6000, flare=60, chaff=60, gun=100},
    SU25_R60 = {pylons={[1]={clsid="{R-60M}"},[11]={clsid="{R-60M}"}}, fuel=2500, flare=128, chaff=128, gun=100},
    SU27_R27 = {pylons={[1]={clsid="{R-73}"},[3]={clsid="{R-27R}"},[8]={clsid="{R-27R}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    SU27_R27ER = {pylons={[1]={clsid="{R-73}"},[3]={clsid="{R-27ER}"},[5]={clsid="{R-27ET}"},[6]={clsid="{R-27ET}"},[8]={clsid="{R-27ER}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    SU27_R73 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[9]={clsid="{R-73}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    SU30_R27ER = {pylons={[1]={clsid="{R-73}"},[3]={clsid="{R-27ER}"},[5]={clsid="{R-27ET}"},[6]={clsid="{R-27ET}"},[8]={clsid="{R-27ER}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    SU30_R77 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[3]={clsid="{R-77}"},[4]={clsid="{R-77}"},[5]={clsid="{R-27ER}"},[6]={clsid="{R-27ER}"},[7]={clsid="{R-77}"},[8]={clsid="{R-77}"},[9]={clsid="{R-73}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    SU33_R27 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[3]={clsid="{R-27R}"},[4]={clsid="{R-27R}"},[9]={clsid="{R-27R}"},[10]={clsid="{R-27R}"},[11]={clsid="{R-73}"},[12]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    SU33_R27ER = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[3]={clsid="{R-27ER}"},[4]={clsid="{R-27ET}"},[9]={clsid="{R-27ER}"},[10]={clsid="{R-27ET}"},[11]={clsid="{R-73}"},[12]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    SU33_R73 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[11]={clsid="{R-73}"},[12]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    YAK52_EMPTY = {pylons={}, fuel=100, flare=0, chaff=0, gun=100},
  }

  local Aircraft = {
    { id="A10", type="A-10A", tiers={"A"}, wvr={GUNS=P.Empty, FOX2=P.A10_AIM9}, speed_class="SLOW" },
    { id="F14", type="F-14B", tiers={"H","X"}, wvr={GUNS=P.Empty, FOX2=P.F14_AIM9}, bvr={FOX1=P.F14_AIM7, FOX3={X=P.F14_AIM54}}, speed_class="FAST" },
    { id="F16", type="F-16C_50", tiers={"H","X"}, wvr={GUNS=P.Empty, FOX2=P.F16_AIM9}, bvr={FOX3={H=P.F16_AIM120, X=P.F16_AIM120}} },
    { id="F18", type="FA-18C_hornet", tiers={"H","X"}, wvr={GUNS=P.Empty, FOX2=P.F18_AIM9}, bvr={FOX3={H=P.F18_AIM120, X=P.F18_AIM120}} },
    { id="F5", type="F-5E-3", tiers={"A","G"}, wvr={GUNS=P.Empty, FOX2=P.F5_AIM9} },
    { id="J11", type="J-11A", tiers={"G","H","X"}, wvr={GUNS=P.Empty, FOX2=P.SU27_R73}, bvr={FOX1={G=P.J11_R27, H=P.J11_R27ER, X=P.J11_R27ER}, FOX3={X=P.J11_R77}} },
    { id="JF17", type="JF-17", tiers={"H","X"}, wvr={GUNS=P.Empty, FOX2=P.JF17_PL5}, bvr={FOX3={H=P.JF17_SD10, X=P.JF17_SD10}} }, -- SD10 is Fox3
    { id="L39", type="L-39ZA", tiers={"A"}, wvr={GUNS=P.Empty, FOX2=P.L39_R60}, speed_class="SLOW" },
    { id="M2000", type="M-2000C", tiers={"G","H"}, wvr={GUNS=P.Empty, FOX2=P.M2000_MAGIC} },
    { id="MIG19", type="MiG-19P", tiers={"G"}, wvr={GUNS=P.Empty, FOX2=P.MIG19_R3S} },
    { id="MIG21", type="MiG-21Bis", tiers={"A","G"}, wvr={GUNS=P.Empty, FOX2=P.MIG21_R60}, bvr={FOX1=P.MIG21_R3R} },
    { id="MIG23", type="MiG-23MLA", tiers={"A"}, wvr={GUNS=P.Empty, FOX2=P.MIG23_R60}, bvr={FOX1=P.MIG23_R23} },
    { id="MIG29A", type="MiG-29A", tiers={"G"}, wvr={GUNS=P.Empty, FOX2=P.MIG29A_R60}, bvr={FOX1=P.MIG29A_R27} },
    { id="MIG29S", type="MiG-29S", tiers={"G","H","X"}, wvr={GUNS=P.Empty, FOX2=P.MIG29S_R73}, bvr={FOX1={G=P.MIG29S_R27, H=P.MIG29S_R27ER, X=P.MIG29S_R27ER}, FOX3={X=P.MIG29S_R77}} },
    { id="MIG31", type="MiG-31", tiers={"X"}, wvr={GUNS=P.Empty, FOX2=P.MIG31_R60}, bvr={FOX1=P.MIG31_R33}, speed_class="FAST" }, -- R33 is Fox1
    { id="SU25", type="Su-25T", tiers={"A"}, wvr={GUNS=P.Empty, FOX2=P.SU25_R60}, speed_class="SLOW" },
    { id="SU27", type="Su-27", tiers={"G","H","X"}, wvr={GUNS=P.Empty, FOX2=P.SU27_R73}, bvr={FOX1={G=P.SU27_R27, H=P.SU27_R27ER, X=P.SU27_R27ER}} },
    { id="SU30", type="Su-30", tiers={"H","X"}, wvr={GUNS=P.Empty, FOX2=P.SU27_R73}, bvr={FOX1=P.SU30_R27ER, FOX3={X=P.SU30_R77}} },
    { id="SU33", type="Su-33", tiers={"G","H","X"}, wvr={GUNS=P.Empty, FOX2=P.SU33_R73}, bvr={FOX1={G=P.SU33_R27, H=P.SU33_R27ER, X=P.SU33_R27ER}} },
    { id="YAK52", type="Yak-52", tiers={"A"}, wvr={GUNS=P.Empty, FOX2=P.YAK52_EMPTY}, speed_class="SLOW" },
    { id="DRONE", type="A-10A", tiers={"A"}, wvr={GUNS=P.Empty}, bvr={}, role="DRONE" },
  }

  for _, ac in ipairs(Aircraft) do
    for _, tier in ipairs(ac.tiers) do
      local skill = Skills[tier]
      
      if ac.role == "DRONE" then
        add(ac.id, ac.type, tier, "DRONE", "NONE", skill, P.Empty, ac.speed_class)
      else
        -- WVR Variants
        if ac.wvr then
          for var, loadout in pairs(ac.wvr) do
            local finalLoadout = loadout
            if type(loadout) == "table" and loadout[tier] then finalLoadout = loadout[tier] end -- Handle tier-specific overrides
            if finalLoadout then
               add(ac.id.."_WVR_"..tier.."_"..var, ac.type, tier, "WVR", var, skill, finalLoadout, ac.speed_class)
               -- Also add base ID for WVR if it's FOX2 (default)
               if var == "FOX2" then
                  add(ac.id.."_WVR_"..tier, ac.type, tier, "WVR", var, skill, finalLoadout, ac.speed_class)
               end
            end
          end
        end
        -- BVR Variants
        if ac.bvr then
          for var, loadout in pairs(ac.bvr) do
            local finalLoadout = loadout
            -- Handle tier-specific overrides (e.g. FOX1 might be R27R for G but R27ER for H)
            if type(loadout) == "table" and (loadout.G or loadout.H or loadout.X or loadout.A) then
               finalLoadout = loadout[tier]
            end
            
            if finalLoadout then
               add(ac.id.."_BVR_"..tier.."_"..var, ac.type, tier, "BVR", var, skill, finalLoadout, ac.speed_class)
               -- Default BVR alias (usually FOX1 for A-H, FOX3 for X if available)
               if var == "FOX1" and tier ~= "X" then
                  add(ac.id.."_BVR_"..tier, ac.type, tier, "BVR", var, skill, finalLoadout, ac.speed_class)
               elseif var == "FOX3" and tier == "X" then
                  add(ac.id.."_BVR_"..tier, ac.type, tier, "BVR", var, skill, finalLoadout, ac.speed_class)
               end
            end
          end
        end
      end
    end
  end

  -- Add Bombers manually as they don't fit the pattern
  table.insert(bandits, { id="TU22_BOMBER", filters={role="BOMBER", type="TU22"}, unit_type="Tu-22M3", skill="Average", payload={} })
  table.insert(bandits, { id="TU95_BOMBER", filters={role="BOMBER", type="TU95"}, unit_type="Tu-95MS", skill="Average", payload={}, speed_class="SLOW" })
  table.insert(bandits, { id="SU34_BOMBER", filters={role="BOMBER", type="SU34"}, unit_type="Su-34", skill="High", payload=P.SU27_R73 }) -- Reusing Su27 loadout for self defense

  return bandits
end

TCS.Config.Catalog.A2A_Bandits = generate_bandits()

-- 3. A2A Packages (Friendly VIPs)
TCS.Config.Catalog.A2A_Packages = {
  { id="AWACS", unit_type="A-50", skill="High", count=1, role="AWACS" },
  { id="AWACS_E2", unit_type="E-2C", skill="High", count=1, role="AWACS" },
  { id="AWACS_E3", unit_type="E-3A", skill="High", count=1, role="AWACS" },
  { id="BOMBER", unit_type="B-52H", skill="High", count=2, role="BOMBER" },
  { id="BOMBER_B1", unit_type="B-1B", skill="High", count=2, role="BOMBER" },
  { id="IL78_TANKER", unit_type="IL-78M", skill="High", count=1, role="TANKER" },
  { id="STRIKE", unit_type="F-15E", skill="High", count=4, role="STRIKE" },
  { id="STRIKE_A10", unit_type="A-10C", skill="High", count=2, role="CAS" },
  { id="STRIKE_F18", unit_type="F/A-18C", skill="High", count=4, role="STRIKE" },
  { id="SU24_STRIKE", unit_type="Su-24M", skill="High", count=4, role="STRIKE" },
  { id="SU25_STRIKE", unit_type="Su-25T", skill="High", count=4, role="STRIKE" },
  { id="TANKER", unit_type="KC-135", skill="High", count=1, role="TANKER" },
  { id="TANKER_S3", unit_type="S-3B Tanker", skill="High", count=1, role="TANKER" },
  { id="TRANSPORT", unit_type="C-130", skill="High", count=1, role="TRANSPORT" },
  { id="TRANSPORT_C17", unit_type="C-17A", skill="High", count=1, role="TRANSPORT" },
  { id="TU22_BOMBER", unit_type="Tu-22M3", skill="High", count=2, role="BOMBER" },
}

env.info("TCS(CATALOG_DATA): ready")