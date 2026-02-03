---------------------------------------------------------------------
-- menus/admin.lua
---------------------------------------------------------------------
env.info("TCS(MENU): loading ADMIN")

function TCS.Menu.BuildAdmin(rec)
  local g = rec.Group:GetName()
  local root = TCS.Menu.Groups[g]
  if not root then return end

  MENU_GROUP_COMMAND:New(rec.Group, "Leave Session", root.ADMIN, function()
    if SESSION then SESSION:Leave(rec) end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Reset All Menus", root.ADMIN, function()
    if PLAYERS and PLAYERS.ByName and TCS.Menu and TCS.Menu.BuildForPlayer then
      for _, p in pairs(PLAYERS.ByName) do
        TCS.Menu.BuildForPlayer(p)
      end
      MESSAGE:New("All menus reset.", 10):ToGroup(rec.Group)
    end
  end)
end
