---------------------------------------------------------------------
-- TCS CORE: ADMIN (Battlefield Commander)
-- Authority + signaling only. No tasking, no spawning.
---------------------------------------------------------------------
env.info("TCS(ADMIN): loading")

TCS = TCS or {}
TCS.Admin = TCS.Admin or {}

---------------------------------------------------------------------
-- Routing (NO domain logic here)
---------------------------------------------------------------------
function TCS.Admin.RouteOrder(order)
  if not order or not order.type then return end

  -- A2G-related conditions
  if order.type == "CAS_OVERRUN"
  or order.type == "IADS_ACTIVE"
  or order.type == "STRIKE_DELAYED" then
    if TCS.A2G and TCS.A2G.OnAdminOrder then
      TCS.A2G.OnAdminOrder(order)
    end
  end

  -- A2A-related conditions
  if order.type == "AIR_SUPERIORITY_THREAT"
  or order.type == "ESCORT_REQUIRED" then
    if TCS.A2A and TCS.A2A.OnAdminOrder then
      TCS.A2A.OnAdminOrder(order)
    end
  end

  -- Maritime (civilian)
  if order.type == "SHIPPING_THREATENED"
  or order.type == "PORT_UNDER_THREAT" then
    if TCS.MAR and TCS.MAR.OnAdminOrder then
      TCS.MAR.OnAdminOrder(order)
    end
  end

  -- Naval combat
  if order.type == "SUW_CONTACT_DETECTED" then
    if TCS.SUW and TCS.SUW.OnAdminOrder then
      TCS.SUW.OnAdminOrder(order)
    end
  end
end

---------------------------------------------------------------------
-- Chat Command Handler
---------------------------------------------------------------------
function TCS.Admin.OnChatCommand(playerID, msg)
  if msg and string.sub(msg, 1, 1) == "/" then env.info("TCS(ADMIN): OnChatCommand received: " .. msg) end
  if not msg or string.sub(msg, 1, 1) ~= "/" then return end

  local args = {}
  for part in string.gmatch(msg, "[^%s]+") do table.insert(args, part) end
  local cmd = string.lower(args[1])

  if cmd == "/tts" then
    local text = table.concat(args, " ", 2)
    if text == "" then text = "Radio check, one two, one two." end
    local label = (TCS.Config and TCS.Config.AWACS and TCS.Config.AWACS.Label) or "MAGIC"
    local display = string.format("%s. %s", label, text)
    if MESSAGE then MESSAGE:New("TCS TTS TEST (GLOBAL): " .. display, 10):ToAll() end
    if TCS.AWACS and TCS.AWACS.TestTTS then TCS.AWACS.TestTTS(text) end
    if net and net.send_chat_to then net.send_chat_to("TTS test sent.", playerID) end
  end

  -- LIST COMMANDS
  if cmd == "/list" then
    local subCmd = string.lower(args[2] or "")
    
    if subCmd == "objects" then
      local prefix = "TCS_"
      local count = 0
      local output = {}

      if SET_GROUP then
        SET_GROUP:New():ForEach(function(g)
          if g and g:IsAlive() and string.sub(g:GetName(), 1, #prefix) == prefix then
            table.insert(output, "GRP: " .. g:GetName())
            count = count + 1
          end
        end)
      end

      if SET_STATIC then
        SET_STATIC:New():ForEach(function(s)
          if s and s:IsAlive() and string.sub(s:GetName(), 1, #prefix) == prefix then
            table.insert(output, "STAT: " .. s:GetName())
            count = count + 1
          end
        end)
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
  if cmd == "/join" then
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
  if cmd == "/destroy" then
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
  if cmd == "/cleanup" then
    local subCmd = string.lower(args[2] or "")
    if subCmd == "all" then
      if not IsAdmin(playerID) then
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

end

env.info("TCS(ADMIN): ready")
