---------------------------------------------------------------------
-- TCS TASKING API (AIR)
-- Public API for programmatic tasking of Air-to-Air capabilities.
---------------------------------------------------------------------
env.info("TCS(API.AIR): loading")

TCS = TCS or {}
TCS.API = TCS.API or {}

-- Legacy Task Manager parameters are intercepted and mapped to the Architect.
local function _resolveAnchor(params)
    if not params.anchor and params.group then
        local u = params.group:GetUnit(1)
        if u and u:IsAlive() then 
            params.anchor = u:GetCoordinate() 
            params.ingressHdg = u:GetHeading()
        end
    end
    return params
end

--- Triggers a CAP (Combat Air Patrol) mission.
-- @param params (table) { group?, echelon?, session? }
function TCS.API.CreateCAP(params)
  if not _G.TriggerSystemCAP then return nil end
  return _G.TriggerSystemCAP(_resolveAnchor(params))
end

--- Triggers an Intercept mission.
-- @param params (table) { group?, echelon?, session? }
function TCS.API.CreateIntercept(params)
  if not _G.TriggerSystemIntercept then return nil end
  return _G.TriggerSystemIntercept(_resolveAnchor(params))
end

--- Triggers a Fighter Sweep mission.
-- @param params (table) { group?, echelon?, session? }
function TCS.API.CreateSweep(params)
  if not _G.TriggerSystemSweep then return nil end
  return _G.TriggerSystemSweep(_resolveAnchor(params))
end

--- Triggers an Escort mission.
-- @param params (table) { group?, package, session? }
-- @param package (string) The type of package to escort (e.g., "STRIKE", "CAS", "HVAA").
function TCS.API.CreateEscort(params)
    if not params or not params.package then
        env.error("TCS(API): CreateEscort missing required parameter: package")
        return
    end

  if not _G.TriggerSystemEscort then return nil end
  return _G.TriggerSystemEscort(_resolveAnchor(params))
end

--- Triggers a Fighter Training mission
-- @param params (table) {group?, mode?, session?}
-- @param mode the mode of training
function TCS.API.CreateAirTraining_H2H(params)
    if not params or not params.mode then
        env.error("TCS(API): CreateAirTraining_H2H missing required parameter: mode")
    return
  end

  local p = _resolveAnchor(params)
  if params.mode == "FOX2" then p.minNm = 10; p.maxNm = 10 end
  if _G.TriggerSystemH2H then return _G.TriggerSystemH2H(p) end
end

function TCS.API.CreateAirTraining_Abeam(params)
  if _G.TriggerSystemAbeam then return _G.TriggerSystemAbeam(_resolveAnchor(params)) end
end

function TCS.API.CreateAirTraining_Defensive(params)
  if _G.TriggerSystemDefensive then return _G.TriggerSystemDefensive(_resolveAnchor(params)) end
end

function TCS.API.CreateAirTraining_Drone(params)
  if _G.TriggerSystemDrone then return _G.TriggerSystemDrone(_resolveAnchor(params)) end
end

env.info("TCS(API.AIR): ready")