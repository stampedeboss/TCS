---------------------------------------------------------------------
-- TCS AIR CATALOG
-- Consolidated database for Air, Statics, and QRF capabilities.
---------------------------------------------------------------------
env.info("TCS(AIR.CATALOG): loading")

TCS = TCS or {}
TCS.Air = TCS.Air or {}
TCS.Air.Catalog = TCS.Air.Catalog or {}

local function generate_aircraft()
  local catalog = { PLANES = {}, HELICOPTERS = {}, SUPPORT = {} }
  local function add(section, id, type, tier, role, var, skill, loadout, speed_class, first_year, last_year, coalitions, tags)
    table.insert(catalog[section], {
      id = id,
      domain = "AIR",
      role = role,
      tier = tier,
      filters = { role=role, tier=tier, type=type, var=var },
      unit_types = {type},
      skill = skill,
      data = { payload = loadout },
      speed_class = speed_class,
      years = {first_year or 1900, last_year or 9999},
      first_service_year = first_year,
      coalitions = coalitions or {"RED", "BLUE"},
      tags = tags or {}
    })
  end

  local Skills = { A="Average", G="Good", H="High", X="Excellent" }
  local P = {
    Empty = {},
    A10_AIM9 = {pylons={[1]={clsid="{AIM-9M}"},[11]={clsid="{AIM-9M}"}}, fuel=4000, flare=120, chaff=240, gun=100},
    F14_AIM54 = {pylons={[1]={clsid="{AIM-9M}"},[3]={clsid="{AIM-54C_Mk47}"},[4]={clsid="{AIM-54C_Mk47}"},[5]={clsid="{AIM-54C_Mk47}"},[6]={clsid="{AIM-54C_Mk47}"},[8]={clsid="{AIM-9M}"}}, fuel=6000, flare=60, chaff=60, gun=100},
    F14_AIM7 = {pylons={[1]={clsid="{AIM-9M}"},[3]={clsid="{AIM-7M}"},[4]={clsid="{AIM-7M}"},[5]={clsid="{AIM-7M}"},[6]={clsid="{AIM-7M}"},[8]={clsid="{AIM-9M}"}}, fuel=6000, flare=60, chaff=60, gun=100},
    F14_AIM9 = {pylons={[1]={clsid="{AIM-9M}"},[8]={clsid="{AIM-9M}"}}, fuel=6000, flare=60, chaff=60, gun=100},
    F16_AIM120 = {pylons={[1]={clsid="{AIM-120C}"},[2]={clsid="{AIM-9M}"},[3]={clsid="{AIM-120C}"},[7]={clsid="{AIM-120C}"},[8]={clsid="{AIM-9M}"},[9]={clsid="{AIM-120C}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    F16_AIM9 = {pylons={[1]={clsid="{AIM-9M}"},[2]={clsid="{AIM-9M}"},[8]={clsid="{AIM-9M}"},[9]={clsid="{AIM-9M}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    F18_AIM120 = {pylons={[1]={clsid="{AIM-9M}"},[2]={clsid="{AIM-120C}"},[3]={clsid="{AIM-120C}"},[7]={clsid="{AIM-120C}"},[8]={clsid="{AIM-120C}"},[9]={clsid="{AIM-9M}"}}, fuel=4000, flare=60, chaff=60, gun=100},
    F18_AIM9 = {pylons={[1]={clsid="{AIM-9M}"},[9]={clsid="{AIM-9M}"}}, fuel=4000, flare=60, chaff=60, gun=100},
    F5_AIM9 = {pylons={[1]={clsid="{AIM-9P5}"},[7]={clsid="{AIM-9P5}"}}, fuel=2000, flare=30, chaff=30, gun=100},
    J11_R27 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[3]={clsid="{R-27R}"},[8]={clsid="{R-27R}"},[9]={clsid="{R-73}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    J11_R27ER = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[3]={clsid="{R-27ER}"},[4]={clsid="{R-27ER}"},[7]={clsid="{R-27ER}"},[8]={clsid="{R-27ER}"},[9]={clsid="{R-73}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    J11_R77 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[3]={clsid="{R-77}"},[4]={clsid="{R-77}"},[5]={clsid="{R-27ER}"},[6]={clsid="{R-27ER}"},[7]={clsid="{R-77}"},[8]={clsid="{R-77}"},[9]={clsid="{R-73}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    JF17_PL5 = {pylons={[1]={clsid="{PL-5EII}"},[7]={clsid="{PL-5EII}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    JF17_SD10 = {pylons={[1]={clsid="{PL-5EII}"},[2]={clsid="{SD-10}"},[6]={clsid="{SD-10}"},[7]={clsid="{PL-5EII}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    L39_R60 = {pylons={[1]={clsid="{R-60M}"},[4]={clsid="{R-60M}"}}, fuel=1000, flare=0, chaff=0, gun=100},
    M2000_MAGIC = {pylons={[1]={clsid="{MAGIC_II}"},[9]={clsid="{MAGIC_II}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    MIG19_R3S = {pylons={[1]={clsid="{R-3S}"},[4]={clsid="{R-3S}"}}, fuel=2000, flare=0, chaff=0, gun=100},
    MIG21_R3R = {pylons={[1]={clsid="{R-60M}"},[2]={clsid="{R-3R}"},[4]={clsid="{R-3R}"},[5]={clsid="{R-60M}"}}, fuel=2000, flare=60, chaff=60, gun=100},
    MIG21_R60 = {pylons={[1]={clsid="{R-60M}"},[2]={clsid="{R-60M}"},[4]={clsid="{R-60M}"},[5]={clsid="{R-60M}"}}, fuel=2000, flare=60, chaff=60, gun=100},
    MIG23_R23 = {pylons={[1]={clsid="{R-23R}"},[2]={clsid="{R-60M}"},[4]={clsid="{R-60M}"},[5]={clsid="{R-23R}"}}, fuel=2500, flare=60, chaff=60, gun=100},
    MIG23_R60 = {pylons={[2]={clsid="{R-60M}"},[4]={clsid="{R-60M}"}}, fuel=2500, flare=60, chaff=60, gun=100},
    MIG29A_R27 = {pylons={[1]={clsid="{R-73}"},[3]={clsid="{R-27R}"},[5]={clsid="{R-27R}"},[7]={clsid="{R-73}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    MIG29A_R60 = {pylons={[1]={clsid="{R-60M}"},[2]={clsid="{R-60M}"},[6]={clsid="{R-60M}"},[7]={clsid="{R-60M}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    MIG29S_R27 = {pylons={[1]={clsid="{R-73}"},[3]={clsid="{R-27R}"},[5]={clsid="{R-27R}"},[7]={clsid="{R-73}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    MIG29S_R27ER = {pylons={[1]={clsid="{R-73}"},[3]={clsid="{R-27ER}"},[5]={clsid="{R-27ER}"},[7]={clsid="{R-73}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    MIG29S_R73 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[6]={clsid="{R-73}"},[7]={clsid="{R-73}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    MIG29S_R77 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-77}"},[3]={clsid="{R-77}"},[5]={clsid="{R-77}"},[6]={clsid="{R-77}"},[7]={clsid="{R-73}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    MIG31_R33 = {pylons={[1]={clsid="{R-33}"},[2]={clsid="{R-33}"},[3]={clsid="{R-33}"},[4]={clsid="{R-33}"}}, fuel=6000, flare=60, chaff=60, gun=100},
    MIG31_R60 = {pylons={[5]={clsid="{R-60M}"},[6]={clsid="{R-60M}"}}, fuel=6000, flare=60, chaff=60, gun=100},
    SU25_R60 = {pylons={[1]={clsid="{R-60M}"},[11]={clsid="{R-60M}"}}, fuel=2500, flare=128, chaff=128, gun=100},
    SU27_R27 = {pylons={[1]={clsid="{R-73}"},[3]={clsid="{R-27R}"},[8]={clsid="{R-27R}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    SU27_R27ER = {pylons={[1]={clsid="{R-73}"},[3]={clsid="{R-27ER}"},[5]={clsid="{R-27ET}"},[6]={clsid="{R-27ET}"},[8]={clsid="{R-27ER}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    SU27_R73 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[9]={clsid="{R-73}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    SU30_R27ER = {pylons={[1]={clsid="{R-73}"},[3]={clsid="{R-27ER}"},[5]={clsid="{R-27ET}"},[6]={clsid="{R-27ET}"},[8]={clsid="{R-27ER}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    SU30_R77 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[3]={clsid="{R-77}"},[4]={clsid="{R-77}"},[5]={clsid="{R-27ER}"},[6]={clsid="{R-27ER}"},[7]={clsid="{R-77}"},[8]={clsid="{R-77}"},[9]={clsid="{R-73}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    SU33_R27 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[3]={clsid="{R-27R}"},[4]={clsid="{R-27R}"},[9]={clsid="{R-27R}"},[10]={clsid="{R-27R}"},[11]={clsid="{R-73}"},[12]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    SU33_R27ER = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[3]={clsid="{R-27ER}"},[4]={clsid="{R-27ET}"},[9]={clsid="{R-27ET}"},[10]={clsid="{R-27ER}"},[11]={clsid="{R-73}"},[12]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    SU33_R73 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[11]={clsid="{R-73}"},[12]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    YAK52_EMPTY = {pylons={}, fuel=100, flare=0, chaff=0, gun=100},
  }

  local Aircraft = {
    -- LOW THREAT / CAS (Restricted entirely to Tier A)
    { id="A10", type="A-10A", tiers={"A"}, role="CAS", wvr={GUNS=P.Empty, FOX2=P.A10_AIM9}, speed_class="SLOW", first_year=1977, coalitions={"BLUE"}, tags={"ground_attack"} },
    { id="L39", type="L-39ZA", tiers={"A"}, role="TRAINER", wvr={GUNS=P.Empty, FOX2=P.L39_R60}, speed_class="SLOW", first_year=1980, coalitions={"RED"}, tags={"trainer"} },
    { id="SU25", type="Su-25T", tiers={"A"}, role="CAS", wvr={GUNS=P.Empty, FOX2=P.SU25_R60}, speed_class="SLOW", first_year=1996, coalitions={"RED"}, tags={"ground_attack"} },
    { id="YAK52", type="Yak-52", tiers={"A"}, role="TRAINER", wvr={GUNS=P.Empty, FOX2=P.YAK52_EMPTY}, speed_class="SLOW", first_year=1979, coalitions={"RED", "BLUE"}, tags={"trainer", "prop"} },
    
    -- WWII / EARLY COLD WAR FIGHTERS (Can be high-threat in era-appropriate scenarios)
    { id="MIG15", type="MiG-15bis", tiers={"A","G","H","X"}, wvr={GUNS=P.Empty}, speed_class="FAST", first_year=1950, coalitions={"RED"}, tags={"korean_war"} },
    { id="F86", type="F-86F Sabre", tiers={"A","G","H","X"}, wvr={GUNS=P.Empty}, speed_class="FAST", first_year=1949, last_year=1994, coalitions={"BLUE"}, tags={"korean_war"} },
    { id="MIG19", type="MiG-19P", tiers={"A","G","H","X"}, wvr={GUNS=P.Empty, FOX2={A=P.Empty, G=P.MIG19_R3S, H=P.MIG19_R3S, X=P.MIG19_R3S}}, first_year=1955, coalitions={"RED"}, tags={"cold_war"} },
    { id="P51", type="P-51D", tiers={"A","G","H","X"}, role="WARBIRD", wvr={GUNS=P.Empty}, speed_class="SLOW", first_year=1944, last_year=1984, coalitions={"BLUE"}, tags={"ww2", "prop"} },
    { id="SPITFIRE", type="SpitfireLFMkIX", tiers={"A","G","H","X"}, role="WARBIRD", wvr={GUNS=P.Empty}, speed_class="SLOW", first_year=1942, last_year=1961, coalitions={"BLUE"}, tags={"ww2", "prop"} },

    -- MID COLD WAR FIGHTERS (Unlock Fox-1 at Tier G/H)
    { id="F5", type="F-5E-3", tiers={"A","G","H","X"}, wvr={GUNS=P.Empty, FOX2={A=P.Empty, G=P.F5_AIM9, H=P.F5_AIM9, X=P.F5_AIM9}}, first_year=1972, coalitions={"BLUE", "RED"}, tags={"aggressor", "cold_war"} },
    { id="MIG21", type="MiG-21Bis", tiers={"A","G","H","X"}, wvr={GUNS=P.Empty, FOX2={A=P.Empty, G=P.MIG21_R60, H=P.MIG21_R60, X=P.MIG21_R60}}, bvr={FOX1={G=P.MIG21_R3R, H=P.MIG21_R3R, X=P.MIG21_R3R}}, first_year=1959, coalitions={"RED"}, tags={"cold_war", "interceptor"} },
    { id="MIG23", type="MiG-23MLD", tiers={"A","G","H","X"}, wvr={GUNS=P.Empty, FOX2={A=P.Empty, G=P.MIG23_R60, H=P.MIG23_R60, X=P.MIG23_R60}}, bvr={FOX1={G=P.MIG23_R23, H=P.MIG23_R23, X=P.MIG23_R23}}, first_year=1970, coalitions={"RED"}, tags={"cold_war", "variable_geometry"} },
    { id="M2000", type="M-2000C", tiers={"A","G","H","X"}, wvr={GUNS=P.Empty, FOX2={A=P.Empty, G=P.M2000_MAGIC, H=P.M2000_MAGIC, X=P.M2000_MAGIC}}, first_year=1984, coalitions={"BLUE"}, tags={"delta_wing", "interceptor"} },
    { id="MIG29A", type="MiG-29A", tiers={"A","G","H","X"}, wvr={GUNS=P.Empty, FOX2={A=P.Empty, G=P.MIG29A_R60, H=P.MIG29A_R60, X=P.MIG29A_R60}}, bvr={FOX1={G=P.MIG29A_R27, H=P.MIG29A_R27, X=P.MIG29A_R27}}, first_year=1983, coalitions={"RED"}, tags={"4th_gen"} },

    -- LATE COLD WAR / 4TH GEN FIGHTERS (Unlock Fox-3 at Tier H/X)
    { id="F14", type="F-14B", tiers={"A","G","H","X"}, wvr={GUNS=P.Empty, FOX2={A=P.Empty, G=P.F14_AIM9, H=P.F14_AIM9, X=P.F14_AIM9}}, bvr={FOX1={G=P.F14_AIM7, H=P.F14_AIM7, X=P.F14_AIM7}, FOX3={H=P.F14_AIM54, X=P.F14_AIM54}}, speed_class="FAST", first_year=1974, coalitions={"BLUE"}, tags={"carrier_capable", "4th_gen", "variable_geometry"} },
    { id="F16", type="F-16C_50", tiers={"A","G","H","X"}, wvr={GUNS=P.Empty, FOX2={A=P.Empty, G=P.F16_AIM9, H=P.F16_AIM9, X=P.F16_AIM9}}, bvr={FOX3={H=P.F16_AIM120, X=P.F16_AIM120}}, first_year=1978, coalitions={"BLUE"}, tags={"4th_gen"} },
    { id="F18", type="FA-18C_hornet", tiers={"A","G","H","X"}, wvr={GUNS=P.Empty, FOX2={A=P.Empty, G=P.F18_AIM9, H=P.F18_AIM9, X=P.F18_AIM9}}, bvr={FOX3={H=P.F18_AIM120, X=P.F18_AIM120}}, first_year=1983, coalitions={"BLUE"}, tags={"carrier_capable", "4th_gen"} },
    { id="MIG29S", type="MiG-29S", tiers={"A","G","H","X"}, wvr={GUNS=P.Empty, FOX2={A=P.Empty, G=P.MIG29S_R73, H=P.MIG29S_R73, X=P.MIG29S_R73}}, bvr={FOX1={G=P.MIG29S_R27, H=P.MIG29S_R27ER, X=P.MIG29S_R27ER}, FOX3={H=P.MIG29S_R77, X=P.MIG29S_R77}}, first_year=1994, coalitions={"RED"}, tags={"4th_gen"} },
    { id="SU27", type="Su-27", tiers={"A","G","H","X"}, wvr={GUNS=P.Empty, FOX2={A=P.Empty, G=P.SU27_R73, H=P.SU27_R73, X=P.SU27_R73}}, bvr={FOX1={G=P.SU27_R27, H=P.SU27_R27ER, X=P.SU27_R27ER}}, first_year=1985, coalitions={"RED"}, tags={"4th_gen"} },
    { id="SU33", type="Su-33", tiers={"A","G","H","X"}, wvr={GUNS=P.Empty, FOX2={A=P.Empty, G=P.SU33_R73, H=P.SU33_R73, X=P.SU33_R73}}, bvr={FOX1={G=P.SU33_R27, H=P.SU33_R27ER, X=P.SU33_R27ER}}, first_year=1998, coalitions={"RED"}, tags={"carrier_capable", "4th_gen"} },
    { id="MIG31", type="MiG-31", tiers={"A","G","H","X"}, wvr={GUNS=P.Empty, FOX2={A=P.Empty, G=P.MIG31_R60, H=P.MIG31_R60, X=P.MIG31_R60}}, bvr={FOX1={G=P.MIG31_R33, H=P.MIG31_R33, X=P.MIG31_R33}}, speed_class="FAST", first_year=1981, coalitions={"RED"}, tags={"interceptor", "supersonic"} },

    -- ADVANCED FIGHTERS
    { id="J11", type="J-11A", tiers={"A","G","H","X"}, wvr={GUNS=P.Empty, FOX2={A=P.Empty, G=P.SU27_R73, H=P.SU27_R73, X=P.SU27_R73}}, bvr={FOX1={G=P.J11_R27, H=P.J11_R27ER, X=P.J11_R27ER}, FOX3={H=P.J11_R77, X=P.J11_R77}}, first_year=1998, coalitions={"RED"}, tags={"4th_gen"} },
    { id="JF17", type="JF-17", tiers={"A","G","H","X"}, wvr={GUNS=P.Empty, FOX2={A=P.Empty, G=P.JF17_PL5, H=P.JF17_PL5, X=P.JF17_PL5}}, bvr={FOX3={H=P.JF17_SD10, X=P.JF17_SD10}}, first_year=2007, coalitions={"RED"}, tags={"4th_gen"} },
    { id="SU30", type="Su-30", tiers={"A","G","H","X"}, wvr={GUNS=P.Empty, FOX2={A=P.Empty, G=P.SU27_R73, H=P.SU27_R73, X=P.SU27_R73}}, bvr={FOX1={G=P.SU30_R27ER, H=P.SU30_R27ER, X=P.SU30_R27ER}, FOX3={H=P.SU30_R77, X=P.SU30_R77}}, first_year=1996, coalitions={"RED"}, tags={"4th_gen"} },

    { id="DRONE", type="A-10A", tiers={"A"}, wvr={GUNS=P.Empty}, bvr={}, role="DRONE", first_year=1977, coalitions={"BLUE", "RED"}, tags={"drone"} },
  }

  for _, ac in ipairs(Aircraft) do
    for _, tier in ipairs(ac.tiers) do
      local skill = Skills[tier]
      if ac.role == "DRONE" then
        add("PLANES", ac.id, ac.type, tier, "DRONE", "NONE", skill, P.Empty, ac.speed_class, ac.first_year, ac.last_year, ac.coalitions, ac.tags)
      else
        if ac.wvr then
          for var, loadout in pairs(ac.wvr) do
            local finalLoadout = loadout
            if type(loadout) == "table" and loadout[tier] then finalLoadout = loadout[tier] end
            if finalLoadout then
               local role = ac.role or "WVR"
               add("PLANES", ac.id.."_"..role.."_"..tier.."_"..var, ac.type, tier, role, var, skill, finalLoadout, ac.speed_class, ac.first_year, ac.last_year, ac.coalitions, ac.tags)
               if var == "FOX2" or (var == "GUNS" and not ac.wvr.FOX2) then 
                  add("PLANES", ac.id.."_"..role.."_"..tier, ac.type, tier, role, var, skill, finalLoadout, ac.speed_class, ac.first_year, ac.last_year, ac.coalitions, ac.tags) 
               end
            end
          end
        end
        if ac.bvr then
          for var, loadout in pairs(ac.bvr) do
            local finalLoadout = loadout
            if type(loadout) == "table" and (loadout.G or loadout.H or loadout.X or loadout.A) then finalLoadout = loadout[tier] end
            if finalLoadout then
               local role = ac.role or "BVR"
               add("PLANES", ac.id.."_"..role.."_"..tier.."_"..var, ac.type, tier, role, var, skill, finalLoadout, ac.speed_class, ac.first_year, ac.last_year, ac.coalitions, ac.tags)
               if (var == "FOX1" and tier ~= "X") or (var == "FOX3" and tier == "X") then
                  add("PLANES", ac.id.."_"..role.."_"..tier, ac.type, tier, role, var, skill, finalLoadout, ac.speed_class, ac.first_year, ac.last_year, ac.coalitions, ac.tags)
               end
            end
          end
        end
      end
    end
  end

  -- BOMBERS
  table.insert(catalog.PLANES, { id="TU22_BOMBER", domain="AIR", role="BOMBER", tier="G", unit_types={"Tu-22M3"}, skill="Average", data={payload={}}, years={1989, 9999}, coalitions={"RED"}, tags={"bomber", "heavy", "supersonic"} })
  table.insert(catalog.PLANES, { id="TU95_BOMBER", domain="AIR", role="BOMBER", tier="G", unit_types={"Tu-95MS"}, skill="Average", speed_class="SLOW", data={payload={}}, years={1981, 9999}, coalitions={"RED"}, tags={"bomber", "heavy", "prop"} })
  table.insert(catalog.PLANES, { id="SU34_BOMBER", domain="AIR", role="BOMBER", tier="H", unit_types={"Su-34"}, skill="High", data={payload={pylons={[1]={clsid="{R-73}"},[12]={clsid="{R-73}"}}}}, years={2014, 9999}, coalitions={"RED"}, tags={"bomber", "strike"} })
  table.insert(catalog.PLANES, { id="B52_BOMBER", domain="AIR", role="BOMBER", tier="H", unit_types={"B-52H"}, skill="High", speed_class="SLOW", data={payload={}}, years={1961, 9999}, coalitions={"BLUE"}, tags={"bomber", "heavy"} })
  table.insert(catalog.PLANES, { id="B1_BOMBER", domain="AIR", role="BOMBER", tier="H", unit_types={"B-1B"}, skill="High", speed_class="FAST", data={payload={}}, years={1986, 9999}, coalitions={"BLUE"}, tags={"bomber", "heavy", "supersonic"} })

  -- ATTACK HELICOPTERS (Consolidated from catalog_air_qrf.lua)
  table.insert(catalog.HELICOPTERS, { id="KA50_HELO", domain="AIR", role="ATTACK_HELO", tier="H", unit_types={"Ka-50"}, skill="High", speed_class="SLOW", data={payload={}}, years={1995, 9999}, coalitions={"RED"}, tags={"helo", "attack"} })
  table.insert(catalog.HELICOPTERS, { id="MI24V_HELO", domain="AIR", role="ATTACK_HELO", tier="G", unit_types={"Mi-24V"}, skill="Good", speed_class="SLOW", data={payload={}}, years={1976, 9999}, coalitions={"RED"}, tags={"helo", "attack", "transport"} })
  table.insert(catalog.HELICOPTERS, { id="AH64D_HELO", domain="AIR", role="ATTACK_HELO", tier="X", unit_types={"AH-64D_BLK_II"}, skill="Excellent", speed_class="SLOW", data={payload={}}, years={2003, 9999}, coalitions={"BLUE"}, tags={"helo", "attack"} })

  -- ADVANCED CAS & STRIKE (Consolidated from catalog_air_qrf.lua)
  table.insert(catalog.PLANES, { id="SU25T_CAS", domain="AIR", role="CAS", tier="H", unit_types={"Su-25T"}, skill="High", speed_class="FAST", data={payload={}}, years={1996, 9999}, coalitions={"RED"}, tags={"cas", "ground_attack"} })
  table.insert(catalog.PLANES, { id="A10C2_CAS", domain="AIR", role="CAS", tier="X", unit_types={"A-10C_2"}, skill="Excellent", speed_class="SLOW", data={payload={}}, years={2005, 9999}, coalitions={"BLUE"}, tags={"cas", "ground_attack"} })
  table.insert(catalog.PLANES, { id="FA18C_STRIKE", domain="AIR", role="STRIKE", tier="X", unit_types={"FA-18C_hornet"}, skill="Excellent", speed_class="FAST", data={payload={}}, years={1987, 9999}, coalitions={"BLUE"}, tags={"strike", "carrier_capable", "4th_gen"} })
  table.insert(catalog.PLANES, { id="F15E_STRIKE", domain="AIR", role="STRIKE", tier="H", unit_types={"F-15E"}, skill="High", speed_class="FAST", data={payload={}}, years={1988, 9999}, coalitions={"BLUE"}, tags={"strike", "4th_gen"} })
  table.insert(catalog.PLANES, { id="SU24_STRIKE", domain="AIR", role="STRIKE", tier="H", unit_types={"Su-24M"}, skill="High", speed_class="FAST", data={payload={}}, years={1983, 9999}, coalitions={"RED"}, tags={"strike", "variable_geometry"} })

  -- SUPPORT AIRCRAFT (Consolidated)
  table.insert(catalog.SUPPORT, { id="A50_AWACS", domain="AIR", role="AWACS", tier="H", unit_types={"A-50"}, skill="High", speed_class="SLOW", data={payload={}}, years={1984, 9999}, coalitions={"RED"}, tags={"awacs", "heavy"} })
  table.insert(catalog.SUPPORT, { id="E2_AWACS", domain="AIR", role="AWACS", tier="H", unit_types={"E-2C"}, skill="High", speed_class="SLOW", data={payload={}}, years={1973, 9999}, coalitions={"BLUE"}, tags={"awacs", "carrier_capable"} })
  table.insert(catalog.SUPPORT, { id="E3_AWACS", domain="AIR", role="AWACS", tier="H", unit_types={"E-3A"}, skill="High", speed_class="SLOW", data={payload={}}, years={1977, 9999}, coalitions={"BLUE"}, tags={"awacs", "heavy"} })
  table.insert(catalog.SUPPORT, { id="IL78_TANKER", domain="AIR", role="TANKER", tier="H", unit_types={"IL-78M"}, skill="High", speed_class="SLOW", data={payload={}}, years={1984, 9999}, coalitions={"RED"}, tags={"tanker", "heavy"} })
  table.insert(catalog.SUPPORT, { id="KC135_TANKER", domain="AIR", role="TANKER", tier="H", unit_types={"KC-135"}, skill="High", speed_class="SLOW", data={payload={}}, years={1957, 9999}, coalitions={"BLUE"}, tags={"tanker", "heavy"} })
  table.insert(catalog.SUPPORT, { id="KC130_TANKER", domain="AIR", role="TANKER", tier="H", unit_types={"KC130"}, skill="High", speed_class="SLOW", data={payload={}}, years={1962, 9999}, coalitions={"BLUE"}, tags={"tanker", "heavy", "prop"} })
  table.insert(catalog.SUPPORT, { id="KC135MPRS_TANKER", domain="AIR", role="TANKER", tier="H", unit_types={"KC135MPRS"}, skill="High", speed_class="SLOW", data={payload={}}, years={1996, 9999}, coalitions={"BLUE"}, tags={"tanker", "heavy"} })
  table.insert(catalog.SUPPORT, { id="S3_TANKER", domain="AIR", role="TANKER", tier="H", unit_types={"S-3B Tanker"}, skill="High", speed_class="SLOW", data={payload={}}, years={1974, 9999}, coalitions={"BLUE"}, tags={"tanker", "carrier_capable"} })
  table.insert(catalog.SUPPORT, { id="A6_TANKER", domain="AIR", role="TANKER", tier="H", unit_types={"A-6E TRAM Tanker"}, skill="High", speed_class="SLOW", data={payload={}}, years={1979, 9999}, coalitions={"BLUE"}, tags={"tanker", "carrier_capable"} })
  table.insert(catalog.SUPPORT, { id="C130_TRANSPORT", domain="AIR", role="TRANSPORT", tier="G", unit_types={"C-130"}, skill="Good", speed_class="SLOW", data={payload={}}, years={1956, 9999}, coalitions={"BLUE"}, tags={"transport", "heavy", "prop"} })
  table.insert(catalog.SUPPORT, { id="C17_TRANSPORT", domain="AIR", role="TRANSPORT", tier="H", unit_types={"C-17A"}, skill="High", speed_class="SLOW", data={payload={}}, years={1995, 9999}, coalitions={"BLUE"}, tags={"transport", "heavy"} })
  table.insert(catalog.HELICOPTERS, { id="SH60_RESCUE", domain="AIR", role="RESCUE", tier="H", unit_types={"SH-60B"}, skill="High", speed_class="SLOW", data={payload={}}, years={1984, 9999}, coalitions={"BLUE"}, tags={"helo", "rescue", "carrier_capable"} })

  return catalog
end

TCS.Air.Catalog.Data = generate_aircraft()

-- =================================================================
-- STATICS & EQUIPMENT CATALOG (Faction-Separated Major Categories)
-- =================================================================
TCS.Air.Catalog.Statics = {
  RED = {
    FARP = { ["FARP Ammo"] = 1, ["FARP Tent"] = 2, ["FARP Fuel"] = 1, ["Ural-375"] = 2 },
    AIRBASE = { ["SKP-11"] = 1, ["APA-5D"] = 2, ["ATMZ-5"] = 2, ["Ural-375"] = 3 },
    DEFENSE = { ["ZU-23 Emplacement Closed"] = 3, ["ZSU-23-4 Shilka"] = 1, ["SA-18 Strela 9P31M"] = 2 }
  },
  BLUE = {
    FARP = { ["FARP Ammo"] = 1, ["FARP Tent"] = 2, ["FARP Fuel"] = 1, ["M818"] = 2 },
    AIRBASE = { ["M1025 HMMWV"] = 3, ["M978 HEMTT Tanker"] = 2, ["M818"] = 2 },
    DEFENSE = { ["Vulcan"] = 3, ["Stinger comm"] = 2, ["M1097 Avenger"] = 1 }
  }
}

-- =================================================================
-- A2G QRF CATALOG (Consolidated from catalog_air_qrf.lua)
-- =================================================================
TCS.Air.Catalog.A2G = TCS.Air.Catalog.A2G or {}

TCS.Air.Catalog.A2G.HELO = {
  { id="ka50", domain="AIR", role="ATTACK_HELO", unit_type="Ka-50", size=1, mobility="AIR", threat_band="H", skill="High", coalition="RED", first_service_year=1995 },
  { id="mi24v", domain="AIR", role="ATTACK_HELO", unit_type="Mi-24V", size=1, mobility="AIR", threat_band="G", skill="Good", coalition="RED", first_service_year=1976 },
  { id="ah64d", domain="AIR", role="ATTACK_HELO", unit_type="AH-64D_BLK_II", size=1, mobility="AIR", threat_band="X", skill="Excellent", coalition="BLUE", first_service_year=2003 },
}

TCS.Air.Catalog.A2G.CAS = {
  { id="su25t", domain="AIR", role="CAS", unit_type="Su-25T", size=1, mobility="AIR", threat_band="H", skill="High", coalition="RED", speed_class="FAST", first_service_year=1996 },
  { id="su25", domain="AIR", role="CAS", unit_type="Su-25", size=1, mobility="AIR", threat_band="G", skill="Good", coalition="RED", speed_class="FAST", first_service_year=1981 },
  { id="a10c", domain="AIR", role="CAS", unit_type="A-10C_2", size=1, mobility="AIR", threat_band="X", skill="Excellent", coalition="BLUE", speed_class="FAST", first_service_year=2005 },
}

TCS.Air.Catalog.A2G.CV_CAS = {
  { id="su33", domain="AIR", role="CAS", unit_type="Su-33", size=1, mobility="AIR", threat_band="H", skill="High", coalition="RED", speed_class="FAST", first_service_year=1998 },
  { id="fa18c", domain="AIR", role="CAS", unit_type="FA-18C_hornet", size=1, mobility="AIR", threat_band="X", skill="Excellent", coalition="BLUE", speed_class="FAST", first_service_year=1987 },
}

-- =================================================================
-- AIR CATALOG QUERY ENGINE (Consolidated from air_catalog.lua)
-- =================================================================
function TCS.Air.Catalog.Query(params)
    local results = {}
    local sourceTable = TCS.Air.Catalog.Data or {}
    
    for section, sectionData in pairs(sourceTable) do
        for _, entry in ipairs(sectionData) do
            local match = true
            
            if params.section and section ~= string.upper(params.section) then match = false end
            if params.domain and entry.domain ~= params.domain then match = false end
            if params.role and entry.role ~= params.role then match = false end
            if params.tier and entry.tier ~= params.tier then match = false end
            if params.var and entry.filters and entry.filters.var ~= params.var then match = false end
            
            if params.year and entry.years then
                local yearStart = entry.years[1] or 0
                local yearEnd = entry.years[2] or 9999
                if params.year < yearStart or params.year > yearEnd then
                    match = false
                end
            end

            if match then table.insert(results, entry) end
        end
    end

    return results
end

-- Automatically run the diagnostic test script to dump combinations to the log
-- dofile([[c:\Users\stamp\Saved Games\DCS\Scripts\TCS\air\test_bandit_catalog.lua]])

env.info("TCS(AIR.CATALOG): ready")