---------------------------------------------------------------------
-- TCS LOGISTICS TOWER: MENU CONFIGURATION
-- Defines dynamic logistics, transport, and resupply tasks.
---------------------------------------------------------------------
env.info("TCS(LOGISTICS.MENU_CONFIG): loading")

TCS = TCS or {}
TCS.Logistics = TCS.Logistics or {}
TCS.Logistics.MenuConfig = {
    TRANSPORT = {
        { label = "Troop Insertion (10-20 NM)",  minNm = 10, maxNm = 20, payload = "TROOPS" },
        { label = "Cargo Airlift (20-40 NM)",    minNm = 20, maxNm = 40, payload = "CARGO" }
    },
    RESUPPLY = {
        { label = "Ground Convoy (5-15 NM)",     minNm = 5,  maxNm = 15, payload = "SUPPLIES" },
        { label = "FARP Setup (15-25 NM)",       minNm = 15, maxNm = 25, payload = "FARP" }
    }
}

env.info("TCS(LOGISTICS.MENU_CONFIG): ready")