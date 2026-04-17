---------------------------------------------------------------------
-- TCS TASK MANAGER
--
-- Purpose:
--   Centralized creation, tracking, and lifecycle management for
--   all tasks generated via the TCS.API.
---------------------------------------------------------------------
env.info("TCS(CORE.TASK_MANAGER): loading")

TCS = TCS or {}
TCS.TaskManager = {}

local _tasks = {}
local _nextTaskId = 1

-- Dispatch table for mapping task types to their handler functions.
-- This replaces the large if/elseif block for better scalability.
local _taskHandlers = {
  -- Unified Architect-driven Tasks
  STRIKE = function(rec, params) return TCS.Mission.Architect.Build("STRIKE", params) end,
  CAS = function(rec, params) return TCS.Mission.Architect.Build("CAS", params) end,
  BAI = function(rec, params) return TCS.Mission.Architect.Build("BAI", params) end,
  SPAWN = function(rec, params) return TCS.Mission.Architect.Build("SPAWN", params) end,
  SEAD = function(rec, params) return TCS.Mission.Architect.Build("SEAD", params) end,
  DEAD = function(rec, params) return TCS.Mission.Architect.Build("DEAD", params) end,
  CAP = function(rec, params) return TCS.Mission.Architect.Build("CAP", params) end,
  SWEEP = function(rec, params) return TCS.Mission.Architect.Build("SWEEP", params) end,
  INTERCEPT = function(rec, params) return TCS.Mission.Architect.Build("INTERCEPT", params) end,
  ESCORT = function(rec, params) return TCS.Mission.Architect.Build("ESCORT", params) end,
  SUW_ANTISHIP = function(rec, params) return TCS.Mission.Architect.Build("SUW_ANTISHIP", params) end,
  SUW_STRIKE = function(rec, params) return TCS.Mission.Architect.Build("SUW_STRIKE", params) end,
  MAR_HARBOR = function(rec, params) return TCS.Mission.Architect.Build("MAR_HARBOR", params) end,
  DSAM = function(rec, params) return TCS.Mission.Architect.Build("DSAM", params) end,

  -- Training Tasks (Maintained separately for Range logic)
  RANGE = function(rec, params) return TCS.RANGE and TCS.RANGE:Start(rec, params.config, params) end,
 }
 
--- Creates and registers a new task.
-- This is the primary entry point called by the API layer.
-- @param taskType (string) The type of task (e.g., "STRIKE", "CAS", "CAP").
-- @param params (table) The parameter table from the API call.
-- @return (number|nil) The ID of the created task, or nil on failure.
function TCS.TaskManager.Create(taskType, params)
  local taskId = _nextTaskId
  _nextTaskId = _nextTaskId + 1

  local rec = {
    Group = params.group,
    Unit = params.group and params.group:GetUnit(1),
    Session = nil -- Resolved below
  }
  if params.group then
    rec.Session = TCS.Common.SessionManager:GetOrCreateSessionForGroup(params.group)
  else
    rec.Session = TCS.Common.SessionManager:Ensure("SYSTEM")
  end

  -- 1. Ensure Anchor Resolution
  if params.anchor and TCS.Scenario and TCS.Scenario.ResolveZone then
    local resolvedZone, zoneOverrides = TCS.Scenario.ResolveZone(params.anchor)
    params.anchor = resolvedZone or params.anchor

    if zoneOverrides then
      for k, v in pairs(zoneOverrides) do
        if params[k] == nil then
          params[k] = v
        end
      end
    end
  end

  params.taskType = taskType
  rec.Params = params

  -- 2. Validate essential parameters before dispatch
  if not params.anchor then
    env.error(string.format("TCS(TASK_MANAGER): Task %s aborted - No valid anchor/zone.", taskType))
    return nil
  end

  local handler = _taskHandlers[taskType]
  if not handler then
      env.error("TCS(TASK_MANAGER): Unknown taskType: " .. tostring(taskType))
      return nil
  end

  local taskHandle = handler(rec, params)

  -- Allow params to override the default module duration
  if taskHandle and params.duration then
    taskHandle.Duration = params.duration
  end

  -- Handle special cases like RESET_RANGE that don't return a trackable handle
  if taskHandle == "NO_HANDLE" then return end

  if not taskHandle then
    env.error("TCS(TASK_MANAGER): Core module for " .. taskType .. " failed to start or return a task handle.")
    return nil
  end

  _tasks[taskId] = {
    Id = taskId,
    Type = taskType,
    Status = "ACTIVE",
    Handle = taskHandle,
    Params = params,
    Rec = rec,
    StartTime = timer.getTime(),
  }

  env.info("TCS(TASK_MANAGER): Created Task #" .. taskId .. " of type " .. taskType)
  if rec.Group then
    TCS.MsgToGroup(rec.Group, "Tasking #" .. taskId .. " (" .. taskType .. ") assigned.", 10)
  end

  return taskId
end

--- Retrieves a task by its ID.
function TCS.TaskManager.GetTask(taskId)
  return _tasks[taskId]
end

--- Ends a task and cleans up its resources.
function TCS.TaskManager.EndTask(taskId, reason)
  local task = _tasks[taskId]
  if not task then return end

  env.info("TCS(TASK_MANAGER): Ending Task #" .. taskId .. ". Reason: " .. reason)
  task.Status = reason

  -- Call the Terminate method on the handle, if it exists.
  if task.Handle and task.Handle.Terminate then
    pcall(function() task.Handle:Terminate(reason) end)
  end

  -- Resolve final respawn parameters
  local shouldRespawn = task.Params.respawn
  local respawnDelay = task.Params.respawnDelay or 300

  -- Handle Recreation/Respawn for System Tasks
  -- Only respawn if it's a system task, has the respawn flag, and didn't end via manual termination
  if not task.Params.group and shouldRespawn then
    if reason == "COMPLETE" or reason == "TIMEOUT" or reason == "ENEMY_ROUTED" or reason == "ENEMY_WIPED" then
      env.info(string.format("TCS(TASK_MANAGER): Task #%d (%s) scheduled for recreation in %d seconds.", taskId, task.Type, respawnDelay))
      timer.scheduleFunction(function()
        TCS.TaskManager.Create(task.Type, task.Params)
      end, nil, timer.getTime() + respawnDelay)
    end
  end

  -- The core Scenario.Stop() function handles the actual despawning of registered objects.
  -- The task manager's role is primarily state tracking.

  _tasks[taskId] = nil -- Remove from active tasks
end

-- Internal monitoring loop to check for completed tasks.
local function _monitorTasks()
  for id, task in pairs(_tasks) do
    if task.Handle and task.Handle.IsOver then
      local status, isOver, reason = pcall(function() return task.Handle:IsOver() end)
      if status and isOver then
        TCS.TaskManager.EndTask(id, reason or "COMPLETE")
      end
    end
  end
  return timer.getTime() + 15 -- Check every 15 seconds
end

-- Start the monitoring loop
timer.scheduleFunction(_monitorTasks, nil, timer.getTime() + 15)

env.info("TCS(CORE.TASK_MANAGER): ready")