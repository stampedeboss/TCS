---------------------------------------------------------------------
-- TCS DIRECT: CUSTOM
-- Streamlined positional and table-aware entry points for custom spawns.
---------------------------------------------------------------------
env.info("TCS(DIRECT.CUSTOM): loading")

TCS = TCS or {}
TCS.Direct = TCS.Direct or {}
TCS.Direct.Custom = {}

--- Streamlined Custom Deploy Trigger
function TCS.Direct.Custom.Deploy(params)
    if not TCS.Land or not TCS.Land.Architect then return nil end
    -- Pass the demand to the Land Architect
    return TCS.Land.Architect.Build("CUSTOM", params)
end

-- Re-home the old global trigger to the new Direct logic
_G.DeployCustom = TCS.Direct.Custom.Deploy

env.info("TCS(DIRECT.CUSTOM): ready")