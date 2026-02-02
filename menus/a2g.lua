---------------------------------------------------------------------
-- menus/a2g.lua
---------------------------------------------------------------------
env.info("TCS(MENU): loading A2G")

function TCS_MENU.BuildA2G(rec)
  local g = rec.Group:GetName()
  local root = TCS_MENU.Groups[g]
  if not root then return end

  MENU_GROUP_COMMAND:New(rec.Group, "BAI", root.A2G, function()
    if A2G_BAI and A2G_BAI.Start then
      A2G_BAI.Start(rec)
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "CAS", root.A2G, function()
    if A2G_CAS and A2G_CAS.Start then
      A2G_CAS.Start(rec)
    end
  end)
end
