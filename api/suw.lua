---------------------------------------------------------------------
-- TCS TASKING API (SUW)
-- Public API for programmatic tasking of Surface Warfare capabilities.
---------------------------------------------------------------------
env.info("TCS(API.SUW): loading")

TCS = TCS or {}
TCS.API = TCS.API or {}

--- Triggers an Anti-Ship mission.
-- @param params (table) { group, session? }
function TCS.API.CreateSUW_AntiShip(params)
   return TCS.TaskManager.Create("SUW_ANTISHIP", params)
end

--- Triggers a Naval Strike mission.
-- @param params (table) { group, session? }
function TCS.API.CreateSUW_NavalStrike(params)
  return TCS.TaskManager.Create("SUW_STRIKE", params)
end

--- Triggers a Convoy mission.
-- @param params (table) { group, session? }
function TCS.API.CreateSUW_Convoy(params)
  return TCS.TaskManager.Create("SUW_CONVOY", params)
end

env.info("TCS(API.SUW): ready")