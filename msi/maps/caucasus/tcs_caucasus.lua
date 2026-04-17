---------------------------------------------------------------------
-- DCS.TCS MAP: CAUCASUS
-- Strategic definitions and initialization.
---------------------------------------------------------------------
env.info("DCS.TCS(MAP): Loading Caucasus Configuration")

_G.DCS = _G.DCS or {}
_G.DCS.TCS = _G.DCS.TCS or {}
DCS.TCS.Map = DCS.TCS.Map or {}

DCS.TCS.Map.Caucasus = {
  Name = "Caucasus",

  -- 1. Airfield Ownership & Logistics
  -- Defines the strategic reality of the map.
  Airbases = {
    Blue = {
      "Kutaisi",
      "Senaki-Kolkhi",
      "Batumi",
      "Kobuleti"
    },
    Red = {
      "Mozdok",
      "Nalchik",
      "Beslan",
      "Mineralnye Vody",
      "Sochi-Adler",
      "Krasnodar-Pashkovsky"
    },
    Neutral = {
      "Gudauta",
      "Sukhumi-Babushara",
      "Tbilisi-Lochini",
      "Vaziani"
    }
  },

  -- 2. Strategic Hubs
  HomePlate = "Kutaisi", -- Primary Blue Hub
  
  Diverts = {
    "Senaki-Kolkhi", -- Forward divert
    "Batumi"         -- Rear divert (Instrument capable)
  },

  -- 3. Carrier & AAR (Calculated in Init)
  Carrier = {},
  AAR = {},

  -- 4. Standing Ranges
  Ranges = {
    {
      Name = "Kobuleti_Range",
      Reference = "Kobuleti",
      Bearing = 90, -- East
      DistNM = 5,
      Heading = 0, -- North aligned targets
      Layout = "MIXED"
    }
  }
}

function DCS.TCS.Map.Caucasus.Init()
  env.info("DCS.TCS(MAP): Initializing Caucasus Theater")

  -- A. Sanitize Neutrals
  if DCS.TCS.Map.SanitizeNeutrals then
    DCS.TCS.Map.SanitizeNeutrals(DCS.TCS.Map.Caucasus.Airbases.Neutral)
  end

  -- B. Identify Carrier Group Placement
  -- Placement: 60 NM West of Batumi (Deep water, safe from coastal SAMs)
  local csgPos = DCS.TCS.Map.GetRelativePoint("Batumi", 270, 60)
  if csgPos then
    DCS.TCS.Map.Caucasus.Carrier = {
      Name = "CSG_STATION",
      Point = csgPos,
      PatrolHeading = 135, -- SE patrol leg
      PatrolLength = 20 -- NM
    }
    env.info(string.format("DCS.TCS(MAP): Carrier Station identified at X:%.0f Y:%.0f (West of Batumi)", csgPos.x, csgPos.y))
  end

  -- C. Identify Air to Air Refueling Zones
  -- Texaco (Heavy): 40 NM North-West of Batumi (Over water)
  local aarPos = DCS.TCS.Map.GetRelativePoint("Batumi", 315, 40)
  if aarPos then
    DCS.TCS.Map.Caucasus.AAR["Texaco"] = {
      ZoneName = "AAR_TEXACO",
      Point = aarPos,
      LegDist = 30,
      LegHdg = 90, -- East-West track
      Alt = 24000,
      Freq = 251.0
    }
    env.info("DCS.TCS(MAP): AAR Zone 'Texaco' identified NW of Batumi")
  end

  -- Shell (Tactical): 20 NM West of Kobuleti
  local shellPos = DCS.TCS.Map.GetRelativePoint("Kobuleti", 270, 20)
  if shellPos then
    DCS.TCS.Map.Caucasus.AAR["Shell"] = {
      ZoneName = "AAR_SHELL",
      Point = shellPos,
      Alt = 16000,
      Freq = 253.0
    }
  end

  -- D. Initialize Standing Ranges
  if DCS.MIS.Caucasus.Ranges and DCS.MIS.BuildStandingRange then
    for _, r in ipairs(DCS.TCS.Map.Caucasus.Ranges) do
      local p = DCS.TCS.Map.GetRelativePoint(r.Reference, r.Bearing, r.DistNM)
      if p then
        local y = land.getHeight({x = p.x, y = p.y})
        local vec3 = {x = p.x, y = y, z = p.y}
        DCS.MIS.BuildStandingRange(r.Name, vec3, r.Heading, r.Layout)
      end
    end
  end

  -- E. Initialize Persistent Strike Targets (Example)
  if DCS.MIS.StrikeManager then
    local factoryPos = DCS.TCS.Map.GetRelativePoint("Mozdok", 180, 10)
    if factoryPos then
      local factoryCoord = COORDINATE:NewFromVec2(factoryPos)
      local factoryTemplate = { category = Group.Category.GROUND, units = {"Ural-375", "Kamaz", "Warehouse"} }
      DCS.MIS.StrikeManager.AddTarget("STRIKE_FACTORY_MOZDOK", factoryTemplate, factoryCoord, 90, 7200) -- 2 hour regen
    end
  end

end

-- Register this map if DCS.TCS Map Core is loaded
if DCS.TCS.Map.Register then
  DCS.TCS.Map.Register(DCS.TCS.Map.Caucasus)
end