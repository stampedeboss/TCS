---------------------------------------------------------------------
-- TCS TASKING API (TRAINING)
-- Public API for programmatic tasking of Training capabilities.
---------------------------------------------------------------------
env.info("TCS(API.TRAINING): loading")

TCS = TCS or {}
TCS.API = TCS.API or {}

--- Resolves the session for an API call.
local function _resolveSession(params)
  if params.session then return params.session end
  if params.group then
    return TCS.SessionManager:GetOrCreateSessionForGroup(params.group)
  end
  return nil
end

--- Creates a Training Range.
-- @param params (table) { group, config, session? }
function TCS.API.CreateRange(params)
  if not params or not params.config then
    env.error("TCS(API): CreateRange missing parameters (config required)")
    return
  end

  return TCS.TaskManager.Create("RANGE", params)
end

--- Resets/Clears the Training Range for a session.
-- @param params (table) { group, session? }
function TCS.API.ResetRange(params)
  -- This is a fire-and-forget action, but we can route it through the manager for consistency.
  return TCS.TaskManager.Create("RESET_RANGE", params)
end

env.info("TCS(API.TRAINING): ready")