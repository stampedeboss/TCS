---------------------------------------------------------------------
-- menus/a2g.lua
---------------------------------------------------------------------
env.info("TCS(MENU): loading A2G")

function TCS.Menu.BuildA2G(rec)
  local g = rec.Group:GetName()
  local root = TCS.Menu.Groups[g]
  if not root then return end

  MENU_GROUP_COMMAND:New(rec.Group, "BAI", root.A2G, function()
    local result = DeployGroundForces({ group = rec.Group, minNm = 25, maxNm = 35 })
    if not result and TCS.MsgToGroup then TCS.MsgToGroup(rec.Group, "Unable to establish BAI battlespace.", 10) end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "CAS", root.A2G, function()
    local result = DeployGroundForces({ group = rec.Group, friendlyCoalition = rec.Group:GetCoalition() })
    if not result and TCS.MsgToGroup then TCS.MsgToGroup(rec.Group, "Unable to establish CAS battlespace.", 10) end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Laser On", root.A2G, function()
    if TCS.API and TCS.API.JTAC_LaserOn then
      TCS.API.JTAC_LaserOn({ group = rec.Group })
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "SEAD", root.A2G, function()
    local result = DeployAirDefenses({ group = rec.Group, minNm = 25, maxNm = 35 })
    if not result and TCS.MsgToGroup then TCS.MsgToGroup(rec.Group, "Unable to establish SEAD battlespace.", 10) end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "DEAD", root.A2G, function()
    local result = DeploySAM({ group = rec.Group, minNm = 25, maxNm = 35 })
    if not result and TCS.MsgToGroup then TCS.MsgToGroup(rec.Group, "Unable to establish DEAD battlespace.", 10) end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Strike", root.A2G, function()
    local result = DeployFacility({ group = rec.Group, minNm = 25, maxNm = 35 })
    if not result and TCS.MsgToGroup then TCS.MsgToGroup(rec.Group, "Unable to establish Strike battlespace.", 10) end
  end)
end
