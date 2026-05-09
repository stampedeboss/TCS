---------------------------------------------------------------------
-- TCS COMMON UTILITIES
---------------------------------------------------------------------
env.info("TCS(UTILS): loading")

TCS = TCS or {}
TCS.Utils = {}

function TCS.Utils.GetGroupName(group)
  return group and group.GetName and group:GetName() or nil
end

function TCS.Utils.ParseCallsign(playerName)
    if not playerName or playerName == "" then return nil end
    local callsign = playerName

    if string.find(callsign, "|") then
        local parts = {}
        for part in string.gmatch(callsign, "([^|]+)") do
            local trimmed_part = part:gsub("^%s*(.-)%s*$", "%1")
            if trimmed_part ~= "" then table.insert(parts, trimmed_part) end
        end

        if #parts > 0 then
            local firstPart = parts[1]
            local lastPart = parts[#parts]
            
            if firstPart:match("%s%d+%-%d+$") then callsign = firstPart
            elseif not lastPart:match("^[0-9]+$") then callsign = lastPart
            else callsign = firstPart end
        end
    end

    callsign = callsign:gsub("^%s*%[[^%]]+%]", "")
    callsign = callsign:gsub("^%s*%{[^%}]+%}", "")
    callsign = callsign:gsub("^%s*<[^>]+>", "")

    local idx_285 = string.find(callsign, "%[285%]")
    if idx_285 then callsign = callsign:sub(1, idx_285 - 1) end

    callsign = callsign:gsub("%s*%[[^%]]+%]", "")
    callsign = callsign:gsub("%s*%{[^%}]+%}", "")
    callsign = callsign:gsub("%s*<[^>]+>", "")
    callsign = callsign:gsub("%s*%(.-%)%s*$", "")
    callsign = callsign:gsub("^%s*(.-)%s*$", "%1")

    return (callsign ~= "") and callsign or nil
end

env.info("TCS(UTILS): ready")