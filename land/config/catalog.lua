TCS = TCS or {}
TCS.Config = TCS.Config or {}

-- This is an example catalog. The user should populate this with their desired units.
TCS.Config.LandCatalog = {
    -- REDFOR
    ["Infantry AK"]         = { service_date = 1949, role = "INFANTRY", coalition = "RED" },
    ["Paratrooper RPG-16"]  = { service_date = 1970, role = "INFANTRY", coalition = "RED" },
    ["Paratrooper AKS-74"]  = { service_date = 1974, role = "INFANTRY", coalition = "RED" },
    ["T-55"]                = { service_date = 1958, role = "ARMOR", coalition = "RED" },
    ["T-72B"]               = { service_date = 1985, role = "ARMOR", coalition = "RED" },
    ["BMP-1"]               = { service_date = 1966, role = "ARMOR", coalition = "RED" },
    ["BMP-2"]               = { service_date = 1980, role = "ARMOR", coalition = "RED" },
    ["BTR-80"]              = { service_date = 1984, role = "ARMOR", coalition = "RED" },
    ["ZSU-23-4 Shilka"]     = { service_date = 1965, role = "AIRDEF", coalition = "RED" },
    ["SA-18 Igla manpad"]   = { service_date = 1983, role = "AIRDEF", coalition = "RED" },
    ["ZSU-57-2"]            = { service_date = 1955, role = "AIRDEF", coalition = "RED" },
    ["Ural-375"]            = { service_date = 1961, role = "TRANSPORT", coalition = "RED" },
    ["KAMAZ Truck"]         = { service_date = 1976, role = "TRANSPORT", coalition = "RED" },
    ["UAZ-469"]             = { service_date = 1971, role = "TRANSPORT", coalition = "RED" },
    ["BRDM-2"]              = { service_date = 1962, role = "RECON", coalition = "RED" },
    ["Uaz-469 DShK"]        = { service_date = 1971, role = "RECON", coalition = "RED" },
    ["ZIL-135"]             = { service_date = 1966, role = "TRANSPORT", coalition = "RED" },

    -- BLUEFOR
    ["Soldier M4"]          = { service_date = 1994, role = "INFANTRY", coalition = "BLUE" },
    ["Soldier M249"]        = { service_date = 1984, role = "INFANTRY", coalition = "BLUE" },
    ["Soldier stinger"]     = { service_date = 1981, role = "INFANTRY", coalition = "BLUE" },
    ["M1A2 Abrams"]         = { service_date = 1992, role = "ARMOR", coalition = "BLUE" },
    ["M-2 Bradley"]         = { service_date = 1981, role = "ARMOR", coalition = "BLUE" },
    ["LAV-25"]              = { service_date = 1983, role = "ARMOR", coalition = "BLUE" },
    ["M6 Linebacker"]       = { service_date = 1997, role = "AIRDEF", coalition = "BLUE" },
    ["M1097 Avenger"]       = { service_date = 1989, role = "AIRDEF", coalition = "BLUE" },
    ["Vulcan"]              = { service_date = 1968, role = "AIRDEF", coalition = "BLUE" },
    ["M1025 HMMWV"]         = { service_date = 1984, role = "TRANSPORT", coalition = "BLUE" },
    ["M 818"]               = { service_date = 1970, role = "TRANSPORT", coalition = "BLUE" },
    ["M1126 Stryker ICV"]   = { service_date = 2002, role = "RECON", coalition = "BLUE" },
    ["M1043 HMMWV Armament"]= { service_date = 1996, role = "RECON", coalition = "BLUE" },
}

env.info("TCS(LAND.CONFIG.CATALOG): loaded")