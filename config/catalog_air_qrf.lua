TCS = TCS or {}
TCS.Config = TCS.Config or {}
TCS.Config.Catalog = TCS.Config.Catalog or {}
TCS.Config.Catalog.A2G = TCS.Config.Catalog.A2G or {}

TCS.Config.Catalog.A2G.HELO = {
  { id="ka50", domain="AIR", role="ATTACK_HELO", unit_type="Ka-50", size=1, mobility="AIR", threat_band="HIGH", coalition="RED", first_service_year=1995 },
  { id="mi24v", domain="AIR", role="ATTACK_HELO", unit_type="Mi-24V", size=1, mobility="AIR", threat_band="MED", coalition="RED", first_service_year=1976 },
  { id="ah64d", domain="AIR", role="ATTACK_HELO", unit_type="AH-64D_BLK_II", size=1, mobility="AIR", threat_band="HIGH", coalition="BLUE", first_service_year=2003 },
}

TCS.Config.Catalog.A2G.CAS = {
  { id="su25t", domain="AIR", role="CAS", unit_type="Su-25T", size=1, mobility="AIR", threat_band="MED", coalition="RED", speed_class="FAST", first_service_year=1996 },
  { id="su25", domain="AIR", role="CAS", unit_type="Su-25", size=1, mobility="AIR", threat_band="MED", coalition="RED", speed_class="FAST", first_service_year=1981 },
  { id="a10c", domain="AIR", role="CAS", unit_type="A-10C_2", size=1, mobility="AIR", threat_band="HIGH", coalition="BLUE", speed_class="FAST", first_service_year=2005 },
}

TCS.Config.Catalog.A2G.CV_CAS = {
  { id="su33", domain="AIR", role="CAS", unit_type="Su-33", size=1, mobility="AIR", threat_band="HIGH", coalition="RED", speed_class="FAST", first_service_year=1998 },
  { id="fa18c", domain="AIR", role="CAS", unit_type="FA-18C_hornet", size=1, mobility="AIR", threat_band="HIGH", coalition="BLUE", speed_class="FAST", first_service_year=1987 },
}