---------------------------------------------------------------------
-- a2a/controller.lua
-- Provides AWACS/GCI functionality for A2A scenarios.
---------------------------------------------------------------------
env.info("TCS(A2A.CONTROLLER): loading")

TCS = TCS or {}
TCS.A2A = TCS.A2A or {}

local CFG = TCS.A2A.Config
local AWACS_CFG = TCS.Config and TCS.Config.AWACS
local UPDATE_INTERVAL = 30 -- Seconds between automatic BRAA updates

-- Helper to resolve BRAA string from either a Coordinate or a Group/Unit
local function ResolveBraa(refUnit, target)
  if not refUnit or not refUnit:IsAlive() then return nil end
  if not target then return nil end

  -- If target is a Group or Unit, use the full BRAA with Aspect
  if (type(target) == "table" and (target.ClassName == "GROUP" or target.ClassName == "UNIT")) then
    if target:IsAlive() then
      return TCS.A2A.BraaText({Unit=refUnit}, target)
    end
    return nil
  end

  -- If target is a Coordinate (fallback for simple BRA)
  if target.GetVec3 then
    local p = refUnit:GetCoordinate()
    local bearing = math.floor((p:HeadingTo(target) % 360) + 0.5)
    local rangeNM = math.floor((p:Get2DDistance(target) * 0.000539957) + 0.5)
    local vec3 = target:GetVec3()
    local altFt = math.floor((vec3.y * 3.28084 / 1000) + 0.5) * 1000
    return string.format("BRA %03d for %d, %d thousand", bearing, rangeNM, altFt/1000)
  end

  return nil
end

-- Helper to parse player names (Ported from carrier_ops.lua)
local function ParseCallsign(playerName)
    if not playerName or playerName == "" then return "Unknown" end

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

    -- 6. Fallback to original name if parsing results in an empty string
    callsign = (callsign ~= "") and callsign or playerName

    -- 7. Ensure tactical suffix (e.g. " 1-1") exists
    if not callsign:match("%s%d+%-%d+$") then
        callsign = callsign .. " 1-1"
    end

    return callsign
end

local function GetCallsign(unit, group)
  -- 1. Try Player Name
  local playerName = nil
  if unit and unit.GetPlayerName then playerName = unit:GetPlayerName() end
  if not playerName and group and group.GetPlayerName then playerName = group:GetPlayerName() end
  
  if playerName then return ParseCallsign(playerName) end

  -- 2. Try Unit Callsign (DCS standard for AI)
  if unit and unit.GetCallsign then
    local cs = unit:GetCallsign()
    if cs and cs ~= "" then return cs end
  end

  -- 3. Fallback to Group Name
  if group then return group:GetName() end
  return "Unknown"
end

-- Single Call
function TCS.A2A.AwacsControllerCallBraa(group, unit, target, label, subLabel, state)
  if not group then return end
  local u = unit or group:GetUnit(1)
  if not u then return end
  
  local braa = ResolveBraa(u, target)
  if braa then
    local awacsLabel = (AWACS_CFG and AWACS_CFG.Label) or "MAGIC"
    local callsign = GetCallsign(u, group)
    local text = string.format("%s: %s, %s. %s", awacsLabel, callsign, label, braa)
    if subLabel and subLabel ~= "" then text = text .. ", " .. subLabel end
    if state and state ~= "" then text = text .. ". " .. state end
    
    MESSAGE:New(text, 10):ToGroup(group)
    if TCS.AWACS and TCS.AWACS.Say then TCS.AWACS.Say(text) end
  end
end

-- Dispatch/Tasking Call (e.g. for Sweep PUSH)
function TCS.A2A.AwacsDispatchNATO(group, unit, location, action, type)
  if not group then return end
  local locStr = (location and location.ToStringBullseye) and location:ToStringBullseye() or "Target"
  local awacsLabel = (AWACS_CFG and AWACS_CFG.Label) or "MAGIC"
  local callsign = GetCallsign(unit or group:GetUnit(1), group)
  local text = string.format("%s: %s, %s %s at %s.", awacsLabel, callsign, action, type, locStr)
  MESSAGE:New(text, 15):ToGroup(group)
  if TCS.AWACS and TCS.AWACS.Say then TCS.AWACS.Say(text) end
end

-- Session-based Periodic Updater
function TCS.A2A.StartAwacsUpdatesSession(session, targetResolver, label, state)
  if not session then return end
  
  local function update()
    if not session.ActiveScenarios then return end -- Session ended?
    
    -- Find a valid target (Group or Coord)
    local target = targetResolver()
    if not target then return end 
    
    -- Broadcast to session using Lead as reference
    local leadName = session.LeadGroupName
    local leadGroup = leadName and GROUP:FindByName(leadName)
    if leadGroup then
       local u = leadGroup:GetUnit(1)
       if u and u:IsAlive() then
          local braa = ResolveBraa(u, target)
          if braa then
             local awacsLabel = (AWACS_CFG and AWACS_CFG.Label) or "MAGIC"
             local callsign = GetCallsign(u, leadGroup)
             local text = string.format("%s: %s, %s. %s", awacsLabel, callsign, label, braa)
             TCS.A2A.NotifySession(session, text, 10)
          end
       end
    end
    
    timer.scheduleFunction(update, nil, timer.getTime() + UPDATE_INTERVAL)
  end
  
  timer.scheduleFunction(update, nil, timer.getTime() + UPDATE_INTERVAL)
end

-- Group-based Periodic Updater (Legacy)
function TCS.A2A.StartAwacsUpdates(group, unit, targetResolver, label, state)
  if not group then return end
  
  local function update()
    if not group or not group:IsAlive() then return end
    local u = unit or group:GetUnit(1)
    
    local target = targetResolver()
    if not target then return end
    
    local braa = ResolveBraa(u, target)
    if braa then
       local awacsLabel = (AWACS_CFG and AWACS_CFG.Label) or "MAGIC"
       local callsign = GetCallsign(u, group)
       local text = string.format("%s: %s, %s. %s", awacsLabel, callsign, label, braa)
       MESSAGE:New(text, 10):ToGroup(group)
       if TCS.AWACS and TCS.AWACS.Say then TCS.AWACS.Say(text) end
    end
    
    timer.scheduleFunction(update, nil, timer.getTime() + UPDATE_INTERVAL)
  end
  
  timer.scheduleFunction(update, nil, timer.getTime() + UPDATE_INTERVAL)
end

-- Placeholder for AutoManage if needed by modules (currently logic is inside modules or unused)
function TCS.A2A.AutoManageBandits_Controller(rec, spawnedGroups, label, isOverFunc, onUpdate, session)
  -- Logic handled by periodic updates + module lifecycle
end

env.info("TCS(A2A.CONTROLLER): ready")