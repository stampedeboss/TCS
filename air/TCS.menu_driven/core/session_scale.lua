
env.info("TCS(SESSION_SCALE): loading")

TCS = TCS or {}

TCS.SessionScale = {
  { max = 2,  echelon = "PLATOON"   },
  { max = 6,  echelon = "COMPANY"   },
  { max = 16, echelon = "BATTALION" },
  { max = 99, echelon = "BRIGADE"   },
}

function TCS.GetEchelonForSession(session)
  local count = session and session.GetPlayerCount and session:GetPlayerCount() or 1
  for _, rule in ipairs(TCS.SessionScale) do
    if count <= rule.max then
      return rule.echelon
    end
  end
  return "PLATOON"
end

env.info("TCS(SESSION_SCALE): ready")
