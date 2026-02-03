---------------------------------------------------------------------
-- SUW MENUS
---------------------------------------------------------------------
env.info("TCS(MENU): loading SUW")

function TCS.Menu.BuildSUW(group)
  if not group then return end
  local gname = group:GetName()
  local root = TCS.Menu.Groups[gname]
  if not root or not root.SUW then return end

  MENU_GROUP_COMMAND:New(group, "Anti-Ship",    root.SUW, TCS.SUW.StartAntiShip, group)
  MENU_GROUP_COMMAND:New(group, "Naval Strike", root.SUW, TCS.SUW.StartStrike,   group)
  MENU_GROUP_COMMAND:New(group, "Convoy",       root.SUW, TCS.SUW.StartConvoy,   group)
end
