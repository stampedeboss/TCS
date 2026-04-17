---------------------------------------------------------------------
-- TCS AIRDEF: MOBILE COMPOSITIONS
-- Tactical / Point-Defense SAM Systems.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.AirDef = TCS.Towers.AirDef or {}
TCS.Towers.AirDef.Compositions = TCS.Towers.AirDef.Compositions or {}

TCS.Towers.AirDef.Compositions.Mobile = {
    ["SA-6"] = {
        ["A"] = { layout = { { category="RADAR", role="TR", x=0, y=0, hdg=0 }, { category="LAUNCHER", role="LN", x=50, y=50, hdg=225 }, { category="LAUNCHER", role="LN", x=-50, y=-50, hdg=45 } }},
        ["G"] = { layout = { { category="RADAR", role="TR", x=0, y=0, hdg=0 }, { category="LAUNCHER", role="LN", x=50, y=50, hdg=225 }, { category="LAUNCHER", role="LN", x=50, y=-50, hdg=315 }, { category="LAUNCHER", role="LN", x=-50, y=-50, hdg=45 }, { category="LAUNCHER", role="LN", x=-50, y=50, hdg=135 } }},
        ["H"] = { layout = { 
            { category="RADAR",   role="TR",   x=0,   y=0,   hdg=0 }, 
            { category="LAUNCHER",role="LN",   x=2,   y=100, hdg=270 },
            { category="LAUNCHER",role="LN",   x=-4,  y=-102,hdg=90 },
            { category="LAUNCHER",role="LN",   x=-105,y=5,   hdg=0 },
            { category="LAUNCHER",role="LN",   x=99,  y=-3,  hdg=180 },
            { category="SUPPORT", role="FUEL", x=129, y=-104,hdg=133 },
            { category="SUPPORT", role="FUEL", x=120, y=-112,hdg=143 },
            { category="SUPPORT", role="PWR",  x=25,  y=25,  hdg=91 },
            { category="SUPPORT", role="UTIL", x=42,  y=-88, hdg=3 },
            { category="SUPPORT", role="UTIL", x=42,  y=-97, hdg=2 },
            { category="SUPPORT", role="CP",   x=22,  y=52,  hdg=91 },
            { category="FIXED_AAA",role="AAA", x=150, y=150, hdg=225 }
        }},
        ["X"] = { layout = { 
            { category="RADAR",   role="TR",   x=0,   y=0,   hdg=0 }, 
            { category="LAUNCHER",role="LN",   x=2,   y=100, hdg=270 },
            { category="LAUNCHER",role="LN",   x=-4,  y=-102,hdg=90 },
            { category="LAUNCHER",role="LN",   x=-105,y=5,   hdg=0 },
            { category="LAUNCHER",role="LN",   x=99,  y=-3,  hdg=180 },
            { category="SUPPORT", role="FUEL", x=129, y=-104,hdg=133 },
            { category="SUPPORT", role="PWR",  x=25,  y=25,  hdg=91 },
            { category="SUPPORT", role="CP",   x=22,  y=52,  hdg=91 },
            { category="LAUNCHER",role="LN",   x=800, y=800, sam_type="SA-22" } 
        }}
    },
    ["SA-11"] = {
        ["A"] = { layout = { { category="RADAR", role="SR", x=0, y=0, hdg=0 }, { category="LAUNCHER", role="LN", x=100, y=100, hdg=225 } }},
        ["G"] = { layout = { { category="RADAR", role="SR", x=0, y=0, hdg=0 }, { category="RADAR", role="TR", x=20, y=-20, hdg=0 }, { category="LAUNCHER", role="LN", x=100, y=100, hdg=225 }, { category="LAUNCHER", role="LN", x=-100, y=-100, hdg=45 } }},
        ["H"] = { layout = { 
            { category="RADAR", role="SR", x=0, y=0, hdg=0 }, 
            { category="RADAR", role="TR", x=20, y=-20, hdg=0 },
            { category="LAUNCHER", role="LN", x=150, y=150, hdg=225 },
            { category="LAUNCHER", role="LN", x=-150, y=-150, hdg=45 },
            { category="SUPPORT", role="CP", x=0, y=-200, hdg=0 },
            { category="FIXED_AAA", role="AAA", x=-100, y=200, hdg=0 }
        }},
        ["X"] = { layout = { 
            { category="RADAR", role="SR", x=0, y=0, hdg=0 }, 
            { category="RADAR", role="TR", x=20, y=-20, hdg=0 },
            { category="LAUNCHER", role="LN", x=150, y=150, hdg=225 },
            { category="LAUNCHER", role="LN", x=-150, y=-150, hdg=45 },
            { category="SUPPORT", role="CP", x=0, y=-200, hdg=0 },
            { category="LAUNCHER", role="LN", x=800, y=800, sam_type="SA-19" } 
        }}
    },
    ["SA-8"] = {
        ["A"] = { layout = { { category="LAUNCHER", role="LN", x=0, y=0, hdg=0 } } },
        ["G"] = { layout = { { category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { category="LAUNCHER", role="LN", x=100, y=50, hdg=45 } }},
        ["H"] = { layout = { { category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { category="LAUNCHER", role="LN", x=100, y=50, hdg=45 }, { category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { category="FIXED_AAA", role="AAA", x=0, y=100, hdg=0 } }},
        ["X"] = { layout = { { category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { category="RADAR", role="TR", x=2500, y=0, sam_type="SA-5" } }}
    },
    ["SA-9"] = {
        ["A"] = { layout = { { category="LAUNCHER", role="LN", x=0, y=0, hdg=0 } } },
        ["G"] = { layout = { { category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { category="LAUNCHER", role="LN", x=50, y=50, hdg=180 } }},
        ["H"] = { layout = { { category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { category="LAUNCHER", role="LN", x=50, y=50, hdg=180 }, { category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }},
        ["X"] = { layout = { { category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { category="RADAR", role="TR", x=1800, y=0, sam_type="SA-6" } }}
    },
    ["SA-15"] = {
        ["A"] = { layout = { { category="RADAR", role="TR", x=0, y=0, hdg=0 } } },
        ["G"] = { layout = { { category="RADAR", role="TR", x=0, y=0, hdg=0 }, { category="RADAR", role="TR", x=50, y=50, hdg=180 } }},
        ["H"] = { layout = { { category="RADAR", role="TR", x=0, y=0, hdg=0 }, { category="RADAR", role="TR", x=50, y=50, hdg=180 }, { category="SUPPORT", role="CP", x=-50, y=50, hdg=0 }, { category="FIXED_AAA", role="AAA", x=0, y=-50, hdg=0 } }},
        ["X"] = { layout = { { category="RADAR", role="TR", x=0, y=0, hdg=0 }, { category="SUPPORT", role="CP", x=-50, y=50, hdg=0 }, { category="RADAR", role="TR", x=2000, y=0, sam_type="SA-2" } }}
    },
    ["SA-19"] = {
        ["A"] = { layout = { { category="LAUNCHER", role="LN", x=0, y=0, hdg=0 } } },
        ["G"] = { layout = { { category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { category="LAUNCHER", role="LN", x=100, y=50, hdg=45 } }},
        ["H"] = { layout = { { category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { category="LAUNCHER", role="LN", x=100, y=50, hdg=45 }, { category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { category="FIXED_AAA", role="AAA", x=50, y=-50, hdg=0 } }},
        ["X"] = { layout = { { category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { category="RADAR", role="TR", x=2500, y=0, sam_type="SA-5" } }}
    },
    ["SA-22"] = {
        ["A"] = { layout = { { category="RADAR", role="TR", x=0, y=0, hdg=0 } } },
        ["G"] = { layout = { { category="RADAR", role="TR", x=0, y=0, hdg=0 }, { category="RADAR", role="TR", x=50, y=0, hdg=180 } } },
        ["H"] = { layout = { { category="RADAR", role="TR", x=0, y=0, hdg=0 }, { category="RADAR", role="TR", x=50, y=0, hdg=180 }, { category="SUPPORT", role="CP", x=0, y=-50, hdg=0 }, { category="FIXED_AAA", role="AAA", x=-50, y=0, hdg=0 } }},
        ["X"] = { layout = { { category="RADAR", role="TR", x=0, y=0, hdg=0 }, { category="SUPPORT", role="CP", x=0, y=-50, hdg=0 }, { category="RADAR", role="TR", x=2500, y=0, sam_type="SA-10" } }}
    }
}

env.info("TCS(CONFIG.AIRDEF.MOBILE): ready")