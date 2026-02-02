---------------------------------------------------------------------
-- menus/admin.lua
---------------------------------------------------------------------
env.info("TCS(MENU): loading ADMIN")

function TCS_MENU.BuildAdmin(rec)
  local g = rec.Group:GetName()
  local root = TCS_MENU.Groups[g]
  if not root then return end

  MENU_GROUP_COMMAND:New(rec.Group, "Leave Session", root.ADMIN, function()
    if SESSION then SESSION:Leave(rec) end
  end)
end
