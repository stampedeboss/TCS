TCS = TCS or {}
TCS.Config = TCS.Config or {}
TCS.Config.Catalog = TCS.Config.Catalog or {}
TCS.Config.Catalog.A2G = TCS.Config.Catalog.A2G or {}

TCS.Config.Catalog.A2G.SHIP_CARGO  = {
  { id="drycargo1", domain="SEA", role="CARGO", unit_type="Dry-cargo ship-1", size=1, mobility="SHIP", threat_band="NONE", coalition="RED", first_service_year=1960 },
  { id="drycargo2", domain="SEA", role="CARGO", unit_type="Dry-cargo ship-2", size=1, mobility="SHIP", threat_band="NONE", coalition="RED", first_service_year=1960 },
  { id="handywind", domain="SEA", role="CARGO", unit_type="HandyWind", size=1, mobility="SHIP", threat_band="NONE", coalition="RED", first_service_year=2000 },
  { id="bulkcarrier", domain="SEA", role="CARGO", unit_type="Bulk Cargo Ship", size=1, mobility="SHIP", threat_band="NONE", coalition="RED", first_service_year=1970 },
}

TCS.Config.Catalog.A2G.SHIP_CORVETTE = {
  { id="molniya", domain="SEA", role="CORVETTE", unit_type="Molniya", size=1, mobility="SHIP", threat_band="MED", coalition="RED", first_service_year=1979 },
  { id="albatros", domain="SEA", role="CORVETTE", unit_type="Albatros", size=1, mobility="SHIP", threat_band="MED", coalition="RED", first_service_year=1970 },
  { id="s130", domain="SEA", role="CORVETTE", unit_type="S-130", size=1, mobility="SHIP", threat_band="LOW", coalition="RED", first_service_year=1943 },
  { id="lsclass", domain="SEA", role="CORVETTE", unit_type="LS_class", size=1, mobility="SHIP", threat_band="LOW", coalition="RED", first_service_year=1940 },
  { id="speedboat", domain="SEA", role="CORVETTE", unit_type="Speedboat", size=1, mobility="SHIP", threat_band="LOW", coalition="RED", first_service_year=1980 },
}

TCS.Config.Catalog.A2G.SHIP_FRIGATE = {
  { id="rezky", domain="SEA", role="FRIGATE", unit_type="Rezky", size=1, mobility="SHIP", threat_band="HIGH", coalition="RED", first_service_year=1970 },
  { id="neustrashimy", domain="SEA", role="FRIGATE", unit_type="Neustrashimy", size=1, mobility="SHIP", threat_band="HIGH", coalition="RED", first_service_year=1993 },
}

TCS.Config.Catalog.A2G.SHIP_DESTROYER = {
  { id="type052b", domain="SEA", role="DESTROYER", unit_type="Type_052B", size=1, mobility="SHIP", threat_band="HIGH", coalition="RED", first_service_year=2004 },
  { id="type052c", domain="SEA", role="DESTROYER", unit_type="Type_052C", size=1, mobility="SHIP", threat_band="HIGH", coalition="RED", first_service_year=2004 },
}

TCS.Config.Catalog.A2G.SHIP_CRUISER = {
  { id="moskva", domain="SEA", role="CRUISER", unit_type="Moskva", size=1, mobility="SHIP", threat_band="HIGH", coalition="RED", first_service_year=1982 },
  { id="pyotr", domain="SEA", role="CRUISER", unit_type="Pyotr Velikiy", size=1, mobility="SHIP", threat_band="HIGH", coalition="RED", first_service_year=1998 },
}

TCS.Config.Catalog.A2G.SHIP_CARRIER = {
  { id="kuznetsov", domain="SEA", role="CARRIER", unit_type="Kuznetsov", size=1, mobility="SHIP", threat_band="HIGH", coalition="RED", first_service_year=1991 },
}

TCS.Config.Catalog.A2G.SHIP_SUBMARINE = {
  { id="kilo", domain="SEA", role="SUBMARINE", unit_type="Kilo", size=1, mobility="SHIP", threat_band="HIGH", coalition="RED", first_service_year=1980 },
  { id="som", domain="SEA", role="SUBMARINE", unit_type="Som", size=1, mobility="SHIP", threat_band="HIGH", coalition="RED", first_service_year=1972 },
  { id="u73", domain="SEA", role="SUBMARINE", unit_type="U-73", size=1, mobility="SHIP", threat_band="MED", coalition="RED", first_service_year=1936 },
}

TCS.Config.Catalog.A2G.SHIP_AMPHIB = {
  { id="bdk775", domain="SEA", role="AMPHIB", unit_type="BDK-775", size=1, mobility="SHIP", threat_band="MED", coalition="RED", first_service_year=1975 },
}

TCS.Config.Catalog.A2G.SHIP_AMPHIB_BLUE = {
  { id="samuel_chase", domain="SEA", role="AMPHIB", unit_type="USS_Samuel_Chase", size=1, mobility="SHIP", threat_band="NONE", coalition="BLUE", first_service_year=1942 },
  { id="lst_mk2", domain="SEA", role="AMPHIB", unit_type="LST_Mk2", size=1, mobility="SHIP", threat_band="NONE", coalition="BLUE", first_service_year=1942 },
}

TCS.Config.Catalog.A2G.SHIP_DOCKED = {
  { id="drycargo1_dock", domain="SEA", role="CARGO", unit_type="Dry-cargo ship-1", size=1, mobility="STATIC", threat_band="NONE", coalition="RED", first_service_year=1960 },
  { id="tanker_dock", domain="SEA", role="CARGO", unit_type="Tanker", size=1, mobility="STATIC", threat_band="NONE", coalition="RED", first_service_year=1960 },
}

TCS.Config.Catalog.A2G.SHIP_CARRIER_BLUE = {
  { id="cvn_72", domain="SEA", role="CARRIER", unit_type="CVN_72", size=1, mobility="SHIP", threat_band="HIGH", coalition="BLUE", first_service_year=1989 },
  { id="stennis", domain="SEA", role="CARRIER", unit_type="Stennis", size=1, mobility="SHIP", threat_band="HIGH", coalition="BLUE", first_service_year=1995 },
  { id="forrestal", domain="SEA", role="CARRIER", unit_type="Forrestal", size=1, mobility="SHIP", threat_band="HIGH", coalition="BLUE", first_service_year=1955 },
}

TCS.Config.Catalog.A2G.SHIP_CRUISER_BLUE = {
  { id="ticonderoga", domain="SEA", role="CRUISER", unit_type="TICONDEROG", size=1, mobility="SHIP", threat_band="HIGH", coalition="BLUE", first_service_year=1983 },
  { id="north_carolina", domain="SEA", role="CRUISER", unit_type="USS_North_Carolina", size=1, mobility="SHIP", threat_band="HIGH", coalition="BLUE", first_service_year=1941 },
}

TCS.Config.Catalog.A2G.SHIP_DESTROYER_BLUE = {
  { id="arleigh_burke", domain="SEA", role="DESTROYER", unit_type="USS_Arleigh_Burke_IIa", size=1, mobility="SHIP", threat_band="HIGH", coalition="BLUE", first_service_year=2000 },
  { id="fletcher", domain="SEA", role="DESTROYER", unit_type="USS_Fletcher", size=1, mobility="SHIP", threat_band="MED", coalition="BLUE", first_service_year=1942 },
}

TCS.Config.Catalog.A2G.SHIP_FRIGATE_BLUE = {
  { id="perry", domain="SEA", role="FRIGATE", unit_type="PERRY", size=1, mobility="SHIP", threat_band="MED", coalition="BLUE", first_service_year=1977 },
}

TCS.Config.Catalog.A2G.SHIP_SUPPLY_BLUE = {
  { id="supply_ship_blue", domain="SEA", role="SUPPLY", unit_type="Ship_Tilde_Supply", size=1, mobility="SHIP", threat_band="NONE", coalition="BLUE", first_service_year=1980 },
}