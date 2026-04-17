---------------------------------------------------------------------
-- api/a2g.lua
-- Public API for programmatic tasking of Air-to-Ground capabilities.
---------------------------------------------------------------------
env.info("TCS(API.A2G): loading")

TCS = TCS or {}
TCS.API = TCS.API or {}

--- Triggers a Strike mission.
-- @param params (table) { anchor, echelon, group?, coalition, session? }
function TCS.API.CreateStrike(params)
  if not params or not params.anchor then
    env.error("TCS(API): CreateStrike missing required parameter: anchor")
    return
  end

  -- Delegate creation and tracking to the Task Manager, group is optional for SYSTEM tasks
  return TCS.TaskManager.Create("STRIKE", params)
end

--- Triggers a SEAD mission.
-- @param params (table) { anchor, echelon, group?, coalition, session? }
function TCS.API.CreateSEAD(params)
  if not params or not params.anchor then
    env.error("TCS(API): CreateSEAD missing required parameter: anchor")
    return
  end

   -- Delegate creation and tracking to the Task Manager, group is optional for SYSTEM tasks
  return TCS.TaskManager.Create("SEAD", params)
end

--- Triggers a CAS mission.
-- @param params (table) { anchor, echelon, group?, coalition, session? }
function TCS.API.CreateCAS(params)
  if not params or not params.anchor then
    env.error("TCS(API): CreateCAS missing required parameter: anchor")
    return
  end

   -- Delegate creation and tracking to the Task Manager, group is optional for SYSTEM tasks
  return TCS.TaskManager.Create("CAS", params)
end

--- Triggers a BAI mission.
-- @param params (table) { anchor, echelon, group?, coalition, session? }
function TCS.API.CreateBAI(params)
  if not params or not params.anchor then
    env.error("TCS(API): CreateBAI missing required parameter: anchor")
    return
  end

   -- Delegate creation and tracking to the Task Manager, group is optional for SYSTEM tasks
  return TCS.TaskManager.Create("BAI", params)
end

--- Triggers a DEAD mission.
-- @param params (table) { anchor, echelon, group, coalition, session? }
function TCS.API.CreateDEAD(params)
  if not params or not params.anchor then
    env.error("TCS(API): CreateDEAD missing required parameter: anchor")
    return
  end

   -- Delegate creation and tracking to the Task Manager, group is optional for SYSTEM tasks
  return TCS.TaskManager.Create("DEAD", params)
end

env.info("TCS(API.A2G): ready")