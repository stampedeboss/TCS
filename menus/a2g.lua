---------------------------------------------------------------------
-- menus/a2g.lua
---------------------------------------------------------------------
env.info("TCS(MENU): loading A2G")

function TCS.Menu.BuildA2G(rec)
  local g = rec.Group:GetName()
  local root = TCS.Menu.Groups[g]
  if not root then return end

  MENU_GROUP_COMMAND:New(rec.Group, "BAI", root.A2G, function()
    if TCS.API and TCS.API.CreateBAI then
      local anchor, reason = TCS.Placement.Resolve(rec.Unit, { domain = "LAND", conditions = { terrain = "FLAT", surface = "OPEN" } })
      if not anchor then
        TCS.A2G.Feedback.ToGroup(rec.Group, "Unable to establish BAI battlespace: " .. tostring(reason), 10)
        return
      end
      TCS.API.CreateBAI({ group = rec.Group, anchor = anchor })
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "CAS", root.A2G, function()
    if TCS.API and TCS.API.CreateCAS then
      local anchor, reason = TCS.Placement.Resolve(rec.Unit, { domain = "LAND", conditions = { terrain = "FLAT", surface = "OPEN" } })
      if not anchor then
        TCS.A2G.Feedback.ToGroup(rec.Group, "Unable to establish CAS battlespace: " .. tostring(reason), 10)
        return
      end
      TCS.API.CreateCAS({ group = rec.Group, anchor = anchor })
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Laser On", root.A2G, function()
    if TCS.API and TCS.API.JTAC_LaserOn then
      TCS.API.JTAC_LaserOn({ group = rec.Group })
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "SEAD", root.A2G, function()
    if TCS.API and TCS.API.CreateSEAD then
      local anchor, reason = TCS.Placement.Resolve(rec.Unit)
      if not anchor then
        TCS.A2G.Feedback.ToGroup(rec.Group, "Unable to establish SEAD battlespace: " .. tostring(reason), 10)
        return
      end
      TCS.API.CreateSEAD({ group = rec.Group, anchor = anchor })
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "DEAD", root.A2G, function()
    if TCS.API and TCS.API.CreateDEAD then
      local anchor, reason = TCS.Placement.Resolve(rec.Unit)
      if not anchor then
        TCS.A2G.Feedback.ToGroup(rec.Group, "Unable to establish DEAD battlespace: " .. tostring(reason), 10)
        return
      end
      TCS.API.CreateDEAD({ group = rec.Group, anchor = anchor })
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Strike", root.A2G, function()
    if TCS.API and TCS.API.CreateStrike then
      local anchor, reason = TCS.Placement.Resolve(rec.Unit)
      if not anchor then
        TCS.A2G.Feedback.ToGroup(rec.Group, "Unable to establish Strike battlespace: " .. tostring(reason), 10)
        return
      end
      TCS.API.CreateStrike({ group = rec.Group, anchor = anchor })
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Logistics", root.A2G, function()
    if TCS.API and TCS.API.CreateLogisticsRun then
      local anchor = TCS.Placement.Resolve(rec.Unit)
      TCS.API.CreateLogisticsRun({ group = rec.Group, destination = anchor })
    end
  end)
end
