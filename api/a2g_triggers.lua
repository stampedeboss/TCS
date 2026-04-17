--- TCS API: A2G Triggers (Keyword Table Pattern)
TCS = TCS or {}

function TriggerBAI(args)
    args = args or {}
    if not TCS.TaskManager then return end
    local coal = args.coalition or (args.group and args.group:GetCoalition()) or coalition.side.RED
    return TCS.TaskManager.Create("BAI", {
        group = args.group, anchor = args.anchor,
        echelon = args.echelon,
        minNm = args.minNm, maxNm = args.maxNm,
        coalition = coal
    })
end

function TriggerSystemBAI(args)
    if not TCS.TaskManager then return nil end
    args = args or {}
    return TCS.TaskManager.Create("BAI", {
        anchor = args.anchor, echelon = args.echelon,
        minNm = args.minNm, maxNm = args.maxNm,
        coalition = args.coalition,
        respawn = args.respawn, duration = args.duration,
        respawnDelay = args.respawnDelay, reinforce = args.reinforce,
        ingressHdg = args.ingressHdg, ingressArc = args.ingressArc,
        group = nil
    })
end

function TriggerSystemStrike(args)
    if not TCS.TaskManager then return nil end
    args = args or {}
    return TCS.TaskManager.Create("STRIKE", {
        anchor = args.anchor, echelon = args.echelon,
        minNm = args.minNm, maxNm = args.maxNm,
        coalition = args.coalition,
        respawn = args.respawn, duration = args.duration,
        respawnDelay = args.respawnDelay,
        ingressHdg = args.ingressHdg, ingressArc = args.ingressArc,
        group = nil
    })
end

function TriggerSystemSEAD(args)
    if not TCS.TaskManager then return nil end
    args = args or {}
    return TCS.TaskManager.Create("SEAD", {
        anchor = args.anchor, echelon = args.echelon,
        minNm = args.minNm, maxNm = args.maxNm,
        coalition = args.coalition,
        respawn = args.respawn, duration = args.duration,
        respawnDelay = args.respawnDelay, reinforce = args.reinforce,
        ingressHdg = args.ingressHdg, ingressArc = args.ingressArc,
        group = nil
    })
end

function TriggerSystemDEAD(args)
    if not TCS.TaskManager then return nil end
    args = args or {}
    return TCS.TaskManager.Create("DEAD", {
        anchor = args.anchor, echelon = args.echelon,
        minNm = args.minNm, maxNm = args.maxNm,
        coalition = args.coalition,
        respawn = args.respawn, duration = args.duration,
        respawnDelay = args.respawnDelay, reinforce = args.reinforce,
        ingressHdg = args.ingressHdg, ingressArc = args.ingressArc,
        group = nil
    })
end

function TriggerSystemCAS(args)
    if not TCS.TaskManager then return nil end
    args = args or {}
    return TCS.TaskManager.Create("CAS", {
        anchor = args.anchor, echelon = args.echelon,
        playerSide = args.playerSide,
        respawn = args.respawn, duration = args.duration,
        respawnDelay = args.respawnDelay,
        skill = args.skill,
        ingressHdg = args.ingressHdg, ingressArc = args.ingressArc,
        group = nil
    })
end