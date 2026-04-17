---------------------------------------------------------------------
-- DCS.MIS: NEVADA (NTTR)
-- Strategic definitions and initialization.
---------------------------------------------------------------------
env.info("DCS.MIS: Loading Nevada Configuration")

_G.DCS = _G.DCS or {}
_G.DCS.MIS = _G.DCS.MIS or {}

DCS.MIS.Nevada = {
  Name = "Nevada",

  Airbases = {
    Blue = { "Nellis AFB", "Creech AFB" },
    Red = { "Tonopah Test Range Airfield", "Groom Lake AFB" },
    Neutral = { "McCarran International", "Henderson Executive", "North Las Vegas" }
  },

  HomePlate = "Nellis AFB",
  
  Diverts = {
    "Creech AFB",
    "McCarran International"
  },

  Carrier = {}, -- Landlocked
  AAR = {},
  Ranges = {
    {
      Name = "Range_63",
      Reference = "Creech AFB",
      Bearing = 315,
      DistNM = 15,
      Heading = 0,
      Layout = "BOMB"
    },
    {
      Name = "Range_62",
      Reference = "Nellis AFB",
      Bearing = 330,
      DistNM = 25,
      Heading = 270,
      Layout = "STRAFE"
    }
  }
}

function DCS.MIS.Nevada.Init()
  env.info("DCS.MIS: Initializing Nevada Theater")

  if DCS.TCS.Map and DCS.TCS.Map.SanitizeNeutrals then
    DCS.TCS.Map.SanitizeNeutrals(DCS.MIS.Nevada.Airbases.Neutral)
  end

  -- AAR Texaco: Sally Corridor (East of ranges)
  local texPos = DCS.TCS.Map.GetRelativePoint("Nellis AFB", 0, 40)
  if texPos then
    DCS.MIS.Nevada.AAR["Texaco"] = {
      ZoneName = "AAR_TEXACO",
      Point = texPos,
      LegDist = 40,
      LegHdg = 90,
      Alt = 24000,
      Freq = 251.0
    }
  end

end

if DCS.MIS and DCS.MIS.Register then DCS.MIS.Register(DCS.MIS.Nevada) end
if DCS.TCS.Map and DCS.TCS.Map.Register then DCS.TCS.Map.Register(DCS.MIS.Nevada) end
