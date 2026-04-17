---------------------------------------------------------------------
-- TCS TASKING API (JTAC)
-- Public API for JTAC-related commands.
---------------------------------------------------------------------
env.info("TCS(API.JTAC): loading")

TCS = TCS or {}
TCS.API = TCS.API or {}

--- Issues a 'Laser On' command for the current session's target.
-- @param params (table) { group }
function TCS.API.JTAC_LaserOn(params)
  if not params or not params.group then return end

  local session = TCS.SessionManager:GetSessionForGroup(params.group)
  
  if session and session.A2G_Target and TCS.A2G.JTAC and TCS.A2G.JTAC.LaserOn then
    TCS.A2G.JTAC.LaserOn(session, session.A2G_Target)
  else
    MESSAGE:New("No active target for Laser.", 5):ToGroup(params.group)
  end
end

env.info("TCS(API.JTAC): ready")