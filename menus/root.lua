---------------------------------------------------------------------
-- menus/root.lua
---------------------------------------------------------------------
env.info("TCS(MENU): loading root")

TCS.Menu = TCS.Menu or {}
TCS.Menu.Groups = TCS.Menu.Groups or {}

function TCS.Menu.BuildRoot(group)
  if not group then return end
  local gname = group:GetName()
  
  -- We overwrite the entry to ensure we are using the fresh Group object 
  -- provided by the current Birth event.
  local root = MENU_GROUP:New(group, "TCS")
  
  -- =========================================================
  -- MODULE MENUS
  -- =========================================================
  local m_training = MENU_GROUP:New(group, "TRAINING", root)
  local m_a2a      = MENU_GROUP:New(group, "A2A", root)
  local m_a2g      = MENU_GROUP:New(group, "A2G", root)
  local m_suw      = MENU_GROUP:New(group, "SUW", root)
  local m_mar      = MENU_GROUP:New(group, "MARITIME", root)

  -- Add FARP command for Helicopters
  if group:GetCategory() == Group.Category.HELICOPTER then
    MENU_GROUP_COMMAND:New(group, "Deploy FARP", m_a2g, function()
      local unit = group:GetUnit(1)
      if unit then
        local coord = unit:GetCoordinate()
        local heading = unit:GetHeading()
        local side = group:GetCoalition()
        
        if TCS.Logistics and TCS.Logistics.SpawnFARP then
            TCS.Logistics.SpawnFARP(coord, math.rad(heading), side)
            MESSAGE:New("FARP deployed at your location.", 10):ToGroup(group)
        end
      end
    end)
  end

  local m_admin = MENU_GROUP:New(group, "ADMIN", root)

  TCS.Menu.Groups[gname] = {
    ROOT     = root,
    TRAINING = m_training,
    A2A      = m_a2a,
    A2G      = m_a2g,
    SUW      = m_suw,
    MAR      = m_mar,
    ADMIN    = m_admin,
  }
end