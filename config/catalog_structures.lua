TCS = TCS or {}
TCS.Config = TCS.Config or {}
TCS.Config.Catalog = TCS.Config.Catalog or {}
TCS.Config.Catalog.A2G = TCS.Config.Catalog.A2G or {}

TCS.Config.Catalog.A2G.STRUCTURE = {
  { id="bunker", domain="LAND", role="FORTIFICATION", unit_type="Bunker", size=1, mobility="STATIC", threat_band="NONE", coalition="RED", first_service_year=1940 },
  { id="outpost", domain="LAND", role="FORTIFICATION", unit_type="Outpost", size=1, mobility="STATIC", threat_band="NONE", coalition="RED", first_service_year=1950 },
  { id="house_armed", domain="LAND", role="FORTIFICATION", unit_type="Armed House", size=1, mobility="STATIC", threat_band="NONE", coalition="RED", first_service_year=1900 },
  { id="container_red1", domain="LAND", role="FORTIFICATION", unit_type="Container Red 1", size=1, mobility="STATIC", threat_band="NONE", coalition="RED", first_service_year=1956 },
  { id="container_red2", domain="LAND", role="FORTIFICATION", unit_type="Container Red 2", size=1, mobility="STATIC", threat_band="NONE", coalition="RED", first_service_year=1956 },
  { id="container_red3", domain="LAND", role="FORTIFICATION", unit_type="Container Red 3", size=1, mobility="STATIC", threat_band="NONE", coalition="RED", first_service_year=1956 },
  { id="wwii_fortification", domain="LAND", role="FORTIFICATION", unit_type="Fortification", size=1, mobility="STATIC", threat_band="NONE", coalition="RED", first_service_year=1942 },
  { id="coastal_fortification", domain="LAND", role="FORTIFICATION", unit_type="Fortification", size=1, mobility="STATIC", threat_band="NONE", coalition="RED", first_service_year=1943 },
}

TCS.Config.Catalog.A2G.RANGE_476 = {
  { id="476_circ_75", domain="LAND", role="RANGE_TARGET", unit_type="476_Target_Circle_75", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
  { id="476_circ_150", domain="LAND", role="RANGE_TARGET", unit_type="476_Target_Circle_150", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
  { id="476_sq_75", domain="LAND", role="RANGE_TARGET", unit_type="476_Target_Square_75", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
  { id="476_sq_150", domain="LAND", role="RANGE_TARGET", unit_type="476_Target_Square_150", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
  { id="476_hard_1", domain="LAND", role="RANGE_TARGET", unit_type="476_Target_Hard_1", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
  { id="476_conex", domain="LAND", role="RANGE_TARGET", unit_type="476_Conex_Box_White", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
  { id="476_truck", domain="LAND", role="RANGE_TARGET", unit_type="476_Target_Truck", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
  { id="476_apc", domain="LAND", role="RANGE_TARGET", unit_type="476_Target_APC", size=1, mobility="STATIC", threat_band="NONE", coalition="RED" },
}