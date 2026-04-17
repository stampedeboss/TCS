---------------------------------------------------------------------
-- TCS TOWER: AIRDEF COMPOSITIONS
-- Defines tiered doctrinal layouts for DSAM structures.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.AirDef = TCS.Towers.AirDef or {}
TCS.Towers.AirDef.Compositions = {}

TCS.Towers.AirDef.Compositions.Batteries = {
    ["SA-2"] = {
        ["A"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="RD", x=10, y=10, hdg=0 },
            { category="RADAR", role="SR", x=-80, y=20, hdg=0 },
            { category="LAUNCHER", role="LN", x=60, y=0, hdg=180 },
            { category="LAUNCHER", role="LN", x=-60, y=0, hdg=0 }
        }},
        ["G"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="RD", x=10, y=10, hdg=0 },
            { category="RADAR", role="SR", x=-80, y=20, hdg=0 },
            { category="LAUNCHER", role="LN", x=60, y=0, hdg=180 },
            { category="LAUNCHER", role="LN", x=30, y=52, hdg=240 },
            { category="LAUNCHER", role="LN", x=-30, y=52, hdg=300 },
            { category="LAUNCHER", role="LN", x=-60, y=0, hdg=0 },
            { category="LAUNCHER", role="LN", x=-30, y=-52, hdg=60 },
            { category="LAUNCHER", role="LN", x=30, y=-52, hdg=120 }
        }},
        ["H"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="RD", x=10, y=10, hdg=0 },
            { category="RADAR", role="SR", x=-80, y=20, hdg=0 },
            { category="LAUNCHER", role="LN", x=60, y=0, hdg=180 },
            { category="LAUNCHER", role="LN", x=30, y=52, hdg=240 },
            { category="LAUNCHER", role="LN", x=-30, y=52, hdg=300 },
            { category="LAUNCHER", role="LN", x=-60, y=0, hdg=0 },
            { category="LAUNCHER", role="LN", x=-30, y=-52, hdg=60 },
            { category="LAUNCHER", role="LN", x=30, y=-52, hdg=120 },
            { category="SUPPORT", role="CP", x=-90, y=-20, hdg=90 },
            { category="FIXED_AAA", role="AAA", x=100, y=100, hdg=225 },
            { category="FIXED_AAA", role="AAA", x=-100, y=-100, hdg=45 }
        }},
        ["X"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="RD", x=10, y=10, hdg=0 },
            { category="RADAR", role="SR", x=-80, y=20, hdg=0 },
            { category="LAUNCHER", role="LN", x=60, y=0, hdg=180 },
            { category="LAUNCHER", role="LN", x=-60, y=0, hdg=0 },
            { category="SUPPORT", role="CP", x=-90, y=-20, hdg=90 },
            { category="FIXED_AAA", role="AAA", x=100, y=100, hdg=225 },
            { category="LAUNCHER", role="LN", x=1000, y=1000, sam_type="SA-15" }, -- Layered SHORAD offset
            { category="LAUNCHER", role="LN", x=-1000, y=-1000, sam_type="SA-15" }
        }}
    },
    ["SA-3"] = {
        ["A"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="SR", x=-50, y=10, hdg=45 },
            { category="LAUNCHER", role="LN", x=50, y=50, hdg=225 },
            { category="LAUNCHER", role="LN", x=-50, y=-50, hdg=45 }
        }},
        ["G"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="SR", x=-50, y=10, hdg=45 },
            { category="LAUNCHER", role="LN", x=60, y=60, hdg=225 },
            { category="LAUNCHER", role="LN", x=60, y=-60, hdg=315 },
            { category="LAUNCHER", role="LN", x=-60, y=-60, hdg=45 },
            { category="LAUNCHER", role="LN", x=-60, y=60, hdg=135 }
        }},
        ["H"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="SR", x=-50, y=10, hdg=45 },
            { category="LAUNCHER", role="LN", x=60, y=60, hdg=225 },
            { category="LAUNCHER", role="LN", x=60, y=-60, hdg=315 },
            { category="LAUNCHER", role="LN", x=-60, y=-60, hdg=45 },
            { category="LAUNCHER", role="LN", x=-60, y=60, hdg=135 },
            { category="SUPPORT", role="CP", x=-80, y=0, hdg=90 },
            { category="FIXED_AAA", role="AAA", x=120, y=0, hdg=270 }
        }},
        ["X"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="LAUNCHER", role="LN", x=60, y=60, hdg=225 },
            { category="LAUNCHER", role="LN", x=-60, y=-60, hdg=45 },
            { category="LAUNCHER", role="LN", x=800, y=0, sam_type="SA-15" } -- Layered Tor
        }}
    },
    ["SA-6"] = {
        ["A"] = { layout = {
            { category="RADAR",    role="TR", x=0,   y=0,   hdg=0 },
            { category="LAUNCHER", role="LN", x=50,  y=50,  hdg=225 },
            { category="LAUNCHER", role="LN", x=-50, y=-50, hdg=45 }
        }},
        ["G"] = { layout = {
            { category="RADAR",    role="TR", x=0,   y=0,   hdg=0 },
            { category="LAUNCHER", role="LN", x=50,  y=50,  hdg=225 },
            { category="LAUNCHER", role="LN", x=50,  y=-50, hdg=315 },
            { category="LAUNCHER", role="LN", x=-50, y=-50, hdg=45 },
            { category="LAUNCHER", role="LN", x=-50, y=50,  hdg=135 }
        }},
        ["H"] = { layout = {
            { category="RADAR",    role="TR", x=0,   y=0,   hdg=0 },
            { category="LAUNCHER", role="LN", x=50,  y=50,  hdg=225 },
            { category="LAUNCHER", role="LN", x=-50, y=-50, hdg=45 },
            { category="SUPPORT", role="CP", x=-100, y=0,   hdg=90 }
        }},
        ["X"] = { layout = {
            { category="RADAR",    role="TR", x=0,   y=0,   hdg=0 },
            { category="LAUNCHER", role="LN", x=50,  y=50,  hdg=225 },
            { category="LAUNCHER", role="LN", x=-50, y=-50, hdg=45 },
            { category="LAUNCHER", role="LN", x=600, y=600, sam_type="SA-22" } -- Layered Pantsir
        }},
        ["X"] = { layout = {
            { category="RADAR",    role="TR", x=0,   y=0,   hdg=0 },
            { category="LAUNCHER", role="LN", x=50,  y=50,  hdg=225 },
            { category="LAUNCHER", role="LN", x=-50, y=-50, hdg=45 },
            { category="LAUNCHER", role="LN", x=600, y=600, sam_type="SA-22" } -- Layered Pantsir
        }}
    },
    ["SA-5"] = {
        ["A"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="LAUNCHER", role="LN", x=200, y=0, hdg=0 }
        }},
        ["G"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="SR", x=-200, y=50, hdg=0 },
            { category="LAUNCHER", role="LN", x=500, y=0, hdg=0 },
            { category="LAUNCHER", role="LN", x=-500, y=0, hdg=180 }
        }},
        ["H"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="SR", x=-200, y=50, hdg=0 },
            { category="LAUNCHER", role="LN", x=500, y=0, hdg=0 },
            { category="LAUNCHER", role="LN", x=250, y=433, hdg=300 },
            { category="LAUNCHER", role="LN", x=-250, y=433, hdg=240 },
            { category="LAUNCHER", role="LN", x=-500, y=0, hdg=180 },
            { category="LAUNCHER", role="LN", x=-250, y=-433, hdg=120 },
            { category="LAUNCHER", role="LN", x=250, y=-433, hdg=60 },
            { category="SUPPORT", role="CP", x=-300, y=0, hdg=90 },
            { category="FIXED_AAA", role="AAA", x=600, y=600, hdg=225 }
        }},
        ["X"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="SR", x=-200, y=50, hdg=0 },
            { category="LAUNCHER", role="LN", x=500, y=0, hdg=0 },
            { category="LAUNCHER", role="LN", x=-500, y=0, hdg=180 },
            { category="SUPPORT", role="CP", x=-300, y=0, hdg=90 },
            { category="LAUNCHER", role="LN", x=1200, y=0, sam_type="SA-11" }, -- Layered Buk
            { category="LAUNCHER", role="LN", x=-1200, y=0, sam_type="SA-11" }
        }}
    },
    ["SA-15"] = {
        ["A"] = { layout = { { category="RADAR", role="TR", x=0, y=0, hdg=0 } } },
        ["G"] = { layout = { 
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="TR", x=50, y=50, hdg=180 } 
        ["H"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="TR", x=50, y=50, hdg=180 },
            { category="FIXED_AAA", role="AAA", x=-50, y=50, hdg=0 }
        }},
        ["X"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="TR", x=50, y=50, hdg=180 },
            { category="RADAR", role="TR", x=1500, y=0, sam_type="SA-2" } -- Layered Strategic
        }}
    },
    ["SA-22"] = {
        ["A"] = { layout = { { category="RADAR", role="TR", x=0, y=0, hdg=0 } } },
        ["G"] = { layout = { { category="RADAR", role="TR", x=0, y=0, hdg=0 } } },
        ["H"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="TR", x=100, y=0, hdg=180 },
            { category="SUPPORT", role="CP", x=0, y=-50, hdg=0 }
        }},
        ["X"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="TR", x=100, y=0, hdg=180 },
            { category="RADAR", role="TR", x=2000, y=0, sam_type="SA-10" } -- Protected S-300
        }}
    },
    ["SA-10"] = {
        ["A"] = { layout = { { category="RADAR", role="TR", x=0, y=0, hdg=0 }, { category="LAUNCHER", role="LN", x=100, y=100, hdg=225 } } },
        ["G"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="SR", x=-100, y=0, hdg=0 },
            { category="LAUNCHER", role="LN", x=200, y=200, hdg=225 },
            { category="LAUNCHER", role="LN", x=-200, y=-200, hdg=45 }
        }},
        ["H"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="SR", x=-100, y=0, hdg=0 },
            { category="LAUNCHER", role="LN", x=200, y=200, hdg=225 },
            { category="LAUNCHER", role="LN", x=-200, y=-200, hdg=45 },
            { category="SUPPORT", role="CP", x=0, y=-100, hdg=0 },
            { category="FIXED_AAA", role="AAA", x=150, y=0, hdg=270 }
        }},
        ["X"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="SR", x=-150, y=0, hdg=0 },
            { category="LAUNCHER", role="LN", x=300, y=300, hdg=225 },
            { category="LAUNCHER", role="LN", x=300, y=-300, hdg=315 },
            { category="LAUNCHER", role="LN", x=-300, y=-300, hdg=45 },
            { category="LAUNCHER", role="LN", x=-300, y=300, hdg=135 },
            { category="LAUNCHER", role="LN", x=425, y=0, hdg=270 },
            { category="LAUNCHER", role="LN", x=-425, y=0, hdg=90 }
        }}
    },
    ["SA-11"] = {
        ["A"] = { layout = { { category="RADAR", role="SR", x=0, y=0, hdg=0 }, { category="LAUNCHER", role="LN", x=100, y=100, hdg=225 } } },
        ["G"] = { layout = {
            { category="RADAR", role="SR", x=0, y=0, hdg=0 },
            { category="RADAR", role="TR", x=20, y=-20, hdg=0 }, -- CP
            { category="LAUNCHER", role="LN", x=100, y=100, hdg=225 },
            { category="LAUNCHER", role="LN", x=-100, y=-100, hdg=45 }
        }},
        ["H"] = { layout = {
            { category="RADAR", role="SR", x=0, y=0, hdg=0 },
            { category="RADAR", role="TR", x=20, y=-20, hdg=0 },
            { category="LAUNCHER", role="LN", x=150, y=150, hdg=225 },
            { category="LAUNCHER", role="LN", x=150, y=-150, hdg=315 },
            { category="LAUNCHER", role="LN", x=-150, y=-150, hdg=45 },
            { category="LAUNCHER", role="LN", x=-150, y=150, hdg=135 }
        }},
        ["H"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="SR", x=-50, y=10, hdg=45 },
            { category="LAUNCHER", role="LN", x=60, y=60, hdg=225 },
            { category="LAUNCHER", role="LN", x=60, y=-60, hdg=315 },
            { category="LAUNCHER", role="LN", x=-60, y=-60, hdg=45 },
            { category="LAUNCHER", role="LN", x=-60, y=60, hdg=135 },
            { category="SUPPORT", role="CP", x=-80, y=0, hdg=90 },
            { category="FIXED_AAA", role="AAA", x=120, y=0, hdg=270 }
        }},
        ["X"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="LAUNCHER", role="LN", x=60, y=60, hdg=225 },
            { category="LAUNCHER", role="LN", x=-60, y=-60, hdg=45 },
            { category="LAUNCHER", role="LN", x=800, y=0, sam_type="SA-19" } -- Layered Tunguska
        }},
        ["X"] = { layout = {
            { category="RADAR", role="SR", x=0, y=0, hdg=0 },
            { category="RADAR", role="TR", x=20, y=-20, hdg=0 },
            { category="LAUNCHER", role="LN", x=150, y=150, hdg=225 },
            { category="LAUNCHER", role="LN", x=-150, y=-150, hdg=45 },
            { category="LAUNCHER", role="LN", x=600, y=600, sam_type="SA-19" } -- Layered Tunguska
        }}
    },
    ["SA-8"] = {
        ["A"] = { layout = { { category="LAUNCHER", role="LN", x=0, y=0, hdg=0 } } },
        ["G"] = { layout = { 
            { category="LAUNCHER", role="LN", x=0, y=0, hdg=0 },
            { category="LAUNCHER", role="LN", x=100, y=50, hdg=45 } 
        }},
        ["X"] = { layout = {
            { category="LAUNCHER", role="LN", x=0, y=0, hdg=0 },
            { category="RADAR", role="TR", x=2000, y=0, sam_type="SA-5" } -- Protected Strategic
        }}
    },
    ["SA-9"] = {
        ["A"] = { layout = { { category="LAUNCHER", role="LN", x=0, y=0, hdg=0 } } },
        ["G"] = { layout = { 
            { category="LAUNCHER", role="LN", x=0, y=0, hdg=0 },
            { category="LAUNCHER", role="LN", x=50, y=50, hdg=180 } 
        }}
    },
    ["SA-15"] = {
        ["A"] = { layout = { { category="RADAR", role="TR", x=0, y=0, hdg=0 } } },
        ["G"] = { layout = { 
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="TR", x=50, y=50, hdg=180 } 
        }},
        ["X"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="TR", x=50, y=50, hdg=180 },
            { category="RADAR", role="TR", x=1500, y=0, sam_type="SA-2" } -- Layered Long Range offset
        }}
    },
    ["SA-19"] = {
        ["G"] = { layout = { { category="LAUNCHER", role="LN", x=0, y=0, hdg=0 } } },
        ["G"] = { layout = { { category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { category="LAUNCHER", role="LN", x=100, y=50, hdg=45 } }},
        ["X"] = { layout = {
            { category="LAUNCHER", role="LN", x=0, y=0, hdg=0 },
            { category="RADAR", role="TR", x=2000, y=0, sam_type="SA-5" } -- Layered Long Range offset
        }}
    }
}

--- Returns the tiered layout for a specific SAM type.
function TCS.Towers.AirDef.GetBattery(type, tier)
    local site = TCS.Towers.AirDef.Compositions.Batteries[type or "SA-6"]
    if not site then return nil end
    
    -- Fallback logic: exact tier -> standard tier (G) -> first available
    return site[tier or "G"] or site["G"] or site[next(site)]
end

env.info("TCS(TOWER.AIRDEF.COMPOSITIONS): ready")