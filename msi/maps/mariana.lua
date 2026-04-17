---------------------------------------------------------------------
-- DCS.TCS MAP: MARIANA ISLANDS
-- Strategic definitions and initialization.
---------------------------------------------------------------------
env.info("DCS.TCS(MAP): Loading Mariana Configuration")

_G.DCS = _G.DCS or {}
_G.DCS.TCS = _G.DCS.TCS or {}
DCS.TCS.Map = DCS.TCS.Map or {}

DCS.TCS.Map.Mariana = {
  Name = "MarianaIslands",

  Airbases = {
    Blue = { "Andersen AFB" },
    Red = { "Saipan Intl" }, -- Fictional occupation
    Neutral = { "Tinian Intl", "Rota Intl", "Antonio B. Won Pat Intl" }
  },

  HomePlate = "Andersen AFB",
  
  Diverts = {
    "Antonio B. Won Pat Intl"
  },

  Carrier = {},
  AAR = {}
}

function DCS.TCS.Map.Mariana.Init()
  env.info("DCS.TCS(MAP): Initializing Mariana Theater")

  if DCS.TCS.Map.SanitizeNeutrals then
    DCS.TCS.Map.SanitizeNeutrals(DCS.TCS.Map.Mariana.Airbases.Neutral)
  end

  -- Carrier: 50 NM West of Guam
  local csgPos = DCS.TCS.Map.GetRelativePoint("Andersen AFB", 270, 50)
  if csgPos then
    DCS.TCS.Map.Mariana.Carrier = {
      Name = "CSG_STATION",
      Point = csgPos,
      PatrolHeading = 180,
      PatrolLength = 30
    }
  end

  -- AAR Texaco: North of Saipan
  local texPos = DCS.TCS.Map.GetRelativePoint("Saipan Intl", 0, 20)
  if texPos then
    DCS.TCS.Map.Mariana.AAR["Texaco"] = {
      ZoneName = "AAR_TEXACO",
      Point = texPos,
      LegDist = 40,
      LegHdg = 90,
      Alt = 22000,
      Freq = 251.0
    }
  end

  -- AAR Shell: West of Rota
  local shellPos = DCS.TCS.Map.GetRelativePoint("Rota Intl", 270, 15)
  if shellPos then
    DCS.TCS.Map.Mariana.AAR["Shell"] = {
      ZoneName = "AAR_SHELL",
      Point = shellPos,
      LegDist = 20,
      LegHdg = 0,
      Alt = 16000,
      Freq = 253.0
    }
  end
end

if DCS.TCS.Map.Register then DCS.TCS.Map.Register(DCS.TCS.Map.Mariana) end