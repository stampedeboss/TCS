---------------------------------------------------------------------
-- TCS MISSION ARCHITECT
-- Director Layer: Assembles component requisitions into an Environment.
-- NOTE: Eventually, every tower will eventually needs to be tracking supply against consumption.
---------------------------------------------------------------------
TCS = TCS or {}
TCS.Mission = TCS.Mission or {}
TCS.Mission.Architect = {}

-- Mission-Specific Setup Defaults (Extracted from legacy A2G config)
TCS.Mission.Architect.Defaults = {
    BAI = { minNm = 15, maxNm = 25, transitTime = 20 },
    CAS = { separationNm = 3 },
    SPAWN = { minNm = 5, maxNm = 10 },
    REINFORCE_THRESHOLD = 0.65
}

--- Builds a Target Environment Specification
-- @param missionType (string) "BAI", "CAS"
-- @param params (table) High-level intent (anchor, echelon, skill, etc.)
function TCS.Mission.Architect.Build(missionType, params)
    local zoneName = type(params.anchor) == "string" and params.anchor or nil
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

    -- Ensure a default coalition exists for component queries
    params.coalition = params.coalition or coalition.side.RED

    params.anchor = anchor -- Update params so everyone uses the object

    local envSpec = {
        missionType = missionType,
        anchor = anchor,
        components = {},
        successCriteria = {}
    }

    if missionType == "BAI" then
        -- Apply intent-based defaults for spawn geometry
        params.minNm = params.minNm or TCS.Mission.Architect.Defaults.BAI.minNm
        params.maxNm = params.maxNm or TCS.Mission.Architect.Defaults.BAI.maxNm
        params.transitTime = params.transitTime or TCS.Mission.Architect.Defaults.BAI.transitTime

        -- Requisition: Enemy column + Mobile AAA protection
        table.insert(envSpec.components, TCS.Towers.Ground.PrepareRequisition("MECH_INF", params))
        table.insert(envSpec.components, TCS.Towers.Ground.PrepareRequisition("MOBILE_AAA", params))

        envSpec.successCriteria = {
            { type = "ATTRITION", missionType = missionType, target = "ALL_ENEMY", threshold = TCS.Mission.Architect.Defaults.REINFORCE_THRESHOLD, result = "ENEMY_ROUTED" }
        }

    elseif missionType == "CAS" then
        -- Recipe: Enemy and Friendly forces converging
        local sep = params.separationNm or TCS.Mission.Architect.Defaults.CAS.separationNm
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
        params.minNm = params.minNm or TCS.Mission.Architect.Defaults.SPAWN.minNm
        params.maxNm = params.maxNm or TCS.Mission.Architect.Defaults.SPAWN.maxNm

        -- Direct Demand: Bypasses standard recipes
        table.insert(envSpec.components, TCS.Towers.Ground.PrepareRequisition("SPAWN", params))
        -- Success is simple elimination
        envSpec.successCriteria = { { type = "ATTRITION", target = "ALL_ENEMY", threshold = 0.90, result = "COMPLETE" } }

    elseif missionType == "STRIKE" then
        -- Strike: Fixed objective (for now MECH_INF until structures are implemented)
        table.insert(envSpec.components, TCS.Towers.Ground.PrepareRequisition("MECH_INF", params))
        envSpec.successCriteria = {
            { type = "ATTRITION", missionType = missionType, target = "ALL_ENEMY", threshold = 0.70, result = "COMPLETE" }
        }

    elseif missionType == "DSAM" or missionType == "SEAD" or missionType == "DEAD" then
        -- SAM-centric missions: Focus on doctrinal site generation
        local samType = params.samType or "SA-6"
        table.insert(envSpec.components, TCS.Towers.AirDef.PrepareRequisition(samType, params))
        
        if missionType == "DEAD" then
            -- DEAD missions: Protecting high-value ground assets (Armor and Infantry) near the site
            local guardParams = {}
            for k,v in pairs(params) do guardParams[k] = v end
            guardParams.minNm = 0.5
            guardParams.maxNm = 2
            
            table.insert(envSpec.components, TCS.Towers.Ground.PrepareRequisition("ARMOR_STRIKE", guardParams))
            table.insert(envSpec.components, TCS.Towers.Ground.PrepareRequisition("INFANTRY", guardParams))
        end

        local resultMsg = (missionType == "DEAD") and "AREA_CLEARED" or "RADARS_SUPPRESSED"
        envSpec.successCriteria = {
            { type = "ATTRITION", missionType = missionType, target = "ALL_ENEMY", threshold = 0.50, result = resultMsg }
        }

    elseif missionType == "CAP" or missionType == "SWEEP" or missionType == "INTERCEPT" or missionType == "ESCORT" then
        -- A2A Missions: Utilize the Air Tower
        table.insert(envSpec.components, TCS.Towers.Air.PrepareRequisition(missionType, params))
        envSpec.successCriteria = {
            { type = "ATTRITION", target = "ALL_ENEMY", threshold = 0.90, result = "AREA_CLEARED" }
        }

    elseif missionType == "SUW_ANTISHIP" or missionType == "SUW_STRIKE" or missionType == "MAR_HARBOR" then
        -- Maritime Missions: Resolve Force Type
        local force = "SAG"
        if missionType == "MAR_HARBOR" then force = "HARBOR" end
        if missionType == "SUW_STRIKE" then force = "CONVOY" end

        table.insert(envSpec.components, TCS.Towers.Maritime.PrepareRequisition(force, params))
        envSpec.successCriteria = {
            { type = "ATTRITION", target = "ALL_ENEMY", threshold = 0.70, result = "OBJECTIVE_DESTROYED" }
        }
    end

    -- Dispatch to Common for Execution
    if TCS.Common and TCS.Common.Dispatcher and TCS.Common.Dispatcher.Execute then
        local result = TCS.Common.Dispatcher.Execute(envSpec, params)
        
        -- 3. Visual Feedback: Draw the mission area on the F10 Map
        if result and TCS.Common.Scenario.F10 and trigger.misc.getUserFlag(285000) <= 9 then
            local session = TCS.Common.SessionManager:GetOrCreateSessionForGroup(params.group)
            TCS.Common.Scenario.F10.Draw(session, missionType, anchor, params.echelon, 5000, zoneName, params.ingressHdg, params.ingressArc)
        end
        
        return result
    end

    return nil
end

--- Issues a tactical override command to all units in a session.
-- @param command (string) "ADVANCE" or "RETREAT"
-- @param params (table) { session, anchor, speed }
function TCS.Mission.Architect.IssueCommand(command, params)
    params = params or {}
    local sessionName = params.session or "SYSTEM"
    local anchor = params.anchor
    
    -- Resolve anchor to coordinate if it's a zone name
    if type(anchor) == "string" then
        local z = ZONE:FindByName(anchor)
        anchor = z and z:GetCoordinate() or nil
    end

    if not anchor then return false end

    -- Iterate through all active tasks in the Tracker
    for _, task in pairs(TCS.Common.Tracker.Tasks) do
        if task.Session and task.Session.Name == sessionName then
            for _, g in ipairs(task.Groups) do
                if g and g:IsAlive() then
                    if command == "ADVANCE" then
                        TCS.Towers.Ground.Behavior.ApplyBehavior(g, { 
                            mode = "ADVANCE", target = anchor, 
                            speedKph = params.speed or 30 
                        })
                    elseif command == "RETREAT" then
                        local retreatPt = TCS.Towers.Ground.Behavior.GetRetreatPoint(anchor, g:GetCoordinate())
                        TCS.Towers.Ground.Behavior.ApplyBehavior(g, { 
                            mode = "ADVANCE", target = retreatPt, 
                            speedKph = 45, onRoad = true 
                        })
                    end
                end
            end
        end
    end
    return true
end

-- Global triggers map to this architect
_G.TriggerMissionBAI = function(p) return TCS.Mission.Architect.Build("BAI", p) end
_G.TriggerMissionCAS = function(p) return TCS.Mission.Architect.Build("CAS", p) end
_G.TriggerSystemDSAM = function(p) return TCS.Mission.Architect.Build("DSAM", p) end
_G.TriggerSystemBAI = function(p) return TCS.Mission.Architect.Build("BAI", p) end
_G.TriggerSystemStrike = function(p) return TCS.Mission.Architect.Build("STRIKE", p) end
_G.TriggerSystemSEAD = function(p) return TCS.Mission.Architect.Build("SEAD", p) end
_G.TriggerSystemDEAD = function(p) return TCS.Mission.Architect.Build("DEAD", p) end
_G.TriggerSystemCAS = function(p) return TCS.Mission.Architect.Build("CAS", p) end

env.info("TCS(MISSION.ARCHITECT): ready")