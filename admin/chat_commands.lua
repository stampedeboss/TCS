---------------------------------------------------------------------
-- admin/chat_commands.lua
-- Handles all chat command logic for TCS.
---------------------------------------------------------------------
env.info("TCS(CHAT_COMMANDS): loading")

TCS = TCS or {}
TCS.Admin = TCS.Admin or {}

function TCS.Admin.OnChatCommand(playerID, msg)
  env.info("TCS(ADMIN): OnChatCommand called with msg: " .. tostring(msg))
  if not msg then return end

  local args = {}
  for part in string.gmatch(msg, "[^%s]+") do table.insert(args, part) end
  if #args == 0 then return end
  local rawCmd = string.lower(args[1])
  local prefix = string.sub(rawCmd, 1, 1)
  
  if prefix ~= "/" and prefix ~= "-" then return end
  local cmd = string.sub(rawCmd, 2)
  env.info("TCS(ADMIN): Parsed command: " .. tostring(cmd))

  if cmd == "tts" then
    local text = table.concat(args, " ", 2)
    if text == "" then text = "Radio check, one two, one two." end
    local label = (TCS.Config and TCS.Config.AWACS and TCS.Config.AWACS.Label) or "MAGIC"
    local display = string.format("%s. %s", label, text)
    if MESSAGE then MESSAGE:New("TCS TTS TEST (GLOBAL): " .. display, 10):ToAll() end
    if TCS.AWACS and TCS.AWACS.TestTTS then TCS.AWACS.TestTTS(text) end
    if net and net.send_chat_to then net.send_chat_to("TTS test sent.", playerID) end
  end

  -- LIST COMMANDS
  if cmd == "list" then
    local subCmd = string.lower(args[2] or "")
    
    if subCmd == "objects" then
      local prefix = "TCS_"
      local count = 0
      local output = {}

      local sides = { coalition.side.RED, coalition.side.BLUE, coalition.side.NEUTRAL }
      for _, side in ipairs(sides) do
        -- Groups
        local groups = coalition.getGroups(side) or {}
        for _, g in ipairs(groups) do
          if g and g:isExist() and string.sub(g:getName(), 1, #prefix) == prefix then
            table.insert(output, "GRP: " .. g:getName())
            count = count + 1
          end
        end
        -- Statics
        local statics = coalition.getStaticObjects(side) or {}
        for _, s in ipairs(statics) do
          if s and s:isExist() and string.sub(s:getName(), 1, #prefix) == prefix then
            table.insert(output, "STAT: " .. s:getName())
            count = count + 1
          end
        end
      end

      local msg = "TCS: Found " .. count .. " active spawns."
      if net and net.send_chat_to then net.send_chat_to(msg, playerID) end
      env.info(msg)

      for _, line in ipairs(output) do
        env.info(line)
        if count <= 20 and net and net.send_chat_to then
          net.send_chat_to(line, playerID)
        end
      end
      if count > 20 and net and net.send_chat_to then
        net.send_chat_to("... (Full list in dcs.log)", playerID)
      end
    
    elseif subCmd == "sessions" then
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
      if net and net.send_chat_to then net.send_chat_to(msg, playerID, 20) end

    elseif subCmd == "players" then
      local msg = "CONNECTED PLAYERS:\n"
      local players = net.get_player_list()
      for _, id in ipairs(players) do
        local pinfo = net.get_player_info(id)
        if pinfo then
          local callsign = TCS.SessionUtils.ParseCallsign(pinfo.name) or pinfo.name
          msg = msg .. string.format("- %s (Callsign: %s)\n", pinfo.name, callsign)
        end
      end
      if net and net.send_chat_to then net.send_chat_to(msg, playerID, 20) end

    else
      if net and net.send_chat_to then net.send_chat_to("Usage: /list [objects|sessions|players]", playerID) end
    end
  end

  -- JOIN COMMAND
  if cmd == "join" then
    local sessionName = args[2]
    if not sessionName then
      if net and net.send_chat_to then net.send_chat_to("Usage: /join <session_name>", playerID) end
      return
    end

    local pinfo = net.get_player_info(playerID)
    if pinfo and pinfo.unitId then
      local unit = UNIT:Find(pinfo.unitId)
      if unit and unit:IsAlive() then
        local group = unit:GetGroup()
        if group then
          TCS.SessionManager:JoinSession(sessionName, group)
          if net and net.send_chat_to then net.send_chat_to("Attempting to join session: " .. sessionName, playerID) end
        end
      end
    end
  end

  -- DESTROY COMMAND
  if cmd == "destroy" then
    local pinfo = net.get_player_info(playerID)
    if pinfo and pinfo.unitId then
      local unit = UNIT:Find(pinfo.unitId)
      if unit and unit:IsAlive() then
        local group = unit:GetGroup()
        if group then TerminateMyBandits(group) end
      end
    end
  end

  -- CLEANUP COMMAND
  if cmd == "cleanup" then
    local subCmd = string.lower(args[2] or "")
    if subCmd == "all" then -- Global cleanup is always admin-only
      if not TCS.SessionUtils.IsAdmin(playerID) then
        if net and net.send_chat_to then net.send_chat_to("You are not authorized to use this command.", playerID) end
        return
      end

      if net and net.send_chat_to then net.send_chat_to("Executing global cleanup of all TCS objects...", playerID) end

      if TCS.A2A and TCS.A2A.CleanupAllSpawns then TCS.A2A.CleanupAllSpawns() end
      if TCS.A2G and TCS.A2G.CleanupAllSpawns then TCS.A2G.CleanupAllSpawns() end

    else
      if net and net.send_chat_to then net.send_chat_to("Usage: /cleanup all", playerID) end
    end
  end

  -- UCID COMMAND
  if cmd == "myucid" then
    local pinfo = net.get_player_info(playerID)
    if pinfo and pinfo.ucid then
      if net and net.send_chat_to then net.send_chat_to("Your UCID: " .. pinfo.ucid, playerID) end
      env.info("TCS(ADMIN): Player " .. pinfo.name .. " requested UCID: " .. pinfo.ucid)
    end
  end

  -- FARP COMMAND
  if cmd == "farp" then
    if not TCS.SessionUtils.IsAdmin(playerID) then
       if net and net.send_chat_to then net.send_chat_to("You are not authorized to use this command.", playerID) end
       return
    end

    local pinfo = net.get_player_info(playerID)
    local playerUnit = nil
    if pinfo then
       local units = coalition.getPlayers(pinfo.side)
       for _, u in ipairs(units) do
          if u:getPlayerName() == pinfo.name then
             playerUnit = u
             break
          end
       end
    end

    if playerUnit and playerUnit:isExist() then
        local coord = playerUnit:getPoint()
        local heading = 0
        if playerUnit.getHeading then heading = playerUnit:getHeading() end
        local side = playerUnit:getCoalition()
        
        local farpName = "TCS_DYN_FARP_" .. math.random(100000)
        
        local farpData = {
          type = "Invisible FARP",
          name = farpName,
          x = coord.x,
          y = coord.z,
          heading = heading,
          category = "Heliports",
        }
        
        if TCS.Spawn and TCS.Spawn.StaticFromData then
           TCS.Spawn.StaticFromData(farpData, side)
           
           -- Support Assets
           local supportName = farpName .. "_SUP"
           local offX = coord.x + 40 * math.cos(heading)
           local offY = coord.z + 40 * math.sin(heading)
           
           local fuel = (side == coalition.side.RED) and "ATMZ-5" or "M978 HEMTT Tanker"
           local ammo = (side == coalition.side.RED) and "Ural-375" or "M818"
           local cmdType  = (side == coalition.side.RED) and "UAZ-469" or "HMMWV1025"
           
           local groupData = {
             name = supportName,
             task = "Ground Nothing",
             units = {
               [1] = { name=supportName.."_1", type=cmdType, x=offX, y=offY, heading=heading, skill="High" },
               [2] = { name=supportName.."_2", type=ammo, x=offX+10, y=offY+10, heading=heading, skill="High" },
               [3] = { name=supportName.."_3", type=fuel, x=offX-10, y=offY+10, heading=heading, skill="High" },
             }
           }
           
           TCS.Spawn.GroupFromData(groupData, Group.Category.GROUND, side)
           
           if net and net.send_chat_to then net.send_chat_to("FARP created at your location.", playerID) end
           env.info("TCS(ADMIN): FARP spawned at " .. farpName)
        end
    else
        if net and net.send_chat_to then net.send_chat_to("Could not find your unit.", playerID) end
    end
  end

  -- DEBUG COMMAND
  if cmd == "debug" then
    local subCmd = string.lower(args[2] or "")
    if subCmd == "session" then
      local pinfo = net.get_player_info(playerID)
      if pinfo and pinfo.unitId then
        local unit = UNIT:Find(pinfo.unitId)
        if unit and unit:IsAlive() then
          local group = unit:GetGroup()
          local session = TCS.SessionManager:GetSessionForGroup(group)
          local msg = session and ("Current session name: '" .. session.Name .. "'") or "Not in a session."
          if net and net.send_chat_to then net.send_chat_to(msg, playerID) end
        end
      end
    end
  end
end

env.info("TCS(CHAT_COMMANDS): ready")