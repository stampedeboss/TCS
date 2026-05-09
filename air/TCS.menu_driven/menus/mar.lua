---------------------------------------------------------------------
-- MAR MENUS
---------------------------------------------------------------------
env.info("TCS(MENU): loading MAR")

function TCS.Menu.BuildMAR(group)
  if not group then return end
  local gname = group:GetName()
  local root = TCS.Menu.Groups[gname]
  if not root or not root.MAR then return end

  MENU_GROUP_COMMAND:New(group, "Harbor",   root.MAR, TCS.MAR.StartHarbor,   group)
  MENU_GROUP_COMMAND:New(group, "Shipping", root.MAR, TCS.MAR.StartShipping, group)
end
