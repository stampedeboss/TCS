---------------------------------------------------------------------
-- menus/a2g.lua
---------------------------------------------------------------------
env.info("TCS(MENU): loading A2G")

function TCS.Menu.BuildA2G(rec)
  local g = rec.Group:GetName()
  local root = TCS.Menu.Groups[g]
  if not root then return end

  MENU_GROUP_COMMAND:New(rec.Group, "BAI", root.A2G, function()
    if TCS.A2G and TCS.A2G.BAI then
      TCS.A2G.BAI(rec.Group)
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "CAS", root.A2G, function()
    if TCS.A2G and TCS.A2G.CAS then
      TCS.A2G.CAS(rec.Group)
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Laser On", root.A2G, function()
    local session = TCS.SessionManager:GetSessionForGroup(rec.Group)
    if session and session.A2G_Target and TCS.A2G.JTAC and TCS.A2G.JTAC.LaserOn then
      TCS.A2G.JTAC.LaserOn(session, session.A2G_Target)
    else
      MESSAGE:New("No active target for Laser.", 5):ToGroup(rec.Group)
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "SEAD", root.A2G, function()
    local session = TCS.SessionManager:GetOrCreateSessionForGroup(rec.Group)
    if TCS.A2G and TCS.A2G.SEAD then
      TCS.A2G.SEAD(session)
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "DEAD", root.A2G, function()
    local session = TCS.SessionManager:GetOrCreateSessionForGroup(rec.Group)
    if TCS.A2G and TCS.A2G.DEAD then
      TCS.A2G.DEAD(session)
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Strike", root.A2G, function()
    local session = TCS.SessionManager:GetOrCreateSessionForGroup(rec.Group)
    if TCS.A2G and TCS.A2G.STRIKE then
      TCS.A2G.STRIKE(session)
    end
  end)
end
