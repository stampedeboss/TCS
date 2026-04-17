---------------------------------------------------------------------
-- TCS AIRDEF: STRATEGIC POOLS
-- Fixed / Long-Range SAM Systems.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Towers = TCS.Towers or {}
TCS.Towers.AirDef = TCS.Towers.AirDef or {}
TCS.Towers.AirDef.Compositions = TCS.Towers.AirDef.Compositions or {}

TCS.Towers.AirDef.Compositions.Pools = {
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
            { category="LAUNCHER", role="LN", x=-60, y=0, hdg=0 },
            { category="SUPPORT", role="CP", x=-90, y=-20, hdg=90 },
            { category="FIXED_AAA", role="AAA", x=100, y=100, hdg=225 },
            { category="FIXED_AAA", role="AAA", x=-100, y=-100, hdg=45 }
        }},
        ["X"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="RD", x=10, y=10, hdg=0 },
            { category="LAUNCHER", role="LN", x=60, y=0, hdg=180 },
            { category="LAUNCHER", role="LN", x=-60, y=0, hdg=0 },
            { category="SUPPORT", role="CP", x=-90, y=-20, hdg=90 },
            { category="FIXED_AAA", role="AAA", x=100, y=100, hdg=225 },
            { category="FIXED_AAA", role="AAA", x=-100, y=-100, hdg=45 },
            { category="LAUNCHER", role="LN", x=1000, y=1000, sam_type="SA-15" },
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
            { category="SUPPORT", role="CP", x=-100, y=0, hdg=90 },
            { category="FIXED_AAA", role="AAA", x=150, y=0, hdg=270 }
        }},
        ["X"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="SR", x=-50, y=10, hdg=45 },
            { category="LAUNCHER", role="LN", x=60, y=60, hdg=225 },
            { category="LAUNCHER", role="LN", x=60, y=-60, hdg=315 },
            { category="LAUNCHER", role="LN", x=-60, y=-60, hdg=45 },
            { category="LAUNCHER", role="LN", x=-60, y=60, hdg=135 },
            { category="SUPPORT", role="CP", x=-100, y=0, hdg=90 },
            { category="FIXED_AAA", role="AAA", x=150, y=0, hdg=270 },
            { category="LAUNCHER", role="LN", x=1000, y=0, sam_type="SA-19" },
            { category="LAUNCHER", role="LN", x=-1000, y=0, sam_type="SA-19" }
        }}
    },
    ["SA-5"] = {
        ["A"] = { layout = { { category="RADAR", role="TR", x=0, y=0, hdg=0 }, { category="LAUNCHER", role="LN", x=200, y=0, hdg=0 } }},
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
            { category="SUPPORT", role="CP", x=-400, y=0, hdg=90 },
            { category="FIXED_AAA", role="AAA", x=700, y=700, hdg=225 }
        }},
        ["X"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="LAUNCHER", role="LN", x=500, y=0, hdg=0 },
            { category="LAUNCHER", role="LN", x=-500, y=0, hdg=180 },
            { category="RADAR", role="SR", x=-200, y=50, hdg=0 },
            { category="LAUNCHER", role="LN", x=250, y=433, hdg=300 },
            { category="LAUNCHER", role="LN", x=-250, y=433, hdg=240 },
            { category="LAUNCHER", role="LN", x=-250, y=-433, hdg=120 },
            { category="LAUNCHER", role="LN", x=250, y=-433, hdg=60 },
            { category="SUPPORT", role="CP", x=-400, y=0, hdg=90 },
            { category="FIXED_AAA", role="AAA", x=700, y=700, hdg=225 },
            { category="LAUNCHER", role="LN", x=1500, y=0, sam_type="SA-11" },
            { category="LAUNCHER", role="LN", x=-1500, y=0, sam_type="SA-11" },
            { category="RADAR", role="SR", x=2500, y=0, sam_type="ALL" }
        }}
    },
    ["SA-10"] = {
        ["A"] = { layout = { { category="RADAR", role="TR", x=0, y=0, hdg=0 }, { category="LAUNCHER", role="LN", x=100, y=100, hdg=225 } }},
        ["G"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="SR", x=-100, y=0, hdg=0 },
            { category="LAUNCHER", role="LN", x=200, y=200, hdg=225 },
            { category="LAUNCHER", role="LN", x=-200, y=-200, hdg=45 }
        }},
        ["H"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="SR", x=-100, y=0, hdg=0 },
            { category="SUPPORT", role="CP", x=50, y=50, hdg=0 },
            { category="LAUNCHER", role="LN", x=200, y=200, hdg=225 },
            { category="LAUNCHER", role="LN", x=-200, y=-200, hdg=45 },
            { category="FIXED_AAA", role="AAA", x=150, y=0, hdg=270 },
            { category="FIXED_AAA", role="AAA", x=-150, y=0, hdg=90 },
            { category="SUPPORT", role="PWR", x=80, y=-80, hdg=0 },
            { category="SUPPORT", role="FUEL", x=100, y=-80, hdg=0 }
        }},
        ["X"] = { layout = {
            { category="RADAR", role="TR", x=0, y=0, hdg=0 },
            { category="RADAR", role="SR", x=-150, y=0, hdg=0 },
            { category="SUPPORT", role="CP", x=50, y=50, hdg=0 },
            { category="LAUNCHER", role="LN", x=300, y=300, hdg=225 },
            { category="LAUNCHER", role="LN", x=300, y=-300, hdg=315 },
            { category="LAUNCHER", role="LN", x=-300, y=-300, hdg=45 },
            { category="LAUNCHER", role="LN", x=-300, y=300, hdg=135 },
            { category="FIXED_AAA", role="AAA", x=150, y=0, hdg=270 },
            { category="FIXED_AAA", role="AAA", x=-150, y=0, hdg=90 },
            { category="LAUNCHER", role="LN", x=1200, y=0, sam_type="SA-15" },
            { category="LAUNCHER", role="LN", x=-1200, y=0, sam_type="SA-15" }
        }}
    }
}

env.info("TCS(CONFIG.AIRDEF.POOLS): ready")