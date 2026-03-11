---------------------------------------------------------------------
-- menus/tasking.lua
-- Dynamic Tasking Board Menu
---------------------------------------------------------------------
env.info("TCS(MENU): loading TASKING")

local Config = TCS.Config or {}
local TaskingConfig = Config.Tasking or {}

local INFO_DURATION = TaskingConfig.INFO_DURATION or 30
local ACTION_DURATION = TaskingConfig.ACTION_DURATION or 10
local NOTIFICATION_DURATION = TaskingConfig.NOTIFICATION_DURATION or 20
local REFRESH_INTERVAL = TaskingConfig.REFRESH_INTERVAL or 5

local function _safeSort(a, b)
  if type(a) == "number" and type(b) == "number" then return a < b end
  return tostring(a) < tostring(b)
end

function TCS.Menu.BuildTasking(rec)
  local g = rec.Group:GetName()
  local root = TCS.Menu.Groups[g]
  if not root or not root.TASKING then return end
  
  local m = root.TASKING
  
  -- Clear previous dynamic menus if tracked
  if rec.Menus and rec.Menus.Tasking then
    for _, cmd in ipairs(rec.Menus.Tasking) do
      cmd:Remove()
    end
  end
  rec.Menus = rec.Menus or {}
  rec.Menus.Tasking = {}

  -- Refresh Command
  local cmdRefresh = MENU_GROUP_COMMAND:New(rec.Group, "Refresh Board", m, function()
    TCS.Menu.BuildTasking(rec)
  end)
  table.insert(rec.Menus.Tasking, cmdRefresh)

  -- Repeat Last Tasking
  local cmdRepeat = MENU_GROUP_COMMAND:New(rec.Group, "Repeat Last Tasking", m, function()
    if TCS.A2G and TCS.A2G.JTAC and TCS.A2G.JTAC.RepeatTasking then
      TCS.A2G.JTAC.RepeatTasking(rec.Group)
    end
  end)
  table.insert(rec.Menus.Tasking, cmdRepeat)

  -- List Taskings
  local taskings = TCS.Controller and TCS.Controller.Taskings or {}
  local count = 0
  local ids = {}
  for id, _ in pairs(taskings) do table.insert(ids, id) end
  table.sort(ids, _safeSort)
  local sig = ""

  for _, id in ipairs(ids) do
    local t = taskings[id]
    count = count + 1
    sig = sig .. tostring(id) .. ","
    local label = string.format("[%d] %s", id, t.Type)
    local sub = MENU_GROUP:New(rec.Group, label, m)
    table.insert(rec.Menus.Tasking, sub)
    
    MENU_GROUP_COMMAND:New(rec.Group, "Info", sub, function()
      local info = string.format("TASKING [%d]\nType: %s\nDesc: %s\nLoc: %s", id, t.Type, t.Desc, t.Location and t.Location:ToStringMGRS() or "N/A")
      MESSAGE:New(info, INFO_DURATION):ToGroup(rec.Group)
    end)
    
    MENU_GROUP_COMMAND:New(rec.Group, "Coords", sub, function()
      if t.Location then
        local mgrs = t.Location:ToStringMGRS()
        local ll = t.Location:ToStringLLDDM()
        local lat, lon = t.Location:GetLat(), t.Location:GetLon()
        local msg = string.format("MGRS: %s\nLL DDM: %s\nLL DD: %.6f, %.6f", mgrs, ll, lat, lon)
        MESSAGE:New(msg, 60):ToGroup(rec.Group)
      else
        MESSAGE:New("No location data available.", 10):ToGroup(rec.Group)
      end
    end)
    
    MENU_GROUP_COMMAND:New(rec.Group, "Accept (Player)", sub, function()
      local ok, msg = TCS.Controller:AcceptTasking(id, rec.Group, "PLAYER")
      MESSAGE:New(msg, ACTION_DURATION):ToGroup(rec.Group)
      TCS.Menu.BuildTasking(rec) -- Refresh after accept
    end)

    MENU_GROUP_COMMAND:New(rec.Group, "Request AI", sub, function()
      local ok, msg = TCS.Controller:AcceptTasking(id, rec.Group, "AI")
      MESSAGE:New(msg, ACTION_DURATION):ToGroup(rec.Group)
      TCS.Menu.BuildTasking(rec)
    end)
  end

  if count == 0 then
    local cmd = MENU_GROUP_COMMAND:New(rec.Group, "(No Active Taskings)", m, function() end)
    table.insert(rec.Menus.Tasking, cmd)
  end

  -- Auto-Refresh Monitor
  rec.TaskingState = rec.TaskingState or {}
  rec.TaskingState.LastSig = sig
  rec.TaskingState.LastIds = ids -- Store ID list for comparison
  
  if not rec.TaskingState.MonitorRunning then
    rec.TaskingState.MonitorRunning = true
    local function check()
       if not rec.Group or not rec.Group:IsAlive() then return end
       
       local currentTaskings = TCS.Controller and TCS.Controller.Taskings or {}
       local cIds = {}
       for id, _ in pairs(currentTaskings) do table.insert(cIds, id) end
       table.sort(cIds, _safeSort)
       local currentSig = ""
       local currentIdSet = {}
       for _, id in ipairs(cIds) do 
         currentSig = currentSig .. tostring(id) .. "," 
         currentIdSet[id] = true
       end
       
       if currentSig ~= rec.TaskingState.LastSig then
          -- Check for new tasks
          if rec.TaskingState.LastIds then
             for _, newId in ipairs(cIds) do
                local isNew = true
                for _, oldId in ipairs(rec.TaskingState.LastIds) do
                   if newId == oldId then isNew = false; break end
                end
                if isNew then MESSAGE:New("New Tasking Available: " .. tostring(currentTaskings[newId].Type), NOTIFICATION_DURATION):ToGroup(rec.Group) end
             end
          end
          
          TCS.Menu.BuildTasking(rec)
       end
       
       timer.scheduleFunction(check, nil, timer.getTime() + REFRESH_INTERVAL)
    end
    timer.scheduleFunction(check, nil, timer.getTime() + REFRESH_INTERVAL)
  end
end