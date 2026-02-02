---------------------------------------------------------------------
-- SUW MENUS
---------------------------------------------------------------------
env.info("TCS(MENU): loading SUW")

function TCS_MENU.BuildSUW(group)
  if not group then return end

  MENU_GROUP_COMMAND:New(group, "Anti-Ship",    TCS_MENU.SUW, TCS.SUW.StartAntiShip, group)
  MENU_GROUP_COMMAND:New(group, "Naval Strike", TCS_MENU.SUW, TCS.SUW.StartStrike,   group)
  MENU_GROUP_COMMAND:New(group, "Convoy",       TCS_MENU.SUW, TCS.SUW.StartConvoy,   group)
end
