---------------------------------------------------------------------
-- DCS.TCS MAP: SYRIA
-- Strategic definitions and initialization.
---------------------------------------------------------------------
env.info("DCS.TCS(MAP): Loading Syria Configuration")

_G.DCS = _G.DCS or {}
_G.DCS.TCS = _G.DCS.TCS or {}
DCS.TCS.Map = DCS.TCS.Map or {}

DCS.TCS.Map.Syria = {
  Name = "Syria",

  Airbases = {
    Blue = {
      "Incirlik",
      "Ramat David",
      "Haifa",
      "Hatay",
      "Akrotiri"
    },
    Red = {
      "Damascus",
      "Aleppo",
      "Bassel Al-Assad",
      "Deir ez-Zor",
      "Tabqa"
    },
    Neutral = {
      "Beirut-Rafic Hariri",
      "Larnaca",
      "Paphos",
      "Gaziantep"
    }
  },

  HomePlate = "Incirlik",
  
  Diverts = {
    "Hatay",
    "Akrotiri"
  },

  Carrier = {},
  AAR = {}
}

function DCS.TCS.Map.Syria.Init()
  env.info("DCS.TCS(MAP): Initializing Syria Theater")

  if DCS.TCS.Map.SanitizeNeutrals then
    DCS.TCS.Map.SanitizeNeutrals(DCS.TCS.Map.Syria.Airbases.Neutral)
  end

  -- Carrier: 40 NM West of Paphos
  local csgPos = DCS.TCS.Map.GetRelativePoint("Paphos", 270, 40)
  if csgPos then
    DCS.TCS.Map.Syria.Carrier = {
      Name = "CSG_STATION",
      Point = csgPos,
      PatrolHeading = 0, -- North patrol
      PatrolLength = 25
    }
  end

  -- AAR Texaco: Over the Med, between Cyprus and Turkey
  local texPos = DCS.TCS.Map.GetRelativePoint("Larnaca", 45, 40)
  if texPos then
    DCS.TCS.Map.Syria.AAR["Texaco"] = {
      ZoneName = "AAR_TEXACO",
      Point = texPos,
      LegDist = 30,
      LegHdg = 90,
      Alt = 24000,
      Freq = 251.0
    }
  end
end

if DCS.TCS.Map.Register then DCS.TCS.Map.Register(DCS.TCS.Map.Syria) end