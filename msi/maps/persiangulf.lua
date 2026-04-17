---------------------------------------------------------------------
-- DCS.TCS MAP: PERSIAN GULF
-- Strategic definitions and initialization.
---------------------------------------------------------------------
env.info("DCS.TCS(MAP): Loading Persian Gulf Configuration")

_G.DCS = _G.DCS or {}
_G.DCS.TCS = _G.DCS.TCS or {}
DCS.TCS.Map = DCS.TCS.Map or {}

DCS.TCS.Map.PersianGulf = {
  Name = "PersianGulf",

  Airbases = {
    Blue = { "Al Dhafra AFB", "Al Minhad AFB", "Fujairah Intl" },
    Red = { "Bandar Abbas Intl", "Lar", "Bandar Lengeh", "Havadarya" },
    Neutral = { "Dubai Intl", "Abu Dhabi Intl", "Sharjah Intl", "Khasab" }
  },

  HomePlate = "Al Dhafra AFB",
  
  Diverts = {
    "Al Minhad AFB",
    "Fujairah Intl"
  },

  Carrier = {},
  AAR = {}
}

function DCS.TCS.Map.PersianGulf.Init()
  env.info("DCS.TCS(MAP): Initializing Persian Gulf Theater")

  if DCS.TCS.Map.SanitizeNeutrals then
    DCS.TCS.Map.SanitizeNeutrals(DCS.TCS.Map.PersianGulf.Airbases.Neutral)
  end

  -- Carrier: Gulf of Oman (East of Fujairah)
  local csgPos = DCS.TCS.Map.GetRelativePoint("Fujairah Intl", 90, 40)
  if csgPos then
    DCS.TCS.Map.PersianGulf.Carrier = {
      Name = "CSG_STATION",
      Point = csgPos,
      PatrolHeading = 150,
      PatrolLength = 30
    }
  end

  -- AAR Texaco: Over the Southern Gulf
  local texPos = DCS.TCS.Map.GetRelativePoint("Sir Abu Nuayr", 90, 20)
  if texPos then
    DCS.TCS.Map.PersianGulf.AAR["Texaco"] = {
      ZoneName = "AAR_TEXACO",
      Point = texPos,
      LegDist = 40,
      LegHdg = 90,
      Alt = 24000,
      Freq = 251.0
    }
  end

  -- AAR Shell: Near Fujairah
  local shellPos = DCS.TCS.Map.GetRelativePoint("Fujairah Intl", 180, 15)
  if shellPos then
    DCS.TCS.Map.PersianGulf.AAR["Shell"] = {
      ZoneName = "AAR_SHELL",
      Point = shellPos,
      LegDist = 20,
      LegHdg = 270,
      Alt = 16000,
      Freq = 253.0
    }
  end
end

if DCS.TCS.Map.Register then DCS.TCS.Map.Register(DCS.TCS.Map.PersianGulf) end