---------------------------------------------------------------------
-- DCS.MIS: CAUCASUS
-- Strategic definitions and initialization.
---------------------------------------------------------------------
env.info("DCS.MIS: Loading Caucasus Configuration")

_G.DCS = _G.DCS or {}
_G.DCS.MIS = _G.DCS.MIS or {}

DCS.MIS.Caucasus = {
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

function DCS.MIS.Caucasus.Init()
  env.info("DCS.MIS: Initializing Caucasus Theater")

  -- A. Sanitize Neutrals
  if DCS.TCS.Map.SanitizeNeutrals then
    DCS.TCS.Map.SanitizeNeutrals(DCS.MIS.Caucasus.Airbases.Neutral)
  end

  -- B. Identify Carrier Group Placement
  -- Placement: 60 NM West of Batumi (Deep water, safe from coastal SAMs)
  local csgPos = DCS.TCS.Map.GetRelativePoint("Batumi", 270, 60)
  if csgPos then
    DCS.MIS.Caucasus.Carrier = {
      Name = "CSG_STATION",
      Point = csgPos,
      PatrolHeading = 135, -- SE patrol leg
      PatrolLength = 20 -- NM
    }
    env.info(string.format("DCS.MIS: Carrier Station identified at X:%.0f Y:%.0f (West of Batumi)", csgPos.x, csgPos.y))
  end

  -- C. Identify Air to Air Refueling Zones
  -- Texaco (Heavy): 40 NM North-West of Batumi (Over water)
  local aarPos = DCS.TCS.Map.GetRelativePoint("Batumi", 315, 40)
  if aarPos then
    DCS.MIS.Caucasus.AAR["Texaco"] = {
      ZoneName = "AAR_TEXACO",
      Point = aarPos,
      LegDist = 30,
      LegHdg = 90, -- East-West track
      Alt = 24000,
      Freq = 251.0
    }
    env.info("DCS.MIS: AAR Zone 'Texaco' identified NW of Batumi")
  end

  -- Shell (Tactical): 20 NM West of Kobuleti
  local shellPos = DCS.TCS.Map.GetRelativePoint("Kobuleti", 270, 20)
  if shellPos then
    DCS.MIS.Caucasus.AAR["Shell"] = {
      ZoneName = "AAR_SHELL",
      Point = shellPos,
      Alt = 16000,
      Freq = 253.0
    }
  end

  -- D. Initialize Standing Ranges
  if DCS.MIS.Caucasus.Ranges and TCS.RANGE and TCS.RANGE.BuildStandingRange then
    for _, r in ipairs(DCS.MIS.Caucasus.Ranges) do
      local p = DCS.TCS.Map.GetRelativePoint(r.Reference, r.Bearing, r.DistNM)
      if p then
        local y = land.getHeight({x = p.x, y = p.y})
        local vec3 = {x = p.x, y = y, z = p.y}
        TCS.RANGE.BuildStandingRange(r.Name, vec3, r.Heading, r.Layout)
      end
    end
  end

  -- E. Initialize Defenses (if the defense module is loaded)
  if DCS.MIS.Caucasus.InitDefenses then
    DCS.MIS.Caucasus.InitDefenses()
  end

  -- F. Dynamic Content (TCS Integration)
  -- This creates a persistent "World Session" to drive TCS modules without players.
  if TCS and TCS.SessionManager then
    local worldSession = TCS.SessionManager:GetOrCreateSystemSession("MIS_CAUCASUS_WORLD")
    
    -- 1. Establish a persistent CAS battle near Zugdidi
    if TCS.A2G and TCS.A2G.CAS and TCS.A2G.CAS.Start then
      local casPt = DCS.TCS.Map.GetRelativePoint("Kobuleti", 350, 25) -- 25NM North of Kobuleti
      if casPt then
        local coord = COORDINATE:NewFromVec2(casPt)
        TCS.A2G.CAS.Start(worldSession, coord, "COMPANY", nil)
        env.info("DCS.MIS: Started persistent CAS battle near Zugdidi.")
      end
    end

    -- 2. Establish a persistent CAP over the mountains
    if TCS.A2A and TCS.A2A.CAP and TCS.A2A.CAP.StartAt then
      local capPt = DCS.TCS.Map.GetRelativePoint("Nalchik", 180, 30) -- South of Nalchik
      if capPt then
        local coord = COORDINATE:NewFromVec2(capPt)
        -- Start a 4-hour CAP
        TCS.A2A.CAP:StartAt(worldSession, coord, 14400, nil)
        env.info("DCS.MIS: Started persistent Red Air CAP south of Nalchik.")
      end
    end

    -- 3. Establish a persistent BAI zone
    if TCS.A2G and TCS.A2G.BAI and TCS.A2G.BAI.Start then
      local baiPt = DCS.TCS.Map.GetRelativePoint("Maykop-Khanskaya", 180, 20) -- 20NM South of Maykop
      if baiPt then
        local coord = COORDINATE:NewFromVec2(baiPt)
        TCS.A2G.BAI.Start(worldSession, coord, "COMPANY", nil)
        env.info("DCS.MIS: Started persistent BAI interdiction south of Maykop.")
      end
    end

    -- 4. Establish a maritime convoy
    if TCS.SUW and TCS.SUW.Start then
      local marPt = DCS.TCS.Map.GetRelativePoint("Sochi-Adler", 270, 30) -- 30NM West of Sochi
      if marPt then
        local coord = COORDINATE:NewFromVec2(marPt)
        TCS.SUW.Start(worldSession, coord, "MAR_CONVOY", "Black Sea Supply", true, nil, "PLATOON")
        env.info("DCS.MIS: Started persistent Maritime Convoy west of Sochi.")
      end
    end

    -- 5. Establish a persistent SEAD front
    if TCS.A2G and TCS.A2G.SEAD and TCS.A2G.SEAD.Start then
      local seadPt = DCS.TCS.Map.GetRelativePoint("Beslan", 270, 15) -- 15NM West of Beslan
      if seadPt then
        local coord = COORDINATE:NewFromVec2(seadPt)
        TCS.A2G.SEAD.Start(worldSession, coord, "PLATOON", nil)
        env.info("DCS.MIS: Started persistent SEAD front west of Beslan.")
      end
    end
  else
    env.warning("DCS.MIS: TCS not loaded. Dynamic content skipped.")
  end
end

-- Register this map if DCS.MIS Core is loaded
if DCS.MIS.Register then
  DCS.MIS.Register(DCS.MIS.Caucasus)
end

if DCS.TCS.Map and DCS.TCS.Map.Register then
  DCS.TCS.Map.Register(DCS.MIS.Caucasus)
end