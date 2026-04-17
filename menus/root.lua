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
  local m_tasking  = MENU_GROUP:New(group, "TASKING", root)

  -- Add FARP command for Helicopters
  if group:GetCategory() == Group.Category.HELICOPTER then
    MENU_GROUP_COMMAND:New(group, "Deploy FARP", m_a2g, function()
      local unit = group:GetUnit(1)
      if unit then
        local coord = unit:GetCoordinate()
        local heading = unit:GetHeading()
        local side = group:GetCoalition()
        
        local farpName = "TCS_DYN_FARP_" .. math.random(100000)
        
        local farpData = {
          type = "Invisible FARP",
          name = farpName,
          x = coord.x,
          y = coord.z,
          heading = math.rad(heading),
          category = "Heliports",
        }
        
        if TCS.Spawn and TCS.Spawn.StaticFromData then
           TCS.Spawn.StaticFromData(farpData, side)
           
           -- Support Assets
           local supportName = farpName .. "_SUP"
           local offCoord = coord:Translate(30, heading)
           local offX = offCoord.x
           local offY = offCoord.z
           
           local fuel = (side == coalition.side.RED) and "ATMZ-5" or "M978 HEMTT Tanker"
           local ammo = (side == coalition.side.RED) and "Ural-375" or "M818"
           local cmdType  = (side == coalition.side.RED) and "SKP-11" or "M1025 HMMWV"
           local pwrType  = (side == coalition.side.RED) and "APA-5D" or "M1025 HMMWV"
           
           local groupData = {
             name = supportName,
             task = "Ground Nothing",
             units = {
               [1] = { name=supportName.."_1", type=cmdType, x=offX, y=offY, heading=math.rad(heading), skill="High" },
               [2] = { name=supportName.."_2", type=ammo, x=offX+8, y=offY+8, heading=math.rad(heading), skill="High" },
               [3] = { name=supportName.."_3", type=fuel, x=offX-8, y=offY+8, heading=math.rad(heading), skill="High" },
               [4] = { name=supportName.."_4", type=pwrType, x=offX, y=offY+15, heading=math.rad(heading), skill="High" },
             }
           }
           
           TCS.Spawn.GroupFromData(groupData, Group.Category.GROUND, side)
           
           local _gp = Group.getByName(supportName)
           if _gp then
             _gp:getController():setCommand({id = 'SetImmortal', params = {value = true}})
           end

           MESSAGE:New("FARP deployed at your location.", 10):ToGroup(group)
        end
      end
    end)
  end

  local m_session  = MENU_GROUP:New(group, "SESSION", root)
  local m_admin = MENU_GROUP:New(group, "ADMIN", root)

  -- =========================================================
  -- SESSION MANAGEMENT
  -- =========================================================
  MENU_GROUP_COMMAND:New(group, "Start Session", m_session, function()
    local s = TCS.SessionManager:GetOrCreateSessionForGroup(group)
    if s then
      MESSAGE:New("Session '" .. s.Name .. "' is active.", 10):ToGroup(group)
    end
  end)

  -- List Sessions
  MENU_GROUP_COMMAND:New(group, "List Sessions", m_session, function()
    local sessions = TCS.SessionManager:GetAllSessions()
    local msg = "ACTIVE SESSIONS:\n"
    local count = 0
    for name, s in pairs(sessions) do
      local mCount = 0
      for _ in pairs(s.Members) do mCount = mCount + 1 end
      msg = msg .. string.format("- %s (Lead: %s, Members: %d)\n", name, s.LeadGroupName or "None", mCount)
      count = count + 1
    end
    if count == 0 then msg = "No active sessions." end
    MESSAGE:New(msg, 20):ToGroup(group)
  end)

  -- Join Existing (Dynamic Menu)
  local m_join = MENU_GROUP:New(group, "Join Session...", m_session)
  
  MENU_GROUP_COMMAND:New(group, "Refresh List", m_join, function()
    local rec = PLAYERS and PLAYERS:GetByGroup(group)
    if rec and TCS.Menu and TCS.Menu.BuildForPlayer then
       TCS.Menu.BuildForPlayer(rec)
       MESSAGE:New("Menu refreshed.", 5):ToGroup(group)
    end
  end)

  local sessions = TCS.SessionManager:GetAllSessions()
  for name, s in pairs(sessions) do
    MENU_GROUP_COMMAND:New(group, "Join " .. name, m_join, function()
       if TCS.SessionManager and TCS.SessionManager.JoinSession then
         -- Directly call the new session manager
         TCS.SessionManager:JoinSession(name, group)
       end
    end)
  end

  -- Advertise
  MENU_GROUP_COMMAND:New(group, "Advertise Session", m_session, function()
    local s = TCS.SessionManager:GetSessionForGroup(group)
    if s then
      MESSAGE:New(group:GetName() .. " is inviting players to join Session " .. s.Name, 15):ToAll()
    else
      MESSAGE:New("You are not in a session.", 5):ToGroup(group)
    end
  end)

  -- Status
  MENU_GROUP_COMMAND:New(group, "Status", m_session, function()
    local s = TCS.SessionManager:GetSessionForGroup(group)
    if s then
      local msg = "SESSION STATUS: " .. s.Name .. "\n"
      msg = msg .. "LEAD: " .. (s.LeadGroupName or "None") .. "\n"
      msg = msg .. "MEMBERS:\n"
      for mName, _ in pairs(s.Members) do
        msg = msg .. " - " .. mName .. "\n"
      end
      MESSAGE:New(msg, 15):ToGroup(group)
    else
      MESSAGE:New("You are not in a session.", 5):ToGroup(group)
    end
  end)

  -- Pass Lead
  MENU_GROUP_COMMAND:New(group, "Pass Lead", m_session, function()
    local s = TCS.SessionManager:GetSessionForGroup(group)
    if s and s:IsLead(group:GetName()) then
      local newLead = nil
      for m in pairs(s.Members) do
        if m ~= group:GetName() then
          local g = GROUP:FindByName(m)
          if g and g:IsAlive() then newLead = m; break end
        end
      end
      if newLead then
        s.LeadGroupName = newLead
        MESSAGE:New("Leadership passed to " .. newLead, 10):ToGroup(group)
        local g = GROUP:FindByName(newLead)
        if g then MESSAGE:New("You are now Session LEAD.", 10):ToGroup(g) end
      else
        MESSAGE:New("No other members to promote.", 5):ToGroup(group)
      end
    end
  end)

  -- Set Difficulty (Lead Only)
  local m_diff = MENU_GROUP:New(group, "Set Difficulty", m_session)
  local diffs = {
    { key="A", label="Beginner (A)" },
    { key="G", label="Standard (G)" },
    { key="H", label="Advanced (H)" },
    { key="X", label="Expert (X)" }
  }
  for _, d in ipairs(diffs) do
    MENU_GROUP_COMMAND:New(group, d.label, m_diff, function()
      local s = TCS.SessionManager:GetSessionForGroup(group)
      if s and s:IsLead(group:GetName()) then
        TCS.SetSessionDifficulty(s, d.key)
        MESSAGE:New("Session Difficulty set to: " .. d.label, 10):ToGroup(group)
      else
        MESSAGE:New("Only the Session Lead can change difficulty.", 5):ToGroup(group)
      end
    end)
  end

  -- Leave
  MENU_GROUP_COMMAND:New(group, "Leave Session", m_session, function()
    if TCS.SessionManager and TCS.SessionManager.LeaveSession then
      TCS.SessionManager:LeaveSession(group)
    end
  end)

  TCS.Menu.Groups[gname] = {
    ROOT     = root,
    SESSION  = m_session,
    TRAINING = m_training,
    A2A      = m_a2a,
    A2G      = m_a2g,
    SUW      = m_suw,
    MAR      = m_mar,
    TASKING  = m_tasking,
    ADMIN    = m_admin,
  }
end