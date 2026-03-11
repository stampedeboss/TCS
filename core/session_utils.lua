env.info("TCS(SESSION.UTILS): loading")

TCS = TCS or {}
TCS.SessionUtils = {}

function TCS.SessionUtils.GetGroupName(group)
  return group and group.GetName and group:GetName() or nil
end

function TCS.SessionUtils.ParseCallsign(playerName)
    if not playerName or playerName == "" then return nil end

    local callsign = playerName

    -- 1. Handle the '|' separator (often a player name or tag separator)
    if string.find(callsign, "|") then
        local parts = {}
        -- Split the string by '|' and collect non-empty, trimmed parts
        for part in string.gmatch(callsign, "([^|]+)") do
            local trimmed_part = part:gsub("^%s*(.-)%s*$", "%1")
            if trimmed_part ~= "" then
                table.insert(parts, trimmed_part)
            end
        end

        if #parts > 0 then
            local firstPart = parts[1]
            local lastPart = parts[#parts]
            
            -- Heuristic 1: If first part looks like a tactical callsign (e.g. "Viper 1-1"), prefer it.
            if firstPart:match("%s%d+%-%d+$") then
                callsign = firstPart
            -- Heuristic 2: If the last part is not purely numeric, assume it's the callsign (e.g. "Squadron | Name").
            elseif not lastPart:match("^[0-9]+$") then
                callsign = lastPart
            -- Heuristic 3: Otherwise (e.g. "Name | Modex"), use the first part.
            else
                callsign = firstPart
            end
        end
    end

    -- 2. Remove leading common tags/prefixes like [TAG], {TAG}, <TAG>
    callsign = callsign:gsub("^%s*%[[^%]]+%]", "") -- Remove leading [TAG]
    callsign = callsign:gsub("^%s*%{[^%}]+%}", "") -- Remove leading {TAG}
    callsign = callsign:gsub("^%s*<[^>]+>", "")   -- Remove leading <TAG>

    -- 3. Special Rule: If [285] is found (and wasn't leading), strip it and everything after
    local idx_285 = string.find(callsign, "%[285%]")
    if idx_285 then
        callsign = callsign:sub(1, idx_285 - 1)
    end

    -- 4. Remove remaining clan tags and similar constructs from anywhere
    callsign = callsign:gsub("%s*%[[^%]]+%]", "") -- [TAG]
    callsign = callsign:gsub("%s*%{[^%}]+%}", "") -- {TAG}
    callsign = callsign:gsub("%s*<[^>]+>", "")   -- <TAG>
    
    -- 5. Remove trailing parenthetical info & Final trim
    callsign = callsign:gsub("%s*%(.-%)%s*$", "") -- Remove trailing ()
    callsign = callsign:gsub("^%s*(.-)%s*$", "%1")

    -- 6. Fallback to nil if parsing results in an empty string
    return (callsign ~= "") and callsign or nil
end

---------------------------------------------------------------------
-- Admin Check
---------------------------------------------------------------------
function TCS.SessionUtils.IsAdmin(playerID)
  if not net then return true end -- Offline/Singleplayer always admin
  
  local admins = (TCS.Config and TCS.Config.Admins) or {}
  if #admins == 0 then return true end -- If no admins defined, everyone is an admin.
  
  local pinfo = net.get_player_info(playerID)
  if not pinfo or not pinfo.ucid then return false end
  for _, ucid in ipairs(admins) do
    if pinfo.ucid == ucid then return true end
  end
  return false
end

env.info("TCS(SESSION.UTILS): ready")