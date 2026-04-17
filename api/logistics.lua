---------------------------------------------------------------------
-- TCS TASKING API (LOGISTICS)
-- Public API for programmatic tasking of Logistics capabilities.
---------------------------------------------------------------------
env.info("TCS(API.LOGISTICS): loading")

TCS = TCS or {}
TCS.API = TCS.API or {}

--- Triggers a Logistics convoy run.
-- @param params (table) { group, destination, echelon, session? }
function TCS.API.CreateLogisticsRun(params)
  if not params or not params.destination then
    env.error("TCS(API): CreateLogisticsRun missing required parameter: destination")
    return
  end

  return TCS.TaskManager.Create("LOGISTICS", params)
end

env.info("TCS(API.LOGISTICS): ready")