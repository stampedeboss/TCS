---------------------------------------------------------------------
-- TCS TASKING API (MARITIME)
-- Public API for programmatic tasking of Maritime capabilities.
---------------------------------------------------------------------
env.info("TCS(API.MAR): loading")

TCS = TCS or {}
TCS.API = TCS.API or {}

--- Triggers a Harbor Control mission.
-- @param params (table) { group, session? }
function TCS.API.CreateMAR_Harbor(params)
  return TCS.TaskManager.Create("MAR_HARBOR", params)
end

--- Triggers a Shipping Lane Control mission.
-- @param params (table) { group, session? }
function TCS.API.CreateMAR_Shipping(params)
  return TCS.TaskManager.Create("MAR_SHIPPING", params)
end

env.info("TCS(API.MAR): ready")