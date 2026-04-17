---------------------------------------------------------------------
-- TCS MISSION ARCHITECT
-- Director Layer: Assembles component requisitions into an Environment.
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Mission = TCS.Mission or {}
TCS.Mission.Architect = {}

--- Builds a Target Environment Specification
-- @param missionType (string) "BAI", "CAS"
-- @param params (table) High-level intent (anchor, echelon, skill, etc.)
function TCS.Mission.Architect.Build(missionType, params)
    -- 0. Resolve Anchor into a Coordinate Object immediately.
    -- This ensures that all downstream specialists (Towers, Spawners, Behaviors)
    -- are working with a valid location object instead of raw strings.
    local anchor = params.anchor
    if type(anchor) == "string" then
        local z = ZONE:FindByName(anchor)
        anchor = z and z:GetCoordinate() or nil
    elseif type(anchor) == "table" and anchor.GetCoordinate then
        anchor = anchor:GetCoordinate()
    end

    if not anchor then
        env.error(string.format("TCS(MISSION.ARCHITECT): Failed to resolve anchor '%s' for %s. Ensure the Trigger Zone exists in ME.", tostring(params.anchor), missionType))
        return nil
    end

    params.anchor = anchor -- Update params so everyone uses the object

    local envSpec = {
        missionType = missionType,
        anchor = anchor,
        components = {},
        successCriteria = {}
    }

    if missionType == "BAI" then
        -- Apply intent-based defaults for spawn geometry
        params.minNm = params.minNm or TCS.Config.Ground.Defaults.MISSION_DEFAULTS.BAI.minNm
        params.maxNm = params.maxNm or TCS.Config.Ground.Defaults.MISSION_DEFAULTS.BAI.maxNm
        params.transitTime = params.transitTime or TCS.Config.Ground.Defaults.MISSION_DEFAULTS.BAI.transitTime

        -- Requisition: Enemy column + Mobile AAA protection
        table.insert(envSpec.components, TCS.Towers.Ground.PrepareRequisition("MECH_INF", params))
        table.insert(envSpec.components, TCS.Towers.Ground.PrepareRequisition("MOBILE_AAA", params))

        envSpec.successCriteria = {
            { type = "ATTRITION", missionType = missionType, target = "ALL_ENEMY", threshold = TCS.Config.Ground.Defaults.MISSION_DEFAULTS.REINFORCE_THRESHOLD, result = "ENEMY_ROUTED" }
        }

    elseif missionType == "CAS" then
        -- Recipe: Enemy and Friendly forces converging
        local sep = params.separationNm or TCS.Config.Ground.Defaults.MISSION_DEFAULTS.CAS.separationNm
        params.minNm = params.minNm or sep
        params.maxNm = params.maxNm or sep

        local enemyParams = params
        local friendlyParams = {}
        for k,v in pairs(params) do friendlyParams[k] = v end
        
        friendlyParams.coalition = (params.coalition == coalition.side.RED) and coalition.side.BLUE or coalition.side.RED
        friendlyParams.interaction = "CONVERGE"

        table.insert(envSpec.components, TCS.Towers.Ground.PrepareRequisition("MECH_INF", enemyParams))
        table.insert(envSpec.components, TCS.Towers.Ground.PrepareRequisition("MECH_INF", friendlyParams))

        envSpec.successCriteria = {
            { type = "ATTRITION", target = "ALL_ENEMY", threshold = 0.65, result = "ENEMY_ROUTED" },
            { type = "ATTRITION", target = "ALL_FRIENDLY", threshold = 0.50, result = "FRIENDLY_OVERRUN" }
        }

    elseif missionType == "SPAWN" then
        params.minNm = params.minNm or TCS.Config.Ground.Defaults.MISSION_DEFAULTS.SPAWN.minNm
        params.maxNm = params.maxNm or TCS.Config.Ground.Defaults.MISSION_DEFAULTS.SPAWN.maxNm

        -- Direct Demand: Bypasses standard recipes
        table.insert(envSpec.components, TCS.Towers.Ground.PrepareRequisition("SPAWN", params))
        -- Success is simple elimination
        envSpec.successCriteria = { { type = "ATTRITION", target = "ALL_ENEMY", threshold = 0.90, result = "COMPLETE" } }

    elseif missionType == "STRIKE" or missionType == "SEAD" or missionType == "DEAD" then
        -- Simplified recipes for testing ground-based air defense and structures
        local force = (missionType == "STRIKE") and "MECH_INF" or "MOBILE_AAA"
        table.insert(envSpec.components, TCS.Towers.Ground.PrepareRequisition(force, params))
        
        envSpec.successCriteria = {
            { type = "ATTRITION", target = "ALL_ENEMY", threshold = 0.70, result = "COMPLETE" }
        }
    end

    -- Dispatch to Common for Execution
    if TCS.Common and TCS.Common.Dispatcher and TCS.Common.Dispatcher.Execute then
        local result = TCS.Common.Dispatcher.Execute(envSpec, params)
        
        -- 3. Visual Feedback: Draw the mission area on the F10 Map
        if result and TCS.Common.Scenario.F10 then
            local session = TCS.Common.SessionManager:GetOrCreateSessionForGroup(params.group)
            TCS.Common.Scenario.F10.Draw(session, missionType, anchor, params.echelon, 5000)
        end
        
        return result
    end

    return nil
end

-- Global triggers map to this architect
_G.TriggerMissionBAI = function(p) return TCS.Mission.Architect.Build("BAI", p) end
_G.TriggerMissionCAS = function(p) return TCS.Mission.Architect.Build("CAS", p) end
_G.TriggerSystemBAI = function(p) return TCS.Mission.Architect.Build("BAI", p) end
_G.TriggerSystemStrike = function(p) return TCS.Mission.Architect.Build("STRIKE", p) end
_G.TriggerSystemSEAD = function(p) return TCS.Mission.Architect.Build("SEAD", p) end
_G.TriggerSystemDEAD = function(p) return TCS.Mission.Architect.Build("DEAD", p) end
_G.TriggerSystemCAS = function(p) return TCS.Mission.Architect.Build("CAS", p) end

env.info("TCS(MISSION.ARCHITECT): ready")