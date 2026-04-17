--- TCS API: A2A Triggers (Keyword Table Pattern)
TCS = TCS or {}

function TriggerSystemCAP(args)
    if not TCS.TaskManager then return nil end
    args = args or {}
    return TCS.TaskManager.Create("CAP", {
        anchor = args.anchor,
        echelon = args.echelon,
        coalition = args.coalition or coalition.side.RED,
        respawn = args.respawn,
        duration = args.duration,
        respawnDelay = args.respawnDelay,
        group = nil
    })
end

function TriggerSystemSweep(args)
    if not TCS.TaskManager then return nil end
    args = args or {}
    return TCS.TaskManager.Create("SWEEP", {
        anchor = args.anchor,
        echelon = args.echelon,
        coalition = args.coalition or coalition.side.RED,
        respawn = args.respawn,
        duration = args.duration,
        respawnDelay = args.respawnDelay,
        group = nil
    })
end