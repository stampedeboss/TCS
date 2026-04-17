---------------------------------------------------------------------
-- TCS TASKING API (A2A)
-- Public API for programmatic tasking of Air-to-Air capabilities.
---------------------------------------------------------------------
env.info("TCS(API.A2A): loading")

TCS = TCS or {}
TCS.API = TCS.API or {}

-- The following API calls delegate creation and tracking to the Task Manager.
-- The 'group' parameter is optional to allow SYSTEM driven tasks, but
-- any other task-specific parameters are required.

--- Triggers a CAP (Combat Air Patrol) mission.
-- @param params (table) { group?, echelon?, session? }
function TCS.API.CreateCAP(params)
  -- Delegate creation and tracking to the Task Manager, group is optional for SYSTEM tasks
  return TCS.TaskManager.Create("CAP", params)
end

--- Triggers an Intercept mission.
-- @param params (table) { group?, echelon?, session? }
function TCS.API.CreateIntercept(params)
   -- Delegate creation and tracking to the Task Manager, group is optional for SYSTEM tasks
  return TCS.TaskManager.Create("INTERCEPT", params)
end

--- Triggers a Fighter Sweep mission.
-- @param params (table) { group?, echelon?, session? }
function TCS.API.CreateSweep(params)
   -- Delegate creation and tracking to the Task Manager, group is optional for SYSTEM tasks
  return TCS.TaskManager.Create("SWEEP", params)
end

--- Triggers an Escort mission.
-- @param params (table) { group?, package, session? }
-- @param package (string) The type of package to escort (e.g., "STRIKE", "CAS", "HVAA").
function TCS.API.CreateEscort(params)
    if not params or not params.package then
        env.error("TCS(API): CreateEscort missing required parameter: package")
        return
    end

  -- Delegate creation and tracking to the Task Manager, group is optional for SYSTEM tasks
  return TCS.TaskManager.Create("ESCORT", params)
end

--- Triggers a Fighter Training mission
-- @param params (table) {group?, mode?, session?}
-- @param mode the mode of training
function TCS.API.CreateA2ATraining_H2H(params)
    if not params or not params.mode then
        env.error("TCS(API): CreateA2ATraining_H2H missing required parameter: mode")
    return
  end

   -- Delegate creation and tracking to the Task Manager, group is optional for SYSTEM tasks
  return TCS.TaskManager.Create("ESCORT", params)
end

env.info("TCS(API.A2A): ready")