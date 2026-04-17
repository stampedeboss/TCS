TCS = TCS or {}
TCS.Config = TCS.Config or {}
TCS.Config.Catalog = TCS.Config.Catalog or {}

local function generate_bandits()
  local bandits = {}
  local function add(id, type, tier, role, var, skill, loadout, speed_class, era)
    table.insert(bandits, {
      id = id,
      filters = { role=role, tier=tier, type=type, var=var },
      unit_type = type,
      skill = skill,
      payload = loadout,
      speed_class = speed_class,
      first_service_year = era
    })
  end

  local Skills = { A="Average", G="Good", H="High", X="Excellent" }
  local P = {
    Empty = {},
    A10_AIM9 = {pylons={[1]={clsid="{AIM-9M}"},[11]={clsid="{AIM-9M}"}}, fuel=4000, flare=120, chaff=240, gun=100},
    F14_AIM54 = {pylons={[1]={clsid="{AIM-9M}"},[3]={clsid="{AIM-54C_Mk47}"},[4]={clsid="{AIM-54C_Mk47}"},[5]={clsid="{AIM-54C_Mk47}"},[6]={clsid="{AIM-54C_Mk47}"},[8]={clsid="{AIM-9M}"}}, fuel=6000, flare=60, chaff=60, gun=100},
    F14_AIM7 = {pylons={[1]={clsid="{AIM-9M}"},[3]={clsid="{AIM-7M}"},[4]={clsid="{AIM-7M}"},[5]={clsid="{AIM-7M}"},[6]={clsid="{AIM-7M}"},[8]={clsid="{AIM-9M}"}}, fuel=6000, flare=60, chaff=60, gun=100},
    F14_AIM9 = {pylons={[2]={clsid="{AIM-9M}"},[7]={clsid="{AIM-9M}"}}, fuel=6000, flare=60, chaff=60, gun=100},
    F16_AIM120 = {pylons={[1]={clsid="{AIM-120C}"},[2]={clsid="{AIM-9M}"},[3]={clsid="{AIM-120C}"},[7]={clsid="{AIM-120C}"},[8]={clsid="{AIM-9M}"},[9]={clsid="{AIM-120C}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    F16_AIM9 = {pylons={[1]={clsid="{AIM-9M}"},[2]={clsid="{AIM-9M}"},[8]={clsid="{AIM-9M}"},[9]={clsid="{AIM-9M}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    F18_AIM120 = {pylons={[1]={clsid="{AIM-9M}"},[2]={clsid="{AIM-120C}"},[3]={clsid="{AIM-120C}"},[7]={clsid="{AIM-120C}"},[8]={clsid="{AIM-120C}"},[9]={clsid="{AIM-9M}"}}, fuel=4000, flare=60, chaff=60, gun=100},
    F18_AIM9 = {pylons={[1]={clsid="{AIM-9M}"},[9]={clsid="{AIM-9M}"}}, fuel=4000, flare=60, chaff=60, gun=100},
    F5_AIM9 = {pylons={[1]={clsid="{AIM-9P5}"},[7]={clsid="{AIM-9P5}"}}, fuel=2000, flare=30, chaff=30, gun=100},
    J11_R27 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[3]={clsid="{R-27R}"},[4]={clsid="{R-27R}"},[9]={clsid="{R-73}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    J11_R27ER = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[3]={clsid="{R-27ER}"},[4]={clsid="{R-27ER}"},[7]={clsid="{R-27ER}"},[8]={clsid="{R-27ER}"},[9]={clsid="{R-73}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    J11_R77 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[3]={clsid="{R-77}"},[4]={clsid="{R-77}"},[5]={clsid="{R-27ER}"},[6]={clsid="{R-27ER}"},[7]={clsid="{R-77}"},[8]={clsid="{R-77}"},[9]={clsid="{R-73}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    JF17_PL5 = {pylons={[1]={clsid="{PL-5EII}"},[7]={clsid="{PL-5EII}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    JF17_SD10 = {pylons={[1]={clsid="{PL-5EII}"},[2]={clsid="{SD-10}"},[6]={clsid="{SD-10}"},[7]={clsid="{PL-5EII}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    L39_R60 = {pylons={[1]={clsid="{R-60M}"},[4]={clsid="{R-60M}"}}, fuel=1000, flare=0, chaff=0, gun=100},
    M2000_MAGIC = {pylons={[1]={clsid="{MAGIC_II}"},[9]={clsid="{MAGIC_II}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    MIG19_R3S = {pylons={[1]={clsid="{R-3S}"},[2]={clsid="{R-3S}"}}, fuel=2000, flare=0, chaff=0, gun=100},
    MIG21_R3R = {pylons={[1]={clsid="{R-60M}"},[2]={clsid="{R-3R}"},[3]={clsid="{R-3R}"},[4]={clsid="{R-60M}"}}, fuel=2000, flare=60, chaff=60, gun=100},
    MIG21_R60 = {pylons={[1]={clsid="{R-60M}"},[2]={clsid="{R-60M}"},[3]={clsid="{R-60M}"},[4]={clsid="{R-60M}"}}, fuel=2000, flare=60, chaff=60, gun=100},
    MIG23_R23 = {pylons={[1]={clsid="{R-23R}"},[2]={clsid="{R-23R}"},[3]={clsid="{R-60M}"},[4]={clsid="{R-60M}"}}, fuel=2500, flare=60, chaff=60, gun=100},
    MIG23_R60 = {pylons={[3]={clsid="{R-60M}"},[4]={clsid="{R-60M}"}}, fuel=2500, flare=60, chaff=60, gun=100},
    MIG29A_R27 = {pylons={[1]={clsid="{R-73}"},[3]={clsid="{R-27R}"},[4]={clsid="{R-27R}"},[6]={clsid="{R-73}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    MIG29A_R60 = {pylons={[1]={clsid="{R-60M}"},[2]={clsid="{R-60M}"},[5]={clsid="{R-60M}"},[6]={clsid="{R-60M}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    MIG29S_R27 = {pylons={[1]={clsid="{R-73}"},[3]={clsid="{R-27R}"},[4]={clsid="{R-27R}"},[6]={clsid="{R-73}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    MIG29S_R27ER = {pylons={[1]={clsid="{R-73}"},[3]={clsid="{R-27ER}"},[4]={clsid="{R-27ER}"},[6]={clsid="{R-73}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    MIG29S_R73 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[5]={clsid="{R-73}"},[6]={clsid="{R-73}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    MIG29S_R77 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-77}"},[3]={clsid="{R-77}"},[4]={clsid="{R-77}"},[5]={clsid="{R-77}"},[6]={clsid="{R-73}"}}, fuel=3000, flare=60, chaff=60, gun=100},
    MIG31_R33 = {pylons={[1]={clsid="{R-33}"},[2]={clsid="{R-33}"},[3]={clsid="{R-33}"},[4]={clsid="{R-33}"}}, fuel=6000, flare=60, chaff=60, gun=100},
    MIG31_R60 = {pylons={[5]={clsid="{R-60M}"},[6]={clsid="{R-60M}"}}, fuel=6000, flare=60, chaff=60, gun=100},
    SU25_R60 = {pylons={[1]={clsid="{R-60M}"},[11]={clsid="{R-60M}"}}, fuel=2500, flare=128, chaff=128, gun=100},
    SU27_R27 = {pylons={[1]={clsid="{R-73}"},[3]={clsid="{R-27R}"},[8]={clsid="{R-27R}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    SU27_R27ER = {pylons={[1]={clsid="{R-73}"},[3]={clsid="{R-27ER}"},[5]={clsid="{R-27ET}"},[6]={clsid="{R-27ET}"},[8]={clsid="{R-27ER}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    SU27_R73 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[9]={clsid="{R-73}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    SU30_R27ER = {pylons={[1]={clsid="{R-73}"},[3]={clsid="{R-27ER}"},[5]={clsid="{R-27ET}"},[6]={clsid="{R-27ET}"},[8]={clsid="{R-27ER}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    SU30_R77 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[3]={clsid="{R-77}"},[4]={clsid="{R-77}"},[5]={clsid="{R-27ER}"},[6]={clsid="{R-27ER}"},[7]={clsid="{R-77}"},[8]={clsid="{R-77}"},[9]={clsid="{R-73}"},[10]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    SU33_R27 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[3]={clsid="{R-27R}"},[4]={clsid="{R-27R}"},[9]={clsid="{R-27R}"},[10]={clsid="{R-27R}"},[11]={clsid="{R-73}"},[12]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    SU33_R27ER = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[3]={clsid="{R-27ER}"},[4]={clsid="{R-27ET}"},[9]={clsid="{R-27ER}"},[10]={clsid="{R-27ET}"},[11]={clsid="{R-73}"},[12]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    SU33_R73 = {pylons={[1]={clsid="{R-73}"},[2]={clsid="{R-73}"},[11]={clsid="{R-73}"},[12]={clsid="{R-73}"}}, fuel=5000, flare=96, chaff=96, gun=100},
    YAK52_EMPTY = {pylons={}, fuel=100, flare=0, chaff=0, gun=100},
  }

  local Aircraft = {
    { id="A10", type="A-10A", tiers={"A"}, wvr={GUNS=P.Empty, FOX2=P.A10_AIM9}, speed_class="SLOW", era=1977 },
    { id="F14", type="F-14B", tiers={"H","X"}, wvr={GUNS=P.Empty, FOX2=P.F14_AIM9}, bvr={FOX1=P.F14_AIM7, FOX3={X=P.F14_AIM54}}, speed_class="FAST", era=1987 },
    { id="F16", type="F-16C_50", tiers={"H","X"}, wvr={GUNS=P.Empty, FOX2=P.F16_AIM9}, bvr={FOX3={H=P.F16_AIM120, X=P.F16_AIM120}}, era=1991 },
    { id="F18", type="FA-18C_hornet", tiers={"H","X"}, wvr={GUNS=P.Empty, FOX2=P.F18_AIM9}, bvr={FOX3={H=P.F18_AIM120, X=P.F18_AIM120}}, era=1987 },
    { id="F5", type="F-5E-3", tiers={"A","G"}, wvr={GUNS=P.Empty, FOX2=P.F5_AIM9}, era=1972 },
    { id="J11", type="J-11A", tiers={"G","H","X"}, wvr={GUNS=P.Empty, FOX2=P.SU27_R73}, bvr={FOX1={G=P.J11_R27, H=P.J11_R27ER, X=P.J11_R27ER}, FOX3={X=P.J11_R77}}, era=1998 },
    { id="JF17", type="JF-17", tiers={"H","X"}, wvr={GUNS=P.Empty, FOX2=P.JF17_PL5}, bvr={FOX3={H=P.JF17_SD10, X=P.JF17_SD10}}, era=2007 },
    { id="L39", type="L-39ZA", tiers={"A"}, wvr={GUNS=P.Empty, FOX2=P.L39_R60}, speed_class="SLOW", era=1980 },
    { id="M2000", type="M-2000C", tiers={"G","H"}, wvr={GUNS=P.Empty, FOX2=P.M2000_MAGIC}, era=1984 },
    { id="MIG19", type="MiG-19P", tiers={"G"}, wvr={GUNS=P.Empty, FOX2=P.MIG19_R3S}, era=1955 },
    { id="MIG21", type="MiG-21Bis", tiers={"A","G"}, wvr={GUNS=P.Empty, FOX2=P.MIG21_R60}, bvr={FOX1=P.MIG21_R3R}, era=1972 },
    { id="MIG23", type="MiG-23MLA", tiers={"A"}, wvr={GUNS=P.Empty, FOX2=P.MIG23_R60}, bvr={FOX1=P.MIG23_R23}, era=1978 },
    { id="MIG29A", type="MiG-29A", tiers={"G"}, wvr={GUNS=P.Empty, FOX2=P.MIG29A_R60}, bvr={FOX1=P.MIG29A_R27}, era=1983 },
    { id="MIG29S", type="MiG-29S", tiers={"G","H","X"}, wvr={GUNS=P.Empty, FOX2=P.MIG29S_R73}, bvr={FOX1={G=P.MIG29S_R27, H=P.MIG29S_R27ER, X=P.MIG29S_R27ER}, FOX3={X=P.MIG29S_R77}}, era=1994 },
    { id="MIG31", type="MiG-31", tiers={"X"}, wvr={GUNS=P.Empty, FOX2=P.MIG31_R60}, bvr={FOX1=P.MIG31_R33}, speed_class="FAST", era=1981 },
    { id="SU25", type="Su-25T", tiers={"A"}, wvr={GUNS=P.Empty, FOX2=P.SU25_R60}, speed_class="SLOW", era=1996 },
    { id="SU27", type="Su-27", tiers={"G","H","X"}, wvr={GUNS=P.Empty, FOX2=P.SU27_R73}, bvr={FOX1={G=P.SU27_R27, H=P.SU27_R27ER, X=P.SU27_R27ER}}, era=1985 },
    { id="SU30", type="Su-30", tiers={"H","X"}, wvr={GUNS=P.Empty, FOX2=P.SU27_R73}, bvr={FOX1=P.SU30_R27ER, FOX3={X=P.SU30_R77}}, era=1996 },
    { id="SU33", type="Su-33", tiers={"G","H","X"}, wvr={GUNS=P.Empty, FOX2=P.SU33_R73}, bvr={FOX1={G=P.SU33_R27, H=P.SU33_R27ER, X=P.SU33_R27ER}}, era=1998 },
    { id="YAK52", type="Yak-52", tiers={"A"}, wvr={GUNS=P.Empty, FOX2=P.YAK52_EMPTY}, speed_class="SLOW", era=1979 },
    { id="MIG15", type="MiG-15bis", tiers={"A","G"}, wvr={GUNS=P.Empty}, speed_class="FAST", era=1950 },
    { id="F86", type="F-86F Sabre", tiers={"A","G"}, wvr={GUNS=P.Empty}, speed_class="FAST", era=1949 },
    { id="P51", type="P-51D", tiers={"A"}, wvr={GUNS=P.Empty}, speed_class="SLOW", era=1944 },
    { id="SPITFIRE", type="SpitfireLFMkIX", tiers={"A"}, wvr={GUNS=P.Empty}, speed_class="SLOW", era=1942 },
    { id="DRONE", type="A-10A", tiers={"A"}, wvr={GUNS=P.Empty}, bvr={}, role="DRONE" },
  }

  for _, ac in ipairs(Aircraft) do
    for _, tier in ipairs(ac.tiers) do
      local skill = Skills[tier]
      if ac.role == "DRONE" then
        add(ac.id, ac.type, tier, "DRONE", "NONE", skill, P.Empty, ac.speed_class)
      else
        if ac.wvr then
          for var, loadout in pairs(ac.wvr) do
            local finalLoadout = loadout
            if type(loadout) == "table" and loadout[tier] then finalLoadout = loadout[tier] end
            if finalLoadout then
               add(ac.id.."_WVR_"..tier.."_"..var, ac.type, tier, "WVR", var, skill, finalLoadout, ac.speed_class, ac.era)
               if var == "FOX2" then add(ac.id.."_WVR_"..tier, ac.type, tier, "WVR", var, skill, finalLoadout, ac.speed_class, ac.era) end
            end
          end
        end
        if ac.bvr then
          for var, loadout in pairs(ac.bvr) do
            local finalLoadout = loadout
            if type(loadout) == "table" and (loadout.G or loadout.H or loadout.X or loadout.A) then finalLoadout = loadout[tier] end
            if finalLoadout then
               add(ac.id.."_BVR_"..tier.."_"..var, ac.type, tier, "BVR", var, skill, finalLoadout, ac.speed_class, ac.era)
               if (var == "FOX1" and tier ~= "X") or (var == "FOX3" and tier == "X") then
                  add(ac.id.."_BVR_"..tier, ac.type, tier, "BVR", var, skill, finalLoadout, ac.speed_class, ac.era)
               end
            end
          end
        end
      end
    end
  end

  table.insert(bandits, { id="TU22_BOMBER", filters={role="BOMBER", type="TU22"}, unit_type="Tu-22M3", skill="Average", payload={}, first_service_year=1989 })
  table.insert(bandits, { id="TU95_BOMBER", filters={role="BOMBER", type="TU95"}, unit_type="Tu-95MS", skill="Average", payload={}, speed_class="SLOW", first_service_year=1981 })
  table.insert(bandits, { id="SU34_BOMBER", filters={role="BOMBER", type="SU34"}, unit_type="Su-34", skill="High", payload={pylons={[9]={clsid="{R-73}"},[10]={clsid="{R-73}"}}}, first_service_year=2014 })

  return bandits
end

TCS.Config.Catalog.A2A_Bandits = generate_bandits()