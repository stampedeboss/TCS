---------------------------------------------------------------------
-- menus/a2a.lua
---------------------------------------------------------------------
env.info("TCS(MENU): loading A2A")

function TCS_MENU.BuildA2A(rec)
  local g = rec.Group:GetName()
  local root = TCS_MENU.Groups[g]
  if not root then return end

  MENU_GROUP_COMMAND:New(rec.Group, "Intercept", root.A2A, function()
    if A2A and A2A.StartIntercept then
      A2A.StartIntercept(rec)
    end
  end)
end
