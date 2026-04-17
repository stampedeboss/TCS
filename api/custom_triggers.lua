--- TCS API: Custom Spawning Triggers
TCS = TCS or {}
TCS.A2G = TCS.A2G or {}
TCS.A2G.Echelons = TCS.A2G.Echelons or {}
-- Define a 1:1 scale echelon for specific spawns to ensure proper labeling and spawner compatibility
TCS.A2G.Echelons["SPAWN"] = { scale = 1.0, spacing = 150, label = "Spawn Force" }

function TriggerSystemSpawn(args)
    if not TCS.TaskManager then return nil end
    args = args or {}

    local requestedTiers = TCS.ResolveTierFilter(args.skill or 2)

    local params = {
        anchor = args.anchor,
        echelon = "SPAWN", -- Absolute count ignores echelon scale
        force = args.composition,
        tier = requestedTiers,
        absoluteCount = true,
        minNm = args.minNm,
        maxNm = args.maxNm,
        coalition = args.coalition,
        respawn = args.respawn,
        duration = args.duration,
        respawnDelay = args.respawnDelay,
        reinforce = args.reinforce,
        group = nil,
        ingressHdg = args.ingressHdg,
        ingressArc = args.ingressArc
    }
    
    env.info("TCS(TRIGGER): Creating System Spawn task at " .. tostring(args.anchor))
    return TCS.TaskManager.Create("SPAWN", params)
end