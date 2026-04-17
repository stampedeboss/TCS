---------------------------------------------------------------------
-- TCS TASKING API (A2A TRAINING)
-- Public API for programmatic tasking of A2A Training capabilities.
---------------------------------------------------------------------
env.info("TCS(API.A2A_TRAINING): loading")

TCS = TCS or {}
TCS.API = TCS.API or {}

--- Triggers a Head-to-Head BFM/ACM setup.
-- @param params (table) { group, mode, session? } where mode is "GUNS" or "FOX2".
function TCS.API.CreateA2ATraining_H2H(params)
  if not params or not params.group then
    env.error("TCS(API): CreateA2ATraining_H2H missing required parameter: group")
    return
  elseif not params or not params.group then
    env.error("TCS(API): CreateA2ATraining_H2H missing required parameter: group")
    return
  end

  return TCS.TaskManager.Create("A2AT_H2H", params)
end

--- Triggers a Defensive BFM setup.
-- @param params (table) { group, session? }
function TCS.API.CreateA2ATraining_Defensive(params)
    if not params or not params.group then
        env.error("TCS(API): CreateA2ATraining_Defensive missing required parameter: group")
        return
    end

    return TCS.TaskManager.Create("A2AT_DEFENSIVE", params)
end

--- Triggers an Abeam BFM setup.
-- @param params (table) { group, session? }
function TCS.API.CreateA2ATraining_Abeam(params)
    if not params or not params.group then
        env.error("TCS(API): CreateA2ATraining_Abeam missing required parameter: group")
        return
    end

    return TCS.TaskManager.Create("A2AT_ABEAM", params)
end

--- Triggers a Target Drone spawn.
-- @param params (table) { group, session? }
function TCS.API.CreateA2ATraining_Drone(params)
    if not params or not params.group then
        env.error("TCS(API): CreateA2ATraining_Drone missing required parameter: group")
        return
    end

    return TCS.TaskManager.Create("A2AT_DRONE", params)
end

env.info("TCS(API.A2A_TRAINING): ready")