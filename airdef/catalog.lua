TCS = TCS or {}
TCS.AirDef = TCS.AirDef or {}

-- Unified System Roster & Doctrinal Layouts
TCS.AirDef.Catalog = {
    -- REDFOR
    ["SA-2"] = { 
        service_date = 1957, mobility = "FIXED", threat = "HIGH", range = 25, coalition = "RED",
        layouts = {
            ["A"] = { layout = { { unit_type="SNR_75V", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="p-19 s-125 sr", category="RADAR", role="RD", x=10, y=10, hdg=0 }, { unit_type="p-19 s-125 sr", category="RADAR", role="SR", x=-80, y=20, hdg=0 }, { unit_type="S_75M_Volhov", category="LAUNCHER", role="LN", x=60, y=0, hdg=180 }, { unit_type="S_75M_Volhov", category="LAUNCHER", role="LN", x=-60, y=0, hdg=0 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=100, y=100, hdg=225 } }},
            ["G"] = { layout = { { unit_type="SNR_75V", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="p-19 s-125 sr", category="RADAR", role="RD", x=10, y=10, hdg=0 }, { unit_type="p-19 s-125 sr", category="RADAR", role="SR", x=-80, y=20, hdg=0 }, { unit_type="S_75M_Volhov", category="LAUNCHER", role="LN", x=60, y=0, hdg=180 }, { unit_type="S_75M_Volhov", category="LAUNCHER", role="LN", x=30, y=52, hdg=240 }, { unit_type="S_75M_Volhov", category="LAUNCHER", role="LN", x=-30, y=52, hdg=300 }, { unit_type="S_75M_Volhov", category="LAUNCHER", role="LN", x=-60, y=0, hdg=0 }, { unit_type="S_75M_Volhov", category="LAUNCHER", role="LN", x=-30, y=-52, hdg=60 }, { unit_type="S_75M_Volhov", category="LAUNCHER", role="LN", x=30, y=-52, hdg=120 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=100, y=100, hdg=225 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=-100, y=-100, hdg=45 } }},
            ["H"] = { layout = { { unit_type="SNR_75V", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="p-19 s-125 sr", category="RADAR", role="RD", x=10, y=10, hdg=0 }, { unit_type="p-19 s-125 sr", category="RADAR", role="SR", x=-80, y=20, hdg=0 }, { unit_type="S_75M_Volhov", category="LAUNCHER", role="LN", x=60, y=0, hdg=180 }, { unit_type="S_75M_Volhov", category="LAUNCHER", role="LN", x=30, y=52, hdg=240 }, { unit_type="S_75M_Volhov", category="LAUNCHER", role="LN", x=-30, y=52, hdg=300 }, { unit_type="S_75M_Volhov", category="LAUNCHER", role="LN", x=-60, y=0, hdg=0 }, { unit_type="S_75M_Volhov", category="LAUNCHER", role="LN", x=-30, y=-52, hdg=60 }, { unit_type="S_75M_Volhov", category="LAUNCHER", role="LN", x=30, y=-52, hdg=120 }, { unit_type="SKP-11", category="SUPPORT", role="CP", x=-90, y=-20, hdg=90 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=100, y=100, hdg=225 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=-100, y=-100, hdg=45 } }},
            ["X"] = { layout = { { unit_type="SNR_75V", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="p-19 s-125 sr", category="RADAR", role="RD", x=10, y=10, hdg=0 }, { unit_type="p-19 s-125 sr", category="RADAR", role="SR", x=-80, y=20, hdg=0 }, { unit_type="S_75M_Volhov", category="LAUNCHER", role="LN", x=60, y=0, hdg=180 }, { unit_type="S_75M_Volhov", category="LAUNCHER", role="LN", x=-60, y=0, hdg=0 }, { unit_type="SKP-11", category="SUPPORT", role="CP", x=-90, y=-20, hdg=90 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=100, y=100, hdg=225 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=-100, y=-100, hdg=45 }, { unit_type="Tor 9A331", category="LAUNCHER", role="LN", x=1000, y=1000, sam_type="SA-15" }, { unit_type="Tor 9A331", category="LAUNCHER", role="LN", x=-1000, y=-1000, sam_type="SA-15" } }},
       }
    },
    ["SA-3"] = {
        service_date = 1961, mobility = "FIXED", threat = "MED", range = 15, coalition = "RED",
        layouts = {
            ["A"] = { layout = { { unit_type="snr s-125 tr", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="p-19 s-125 sr", category="RADAR", role="SR", x=-50, y=10, hdg=45 }, { unit_type="5p73 s-125 ln", category="LAUNCHER", role="LN", x=50, y=50, hdg=225 }, { unit_type="5p73 s-125 ln", category="LAUNCHER", role="LN", x=-50, y=-50, hdg=45 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=100, y=0, hdg=270 } }},
            ["G"] = { layout = { { unit_type="snr s-125 tr", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="p-19 s-125 sr", category="RADAR", role="SR", x=-50, y=10, hdg=45 }, { unit_type="5p73 s-125 ln", category="LAUNCHER", role="LN", x=60, y=60, hdg=225 }, { unit_type="5p73 s-125 ln", category="LAUNCHER", role="LN", x=60, y=-60, hdg=315 }, { unit_type="5p73 s-125 ln", category="LAUNCHER", role="LN", x=-60, y=-60, hdg=45 }, { unit_type="5p73 s-125 ln", category="LAUNCHER", role="LN", x=-60, y=60, hdg=135 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=100, y=0, hdg=270 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=-100, y=0, hdg=90 } }},
            ["H"] = { layout = { { unit_type="snr s-125 tr", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="p-19 s-125 sr", category="RADAR", role="SR", x=-50, y=10, hdg=45 }, { unit_type="5p73 s-125 ln", category="LAUNCHER", role="LN", x=60, y=60, hdg=225 }, { unit_type="5p73 s-125 ln", category="LAUNCHER", role="LN", x=60, y=-60, hdg=315 }, { unit_type="5p73 s-125 ln", category="LAUNCHER", role="LN", x=-60, y=-60, hdg=45 }, { unit_type="5p73 s-125 ln", category="LAUNCHER", role="LN", x=-60, y=60, hdg=135 }, { unit_type="SKP-11", category="SUPPORT", role="CP", x=-100, y=0, hdg=90 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=150, y=0, hdg=270 } }},
            ["X"] = { layout = { { unit_type="snr s-125 tr", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="p-19 s-125 sr", category="RADAR", role="SR", x=-50, y=10, hdg=45 }, { unit_type="5p73 s-125 ln", category="LAUNCHER", role="LN", x=60, y=60, hdg=225 }, { unit_type="5p73 s-125 ln", category="LAUNCHER", role="LN", x=60, y=-60, hdg=315 }, { unit_type="5p73 s-125 ln", category="LAUNCHER", role="LN", x=-60, y=-60, hdg=45 }, { unit_type="5p73 s-125 ln", category="LAUNCHER", role="LN", x=-60, y=60, hdg=135 }, { unit_type="SKP-11", category="SUPPORT", role="CP", x=-100, y=0, hdg=90 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=150, y=0, hdg=270 }, { unit_type="2S6 Tunguska", category="LAUNCHER", role="LN", x=1000, y=0, sam_type="SA-19" }, { unit_type="2S6 Tunguska", category="LAUNCHER", role="LN", x=-1000, y=0, sam_type="SA-19" } }}
        }
    },
    ["SA-5"] = {
        service_date = 1967, mobility = "FIXED", threat = "HIGH", range = 150, coalition = "RED",
        layouts = {
            ["A"] = { layout = { { unit_type="RPC_5N62V", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="S-200_Launcher", category="LAUNCHER", role="LN", x=200, y=0, hdg=0 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=200, y=200, hdg=225 } }},
            ["G"] = { layout = { { unit_type="RPC_5N62V", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="p-19 s-125 sr", category="RADAR", role="SR", x=-200, y=50, hdg=0 }, { unit_type="S-200_Launcher", category="LAUNCHER", role="LN", x=500, y=0, hdg=0 }, { unit_type="S-200_Launcher", category="LAUNCHER", role="LN", x=-500, y=0, hdg=180 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=200, y=200, hdg=225 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=-200, y=-200, hdg=45 } }},
            ["H"] = { layout = { { unit_type="RPC_5N62V", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="p-19 s-125 sr", category="RADAR", role="SR", x=-200, y=50, hdg=0 }, { unit_type="S-200_Launcher", category="LAUNCHER", role="LN", x=500, y=0, hdg=0 }, { unit_type="S-200_Launcher", category="LAUNCHER", role="LN", x=250, y=433, hdg=300 }, { unit_type="S-200_Launcher", category="LAUNCHER", role="LN", x=-250, y=433, hdg=240 }, { unit_type="S-200_Launcher", category="LAUNCHER", role="LN", x=-500, y=0, hdg=180 }, { unit_type="S-200_Launcher", category="LAUNCHER", role="LN", x=-250, y=-433, hdg=120 }, { unit_type="S-200_Launcher", category="LAUNCHER", role="LN", x=250, y=-433, hdg=60 }, { unit_type="SKP-11", category="SUPPORT", role="CP", x=-400, y=0, hdg=90 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=700, y=700, hdg=225 } }},
            ["X"] = { layout = { { unit_type="RPC_5N62V", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="S-200_Launcher", category="LAUNCHER", role="LN", x=500, y=0, hdg=0 }, { unit_type="S-200_Launcher", category="LAUNCHER", role="LN", x=-500, y=0, hdg=180 }, { unit_type="p-19 s-125 sr", category="RADAR", role="SR", x=-200, y=50, hdg=0 }, { unit_type="S-200_Launcher", category="LAUNCHER", role="LN", x=250, y=433, hdg=300 }, { unit_type="S-200_Launcher", category="LAUNCHER", role="LN", x=-250, y=433, hdg=240 }, { unit_type="S-200_Launcher", category="LAUNCHER", role="LN", x=-250, y=-433, hdg=120 }, { unit_type="S-200_Launcher", category="LAUNCHER", role="LN", x=250, y=-433, hdg=60 }, { unit_type="SKP-11", category="SUPPORT", role="CP", x=-400, y=0, hdg=90 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=700, y=700, hdg=225 }, { unit_type="SA-11 Buk LN 9A310M1", category="LAUNCHER", role="LN", x=1500, y=0, sam_type="SA-11" }, { unit_type="SA-11 Buk LN 9A310M1", category="LAUNCHER", role="LN", x=-1500, y=0, sam_type="SA-11" }, { unit_type="p-19 s-125 sr", category="RADAR", role="SR", x=2500, y=0 } }}
        }
    },
    ["SA-6"] = {
        service_date = 1970, mobility = "MOBILE", threat = "HIGH", range = 15, coalition = "RED",
        layouts = {
            ["A"] = { layout = { { unit_type="Kub 1S91 str", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="Kub 2P25 ln", category="LAUNCHER", role="LN", x=50, y=50, hdg=225 }, { unit_type="Kub 2P25 ln", category="LAUNCHER", role="LN", x=-50, y=-50, hdg=45 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=100, y=100, hdg=225 } }},
            ["G"] = { layout = { { unit_type="Kub 1S91 str", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="Kub 2P25 ln", category="LAUNCHER", role="LN", x=50, y=50, hdg=225 }, { unit_type="Kub 2P25 ln", category="LAUNCHER", role="LN", x=50, y=-50, hdg=315 }, { unit_type="Kub 2P25 ln", category="LAUNCHER", role="LN", x=-50, y=-50, hdg=45 }, { unit_type="Kub 2P25 ln", category="LAUNCHER", role="LN", x=-50, y=50, hdg=135 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=100, y=100, hdg=225 } }},
            ["H"] = { layout = { { unit_type="Kub 1S91 str", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="Kub 2P25 ln", category="LAUNCHER", role="LN", x=2, y=100, hdg=270 }, { unit_type="Kub 2P25 ln", category="LAUNCHER", role="LN", x=-4, y=-102, hdg=90 }, { unit_type="Kub 2P25 ln", category="LAUNCHER", role="LN", x=-105, y=5, hdg=0 }, { unit_type="Kub 2P25 ln", category="LAUNCHER", role="LN", x=99, y=-3, hdg=180 }, { unit_type="ZIL-131 KUNG", category="SUPPORT", role="FUEL", x=129, y=-104, hdg=133 }, { unit_type="ZIL-131 KUNG", category="SUPPORT", role="FUEL", x=120, y=-112, hdg=143 }, { unit_type="ATMZ-5", category="SUPPORT", role="PWR", x=25, y=25, hdg=91 }, { unit_type="Ural-375", category="SUPPORT", role="UTIL", x=42, y=-88, hdg=3 }, { unit_type="Ural-375", category="SUPPORT", role="UTIL", x=42, y=-97, hdg=2 }, { unit_type="SKP-11", category="SUPPORT", role="CP", x=22, y=52, hdg=91 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=150, y=150, hdg=225 } }},
            ["X"] = { layout = { { unit_type="Kub 1S91 str", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="Kub 2P25 ln", category="LAUNCHER", role="LN", x=2, y=100, hdg=270 }, { unit_type="Kub 2P25 ln", category="LAUNCHER", role="LN", x=-4, y=-102, hdg=90 }, { unit_type="Kub 2P25 ln", category="LAUNCHER", role="LN", x=-105, y=5, hdg=0 }, { unit_type="Kub 2P25 ln", category="LAUNCHER", role="LN", x=99, y=-3, hdg=180 }, { unit_type="ZIL-131 KUNG", category="SUPPORT", role="FUEL", x=129, y=-104, hdg=133 }, { unit_type="ATMZ-5", category="SUPPORT", role="PWR", x=25, y=25, hdg=91 }, { unit_type="SKP-11", category="SUPPORT", role="CP", x=22, y=52, hdg=91 }, { unit_type="2S6 Tunguska", category="LAUNCHER", role="LN", x=800, y=800, sam_type="SA-19" }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=150, y=150, hdg=225 } }}
        }
    },
    ["SA-8"] = {
        service_date = 1971, mobility = "MOBILE", threat = "MED", range = 8, coalition = "RED",
        layouts = {
            ["A"] = { layout = { { unit_type="Osa 9A33 ln", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=0, y=100, hdg=0 } } },
            ["G"] = { layout = { { unit_type="Osa 9A33 ln", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="Osa 9A33 ln", category="LAUNCHER", role="LN", x=100, y=50, hdg=45 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=0, y=100, hdg=0 } }},
            ["H"] = { layout = { { unit_type="Osa 9A33 ln", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="Osa 9A33 ln", category="LAUNCHER", role="LN", x=100, y=50, hdg=45 }, { unit_type="BTR-80", category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=0, y=100, hdg=0 } }},
            ["X"] = { layout = { { unit_type="Osa 9A33 ln", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="BTR-80", category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { unit_type="Tor 9A331", category="LAUNCHER", role="LN", x=1000, y=0, sam_type="SA-15" }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=0, y=100, hdg=0 } }}
         }
    },
    ["SA-9"] = {
        service_date = 1972, mobility = "MOBILE", threat = "LOW", range = 4, coalition = "RED",
        layouts = {
            ["A"] = { layout = { { unit_type="Strela-1 9P31", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } } },
            ["G"] = { layout = { { unit_type="Strela-1 9P31", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="Strela-1 9P31", category="LAUNCHER", role="LN", x=50, y=50, hdg=180 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }},
            ["H"] = { layout = { { unit_type="Strela-1 9P31", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="Strela-1 9P31", category="LAUNCHER", role="LN", x=50, y=50, hdg=180 }, { unit_type="BTR-80", category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }},
            ["X"] = { layout = { { unit_type="Strela-1 9P31", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="BTR-80", category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { unit_type="2S6 Tunguska", category="LAUNCHER", role="LN", x=1000, y=0, sam_type="SA-19" }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }}
        }
    },
    ["SA-10"] = {
        service_date = 1980, mobility = "FIXED", threat = "HIGH", range = 45, coalition = "RED",
        layouts = {
            ["A"] = { layout = { { unit_type="S-300PS 40B6M tr", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="S-300PS 5P85C ln", category="LAUNCHER", role="LN", x=100, y=100, hdg=225 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=150, y=0, hdg=270 } }},
            ["G"] = { layout = { { unit_type="S-300PS 40B6M tr", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="S-300PS 64H6E sr", category="RADAR", role="SR", x=-100, y=0, hdg=0 }, { unit_type="S-300PS 5P85C ln", category="LAUNCHER", role="LN", x=200, y=200, hdg=225 }, { unit_type="S-300PS 5P85C ln", category="LAUNCHER", role="LN", x=-200, y=-200, hdg=45 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=150, y=0, hdg=270 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=-150, y=0, hdg=90 } }},
            ["H"] = { layout = { { unit_type="S-300PS 40B6M tr", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="S-300PS 64H6E sr", category="RADAR", role="SR", x=-100, y=0, hdg=0 }, { unit_type="S-300PS 54K6 cp", category="SUPPORT", role="CP", x=50, y=50, hdg=0 }, { unit_type="S-300PS 5P85C ln", category="LAUNCHER", role="LN", x=200, y=200, hdg=225 }, { unit_type="S-300PS 5P85C ln", category="LAUNCHER", role="LN", x=-200, y=-200, hdg=45 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=150, y=0, hdg=270 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=-150, y=0, hdg=90 }, { unit_type="ATMZ-5", category="SUPPORT", role="PWR", x=80, y=-80, hdg=0 }, { unit_type="ZIL-131 KUNG", category="SUPPORT", role="FUEL", x=100, y=-80, hdg=0 } }},
            ["X"] = { layout = { { unit_type="S-300PS 40B6M tr", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="S-300PS 64H6E sr", category="RADAR", role="SR", x=-150, y=0, hdg=0 }, { unit_type="S-300PS 54K6 cp", category="SUPPORT", role="CP", x=50, y=50, hdg=0 }, { unit_type="S-300PS 5P85C ln", category="LAUNCHER", role="LN", x=300, y=300, hdg=225 }, { unit_type="S-300PS 5P85C ln", category="LAUNCHER", role="LN", x=300, y=-300, hdg=315 }, { unit_type="S-300PS 5P85C ln", category="LAUNCHER", role="LN", x=-300, y=-300, hdg=45 }, { unit_type="S-300PS 5P85C ln", category="LAUNCHER", role="LN", x=-300, y=300, hdg=135 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=150, y=0, hdg=270 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=-150, y=0, hdg=90 }, { unit_type="Tor 9A331", category="LAUNCHER", role="LN", x=1200, y=0, sam_type="SA-15" }, { unit_type="Tor 9A331", category="LAUNCHER", role="LN", x=-1200, y=0, sam_type="SA-15" } }}
        }
    },
    ["SA-11"] = {
        service_date = 1979, mobility = "MOBILE", threat = "HIGH", range = 18, coalition = "RED",
        layouts = {
            ["A"] = { layout = { { unit_type="SA-11 Buk SR 9S18M1", category="RADAR", role="SR", x=0, y=0, hdg=0 }, { unit_type="SA-11 Buk LN 9A310M1", category="LAUNCHER", role="LN", x=100, y=100, hdg=225 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=-100, y=100, hdg=135 } }},
            ["G"] = { layout = { { unit_type="SA-11 Buk SR 9S18M1", category="RADAR", role="SR", x=0, y=0, hdg=0 }, { unit_type="SA-11 Buk CC 9S470M1", category="RADAR", role="TR", x=20, y=-20, hdg=0 }, { unit_type="SA-11 Buk LN 9A310M1", category="LAUNCHER", role="LN", x=100, y=100, hdg=225 }, { unit_type="SA-11 Buk LN 9A310M1", category="LAUNCHER", role="LN", x=-100, y=-100, hdg=45 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=-100, y=100, hdg=135 } }},
            ["H"] = { layout = { { unit_type="SA-11 Buk SR 9S18M1", category="RADAR", role="SR", x=0, y=0, hdg=0 }, { unit_type="SA-11 Buk CC 9S470M1", category="RADAR", role="TR", x=20, y=-20, hdg=0 }, { unit_type="SA-11 Buk LN 9A310M1", category="LAUNCHER", role="LN", x=150, y=150, hdg=225 }, { unit_type="SA-11 Buk LN 9A310M1", category="LAUNCHER", role="LN", x=-150, y=-150, hdg=45 }, { unit_type="SKP-11", category="SUPPORT", role="CP", x=0, y=-200, hdg=0 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=-100, y=200, hdg=0 } }},
            ["X"] = { layout = { { unit_type="SA-11 Buk SR 9S18M1", category="RADAR", role="SR", x=0, y=0, hdg=0 }, { unit_type="SA-11 Buk CC 9S470M1", category="RADAR", role="TR", x=20, y=-20, hdg=0 }, { unit_type="SA-11 Buk LN 9A310M1", category="LAUNCHER", role="LN", x=150, y=150, hdg=225 }, { unit_type="SA-11 Buk LN 9A310M1", category="LAUNCHER", role="LN", x=-150, y=-150, hdg=45 }, { unit_type="SKP-11", category="SUPPORT", role="CP", x=0, y=-200, hdg=0 }, { unit_type="2S6 Tunguska", category="LAUNCHER", role="LN", x=800, y=800, sam_type="SA-19" }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=-100, y=200, hdg=0 } }}
        }
    },
    ["SA-13"] = {
        service_date = 1975, mobility = "MOBILE", threat = "LOW", range = 3, coalition = "RED",
        layouts = {
            ["A"] = { layout = { { unit_type="Strela-10M3", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } } },
            ["G"] = { layout = { { unit_type="Strela-10M3", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="Strela-10M3", category="LAUNCHER", role="LN", x=50, y=50, hdg=180 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }},
            ["H"] = { layout = { { unit_type="Strela-10M3", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="Strela-10M3", category="LAUNCHER", role="LN", x=50, y=50, hdg=180 }, { unit_type="BTR-80", category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }},
            ["X"] = { layout = { { unit_type="Strela-10M3", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="BTR-80", category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { unit_type="2S6 Tunguska", category="LAUNCHER", role="LN", x=1000, y=0, sam_type="SA-19" }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }}
        }
    },
    ["SA-15"] = {
        service_date = 1986, mobility = "MOBILE", threat = "HIGH", range = 6, coalition = "RED",
        layouts = {
            ["A"] = { layout = { { unit_type="Tor 9A331", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=0, y=-50, hdg=0 } } },
            ["G"] = { layout = { { unit_type="Tor 9A331", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="Tor 9A331", category="LAUNCHER", role="LN", x=50, y=50, hdg=180 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=0, y=-50, hdg=0 } }},
            ["H"] = { layout = { { unit_type="Tor 9A331", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="Tor 9A331", category="LAUNCHER", role="LN", x=50, y=50, hdg=180 }, { unit_type="BTR-80", category="SUPPORT", role="CP", x=-50, y=50, hdg=0 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=0, y=-50, hdg=0 } }},
            ["X"] = { layout = { { unit_type="Tor 9A331", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="BTR-80", category="SUPPORT", role="CP", x=-50, y=50, hdg=0 }, { unit_type="2S6 Tunguska", category="LAUNCHER", role="LN", x=1000, y=0, sam_type="SA-19" }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=0, y=-50, hdg=0 } }}
        }
    },
    ["SA-19"] = {
        service_date = 1982, mobility = "MOBILE", threat = "HIGH", range = 6, coalition = "RED",
        layouts = {
            ["A"] = { layout = { { unit_type="2S6 Tunguska", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=50, y=-50, hdg=0 } } },
            ["G"] = { layout = { { unit_type="2S6 Tunguska", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="2S6 Tunguska", category="LAUNCHER", role="LN", x=100, y=50, hdg=45 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=50, y=-50, hdg=0 } }},
            ["H"] = { layout = { { unit_type="2S6 Tunguska", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="2S6 Tunguska", category="LAUNCHER", role="LN", x=100, y=50, hdg=45 }, { unit_type="BTR-80", category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=50, y=-50, hdg=0 } }},
            ["X"] = { layout = { { unit_type="2S6 Tunguska", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="BTR-80", category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { unit_type="Tor 9A331", category="LAUNCHER", role="LN", x=1000, y=0, sam_type="SA-15" }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=50, y=-50, hdg=0 } }}
        }
    },
    ["SA-22"] = {
        service_date = 2012, mobility = "MOBILE", threat = "HIGH", range = 10, coalition = "RED",
        layouts = {
            ["A"] = { layout = { { unit_type="2S6 Tunguska", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=-50, y=0, hdg=0 } } },
            ["G"] = { layout = { { unit_type="2S6 Tunguska", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="2S6 Tunguska", category="LAUNCHER", role="LN", x=50, y=0, hdg=180 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=-50, y=0, hdg=0 } } },
            ["H"] = { layout = { { unit_type="2S6 Tunguska", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="2S6 Tunguska", category="LAUNCHER", role="LN", x=50, y=0, hdg=180 }, { unit_type="BTR-80", category="SUPPORT", role="CP", x=0, y=-50, hdg=0 }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=-50, y=0, hdg=0 } }},
            ["X"] = { layout = { { unit_type="2S6 Tunguska", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="BTR-80", category="SUPPORT", role="CP", x=0, y=-50, hdg=0 }, { unit_type="Tor 9A331", category="LAUNCHER", role="LN", x=1000, y=0, sam_type="SA-15" }, { unit_type="ZU-23 Emplacement", category="FIXED_AAA", role="AAA", x=-50, y=0, hdg=0 } }}
        }
    },

    -- BLUEFOR
    ["Hawk"] = { 
        service_date = 1960, mobility = "FIXED", threat = "MED", range = 25, coalition = "BLUE",
        layouts = {
            ["A"] = { layout = { { unit_type="Hawk tr", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="Hawk ln", category="LAUNCHER", role="LN", x=60, y=60, hdg=225 }, { unit_type="Hawk ln", category="LAUNCHER", role="LN", x=-60, y=-60, hdg=45 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=100, y=0, hdg=270 } }},
            ["G"] = { layout = { { unit_type="Hawk tr", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="Hawk sr", category="RADAR", role="SR", x=-50, y=10, hdg=45 }, { unit_type="Hawk ln", category="LAUNCHER", role="LN", x=60, y=60, hdg=225 }, { unit_type="Hawk ln", category="LAUNCHER", role="LN", x=-60, y=-60, hdg=45 }, { unit_type="Hawk ln", category="LAUNCHER", role="LN", x=60, y=-60, hdg=315 }, { unit_type="Hawk ln", category="LAUNCHER", role="LN", x=-60, y=60, hdg=135 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=100, y=0, hdg=270 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=-100, y=0, hdg=90 } }},
            ["H"] = { layout = { { unit_type="Hawk tr", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="Hawk sr", category="RADAR", role="SR", x=-50, y=10, hdg=45 }, { unit_type="Hawk pcp", category="SUPPORT", role="CP", x=-100, y=0, hdg=90 }, { unit_type="Hawk ln", category="LAUNCHER", role="LN", x=60, y=60, hdg=225 }, { unit_type="Hawk ln", category="LAUNCHER", role="LN", x=-60, y=-60, hdg=45 }, { unit_type="Hawk ln", category="LAUNCHER", role="LN", x=60, y=-60, hdg=315 }, { unit_type="Hawk ln", category="LAUNCHER", role="LN", x=-60, y=60, hdg=135 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=100, y=0, hdg=270 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=-100, y=0, hdg=90 } }},
            ["X"] = { layout = { { unit_type="Hawk tr", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="Hawk sr", category="RADAR", role="SR", x=-50, y=10, hdg=45 }, { unit_type="Hawk pcp", category="SUPPORT", role="CP", x=-100, y=0, hdg=90 }, { unit_type="Hawk ln", category="LAUNCHER", role="LN", x=60, y=60, hdg=225 }, { unit_type="Hawk ln", category="LAUNCHER", role="LN", x=-60, y=-60, hdg=45 }, { unit_type="Hawk ln", category="LAUNCHER", role="LN", x=60, y=-60, hdg=315 }, { unit_type="Hawk ln", category="LAUNCHER", role="LN", x=-60, y=60, hdg=135 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=150, y=0, hdg=270 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=-100, y=0, hdg=90 } }}
        }
    },
    ["Patriot"] = {
        service_date = 1981, mobility = "FIXED", threat = "HIGH", range = 60, coalition = "BLUE",
        layouts = {
            ["A"] = { layout = { { unit_type="Patriot str", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="Patriot ln", category="LAUNCHER", role="LN", x=100, y=100, hdg=225 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=150, y=0, hdg=270 } }},
            ["G"] = { layout = { { unit_type="Patriot str", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="Patriot ln", category="LAUNCHER", role="LN", x=200, y=200, hdg=225 }, { unit_type="Patriot ln", category="LAUNCHER", role="LN", x=-200, y=-200, hdg=45 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=150, y=0, hdg=270 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=-150, y=0, hdg=90 } }},
            ["H"] = { layout = { { unit_type="Patriot str", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="Patriot cp", category="SUPPORT", role="CP", x=50, y=50, hdg=0 }, { unit_type="Patriot EPP", category="SUPPORT", role="PWR", x=80, y=-80, hdg=0 }, { unit_type="Patriot ln", category="LAUNCHER", role="LN", x=200, y=200, hdg=225 }, { unit_type="Patriot ln", category="LAUNCHER", role="LN", x=-200, y=-200, hdg=45 }, { unit_type="Patriot ln", category="LAUNCHER", role="LN", x=200, y=-200, hdg=315 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=150, y=0, hdg=270 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=-150, y=0, hdg=90 } }},
            ["X"] = { layout = { { unit_type="Patriot str", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="Patriot cp", category="SUPPORT", role="CP", x=50, y=50, hdg=0 }, { unit_type="Patriot EPP", category="SUPPORT", role="PWR", x=80, y=-80, hdg=0 }, { unit_type="Patriot ln", category="LAUNCHER", role="LN", x=300, y=300, hdg=225 }, { unit_type="Patriot ln", category="LAUNCHER", role="LN", x=-300, y=-300, hdg=45 }, { unit_type="Patriot ln", category="LAUNCHER", role="LN", x=300, y=-300, hdg=315 }, { unit_type="Patriot ln", category="LAUNCHER", role="LN", x=-300, y=300, hdg=135 }, { unit_type="M1097 Avenger", category="LAUNCHER", role="LN", x=1200, y=0, sam_type="M1097 Avenger" }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=150, y=0, hdg=270 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=-150, y=0, hdg=90 } }}
        }
    },
    ["NASAMS"] = {
        service_date = 1998, mobility = "FIXED", threat = "MED", range = 15, coalition = "BLUE",
        layouts = {
            ["A"] = { layout = { { unit_type="NASAMS_Radar_MPQ64F1", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="NASAMS_LN_B", category="LAUNCHER", role="LN", x=50, y=50, hdg=225 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=100, y=0, hdg=270 } }},
            ["G"] = { layout = { { unit_type="NASAMS_Radar_MPQ64F1", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="NASAMS_LN_B", category="LAUNCHER", role="LN", x=60, y=60, hdg=225 }, { unit_type="NASAMS_LN_B", category="LAUNCHER", role="LN", x=-60, y=-60, hdg=45 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=100, y=0, hdg=270 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=-100, y=0, hdg=90 } }},
            ["H"] = { layout = { { unit_type="NASAMS_Radar_MPQ64F1", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="NASAMS_Command_Post", category="SUPPORT", role="CP", x=-100, y=0, hdg=90 }, { unit_type="NASAMS_LN_B", category="LAUNCHER", role="LN", x=60, y=60, hdg=225 }, { unit_type="NASAMS_LN_B", category="LAUNCHER", role="LN", x=-60, y=-60, hdg=45 }, { unit_type="NASAMS_LN_B", category="LAUNCHER", role="LN", x=60, y=-60, hdg=315 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=100, y=0, hdg=270 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=-100, y=0, hdg=90 } }},
            ["X"] = { layout = { { unit_type="NASAMS_Radar_MPQ64F1", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="NASAMS_Command_Post", category="SUPPORT", role="CP", x=-100, y=0, hdg=90 }, { unit_type="NASAMS_LN_B", category="LAUNCHER", role="LN", x=60, y=60, hdg=225 }, { unit_type="NASAMS_LN_B", category="LAUNCHER", role="LN", x=-60, y=-60, hdg=45 }, { unit_type="NASAMS_LN_B", category="LAUNCHER", role="LN", x=60, y=-60, hdg=315 }, { unit_type="NASAMS_LN_B", category="LAUNCHER", role="LN", x=-60, y=60, hdg=135 }, { unit_type="M1097 Avenger", category="LAUNCHER", role="LN", x=1000, y=0, sam_type="M1097 Avenger" }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=100, y=0, hdg=270 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=-100, y=0, hdg=90 } }}
        }
    },
    ["Vulcan"] = {
        service_date = 1968, mobility = "MOBILE", threat = "LOW", range = 1, coalition = "BLUE",
        layouts = {
            ["A"] = { layout = { { unit_type="Vulcan", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 } } },
            ["G"] = { layout = { { unit_type="Vulcan", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="Vulcan", category="LAUNCHER", role="LN", x=50, y=50, hdg=180 } }},
            ["H"] = { layout = { { unit_type="Vulcan", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="Vulcan", category="LAUNCHER", role="LN", x=50, y=50, hdg=180 }, { unit_type="M1025 HMMWV", category="SUPPORT", role="CP", x=-50, y=0, hdg=90 } }},
            ["X"] = { layout = { { unit_type="Vulcan", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="M1025 HMMWV", category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { unit_type="Vulcan", category="LAUNCHER", role="LN", x=50, y=50, hdg=180 } }}
        }
    },
    ["M6 Linebacker"] = {
        service_date = 1997, mobility = "MOBILE", threat = "LOW", range = 3, coalition = "BLUE",
        layouts = {
            ["A"] = { layout = { { unit_type="M6 Linebacker", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } } },
            ["G"] = { layout = { { unit_type="M6 Linebacker", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="M6 Linebacker", category="LAUNCHER", role="LN", x=50, y=50, hdg=180 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }},
            ["H"] = { layout = { { unit_type="M6 Linebacker", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="M6 Linebacker", category="LAUNCHER", role="LN", x=50, y=50, hdg=180 }, { unit_type="M1025 HMMWV", category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }},
            ["X"] = { layout = { { unit_type="M6 Linebacker", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="M1025 HMMWV", category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { unit_type="M1097 Avenger", category="LAUNCHER", role="LN", x=1000, y=0, sam_type="M1097 Avenger" }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }}
        }
    },
    ["M1097 Avenger"] = {
        service_date = 1989, mobility = "MOBILE", threat = "LOW", range = 3, coalition = "BLUE",
        layouts = {
            ["A"] = { layout = { { unit_type="M1097 Avenger", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } } },
            ["G"] = { layout = { { unit_type="M1097 Avenger", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="M1097 Avenger", category="LAUNCHER", role="LN", x=50, y=50, hdg=180 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }},
            ["H"] = { layout = { { unit_type="M1097 Avenger", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="M1097 Avenger", category="LAUNCHER", role="LN", x=50, y=50, hdg=180 }, { unit_type="M1025 HMMWV", category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }},
            ["X"] = { layout = { { unit_type="M1097 Avenger", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="M1025 HMMWV", category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { unit_type="Vulcan", category="LAUNCHER", role="LN", x=1000, y=0, sam_type="Vulcan" }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }}
        }
    },
    ["M48 Chaparral"] = {
        service_date = 1969, mobility = "MOBILE", threat = "LOW", range = 3, coalition = "BLUE",
        layouts = {
            ["A"] = { layout = { { unit_type="M48 Chaparral", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } } },
            ["G"] = { layout = { { unit_type="M48 Chaparral", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="M48 Chaparral", category="LAUNCHER", role="LN", x=100, y=50, hdg=45 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }},
            ["H"] = { layout = { { unit_type="M48 Chaparral", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="M48 Chaparral", category="LAUNCHER", role="LN", x=100, y=50, hdg=45 }, { unit_type="M1025 HMMWV", category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }},
            ["X"] = { layout = { { unit_type="M48 Chaparral", category="LAUNCHER", role="LN", x=0, y=0, hdg=0 }, { unit_type="M1025 HMMWV", category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { unit_type="Vulcan", category="LAUNCHER", role="LN", x=1000, y=0, sam_type="Vulcan" }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }}
        }
    },
    ["Rapier"] = {
        service_date = 1971, mobility = "FIXED", threat = "LOW", range = 4, coalition = "BLUE",
        layouts = {
            ["A"] = { layout = { { unit_type="rapier_fsa_optical_tracker_unit", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="rapier_fsa_blindfire_radar", category="RADAR", role="TR", x=10, y=10, hdg=0 }, { unit_type="rapier_fsa_launcher", category="LAUNCHER", role="LN", x=20, y=20, hdg=0 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } } },
            ["G"] = { layout = { { unit_type="rapier_fsa_optical_tracker_unit", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="rapier_fsa_blindfire_radar", category="RADAR", role="TR", x=10, y=10, hdg=0 }, { unit_type="rapier_fsa_launcher", category="LAUNCHER", role="LN", x=50, y=50, hdg=180 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }},
            ["H"] = { layout = { { unit_type="rapier_fsa_optical_tracker_unit", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="rapier_fsa_blindfire_radar", category="RADAR", role="TR", x=10, y=10, hdg=0 }, { unit_type="rapier_fsa_launcher", category="LAUNCHER", role="LN", x=50, y=50, hdg=180 }, { unit_type="rapier_fsa_launcher", category="LAUNCHER", role="LN", x=-50, y=-50, hdg=0 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }},
            ["X"] = { layout = { { unit_type="rapier_fsa_optical_tracker_unit", category="RADAR", role="TR", x=0, y=0, hdg=0 }, { unit_type="rapier_fsa_blindfire_radar", category="RADAR", role="TR", x=10, y=10, hdg=0 }, { unit_type="rapier_fsa_launcher", category="LAUNCHER", role="LN", x=50, y=50, hdg=180 }, { unit_type="rapier_fsa_launcher", category="LAUNCHER", role="LN", x=-50, y=-50, hdg=0 }, { unit_type="M1097 Avenger", category="LAUNCHER", role="LN", x=1000, y=0, sam_type="M1097 Avenger" }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }}
        }
    },
    ["Roland"] = {
        service_date = 1977, mobility = "MOBILE", threat = "LOW", range = 4, coalition = "BLUE",
        layouts = {
            ["A"] = { layout = { { unit_type="Roland Radar", category="RADAR", role="SR", x=0, y=0, hdg=0 }, { unit_type="Roland ADS", category="LAUNCHER", role="LN", x=20, y=20, hdg=0 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } } },
            ["G"] = { layout = { { unit_type="Roland Radar", category="RADAR", role="SR", x=0, y=0, hdg=0 }, { unit_type="Roland ADS", category="LAUNCHER", role="LN", x=20, y=20, hdg=0 }, { unit_type="Roland ADS", category="LAUNCHER", role="LN", x=100, y=50, hdg=45 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }},
            ["H"] = { layout = { { unit_type="Roland Radar", category="RADAR", role="SR", x=0, y=0, hdg=0 }, { unit_type="Roland ADS", category="LAUNCHER", role="LN", x=20, y=20, hdg=0 }, { unit_type="Roland ADS", category="LAUNCHER", role="LN", x=100, y=50, hdg=45 }, { unit_type="M1025 HMMWV", category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }},
            ["X"] = { layout = { { unit_type="Roland Radar", category="RADAR", role="SR", x=0, y=0, hdg=0 }, { unit_type="Roland ADS", category="LAUNCHER", role="LN", x=20, y=20, hdg=0 }, { unit_type="M1025 HMMWV", category="SUPPORT", role="CP", x=-50, y=0, hdg=90 }, { unit_type="M1097 Avenger", category="LAUNCHER", role="LN", x=1000, y=0, sam_type="M1097 Avenger" }, { unit_type="Vulcan", category="FIXED_AAA", role="AAA", x=50, y=0, hdg=270 } }}
        }
    }
}

-- Era Substitution Matrix
-- Maps modern capabilities to their historical predecessors. 
-- If a mission's Year Limit restricts a requested system, it cascades down this list.
TCS.AirDef.Substitutions = {
    ["SA-22"]         = { "SA-19", "SA-15", "SA-8" },
    ["SA-19"]         = { "SA-8", "SA-9" },
    ["SA-15"]         = { "SA-8" },
    ["SA-11"]         = { "SA-6" },
    ["SA-10"]         = { "SA-5", "SA-2" },
    ["Patriot"]       = { "Hawk" },
    ["NASAMS"]        = { "Hawk" },
    ["M6 Linebacker"] = { "M48 Chaparral", "Vulcan" },
    ["M1097 Avenger"] = { "M48 Chaparral", "Vulcan" }
}

env.info("TCS(AIRDEF.CATALOG): loaded")