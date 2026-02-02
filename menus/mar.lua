---------------------------------------------------------------------
-- MAR MENUS
---------------------------------------------------------------------
env.info("TCS(MENU): loading MAR")

function TCS_MENU.BuildMAR(group)
  if not group then return end

  MENU_GROUP_COMMAND:New(group, "Harbor",   TCS_MENU.MAR_HARBOR,   TCS.MAR.StartHarbor,   group)
  MENU_GROUP_COMMAND:New(group, "Shipping", TCS_MENU.MAR_SHIPPING, TCS.MAR.StartShipping, group)
end
