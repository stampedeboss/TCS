---------------------------------------------------------------------
-- menus/a2g.lua
---------------------------------------------------------------------
env.info("TCS(MENU): loading A2G")

function TCS.Menu.BuildA2G(rec)
  local g = rec.Group:GetName()
  local root = TCS.Menu.Groups[g]
  if not root then return end

  MENU_GROUP_COMMAND:New(rec.Group, "BAI", root.A2G, function()
    if TCS.A2G and TCS.A2G.BAI and TCS.A2G.BAI.MenuRequest then
      TCS.A2G.BAI.MenuRequest(rec.Group)
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "CAS", root.A2G, function()
    if TCS.A2G and TCS.A2G.CAS and TCS.A2G.CAS.MenuRequest then
      TCS.A2G.CAS.MenuRequest(rec.Group)
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
    if TCS.A2G and TCS.A2G.SEAD and TCS.A2G.SEAD.MenuRequest then
      TCS.A2G.SEAD.MenuRequest(rec.Group)
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "DEAD", root.A2G, function()
    if TCS.A2G and TCS.A2G.DEAD and TCS.A2G.DEAD.MenuRequest then
      TCS.A2G.DEAD.MenuRequest(rec.Group)
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Strike", root.A2G, function()
    if TCS.A2G and TCS.A2G.STRIKE and TCS.A2G.STRIKE.MenuRequest then
      TCS.A2G.STRIKE.MenuRequest(rec.Group)
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Logistics", root.A2G, function()
    if TCS.A2G and TCS.A2G.LOGISTICS and TCS.A2G.LOGISTICS.MenuRequest then
      TCS.A2G.LOGISTICS.MenuRequest(rec.Group)
    end
  end)
end
