---------------------------------------------------------------------
-- TCS AIR PLANNER (Tier 1 API)
-- Translates intent-based requests into concrete Architect blueprints.
---------------------------------------------------------------------
env.info("TCS(AIR.PLANNER): loading")

TCS = TCS or {}
TCS.Air = TCS.Air or {}
TCS.Air.Planner = {}

-- The Expected Intent Contract from the Signals Domain:
-- request = {
--   intent = "ACM" | "BVR" | "CAP" | "SWEEP" | "INTERCEPT" | "ESCORT",
--   coalition = number (e.g., coalition.side.RED),
--   anchor = COORDINATE (Primary location / Mark 1),
--   destination = COORDINATE (Optional / Mark 2),
--   tier = "A" | "G" | "H" | "X" (Optional, defaults to G),
--   variant = "GUNS" | "FOX2" (Optional constraints),
--   heading = number (Optional, provides direction context in degrees)
-- }

function TCS.Air.Planner.Execute(request)
    if not request or not request.intent or not request.anchor then 
        return false, "Invalid request: Missing intent or anchor coordinates." 
    end

    local intent = string.upper(request.intent)
    local intentConfig = TCS.Air.Settings and TCS.Air.Settings.INTENT and TCS.Air.Settings.INTENT[intent]

    if not intentConfig then
        return false, string.format("Unknown intent '%s'. No configuration found in settings.", intent)
    end

    local missionType
    local role

    if intent == "ACM" then
        missionType = "BUILD"
        role = "WVR"
    elseif intent == "BVR" then
        missionType = "BUILD"
        role = "BVR"
    else
        missionType = intent
        role = "FIGHTER"
    end

    local params = {
        anchor = request.anchor,
        coalition = request.coalition or coalition.side.RED,
        tier = request.tier or "G",
        var = request.variant,
        role = role,
        minNm = intentConfig.minNm,
        maxNm = intentConfig.maxNm,
        ingressArc = intentConfig.arc
    }

    if request.heading then
        params.anchorHdg = request.heading
    end
    
    if intent == "ESCORT" then
        -- If a 2nd mark was provided, it becomes the destination for the package.
        if request.destination then params.destination = request.destination end
    end

    -- Hand off the detailed blueprint to the Tier 2 Architect
    if TCS.Air.Architect and TCS.Air.Architect.Build then
        local zoneIds = TCS.Air.Architect.Build(missionType, params)
        if zoneIds and #zoneIds > 0 then return true, string.format("%s mission dispatched successfully.", intent) end
        return false, string.format("Failed to generate %s. No era-appropriate assets found in catalog.", intent)
    end

    return false, "Air Architect offline."
end

env.info("TCS(AIR.PLANNER): ready")