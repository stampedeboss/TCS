---------------------------------------------------------------------
-- menus/root.lua
---------------------------------------------------------------------
env.info("TCS(MENU): loading root")

TCS.Menu = TCS.Menu or {}
TCS.Menu.Groups = TCS.Menu.Groups or {}

function TCS.Menu.BuildRoot(group)
  local gname = group:GetName()
  
  -- We overwrite the entry to ensure we are using the fresh Group object 
  -- provided by the current Birth event.
  local root = MENU_GROUP:New(group, "TCS")

  TCS.Menu.Groups[gname] = {
    ROOT     = root,
    TRAINING = MENU_GROUP:New(group, "TRAINING", root),
    A2A      = MENU_GROUP:New(group, "A2A", root),
    A2G      = MENU_GROUP:New(group, "A2G", root),
    -- Added missing parents for SUW and MAR
    SUW      = MENU_GROUP:New(group, "SUW", root),
    MAR      = MENU_GROUP:New(group, "MARITIME", root),
    ADMIN    = MENU_GROUP:New(group, "ADMIN", root),
  }
end