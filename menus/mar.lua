---------------------------------------------------------------------
-- menus/mar.lua
---------------------------------------------------------------------
env.info("TCS(MENU): loading MAR")

function TCS.Menu.BuildMAR(rec)
  local g = rec.Group:GetName()
  local root = TCS.Menu.Groups[g]
  if not root or not root.MAR then return end

  MENU_GROUP_COMMAND:New(rec.Group, "Harbor Control", root.MAR, function()
    if TCS.API and TCS.API.CreateMAR_Harbor then
      TCS.API.CreateMAR_Harbor({ group = rec.Group })
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Shipping Lane", root.MAR, function()
    if TCS.API and TCS.API.CreateMAR_Shipping then
      TCS.API.CreateMAR_Shipping({ group = rec.Group })
    end
  end)
end