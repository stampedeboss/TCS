---------------------------------------------------------------------
-- TCS DIRECT: CUSTOM
-- Streamlined positional and table-aware entry points for custom spawns.
---------------------------------------------------------------------
env.info("TCS(DIRECT.CUSTOM): loading")

TCS = TCS or {}
TCS.Direct = TCS.Direct or {}
TCS.Direct.Custom = {}

--- Streamlined Custom Spawn Trigger
function TCS.Direct.Custom.Spawn(params)
    if not TCS.Mission or not TCS.Mission.Architect then return nil end
    -- Pass the demand to the Mission Architect
    return TCS.Mission.Architect.Build("SPAWN", params)
end

-- Re-home the old global trigger to the new Direct logic
_G.TriggerSystemSpawn = TCS.Direct.Custom.Spawn

env.info("TCS(DIRECT.CUSTOM): ready")