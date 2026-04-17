---------------------------------------------------------------------
-- menus/suw.lua
---------------------------------------------------------------------
env.info("TCS(MENU): loading SUW")

function TCS.Menu.BuildSUW(rec)
  local g = rec.Group:GetName()
  local root = TCS.Menu.Groups[g]
  if not root or not root.SUW then return end

  MENU_GROUP_COMMAND:New(rec.Group, "Anti-Ship", root.SUW, function()
    if TCS.API and TCS.API.CreateSUW_AntiShip then
      TCS.API.CreateSUW_AntiShip({ group = rec.Group })
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Naval Strike", root.SUW, function()
    if TCS.API and TCS.API.CreateSUW_NavalStrike then
      TCS.API.CreateSUW_NavalStrike({ group = rec.Group })
    end
  end)

  MENU_GROUP_COMMAND:New(rec.Group, "Convoy Hunt", root.SUW, function()
    if TCS.API and TCS.API.CreateSUW_Convoy then
      TCS.API.CreateSUW_Convoy({ group = rec.Group })
    end
  end)
end